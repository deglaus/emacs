;; Minibuffer kill
(define-key minibuffer-local-map "\M-s" nil)

;; Line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)                             
(add-hook 'text-mode-hook 'display-line-numbers-mode)  

;; Show parantheses
(show-paren-mode 1)

;; (Hopefully) enable copy-pasta outside of Emacs
(setq x-select-enable-clipboard t)

;; Disable auto backup files
(setq make-backup-files nil)                                                      
(setq auto-save-default nil)

;; Conservatice scrolling
(setq scroll-conservatively 100)

;; Disable ring-bell
(setq ring-bell-function 'ignore) 

;; Prettyify
(global-prettify-symbols-mode t)

;; Braket pair-mathing
  (setq electric-pair-pairs '(
                              (?\{ . ?\})
                              (?\( . ?\))
                              (?\[ . ?\])
                              (?\" . ?\")
                              ))
  (electric-pair-mode t)

;; Cursor put in new window 
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

;; Highlight current line
(global-hl-line-mode t)

;; yes y no n
(defalias 'yes-or-no-p 'y-or-n-p)

;; defer package loading
(setq use-package-always-defer t)

;; search keybind
(global-set-key (kbd "C-s") 'isearch-forward)
(define-key isearch-mode-map "\C-s" 'isearch-repeat-forward)

;; comment-uncomment keybind
(global-set-key (kbd "C-c r") 'comment-region)
(global-set-key (kbd "C-c u") 'uncomment-region)

;; Eshell
(defun eshell-other-window ()
  "Create or visit an eshell buffer."
  (interactive)
  (if (not (get-buffer "*eshell*"))
      (progn
        (split-window-sensibly (selected-window))
        (other-window 1)
        (eshell))
    (switch-to-buffer-other-window "*eshell*")))

(global-set-key (kbd "<s-C-return>") 'eshell-other-window)
(defalias 'open 'find-file-other-window)
(defalias 'c 'eshell/clear-scrollback)

;; Beacon on cursor
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :init
  (beacon-mode 1))

;; Switch window
(use-package switch-window
  :ensure t
  :config
  (setq switch-window-input-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcuts
		'("a" "s" "d" "f" "j" "k" "l"))
  :bind
  ([remap other-window] . switch-window))

;; Ido mode -- ease buffer and find file

(use-package ido
  :init
  (ido-mode 1)
  :config
  (setq ido-enable-flex-matching nil)
  (setq ido-create-new-buffer 'always)
  (setq ido-everywhere t))

(use-package ido-vertical-mode
  :ensure t
  :init
  (ido-vertical-mode 1))
										; This enables arrow keys to select while in ido mode. If you want to
										; instead use the default Emacs keybindings, change it to
										; "'C-n-and-C-p-only"
(setq ido-vertical-define-keys 'C-n-C-p-up-and-down)


;; page-break lines
(use-package page-break-lines
  :ensure t
  :diminish (page-break-lines-mode visual-line-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((projectile-project-compilation-cmd . "bear -- scons build/X86_MESI_Two_Level/gem5.debug -j 12"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
