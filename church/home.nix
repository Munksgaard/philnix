{ pkgs, ... }: {
  home.packages = with pkgs; [ atool fd httpie wget ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "23.11";

  programs = {
    alacritty.enable = true;
    bash.enable = true;
    bat.enable = true;
    bottom.enable = true;
    chromium.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };

    emacs = {
      enable = true;
      package = pkgs.emacs29;
    };
    eza = {
      enable = true;
      enableAliases = true;
    };
    feh.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
      policies = { DefaultDownloadDirectory = "\${home}/tmp"; };
    };
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
