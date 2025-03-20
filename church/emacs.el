(setq user-full-name "Philip Munksgaard")
(setq user-mail-address "philip@munksgaard.me")

;; Disable startup message.
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message (user-login-name))

(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Disable some GUI distractions.
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Don't ring a bell
(setq ring-bell-function 'ignore)

;; Always prefer horizontal splits on my screen
(setq split-height-threshold nil)

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

;; Delete highlighted selection with a keypress
(delete-selection-mode t)

;; Enable some features that are disabled by default.
;(put 'narrow-to-region 'disabled nil)

;; Typically, I only want spaces when pressing the TAB key. I also
;; want 4 of them.
(setq-default indent-tabs-mode nil
              tab-width 8
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
(keymap-global-set "M-o" 'other-window)

;; Font size
(keymap-global-set "C-+" 'text-scale-increase)
(keymap-global-set "C-\\" 'text-scale-increase)
(keymap-global-set "C--" 'text-scale-decrease)

;; smlfmt
(defun smlfmt ()
  (interactive)
  (save-buffer)
  (let ((ret (call-process "${pkgs.smlfmt}/bin/smlfmt" nil nil nil "--force" (buffer-file-name))))
    (if (= ret 0)
        (revert-buffer t t t)
      (message "smlfmt failed: %s" ret))))

;; Fix colors in dark terminal
(setq frame-background-mode 'dark)

;; https://protesilaos.com/codelog/2024-11-28-basic-emacs-configuration/#h:1e468b2a-9bee-4571-8454-e3f5462d9321
(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(keymap-global-set "C-g" #'prot/keyboard-quit-dwim)

;; Put customizations in separate file
(setq custom-file (concat user-emacs-directory "custom.el"))

;; Use emacs loopback for pinentry
;;
;; https://www.gnu.org/software/emacs/manual/html_node/epa/GnuPG-Pinentry.html
(setq epg-pinentry-mode 'loopback)

;;; Packages

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(use-package dracula-theme
  :ensure t
  :config
  (load-theme 'dracula t))

(use-package magit
  :ensure t
  :bind (("C-c m" . magit-status)
         ("C-c b" . magit-blame)
         ("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch))
  :config
  (setq magit-diff-options (quote ("--word-diff")))
  (setq magit-diff-refine-hunk 'all)
  (add-to-list 'magit-repository-directories '("~/src/" . 1))
  (add-to-list 'git-commit-style-convention-checks
               'overlong-summary-line))

(use-package elixir-mode
  :ensure t)

(use-package direnv
  :ensure t
  :config (direnv-mode))

(use-package notifications
  :ensure t
  :commands notifications-notify)

(use-package hippie-exp
  :ensure t
  :config (global-set-key [remap dabbrev-expand] 'hippie-expand))

(use-package winner
  :ensure t
  :config (winner-mode 1))

(use-package buffer-move
  :ensure t
  :bind (("C-M-<up>" . buf-move-up)
         ("C-M-<down>" . buf-move-down)
         ("C-M-<left>" . buf-move-left)
         ("C-M-<right>" . buf-move-right)))

(use-package ido
  :ensure t
  :config
  (ido-mode t)
  (define-key ido-common-completion-map
              (kbd "C-x g") 'ido-enter-magit-status)
  (setq ido-enable-prefix nil)
  (setq ido-enable-flex-matching t)
  (setq ido-create-new-buffer 'always)
  (setq ido-use-filename-at-point 'guess)
  (setq ido-max-prospects 10)
  (setq ido-default-file-method 'selected-window))

(use-package avy
  :ensure t
  :bind ("M-j" . avy-goto-char-timer))

(use-package eglot
  :ensure t
  :bind ("C-." . eglot-code-actions))

(use-package haskell-mode
        :ensure t
        :commands interactive-haskell-mode
        :mode (("\\.hs\\'" . haskell-mode)
               ("\\.lhs\\'" . literate-haskell-mode)))

(use-package markdown-mode
  :ensure t
  :mode ("\\.mdwn\\'"
         "\\.markdown\\'"
         "\\.md\\'"
         "\\.livemd\\'"))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . subword-mode))

(use-package org
  :ensure t
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda)
         ("C-c l" . org-store-link))
  :config
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
        org-refile-allow-creating-parent-nodes 'confirm))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :bind (:map company-mode-map
              ([remap completion-at-point] . company-complete-common)
              ([remap complete-symbol] . company-complete-common))
  :config
  (setq company-idle-delay 0.3
        company-show-numbers t))

(use-package company-quickhelp
  :ensure t
  :after company
  :commands company-quickhelp-mode
  :config (company-quickhelp-mode 1))

(use-package yaml-mode
  :ensure t
  :mode "\\.yaml\\'")

(use-package erlang
  :ensure t)

(use-package elixir-mode
  :ensure t
  :hook (elixir-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil t))))

(use-package exunit
  :ensure t
  :hook (elixir-mode . exunit-mode))

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :config
  (setq rust-format-on-save t))

(use-package systemd
  :ensure t)

(use-package futhark-mode
  :ensure t
  :mode "\\.fut\\(_[a-z_]+\\)?\\'")

(use-package sml-mode
  :ensure t)

(use-package elpher
  :ensure t
  :hook (elpher . (lambda () (setq show-trailing-whitespace nil))))

(use-package ledger-mode
  :ensure t
  :hook
  (ledger-mode .
               (lambda ()
                 (setq-local tab-always-indent 'complete)
                 (setq-local completion-cycle-threshold t)
                 (setq-local ledger-complete-in-steps t)
                 (setq-local ledger-default-date-format ledger-iso-date-format))))

(use-package csv-mode
  :ensure t)

(use-package flymake
  :ensure t
  :bind (("M-n" . flymake-goto-next-error)
         ("M-p" . flymake-goto-prev-error)))

(use-package inf-elixir
  :ensure t
  :bind (("C-c i i" . inf-elixir)
         ("C-c i p" . inf-elixir-project)
         ("C-c i l" . inf-elixir-send-line)
         ("C-c i r" . inf-elixir-send-region)
         ("C-c i b" . inf-elixir-send-buffer)
          ("C-c i R" . inf-elixir-reload-module)))

(use-package just-mode
  :ensure t
  :config (setq just-indent-offset 2))

(use-package deadgrep
  :ensure t)
