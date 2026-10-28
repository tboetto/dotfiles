;;; tony-emacs-project.el --- project.el tweaks  -*- lexical-binding: t; -*-
(defvar my/consult-ripgrep-last-include "")
(defvar my/consult-ripgrep-last-exclude "")

(defun my/ripgrep-expand-globs (input prefix)
  "Turn comma or space separated INPUT into ripgrep --glob arguments.
PREFIX is \"\" for includes and \"!\" for excludes."
  (mapcan
   (lambda (tok)
     (let ((tok (string-remove-suffix "/" tok)))
       (cond
        ((string-match-p "/" tok)
         (list (concat " --glob=" prefix tok)
               (concat " --glob=" prefix tok "/**")))
        ((string-match-p "[*?[]" tok)
         (list (concat " --glob=" prefix tok)))
        (t
         (list (concat " --glob=" prefix "*." (string-remove-prefix "." tok)))))))
   (split-string input "[, ]+" t)))

(defun my/consult-ripgrep-globs (&optional dir)
  "Prompt for include and exclude globs, then run `consult-ripgrep'.
With prefix argument DIR, also prompt for the directory."
  (interactive "P")
  (let* ((inc (read-string "Include globs: " my/consult-ripgrep-last-include))
         (exc (read-string "Exclude globs: " my/consult-ripgrep-last-exclude))
         (consult-ripgrep-args
          (concat consult-ripgrep-args
                  (apply #'concat (my/ripgrep-expand-globs inc ""))
                  (apply #'concat (my/ripgrep-expand-globs exc "!")))))
    (setq my/consult-ripgrep-last-include inc
          my/consult-ripgrep-last-exclude exc)
    (consult-ripgrep dir)))

(use-package project
  :ensure nil
  :bind (:map project-prefix-map
              ("g" . consult-ripgrep)
              ("G" . my/consult-ripgrep-globs))
  :config
  (setq xref-search-program 'ripgrep))

(provide 'tony-emacs-project)
