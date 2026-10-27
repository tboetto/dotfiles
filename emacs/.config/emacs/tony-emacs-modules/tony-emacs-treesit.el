;;; tony-emacs-treesit.el --- Tree-sitter grammars and major mode remapping  -*- lexical-binding: t; -*-
(use-package
 treesit
 :ensure nil ; built in
 :custom
 ;; Install a grammar the first time a mode actually needs it, rather than
 ;; looping over every recipe on each startup. Set to `always' to skip the
 ;; confirmation prompt.
 (treesit-auto-install-grammar 'ask)
 (treesit-font-lock-level 6)
 :config
 (dolist (grammar
          '((angular "https://github.com/dlvandenberg/tree-sitter-angular")
            (bash "https://github.com/tree-sitter/tree-sitter-bash")
            (c "https://github.com/tree-sitter/tree-sitter-c")
            (cmake "https://github.com/uyha/tree-sitter-cmake")
            (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
            (css "https://github.com/tree-sitter/tree-sitter-css")
            (elisp "https://github.com/Wilfred/tree-sitter-elisp")
            (gdscript "https://github.com/PrestonKnopp/tree-sitter-gdscript")
            (html "https://github.com/tree-sitter/tree-sitter-html")
            (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
            (json "https://github.com/tree-sitter/tree-sitter-json")
            (make "https://github.com/alemuller/tree-sitter-make")
            (markdown "https://github.com/ikatyang/tree-sitter-markdown")
            (prisma "https://github.com/victorhqc/tree-sitter-prisma")
            (python "https://github.com/tree-sitter/tree-sitter-python")
            (toml "https://github.com/tree-sitter/tree-sitter-toml" "v0.5.1")
            (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
   (add-to-list 'treesit-language-source-alist grammar)))

(setopt treesit-enabled-modes t)

;; Deliberate deviations from `treesit-major-mode-remap-alist', which sends
;; JS to `js-ts-mode'. typescript-ts-mode handles plain JS better for this
;; codebase. Note core's `auto-mode-alist' yields `javascript-mode' (an alias
;; of `js-mode') for .js, so both symbols need an entry. json-mode and
;; js2-mode are third-party and absent from the built-in table.
(dolist (mapping '((js-mode . typescript-ts-mode)
                   (javascript-mode . typescript-ts-mode)
                   (js2-mode . typescript-ts-mode)
                   (json-mode . json-ts-mode)
                   ;; gdscript-mode.el pushes its own .gd entry onto
                   ;; `auto-mode-alist' when it loads, so remap instead.
                   (gdscript-mode . gdscript-ts-mode)))
  (add-to-list 'major-mode-remap-alist mapping))

(use-package treesit-fold
  :ensure (:host github :repo "emacs-tree-sitter/treesit-fold")
  :hook (elpaca-after-init . global-treesit-fold-mode)
  :config
  ;; ngxhtml-ts-mode is custom, so treesit-fold has no rules for it. Reuse the
  ;; HTML element rule and fold Angular control-flow blocks (@if/@for/...).
  (add-to-list 'treesit-fold-range-alist
               '(ngxhtml-ts-mode
                 (element . treesit-fold-range-html)
                 (statement_block . treesit-fold-range-seq)))
  :bind (("C-c z t" . treesit-fold-toggle)
         ("C-c z o" . treesit-fold-open-all)
         ("C-c z c" . treesit-fold-close-all)))

(dolist (entry '(("\\.js\\'" . typescript-ts-mode)
                 ("\\.mjs\\'" . typescript-ts-mode)
                 ("\\.cjs\\'" . typescript-ts-mode)
                 ("\\.ts\\'" . typescript-ts-mode)
                 ("\\.mts\\'" . typescript-ts-mode)
                 ("\\.jsx\\'" . tsx-ts-mode)
                 ("\\.json\\'" . json-ts-mode)
                 ("\\.yaml\\'" . yaml-ts-mode)
                 ("\\.Dockerfile\\'" . dockerfile-ts-mode)
                 ("\\.prisma\\'" . prisma-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(provide 'tony-emacs-treesit)
