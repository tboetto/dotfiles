(use-package
 textsize
 :ensure t
 :init (textsize-mode)
 ;; Can set macOS specific font size if necessary
 :custom
 (textsize-default-points
  (if (eq system-type 'darwin)
      15
    15))
 :config (textsize-fix-frame)
 (customize-set-variable
  'textsize-monitor-size-thresholds
  '((0 . -3) (340 . 0) (600 . -1) (900 . 6) (1200 . 9)))
 (customize-set-variable
  'textsize-pixel-pitch-thresholds '((0 . 15) (.08 . 15) (0.11 . 0))))

;; stole this from jmccarrell
(defun tb/dump-frame-textsize-metrics ()
  "Dump selected frame metrics from the currently selected frame to the *Message* buffer.
  Intended to be helpful for debugging the choices textsize makes for a given monitor/display."
  (interactive)
  (let (f
        (selected-frame))
    (message "emacs frame geometry: X Y WIDTH HEIGHT: %s"
             (frame-monitor-attribute 'geometry f))
    (message "emacs monitor size WIDTH HEIGHT mm: %s"
             (frame-monitor-attribute 'mm-size f))
    (message "textsize monitor size  mm: %d"
             (textsize--monitor-size-mm f))
    (message "textsize monitor size pix: %d"
             (textsize--monitor-size-px f))
    (message "pixel pitch %.02f" (textsize--pixel-pitch f))
    (message "textsize default points %d" textsize-default-points)
    (message "textsize frame offset %d"
             (or (frame-parameter f 'textsize-manual-adjustment) 0))
    (message "pixel pitch adjustment %d"
             (textsize--threshold-offset
              textsize-pixel-pitch-thresholds
              (textsize--pixel-pitch f)))
    (message "monitor size adjustment %d"
             (textsize--threshold-offset
              textsize-monitor-size-thresholds
              (textsize--monitor-size-mm f)))
    (message "text size chosen: %d" (textsize--point-size f))
    (message "default-font: WIDTHxHEIGHT %dx%d"
             (default-font-width)
             (default-font-height))
    (message "resultant text area in chars WIDTHxHEIGHT %dx%d"
             (frame-width f)
             (frame-height f))
    (message "default face font %s" (face-attribute 'default :font)))
  nil)

(provide 'tony-emacs-textsize)
