;;; init.el --- Main init: elpaca bootstrap and module loading  -*- lexical-binding: t; -*-
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca
 elpaca-use-package
 ;; Enable Elpaca support for use-package's :ensure keyword.
 (elpaca-use-package-mode))

(setq elpaca-menu-functions
      (remq 'elpaca-menu-gnu-elpa
            (remq 'elpaca-menu-nongnu-elpa elpaca-menu-functions)))

;; GNU ELPA transitive dependencies (moved off MELPA, needed by lsp-mode).
;; Declared early so elpaca has their recipes before processing the queue.
(use-package spinner :ensure (:host github :repo "Malabarba/spinner.el") :defer t)
(use-package compat :ensure (:host github :repo "emacs-compat/compat"))

(use-package org
  :ensure (org :host github :repo "bzg/org-mode" :branch "main")
  :defer t)
(elpaca-wait)

(when (locate-file "org-latex-preview"
                   (list (expand-file-name "org" lisp-directory))
                   '(".elc" ".el" ".el.gz"))
  (display-warning
   'tony-init
   (format "Emacs %s bundles org-latex-preview; remove the Org development branch block from my-init.org."
           emacs-version)))

(setq ring-bell-function #'ignore)

(repeat-mode 1)

(add-hook 'magit-diff-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'markdown-mode-hook 'visual-line-mode)

(setq make-backup-files t)
(setq create-lockfiles nil)

;; Line numbers only where they earn their keep -- not in org, magit, dired,
;; vterm or the agent-shell sidebar.
(dolist (hook '(prog-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; `hl-line-mode' is buffer-local: calling it here only ever highlighted
;; whichever buffer happened to be current during init. Use the global mode.
(global-hl-line-mode 1)

(setq recentf-auto-cleanup 'never)
(recentf-mode 1)
(run-with-idle-timer 30 nil #'recentf-cleanup)
(setq history-length 25)
(with-eval-after-load 'savehist
  (when (daemonp)
    (setq savehist-file (expand-file-name "history-daemon" user-emacs-directory)))
  (add-hook 'savehist-save-hook
            (lambda () (setq command-history (seq-take command-history 100)))))
(savehist-mode 1)
(save-place-mode 1)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq vc-follow-symlinks t)

;; `minibuffer-prompt-properties' already defaults to exactly these values on
;; Emacs 31, so only the hook is needed.
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(setq enable-recursive-minibuffers t)
(minibuffer-depth-indicate-mode 1)  

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)
;; Disable the damn thing by making it disposable. 
;; (setq custom-file (make-temp-file "emacs-custom-"))

;; `w32-pass-apps-to-system' / `w32-apps-modifier' only get a real `defvar' from
;; w32-fns.el, which isn't loaded on this platform, so forward-declare them to
;; keep the byte-compiler from treating the `setq' below as a free variable.
(defvar w32-pass-apps-to-system)
(defvar w32-apps-modifier)
(when (eq system-type 'windows-nt)
  (setq w32-pass-apps-to-system nil)
  (setq w32-apps-modifier 'hyper))

(defun enable-hyper-super-modifiers-linux-x ()
  "Make the <menu> key act as the hyper modifier.
On modern Linux the <windows> key is usually already mapped to Super.
Note: for H-s you must release <menu> before pressing `s'."
  (define-key key-translation-map [menu] 'event-apply-hyper-modifier))

;; Only meaningful under X -- there is no <menu> key event to translate in a
;; terminal frame, and macOS has its own modifier handling.
(defun tony/enable-hyper-in-x-frame (frame)
  "Install the <menu> hyper translation on FRAME's terminal if it is X."
  (when (eq (window-system frame) 'x)
    (with-selected-frame frame
      (enable-hyper-super-modifiers-linux-x))))

(when (eq window-system 'x)
  (enable-hyper-super-modifiers-linux-x))
(add-hook 'after-make-frame-functions #'tony/enable-hyper-in-x-frame)

;; Vertico settings
;; Add prompt indicator to `completing-read-multiple'.
;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
(require 'crm) ; for `crm-separator'
(defun crm-indicator (args)
  (cons
   (format "[CRM%s] %s"
           (replace-regexp-in-string
            "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" "" crm-separator)
           (car args))
   (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'crm-indicator)

(require 'server)
(unless (or (daemonp) (server-running-p))
  (server-start))

(mapc
 (lambda (string)
   (add-to-list 'load-path (locate-user-emacs-file string)))
 '("tony-lisp" "tony-emacs-modules"))
(require 'tony-emacs-meow)
(require 'tony-emacs-miscellaneous)
(require 'tony-emacs-visual-fill-column)
(require 'tony-emacs-org)
(require 'tony-emacs-inkscape)
(require 'tony-emacs-project)
(require 'tony-emacs-pulsar)
(require 'tony-emacs-fonts)
(require 'tony-emacs-nerd-icons)
(require 'tony-emacs-tweakers)
(require 'tony-emacs-which-key)
(require 'tony-emacs-godot)
(require 'tony-emacs-themes)
;; Must follow `tony-emacs-themes': solaire advises `load-theme' to swap
;; backgrounds, so the themes need to be available first.
(require 'tony-emacs-solaire-mode)
(require 'tony-emacs-doom-modeline)
(require 'tony-emacs-vertico)
(require 'tony-emacs-marginalia)
(require 'tony-emacs-orderless)
(require 'tony-emacs-consult)
(require 'tony-emacs-embark)
(require 'tony-emacs-dirvish)
(require 'tony-emacs-diff-hl)
(require 'tony-emacs-magit)
(require 'tony-emacs-blamer)
(require 'tony-emacs-denote)
(require 'tony-emacs-completion)
(require 'tony-emacs-spellchecker)
(require 'tony-emacs-linter)
(require 'tony-emacs-prettier)
(require 'tony-emacs-treesit)
(require 'tony-emacs-languages)
(require 'tony-emacs-lsp-mode)
(require 'tony-emacs-ngx)
(require 'tony-emacs-react)
(require 'tony-emacs-lsp-biome)
(require 'tony-emacs-info-manuals)
(require 'tony-emacs-copilot)
(require 'tony-emacs-agent-shell)
(require 'tony-emacs-agent-shell-sidebar)
(require 'tony-emacs-mermaid)
