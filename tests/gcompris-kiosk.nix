{ inputs, pkgs }:

pkgs.testers.runNixOSTest {
  name = "gcompris-kiosk";
  node.specialArgs = inputs;

  nodes.machine = {
    imports = [ ../meier/common.nix ];
    system.stateVersion = "26.05";
    virtualisation = {
      memorySize = 4096;
      cores = 2;
      # Cage requires a KMS-capable virtual GPU, like nixpkgs' own Cage test.
      qemu.options = [ "-vga none -device virtio-gpu-pci" ];
    };
  };

  enableOCR = true;
  testScript = ''
    start_all()
    machine.wait_for_unit("cage-tty1.service")
    machine.wait_until_succeeds("pgrep -u gcompris -f '/bin/[.]?gcompris-qt'")
    machine.wait_until_succeeds(
        "grep -Fx 'locale=da_DK.UTF-8' /home/gcompris/.config/gcompris/gcompris-qt.conf"
    )
    machine.succeed("test -r /home/gcompris/.local/share/GCompris/voices-ogg/da/misc/welcome.ogg")
    machine.wait_for_text("GCompris")
    machine.screenshot("gcompris-danish")

    uid = machine.succeed("id -u gcompris").strip()
    machine.succeed(f"test -S /run/user/{uid}/bus")
    machine.wait_until_succeeds(f"test -S /run/user/{uid}/pipewire-0")
    machine.wait_until_succeeds(f"test -S /run/user/{uid}/pulse/native")

    # Killing only the application must restart the whole kiosk session.
    previous = machine.succeed("systemctl show cage-tty1 -p InvocationID --value").strip()
    machine.succeed("pkill -TERM -u gcompris -f '/bin/[.]?gcompris-qt'")
    machine.wait_until_succeeds(
        f"test $(systemctl show cage-tty1 -p InvocationID --value) != {previous}"
    )
    machine.wait_until_succeeds("pgrep -u gcompris -f '/bin/[.]?gcompris-qt'")
    # The first-run welcome dialog is absent on subsequent launches, so do
    # not require its title to appear again. Wait for the new QML scene.
    machine.wait_until_succeeds(
        "journalctl -b --no-pager | grep -F 'enter main.qml (run #2,'"
    )
    machine.screenshot("gcompris-restarted")
  '';
}
