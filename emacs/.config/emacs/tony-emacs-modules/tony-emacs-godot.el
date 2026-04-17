(use-package gdscript-mode
  :ensure (:host github :repo "godotengine/emacs-gdscript-mode")
  :hook ((gdscript-mode . lsp-deferred)
         (gdscript-ts-mode . lsp-deferred))
  :init
  (require 'lsp-gdscript))

(provide 'tony-emacs-godot)
