{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.teams;
in
{
  options.laptop.teams = {
    enable = lib.mkEnableOption "Microsoft Teams client";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.teams-for-linux ];
  };
}
