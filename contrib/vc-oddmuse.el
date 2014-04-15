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

(defvar vc-oddmuse-get-history-command
  "curl --silent %w\"?action=history;id=%t;raw=1\""
  "Command to use to get the history of a page.
It must print the page to stdout.

%?  '?' character
%w  URL of the wiki as provided by `oddmuse-wikis'
%t  Page title as provided by `oddmuse-page-name'")

(defun vc-oddmuse-diff (files &optional rev1 rev2 buffer)
  "Report the differences for FILES."
  (setq buffer (or buffer (get-buffer-create "*vc-diff*")))
  (dolist (file files)
    (setq oddmuse-page-name (file-name-nondirectory file)
	  oddmuse-wiki (or oddmuse-wiki
			   (file-name-nondirectory
			    (directory-file-name
			     (file-name-directory file)))))
    (let* ((wiki-data (or (assoc oddmuse-wiki oddmuse-wikis)
			  (error "Cannot find data for wiki %s" oddmuse-wiki)))
	   (url (nth 1 wiki-data)))
      (unless rev1
	;; Since we don't know the most recent revision we have to fetch
	;; it from the server every time.
	(with-temp-buffer
	  (let ((max-mini-window-height 1))
	    (oddmuse-run "Determining latest revision"
			 (oddmuse-format-command vc-oddmuse-get-history-command)
			 (current-buffer) nil))
	  (if (re-search-forward "^revision: \\([0-9]+\\)$" nil t)
	      (setq rev1 (match-string 1))
	    (error "Cannot determine the latest revision from the page history"))))
      (dolist (rev (list rev1 rev2))
	(when (and rev
		   (not (file-readable-p (concat oddmuse-directory
						 "/" oddmuse-wiki "/"
						 oddmuse-page-name
						 ".~" rev "~"))))
	  (let* ((oddmuse-revision rev)
		 (command (oddmuse-format-command vc-oddmuse-get-revision-command))
		 (coding (nth 2 wiki-data))
		 (filename (concat oddmuse-directory "/" oddmuse-wiki "/"
				   oddmuse-page-name ".~" rev "~"))
		 (coding-system-for-read coding)
		 (coding-system-for-write coding))
	    (with-temp-buffer
	      (let ((max-mini-window-height 1))
		(oddmuse-run (concat "Downloading revision " rev)
			     command (current-buffer) nil))
	      (write-file filename)))))
      (diff-no-select
       (if rev1
	   (concat oddmuse-directory "/" oddmuse-wiki "/" oddmuse-page-name ".~" rev1 "~")
	 file)
       (if rev2
	   (concat oddmuse-directory "/" oddmuse-wiki "/" oddmuse-page-name ".~" rev2 "~")
	 file)
       nil
       (vc-switches 'oddmuse 'diff)
       buffer))))

(provide 'vc-oddmuse)
