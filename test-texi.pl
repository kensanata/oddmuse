#!/usr/bin/perl
# Copyright (C) 2003  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

$ConfigFile = "/home/alex/WWW/emacswiki/cgi-bin/test-texi-config";
$outdir = "/home/alex/WWW/emacswiki/test";
$outname = "emacswiki.texi";
$licensefile = "/home/alex/WWW/emacswiki/fdl.texi";

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(time);
$year += 1900;
$today = "$year-$mon-$mday $hour:$min";

$intro = qq{\input texinfo \@c -*-texinfo-*-
\@c %**start of header
\@setfilename emacswiki.info
\@settitle Emacs Wiki Book
\@documentdescription
The EmacsWiki collects elisp code, questions and answers related to elisp code
and style, introductions to elisp packages and links to their sources, or the
source itself, complete manuals or documentation fragments, comments on Emacs
and XEmacs features, differences and history, ports, jokes, pointers to clones
and emacs-look-alikes, as well as references to other emacs related information
on the web.
\@end documentdescription
\@c %**end of header
\@ifinfo
\@dircategory Emacs
\@direntry
* EmacsWiki: (emacswiki).       Snapshot of http://www.emacswiki.org/
\@end direntry

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.1 or
any later version published by the Free Software Foundation; with no
Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
Texts.  A copy of the license is included in the section entitled "GNU
Free Documentation License".
\@end ifinfo

\@ifnottex
\@node Top, $MainPage, , (dir)
\@top EmacsWiki
The EmacsWiki collects elisp code, questions and answers related to elisp code
and style, introductions to elisp packages and links to their sources, or the
source itself, complete manuals or documentation fragments, comments on Emacs
and XEmacs features, differences and history, ports, jokes, pointers to clones
and emacs-look-alikes, as well as references to other emacs related information
on the web.

If you would like to modify this document, please consider visiting
the EmacsWiki itself at \@uref{http://www.emacswiki.org/} and changing
the original pages.  This document was generated from the original
pages $today.
\@end ifnottex

\@titlepage
\@title EmacsWiki
\@subtitle Dedicated to Emacs and XEmacs
\@subtitle $today
\@author The EmacsWiki Contributors
\@page
\@vskip 0pt plus 1filll
Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.1 or
any later version published by the Free Software Foundation; with no
Invariant Sections, with no Front-Cover Texts, and with no Back-Cover
Texts.  A copy of the license is included in the section entitled "GNU
Free Documentation License".

If you would like to modify this document, please consider visiting
the EmacsWiki itself at \@uref{http://www.emacswiki.org/} and changing
the original pages.  This document was generated from the original
pages $today.
\@end titlepage
};

do 'texi.pl';
