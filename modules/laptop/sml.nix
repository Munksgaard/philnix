{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.sml;
in
{
  options.laptop.sml = {
    enable = lib.mkEnableOption "SML development tools (mosml, mlton, smlfmt, millet)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mosml
      mlton
      smlfmt
      millet
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package sml-mode
        :ensure t)

      (defun smlfmt ()
        (interactive)
        (save-buffer)
        (let* ((smlfmt-bin (executable-find "smlfmt"))
               (ret (call-process smlfmt-bin nil nil nil "--force" (buffer-file-name))))
          (if (= ret 0)
              (revert-buffer t t t)
            (message "smlfmt failed: %s" ret))))
    '';
  };
}
