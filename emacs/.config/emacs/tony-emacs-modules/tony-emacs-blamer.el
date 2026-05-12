(use-package
 blamer
 :ensure (:host github :repo "artawower/blamer.el")
 :bind (("s-i" . my/blamer-toggle-mode)
        ("s-I" . my/blamer-open-pr))
 :custom (blamer-idle-time 0.3) (blamer-min-offset 70)
 :custom-face
 (blamer-face
  ((t :foreground "#7a88cf" :background nil :height 140 :italic t)))
 :config
 (global-blamer-mode 1)
 (defun my/blamer-toggle-mode ()
   "Toggle blamer-mode on/off."
   (interactive)
   (blamer-mode (if blamer-mode -1 1)))
 (defun my/blamer-open-pr ()
   "Open the GitHub PR that merged the commit at the current line."
   (interactive)
   (let ((line (line-number-at-pos))
         (dir default-directory))
     (blamer--get-async-blame-info
      (buffer-file-name) line line
      (lambda (commit-info)
        (when (and commit-info (string-match "^\\([[:xdigit:]]+\\) " commit-info))
          (let* ((sha (match-string 1 commit-info))
                 (default-directory dir)
                 (url (string-trim
                       (shell-command-to-string
                        (format "gh pr list --search %s --state merged --json url --jq '.[0].url' 2>/dev/null"
                                (shell-quote-argument sha))))))
            (if (string-empty-p url)
                (message "No merged PR found for commit %s" sha)
              (browse-url url)))))))))

(provide 'tony-emacs-blamer)
