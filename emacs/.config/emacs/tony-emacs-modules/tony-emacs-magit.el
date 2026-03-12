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
 :config (setq git-commit-summary-max-length 50)
 ;; NOTE 2023-01-24: I used to also include `overlong-summary-line'
 ;; in this list, but I realised I do not need it.  My summaries are
 ;; always in check.  When I exceed the limit, it is for a good
 ;; reason.
 (setq git-commit-style-convention-checks '(non-empty-second-line))
 (define-key magit-mode-map (kbd "x") #'magit-discard)
 (setq magit-diff-refine-hunk t)

 ;; Show icons for files in the Magit status and other buffers.
 (with-eval-after-load 'magit
   (setq magit-format-file-function #'magit-format-file-nerd-icons)))

(provide 'tony-emacs-magit)
