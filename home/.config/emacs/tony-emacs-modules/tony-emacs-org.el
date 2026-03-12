(use-package
 org
 :ensure nil
 :init
 (setopt org-confirm-babel-evaluate nil)
 (setq org-directory (expand-file-name "~/Documents/org/"))
 (setq org-imenu-depth 7)
 (setq org-log-done 'time)
 (setq org-log-into-drawer t)
 :config
 (setq org-startup-indented t)
 (add-to-list 'org-src-lang-modes '("typescript" . typescript-ts))
 )

(use-package
  org-agenda
  :ensure nil
  :bind
  (("C-c A" . org-agenda))
  :config (setq org-agenda-files (list org-directory)))

;; (use-package org-alert
;;   :ensure t
;;   :hook (org-agenda-mode . org-alert-mode))

(use-package
 org-modern
 :ensure t
 :hook (org-mode . org-modern-mode)
 :config
 (setq
  org-modern-keyword nil
  org-modern-block-name nil
  org-modern-timestamp nil
  ))

(use-package org-modern-indent
  :ensure (:host github :repo "jdtsmith/org-modern-indent")
  :hook
  (org-mode . org-modern-indent-mode))

(use-package org-appear :ensure t :hook (org-mode . org-appear-mode))
(setq org-appear-trigger 'always)

(use-package ob-racket
  :ensure (:host github :repo "DEADB17/ob-racket"))

(provide 'tony-emacs-org)
