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
 '(ecb-default-directory "/home/isaiah")
 '(ecb-layout-name "left14")
 '(ecb-layout-window-sizes (quote (("left14" (ecb-directories-buffer-name 0.25380710659898476 . 0.72) (ecb-history-buffer-name 0.25380710659898476 . 0.26)))))
 '(ecb-options-version "2.40")
 '(ecb-source-path (quote ((#("/" 0 1 (help-echo "Mouse-2 toggles maximizing, mouse-3 displays a popup-menu")) #("/" 0 1 (help-echo "Mouse-2 toggles maximizing, mouse-3 displays a popup-menu"))) ("/home/isaiah/codes" "codes"))))
 '(inhibit-startup-screen t)
 '(quack-default-program "mzscheme")
 '(quack-programs (quote ("mzscheme" "bigloo" "csi" "csi -hygienic" "gosh" "gracket" "gsi" "gsi ~~/syntax-case.scm -" "guile" "kawa" "mit-scheme" "racket" "racket -il typed/racket" "rs" "scheme" "scheme48" "scsh" "sisc" "stklos" "sxi")))
 '(quack-run-scheme-always-prompts-p nil)
 '(show-paren-mode t)
 '(speedbar-smart-directory-expand-flag nil)
 '(sr-speedbar-right-side nil)
 '(tool-bar-mode nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "darkslategrey" :foreground "wheat" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 135 :width normal :foundry "xos4" :family "Terminus")))))
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

(global-set-key (kbd "C-i") 'viper-change-state-to-vi)

;; Autoindent open-*-lines
(defvar newline-and-indent t
  "Modify the behavior of the open-*-line functions to cause them to autoindent.")
; color-theme
(require 'color-theme)
(eval-after-load "color-theme"
                 '(progn
                    (color-theme-initialize)
                    (color-theme-tangotango)))

;(add-to-list 'load-path "/usr/share/emacs/site-lisp/highlight-parentheses.el")
;(require 'highlight-parentheses)
;(setq hl-paren-colors
;      '(;"#8f8f8f" ; this comes from Zenburn
;                   ; and I guess I'll try to make the far-outer parens look like this
;        "orange1" "yellow1" "greenyellow" "green1"
;        "springgreen1" "cyan1" "slateblue1" "magenta1" "purple"))

; (add-hook 'scheme-mode-hook (lambda () (highlight-parentheses-mode +1)))
<<<<<<< HEAD
=======
(add-hook 'scheme-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'clojure-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'slime-repl-mode-hook (lambda () (paredit-mode +1)))
>>>>>>> 6611075ac1c96e23529662d6b5d14e1dda461f8a
; (add-hook 'clojure-mode-hook (lambda () (set (make-local-variable 'ffip-regexp) ".*\\.clj")))
(add-hook 'scheme-mode-hook 
            (lambda () 
                (paredit-mode t)
                (show-paren-mode +1)))
(defalias 'yes-or-no-p 'y-or-n-p)
; org-mode
(require 'org-install)
(setq org-agenda-files (list "~/.org/tasks.org"))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
;(add-to-list 'load-path "/usr/share/emacs/scala-mode")
;(require 'scala-mode-auto)
;(add-hook 'scala-mode-hook
;          '(lambda ()
;             (scala-mode-feature-electric-mode)
;             ))
;(add-to-list 'load-path "/home/isaiah/builds/ensime_2.8.1-0.4.1/elisp/")
;(require 'ensime)
;(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
; slime
;(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
;(require 'slime)
;(eval-after-load 'slime '(setq slime-protocol-version 'ignore))
;(slime-setup '(slime-repl))
;;; backup/autosave
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
<<<<<<< HEAD

; icicles
(setq load-path (cons "/usr/share/emacs/site-lisp/icicles" load-path))
(require 'icicles)

;(load-file "~/.emacs.d/elpa-to-submit/viper-in-more-modes.el")
;(add-to-list 'load-path "~/.emacs.d/elpa-to-submit/viper-in-more-modes.el")
;(add-to-list 'load-path "~/.emacs.d/elpa-to-submit/viper-boot.el")
(require 'vimpulse)
;(require 'viper-in-more-modes)

;;; full-ack
;(add-to-list 'load-path "~/.emacs.d/elpa-to-submit/full-ack.el")
;(load-file "~/.emacs.d/elpa-to-submit/full-ack.el")
;(autoload 'ack-same "full-ack" nil t)
;(autoload 'ack "full-ack" nil t)
;(autoload 'ack-find-same-file "full-ack" nil t)
;(autoload 'ack-find-file "full-ack" nil t)

;;; slime-override-mode
;; http://github.com/briancarper/dotfiles/raw/master/.emacs
;; {} are not handled correctly by paredit in the repl,
;; but these lines fixes it
(defvar slime-override-map (make-keymap))
(define-minor-mode slime-override-mode
  "Fix SLIME REPL keybindings"
  nil " SLIME-override" slime-override-map)

(define-key slime-override-map (kbd "<C-return>") 'paredit-newline)
(define-key slime-override-map (kbd "{") 'paredit-open-curly)
(define-key slime-override-map (kbd "}") 'paredit-close-curly)
(define-key slime-override-map [delete] 'paredit-forward-delete)
(define-key slime-override-map [backspace] 'paredit-backward-delete)
;;(define-key slime-override-map "\C-j" 'slime-repl-return)

(add-hook 'slime-repl-mode-hook
        (lambda ()
                (slime-override-mode t)
                (paredit-mode t)
                (slime-redirect-inferior-output)
                (modify-syntax-entry ?\[ "(]")
                (modify-syntax-entry ?\] ")[")
                (modify-syntax-entry ?\{ "(}")
                (modify-syntax-entry ?\} "){")))
(add-hook 'clojure-mode-hook    
        (lambda () 
                (paredit-mode t)
                (slime-override-mode t)))
(require 'sr-speedbar)
(global-set-key (kbd "<f11>") 'sr-speedbar-toggle)
(custom-set-variables
   '(speedbar-show-unknown-files t))
;;; dirtree
;(load-file "~/.emacs.d/elpa-to-submit/tree-mode.el")
;(load-file "~/.emacs.d/elpa-to-submit/windata.el")
;(load-file "~/.emacs.d/elpa-to-submit/dirtree.el")
;(autoload 'dirtree "dirtree" "Add directory to tree view")
;(set-default-font "terminus-14")
