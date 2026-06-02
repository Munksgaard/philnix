{ pkgs, homeStateVersion, ... }:
{
  home.packages = with pkgs; [
    atool
    fd
    httpie
    wget
    nix-init
  ];

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = homeStateVersion;

  imports = [
    ./alacritty.nix
    ./emacs.nix
    ./firefox.nix

  ];

  programs = {
    bash = {
      enable = true;
      bashrcExtra = ''
        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
        source "$EAT_SHELL_INTEGRATION_DIR/bash"
      '';
    };

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
    ripgrep.enable = true;

    vim.enable = true;

    zathura.enable = true;
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
    sway.enable = true;
    gtk.enable = true;
  };

  xresources.extraConfig = ''
    # Fix blurryness in emacs
    # https://emacs.stackexchange.com/a/83322
    Xft.autohint: 1
    Xft.antialias: 1
    Xft.hinting: 1
    Xft.hintstyle: hintslight
    Xft.dpi: 96
    Xft.rgba: rgb
    Xft.lcdfilter: lcddefault
  '';

  services = {
    kanshi.enable = true;
    mako.enable = true;
    gnome-keyring.enable = true;
  };
}
