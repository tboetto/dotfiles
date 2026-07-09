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

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(provide 'tony-emacs-miscellaneous)
