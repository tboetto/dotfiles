(setopt custom-theme-directory "~/.config/emacs/themes/")

(setq custom-safe-themes t)

(add-hook 'after-make-frame-functions #'my-load-theme-in-all-frames)

(use-package modus-themes
  :ensure t)

(use-package ef-themes
 :ensure t
    )

(use-package standard-themes
:ensure t)

(use-package
 doric-themes
 :ensure t
 :custom (doric-themes-toggle '(doric-light doric-obsidian)))

(use-package
 doom-themes
 :ensure t
 :init
 (defun my-rose-pine ()
   "Clear previous theme and load rosé pine."
   (interactive)
   (my-load-theme 'doom-rose-pine))

 (defun my-rose-pine-dawn ()
   "Clear previous theme and load rosé pine dawn."
   (interactive)
   (my-load-theme 'doom-rose-pine-dawn))

 (defun my-doom-one ()
   "Clear previous theme and load doom-one."
   (interactive)
   (my-load-theme 'doom-one))

 (defun my-gruvbox ()
   "Clear previous theme and load gruvbox."
   (interactive)
   (my-load-theme 'doom-gruvbox))

 (defun my-gruvbox-light ()
   "Clear previous theme and load gruvbox."
   (interactive)
   (my-load-theme 'doom-gruvbox-light))

 (defun my-toggle-rose-pine ()
   "Toggle between light and dark Rosé Pine themes."
   (interactive)
   (if (eq (nth 0 custom-enabled-themes) 'doom-rose-pine)
       (my-rose-pine-dawn)
     (my-rose-pine)))

 (defun my-toggle-gruvbox ()
   "Toggle between light and dark Gruvbox themes."
   (interactive)
   (if (eq (nth 0 custom-enabled-themes) 'doom-gruvbox)
       (my-gruvbox-light)
     (my-gruvbox)))

 (defun my-toggle-tomorrow ()
   "Toggle between light and dark Tomorrow themes."
   (interactive)
   (if (eq (nth 0 custom-enabled-themes) 'doom-tomorrow-night)
       (my-load-theme 'doom-tomorrow-day)
     (my-load-theme 'doom-tomorrow-night)))
 :custom (doom-themes-enable-bold t) (doom-themes-enable-italic t)
 :config (doom-themes-org-config))

(use-package
 naysayer-theme
 :ensure t
 :init
 (defun my-naysayer-theme ()
   "Clear previous theme and load naysayer."
   (interactive)
   (my-load-theme 'naysayer)))

(use-package
 acme-theme
 :ensure t
 :init (setq acme-theme-black-fg t)

 (defun my-acme-theme ()
   "Clear previous theme and load acme."
   (interactive)
   (my-load-theme 'acme)))

(use-package
 kaolin-themes
 :ensure t
 :init
 (defun my-kaolin-dark ()
   "Clear previous theme and load kaolin dark."
   (interactive)
   (my-load-theme 'kaolin-dark))

 (defun my-kaolin-light ()
   "Clear previous theme and load kaolin light."
   (interactive)
   (my-load-theme 'kaolin-light))

 (defun my-kaolin-mono-dark ()
   "Clear previous theme and load kaolin mono dark."
   (interactive)
   (my-load-theme 'kaolin-mono-dark))

 (defun my-kaolin-mono-light ()
   "Clear previous theme and load kaolin mono light."
   (interactive)
   (my-load-theme 'kaolin-mono-light)))

(defun my-toggle-solarized ()
  "Toggle between light and dark solarized themes."
  (interactive)
  (if (eq (nth 0 custom-enabled-themes) 'doom-solarized-dark)
      (my-solarized-light)
    (my-solarized-dark)))

(defun my-solarized-light ()
  "Clear previous theme and load solarized light"
  (interactive)
  (my-load-theme 'doom-solarized-light))

(defun my-solarized-dark ()
  "Clear previous theme and load solarized dark"
  (interactive)
  (my-load-theme 'doom-solarized-dark))

(use-package remember-last-theme
  :after (acme-theme kaolin-themes naysayer-theme doom-themes doric-themes standard-themes ef-themes modus-themes)
  :config
  (remember-theme-load)
  (add-hook 'kill-emacs-hook 'remember-theme-save)
  )

(provide 'tony-emacs-themes)
