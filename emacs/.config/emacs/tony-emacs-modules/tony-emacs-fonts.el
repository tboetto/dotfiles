(defvar my-linux-font "Aporetic Serif Mono")
(defvar my-macos-font "Aporetic Serif Mono")

(if (eq system-type 'darwin)
    (defvar my-editor-font my-macos-font)
  (defvar my-editor-font my-linux-font))

(if (eq system-type 'darwin)
    (progn
      (defvar my-default-font my-editor-font)
      (defvar my-variable-pitch-font "Aporetic Sans")
      (defvar my-serif-font "Aporetic Sans"))
  (progn
    (defvar my-default-font my-editor-font)
    (defvar my-variable-pitch-font "Aporetic Sans")
    (defvar my-serif-font "Aporetic Sans")))

(defun my-setup-linux-fonts ()
  "Separate setups for fonts in WSL and regular GNU/Linux."
  (if (getenv "WSL_DISTRO_NAME")
      (setq
       my-font-height 200
       my-xxs-font-height 100
       my-xs-font-height 125
       my-small-font-height 150
       my-medium-font-height 250
       my-large-font-height 350
       my-presentation-font-height 650)
    (setq
     my-font-height 200
     my-xxs-font-height 100
     my-xs-font-height 125
     my-small-font-height 150
     my-medium-font-height 250
     my-large-font-height 350
     my-presentation-font-height 650)))

(if (eq system-type 'darwin)
    (setq
     my-font-height 200
     my-xxs-font-height 100
     my-xs-font-height 125
     my-small-font-height 150
     my-medium-font-height 250
     my-large-font-height 350
     my-presentation-font-height 650)

  (my-setup-linux-fonts))

(use-package
 fontaine
 :ensure t
 :init (fontaine-mode 1)
 ;; Persist the latest font preset when closing/starting Emacs and
 ;; while switching between themes.
 :bind (("C-c f" . fontaine-set-preset) ("C-c F" . fontaine-toggle-preset))
 :custom
 (fontaine-latest-state-file
  (locate-user-emacs-file "fontaine-latest-state.eld"))
 (fontaine-presets
  `((xxs :default-height ,my-xxs-font-height)
    (xs :default-height ,my-xs-font-height)
    (small :default-height ,my-small-font-height)
    (regular) ; like this it uses all the fallback values and is named
    ; `regular'
    (medium :default-height ,my-medium-font-height)
    (large :default-height ,my-large-font-height)
    (presentation :default-height ,my-presentation-font-height)
    (t
     ;; I keep all properties for didactic purposes, but most can be omitted.
     ;; See the fontaine manual for the technicalities:
     ;; <https://protesilaos.com/emacs/fontaine>.
     :default-family ,my-default-font
     :default-weight regular
     :default-height ,my-font-height

     :fixed-pitch-family ,my-default-font ; falls back to :default-family
     :fixed-pitch-weight nil ; falls back to :default-weight
     :fixed-pitch-height 1.0 ;,(/ 1 1.1)

     :fixed-pitch-serif-family nil ; falls back to :default-family
     :fixed-pitch-serif-weight nil ; falls back to :default-weight
     :fixed-pitch-serif-height 1.0

     :variable-pitch-family ,my-variable-pitch-font
     :variable-pitch-weight nil
     :variable-pitch-height 1.0 ; 1.1

     :mode-line-active-family nil ; falls back to :default-family
     :mode-line-active-weight nil ; falls back to :default-weight
     :mode-line-active-height 1.0

     :mode-line-inactive-family nil ; falls back to :default-family
     :mode-line-inactive-weight nil ; falls back to :default-weight
     :mode-line-inactive-height 1.0

     :header-line-family nil ; falls back to :default-family
     :header-line-weight nil ; falls back to :default-weight
     :header-line-height 1.0

     :line-number-family nil ; falls back to :default-family
     :line-number-weight nil ; falls back to :default-weight
     :line-number-height 1.0

     :tab-bar-family nil ; falls back to :default-family
     :tab-bar-weight nil ; falls back to :default-weight
     :tab-bar-height 1.0

     :tab-line-family nil ; falls back to :default-family
     :tab-line-weight nil ; falls back to :default-weight
     :tab-line-height 1.0

     :bold-family nil ; use whatever the underlying face has
     :bold-weight nil

     :italic-family nil
     :italic-slant nil

     :line-spacing nil)))

 :config
 ;; Set the last preset or fall back to desired style from `fontaine-presets'
 ;; (the `regular' in this case).
 (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))
 (with-eval-after-load 'pulsar
   (add-hook 'fontaine-set-preset-hook #'pulsar-pulse-line)))

;;;; Show Font (preview fonts)
;; Read the manual: <https://protesilaos.com/emacs/show-font>
(use-package
 show-font
 :ensure t
 :if (display-graphic-p)
 :commands (show-font-select-preview show-font-list show-font-tabulated)
 :config
 ;; These are the defaults, but I keep them here for easier access.
 (setq show-font-pangram 'prot) (setq show-font-character-sample "
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789   !@#$¢%^&*~|
`'\"‘’“”.,;:  ()[]{}—-_+=<>

()[]{}<>«»‹› 6bB8&0ODdoa 1tiIlL|\/
!ij c¢ 5$Ss 7Z2z 9gqp nmMNNMW uvvwWuuw
x×X .,·°;:¡!¿?`'‘’   ÄAÃÀ TODO
")

 (setq show-font-display-buffer-action-alist
       '(display-buffer-full-frame)))

(provide 'tony-emacs-fonts)
