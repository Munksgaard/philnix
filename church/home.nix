{ pkgs, ... }: {
  home.packages = with pkgs; [ atool fd httpie wget nix-init ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  imports = [ ./alacritty.nix ./emacs.nix ./firefox.nix ];

  programs = {
    bash.enable = true;
    bat.enable = true;
    bottom.enable = true;
    chromium.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    eza.enable = true;
    feh.enable = true;
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      ignores = [ "*~" "*.swp" "*#" ];
      userName = "Philip Munksgaard";
      userEmail = "philip@munksgaard.me";
      signing = {
        key = "56584D0971AFE45FCC296BD74CE62A90EFC0B9B2";
        signByDefault = true;
      };
    };
    ripgrep.enable = true;

    tmux = {
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
    };

    vim.enable = true;
    zathura.enable = true;
  };

  services = {
    emacs = {
      enable = true;
      defaultEditor = true;
    };
  };
}
