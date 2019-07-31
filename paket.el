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
  (compile (apply 'paket-command "install" (transient-args))))

(define-transient-command paket-install ()
  :value '()
  ["Arguments"
   ("-f" "Force" "--force")
   ("-r" "Only Referenced" "--only-referenced")
   ]
  ["Actions"
   ("i" "Install" paket-install-command)]
  (interactive)
  (transient-setup 'paket-install nil nil))


;;;###autoload
(define-transient-command paket-pack-command (output-path)
  (interactive "DOutput Directory: ")
  (compile (apply 'paket-command "pack" output-path (transient-args))))

(define-transient-command paket-pack ()
  :value '()
  ["Options"
   ("=v" "Version" "--version " read-string)
   ]
  ["Actions"
   ("p" "Pack" paket-pack-command)]
  (interactive)
  (transient-setup 'paket-pack nil nil))

(define-transient-command paket ()
  :value '()
  [["Update"
    ("i" "Install" paket-install)]
   ["Release"
    ("p" "Pack" paket-pack)]]
  (interactive)
  (transient-setup 'paket nil nil))

;; (define-suffix-command paket-list-packages ()
;;   :transient nil
;;   (interactive)
;;   )

(provide 'paket)
;;; paket.el ends here
