;;; tony-emacs-visual-fill-column.el --- Centered, width-limited visual line wrapping  -*- lexical-binding: t; -*-
  (use-package visual-fill-column
  :ensure t
  :hook (org-mode . visual-line-mode)
  :init
  (setq-default visual-fill-column-center-text t)
  (setq-default visual-fill-column-width 400)
  (setq-default visual-fill-column-enable-sensible-window-split t)

  (add-hook 'visual-line-mode-hook #'visual-fill-column-for-vline)

  ;; Org buffers alone get a narrower fill column; the 400 default stays for
  ;; agent-shell and other visual-line-mode buffers, where markdown table
  ;; rendering needs the extra width. Re-adjusting after the setq-local
  ;; covers both hook orderings: if visual-fill-column-mode already enabled
  ;; with the old width, this recomputes margins immediately. Guarded with
  ;; `bound-and-true-p' because an org buffer can be initialized at startup
  ;; before elpaca has loaded the package, and `visual-fill-column-adjust'
  ;; isn't autoloaded; when the mode enables later it reads the local width.
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local visual-fill-column-width 140)
              (when (bound-and-true-p visual-fill-column-mode)
                (visual-fill-column-adjust))))

  :config
  (advice-add 'text-scale-adjust :after #'visual-fill-column-adjust))

(provide 'tony-emacs-visual-fill-column)
