;;; tony-emacs-react.el --- ESLint LSP for the React/Next.js project  -*- lexical-binding: t; -*-

(use-package
 lsp-eslint
 :ensure nil ; ships with lsp-mode
 :after lsp-mode
 :custom
 (lsp-eslint-enable t)
 (lsp-eslint-run "onType")
 (lsp-eslint-package-manager "npm"))

(provide 'tony-emacs-react)
