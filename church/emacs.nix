{ pkgs, config, ... }:
let emacs = pkgs.emacs30-pgtk;
in {

  programs.emacs = {
    enable = true;
    package = emacs;
  };

  home.file.".emacs.d/init.el" = { source = ./emacs.el; };

  services = {
    emacs = {
      enable = true;
      package = emacs;
      defaultEditor = true;
      startWithUserSession = true;
    };
  };
}
