;; Make emacs startup faster
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
 
(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
 
(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))
 
(defun startup/reset-gc ()
  (setq gc-cons-threshold 16777216
    gc-cons-percentage 0.1))
 
(add-hook 'emacs-startup-hook 'startup/revert-file-name-handler-alist)
(add-hook 'emacs-startup-hook 'startup/reset-gc)
;;

;; Initialize melpa repo
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
        '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load Witchmacs theme
(load-theme 'Witchmacs t)

;; Set emacs to fullscreen upon launch
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#262626" "#FF6666" "#A6E22E" "#FFFF66" "#6666FF" "#FD5FF0" "#99CCFF" "#F1EFEE"])
 '(custom-safe-themes
   '("f137a76eab702d9b967e928c6f5526ac263fde0ade01f1cbcb78835637645f4c" "5d2953871baac3b77e2ed6cc606724672e27e939c973568a3b7fe80b8af8d4bf" "e2ddc4645016398e70a3abac2e3c8c6af2787bfe35dfc9cab53f76a6aec7a10c" "5f7280d1c4c655b850f2a8ad5fa7db3e5bda1de7ec57d3504c2463d8413b8e6e" "acb636fb88d15c6dd4432e7f197600a67a48fd35b54e82ea435d7cd52620c96d" default))
 '(package-selected-packages
   '(meghanada company-irony company-c-headers yasnippet-snippets yasnippet company magit treemacs-icons-dired treemacs-evil treemacs undo-tree page-break-lines async ido-vertical-mode switch-window avy beacon evil swiper which-key dashboard spaceline diminish auto-package-update htmlize use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
