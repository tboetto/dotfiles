;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                MAGIT               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package
 transient
 :defer t
 :ensure
 (transient :type git :host github :repo "magit/transient")
 :config (setq transient-show-popup 0.5))

(use-package
 magit
 :ensure t
 :bind
 (:map
  global-map ("C-c g" . magit-status)
  :map magit-mode-map ("C-w" . nil) ("M-w" . nil))
 :init (setq magit-define-global-key-bindings nil)
 (setq magit-section-visibility-indicator
       '(magit-fringe-bitmap> . magit-fringe-bitmapv))
 (setq magit-diff-specify-hunk-foreground nil)
 :config (setq git-commit-summary-max-length 50)
 ;; NOTE 2023-01-24: I used to also include `overlong-summary-line'
 ;; in this list, but I realised I do not need it.  My summaries are
 ;; always in check.  When I exceed the limit, it is for a good
 ;; reason.
 (setq git-commit-style-convention-checks '(non-empty-second-line))
 (define-key magit-mode-map (kbd "x") #'magit-discard)
 (setq magit-diff-refine-hunk t)
 (setq magit-diff-fontify-hunk 'all)
 (setq magit-diff-use-indicator-faces t)

 ;; --- Performance tweaks ---
 ;; Flip to t to profile section timings in *Messages*.
 (setq magit-refresh-verbose nil)
 ;; Fewer commits in the status log section (default 10).
 (setq magit-log-section-commit-count 5)
 ;; Skip "branches containing this commit" lookup in revision buffers.
 (setq magit-revision-insert-related-refs nil)
 ;; Faster ref listing on repos with many branches.
 (setq magit-list-refs-sortby "-committerdate")
 ;; Skip whitespace analysis in diffs (syntax fontification unaffected).
 (setq magit-diff-paint-whitespace nil)
 (setq magit-diff-highlight-indentation nil)
 (setq magit-diff-highlight-trailing nil)
 ;; Don't prompt before refresh, don't show diff on commit.
 (setq magit-save-repository-buffers 'dontask)
 (setq magit-commit-show-diff nil)
 ;; Let auto-revert skip magit's own buffers.
 (setq auto-revert-buffer-list-filter
       'magit-auto-revert-repository-buffer-p)
 ;; Restrict VC probing to Git so file open / save don't scan other backends.
 (setq vc-handled-backends '(Git))
 ;; Skip expensive commit-diff popup when composing a commit message.
 (remove-hook 'server-switch-hook 'magit-commit-diff)
 ;; Trim status buffer sections that aren't useful day-to-day.
 (dolist (fn '(magit-insert-tags-header
               magit-insert-unpushed-to-upstream-or-recent
               magit-insert-unpulled-from-upstream))
   (remove-hook 'magit-status-sections-hook fn))

 ;; Show icons for files in the Magit status and other buffers.
 (with-eval-after-load 'magit
   (setq magit-format-file-function #'magit-format-file-nerd-icons)))

(provide 'tony-emacs-magit)
