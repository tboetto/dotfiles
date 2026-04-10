(use-package
  exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (add-to-list 'exec-path-from-shell-variables "NODE_EXTRA_CA_CERTS")
    (exec-path-from-shell-initialize)))
(provide 'tony-emacs-miscellaneous)
