(add-to-list 'vc-handled-backends 'oddmuse)

(defun vc-oddmuse-revision-granularity () 'file)

(defun vc-oddmuse-registered (file)
  "Handle files in `oddmuse-directory'."
  (string-match (concat "^" (expand-file-name oddmuse-directory))
		(file-name-directory file)))

(defun vc-oddmuse-state (file)
  "No idea."
  'up-to-date)

(defun vc-oddmuse-working-revision (file)
  "No idea")

(defun vc-oddmuse-checkout-model (files)
  "No locking."
  'implicit)

(defun vc-oddmuse-create-repo (file)
  (error "You cannot create Oddmuse wikis using Emacs."))

(defun vc-oddmuse-register (files &optional rev comment)
  "This always works.")

(defun vc-oddmuse-revert (file &optional contents-done)
  "No idea"
  nil)

(defvar vc-oddmuse-log-command
  "curl --silent %w\"?action=rc;showedit=1;all=1;from=1;raw=1;match=%r\""
  "Command to use for publishing index pages.
It must print the page to stdout.

%?  '?' character
%w  URL of the wiki as provided by `oddmuse-wikis'
%r  Regular expression, URL encoded, of the pages to limit ourselves to.
    This uses the free variable `regexp'.")

(defun vc-oddmuse-print-log (files buffer &optional shortlog
				   start-revision limit)
  "Load complete recent changes for the files."
  (let* ((wiki (or oddmuse-wiki
		   (completing-read "Wiki: " oddmuse-wikis nil t)))
	 (wiki-data (assoc wiki oddmuse-wikis))
	 (url (nth 1 wiki-data))
	 (regexp (concat
		  "^("  ;; Perl regular expression!
		  (mapconcat 'file-name-nondirectory files "|")
		  ")$"))
	 (command (oddmuse-format-command vc-oddmuse-log-command))
	 (coding (nth 2 wiki-data))
	 (coding-system-for-read coding)
	 (coding-system-for-write coding)
	 (max-mini-window-height 1))
    (oddmuse-run "Load recent changes" command buffer nil))
  ;; Parse current buffer as RSS 3.0 and display it correctly.
  (save-excursion
    (with-current-buffer buffer
      (let (result)
	(dolist (item (cdr (split-string (buffer-string) "\n\n")));; skip first item
	  (let ((data (mapcar (lambda (line)
				(when (string-match "^\\(.*?\\): \\(.*\\)" line)
				  (cons (match-string 1 line)
					(match-string 2 line))))
			      (split-string item "\n"))))
	    (setq result (cons data result))))
	(dolist (item (nreverse result))
	  (insert "title:      " (cdr (assoc "title" item)) "\n"
	          "version:    " (cdr (assoc "revision" item)) "\n"
	          "generator:  " (cdr (assoc "generator" item)) "\n"
	          "timestamp:  " (cdr (assoc "last-modified" item)) "\n\n"
		  "    " (or (cdr (assoc "description" item)) ""))
	  (fill-paragraph)
	  (insert "\n\n"))
	(goto-char (point-min))))))

(defun vc-oddmuse-log-outgoing ()
  (error "This is not supported."))

(defun vc-oddmuse-log-incoming ()
  (error "This is not supported."))

(defun vc-oddmuse-diff ()
  "No idea"
  nil)

(provide 'vc-oddmuse)
