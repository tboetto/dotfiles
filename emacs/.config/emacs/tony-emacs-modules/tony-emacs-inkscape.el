;;; tony-emacs-inkscape.el --- Inkscape figures in Org notes  -*- lexical-binding: t; -*-
(require 'filenotify)
(require 'subr-x)

(defvar my/latex-math-macros) ; tony-emacs-org
(declare-function org-element-context "org-element")
(declare-function org-element-lineage "org-element-ast")
(declare-function org-element-property "org-element-ast")
(declare-function org-element-begin "org-element")
(declare-function org-element-end "org-element")
(declare-function org-link-preview-file "ol")
(declare-function org-link-preview-region "ol")
(declare-function org-link-set-parameters "ol")
(declare-function org-latex-export-to-pdf "ox-latex")
(declare-function org-open-file "org")
(declare-function denote-retrieve-filename-identifier "denote")
(declare-function server-edit "server")
(declare-function laas-mode "laas")
(declare-function meow-insert-mode "meow")
(declare-function x-change-window-property "xfns.c")

(defgroup my/inkscape nil
  "Inkscape figures in Org notes."
  :group 'org)

(defcustom my/inkscape-template
  (locate-user-emacs-file "templates/inkscape-figure.svg")
  "SVG file copied to make a new figure."
  :type 'file)

(defcustom my/inkscape-figures-directory "figures"
  "Directory holding figures, relative to the note.
Each note gets its own subdirectory in it."
  :type 'string)

(defcustom my/inkscape-shortcut-manager-directory
  "~/.local/src/clonedStuff/inkscape-shortcut-manager"
  "Clone of Castel's inkscape-shortcut-manager, or nil to never start it."
  :type '(choice directory (const nil)))

(defconst my/inkscape-shortcut-manager-config-directory
  "~/.config/inkscape-shortcut-manager/"
  "Where the shortcut manager looks for config.py, styles and objects.")

(defun my/inkscape--note-file ()
  "File of the current note, or a `user-error' when there is none."
  (or (buffer-file-name (buffer-base-buffer))
      (user-error "This buffer is not visiting a file")))

(defun my/inkscape--figure-dir (&optional file)
  "Figure directory of note FILE, default the current buffer's file."
  (let* ((file (or file (my/inkscape--note-file)))
         (id (or (and (fboundp 'denote-retrieve-filename-identifier)
                      (ignore-errors (denote-retrieve-filename-identifier file)))
                 (file-name-base file))))
    (file-name-as-directory
     (expand-file-name
      id (expand-file-name my/inkscape-figures-directory
                           (file-name-directory file))))))

(defun my/inkscape--rendered (file)
  "Path of the LaTeX-rendered copy of figure FILE."
  (expand-file-name (concat ".rendered/" (file-name-nondirectory file))
                    (file-name-directory file)))

(defun my/inkscape--slug (title dir)
  "Turn TITLE into a file name base not yet used by an SVG in DIR."
  (let* ((base (string-trim (replace-regexp-in-string
                             "[^a-z0-9]+" "-" (downcase title))
                            "-+" "-+"))
         (base (if (string-empty-p base) "figure" base))
         (slug base)
         (n 1))
    (while (file-exists-p (expand-file-name (concat slug ".svg") dir))
      (setq slug (format "%s-%d" base (setq n (1+ n)))))
    slug))

(defun my/inkscape--link-block (title file &optional indent)
  "Org text that includes figure FILE with caption TITLE.
Each line is indented by INDENT columns."
  (let ((pad (make-string (or indent 0) ?\s)))
    (format "%s#+CAPTION: %s\n%s#+NAME: fig:%s\n%s[[file:%s]]"
            pad title pad (file-name-base file) pad
            (file-relative-name file))))

(defvar my/inkscape--watches (make-hash-table :test #'equal)
  "Figure directory -> file notification descriptor.")
(defvar my/inkscape--timers (make-hash-table :test #'equal)
  "Figure file -> pending debounce timer.")
(defvar my/inkscape--renders (make-hash-table :test #'equal)
  "Figure file -> `running', or `dirty' when it changed during the render.")

(defun my/inkscape--watch (dir)
  "Render figures in DIR whenever they are saved."
  (let ((dir (file-name-as-directory (expand-file-name dir))))
    (when (and (file-directory-p dir)
               (not (file-notify-valid-p (gethash dir my/inkscape--watches))))
      (puthash dir (file-notify-add-watch dir '(change) #'my/inkscape--notify)
               my/inkscape--watches))))

(defun my/inkscape--notify (event)
  "Schedule a render for the figure that file notification EVENT is about."
  (pcase-let* ((`(,_ ,action ,file . ,rest) event)
               (file (if (eq action 'renamed) (car rest) file)))
    (when (and (memq action '(created changed renamed))
               (string-suffix-p ".svg" file)
               (not (string-prefix-p "." (file-name-nondirectory file))))
      (when-let* ((timer (gethash file my/inkscape--timers)))
        (cancel-timer timer))
      (puthash file (run-with-timer 0.5 nil #'my/inkscape--render file)
               my/inkscape--timers))))

(defun my/inkscape--log (format-string &rest args)
  "Append a line to the *inkscape-figures* buffer."
  (with-current-buffer (get-buffer-create "*inkscape-figures*")
    (goto-char (point-max))
    (insert (apply #'format format-string args) "\n")))

(defun my/inkscape--render (file)
  "Build the rendered copy of figure FILE asynchronously."
  (remhash file my/inkscape--timers)
  (cond
   ((gethash file my/inkscape--renders)
    (puthash file 'dirty my/inkscape--renders))
   ((file-exists-p file)
    (let* ((name (file-name-base file))
           (dir (file-name-directory (my/inkscape--rendered file))))
      (make-directory dir t)
      (when (zerop (hash-table-count my/inkscape--renders))
        (with-current-buffer (get-buffer-create "*inkscape-figures*")
          (erase-buffer)))
      (puthash file 'running my/inkscape--renders)
      (my/inkscape--log "== %s  %s" (format-time-string "%T") file)
      (delete-file (expand-file-name (concat name ".pdf_tex") dir))
      (with-temp-file (expand-file-name (concat name ".wrap.tex") dir)
        (insert "\\documentclass{standalone}\n"
                "\\usepackage{graphicx,xcolor,transparent,calc,amsmath,amssymb}\n"
                my/latex-math-macros "\n"
                "\\begin{document}\n"
                "\\input{" name ".pdf_tex}\n"
                "\\end{document}\n"))
      (my/inkscape--chain
       file dir
       `(("inkscape" ,file "--export-area-drawing" "--export-type=pdf"
          "--export-latex" ,(concat "--export-filename=" dir name ".pdf"))
         ("pdflatex" "-interaction=nonstopmode" "-halt-on-error"
          ,(concat name ".wrap.tex"))
         ("pdf2svg" ,(concat name ".wrap.pdf") ,(concat name ".tmp.svg"))))))))

(defun my/inkscape--chain (file dir commands)
  "Run COMMANDS one after another in DIR, then finish the render of FILE."
  (if (null commands)
      (my/inkscape--finish file dir)
    (let ((default-directory dir))
      (make-process
       :name "inkscape-figure"
       :buffer (get-buffer-create "*inkscape-figures*")
       :command (car commands)
       :connection-type 'pipe
       :noquery t
       :sentinel
       (lambda (process _event)
         (when (memq (process-status process) '(exit signal))
           (if (zerop (process-exit-status process))
               (my/inkscape--chain file dir (cdr commands))
             (my/inkscape--done file dir)
             (my/inkscape--log "!! %s failed" (caar commands))
             (message "Figure %s: %s failed, see *inkscape-figures*"
                      (file-name-base file) (caar commands)))))))))

(defun my/inkscape--finish (file dir)
  "Install the freshly rendered copy of FILE from DIR and show it."
  (let ((tmp (expand-file-name (concat (file-name-base file) ".tmp.svg") dir)))
    (with-temp-buffer
      (insert-file-contents tmp)
      (while (re-search-forward "rgb(0%, ?0%, ?0%)\\|#000000" nil t)
        (replace-match "currentColor" t t))
      (write-region nil nil tmp nil 'silent))
    (rename-file tmp (my/inkscape--rendered file) t))
  (my/inkscape--done file dir)
  (my/inkscape--refresh file))

(defun my/inkscape--done (file dir)
  "Remove intermediate files for FILE in DIR; render again if it changed."
  (dolist (ext '(".pdf" ".pdf_tex" ".wrap.tex" ".wrap.pdf" ".wrap.aux"
                 ".wrap.log" ".tmp.svg"))
    (delete-file (expand-file-name (concat (file-name-base file) ext) dir)))
  (let ((state (gethash file my/inkscape--renders)))
    (remhash file my/inkscape--renders)
    (when (eq state 'dirty)
      (my/inkscape--render file))))

(defun my/inkscape--refresh (file)
  "Redisplay the preview of every Org link to figure FILE."
  (let ((name (file-name-nondirectory file)))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (derived-mode-p 'org-mode)
          (save-excursion
            (save-restriction
              (widen)
              (goto-char (point-min))
              (while (search-forward name nil t)
                (when-let* ((link (org-element-lineage
                                   (save-excursion (backward-char)
                                                   (org-element-context))
                                   'link t))
                            ((equal (org-element-property :type link) "file"))
                            ((equal (expand-file-name
                                     (org-element-property :path link))
                                    file)))
                  (org-link-preview-region nil t (org-element-begin link)
                                           (org-element-end link)))))))))))

(defun my/inkscape-render-figures ()
  "Render every figure of the current note again."
  (interactive nil org-mode)
  (let* ((dir (my/inkscape--figure-dir))
         (files (and (file-directory-p dir)
                     (directory-files dir t "\\`[^.].*\\.svg\\'"))))
    (mapc #'my/inkscape--render files)
    (message "Rendering %d figure(s)" (length files))))

(defun my/inkscape--link-preview (ov path link)
  "Preview file link PATH in OV, preferring a rendered figure copy.
See `org-link-preview-file' for OV, PATH and LINK."
  (let ((rendered (and (string-suffix-p ".svg" path t)
                       (my/inkscape--rendered (expand-file-name path)))))
    (org-link-preview-file
     ov (if (and rendered (file-exists-p rendered)) rendered path) link)))

(defun my/inkscape--org-setup ()
  "Watch the current note's figure directory if it has one."
  (when (buffer-file-name (buffer-base-buffer))
    (my/inkscape--watch (my/inkscape--figure-dir))))

(setq org-startup-with-link-previews t)
(add-hook 'org-mode-hook #'my/inkscape--org-setup)
(with-eval-after-load 'ol
  (org-link-set-parameters "file" :preview #'my/inkscape--link-preview))

(defun my/inkscape--open (file)
  "Edit figure FILE in Inkscape."
  (unless (executable-find "inkscape")
    (user-error "Inkscape is not installed"))
  (my/inkscape--watch (file-name-directory file))
  (my/inkscape-shortcut-manager-start)
  (call-process "inkscape" nil 0 nil file))

(defun my/inkscape--create (title)
  "Replace the current line with a new figure called TITLE and open it."
  (unless (file-exists-p my/inkscape-template)
    (user-error "No figure template at %s" my/inkscape-template))
  (let* ((dir (my/inkscape--figure-dir))
         (file (expand-file-name
                (concat (my/inkscape--slug title dir) ".svg") dir))
         (indent (current-indentation)))
    (make-directory dir t)
    (copy-file my/inkscape-template file)
    (delete-region (pos-bol) (pos-eol))
    (insert (my/inkscape--link-block title file indent))
    (my/inkscape--open file)
    (message "Created %s" (file-relative-name file))))

(defun my/inkscape--pick ()
  "Choose one of the current note's figures, open it and copy its link."
  (let* ((dir (my/inkscape--figure-dir))
         (files (and (file-directory-p dir)
                     (sort (directory-files dir t "\\`[^.].*\\.svg\\'")
                           #'file-newer-than-file-p)))
         (names (mapcar #'file-name-base files)))
    (unless names
      (user-error "This note has no figures yet; type a title on the line first"))
    (let* ((name (completing-read
                  "Figure: "
                  (lambda (string pred action)
                    (if (eq action 'metadata)
                        '(metadata (display-sort-function . identity)
                                   (cycle-sort-function . identity))
                      (complete-with-action action names string pred)))
                  nil t))
           (file (expand-file-name (concat name ".svg") dir)))
      (kill-new (my/inkscape--link-block
                 (let ((title (string-replace "-" " " name)))
                   (concat (upcase (substring title 0 1)) (substring title 1)))
                 file))
      (my/inkscape--open file)
      (message "Opened %s; its link block is on the kill ring" name))))

(defun my/inkscape-figure-dwim ()
  "Open, create or pick an Inkscape figure, depending on the current line.
On a line with a link to an SVG, open it.  On a line with other
text, use the text as the title of a new figure.  On an empty
line, choose among the note's figures."
  (interactive nil org-mode)
  (let ((line (string-trim (buffer-substring-no-properties (pos-bol) (pos-eol)))))
    (cond
     ((string-match "\\[\\[\\(?:file:\\)?\\([^]]+\\.svg\\)\\]" line)
      (my/inkscape--open (expand-file-name (match-string 1 line))))
     ((string-empty-p line) (my/inkscape--pick))
     ((string-match-p "\\`\\(?:\\*+ \\|#\\+\\)" line)
      (user-error "Put the figure title on a plain line of its own"))
     (t (my/inkscape--create line)))))

(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c e" #'my/inkscape-figure-dwim))

(defvar my/inkscape--shortcut-manager nil
  "The shortcut manager process.")

(defun my/inkscape-shortcut-manager-start ()
  "Start the Inkscape shortcut manager unless it is already running."
  (interactive)
  (let ((main (and my/inkscape-shortcut-manager-directory
                   (expand-file-name "main.py"
                                     my/inkscape-shortcut-manager-directory))))
    (cond
     ((process-live-p my/inkscape--shortcut-manager))
     ((not (and main (file-exists-p main) (eq window-system 'x)))
      (when (called-interactively-p 'any)
        (message "No shortcut manager at %s, or not on X11"
                 my/inkscape-shortcut-manager-directory)))
     (t
      (make-directory my/inkscape-shortcut-manager-config-directory t)
      (with-temp-file (expand-file-name
                       "macros.tex" my/inkscape-shortcut-manager-config-directory)
        (insert my/latex-math-macros "\n"))
      (let ((default-directory (file-name-directory main)))
        (setq my/inkscape--shortcut-manager
              (make-process
               :name "inkscape-shortcut-manager"
               :buffer (get-buffer-create "*inkscape-shortcut-manager*")
               :command (list "python3" "-u" main)
               :connection-type 'pipe
               :noquery t)))))))

(defun my/inkscape-shortcut-manager-stop ()
  "Stop the Inkscape shortcut manager."
  (interactive)
  (when (process-live-p my/inkscape--shortcut-manager)
    (delete-process my/inkscape--shortcut-manager))
  (setq my/inkscape--shortcut-manager nil))

(defvar-keymap my/inkscape-latex-popup-mode-map
  "C-c C-c" #'my/inkscape-latex-popup-finish
  "C-c C-k" #'my/inkscape-latex-popup-cancel)

(define-minor-mode my/inkscape-latex-popup-mode
  "Keys for the LaTeX popup opened from Inkscape."
  :lighter " InkTeX")

(defun my/inkscape-latex-popup-finish ()
  "Save the popup's text and hand it back to Inkscape."
  (interactive)
  (save-buffer)
  (server-edit))

(defun my/inkscape-latex-popup-cancel ()
  "Close the popup without adding text to the figure."
  (interactive)
  (erase-buffer)
  (insert "$$")
  (my/inkscape-latex-popup-finish))

(defun my/inkscape-latex-popup-setup ()
  "Set up a frame that the shortcut manager opened for LaTeX input."
  (let ((frame (selected-frame)))
    (when (equal (frame-parameter frame 'name) "inkscape-latex")
      (when (eq (framep frame) 'x)
        (x-change-window-property
         "_NET_WM_WINDOW_TYPE" '("_NET_WM_WINDOW_TYPE_DIALOG")
         frame "ATOM" 32 t))
      (make-frame-visible frame)
      (pcase-let ((`(,x ,y ,width ,height) (frame-monitor-workarea frame)))
        (set-frame-position
         frame
         (+ x (/ (- width (frame-outer-width frame)) 2))
         (+ y (- height (frame-outer-height frame) 40))))
      (select-frame-set-input-focus frame)
      (my/inkscape-latex-popup-mode 1)
      (when (fboundp 'laas-mode) (laas-mode 1))
      (goto-char (point-min))
      (when (looking-at-p "\\$\\$") (forward-char 1))
      (when (bound-and-true-p meow-mode) (meow-insert-mode 1)))))

(add-hook 'server-switch-hook #'my/inkscape-latex-popup-setup)

(defvar org-latex-pdf-process)
(defvar org-latex-packages-alist)

(defun my/inkscape-org-export-pdf ()
  "Export the buffer to PDF with Inkscape figures, then open the PDF.
Shell escape is on for this one export only."
  (interactive nil org-mode)
  (require 'ox-latex)
  (unless (listp org-latex-pdf-process)
    (user-error "`org-latex-pdf-process' is not a list of commands"))
  (let ((org-latex-pdf-process
         (mapcar (lambda (command)
                   (string-replace "%latex " "%latex -shell-escape " command))
                 org-latex-pdf-process))
        (org-latex-packages-alist
         (append org-latex-packages-alist
                 (list '("" "svg") my/latex-math-macros))))
    (org-open-file (org-latex-export-to-pdf))))

(provide 'tony-emacs-inkscape)
