{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.ghostty;
in
{
  options.laptop.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.munksgaard.programs.ghostty = {
      enable = true;
      settings = {
        theme = "Dracula";
      };
    };
  };
}
