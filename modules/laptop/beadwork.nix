{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.beadwork;
in
{
  options.laptop.beadwork = {
    enable = lib.mkEnableOption "Beadwork CLI";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.beadwork ];
  };
}
