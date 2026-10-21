{ config, ... }:

{
  imports = [
    ../modules/common
    ../modules/gcompris-kiosk.nix
  ];

  common = {
    enable = true;
    # The installed host sets a longer retention period; the ISO needs no GC.
    enableGC = false;
  };

  services.gcompris-kiosk.enable = true;
  services.xserver.xkb.layout = "dk";
  networking.networkmanager.enable = true;

  users.users.munksgaard = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = config.common.authorizedKeys;
    # Set a local console password at installation; SSH remains key-only.
    initialHashedPassword = "!";
  };
  security.sudo.wheelNeedsPassword = false;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };
}
