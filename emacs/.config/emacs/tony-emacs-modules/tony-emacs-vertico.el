(use-package
 vertico
 :ensure t
 :init (vertico-mode)
 :bind (:map vertico-map ("C-j" . vertico-next) ("C-k" . vertico-previous))

 ;; Different scroll margin
 ;; (setq vertico-scroll-margin 0)

 ;; Show more candidates
 ;; (setq vertico-count 20)

 ;; Grow and shrink the Vertico minibuffer
 ;; (setq vertico-resize t)

 ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
 ;; (setq vertico-cycle t)
 )

(provide 'tony-emacs-vertico)
