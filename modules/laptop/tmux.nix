{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.tmux;
in
{
  options.laptop.tmux = {
    enable = lib.mkEnableOption "tmux terminal multiplexer";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.munksgaard.programs.tmux = {
      enable = true;

      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-show-powerline true
            set -g @dracula-show-battery false
            set -g @dracula-plugins " "
          '';
        }
      ];

      sensibleOnTop = true;

      # These are usually set by sensible, but due to
      # https://github.com/nix-community/home-manager/issues/2541
      # they are unintentionally overwritten by programs.tmux
      terminal = "screen-256color";
      historyLimit = 50000;
    };
  };
}
