# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: html-uploads.pl,v 1.1 2004/09/25 18:00:37 as Exp $</p>';

$Action{download} = \&HtmlUploadsDoDownload;

# anybody can download raw html

sub HtmlUploadsDoDownload {
  push(@UploadTypes, 'text/html') unless grep(/^text\/html$/, @UploadTypes);
  return DoDownload(@_);
}

# but only admins can upload raw html

*OldHtmlUploadsDoPost = *DoPost;
*DoPost = *NewHtmlUploadsDoPost;

sub NewHtmlUploadsDoPost {
  my @args = @_;
  if (not grep(/^text\/html$/, @UploadTypes)
      and UserIsAdmin()) {
    push(@UploadTypes, 'text/html');
  }
  return OldHtmlUploadsDoPost(@args);
}
