{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.ergodox;
in
{
  options.laptop.ergodox = {
    enable = lib.mkEnableOption "Ergodox/Moonlander keyboard support";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wally-cli
    ];

    users.groups.plugdev = { };

    users.users.munksgaard.extraGroups = [ "plugdev" ];

    # Stuff for the Ergodox Moonlander
    services.udev.extraRules = ''
      # Teensy rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      # STM32 rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", \
          MODE:="0666", \
          SYMLINK+="stm32_dfu"

      # Rule for the Moonlander
      SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
    '';
  };
}
