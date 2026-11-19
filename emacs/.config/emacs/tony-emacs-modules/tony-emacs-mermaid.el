;;; tony-emacs-mermaid.el --- Mermaid diagram mode  -*- lexical-binding: t; -*-
  (use-package mermaid-mode
    :ensure (:host github :repo "abrochard/mermaid-mode")
    :after org)

(defvar mermaid-flags) ; mermaid-mode
(declare-function my/inkscape--figure-dir "tony-emacs-inkscape")
(declare-function org-babel-get-src-block-info "ob-core")
(declare-function org-babel-where-is-src-block-result "ob-core")
(declare-function org-babel-result-end "ob-core")
(declare-function org-link-preview-region "ol")

(defconst my/mermaid-browsers
  '("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/usr/bin/chromium")
  "Browsers Puppeteer may render mermaid diagrams with, first found wins.")

(unless (getenv "PUPPETEER_EXECUTABLE_PATH")
  (when-let* ((browser (seq-find #'file-executable-p my/mermaid-browsers)))
    (setenv "PUPPETEER_EXECUTABLE_PATH" browser)))

(defun my/mermaid-output-dir ()
  "Figure directory of the current note, or nil to write beside it."
  (when (fboundp 'my/inkscape--figure-dir)
    (ignore-errors (file-relative-name (my/inkscape--figure-dir)))))

(defconst my/mermaid-config
  '((htmlLabels . :false)
    (flowchart . ((htmlLabels . :false) (useMaxWidth . :false)))
    (sequence . ((useMaxWidth . :false))))
  "Mermaid configuration passed to every mmdc run.")

(defun my/mermaid-write-config ()
  "Write `my/mermaid-config' to a temporary JSON file and return its path."
  (let ((file (expand-file-name "mermaid-config.json"
                                temporary-file-directory)))
    (with-temp-file file
      (insert (json-serialize my/mermaid-config)))
    file))

(defun my/mermaid-theme ()
  "Mermaid theme matching the current Emacs background."
  (if (eq (frame-parameter nil 'background-mode) 'dark) "dark" "default"))

(defun my/mermaid-preserve-spaces (file)
  "Mark SVG FILE so librsvg keeps the spaces between label words."
  (with-temp-file file
    (insert-file-contents file)
    (when (and (re-search-forward "<svg " nil t)
               (not (looking-at-p "xml:space")))
      (insert "xml:space=\"preserve\" "))))

(defun my/mermaid-preview-result ()
  "Fix up and preview the image result of the mermaid block at point."
  (when (equal (car (org-babel-get-src-block-info 'no-eval)) "mermaid")
    (when-let* ((beg (org-babel-where-is-src-block-result)))
      (save-excursion
        (goto-char beg)
        (forward-line)
        (let ((link (org-element-context)))
          (when (org-element-type-p link 'link)
            (let ((file (expand-file-name (org-element-property :path link))))
              (when (file-exists-p file)
                (my/mermaid-preserve-spaces file)))))
        (org-link-preview-region nil t beg (org-babel-result-end))))))

(defun my/org-link-preview-in-displayed-window (fn &rest args)
  "Call FN with ARGS in a window showing the current buffer, if any."
  (let ((window (get-buffer-window nil t)))
    (if (and window (not (eq window (selected-window))))
        (with-selected-window window (apply fn args))
      (apply fn args))))

(with-eval-after-load 'mermaid-mode
  (add-to-list 'org-babel-load-languages '(mermaid . t))
  (setq org-babel-default-header-args:mermaid
        '((:results . "file")
          (:exports . "results")
          (:file-ext . "svg")
          (:output-dir . my/mermaid-output-dir)
          (:theme . my/mermaid-theme)
          (:background-color . "transparent")))
  (setq mermaid-flags
        (concat "-c " (shell-quote-argument (my/mermaid-write-config))))
  (setq org-image-max-width 'window)
  (advice-add 'org-link-preview-region :around
              #'my/org-link-preview-in-displayed-window)
  (add-hook 'org-babel-after-execute-hook #'my/mermaid-preview-result))

(declare-function image-display-size "image.c")
(declare-function image-get-display-property "image-mode")
(declare-function image-set-window-hscroll "image-mode")
(declare-function image-set-window-vscroll "image-mode")
(declare-function image-transform-original "image-mode")

(defun my/image-drag-pan (event)
  "Pan the image in the window of EVENT by dragging the mouse."
  (interactive "e")
  (with-selected-window (posn-window (event-start event))
    (let* ((size (image-display-size (image-get-display-property) t))
           (char (frame-char-width))
           (max-x (max 0 (- (car size) (window-body-width nil t))))
           (max-y (max 0 (- (cdr size) (window-body-height nil t))))
           (start (cdr (mouse-pixel-position)))
           (x0 (* (window-hscroll) char))
           (y0 (window-vscroll nil t)))
      (track-mouse
        (while (mouse-movement-p (read-event))
          (let ((pos (cdr (mouse-pixel-position))))
            (when (car pos)
              (image-set-window-hscroll
               (/ (min max-x (max 0 (- x0 (- (car pos) (car start))))) char))
              (image-set-window-vscroll
               (min max-y (max 0 (- y0 (- (cdr pos) (cdr start)))))))))))))

(defun my/image-original-size-for-figures ()
  "Show an SVG from a note's figure directory at its original size."
  (when (and buffer-file-name
             (string-match-p "/figures/[^/]+/[^/]+\\.svg\\'" buffer-file-name))
    (image-transform-original)))

(with-eval-after-load 'image-mode
  (keymap-set image-mode-map "<down-mouse-1>" #'my/image-drag-pan)
  (add-hook 'image-mode-hook #'my/image-original-size-for-figures))

(provide 'tony-emacs-mermaid)
