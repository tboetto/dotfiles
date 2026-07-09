(use-package
 denote
 :ensure (:host github :repo "protesilaos/denote")
 :demand t
 :init
 :config
 (setq denote-file-type 'org)
 (setq denote-workdir (expand-file-name "~/Documents/org/work-notes"))
 (setq denote-directory (expand-file-name "~/Documents/org/denote"))
 (setq denote-known-keywords
       '("emacs"
         "org mode"
         "denote"
         "game dev"
         "godot"
         "C"
         "lisp"
         "typescript"
         "javascript"
         "angular"
         "ngrx"
         "hand tools"
         "power tools"
         "offroading"
         "preparedness")))

(use-package
 denote-journal
 :ensure (:host github :repo "protesilaos/denote-journal")
 :demand t
 :after denote
 :custom
 (denote-journal-directory
  (expand-file-name "journal" denote-directory))
 (denote-journal-title-format 'day-date-month-year)
 (denote-journal-keyword "journal")

 :config
 (with-eval-after-load 'org-capture
   (add-to-list
    'org-capture-templates
    '("ndj"
      "Journal"
      entry
      (file denote-journal-path-to-new-or-existing-entry)
      "* %U\n\n%?"
      :kill-buffer t
      :empty-lines 1)))

 :bind
 (("C-c n j" . denote-journal-new-entry)
  ("C-c n J" . denote-journal-new-or-existing-entry)))

(use-package
 denote-markdown
 ;; TODO There is apparently Obsidian support. Maybe I could create a Silo or
 ;; something that is located at the Obsidian directory. Having the ability to
 ;; link my Obsidian notes with my denote(s) would be really nice. Definitely
 ;; going to look into this.
 :ensure (:host github :repo "protesilaos/denote-markdown")
 :demand t
 :after denote)

(use-package
  denote-silo
  :ensure (:host github :repo "protesilaos/denote-silo")
  :demand t
  :after denote
  :custom
  (denote-silo-directories (list denote-directory denote-workdir))
  :bind
  (("C-c N d" . denote-silo-dired)
   ("C-c N n" . denote-silo-open-or-create)
   ("C-c N N" . denote-silo-select-silo-then-command)
   ("C-c N c" . denote-silo-cd)))

(use-package denote-sequence
:ensure (:host github :repo "protesilaos/denote-sequence")
:bind
( :map global-map
  ;; Here we make "C-c n s" a prefix for all "[n]otes with [s]equence".
  ;; This is just for demonstration purposes: use the key bindings
  ;; that work for you.  Also check the commands:
  ;;
  ;; - `denote-sequence-new-parent'
  ;; - `denote-sequence-new-sibling'
  ;; - `denote-sequence-new-child'
  ;; - `denote-sequence-new-child-of-current'
  ;; - `denote-sequence-new-sibling-of-current'
  ("C-c n s s" . denote-sequence)
  ("C-c n s f" . denote-sequence-find)
  ("C-c n s l" . denote-sequence-link)
  ("C-c n s d" . denote-sequence-dired)
  ("C-c n s r" . denote-sequence-reparent)
  ("C-c n s c" . denote-sequence-convert))
:config
;; The default sequence scheme is `numeric'.
(setq denote-sequence-scheme 'alphanumeric))

(use-package
 denote-explore
 :ensure t
 :after denote denote-sequence
 :custom
 ;; Where to store network data and in which format
 (denote-explore-network-directory
  (concat denote-directory "/graphs/"))
 (denote-explore-network-filename "denote-network")
 ;; Output format
 (denote-explore-network-format 'graphviz)
 (denote-explore-network-graphviz-filetype "svg")
 ;; Exlude keywords or regex
 (denote-explore-network-keywords-ignore '("bib"))
 :bind
 ( ;; Statistics
  ("C-c n e c" . denote-explore-count-notes)
  ("C-c n e C" . denote-explore-count-keywords)
  ("C-c n e b" . denote-explore-keywords-barchart)
  ("C-c n e x" . denote-explore-extensions-barchart)
  ;; Random walks
  ("C-c n e r" . denote-explore-random-note)
  ("C-c n e l" . denote-explore-random-link)
  ("C-c n e k" . denote-explore-random-keyword)
  ;; Denote Janitor
  ("C-c n e d" . denote-explore-identify-duplicate-notes)
  ("C-c n e z" . denote-explore-zero-keywords)
  ("C-c n e s" . denote-explore-single-keywords)
  ("C-c n e o" . denote-explore-sort-keywords)
  ("C-c n e r" . denote-explore-rename-keywords)
  ;; Visualise denote
  ("C-c n e n" . denote-explore-network)
  ("C-c n e v" . denote-explore-network-regenerate)
  ("C-c n e D" . denote-explore-degree-barchart)))

(use-package consult-denote
  :ensure (:host github :repo "protesilaos/consult-denote")
  :bind
  (("C-c n c f" . consult-denote-find)
   ("C-c n c g" . consult-denote-grep))

  :custom
  (consult-denote-find-command 'consult-fd)
  (consult-denote-grep-command 'consult-ripgrep)

  :config
  (consult-denote-mode 1))

(provide 'tony-emacs-denote)
