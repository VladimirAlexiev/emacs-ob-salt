;;; ob-salt.el --- org-babel functions for SALT evaluation

;; Copyright (C) 2010-2012  Free Software Foundation, Inc.

;; Author: Vladimir.Alexiev@ontotext.com
;; Keywords: literate programming, UI mockups
;; Homepage: http://orgmode.org

;; Use and distribute this file freely.

;;; Commentary:
;; Org-Babel support for evaluating SALT, which lets you make UI mockups in ascii 
;; http://plantuml.sourceforge.net/salt.html
;;
;; Stolen shamelessly from ob-plantuml.el by Zhang Weize

;;; Requirements:
;; plantuml     | http://plantuml.sourceforge.net/
;; plantuml.jar | `org-plantuml-jar-path' should point to the jar file

;;; Test:
;; #+begin_src salt :file salt01.png
;; {
;;   Just plain text
;;   [This is my button]
;;   ()  Unchecked radio
;;   (X) Checked radio
;;   []  Unchecked box
;;   [X] Checked box
;;   "Enter text here   "
;;   ^This is a droplist^
;; }
;; #+end_src
;; #+results:
;; file:salt01.png

;;; TODO
;; - merge with ob-plantuml.el for easier maintenance (this file is made by copy & paste)
;; - SALT uses | to make tabular arrangements of controls. Integrate somehow with org-table mode; but SALT has no | at start of line

;;; Code:
(require 'ob)
(require 'ob-eval)

(defvar org-babel-default-header-args:salt
  '((:results . "file") (:exports . "results"))
  "Default arguments for evaluating a salt source block.")

(defcustom org-plantuml-jar-path nil
  "Path to the plantuml.jar file."
  :group 'org-babel
  :version "24.1"
  :type 'string)

(defun org-babel-execute:salt (body params)
  "Execute a block of salt code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((result-params (split-string (or (cdr (assoc :results params)) "")))
	 (out-file (or (cdr (assoc :file params))
		       (error "salt requires a \":file\" header argument")))
	 (cmdline (cdr (assoc :cmdline params)))
	 (in-file (org-babel-temp-file "salt-"))
	 (java (or (cdr (assoc :java params)) ""))
	 (cmd (if (not org-plantuml-jar-path)
		  (error "`org-plantuml-jar-path' is not set")
		(concat "java " java " -jar "
			(shell-quote-argument
			 (expand-file-name org-plantuml-jar-path))
			(if (string= (file-name-extension out-file) "svg")
			    " -tsvg" "")
			(if (string= (file-name-extension out-file) "eps")
			    " -teps" "")
			" -p " cmdline " < "
			(org-babel-process-file-name in-file)
			" > "
			(org-babel-process-file-name out-file)))))
    (unless (file-exists-p org-plantuml-jar-path)
      (error "Could not find plantuml.jar at %s" org-plantuml-jar-path))
    (with-temp-file in-file (insert (concat "@startsalt\n" body "\n@endsalt")))
    (message "%s" cmd) (org-babel-eval cmd "")
    nil)) ;; signal that output has already been written to file

(defun org-babel-prep-session:salt (session params)
  "Return an error because salt does not support sessions."
  (error "Salt does not support sessions"))

(provide 'ob-salt)



;;; ob-salt.el ends here
