;; copilot requires track-changes >= 1.4
(use-package track-changes :ensure t)

(use-package copilot
  :ensure (:host github :repo "copilot-emacs/copilot.el")
  :after track-changes
  :hook (prog-mode . copilot-mode)
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
  ;; Show a nerd-icons Copilot indicator in the mode-line
  (with-eval-after-load 'nerd-icons
    (defun tony/copilot-mode-line-indicator ()
      (when (bound-and-true-p copilot-mode)
        (concat " " (nerd-icons-faicon "nf-fa-github") " Copilot")))
    (add-to-list 'global-mode-string
                 '(:eval (tony/copilot-mode-line-indicator)))))

(provide 'tony-emacs-copilot)
