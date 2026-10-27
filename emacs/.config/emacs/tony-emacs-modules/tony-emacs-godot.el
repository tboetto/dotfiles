;;; tony-emacs-godot.el --- Godot / GDScript support  -*- lexical-binding: t; -*-
  (use-package gdscript-mode
    :ensure (:host github :repo "godotengine/emacs-gdscript-mode")
    :hook ((gdscript-mode . lsp-deferred)
           (gdscript-ts-mode . lsp-deferred))
    :init
    (require 'lsp-gdscript)
    :config
    ;; Godot sends a custom `gdscript/capabilities' notification (only used by
    ;; the VS Code extension); ignore it to avoid the "Unknown notification" warning.
    (puthash "gdscript/capabilities" #'ignore
             (lsp--client-notification-handlers (gethash 'gdscript lsp-clients))))

(provide 'tony-emacs-godot)
