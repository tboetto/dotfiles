(use-package agent-shell-sidebar
  :ensure (:host github :repo "cmacrae/agent-shell-sidebar")
  :bind
  (("C-c a s" . agent-shell-sidebar-toggle)
   ("C-c a f" . agent-shell-sidebar-toggle-focus))
  :custom
  (agent-shell-sidebar-width "25%")
  (agent-shell-sidebar-minimum-width 80)
  (agent-shell-sidebar-maximum-width "50%")
  (agent-shell-sidebar-position 'right)
  (agent-shell-sidebar-locked t)
  (agent-shell-sidebar-default-config
   (agent-shell-anthropic-make-claude-code-config)))

(provide 'tony-emacs-agent-shell-sidebar)
