;;; tony-emacs-spellchecker.el --- Jinx spell checking  -*- lexical-binding: t; -*-
(use-package
 jinx
 :ensure t
 :hook (emacs-startup . global-jinx-mode)
 :bind (("M-$" . jinx-correct) ("C-M-$" . jinx-languages)))

(provide 'tony-emacs-spellchecker)
