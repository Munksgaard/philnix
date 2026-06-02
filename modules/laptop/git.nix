{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.git;
in
{
  options.laptop.git = {
    enable = lib.mkEnableOption "Git version control";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.munksgaard.programs.git = {
      enable = true;
      package = pkgs.gitFull;
      ignores = [
        "*~"
        "*.swp"
        "*#"
      ];
      settings = {
        user = {
          name = "Philip Munksgaard";
          email = "philip@munksgaard.me";
        };
      };
      signing = {
        key = "56584D0971AFE45FCC296BD74CE62A90EFC0B9B2";
        signByDefault = true;
      };
    };
  };
}
