(use-package visual-fill-column
:ensure t
:hook (org-mode . visual-line-mode)
:init
(setq-default visual-fill-column-center-text t)
(setq-default visual-fill-column-width 100)
(setq-default visual-fill-column-enable-sensible-window-split t)

(add-hook 'visual-line-mode-hook #'visual-fill-column-for-vline)

:config
(advice-add 'text-scale-adjust :after #'visual-fill-column-adjust))

(provide 'tony-emacs-visual-fill-column)
