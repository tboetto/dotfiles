(use-package
 sh-mode
 :ensure nil ;; built in
 :mode "\\.zsh\\'" "\\.sh\\'")

(use-package
 aggressive-indent
 :ensure t
 :hook

 '(clojure-mode
   elisp-mode emacs-lisp-mode lisp-mode common-lisp-mode scheme-mode))

(use-package
 smartparens
 :ensure t
 :hook
 (clojure-mode . smartparens-mode)
 (scheme-mode . smartparens-mode)
 :config (require 'smartparens-config))

(setq racket-program "/usr/bin/racket")
(setq org-babel-debug t)

(use-package
 racket-mode
 :after org
 :ensure t
 :config (add-to-list 'org-babel-load-languages '(racket . t)))



(provide 'tony-emacs-languages)
