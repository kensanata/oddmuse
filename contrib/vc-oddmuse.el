;;; vc-oddmuse.el -- add VC support to oddmuse-curl
;; 
;; Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
;; 
;; Latest version:
;;   http://git.savannah.gnu.org/cgit/oddmuse.git/plain/contrib/vc-oddmuse.el
;; Discussion, feedback:
;;   http://www.emacswiki.org/cgi-bin/wiki/OddmuseCurl
;; 
;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option)
;; any later version.
;; 
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;; 
;; You should have received a copy of the GNU General Public License along
;; with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Add the following to your init file:
;;
;; (add-to-list 'vc-handled-backends 'oddmuse)

(add-to-list 'vc-handled-backends 'oddmuse)

(require 'oddmuse)
(require 'diff)

(defun vc-oddmuse-revision-granularity () 'file)

(defun vc-oddmuse-registered (file)
  "Handle files in `oddmuse-directory'."
  (string-match (concat "^" (expand-file-name oddmuse-directory))
		(file-name-directory file)))

(defun vc-oddmuse-state (file)
  "Return the current version control state of FILE.
For a list of possible values, see `vc-state'."
  ;; Avoid downloading the current version from the wiki and comparing
  ;; the text: Too much traffic!
  'edited)

(defun vc-oddmuse-working-revision (file)
  "The current revision based on `oddmuse-revisions'."
  (oddmuse-revision-get oddmuse-wiki oddmuse-page-name))

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
	 (coding-system-for-write coding))
    (oddmuse-run "Getting recent changes" command buffer nil))
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

(defvar vc-oddmuse-get-revision-command
  "curl --silent %w\"?action=browse;id=%t;revision=%o;raw=1\""
  "Command to use to get older revisions of a page.
It must print the page to stdout.

%?  '?' character
%w  URL of the wiki as provided by `oddmuse-wikis'
%t  Page title as provided by `oddmuse-page-name'
%o  Revision to retrieve as provided by `oddmuse-revision'")

(defun oddmuse-revision-filename (rev)
  "Return filename for revision REV.
This uses `oddmuse-directory', `oddmuse-wiki' and
`oddmuse-page-name'."
  (concat oddmuse-directory
	  "/" oddmuse-wiki
	  "/" oddmuse-page-name
	  ".~" rev "~"))

(defun vc-oddmuse-diff (files &optional rev1 rev2 buffer)
  "Report the differences for FILES."
  (setq buffer (or buffer (get-buffer-create "*vc-diff*")))
  (dolist (file files)
    (with-oddmuse-file file
      (setq rev1 (or rev1 (oddmuse-get-latest-revision)))
      (dolist (rev (list rev1 rev2))
	(when (and rev (not (file-readable-p (oddmuse-revision-filename rev))))
	  (let* ((oddmuse-revision rev)
		 (command (oddmuse-format-command vc-oddmuse-get-revision-command))
		 (filename (oddmuse-revision-filename rev)))
	    (with-temp-buffer
	      (oddmuse-run (concat "Downloading revision " rev) command)
	      (write-file filename)))))
      (diff-no-select
       (if rev1 (oddmuse-revision-filename rev1) file)
       (if rev2 (oddmuse-revision-filename rev2) file)
       nil
       (vc-switches 'oddmuse 'diff)
       buffer))))

(defun vc-oddmuse-revert (file &optional contents-done)
  "Revert FILE back to the wiki revision.
If optional arg CONTENTS-DONE is non-nil, then nothing needs to
be done, as the contents of FILE have already been reverted from
a version backup."
  (unless contents-done
    (with-oddmuse-file file
      (let ((command (oddmuse-format-command vc-oddmuse-get-revision-command)))
	(with-temp-buffer
	  (oddmuse-run "Loading" command)
	  (write-file file))))))

(defun vc-oddmuse-checkin (files rev comment)
  "Commit changes in FILES to this backend.
REV is a historical artifact and should be ignored.  COMMENT is
used as a check-in comment."
  (dolist (file files)
    (with-oddmuse-file file
      (let* ((summary comment)
	     (command (oddmuse-format-command oddmuse-post-command))
	     (buf (get-buffer-create " *oddmuse-response*")))
	(with-temp-buffer
	  (insert-file-contents file)
	  (oddmuse-run "Posting" command buf t 302))))))

(provide 'vc-oddmuse)
