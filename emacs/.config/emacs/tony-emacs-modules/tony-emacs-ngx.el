;;; lsp-ngx.el --- description -*- lexical-binding: t; -*-

;; Copyright (C) 2020 emacs-lsp maintainers

;; Author: emacs-lsp maintainers
;; Keywords: lsp,

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; LSP Clients for the ngx Web application framework.

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

;;;(defvar-local node-path (shell-command-to-string "which node"))
(with-eval-after-load 'lsp-mode
  ;;; ngx
  (defgroup lsp-ngx nil
    "ngx LSP client, provided by the ngx Language Service Server."
    :group 'lsp-mode
    :version "8.0.0"
    :link '(url-link "https://github.com/ngx/vscode-ng-language-service"))

  (defcustom lsp-clients-ngx-language-server-command nil
    "The command that starts the ngx language server."
    :group 'lsp-ngx
    :type
    '(choice
      (string :tag "Single string value")
      (repeat :tag "List of string values" string)))

  (defcustom lsp-clients-ngx-node-get-prefix-command
    "npm config get --global prefix"
    "The shell command that returns the path of NodeJS's prefix.
    Has no effects when `lsp-clients-ngx-language-server-command' is set."
    :group 'lsp-ngx
    :type 'string)

  (defun lsp-client--ngx-start-loading (_workspace params)
    (lsp--info "Started loading project %s" params))

  (defun lsp-client--ngx-finished-loading (_workspace params)
    (lsp--info "Finished loading project %s" params))

  (lsp-register-client
   (make-lsp-client
    :new-connection
    (lsp-stdio-connection
     (lambda ()
       (if lsp-clients-ngx-language-server-command
           lsp-clients-ngx-language-server-command
         (let ((node-modules-path
                (f-join
                 (string-trim
                  (shell-command-to-string
                   lsp-clients-ngx-node-get-prefix-command))
                 (if (eq system-type 'windows-nt)
                     "node_modules"
                   "lib/node_modules"))))
           ;; The shell command takes a significant time to run,
           ;; so we "cache" its results after running once
           (setq lsp-clients-ngx-language-server-command
                 (list
                  "ngserver"
                  "--stdio"
                  "--tsProbeLocations"
                  node-modules-path
                  "--ngProbeLocations"
                  (f-join
                   node-modules-path
                   "@ngx/language-server/node_modules/")))
           lsp-clients-ngx-language-server-command))))
    :activation-fn

    (lambda (&rest _args)
      (and
       (string-match-p "\\(\\.html\\|\\.ts\\)\\'" (buffer-file-name))
       (lsp-workspace-root)
       ;; Use 'or' to check for either 'angular.json' or the '.angular' directory
       (or (file-exists-p
            (f-join (lsp-workspace-root) "angular.json"))
           (file-directory-p
            (f-join (lsp-workspace-root) ".angular")))))
    :priority -1
    :notification-handlers
    (ht
     ("angular/projectLoadingStart" #'lsp-client--ngx-start-loading)
     ("angular/projectLoadingFinish"
      #'lsp-client--ngx-finished-loading)
     ("angular/projectLanguageService" #'ignore))
    :add-on? t
    :server-id 'ngx-ls))


  (lsp-consistency-check lsp-ngx)

  ;;;
  ;;;(with-eval-after-load 'lsp-mode
  ;;;  (add-to-list 'lsp-language-id-configuration
  ;;;               '(ngxhtml-ts-mode . "ngxhtml"))
  ;;;
  ;;;  (lsp-register-client
  ;;;   (make-lsp-client :new-connection
  ;;;                    (lsp-stdio-connection
  ;;;                     '("node"
  ;;;                       "/home/cyf/.nvm/versions/node/v23.8.0/lib/node_modules/@angular/language-server"
  ;;;                       "--ngProbeLocations"
  ;;;                       "/home/cyf/.nvm/versions/node/v23.8.0/lib/node_modules"
  ;;;                       "--tsProbeLocations"
  ;;;                       "/home/cyf/.nvm/versions/node/v23.8.0/lib/node_modules/"
  ;;;                       "--stdio"))
  ;;;                    :activation-fn (lsp-activate-on "ngxhtml")
  ;;;                    :server-id 'ngxhtml-ls
  ;;;		   :notification-handlers (ht ("angular/projectLoadingStart" #'ignore)
  ;;;                                               ("angular/projectLoadingFinish" #'ignore)))))
  )
(provide 'tony-emacs-ngx)
;;; tony-emacs-ngx.el ends here
