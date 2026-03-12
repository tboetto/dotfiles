(use-package
 nerd-icons
 :ensure t
 :if (display-graphic-p)
 :config (setq nerd-icons-font-family "Symbols Nerd Font"))

(use-package
 nerd-icons-dired
 :ensure t
 :after nerd-icons
 :hook (dired-mode . nerd-icons-dired-mode))

(use-package
 nerd-icons-ibuffer
 :ensure t
 :after nerd-icons
 :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package
 nerd-icons-corfu
 :ensure t
 :after nerd-icons
 :after corfu
 :config
 (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(provide 'tony-emacs-nerd-icons)
