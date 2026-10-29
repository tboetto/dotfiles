;;; tony-emacs-miscellaneous.el --- Odds and ends: shell env, compat, markdown  -*- lexical-binding: t; -*-
(use-package
 exec-path-from-shell
 :ensure t
 :config
 (when (memq window-system '(mac ns x))
   (add-to-list 'exec-path-from-shell-variables "NODE_EXTRA_CA_CERTS")
   (exec-path-from-shell-initialize)))

(use-package compat
  :ensure (:host github :repo "emacs-compat/compat" :type git :wait t))

(electric-pair-mode 1)
;; Always overtype a closer that's already next to point. The default
;; (`electric-pair-preserve-balance') only overtypes when that helps balance
;; the buffer, so any earlier unclosed "(" -- common in prose, org, and the
;; agent-shell transcript -- makes typing ")" insert a second one: "(abc))".
(setq electric-pair-skip-self t)

;; `skip-self' doesn't help with double quotes. Emacs decides whether a typed
;; `"' opens or closes a string by asking the parser if point is already
;; inside one. In org and comint-derived buffers (agent-shell) `"' is a string
;; delimiter, so one stray `"' earlier in the buffer makes every later quote
;; look like a closer and typing "hello" yields "hello"". Don't auto-pair `"'
;; in those prose-like modes; code modes keep it.
(defun my/electric-pair-no-double-quote (char)
  "Inhibit pairing for CHAR when it is a double quote, else use the default."
  (or (eq char ?\")
      (electric-pair-default-inhibit char)))

(dolist (hook '(org-mode-hook agent-shell-mode-hook))
  (add-hook hook
            (lambda ()
              (setq-local electric-pair-inhibit-predicate
                          #'my/electric-pair-no-double-quote))))

(defvar-local my/electric-pair-before-beacon nil
  "Whether `electric-pair-local-mode' was on before meow beacon mode started.")

(defun my/electric-pair-toggle-for-beacon ()
  "Disable electric pairing while `meow-beacon-mode' is active, then restore it."
  (if meow-beacon-mode
      (progn
        (setq my/electric-pair-before-beacon electric-pair-mode)
        (electric-pair-local-mode -1))
    (when my/electric-pair-before-beacon
      (electric-pair-local-mode 1))))

(add-hook 'meow-beacon-mode-hook #'my/electric-pair-toggle-for-beacon)

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(defcustom my/alpha-background 90
  "Background opacity (0-100) used when transparency is enabled.
Matches `st.alpha: 0.9' in xresources. Needs a compositor (xcompmgr)."
  :type 'integer
  :group 'convenience)

(defconst my/alpha-parameter
  (if (eq system-type 'darwin) 'alpha 'alpha-background)
  "Frame parameter used for transparency.
The NS port ignores `alpha-background', so macOS falls back to
`alpha', which also fades text.")

(defun my/set-alpha-background (value)
  "Set `my/alpha-parameter' to VALUE on all frames and on new frames."
  (setf (alist-get my/alpha-parameter default-frame-alist) value)
  (setf (alist-get my/alpha-parameter initial-frame-alist) value)
  (dolist (frame (frame-list))
    (set-frame-parameter frame my/alpha-parameter value)))

(defun my/toggle-transparency ()
  "Toggle background transparency between `my/alpha-background' and opaque."
  (interactive)
  (let ((on (/= (or (alist-get my/alpha-parameter default-frame-alist) 100) 100)))
    (my/set-alpha-background (if on 100 my/alpha-background))
    (message "Transparency %s" (if on "off" "on"))))

(my/set-alpha-background my/alpha-background)

(provide 'tony-emacs-miscellaneous)
