(use-package anzu :ensure t :config (global-anzu-mode))

(use-package
 surround
 :ensure t
 :bind-keymap ("C-c s" . surround-keymap))

;; (pixel-scroll-precision-mode)
(use-package
 ultra-scroll
 :ensure t
 :init
 (setopt
  scroll-conservatively 3
  scroll-margin 0)
 :config (ultra-scroll-mode 1))

(provide 'tony-emacs-tweakers)
