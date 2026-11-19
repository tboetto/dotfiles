;;; tony-emacs-prettier.el --- Apheleia auto-formatting  -*- lexical-binding: t; -*-
;; auto-format different source code files extremely intelligently
;; https://github.com/radian-software/apheleia
(use-package elisp-autofmt :ensure t)

(use-package
 apheleia
 :ensure t
 :diminish
 :config (apheleia-global-mode 1)

 ;; Configure prettierd formatter
 (setf (alist-get 'prettierd apheleia-formatters)
       '("prettierd" "--stdin-filepath" filepath))
 ;; Update mode associations to use prettierd instead of prettier
 (setf (alist-get 'js-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'js-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'typescript-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'json-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'css-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'scss-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'css-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'html-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'web-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'ngxhtml-ts-mode apheleia-mode-alist) 'prettierd)
 (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist)
       'elisp-autofmt)

 ;; prettierd falls back to Prettier defaults when a project has no Prettier
 ;; config, which rewrites an unformatted codebase on every save.
 (defun tony/prettier-config-missing-p ()
   "Non-nil when the buffer is a JS/TS/CSS file in a project with no Prettier config."
   (and (memq major-mode '(typescript-ts-mode tsx-ts-mode js-ts-mode css-ts-mode json-ts-mode))
        (not (locate-dominating-file
              default-directory
              (lambda (dir)
                (or (directory-files dir nil "\\`\\(\\.prettierrc\\|prettier\\.config\\.\\)" t 1)
                    (let ((pkg (expand-file-name "package.json" dir)))
                      (and (file-exists-p pkg)
                           (with-temp-buffer
                             (insert-file-contents pkg)
                             (re-search-forward "\"prettier\"" nil t))))))))))
 (add-to-list 'apheleia-inhibit-functions #'tony/prettier-config-missing-p))

(provide 'tony-emacs-prettier)
