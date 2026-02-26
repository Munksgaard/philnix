{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.laptop.elixir;
  beam_pkgs = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
in
{
  options.laptop.elixir = {
    enable = lib.mkEnableOption "Elixir/Erlang development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      beam_pkgs.erlang
      beam_pkgs.elixir_1_18
    ];

    home-manager.users.munksgaard.emacsConfig.extraConfig = ''
      (use-package erlang
        :ensure t)

      ;; Needed for 'elixir-format.
      ;;
      ;; We use 'elixir-format until the elixir LSPs are good enough that I want to
      ;; run them all the time and we can run eglot-format instead.
      ;;
      ;; https://github.com/wkirschbaum/elixir-ts-mode/issues/9
      (use-package elixir-mode :ensure t)

      (use-package elixir-ts-mode
        :ensure t
        :mode "\\.exs?\\'"
        :hook (elixir-ts-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil t))))

      (use-package heex-ts-mode
        :ensure t
        :hook (heex-ts-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))
        :config
        (add-hook 'heex-ts-mode-hook
            (lambda ()
              (keymap-local-unset "M-o"))))

      (use-package exunit
        :ensure t
        :hook (elixir-mode . exunit-mode)
        :hook (elixir-ts-mode . exunit-mode)
        :hook (heex-ts-mode . exunit-mode)
        :hook (magit-status-mode . exunit-mode))

      (use-package inf-elixir
        :ensure t
        :bind (("C-c i i" . inf-elixir)
               ("C-c i p" . inf-elixir-project)
               ("C-c i l" . inf-elixir-send-line)
               ("C-c i r" . inf-elixir-send-region)
               ("C-c i b" . inf-elixir-send-buffer)
                ("C-c i R" . inf-elixir-reload-module)))

      (with-eval-after-load 'eglot
        (add-to-list 'eglot-server-programs
                     '(elixir-ts-mode . ("expert" "--stdio")))
        (add-to-list 'eglot-server-programs
                     '(heex-ts-mode . ("expert" "--stdio")))
        (add-hook 'heex-ts-mode-hook 'eglot-ensure))
    '';
  };
}
