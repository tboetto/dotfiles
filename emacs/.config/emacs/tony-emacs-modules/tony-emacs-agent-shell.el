;; Claude daily cost tracking for mode-line.
;; Updated after each agent turn via ccusage.
(defvar tony--claude-daily-cost-string nil
  "Today's cumulative Claude cost string, e.g. \" $1.33/d\".")

(defvar tony--claude-cost-output ""
  "Accumulated stdout from the ccusage subprocess.")

(defun tony--claude-cost-refresh ()
  "Asynchronously query ccusage and update `tony--claude-daily-cost-string'."
  (setq tony--claude-cost-output "")
  (let ((proc (start-process "tony-claude-cost" nil
                             "npx" "ccusage" "daily" "--json" "--no-color")))
    (set-process-filter proc
                        (lambda (_p out)
                          (setq tony--claude-cost-output
                                (concat tony--claude-cost-output out))))
    (set-process-sentinel proc
                          (lambda (_p event)
                            (when (string-prefix-p "finished" event)
                              (condition-case nil
                                  (let* ((json-array-type 'list)
                                         (json-object-type 'alist)
                                         (data (json-read-from-string
                                                tony--claude-cost-output))
                                         (daily (alist-get 'daily data))
                                         (today (format-time-string "%Y-%m-%d"))
                                         (entry (seq-find
                                                 (lambda (e)
                                                   (equal (alist-get 'period e) today))
                                                 daily))
                                         (cost (if entry
                                                   (float (alist-get 'totalCost entry))
                                                 0.0)))
                                    (setq tony--claude-daily-cost-string
                                          (format " $%.2f/d" cost))
                                    (force-mode-line-update t))
                                (error nil)))))))

;; Show today's cost in the global mode-line.
(add-to-list 'global-mode-string
             '(:eval tony--claude-daily-cost-string) t)

(use-package shell-maker :ensure t)

(use-package acp :ensure t :after shell-maker)

(use-package agent-shell
  :ensure (:host github :repo "xenodium/agent-shell")
  :after (shell-maker acp)
  :bind
  (("C-c a a" . agent-shell)
   ("C-c a c" . agent-shell-anthropic-start-claude-code)
   ("C-c a u" . agent-shell-cursor-start-agent))
  :config
  ;; Inherit the current Emacs process environment so the claude binary
  ;; in PATH (and nvm, etc.) is visible to the agent subprocess
  (setq agent-shell-session-restore-verbosity 'full)
  (setq agent-shell-markdown-render-function #'agent-shell-markdown-replace-markup)
  (setq agent-shell-highlight-blocks t)
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables
         :inherit-env t))
  ;; Inherit env for cursor-agent-acp so the cursor binary is visible
  (setq agent-shell-cursor-environment
        (agent-shell-make-environment-variables
         :inherit-env t))
  (setq agent-shell-session-strategy 'prompt)
  ;; Show per-turn token/cost breakdown inline after each response, expanded by default.
  (setq agent-shell-show-usage-at-turn-end t)
  (advice-add 'agent-shell--update-fragment :around
              (lambda (orig-fn &rest args)
                (if (string-suffix-p "-usage" (or (plist-get args :block-id) ""))
                    (apply orig-fn (plist-put (copy-sequence args) :expanded t))
                  (apply orig-fn args))))
  :hook
  ;; After each agent turn, refresh the cumulative daily cost in the mode-line.
  (agent-shell-mode . (lambda ()
                        (agent-shell-subscribe-to
                         :shell-buffer (current-buffer)
                         :event 'turn-complete
                         :on-event (lambda (_event)
                                     (tony--claude-cost-refresh))))))

(provide 'tony-emacs-agent-shell)
