# dotfiles

## Emacs config is literate

`emacs/.config/emacs/my-init.org` is the source of truth for the Emacs config. It tangles to `early-init.el`, `init.el`, everything in `tony-emacs-modules/`, and `tony-lisp/ngxhtml-ts-mode.el`. Each source block's `:tangle` header names its target file.

- Make every change to a tangled file in `my-init.org`, never in the `.el` file directly. Edits to a tangled `.el` are overwritten the next time the org file is tangled.
- Put explanatory prose in the org heading text around the block rather than in comments inside the block, matching the existing sections.
- After editing, tangle with the running Emacs:

  ```sh
  emacsclient --eval '(progn (require (quote ob-tangle)) (org-babel-tangle-file "/Users/c131265/dotfiles/emacs/.config/emacs/my-init.org" nil "emacs-lisp"))'
  ```

- Review `git diff` on the tangled `.el` files to confirm only the intended lines changed, then stage both `my-init.org` and the regenerated `.el` files by path.
- Files that are not tangled are edited directly: `themes/*.el` and `tony-lisp/remember-last-theme.el`. Check for a `:tangle` header naming a file before assuming it is hand-maintained.
- Untracked state files Emacs writes (`*.eld`, `tramp`, `eln-cache`, `elpaca`) are never staged.
