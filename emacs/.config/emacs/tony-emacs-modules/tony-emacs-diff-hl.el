;;; tony-emacs-diff-hl.el --- VC diff indicators in the fringe  -*- lexical-binding: t; -*-
(use-package
 diff-hl
 :ensure t
 :bind
 (("C-c v h" . diff-hl-show-hunk)
  ("C-c v n" . diff-hl-show-hunk-next)
  ("C-c v p" . diff-hl-show-hunk-previous)
  ("C-c v r" . diff-hl-revert-hunk)
  ("C-c v s" . diff-hl-stage-dwim))
 :init
 (global-diff-hl-mode)
 (diff-hl-flydiff-mode) ; update diff-hl on the fly
 (add-hook 'dired-mode-hook 'diff-hl-dired-mode)) ; show diff in dired
;; NOTE: diff-hl-magit-{pre,post}-refresh hooks intentionally omitted —
;; they iterate every visible buffer on each magit refresh, which makes
;; staging/unstaging noticeably slow.

(provide 'tony-emacs-diff-hl)
