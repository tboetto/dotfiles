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

(use-package markdown-mode
  :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(provide 'tony-emacs-miscellaneous)
