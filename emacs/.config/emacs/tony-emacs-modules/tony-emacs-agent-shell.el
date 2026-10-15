;;; tony-emacs-agent-shell.el --- Agent shell (ACP) for Claude Code and friends  -*- lexical-binding: t; -*-
  ;; fnm exposes Node globals through a per-shell dir under
  ;; /run/user/UID/fnm_multishells/, which disappears with that shell and is
  ;; absent entirely when Emacs starts from a desktop launcher. Its "default"
  ;; alias is stable, so use that to keep claude-agent-acp on exec-path.
  (let ((fnm-bin (expand-file-name "~/.local/share/fnm/aliases/default/bin")))
    (when (file-directory-p fnm-bin)
      (add-to-list 'exec-path fnm-bin)
      (setenv "PATH" (concat fnm-bin path-separator (getenv "PATH")))))

  (use-package shell-maker :ensure t)

  (use-package acp :ensure t :after shell-maker)

;; agent-shell draws its header SVG at the frame's own font metrics --
;; `frame-char-height', plus the default face's family and size -- so it
;; already tracks the fontaine preset. Emacs then inflates the finished
;; image a second time by `image-scaling-factor', whose `auto' value works
;; out to ~1.6 at this font size, landing the header ~60% larger than body
;; text. An explicit :scale in the image spec beats `image-scaling-factor',
;; and the header string carries exactly one image, so pin it there rather
;; than changing image scaling for the whole buffer.
(defun my/agent-shell-header-unscale (header)
  "Pin the SVG image in HEADER to :scale 1 so it matches body text."
  (when (stringp header)
    (let ((pos 0))
      (while (and pos (< pos (length header)))
        (let ((image (get-text-property pos 'display header)))
          (when (imagep image)
            (setf (image-property image :scale) 1)))
        (setq pos (next-single-property-change pos 'display header)))))
  header)

(use-package agent-shell
  :ensure (:host github :repo "xenodium/agent-shell")
  :after (shell-maker acp)
  :bind
  (("C-c a a" . agent-shell)
   ("C-c a c" . agent-shell-anthropic-start-claude-code)
   ("C-c a u" . agent-shell-cursor-start-agent)
   ("C-c a p" . agent-shell-prompt-compose)
   ("C-c a t" . agent-shell-prompt-steer)
   ("C-c a r" . agent-shell-prompt-queue-resume)
   ("C-c a w" . agent-shell-copy-last-output))
  :config
  (setq agent-shell-session-restore-verbosity 'full)
  (setq agent-shell-session-strategy 'prompt)
  ;; Claude Code is the only agent in use, so skip the picker that
  ;; `agent-shell' and the sidebar would otherwise show.
  (setq agent-shell-preferred-agent-config 'claude-code)
  ;; Report tokens and spend in the shell header. Both need
  ;; `agent-shell-header-style' non-nil, which it is on a graphical frame.
  (setq agent-shell-show-cost-indicator t)
  (setq agent-shell-show-usage-at-turn-end t)
  ;; The sidebar is a dedicated side window, which display-buffer-same-window
  ;; (the default) refuses to use, leaving link placement up to whatever
  ;; display-buffer falls through to. Send files to a real window instead.
  (setq agent-shell-file-display-action
        '((display-buffer-reuse-window display-buffer-use-some-window)))
  ;; Inherit the current Emacs process environment so the claude binary
  ;; in PATH (and nvm, etc.) is visible to the agent subprocess
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables
         :inherit-env t))
  ;; Inherit env for cursor-agent-acp so the cursor binary is visible
  (setq agent-shell-cursor-environment
        (agent-shell-make-environment-variables
         :inherit-env t))
  (advice-add 'agent-shell--render-header-model-uncached
              :filter-return #'my/agent-shell-header-unscale))

(provide 'tony-emacs-agent-shell)
