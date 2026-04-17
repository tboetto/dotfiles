(use-package project
  :ensure nil
  :bind (:map project-prefix-map
              ("g" . consult-ripgrep))
  :config
  (setq xref-search-program 'ripgrep))

(provide 'tony-emacs-project)
