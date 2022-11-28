(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)

(show-paren-mode 1)

(setq inhibit-startup-message t)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq x-select-enable-clipboard t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq scroll-conservatively 100)

(setq ring-bell-function 'ignore)

(setq-default tab-width 4)
(setq-default standard-indent 4)
(setq c-basic-offset tab-width)
(setq-default electric-indent-inhibit t)
(setq-default indent-tabs-mode t)
(setq backward-delete-char-untabify-method 'nil)

(global-prettify-symbols-mode t)

(setq electric-pair-pairs '(
                            (?\{ . ?\})
                            (?\( . ?\))
                            (?\[ . ?\])
                            (?\" . ?\")
                            ))
(electric-pair-mode t)

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

(defalias 'yes-or-no-p 'y-or-n-p)

(global-set-key (kbd "s-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "s-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "s-C-<down>") 'shrink-window)
(global-set-key (kbd "s-C-<up>") 'enlarge-window)

(global-hl-line-mode t)

(setq use-package-always-defer t)

;; Transparency usually on 95
(set-frame-parameter (selected-frame) 'alpha '(100 100))
(add-to-list 'default-frame-alist '(alpha 100 100))

(global-set-key (kbd "C-s") 'isearch-forward)
(define-key isearch-mode-map "\C-s" 'isearch-repeat-forward)

(global-set-key (kbd "C-c r") 'comment-region)
(global-set-key (kbd "C-c u") 'uncomment-region)

(use-package org
  :config
  (add-hook 'org-mode-hook 'org-indent-mode)
  (add-hook 'org-mode-hook
            '(lambda ()
               (visual-line-mode 1))))

(use-package org-indent
  :diminish org-indent-mode)

(use-package htmlize
  :ensure t)

(setq eshell-prompt-regexp "^[^αλ\n]*[αλ] ")
(setq eshell-prompt-function
      (lambda nil
        (concat
         (if (string= (eshell/pwd) (getenv "HOME"))
             (propertize "~" 'face `(:foreground "#99CCFF"))
           (replace-regexp-in-string
            (getenv "HOME")
            (propertize "~" 'face `(:foreground "#99CCFF"))
            (propertize (eshell/pwd) 'face `(:foreground "#99CCFF"))))
         (if (= (user-uid) 0)
             (propertize " α " 'face `(:foreground "#FF6666"))
         (propertize " λ " 'face `(:foreground "#A6E22E"))))))

(setq eshell-highlight-prompt nil)

(defalias 'open 'find-file-other-window)
(defalias 'c 'eshell/clear-scrollback)

(defun eshell/sudo-open (filename)
  "Open a file as root in Eshell."
  (let ((qual-filename (if (string-match "^/" filename)
                           filename
                         (concat (expand-file-name (eshell/pwd)) "/" filename))))
    (switch-to-buffer
     (find-file-noselect
      (concat "/sudo::" qual-filename)))))

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

(use-package auto-package-update
  :defer nil
  :ensure t
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package diminish
  :ensure t)

;(defmacro diminish-built-in (&rest modes)
;  "Accepts a list MODES of built-in emacs modes and generates `with-eval-after-load` diminish forms based on the file implementing the mode functionality for each mode."
;  (declare (indent defun))
;  (let* ((get-file-names (lambda (pkg) (file-name-base (symbol-file pkg))))
;	 (diminish-files (mapcar get-file-names modes))
;	 (zip-diminish   (-zip modes diminish-files)))
;    `(progn
;       ,@(cl-loop for (mode . file) in zip-diminish
;		  collect `(with-eval-after-load ,file
;			     (diminish (quote ,mode)))))))
; This bit goes in init.el
;(diminish-built-in
;  beacon-mode
;  which-key-mode
;  page-break-lines-mode
;  undo-tree-mode
;  eldoc-mode
;  abbrev-mode
;  irony-mode
;  company-mode
;  meghanada-mode)

(use-package spaceline
  :ensure t)

(use-package powerline
      :ensure t
      :init
      (spaceline-spacemacs-theme)
      :hook
      ('after-init-hook) . 'powerline-reset)

(use-package dashboard
  :ensure t
  :defer nil
  :preface
  (defun update-config ()
    "Update Witchmacs to the latest version."
    (interactive)
    (let ((dir (expand-file-name user-emacs-directory)))
      (if (file-exists-p dir)
          (progn
            (message "Witchmacs is updating!")
            (cd dir)
            (shell-command "git pull")
            (message "Update finished. Switch to the messages buffer to see changes and then restart Emacs"))
        (message "\"%s\" doesn't exist." dir))))

  (defun create-scratch-buffer ()
    "Create a scratch buffer"
    (interactive)
    (switch-to-buffer (get-buffer-create "*scratch*"))
    (lisp-interaction-mode))
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents . 5)))
  (setq dashboard-banner-logo-title "E M A C S")
  (setq dashboard-startup-banner "~/.emacs.d/yuidash.png")
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts nil)
  (setq dashboard-set-init-info t)
  (setq dashboard-init-info (format "%d packages loaded in %s"
                                    (length package-activated-list) (emacs-init-time)))
  (setq dashboard-set-footer nil)
  (setq dashboard-set-navigator t)
  (setq dashboard-navigator-buttons
        `(;; line1 (currently empty)

          ;; line 2
          ((,nil
            "Open scratch buffer"
            "Switch to the scratch buffer"
            (lambda (&rest _) (create-scratch-buffer))
            'default)
           (nil
            "Open config.org"
            "Open Witchmacs' configuration file for easy editing"
            (lambda (&rest _) (find-file "~/.emacs.d/config.org"))
            'default)))))

;(insert (concat
;         (propertize (format "%d packages loaded in %s"
;                             (length package-activated-list) (emacs-init-time))
;                     'face 'font-lock-comment-face)))
;
;(dashboard-center-line)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :init
  (which-key-mode))

(use-package swiper
  :ensure t
  ;;:bind ("C-s" . 'swiper)
  )

(use-package evil
  :ensure t
  :defer nil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
;; evil-mode 0 means disabled. Change to 1 to enable it.
  (evil-mode 0))

;(use-package evil-collection
;  :after evil
;  :ensure t
;  :config
;  (evil-collection-init))

(use-package beacon
  :ensure t
  :diminish beacon-mode
  :init
  (beacon-mode 1))

(use-package avy
      :ensure t
      :bind
      ("M-s" . avy-goto-char))

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

(use-package async
      :ensure t
      :init
      (dired-async-mode 1))

(use-package page-break-lines
  :ensure t
  :diminish (page-break-lines-mode visual-line-mode))

(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode)

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if (executable-find "python3") 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-follow-delay             0.2
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         30)
    (treemacs-resize-icons 11)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (executable-find "python3"))))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after treemacs evil
    :ensure t)

  (use-package treemacs-icons-dired
    :after treemacs dired
    :ensure t
    :config (treemacs-icons-dired-mode))

(use-package magit
  :ensure t)

(use-package latex
    :mode
    ("\\.tex\\'" . latex-mode)
    :bind
    (:map LaTeX-mode-map
          ("M-<delete>" . TeX-remove-macro)
          ("C-c C-r" . reftex-query-replace-document)
          ("C-c C-g" . reftex-grep-document))
    :init
    ;; A function to delete the current macro in AUCTeX.
    ;; Note: keybinds won't be added to TeX-mode-hook if not kept at the end of the AUCTeX setup!
    (defun TeX-remove-macro ()
        "Remove current macro and return TRUE, If no macro at point, return Nil."
        (interactive)
        (when (TeX-current-macro)
            (let ((bounds (TeX-find-macro-boundaries))
                  (brace  (save-excursion
                              (goto-char (1- (TeX-find-macro-end)))
                              (TeX-find-opening-brace))))
                (delete-region (1- (cdr bounds)) (cdr bounds))
                (delete-region (car bounds) (1+ brace)))
            t))
    :config
    (add-to-list 'TeX-command-list
                 '("Makeglossaries" "makeglossaries %s" TeX-run-command nil
                   (latex-mode)
                   :help "Run makeglossaries script, which will choose xindy or makeindex") t)

    (setq-default TeX-master nil ; by each new fie AUCTEX will ask for a master fie.
                  TeX-PDF-mode t
                  TeX-engine 'xetex)     ; optional

    (setq TeX-auto-save t
          TeX-save-query nil       ; don't prompt for saving the .tex file
          TeX-parse-self t
          TeX-show-compilation nil         ; if `t`, automatically shows compilation log
          LaTeX-babel-hyphen nil ; Disable language-specific hyphen insertion.
          ;; `"` expands into csquotes macros (for this to work, babel pkg must be loaded after csquotes pkg).
          LaTeX-csquotes-close-quote "}"
          LaTeX-csquotes-open-quote "\\enquote{"
          TeX-file-extensions '("Rnw" "rnw" "Snw" "snw" "tex" "sty" "cls" "ltx" "texi" "texinfo" "dtx"))

    ;; Font-lock for AuCTeX
    ;; Note: '«' and '»' is by pressing 'C-x 8 <' and 'C-x 8 >', respectively
    (font-lock-add-keywords 'latex-mode (list (list "\\(«\\(.+?\\|\n\\)\\)\\(+?\\)\\(»\\)" '(1 'font-latex-string-face t) '(2 'font-latex-string-face t) '(3 'font-latex-string-face t))))
    ;; Add standard Sweave file extensions to the list of files recognized  by AuCTeX.
    (add-hook 'TeX-mode-hook (lambda () (reftex-isearch-minor-mode)))
    )

(use-package eldoc
  :diminish eldoc-mode)

(use-package abbrev
  :diminish abbrev-mode)

(use-package company
  :ensure t
  :diminish (meghanada-mode company-mode irony-mode)
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 3)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "SPC") #'company-abort)
  :hook
  ((java-mode c-mode c++-mode) . company-mode))

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :hook
  ((c-mode c++-mode) . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :ensure t)

(use-package company-c-headers
       :defer nil
       :ensure t)

     (use-package company-irony
       :defer nil
       :ensure t
       :config
       (setq company-backends '((company-c-headers
                                 company-dabbrev-code
                                 company-irony))))
     (use-package irony
       :defer nil
       :ensure t
       :config
       :hook
       ((c++-mode c-mode) . irony-mode)
       ('irony-mode-hook) . 'irony-cdb-autosetup-compile-options)

   ;; Binds C-c C-l to compile in C-mode
       (add-hook 'c-mode-common-hook 
             (lambda () (define-key c-mode-base-map (kbd "C-c C-l") 'compile)))

;; Binds super right to end of line and super left to beginning of line.
       (add-hook 'c-mode-common-hook 
             (lambda () (define-key c-mode-base-map (kbd "<s-right>") 'move-end-of-line)))

  (add-hook 'c-mode-common-hook 
             (lambda () (define-key c-mode-base-map (kbd "<s-left>") 'move-beginning-of-line)))

(use-package meghanada
  :ensure t
  :defer nil
  :config
  (add-hook 'java-mode-hook
            (lambda ()
              (meghanada-mode t)))
  (setq meghanada-java-path "java")
  (setq meghanada-maven-path "mvn"))

(add-to-list 'load-path "~/.emacs.d/web/")
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))

(unless (package-installed-p 'clojure-mode)
  (package-install 'clojure-mode))

(add-to-list 'load-path "~/.emacs.d/go-mode.el/")
(autoload 'go-mode "go-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
