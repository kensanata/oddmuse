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

(require 'oddmuse-curl)
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
  (concat "curl --silent %w"
	  " --form action=rc"
	  " --form showedit=1"
	  " --form all=1"
	  " --form from=1"
	  " --form raw=1"
	  " --form match='%r'")
  "Command to use for publishing index pages.
It must print the page to stdout.

See `oddmuse-format-command' for the formatting options.")

(defun vc-oddmuse-print-log (files buffer &optional shortlog start-revision limit)
  "Load complete recent changes for the files."
  ;; Derive `oddmuse-wiki' from the first file
  (with-oddmuse-file (car files)
    ;; The wiki expects a Perl regular expression!
    (let ((regexp (concat "^(" (mapconcat 'file-name-nondirectory files "|") ")$")))
      (oddmuse-run "Getting recent changes" vc-oddmuse-log-command nil nil buffer)))
  (with-current-buffer buffer
    (oddmuse-render-rss3))
  'limit-unsupported)

(defun vc-oddmuse-log-outgoing ()
  (error "This is not supported."))

(defun vc-oddmuse-log-incoming ()
  (error "This is not supported."))

(defvar vc-oddmuse-get-revision-command
  (concat "curl --silent"
	  " --form action=browse"
	  " --form id=%t"
	  " --form revision=%v"
	  " --form raw=1"
	  " '%w'")
  "Command to use to get older revisions of a page.
It must print the page to stdout.

%?  '?' character
%w  URL of the wiki as provided by `oddmuse-wikis'
%t  Page title as provided by `oddmuse-page-name'
%v  Revision to retrieve as provided by `oddmuse-revision'")

(defun oddmuse-revision-filename (rev)
  "Return filename for revision REV.
This uses `oddmuse-directory', `wiki' and `pagename' as bound by
`with-oddmuse-file'."
  (concat oddmuse-directory
	  "/" wiki
	  "/" pagename
	  ".~" rev "~"))

(defun vc-oddmuse-diff (files &optional rev1 rev2 buffer)
  "Report the differences for FILES."
  (setq buffer (or buffer (get-buffer-create "*vc-diff*")))
  (dolist (file files)
    (with-oddmuse-file file
      (setq rev1 (or rev1 (oddmuse-get-latest-revision wiki pagename)))
      (dolist (rev (list rev1 rev2))
	(when (and rev (not (file-readable-p (oddmuse-revision-filename rev))))
	  (let* ((oddmuse-revision rev)
		 (command vc-oddmuse-get-revision-command)
		 (filename (oddmuse-revision-filename rev)))
	    (with-temp-buffer
	      (oddmuse-run
	       (concat "Downloading revision " rev)
	       command wiki pagename)
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
	  (oddmuse-run "Posting" command wiki pagename buf t 302))))))

(provide 'vc-oddmuse)
