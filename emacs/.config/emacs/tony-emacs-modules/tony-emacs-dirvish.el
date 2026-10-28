;;; tony-emacs-dirvish.el --- dirvish: a better dired  -*- lexical-binding: t; -*-
(when (and (eq system-type 'darwin) (executable-find "gls"))
  (setq insert-directory-program "gls"))

(use-package dirvish
  :ensure t
  :init (dirvish-override-dired-mode)
  :bind
  (("C-c d" . dirvish-dwim)
   ("C-c D" . dirvish-side)
   :map dirvish-mode-map
   ("h" . dired-up-directory)
   ("l" . dired-find-file)
   ("a" . dirvish-quick-access)
   ("f" . dirvish-file-info-menu)
   ("y" . dirvish-yank-menu)
   ("N" . dirvish-narrow)
   ("TAB" . dirvish-subtree-toggle)
   ("M-f" . dirvish-history-go-forward)
   ("M-b" . dirvish-history-go-backward)
   ("M-l" . dirvish-ls-switches-menu)
   ("M-m" . dirvish-mark-menu)
   ("M-t" . dirvish-layout-toggle)
   ("M-s" . dirvish-setup-menu)
   ("M-e" . dirvish-emerge-menu))
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/" "Home")
     ("d" "~/Downloads/" "Downloads")
     ("c" "~/dotfiles/" "Dotfiles")))
  (dirvish-attributes
   '(nerd-icons file-time file-size collapse subtree-state vc-state git-msg))
  (dirvish-subtree-state-style 'nerd)
  (dirvish-side-width 38)
  (dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))
  (delete-by-moving-to-trash t)
  (dired-listing-switches
   "-l --almost-all --human-readable --group-directories-first --no-group")
  :config
  (dirvish-peek-mode)
  (dirvish-side-follow-mode))

(provide 'tony-emacs-dirvish)
