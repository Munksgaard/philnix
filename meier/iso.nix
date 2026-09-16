{
  lib,
  modulesPath,
  self,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./common.nix
  ];

  networking.hostName = "meier-installer";
  # The minimal installer otherwise forcibly disables fontconfig.
  fonts.fontconfig.enable = lib.mkForce true;
  isoImage.edition = "meier";
  isoImage.configurationName = "Danish GCompris kiosk / meier installer";

  # A read-only snapshot for installation, including flake.lock and the guide.
  # This is not an offline installation closure: installation needs internet.
  environment.etc."philnix".source = self;

  # The installation profile supplies a local nixos autologin on the other VTs.
  # SSH uses munksgaard's key, never the installer's empty local passwords.
  system.autoUpgrade.enable = false;
  nix.gc.automatic = lib.mkForce false;
}
