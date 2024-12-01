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
;; Try to use ace-window
;; (global-set-key [C-tab] 'other-window)
;; (global-set-key [C-S-iso-lefttab] (lambda () (interactive) (other-window -1)))

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

;; Fix colors in dark terminal
(setq frame-background-mode 'dark)
