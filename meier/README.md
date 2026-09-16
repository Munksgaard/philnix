# meier: Danish GCompris kiosk

A Lenovo all-in-one PC, provisionally targeting `x86_64-linux`. Confirm the CPU,
firmware, graphics, audio and disk layout on the actual machine before installing.

Both the installed machine and live USB use the Danish translation flake and
recordings already used by the laptops. Cage starts GCompris fullscreen with
`--enable-kioskmode --locale da_DK` and a Danish keyboard layout. There is no full
desktop or display manager. This is a convenience kiosk, not a physical-access
security boundary.

## Build and try the live USB

From the repository root:

```sh
nix build .#meier-iso --out-link result-meier-iso
ls -lh result-meier-iso/iso/
```

Write the ISO to a USB stick using an image-writing tool (for example GNOME
Disks' **Restore Disk Image**). Writing the image erases the **USB stick**: check
its identity and do not select the computer's internal disk. Eject it safely,
then select it from the Lenovo's firmware boot menu. Secure Boot may need to be
disabled for the unsigned NixOS image.

The live system runs GCompris without installing anything on the internal disk.
Test Danish menus and voices, speakers, graphics, keyboard, mouse and any
touchscreen. Its settings are temporary and disappear on reboot. Danish voices
are bundled; GCompris may still offer downloads of additional assets such as
word images and background music on first launch.

Use **Ctrl+Alt+F2** for the installer's `nixos` console with passwordless sudo;
**Ctrl+Alt+F1** returns to the kiosk. Wired networking is simplest. Use `nmtui`
on the console to set up Wi-Fi. Maintenance is also available over SSH:

```sh
ssh munksgaard@<installer-ip>
```

The authorized key comes from `common.authorizedKeys`. SSH password and root
login are disabled; the installer's passwordless local console is intentionally
retained. No private SSH key or Wi-Fi credential is embedded in the ISO.

The ISO includes a read-only repository snapshot at `/etc/philnix`. It includes
`flake.lock`, but **is not a fully offline installer**; installing/building the
final configuration requires internet access. A standard NixOS installer can
also install this configuration, but won't provide the live kiosk preview.

## Install on the internal disk

**Nothing partitions or formats disks automatically.** Back up existing data,
identify the intended disk with `lsblk -f`, and choose a partition layout after
checking the hardware. For a UEFI installation, normally create an EFI System
Partition and a Linux root filesystem. Consider swap for a low-memory machine.
Partition/format them manually and mount the root filesystem at `/mnt`, and the
EFI partition at `/mnt/boot`. Follow the NixOS installation manual for these
hardware-dependent steps. Check `/sys/firmware/efi` to confirm the USB was booted
in UEFI mode rather than legacy BIOS mode.

Once the filesystems are mounted:

```sh
sudo nixos-generate-config --root /mnt
cp -rL /etc/philnix /tmp/philnix
chmod -R u+w /tmp/philnix
sudo cp /mnt/etc/nixos/hardware-configuration.nix /tmp/philnix/meier/hardware-configuration.nix
```

Replace the hardware placeholder completely. Then edit
`/tmp/philnix/meier/meier.nix` to select the bootloader. For UEFI, uncomment the
systemd-boot and EFI-variable options. A legacy BIOS installation needs a GRUB
configuration for the actual target disk instead. Do not copy another host's
disk UUIDs or hardware module.

Review the generated hardware configuration, including networking and swap.
The installed system uses NetworkManager; live Wi-Fi connections are not
implicitly copied to the installed system. Use `nmtui` after installation to
configure Wi-Fi again (the console password below makes this possible).

```sh
sudo nixos-install --no-root-passwd --flake /tmp/philnix#meier
sudo nixos-enter --root /mnt -c 'passwd munksgaard'
```

The second command sets the administrator's local console password. Root and
`gcompris` have no password login. `munksgaard` can use sudo without a password;
SSH still requires the authorized key. Keep the kiosk account unprivileged.

**Before the first installed boot, commit and push the real hardware and
bootloader configuration to `master`.** Copy those two files back to your normal
checkout, review them, and commit there; the ISO snapshot has no `.git` directory.
Otherwise automatic updates will fetch the still-incomplete configuration. You
can instead disable `system.autoUpgrade.enable` locally until the matching
configuration is published.

Reboot and remove the USB. The internal installation should start GCompris.
The checked-in hardware placeholder deliberately fails NixOS assertions until
it is replaced; the ISO is independent of that placeholder and remains buildable.

## Updates and maintenance

`meier` checks `github:Munksgaard/philnix/master#meier` daily, including catching
up after being powered off. It follows the committed `flake.lock`; it does not
update dependencies independently. Push lockfile changes to deliver newer
packages, translations or voices.

Updates use `nixos-rebuild boot`: a successful build becomes the next boot's
default, but does not interrupt the current game or force a reboot. A failed
build leaves the previous boot default intact. A successfully built but broken
system does **not** automatically roll back: select an older generation from the
boot menu. Weekly garbage collection removes generations older than 30 days,
so recovery history is finite. The live ISO does not auto-update or run GC.

On the installed system, Ctrl+Alt+F2 provides a normal login console for
`munksgaard` using the password set during installation. Useful commands:

```sh
sudo journalctl -b -u cage-tty1.service
sudo journalctl -b _UID="$(id -u gcompris)"
sudo journalctl -u nixos-upgrade.service
systemctl list-timers nixos-upgrade.timer
sudo systemctl start nixos-upgrade.service
sudo systemctl restart cage-tty1.service
sudo poweroff
```

For settings not covered by the launcher, temporarily set
`services.gcompris-kiosk.kioskMode = false;` in `meier/meier.nix`, rebuild and
restart/reboot into that configuration. GCompris settings and progress live in
the kiosk user's persistent home directory on the installed machine.

## Checks

```sh
nix build .#checks.x86_64-linux.gcompris-config
nix build .#checks.x86_64-linux.gcompris-kiosk
nix build .#meier-iso
```

The configuration check covers shared laptop packaging, kiosk settings, SSH,
auto-updates, ISO isolation and a test-only installed disk configuration. It is
not a graphical boot test. The separate `gcompris-kiosk` VM test checks startup,
Danish settings and voice files, user audio sockets, and restarting after an
application exit. It needs KVM and does not replace testing on the Lenovo.
Add `meier`'s actual system build to the flake checks once its hardware
configuration and bootloader are available.
