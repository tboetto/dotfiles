(use-package pulsar
:ensure t
:bind
( :map global-map
  ("C-x l" . pulsar-pulse-line) ; overrides `count-lines-page'
  ("C-x L" . pulsar-highlight-permanently-dwim)) ; or use `pulsar-highlight-temporarily-dwim'
:init
(pulsar-global-mode 1)
:config
(setq pulsar-delay 0.055)
(setq pulsar-iterations 5)
(setq pulsar-face 'pulsar-green)
(setq pulsar-region-face 'pulsar-yellow)
(setq pulsar-highlight-face 'pulsar-magenta))

(provide 'tony-emacs-pulsar)
