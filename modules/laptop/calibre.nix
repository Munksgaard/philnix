{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.calibre;
in
{
  options.laptop.calibre = {
    enable = lib.mkEnableOption "Calibre e-book management";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.calibre ];
  };
}
