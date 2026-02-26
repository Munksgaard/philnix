{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.rust;
in
{
  options.laptop.rust = {
    enable = lib.mkEnableOption "Rust development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rustup
      rust-analyzer
      cargo-crev
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package rust-mode
        :ensure t
        :mode "\\.rs\\'"
        :config
        (setq rust-format-on-save t))
    '';
  };
}
