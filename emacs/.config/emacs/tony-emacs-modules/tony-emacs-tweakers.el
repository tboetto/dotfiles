;;; tony-emacs-tweakers.el --- Small quality-of-life commands and modes  -*- lexical-binding: t; -*-
(setopt isearch-lazy-count t
        lazy-count-prefix-format "(%s/%s) "
        lazy-count-suffix-format nil)

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

(defun my/path-with-position (absolute)
  "Return the current file path plus position, relative unless ABSOLUTE."
  (let* ((file-path
          (cond
           ((derived-mode-p 'dired-mode) (dired-get-file-for-visit))
           ((buffer-file-name) (buffer-file-name))
           (t (error "No file associated with this buffer"))))
         (root (or (when-let* ((proj (project-current)))
                     (project-root proj))
                   default-directory))
         (path (if absolute
                   (expand-file-name file-path)
                 (file-relative-name file-path root))))
    (cond
     ((derived-mode-p 'dired-mode) path)
     ((use-region-p)
      (format "%s:%d-%d" path
              (line-number-at-pos (region-beginning))
              (line-number-at-pos (region-end))))
     (t
      (format "%s:%d:%d" path
              (line-number-at-pos)
              (1+ (- (point) (line-beginning-position))))))))

(defun my/copy-relative-path-with-line ()
  "Copy the project-relative path with line and column to the clipboard."
  (interactive)
  (let ((result (my/path-with-position nil)))
    (kill-new result)
    (message "Copied: %s" result)))

(defun my/copy-absolute-path-with-line ()
  "Copy the absolute path with line and column to the clipboard."
  (interactive)
  (let ((result (my/path-with-position t)))
    (kill-new result)
    (message "Copied: %s" result)))

(global-set-key (kbd "C-c y p") #'my/copy-relative-path-with-line)
(global-set-key (kbd "C-c y P") #'my/copy-absolute-path-with-line)

(defun my/open-in-chrome ()
  "Open the current buffer's file in Google Chrome."
  (interactive)
  (let ((file (or (buffer-file-name)
                  (and (derived-mode-p 'dired-mode) (dired-get-file-for-visit)))))
    (unless file (user-error "Buffer is not visiting a file"))
    (call-process "open" nil 0 nil "-a" "Google Chrome" file)))

(global-set-key (kbd "C-c b") #'my/open-in-chrome)

(provide 'tony-emacs-tweakers)
