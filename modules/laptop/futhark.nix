{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.futhark;
in
{
  options.laptop.futhark = {
    enable = lib.mkEnableOption "Futhark development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      futhark
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package futhark-mode
        :ensure t
        :mode "\\.fut\\(_[a-z_]+\\)?\\'")
    '';
  };
}
