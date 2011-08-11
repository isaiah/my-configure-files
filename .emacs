(add-to-list 'load-path "~/.emacs.d/")
(require 'package)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(tool-bar-mode 0)
(scroll-bar-mode nil)
(require 'quack)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-layout-name "left14")
 '(ecb-layout-window-sizes (quote (("left14" (ecb-directories-buffer-name 0.25380710659898476 . 0.72) (ecb-history-buffer-name 0.25380710659898476 . 0.26)))))
 '(ecb-options-version "2.40")
 '(ecb-default-directory "/home/isaiah")
 '(quack-default-program "mzscheme")
 '(quack-programs (quote ("mzscheme" "bigloo" "csi" "csi -hygienic" "gosh" "gracket" "gsi" "gsi ~~/syntax-case.scm -" "guile" "kawa" "mit-scheme" "racket" "racket -il typed/racket" "rs" "scheme" "scheme48" "scsh" "sisc" "stklos" "sxi")))
 '(quack-run-scheme-always-prompts-p nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
;; Load CEDET
(load-file "/usr/share/emacs/site-lisp/cedet/common/cedet.el")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/ecb")
(require 'ecb-autoloads)
(setq linum-format "%d ")
(global-linum-mode 1)
;; ido mode
(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;; dot mode
;(require 'dot-mode)
;(add-hook 'find-file-hooks 'dot-mode-on)

;; WholeLineOrRegion
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if (region-active-p) (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if (region-active-p) (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;; Behave like vi's o command
(defun open-next-line (arg)
  "Move to the next line and then opens a line.
See also `newline-and-indent'."
  (interactive "p")
  (end-of-line)
  (open-line arg)
  (next-line 1)
  (when newline-and-indent
    (indent-according-to-mode)))

(global-set-key (kbd "C-o") 'open-next-line)

;; Behave like vi's O command
(defun open-previous-line (arg)
  "Open a new line before the current one. 
 See also `newline-and-indent'."
  (interactive "p")
  (beginning-of-line)
  (open-line arg)
  (when newline-and-indent
    (indent-according-to-mode)))

(global-set-key (kbd "M-o") 'open-previous-line)

;; Autoindent open-*-lines
(defvar newline-and-indent t
  "Modify the behavior of the open-*-line functions to cause them to autoindent.")
; color-theme
(require 'color-theme)
(eval-after-load "color-theme"
                 '(progn
                    (color-theme-initialize)
                    (color-theme-gnome2)))

(add-to-list 'load-path "/usr/share/emacs/site-lisp/highlight-parentheses.el")
(require 'highlight-parentheses)
(setq hl-paren-colors
      '(;"#8f8f8f" ; this comes from Zenburn
                   ; and I guess I'll try to make the far-outer parens look like this
        "orange1" "yellow1" "greenyellow" "green1"
        "springgreen1" "cyan1" "slateblue1" "magenta1" "purple"))

; (add-hook 'scheme-mode-hook (lambda () (highlight-parentheses-mode +1)))
(add-hook 'scheme-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'clojure-mode-hook (lambda () (paredit-mode +1)))
; (add-hook 'clojure-mode-hook (lambda () (set (make-local-variable 'ffip-regexp) ".*\\.clj")))
(add-hook 'scheme-mode-hook (lambda () (show-paren-mode +1)))
;(setq viper-mode t)
(defalias 'yes-or-no-p 'y-or-n-p)
;(require 'viper)
(require 'vimpulse)
; org-mode
(require 'org-install)
(setq org-agenda-files (list "~/.org/tasks.org"))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(add-to-list 'load-path "/usr/share/emacs/scala-mode")
(require 'scala-mode-auto)
(add-hook 'scala-mode-hook
          '(lambda ()
             (scala-mode-feature-electric-mode)
             ))
(add-to-list 'load-path "/home/isaiah/builds/ensime_2.8.1-0.4.1/elisp/")
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
; slime
(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
(require 'slime)
(eval-after-load 'slime '(setq slime-protocol-version 'ignore))
(slime-setup '(slime-repl))
;;; backup/autosave
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
