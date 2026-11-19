;;; tony-emacs-org.el --- Org mode, agenda, and export helpers  -*- lexical-binding: t; -*-
  (use-package
   org
   :ensure nil
   :defer t
   :init
   (setopt org-confirm-babel-evaluate nil)
   (setq org-directory (expand-file-name "~/Documents/org/"))
   (setq org-imenu-depth 7)
   (setq org-log-done 'time)
   (setq org-log-into-drawer t)
   :config
   (setq org-startup-indented t)
   (add-to-list 'org-src-lang-modes '("typescript" . typescript-ts))
   )

(require 'warnings)
(add-to-list 'warning-suppress-log-types
             '(defvaralias losing-value org-format-latex-header))

(use-package
  org-agenda
  :ensure nil
  :bind
  (("C-c A" . org-agenda))
  :config (setq org-agenda-files (list org-directory)))

;; mode-line clock shows only today's clocked time (not all-time total)
(setq org-clock-mode-line-total 'today)

(use-package org-wild-notifier
  :ensure t
  :defer t
  :init (run-with-idle-timer 5 nil #'org-wild-notifier-mode 1)
  :custom
  ;; dunst via libnotify on Linux, osascript-based notifications on macOS
  (alert-default-style (if (eq system-type 'darwin) 'osx-notifier 'libnotify))
  (org-wild-notifier-alert-time '(10 0))
  (org-wild-notifier-keyword-whitelist '("TODO" "NEXT"))
  ;; untimed (day-wide) tasks: remind at these times
  (org-wild-notifier-day-wide-alert-times '("09:00" "14:30")))

(use-package
 org-modern
 :ensure t
 :hook (org-mode . org-modern-mode)
 :config
 (setq
  org-modern-keyword nil
  org-modern-block-name nil
  ;; valign draws tables; with both on, the rule under a header row
  ;; comes out as a short box that ignores the column widths.
  org-modern-table nil
  org-modern-timestamp nil
  ))

(use-package org-modern-indent
  :ensure (:host github :repo "jdtsmith/org-modern-indent")
  :defer t
  :hook
  (org-mode . (lambda ()
                (org-indent-mode 1)
                (org-modern-indent-mode 1))))

(use-package org-appear :ensure t :hook (org-mode . org-appear-mode))
(setq org-appear-trigger 'always)

(setq org-startup-with-latex-preview t
      org-highlight-latex-and-related '(latex))
(add-hook 'org-mode-hook #'org-latex-preview-mode)
(with-eval-after-load 'org-latex-preview
  (define-advice org-latex-preview--tex-styled (:filter-args (args) always-emit-color)
    (pcase-let ((`(,type ,value ,options) args))
      (list type value (plist-put (copy-sequence options) :continue-color nil)))))

;; pixel-aligns table columns so latex preview images do not skew the pipes
(use-package valign
  :ensure (:host github :repo "casouri/valign")
  :hook (org-mode . valign-mode)
  :custom (valign-fancy-bar t))

(use-package auctex
  :ensure (:host github :repo "emacsmirror/auctex" :files ("texmathp.el"))
  :defer t)
(use-package tempel :ensure t :defer t)
(use-package laas
  :ensure t
  :hook (org-mode . laas-mode)
  :config
  (defun my/org-math-start-p ()
    "Non-nil at the start of a word in Org prose, outside math, code blocks and verbatim text."
    (ignore-errors
      (and (not (laas-mathp))
           (or (bolp) (memq (char-before) '(?\s ?\t ?\()))
           (not (org-in-block-p '("src" "example" "export")))
           (not (memq (org-element-type (org-element-context)) '(verbatim code))))))
  (defun my/laas-word-start-p ()
    "Non-nil in math when the snippet key does not continue a word or a \\command."
    (and (laas-mathp)
         (not (and (char-before)
                   (or (eq (char-before) ?\\)
                       (memq (get-char-code-property (char-before) 'general-category)
                             '(Lu Ll)))))))
  (defun my/latex-in-text-arg-p ()
    "Non-nil when point is inside the argument of \\text, \\mbox or a \\textXX command."
    (seq-some (lambda (open)
                (and (eq (char-after open) ?{)
                     (save-excursion
                       (goto-char open)
                       (looking-back "\\\\\\(?:text[a-z]*\\|mbox\\|intertext\\)" (line-beginning-position)))))
              (nth 9 (syntax-ppss))))
  (advice-add 'laas-org-mathp :after-while
              (lambda () (not (my/latex-in-text-arg-p)))
              '((name . my/laas-not-in-text)))
  (defun my/tempel (template)
    "Return a command that inserts tempel TEMPLATE."
    (lambda () (interactive) (tempel-insert template)))
  (aas-set-snippets 'laas-mode
    :cond #'my/org-math-start-p
    ";;m" (my/tempel '("\\(" p "\\)"))
    ";;M" (my/tempel '("\\[" p "\\]"))
    ";;a" (my/tempel '("\\begin{align*}" n p n "\\end{align*}"))
    ";;b" (my/tempel '("\\begin{" (p "" env) "}" n p n "\\end{" env "}")))
  (aas-set-snippets 'laas-mode
    :cond #'laas-mathp
    ";;o" "^\\circ"
    "sec" "\\sec" ; laas ships csc/cot/arcsec but no sec
    "flr" (my/tempel '("\\lfloor " p " \\rfloor"))
    "cei" (my/tempel '("\\lceil " p " \\rceil"))
    "td" (my/tempel '("^{" p "}"))
    "rd" (my/tempel '("^{(" p ")}"))
    "__" (my/tempel '("_{" p "}"))
    "invs" "^{-1}"
    "compl" "^{c}"
    "Nn" "\\cap"
    "UU" "\\cup"
    "bcap" (my/tempel '("\\bigcap_{" (p "i \\in I") "} "))
    "bcup" (my/tempel '("\\bigcup_{" (p "i \\in I") "} "))
    "ooo" "\\infty"
    "OO" "\\emptyset"
    "lll" "\\ell"
    "nabl" "\\nabla"
    "<->" "\\leftrightarrow"
    "<!" "\\triangleleft"
    "DD" "\\DD")
  (aas-set-snippets 'laas-mode
    :cond #'my/laas-word-start-p
    "case" (my/tempel '("\\begin{cases} " p " & " p " \\\\ " p " & " p " \\end{cases}"))
    "pmat" (my/tempel '("\\begin{pmatrix} " p " \\end{pmatrix}"))
    "bmat" (my/tempel '("\\begin{bmatrix} " p " \\end{bmatrix}"))
    "vmat" (my/tempel '("\\begin{vmatrix} " p " \\end{vmatrix}"))
    "cvec" (my/tempel '("\\begin{pmatrix} " (p "x" var) "_" (p "1")
                        " \\\\ \\vdots \\\\ " var "_" (p "n") " \\end{pmatrix}"))
    "sum" (my/tempel '("\\sum_{" (p "n") "=" (p "1") "}^{" (p "\\infty") "} " p))
    "prod" (my/tempel '("\\prod_{" (p "n") "=" (p "1") "}^{" (p "\\infty") "} " p))
    "taylor" (my/tempel '("\\sum_{" (p "k" k) "=" (p "0") "}^{" (p "\\infty") "} "
                          (p "c") "_" k " (x-" (p "a") ")^" k))
    "lim" (my/tempel '("\\lim_{" (p "n") " \\to " (p "\\infty") "} "))
    "lsup" (my/tempel '("\\limsup_{" (p "n") " \\to " (p "\\infty") "} "))
    "linf" (my/tempel '("\\liminf_{" (p "n") " \\to " (p "\\infty") "} "))
    "int" "\\int"
    "dint" (my/tempel '("\\int_{" p "}^{" p "} " p))
    "part" (my/tempel '("\\frac{\\partial " p "}{\\partial " p "}"))
    "sq" (my/tempel '("\\sqrt{" p "}"))
    "set" (my/tempel '("\\{ " p " \\}"))
    "norm" (my/tempel '("\\| " p " \\|"))
    "conj" (my/tempel '("\\overline{" p "}"))
    "tt" (my/tempel '("\\text{" p "}"))
    "sts" (my/tempel '("_\\text{" p "}"))
    "mcal" (my/tempel '("\\mathcal{" p "}"))
    "lrp" (my/tempel '("\\left( " p " \\right)"))
    "lrs" (my/tempel '("\\left[ " p " \\right]"))
    "lrb" (my/tempel '("\\left\\{ " p " \\right\\}"))
    "lrv" (my/tempel '("\\left| " p " \\right|"))
    "lra" (my/tempel '("\\left\\langle " p " \\right\\rangle")))
  ;; TAB leaves the fragment; tempel-map is only active during a template.
  (with-eval-after-load 'tempel
    (define-key tempel-map (kbd "TAB") #'tempel-next)
    (define-key tempel-map (kbd "<tab>") #'tempel-next)
    (define-key tempel-map (kbd "<backtab>") #'tempel-previous)
    ;; Leave M-RET to Org (new bullet); tempel's default is tempel-done.
    (keymap-unset tempel-map "M-RET" t)
    ;; tempel-map stays active in the whole buffer until every template is
    ;; finished, so finish a template once point leaves it.
    (defun my/tempel-finish-when-left ()
      "Finish each active tempel template that point is no longer inside."
      (when tempel--active
        (dolist (st (copy-sequence tempel--active))
          (let ((range (caar st)))
            (if (not (overlay-buffer range))
                (tempel--disable st)
              (unless (<= (overlay-start range) (point) (overlay-end range))
                (tempel--done st)))))))
    (add-hook 'post-command-hook #'my/tempel-finish-when-left)
    (defvar-local my/org-math--auto-space nil
      "Position just after the space `my/org-math-space-after-exit' inserted.")
    (defun my/org-math-drop-auto-space ()
      "Delete the auto-inserted space when the next typed character is punctuation."
      (remove-hook 'post-self-insert-hook #'my/org-math-drop-auto-space t)
      (when (and (eql (1- (point)) my/org-math--auto-space)
                 (memq last-command-event '(?. ?, ?? ?! ?: ?\; ?\)))
                 (eq (char-before (1- (point))) ?\s))
        (save-excursion (goto-char (- (point) 2)) (delete-char 1))))
    (defun my/org-math-space-after-exit (&rest _)
      "Insert a space after a math fragment TAB has just stepped out of."
      (when (and (derived-mode-p 'org-mode)
                 (looking-back "\\\\[])]" (- (point) 2))
                 (or (eolp) (not (looking-at-p "[[:space:][:punct:]]"))))
        (insert " ")
        (setq my/org-math--auto-space (point))
        (add-hook 'post-self-insert-hook #'my/org-math-drop-auto-space nil t)))
    (advice-add 'tempel-next :after #'my/org-math-space-after-exit)))

;; laas expands to commands plain LaTeX lacks (\RR, \arcsec, \mathem, ...).
;; \providecommand never clobbers a real one. Needs amsmath and amssymb.
(defconst my/latex-math-macros
  (concat (mapconcat (lambda (l) (format "\\providecommand{\\%s%s}{\\mathbb{%s}}" l l l))
                     '("N" "Z" "Q" "R" "C" "P" "H" "F" "D") "\n")
          "\n\\providecommand{\\mathem}[1]{\\mathit{#1}}\n"
          "\\DeclareMathOperator{\\arccot}{arccot}\n"
          "\\DeclareMathOperator{\\arccsc}{arccsc}\n"
          "\\DeclareMathOperator{\\arcsec}{arcsec}")
  "LaTeX definitions for the commands laas snippets expand to.")

(setq org-latex-preview-preamble
      (concat "\\documentclass{article}\n[DEFAULT-PACKAGES]\n[PACKAGES]\n\\usepackage{xcolor}\n"
              my/latex-math-macros))

(defun my/denote-org-files ()
  "Denote files ending in .org; skips stray files like *.org.empty-*."
  (denote-directory-files "\\.org\\'"))

(setq org-refile-targets
      '(("~/Documents/org/tasks.org" :maxlevel . 2)
        (my/denote-org-files :maxlevel . 2))
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

(use-package ob-racket
  :ensure (:host github :repo "DEADB17/ob-racket")
  :after org)

(use-package
  ox-md
  :ensure nil
  :after org
  :config
  (defun my/org-subtree-to-markdown-clipboard ()
    "Export the current org subtree to markdown and copy to clipboard."
    (interactive)
    (let ((md (org-export-as 'md t)))
      (kill-new md)
      (message "Subtree exported to clipboard as markdown")))

  (defun my/org-subtree-to-slack-clipboard ()
    "Export the current org subtree to Slack-formatted text and copy to clipboard."
    (interactive)
    (let* ((md (org-export-as 'md t))
           (slack (with-temp-buffer
                    (insert md)
                    ;; Remove table of contents
                    (goto-char (point-min))
                    (when (re-search-forward "^# Table of Contents$" nil t)
                      (let ((start (line-beginning-position)))
                        (when (re-search-forward "^<a id=" nil t)
                          (delete-region start (line-beginning-position)))))
                    ;; Remove <a id="..."></a> anchor lines
                    (goto-char (point-min))
                    (while (re-search-forward "^<a id=\"[^\"]*\"></a>\n?" nil t)
                      (replace-match ""))
                    ;; Convert markdown headings to Slack bold
                    (goto-char (point-min))
                    (while (re-search-forward "^#+ \\(.*\\)$" nil t)
                      (replace-match "*\\1*"))
                    ;; Collapse multiple blank lines
                    (goto-char (point-min))
                    (while (re-search-forward "\n\n\n+" nil t)
                      (replace-match "\n\n"))
                    (string-trim (buffer-string)))))
      (kill-new slack)
      (message "Subtree exported to clipboard as Slack-formatted text"))))

(provide 'tony-emacs-org)
