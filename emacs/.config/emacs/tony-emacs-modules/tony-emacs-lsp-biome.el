(use-package
 lsp-biome
 :after apheleia
 :ensure (:host github :repo "cxa/lsp-biome"))

(defun my/biome-organize-imports ()
  "Run biome's organize imports code action explicitly."
  (interactive)
  (lsp-execute-code-action-by-kind "source.organizeImports.biome"))

(provide 'tony-emacs-lsp-biome)
