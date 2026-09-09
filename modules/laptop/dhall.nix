{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.dhall;
in
{
  options.laptop.dhall = {
    enable = lib.mkEnableOption "Dhall development tools and Emacs integration";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.dhall ];

    home-manager.users.munksgaard.emacsConfig = {
      extraEmacsPackages = [
        pkgs.dhall
        pkgs.dhall-lsp-server
      ];

      extraConfig = ''
        (use-package dhall-mode
          :ensure t
          :mode "\\.dhall\\'"
          :hook (dhall-mode . eglot-ensure)
          :custom
          (dhall-format-at-save t)
          ;; Eglot provides diagnostics, so avoid duplicate background type checking.
          (dhall-use-header-line nil)
          :config
          (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs
                         '(dhall-mode . ("dhall-lsp-server")))))
      '';
    };
  };
}
