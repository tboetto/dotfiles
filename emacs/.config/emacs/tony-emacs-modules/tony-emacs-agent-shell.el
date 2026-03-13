(use-package shell-maker :ensure t)

(use-package acp :ensure t :after shell-maker)

(use-package agent-shell
  :ensure t
  :after (shell-maker acp)
  :bind
  (("C-c a a" . agent-shell)
   ("C-c a c" . agent-shell-anthropic-start-claude-code)
   ("C-c a u" . agent-shell-cursor-start-agent))
  :config
  ;; Inherit the current Emacs process environment so the claude binary
  ;; in PATH (and nvm, etc.) is visible to the agent subprocess
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables
         :inherit-env t))
  ;; Inherit env for cursor-agent-acp so the cursor binary is visible
  (setq agent-shell-cursor-environment
        (agent-shell-make-environment-variables
         :inherit-env t)))

(provide 'tony-emacs-agent-shell)
