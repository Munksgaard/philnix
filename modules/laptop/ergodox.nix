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
    hardware.keyboard.zsa.enable = true;

    environment.systemPackages = with pkgs; [
      keymapp
      wally-cli
    ];
  };
}
