{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.gcompris;
in
{
  options.laptop.gcompris = {
    enable = lib.mkEnableOption "GCompris educational software suite";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gcompris ];
  };
}
