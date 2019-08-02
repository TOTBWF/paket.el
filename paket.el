;;; paket.el --- description -*- lexical-binding: t; -*-

;;; Code:

(require 'transient)
(require 'projectile)

(defun paket-command (command &rest args)
  "Find the paket command in the project root."
  (let* ((search-path (list (concat (projectile-project-root) ".paket")))
         (paket-cmd (or
                     (locate-file "paket" search-path)
                     (if-let ((paket-exe (locate-file "paket.exe" search-path))) (concat "mono " paket-exe))
                     )))
    (s-join " " (append (list paket-cmd command) args))))

(define-suffix-command paket-install-command ()
  :transient nil
  (interactive)
  (compile (apply 'paket-command "install" (transient-args 'paket-install))))

(define-infix-argument paket:--preserve-level ()
  :description "Preserve"
  :class 'transient-option
  :key "-p"
  :argument "--keep-"
  :choices '("major" "minor" "patch")
  )

(define-transient-command paket-install ()
  :value '()
  ["Arguments"
   ("-f" "Force" "--force")
   ("-r" "Only Referenced" "--only-referenced")
   ]
  ["Options"
   ("=p" paket:--preserve-level)
   ]
  ["Actions"
   ("i" "Install" paket-install-command)]
  (interactive)
  (transient-setup 'paket-install nil nil))

(define-suffix-command paket-pack-command (output-path)
  (interactive "DOutput Directory: ")
  (compile (apply 'paket-command "pack" output-path (transient-args 'paket-pack))))

(define-transient-command paket-pack ()
  :value '()
  ["Options"
   ("=v" "Version" "--version " read-string)
   ]
  ["Actions"
   ("p" "Pack" paket-pack-command)])

(define-suffix-command paket-restore-command ()
  (interactive)
  (compile (apply 'paket-command "restore" (transient-args 'paket-restore))))

(define-transient-command paket-restore ()
  :value '()
  ["Arguments"
   ("-f" "Force" "--force")
   ("-r" "Only Referenced" "--only-referenced")
   ]
  ["Actions"
   ("r" "Restore" paket-restore-command)
   ])

(defun paket--list-packages ()
    (with-temp-buffer
      (insert (shell-command-to-string (paket-command "show-installed-packages")))
      (goto-char (point-min))
      ))

(defvar paket-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-i") 'paket-install)
    (define-key map (kbd "C-c C-p") 'paket-pack)
    (define-key map (kbd "C-c C-r") 'paket-restore)
    map))

(defvar paket-keywords
  '(("^[[:blank:]]*\\(nuget\\|source\\|version\\|group\\)" (1 font-lock-keyword-face))))

(add-to-list 'auto-mode-alist '("paket.dependencies" . paket-mode))

(define-derived-mode paket-mode prog-mode "Paket"
  "Major mode for editing paket files"
  (use-local-map paket-mode-map)
  (setq font-lock-defaults '(paket-keywords)))

(provide 'paket)
;;; paket.el ends here
