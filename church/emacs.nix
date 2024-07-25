{ pkgs, ... }: {

  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs29-pgtk;
  programs.emacs.extraPackages = epkgs:
    with epkgs;
    [ epkgs.treesit-grammars.with-all-grammars ];

  programs.emacs.init = {
    # Lots of inspiration from
    # https://git.sr.ht/~rycee/configurations/tree/34b13ff0054a8a3a26b5b74b83fd703fbf467de7/item/user/emacs.nix

    enable = true;
    recommendedGcSettings = true;

    prelude = builtins.readFile ./prelude.el;
    usePackage = {
      ansi-color = {
        enable = true;
        command = [ "ansi-color-apply-on-region" ];
      };

      dracula-theme = {
        enable = true;
        earlyInit = ''
          (require 'dracula-theme)
          (load-theme 'dracula t)
        '';
      };

      # From https://github.com/mlb-/emacs.d/blob/a818e80f7790dffa4f6a775987c88691c4113d11/init.el#L472-L482
      compile = {
        enable = true;
        defer = true;
        after = [ "ansi-color" ];
        hook = [''
          (compilation-filter . (lambda ()
                                  (when (eq major-mode 'compilation-mode)
                                    (ansi-color-apply-on-region compilation-filter-start (point-max)))))
        ''];
      };

      beacon = {
        enable = true;
        command = [ "beacon-mode" ];
        diminish = [ "beacon-mode" ];
        defer = 1;
        config = "(beacon-mode 1)";
      };

      direnv = {
        enable = true;
        config = "(direnv-mode)";
      };

      js = {
        enable = true;
        mode = [ ''("\\.js\\'" . js-mode)'' ''("\\.json\\'" . js-mode)'' ];
        config = ''
          (setq js-indent-level 2)
        '';
      };

      notifications = {
        enable = true;
        command = [ "notifications-notify" ];
      };

      # Hook up hippie expand.
      hippie-exp = {
        enable = true;
        config = ''
          (global-set-key [remap dabbrev-expand] 'hippie-expand)
        '';
      };

      # Enable winner mode. This global minor mode allows you to
      # undo/redo changes to the window configuration. Uses the
      # commands C-c <left> and C-c <right>.
      winner = {
        enable = true;
        config = "(winner-mode 1)";
      };

      buffer-move = {
        enable = true;
        bind = {
          "C-M-<up>" = "buf-move-up";
          "C-M-<down>" = "buf-move-down";
          "C-M-<left>" = "buf-move-left";
          "C-M-<right>" = "buf-move-right";
        };
      };

      # Configure magit, a nice mode for the git SCM.
      magit = {
        enable = true;
        bind = {
          "C-c m" = "magit-status";
          "C-c b" = "magit-blame";
          "C-x g" = "magit-status";
          "C-x M-g" = "magit-dispatch";
        };
        config = ''
          (setq magit-diff-options (quote ("--word-diff")))
          (setq magit-diff-refine-hunk 'all)
          (add-to-list 'magit-repository-directories '("~/src/" . 1))
          (add-to-list 'git-commit-style-convention-checks
                       'overlong-summary-line)
        '';
        hook = [''
          ;; Unfortunately magit hijacks my preferred window switching keybinding.
          (magit-mode
           . (lambda ()
               (local-unset-key [C-tab])))
        ''];
      };

      ido = {
        enable = true;
        config = ''
          (ido-mode t)
          (define-key ido-common-completion-map
            (kbd "C-x g") 'ido-enter-magit-status)
          (setq ido-enable-prefix nil)
          (setq ido-enable-flex-matching t)
          (setq ido-create-new-buffer 'always)
          (setq ido-use-filename-at-point 'guess)
          (setq ido-max-prospects 10)
          (setq ido-default-file-method 'selected-window)
        '';
      };

      avy = {
        enable = true;
        bind = { "M-j" = "avy-goto-char-timer"; };
      };

      eglot = {
        enable = true;
        bind = { "C-." = "eglot-code-actions"; };
      };

      haskell-mode = {
        enable = true;
        command = [ "interactive-haskell-mode" ];
        mode = [
          ''("\\.hs\\'" . haskell-mode)''
          ''("\\.lhs\\'" . literate-haskell-mode)''
        ];
      };

      markdown-mode = {
        enable = true;
        mode = [
          ''"\\.mdwn\\'"''
          ''"\\.markdown\\'"''
          ''"\\.md\\'"''
          ''"\\.livemd\\'"''
        ];
      };

      pandoc-mode = {
        enable = true;
        after = [ "markdown-mode" ];
        hook = [ "markdown-mode" ];
        bindLocal = {
          markdown-mode-map = { "C-c C-c" = "pandoc-run-pandoc"; };
        };
      };

      nix-mode = {
        enable = true;
        mode = [ ''"\\.nix\\'"'' ];
        hook = [ "(nix-mode . subword-mode)" ];
      };

      org = {
        enable = true;
        bind = {
          "C-c c" = "org-capture";
          "C-c a" = "org-agenda";
          "C-c l" = "org-store-link";
        };
        hook = [
          # ''
          #   (org-mode
          #    . (lambda ()
          #        (add-hook 'completion-at-point-functions
          #                  'pcomplete-completions-at-point nil t)))
          # ''
          ''
            ;; Unfortunately org-mode takes over my preferred window switching keybinding.
            (org-mode
             . (lambda ()
                 (local-unset-key [C-tab])))
          ''
        ];
        config = ''
          ;; Some general stuff.
          (setq org-reverse-note-order t
                org-use-fast-todo-selection t)

          ;; Refiling should include not only the current org buffer but
          ;; also the standard org files. Further, set up the refiling to
          ;; be convenient with IDO. Follows norang's setup quite closely.
          (setq org-refile-targets '((nil :maxlevel . 2)
                                     (org-agenda-files :maxlevel . 2))
                org-refile-use-outline-path t
                org-outline-path-complete-in-steps nil
                org-refile-allow-creating-parent-nodes 'confirm)
        '';
      };

      ace-window = {
        enable = true;
        extraConfig = ''
          :bind* (("M-o" . ace-window))
        '';
      };

      company = {
        enable = true;
        hook = [ "(after-init . global-company-mode)" ];
        extraConfig = ''
          :bind (:map company-mode-map
                      ([remap completion-at-point] . company-complete-common)
                      ([remap complete-symbol] . company-complete-common))
        '';
        config = ''
          (setq company-idle-delay 0.3
                company-show-numbers t)
        '';
      };

      company-quickhelp = {
        enable = true;
        after = [ "company" ];
        command = [ "company-quickhelp-mode" ];
        config = ''
          (company-quickhelp-mode 1)
        '';
      };

      yaml-mode = {
        enable = true;
        mode = [ ''"\\.yaml\\'"'' ];
      };

      erlang = { enable = true; };

      elixir-mode = {
        enable = true;
        hook = [
          "(elixir-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))"
        ];
      };

      exunit = {
        enable = true;
        hook = [ "(elixir-mode . exunit-mode)" ];
      };

      rust-mode = {
        enable = true;
        mode = [ ''"\\.rs\\'"'' ];
        config = ''
          (setq rust-format-on-save t)
        '';
      };

      systemd = {
        enable = true;
        defer = true;
      };

      futhark-mode = {
        enable = true;
        mode = [ ''"\\.fut\\(_[a-z_]+\\)?\\'"'' ];
      };

      sml-mode = { enable = true; };

      elpher = {
        enable = true;
        hook = [ "(elpher . (lambda () (setq show-trailing-whitespace nil)))" ];
      };

      ledger-mode = {
        enable = true;
        hook = [''
          (ledger-mode .
            (lambda ()
              (setq-local tab-always-indent 'complete)
              (setq-local completion-cycle-threshold t)
              (setq-local ledger-complete-in-steps t)
              (setq-local ledger-default-date-format ledger-iso-date-format)))
        ''];
      };

      csv-mode.enable = true;

      flymake = {
        enable = true;
        bind = {
          "M-n" = "flymake-goto-next-error";
          "M-p" = "flymake-goto-prev-error";
        };
      };

      inf-elixir = {
        enable = true;
        bind = {
          "C-c i i" = "inf-elixir";
          "C-c i p" = "inf-elixir-project";
          "C-c i l" = "inf-elixir-send-line";
          "C-c i r" = "inf-elixir-send-region";
          "C-c i b" = "inf-elixir-send-buffer";
          "C-c i R" = "inf-elixir-reload-module";
        };
      };

      just-mode = {
        enable = true;
        config = ''
          (setq just-indent-offset 2)
        '';
      };

      deadgrep.enable = true;
    };
  };
}
