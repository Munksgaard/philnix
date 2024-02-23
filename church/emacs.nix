{ pkgs, ... }: {

  programs.emacs.enable = true;
  programs.emacs.package = pkgs.emacs29;
  programs.emacs.extraPackages = epkgs:
    with epkgs;
    [ epkgs.treesit-grammars.with-all-grammars ];

  programs.emacs.init = {
    # Lots of inspiration from
    # https://git.sr.ht/~rycee/configurations/tree/34b13ff0054a8a3a26b5b74b83fd703fbf467de7/item/user/emacs.nix

    enable = true;
    recommendedGcSettings = true;

    prelude = ''
            ;; Disable startup message.
            (setq user-full-name "Philip Munksgaard")
            (setq user-mail-address "philip@munksgaard.me")

            (setq inhibit-startup-screen t
                  inhibit-startup-message t
                  inhibit-startup-echo-area-message (user-login-name))

            (setq initial-major-mode 'fundamental-mode
                  initial-scratch-message nil)

            ;; Disable some GUI distractions.
            (tool-bar-mode -1)
            (scroll-bar-mode -1)
            (menu-bar-mode -1)

            ;; Set up fonts early.
            ;(set-face-attribute 'default
            ;                    nil
            ;                    :height 80
            ;                    :family "Fantasque Sans Mono")
            ;(set-face-attribute 'variable-pitch
            ;                    nil
            ;                    :family "DejaVu Sans")

            ;; Set frame title.
            (setq frame-title-format
                  '("" invocation-name ": "(:eval
                                            (if (buffer-file-name)
                                                (abbreviate-file-name (buffer-file-name))
                                              "%b"))))

            ;; Accept 'y' and 'n' rather than 'yes' and 'no'.
            (defalias 'yes-or-no-p 'y-or-n-p)

            ;; Don't want to move based on visual line.
            ;(setq line-move-visual nil)

            ;; Stop creating backup and autosave files.
            ;(setq make-backup-files nil
            ;      auto-save-default nil)

            ;; Always show line and column number in the mode line.
            (line-number-mode)
            (column-number-mode)

            ;; Enable some features that are disabled by default.
            ;(put 'narrow-to-region 'disabled nil)

            ;; Typically, I only want spaces when pressing the TAB key. I also
            ;; want 4 of them.
            (setq-default indent-tabs-mode nil
                          tab-width 4
                          c-basic-offset 2)

            ;; Trailing white space are banned!
            (setq-default show-trailing-whitespace t)

            ;; I typically want to use UTF-8.
            (prefer-coding-system 'utf-8)

            ;; Nicer handling of regions.
            (transient-mark-mode 1)

            ;; Make moving cursor past bottom only scroll a single line rather
            ;; than half a page.
            (setq scroll-step 1
                  scroll-conservatively 5)

            ;; Nicer scrolling
            (pixel-scroll-precision-mode)

            ;; Improved handling of clipboard in GNU/Linux and otherwise.
            ;(setq select-enable-clipboard t
            ;      select-enable-primary t
            ;      save-interprogram-paste-before-kill t)

            ;; Pasting with middle click should insert at point, not where the
            ;; click happened.
            ;(setq mouse-yank-at-point t)

            ;; Shouldn't highlight trailing spaces in terminal mode.
            (add-hook 'term-mode (lambda () (setq show-trailing-whitespace nil)))
            (add-hook 'term-mode-hook (lambda () (setq show-trailing-whitespace nil)))

            ;; Show matching paren
            (show-paren-mode 1)

            ;; Show buffer size in status line
            (size-indication-mode t)

            ;; Set the fill-column to 80 instead of the default 72
            (setq-default fill-column 80)

            ;; Delete trailing whitespace before saving
            (add-hook 'before-save-hook
                      'delete-trailing-whitespace)

            ;; Kill whole line on C-k
            (setq-default kill-whole-line t)

            ;; Disable colors in shell mode
            ;; From https://old.reddit.com/r/emacs/comments/9x2st8/disable_all_colours_in_shell_mode/
            ;; (setf ansi-color-for-comint-mode 'filter)

            ;; Avoid hangs on long lines in the shell
            ;; From https://old.reddit.com/r/emacs/comments/9x2st8/disable_all_colours_in_shell_mode/ea45tt7/
            ;; (setq shell-font-lock-keywords nil)

            ;; Scroll output
            ;(setq compilation-scroll-output t)

            ;; Cycle windows with C-tab and C-S-tab
            (global-set-key [C-tab] 'other-window)
            (global-set-key [C-S-iso-lefttab] (lambda () (interactive) (other-window -1)))

            ;; Font size
            (define-key global-map (kbd "C-+") 'text-scale-increase)
            (define-key global-map (kbd "C-\\") 'text-scale-increase)
            (define-key global-map (kbd "C--") 'text-scale-decrease)

            ;; smlfmt
            (defun smlfmt ()
              (interactive)
      	(save-buffer)
              (let ((ret (call-process "${pkgs.smlfmt}/bin/smlfmt" nil nil nil "--force" (buffer-file-name))))
                (if (= ret 0)
                  (revert-buffer t t t)
                  (message "smlfmt failed: %s" ret))))
    '';

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
        command = [ "direnv-mode" "direnv-update-environment" ];
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
          (setq magit-completing-read-function 'ivy-completing-read)
          (add-to-list 'git-commit-style-convention-checks
                       'overlong-summary-line)
          (define-key magit-status-mode-map (kbd "C-<tab>") nil)
        '';
      };

      #tramp = {
      #  enable = true;
      #};

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

      #lsp-ui = {
      #  enable = true;
      #  command = [ "lsp-ui-mode" ];
      #  bind = {
      #    "C-c r d" = "lsp-ui-doc-show";
      #    "C-c f s" = "lsp-ui-find-workspace-symbol";
      #  };
      #  config = ''
      #    (setq lsp-ui-sideline-enable t
      #          lsp-ui-sideline-show-symbol nil
      #          lsp-ui-sideline-show-hover nil
      #          lsp-ui-sideline-show-code-actions nil
      #          lsp-ui-sideline-update-mode 'point
      #          lsp-ui-doc-enable nil)
      #  '';
      #};

      #lsp-ui-flycheck = {
      #  enable = true;
      #  command = [ "lsp-ui-flycheck-enable" ];
      #  after = [ "flycheck" "lsp-ui" ];
      #};

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
          "C-c b" = "org-switchb";
        };
        hook = [''
          (org-mode
           . (lambda ()
               (add-hook 'completion-at-point-functions
                         'pcomplete-completions-at-point nil t)))
        ''];
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

          ;; Unfortunately org-mode takes over my preferred window switching keybinding.
          (unbind-key "C-<Tab>" org-mode-map)
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
        # diminish = [ "company-mode" ];
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

      elixir-ts-mode = { enable = true; };

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
        hook = [
          "(elpher-mode-mode . (lambda () (setq show-trailing-whitespace nil)))"
        ];
      };

      ledger-mode = {
        enable = true;
        hook = [''
                    (ledger-mode-mode .
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
    };
  };
}
