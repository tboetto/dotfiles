(use-package
 diff-hl
 :ensure t
 :init
 (global-diff-hl-mode)
 (diff-hl-flydiff-mode) ; update diff-hl on the fly
 (add-hook 'dired-mode-hook 'diff-hl-dired-mode)) ; show diff in dired
;; NOTE: diff-hl-magit-{pre,post}-refresh hooks intentionally omitted —
;; they iterate every visible buffer on each magit refresh, which makes
;; staging/unstaging noticeably slow.

(provide 'tony-emacs-diff-hl)
