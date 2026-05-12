(use-package anzu :ensure t :config (global-anzu-mode))

(use-package
 surround
 :ensure t
 :bind-keymap ("C-c s" . surround-keymap))

;; (pixel-scroll-precision-mode)
(use-package
 ultra-scroll
 :ensure t
 :init
 (setopt
  scroll-conservatively 3
  scroll-margin 0)
 :config (ultra-scroll-mode 1))

(defun my/copy-relative-path-with-line ()
  "Copy relative path of current file with line number to clipboard.
In dired, copies the path of the file at point without a line number.
Path is relative to the project root, or `default-directory' if no project."
  (interactive)
  (let* ((file-path
          (cond
           ((derived-mode-p 'dired-mode) (dired-get-file-for-visit))
           ((buffer-file-name) (buffer-file-name))
           (t (error "No file associated with this buffer"))))
         (root (or (when-let ((proj (project-current)))
                     (project-root proj))
                   default-directory))
         (relative (file-relative-name file-path root))
         (result
          (if (derived-mode-p 'dired-mode)
              relative
            (format "%s:%d" relative (line-number-at-pos)))))
    (kill-new result)
    (message "Copied: %s" result)))

(global-set-key (kbd "C-c y p") #'my/copy-relative-path-with-line)

(provide 'tony-emacs-tweakers)
