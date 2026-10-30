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

(defconst tony/gdshader-lsp-binary
  (expand-file-name
   "~/.local/src/gdshader-lsp-cpp/bin/linux/release/gdshader_lsp_release_linux")
  "Built gdshader-lsp-cpp server. Only exists on machines where it was built.")

(use-package gdshader-mode
  :ensure t
  :mode ("\\.gdshader\\'" "\\.gdshaderinc\\'")
  :config
  ;; Skip the LSP entirely where the binary isn't built (e.g. the work macOS
  ;; machine), so there is no failed-start noise there.
  (when (file-executable-p tony/gdshader-lsp-binary)
    (add-hook 'gdshader-mode-hook #'lsp-deferred)
    (with-eval-after-load 'lsp-mode
      (add-to-list 'lsp-language-id-configuration '(gdshader-mode . "gdshader"))
      (lsp-register-client
       (make-lsp-client
        :new-connection
        (lsp-stdio-connection (list tony/gdshader-lsp-binary "--stdio"))
        :activation-fn (lsp-activate-on "gdshader")
        :server-id 'gdshader-lsp)))))

(provide 'tony-emacs-godot)
