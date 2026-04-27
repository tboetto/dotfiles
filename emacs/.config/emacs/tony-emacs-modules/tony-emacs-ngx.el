;;; tony-emacs-ngx.el --- Angular LSP + ngxhtml-ts-mode config -*- lexical-binding: t; -*-

;;; Code:

(use-package ngxhtml-ts-mode)

(add-hook 'ngxhtml-ts-mode-hook #'lsp-deferred)

;;; for formatter
;;(push '(prettier-ngxhtml . ( "apheleia-npx" "prettier" "--stdin-filepath" filepath
;;"--parser=angular"
;;(apheleia-formatters-js-indent "--use-tabs"
;;"--tab-width")))
;;apheleia-formatters)
;;(push '(ngxhtml-ts-mode . prettier-ngxhtml)
;;apheleia-mode-alist)
;;; uncomment this to disable formater
;;;(defun ngxhtml-setting-hooks ()
;;;  (apheleia-mode -1))
;;;(add-hook 'ngxhtml-ts-mode-hook #'ngxhtml-setting-hooks)

(defun tony/angular-ls-command ()
  "Build ngserver command using project-local node_modules when available.
Uses project node_modules for --tsProbeLocations and --ngProbeLocations so
ngserver loads the project's Angular/TypeScript versions (like VSCode does).
Falls back to npm's global node_modules."
  (let* ((root (lsp-workspace-root))
         (project-nm (and root (expand-file-name "node_modules" root)))
         (global-nm (string-trim (shell-command-to-string "npm root -g")))
         (ts-probe (if (and project-nm
                            (file-directory-p (expand-file-name "typescript" project-nm)))
                       project-nm
                     global-nm))
         (ng-probe (if (and project-nm
                            (file-directory-p (expand-file-name "@angular/language-service" project-nm)))
                       project-nm
                     (expand-file-name "@angular/language-server/node_modules" global-nm))))
    (list "ngserver" "--stdio"
          "--tsProbeLocations" ts-probe
          "--ngProbeLocations" ng-probe)))

;; Override angular-ls after lsp-angular loads to use project-local probe locations.
;; The built-in angular-ls caches a global path on first use; our version recomputes
;; per workspace so each project gets its own Angular/TypeScript versions.
(with-eval-after-load 'lsp-angular
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection #'tony/angular-ls-command)
    :activation-fn
    (lambda (&rest _args)
      (and (string-match-p "\\(\\.html\\|\\.ts\\)\\'" (buffer-file-name))
           (lsp-workspace-root)
           (or (file-exists-p (f-join (lsp-workspace-root) "angular.json"))
               (file-directory-p (f-join (lsp-workspace-root) ".angular")))))
    :priority -1
    :notification-handlers
    (ht ("angular/projectLoadingStart" #'ignore)
        ("angular/projectLoadingFinish" #'ignore)
        ("angular/projectLanguageService" #'ignore))
    :add-on? t
    :server-id 'angular-ls)))

(provide 'tony-emacs-ngx)
;;; tony-emacs-ngx.el ends here
