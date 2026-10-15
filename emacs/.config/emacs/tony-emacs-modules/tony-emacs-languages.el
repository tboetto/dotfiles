;;; tony-emacs-languages.el --- Per-language modes: shell, lisp, racket  -*- lexical-binding: t; -*-
(use-package
 sh-mode
 :ensure nil ; built in
 ;; `treesit-enabled-modes' remaps sh-mode to bash-ts-mode from here.
 :mode ("\\.zsh\\'" "\\.sh\\'"))

(use-package
 aggressive-indent
 :ensure t
 ;; NOTE: `elisp-mode' used to be in this list. It is not a major mode -- the
 ;; mode is `emacs-lisp-mode' -- so it only interned a hook nothing ever ran.
 :hook
 (clojure-mode
  emacs-lisp-mode lisp-mode common-lisp-mode scheme-mode))

(use-package
 smartparens
 :ensure t
 :hook
 (clojure-mode . smartparens-mode)
 (scheme-mode . smartparens-mode)
 :config (require 'smartparens-config))

(setq racket-program "/usr/bin/racket")

(use-package
 racket-mode
 :after org
 :ensure t
 :config (add-to-list 'org-babel-load-languages '(racket . t)))



(provide 'tony-emacs-languages)
