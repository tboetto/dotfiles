;;; tony-emacs-org.el --- Org mode, agenda, and export helpers  -*- lexical-binding: t; -*-
  (use-package
   org
   :ensure nil
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

(use-package
  org-agenda
  :ensure nil
  :bind
  (("C-c A" . org-agenda))
  :config (setq org-agenda-files (list org-directory)))

;; (use-package org-alert
;;   :ensure t
;;   :hook (org-agenda-mode . org-alert-mode))

(use-package
 org-modern
 :ensure t
 :hook (org-mode . org-modern-mode)
 :config
 (setq
  org-modern-keyword nil
  org-modern-block-name nil
  org-modern-timestamp nil
  ))

(use-package org-modern-indent
  :ensure (:host github :repo "jdtsmith/org-modern-indent")
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
(use-package valign :ensure (:host github :repo "casouri/valign") :hook (org-mode . valign-mode))

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
  (aas-set-snippets 'laas-mode
    :cond #'my/org-math-start-p
    ";;m" (lambda () (interactive) (insert "\\(\\)") (backward-char 2))
    ";;M" (lambda () (interactive) (insert "\\[\\]") (backward-char 2))))

(defun my/denote-org-files ()
  "Denote files ending in .org; skips stray files like *.org.empty-*."
  (denote-directory-files "\\.org\\'"))

(setq org-refile-targets
      '(("~/Documents/org/tasks.org" :maxlevel . 2)
        (my/denote-org-files :maxlevel . 2))
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

(use-package ob-racket
  :ensure (:host github :repo "DEADB17/ob-racket"))

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
