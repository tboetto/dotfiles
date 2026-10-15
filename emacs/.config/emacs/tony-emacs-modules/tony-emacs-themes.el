;;; tony-emacs-themes.el --- Theme packages and switching commands  -*- lexical-binding: t; -*-
(setopt custom-theme-directory (locate-user-emacs-file "themes/"))

;; Defined in tony-lisp/remember-last-theme.el, which loads after this file.
(declare-function my-load-theme "remember-last-theme" (&optional theme))

(setq custom-safe-themes t)

(use-package modus-themes
  :ensure t)

(use-package ef-themes
  :ensure (:host github :repo "protesilaos/ef-themes"))

(use-package standard-themes
:ensure (:host github :repo "protesilaos/standard-themes"))

(use-package
 doric-themes
 :ensure (:host github :repo "protesilaos/doric-themes")
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

(defun tony/lexbind-cookie-add-to-file (file)
  "Add a `lexical-binding' cookie to FILE's first line if it lacks one.
Idempotent: does nothing if the cookie is already present. Note this dirties
the package's git worktree if FILE lives under elpaca/sources; if
`elpaca-update' ever balks, run `git checkout -- .' in that source dir."
  (when (file-exists-p file)
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (unless (search-forward "lexical-binding" (line-end-position) t)
        (end-of-line)
        (insert "  -*- lexical-binding: t; -*-")
        (write-region (point-min) (point-max) file nil 'quiet)))))

(defun tony/add-lexbind-cookie (e)
  "Elpaca `:build' step: patch E's main file via `tony/lexbind-cookie-add-to-file'.
For third-party packages that ship without a `lexical-binding' cookie, so
Emacs 31 warns on every load. Only runs on a package's first build --
`elpaca<-builtp' is just `(file-exists-p build-dir)', so once a package has
been built once, every later startup takes the two-step
`elpaca--pre-built-steps' path and skips `:build' forever. See
`tony/ensure-lexbind-cookie' for the self-healing counterpart that covers
that case."
  (when-let* ((dir (elpaca<-source-dir e))
              (file (expand-file-name (format "%s.el" (elpaca<-package e)) dir)))
    (tony/lexbind-cookie-add-to-file file))
  (elpaca-continue e))

(defun tony/ensure-lexbind-cookie (package)
  "Patch PACKAGE's built file via `tony/lexbind-cookie-add-to-file', if built.
Meant for a `use-package' `:init' form, which -- unlike elpaca's `:build'
steps -- always runs at startup regardless of whether the package was
already built in a previous session. Belt-and-suspenders alongside
`tony/add-lexbind-cookie': fixes the common case where the build directory
already existed before this fix was added, with no manual rebuild needed."
  (tony/lexbind-cookie-add-to-file
   (expand-file-name (format "%s/%s.el" package package) elpaca-builds-directory)))

;; Upstream naysayer has no `lexical-binding' cookie (dormant since 2025-05)
;; and Emacs 31 warns on every load, so patch it as a build step, and again
;; (self-healing, in case the build step above was skipped) in :init.
(use-package
 naysayer-theme
 :ensure
 (:build (:before elpaca-build-link tony/add-lexbind-cookie))
 :init
 (tony/ensure-lexbind-cookie "naysayer-theme")
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
  :ensure nil ; local, in tony-lisp/
  :after (acme-theme kaolin-themes naysayer-theme doom-themes doric-themes standard-themes ef-themes modus-themes)
  :config
  (remember-theme-load)
  (add-hook 'kill-emacs-hook 'remember-theme-save)
  ;; Re-apply the theme in frames made later by emacsclient, otherwise the
  ;; menu bar keeps the theme the server started with. Hooked here rather
  ;; than at the top of this file because `remember-last-theme' is what
  ;; defines the function.
  (add-hook 'after-make-frame-functions #'my-load-theme-in-all-frames))

(provide 'tony-emacs-themes)
