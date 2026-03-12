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
       'elisp-autofmt))

(provide 'tony-emacs-prettier)
