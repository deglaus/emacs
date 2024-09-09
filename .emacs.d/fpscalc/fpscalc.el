;;; fpscalc-mode.el --- a major mode for .fps files and the fpscalc tool -*- lexical-binding: t
;;;
;;; Commentary:
;;;
;;; Use `compute' to execute the .fps program in the current
;;; buffer with the tool 'fpscalc'. This is by default bound
;;; to `C-c C-c'.
;;;
;;; Author: Emanuel Berg (incal) <moasenwood@zoho.eu>
;;; Created: 2014-07-03
;;; Keywords: unix
;;; License: GPL3+
;;; URL: https://dataswamp.org/~incal/fps/fpscalc.el
;;; Version: 2.0.0
;;;
;;; First update:
;;;
;;; This is an Emacs major mode [1] to be used with the tool
;;; fpscalc [2] to edit the kind of in-data .fps files [3]
;;; crunched by fpscalc.
;;;
;;; Have a look at the dump to get a feeling what it is all
;;; about [4].
;;;
;;; The mode includes:
;;;
;;; 1. A very ambitious font lock (or syntax highlight)
;;;    - it looks like a circus at first, but once you get
;;;    used to it, it is very useful. (I didn't use the
;;;    font-lock faces because I want everything to be
;;;    configurable on
;;;    a per-mode/-application/whatever basis.)
;;;
;;; 2. The familiar (un)comment (DWIM) key: M-;
;;;
;;; 3. Indentation (very easy - I just used the C mode ditto -
;;;    but nonetheless, it is there) [This is not so anymore.
;;;    The C mode inheritance is dropped, and indentation is
;;;    setup explicitly. Read on.]
;;;
;;; 4. A defun (`compute') to run fpscalc with the .fps
;;;    program that is currently edited in Emacs; then, have
;;;    Emacs show the result in a new buffer. By default, this
;;;    is bound to `C-c C-c'. This is more or less the same as
;;;    doing it in a shell, only it might be a small
;;;    time-and-comfort gain not having to leave Emacs.
;;;
;;; 5. The mode is associated with the ".fps" extension.
;;;
;;; Second update:
;;;
;;; In the first incarnation, to get indentation, I derived
;;; the fpscalc mode from the C mode. Because the syntaxes are
;;; so close, I thought that would work. And it did.... except
;;; for the M-; "!" comment. Such comments could be *inserted*
;;; on M-;, but not *removed*, instead, I got another comment
;;; layer (just like the nested quotes in messages).
;;;
;;; Also, comments broke indentation.
;;;
;;; So, I dropped the C mode, and the comments worked
;;; both ways.
;;;
;;; Last, I used some material I found on the web to get
;;; indentation. (The indentation code is very close to what
;;; I found. I would provide a link, but, right now, I can't
;;; find the page.)
;;;
;;; You have to have indentation. "May I indent your code?" is
;;; still the worst hacker insult in the book, a book that by
;;; now has quite a heft... Seriously, it stinks without
;;; indentation: half the time you just (re)align lines.
;;;
;;; Some extra material:
;;;
;;; Also, I made an example in LaTeX how to create diagrams,
;;; that can be used in connection with fpscalc, to illustrate
;;; task flows. Check out dumps, source, etc., here: [5].
;;; Actually, looking back at those figures now, they look
;;; gorgeous! They use the LaTeX 'pgfgantt' package.
;;;
;;; (I write this in this document, as it might be Googled for
;;; fpscalc, and lots of poor students, held at starvation
;;; point by the pitch-dark computer industry, might benefit
;;; from both the Emacs mode, and the diagram LaTeX
;;; skeleton code.)
;;;
;;; Last, writing such LaTeX code, there are lines like this:
;;;
;;;   \gantttitlelist{,,2,,,5,,7,,9,,,12,13,,15,,17}{1}
;;;
;;; used to produce the timeline. As you can see, to make it
;;; work, each digit has to be preceded by as many commas.
;;; To not have to insert those manually, I wrote some Elisp
;;; to do the job:
;;;
;;;   (defun insert-times-helper (times last)
;;;     (if times
;;;         (let*((next             (car times))
;;;               (rest             (cdr times))
;;;              (number-of-commas (- next last) ))
;;;          (dotimes (dummy number-of-commas) (insert ","))
;;;          (insert (int-to-string next))
;;;          (insert-times-helper rest next) )))
;;;  (defun insert-times (times)
;;;    (interactive "times: ")
;;;    (insert-times-helper times 0) )
;;;
;;; Use M-x insert-times (2 5 7 9 12 13 15 17) RET to get the
;;; above result. Note the perhaps uncommon (for interactive
;;; use) list syntax. In Elisp, it'd look like this:
;;;
;;;   (insert-times '(2 5 7 9 12 13 15 17))
;;;
;;; Also, I put this in my .zshrc so I don't have to bother
;;; with the redirection syntax of fpscalc.
;;;
;;;   # fpscalc
;;;   rt () {
;;;       ext=.fps
;;;       sys=$(basename $1 $ext)
;;;       fpscalc < ${sys}${ext} > ${sys}-fallout.txt
;;;   }
;;;
;;; Outro:
;;;
;;; Please drop me a mail (topmost this file) if you benefited
;;; from these tools, or if you have any comments how they can
;;; be improved.
;;;
;;; ---
;;; [1 - Elisp source]
;;;   http://user.it.uu.se/~embe8573/fps/fpscalc.el
;;;
;;; [2 - the tool: *not* written by me; external link]
;;;   http://www.idt.mdh.se/~ael01/fpscalc
;;;
;;; [3 - sample input file]
;;;   http://user.it.uu.se/~embe8573/fps/demo.fps
;;;
;;; [4 - source-in-mode dump]
;;;   http://user.it.uu.se/~embe8573/fps/fpscalc.png
;;;
;;; [5 - dump, source, and the PDF of a CIS ("critical
;;;      instant scheme"); and more]
;;;   http://user.it.uu.se/~embe8573/fps/cis/cis.png
;;;
;;; Code:

(define-abbrev-table 'fpscalc-mode-abbrev-table
  '(("init" "initialise")
    ("prio" "priority") ))

(defgroup fpscalc nil
  "The `fpscalc' mode."
  :group 'local)

(defgroup fpscalc-faces nil
  "The faces used by the `fpscalc' major mode."
  :group 'fpscalc
  :group 'faces)

(defface fpscalc-program-parts
  '((t :inherit font-lock-keyword-face :background "black" :foreground "magenta" :bold t))
  "The words declarations, initialise, semaphores, and formulas."
  )

(defface fpscalc-math-functions
  '((t :inherit font-lock-function-name-face :background "black" :foreground "red" :bold nil))
  "The words sigma; floor and ceiling; and, min and max."
  )

(defface fpscalc-task-priority-sets
  '((t :inherit font-lock-builtin-face :background "black" :foreground "magenta" :bold nil))
  "The words lp, ep, and hp; and all."
  )

(defface fpscalc-comment
  '((t :inherit font-lock-comment-face :background "black" :foreground "blue" :bold t))
  "The comment sign (!) as well as everything to its right."
  )

(defface fpscalc-variable-type
  '((t :inherit font-lock-type-face :background "black" :foreground "yellow"))
  "The words scalar, indexed, priority, and blocking."
  )

(defface fpscalc-variable-name
  '((t :inherit font-lock-variable-name-face :background "black" :foreground "green"))
  "After scalar, indexed, priority, and blocking; later, in use."
  )

(defface fpscalc-i-task
  '((t :inherit font-lock-constant-face :background "black" :foreground "yellow" :bold t))
  "The word i."
  )

(defface fpscalc-j-task
  '((t :inherit font-lock-constant-face :background "black" :foreground "blue" :bold t))
  "The word j."
  )

(defface fpscalc-tasks-keyword
  '((t :inherit font-lock-keyword-face :background "black" :foreground "blue"))
  "The word tasks."
  )

(defface fpscalc-task-name-and-index
  '((t :inherit font-lock-variable-name-face :background "black" :foreground "cyan" :bold t))
  "After tasks, and in use."
  )

(defface fpscalc-system-keyword
  '((t :inherit font-lock-keyword-face :background "black" :foreground "red" :bold t))
  "The word system."
  )

(defface fpscalc-system-name
  '((t :inherit font-lock-doc-face :background "black" :foreground "green" :bold t))
  "The word after the word system."
  )

(defface fpscalc-semaphore-keyword
  '((t :inherit font-lock-keyword-face :background "black" :foreground "blue" :bold nil))
  "The word semaphore."
  )

(defface fpscalc-semaphore-name
  '((t :inherit font-lock-variable-name-face :background "black" :foreground "yellow" :bold t))
  "The word after the word semaphore, after the left parenthesis."
  )

(defvar fpscalc-keywords
  '(("\\(!.*$\\)" . 'fpscalc-comment)
    ("\\(semaphore\\)\\((\\)\\([[:word:]]+\\)\\(\\, \\)\\([[:word:]]+\\)"
     (1 'fpscalc-semaphore-keyword)
     (3 'fpscalc-semaphore-name)
     (5 'fpscalc-task-name-and-index) )
    ("declarations\\|initialise\\|semaphores\\|formulas" . 'fpscalc-program-parts)
    ("sigma\\|floor\\|ceiling\\|min\\|max" . 'fpscalc-math-functions)
    ("lp\\|ep\\|hp\\|all" . 'fpscalc-task-priority-sets)
    ("\\([[:word:]]\\)\\(\\[\\)\\(i\\)\\(\\]\\)"
     (1 'fpscalc-variable-name)
     (3 'fpscalc-i-task) )
    ("\\([[:word:]]\\)\\(\\[\\)\\(j\\)\\(\\]\\)"
     (1 'fpscalc-variable-name)
     (3 'fpscalc-j-task))
    ("\\([[:word:]]\\)\\(\\[\\)\\(.*\\)\\(\\]\\)"
     (1 'fpscalc-variable-name)
     (3 'fpscalc-task-name-and-index))
    ("\\(system \\)\\(.* \\)"
     (1 'fpscalc-system-keyword)
     (2 'fpscalc-system-name))
    ("\\(scalar\\|indexed\\|priority\\|blocking\\)\\( \\)+\\(\\(\\([[:word:]]\\( *\\, *\\)?\\)\\)*\\)"
     (1 'fpscalc-variable-type)
     (3 'fpscalc-variable-name))
    ("\\(tasks +\\)\\(\\(\\([[:word:]]\\( *\\, *\\)?\\)\\)*\\)"
     (1 'fpscalc-tasks-keyword)
     (2 'fpscalc-task-name-and-index))
    ))

(define-generic-mode fpscalc-mode
  '("!")
  nil
  fpscalc-keywords
  '("\\.fps\\'")
  '((lambda ()
      (progn
        (setq indent-line-function 'fpscalc-indent-line)
        (local-set-key "\C-c\C-c" 'compute) )))
  "Major mode for .fps files and the fpscalc tool.")

(defvar fpscalc-mode-map
  (let ((the-map (make-keymap)))
    (define-key the-map (kbd "TAB") 'newline-and-indent)
    the-map)
  "Keymap for the fpscalc major mode.")

(defvar fpscalc-mode-syntax-table
  (let ((syntax-table (make-syntax-table)))
    (modify-syntax-entry ?!  "< b" syntax-table)
    (modify-syntax-entry ?\n "> b" syntax-table)
    syntax-table)
  "The syntax table for `fpscalc-mode'."
  )

(defcustom fpscalc-command-name "fpscalc"
  "Name of the fpscalc executable to invoke in `fpscalc-mode'."
  :type 'file
  )

(defun compute ()
  "Run the system defined in the current buffer (i.e., an .fps file), save the fallout in a file, and show that file in a new buffer."
  (interactive)
  (let*((src      (buffer-file-name))
        (src-base (file-name-sans-extension src))
        (dst      (format "%s_fallout.txt" src-base))
        (srcq     (shell-quote-argument src))
        (dstq     (shell-quote-argument dst)) )
    (shell-command (format "%s < %s > %s" fpscalc-command-name srcq dstq))
    (display-buffer (find-file-noselect dst)) ))

(defun fpscalc-indent-line ()
  "Indentation function."
  (interactive)
  (beginning-of-line)
  (if (bobp) (indent-line-to 0)
    (let ((not-indented t)
          (cur-indent   0)
          (indent-unit  2))
      (if (looking-at "^[ \t]*}")
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) indent-unit) ))
            (when (< cur-indent 0) (setq cur-indent 0)) )
        (save-excursion
          (while not-indented
            (forward-line -1)
            (if (looking-at "^[ \t]*}")
                (progn
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil) )
              (if (looking-at "^[ \t]*\\(system\\|declarations\\|semaphores\\|initialise\\|formulas\\)")
                  (progn
                    (setq cur-indent (+ (current-indentation) indent-unit))
                    (setq not-indented nil) )
                (when (bobp) (setq not-indented nil) ))))))
      (indent-line-to cur-indent) )))

(provide 'fpscalc)
;;; fpscalc.el ends here
