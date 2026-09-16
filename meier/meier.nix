{ ... }:

{
  imports = [
    ./common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "meier";

  # Select a bootloader after checking the Lenovo's firmware. For UEFI:
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:Munksgaard/philnix/master#meier";
    upgrade = false;
    # Never interrupt a game: activate updates at the next normal boot.
    operation = "boot";
    dates = "daily";
    persistent = true;
    randomizedDelaySec = "15min";
    allowReboot = false;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Initial installation compatibility version; do not bump on upgrades.
  system.stateVersion = "26.05";
}
