;; copilot requires track-changes >= 1.4
(use-package track-changes
  :ensure (:host github :repo "emacs-straight/track-changes" :type git))

(use-package copilot
  :ensure (:host github :repo "copilot-emacs/copilot.el")
  :after track-changes
  :hook ((prog-mode . copilot-mode)
         (prog-mode . copilot-nes-mode)
         (ngxhtml-ts-mode . copilot-mode)
         (ngxhtml-ts-mode . copilot-nes-mode))
  :bind
  (:map copilot-completion-map
        ("<tab>"   . copilot-accept-completion)
        ("TAB"     . copilot-accept-completion)
        ("C-TAB"   . copilot-accept-completion-by-word)
        ("C-<tab>" . copilot-accept-completion-by-word)
        ("M-n"     . copilot-next-completion)
        ("M-p"     . copilot-previous-completion))
  :custom
  (copilot-idle-delay 0.5)
  (copilot-max-char -1)
  :config
  ;; copilot-nes-mode's default TAB/C-g bindings live in the ordinary
  ;; minor-mode map, which loses to corfu's completion popup whenever
  ;; both are active. Give NES the same at-point overlay keymap trick
  ;; copilot-completion-map already uses, so it wins the same way.
  (defvar-local tony/copilot-nes--keymap-overlay nil)
  (defvar tony/copilot-nes-priority-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "TAB") #'copilot-nes-accept)
      (define-key map [tab] #'copilot-nes-accept)
      (define-key map (kbd "C-g") #'copilot-nes-dismiss)
      map))
  (defun tony/copilot-nes--sync-keymap-overlay (&rest _)
    (if copilot-nes--edit
        (progn
          (unless (overlayp tony/copilot-nes--keymap-overlay)
            (setq tony/copilot-nes--keymap-overlay (make-overlay 1 1 nil nil t))
            (overlay-put tony/copilot-nes--keymap-overlay 'keymap tony/copilot-nes-priority-map)
            (overlay-put tony/copilot-nes--keymap-overlay 'priority 101))
          (move-overlay tony/copilot-nes--keymap-overlay (point) (min (point-max) (1+ (point)))))
      (when (overlayp tony/copilot-nes--keymap-overlay)
        (move-overlay tony/copilot-nes--keymap-overlay 1 1))))
  (advice-add 'copilot-nes--display :after #'tony/copilot-nes--sync-keymap-overlay)
  (advice-add 'copilot-nes--clear :after #'tony/copilot-nes--sync-keymap-overlay)
  (advice-add 'copilot-nes--post-command :after #'tony/copilot-nes--sync-keymap-overlay)
  ;; Teach copilot the indentation variable for ngxhtml-ts-mode
  (add-to-list 'copilot-indentation-alist
               '(ngxhtml-ts-mode ngxhtml-ts-mode-indent-offset))
  (add-to-list 'copilot-indentation-alist
               '(mhtml-mode sgml-basic-offset))
  (add-to-list 'copilot-indentation-alist
               '(gdscript-mode gdscript-indent-offset))
  (add-to-list 'copilot-indentation-alist
               '(gdscript-ts-mode gdscript-indent-offset))
  ;; Show a nerd-icons Copilot indicator in the mode-line
  (with-eval-after-load 'nerd-icons
    (defun tony/copilot-mode-line-indicator ()
      (when (bound-and-true-p copilot-mode)
        (concat " " (nerd-icons-faicon "nf-fa-github") " Copilot")))
    (add-to-list 'global-mode-string
                 '(:eval (tony/copilot-mode-line-indicator)))))

(provide 'tony-emacs-copilot)
