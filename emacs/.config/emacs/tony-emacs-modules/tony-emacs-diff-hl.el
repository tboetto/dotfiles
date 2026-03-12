(use-package
 diff-hl
 :ensure t
 :init
 (global-diff-hl-mode)
 (diff-hl-flydiff-mode) ; update diff-hl on the fly
 (add-hook 'dired-mode-hook 'diff-hl-dired-mode) ; show diff in dired
 :hook
 (magit-pre-refresh . diff-hl-magit-pre-refresh)
 (magit-post-refresh . diff-hl-magit-post-refresh))

(provide 'tony-emacs-diff-hl)
