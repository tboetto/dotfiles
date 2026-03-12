;;; ngxhtml-ts-mode.el --- tree-sitter support for NGXHTML  -*- lexical-binding: t; -*-

;; Took this from github.com/yolksys

;; Copyright (C) 2023-2025 Free Software Foundation, Inc.

;; Author     : cyf <theo@thornhill.no>
;; Maintainer : yf <theo@thornhill.no>
;; Created    : January 2025
;; Keywords   : ngxhtml languages tree-sitter

;; This file is not part of GNU Emacs.

;; This file is free software

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

(require 'treesit)
(require 'sgml-mode)

(if (not treesit-load-name-override-list)
    (setq treesit-load-name-override-list
          '((ngxhtml "libtree-sitter-angular" "tree_sitter_angular")))
  (add-to-list
   treesit-load-name-override-list
   '(ngxhtml "libtree-sitter-angular" "tree_sitter_angular")))

;;;for ngxhtml start
(defgroup ngx-group nil
  "ngx group")

(defface ngx-control-face
  '((((class color) (min-colors 88) (background light))
     :foreground "#D73A49")
    (((class color) (min-colors 88) (background dark))
     :foreground "#F97583")
    (((class color) (min-colors 16) (background light))
     :foreground "#D73A49")
    (((class color) (min-colors 16) (background dark))
     :foreground "#F97583")
    (((class color) (min-colors 8))
     :background "green"
     :foreground "black")
    (t :inverse-video t))
  "Basic face for ngx."
  :group 'ngx-group)

(defface ngx-pipe-face
  '((((class color) (min-colors 88) (background light))
     :foreground "#6F42C1")
    (((class color) (min-colors 88) (background dark))
     :foreground "#B392F0")
    (((class color) (min-colors 16) (background light))
     :foreground "#6F42C1")
    (((class color) (min-colors 16) (background dark))
     :foreground "#B392F0")
    (((class color) (min-colors 8))
     :background "green"
     :foreground "black")
    (t :inverse-video t))
  "Basic face for ngx."
  :group 'ngx-group)

(defface ngx-bind-face
  '((((class color) (min-colors 88) (background light))
     :foreground "#6F42C1")
    (((class color) (min-colors 88) (background dark))
     :foreground "#8514f5")
    (((class color) (min-colors 16) (background light))
     :foreground "#6F42C1")
    (((class color) (min-colors 16) (background dark))
     :foreground "#8514f5")
    (((class color) (min-colors 8))
     :background "green"
     :foreground "black")
    (t :inverse-video t))
  "Basic face for ngx."
  :group 'ngx-group)

(defface ngx-id-face
  '((((class color) (min-colors 88) (background light))
     :foreground "#22863A")
    (((class color) (min-colors 88) (background dark))
     :foreground "#85E89D")
    (((class color) (min-colors 16) (background light))
     :foreground "#22863A")
    (((class color) (min-colors 16) (background dark))
     :foreground "#85E89D")
    (((class color) (min-colors 8))
     :background "green"
     :foreground "black")
    (t :inverse-video t))
  "Basic face for ngx."
  :group 'ngx-group)

;;;for ngxhtml end

(defcustom ngxhtml-ts-mode-indent-offset 2
  "Number of spaces for each indentation step in `ngxhtml-ts-mode'."
  :version "29.1"
  :type 'integer
  :safe 'integerp
  :group 'ngxhtml)

(defvar ngxhtml-ts-mode--indent-rules
  `((ngxhtml
     ((parent-is "fragment") column-0 0)
     ((node-is "/>") parent-bol 0)
     ((node-is ">") parent-bol 0)
     ((node-is "end_tag") parent-bol 0)
     ((node-is "}") parent-bol 0) ;;;
     ((parent-is "statement_block")
      parent-bol
      ngxhtml-ts-mode-indent-offset) ;;;
     ((parent-is "comment") prev-adaptive-prefix 0)
     ((parent-is "element") parent-bol ngxhtml-ts-mode-indent-offset)
     ((parent-is "script_element")
      parent-bol
      ngxhtml-ts-mode-indent-offset)
     ((parent-is "style_element")
      parent-bol
      ngxhtml-ts-mode-indent-offset)
     ((parent-is "start_tag")
      parent-bol
      ngxhtml-ts-mode-indent-offset)
     ((parent-is "self_closing_tag")
      parent-bol
      ngxhtml-ts-mode-indent-offset)
     (catch-all parent-bol 0)))
  "Tree-sitter indent rules.")

(defvar ngxhtml-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'ngxhtml
   :override t
   :feature
   'comment
   `((comment) @font-lock-comment-face)
   :language 'ngxhtml
   :override t
   :feature
   'keyword
   `("doctype" @font-lock-keyword-face)
   :language 'ngxhtml
   :override t
   :feature
   'definition
   `((tag_name) @font-lock-function-name-face)
   :language 'ngxhtml
   :override t
   :feature
   'string
   `((quoted_attribute_value) @font-lock-string-face)
   :language 'ngxhtml
   :override t
   :feature
   'property
   `((attribute_name) @font-lock-variable-name-face)

   ;;;ngx start
   :language 'ngxhtml
   :override t
   :feature
   'id
   `((identifier) @ngx-id-face)
   :language 'ngxhtml
   :override t
   :feature
   'control
   `(["@" @ngx-control-face (control_keyword) @ngx-control-face])
   :language 'ngxhtml
   :override t
   :feature
   'pipe
   `((pipe_call) @ngx-pipe-face)
   :language 'ngxhtml
   :feature
   'bind
   `((["(" @ngx-bind-face "[" @ngx-bind-face "[(" @ngx-bind-face]
      (binding_name)))
   :language 'ngxhtml
   :override t
   :feature
   'bind
   `(((binding_name)
      @ngx-bind-face
      [")" @ngx-bind-face "]" @ngx-bind-face ")]" @ngx-bind-face])))
  ;;;ngx end
  "Tree-sitter font-lock settings for `ngxhtml-ts-mode'.")

(defun ngxhtml-ts-mode--defun-name (node)
  "Return the defun name of NODE.
  Return nil if there is no name or if NODE is not a defun node."
  (when (equal (treesit-node-type node) "tag_name")
    (treesit-node-text node t)))

;;;###autoload
(define-derived-mode
 ngxhtml-ts-mode
 html-mode
 "NGXHTML[ts]"
 "Major mode for editing Ngxhtml, powered by tree-sitter."
 :group 'ngxhtml

 (unless (treesit-ready-p 'ngxhtml)
   (error "Tree-sitter for NGXHTML isn't available"))

 (treesit-parser-create 'ngxhtml)

 ;; Indent.
 (setq-local treesit-simple-indent-rules
             ngxhtml-ts-mode--indent-rules)

 ;; Navigation.
 (setq-local treesit-defun-type-regexp "element")

 (setq-local treesit-defun-name-function
             #'ngxhtml-ts-mode--defun-name)

 (setq-local treesit-thing-settings
             `((ngxhtml
                (sexp
                 ,(regexp-opt
                   '("element" "text" "attribute" "value")))
                (sentence "tag")
                (text ,(regexp-opt '("comment" "text"))))))

 ;; Font-lock.
 (setq-local treesit-font-lock-settings
             ngxhtml-ts-mode--font-lock-settings)
 (setq-local treesit-font-lock-feature-list
             '((comment keyword definition)
               (property string)
               (control pipe bind icu utl sd id)
               ()
               ()))

 ;; Imenu.
 (setq-local treesit-simple-imenu-settings
             '(("Element" "\\`tag_name\\'" nil nil)))

 ;; Outline minor mode.
 (setq-local treesit-outline-predicate "\\`element\\'")
 ;; `ngxhtml-ts-mode' inherits from `ngxhtml-mode' that sets
 ;; regexp-based outline variables.  So need to restore
 ;; the default values of outline variables to be able
 ;; to use `treesit-outline-predicate' above.
 (kill-local-variable 'outline-regexp)
 (kill-local-variable 'outline-heading-end-regexp)
 (kill-local-variable 'outline-level)

 (treesit-major-mode-setup))

(derived-mode-add-parents 'ngxhtml-ts-mode '(html-mode))

(if (treesit-ready-p 'ngxhtml)
    (add-to-list
     'auto-mode-alist '("\\.component.html\\'" . ngxhtml-ts-mode)))

(provide 'ngxhtml-ts-mode)

;;; ngxhtml-ts-mode.el ends here
