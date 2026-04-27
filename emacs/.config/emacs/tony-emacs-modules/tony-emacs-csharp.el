(use-package csharp-mode
  :ensure nil
  :hook ((csharp-mode . lsp-deferred)
         (csharp-ts-mode . lsp-deferred))
  :init
  (with-eval-after-load 'lsp-mode
    (require 'lsp-csharp)))

(provide 'tony-emacs-csharp)
