;;; tony-emacs-linter.el --- Flycheck and editorconfig  -*- lexical-binding: t; -*-
(use-package
 flycheck
 :ensure t
 :init (global-flycheck-mode)
 :bind
 (:map
  flycheck-mode-map
  ("M-n" . flycheck-next-error) ; optional but recommended error navigation
  ("M-p" . flycheck-previous-error)))

(use-package editorconfig
  :ensure nil ; built in since Emacs 30
  :config (editorconfig-mode 1))

(provide 'tony-emacs-linter)
