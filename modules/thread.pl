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

$ModulesDescription .= '<p>$Id: thread.pl,v 1.1 2004/03/14 13:00:11 as Exp $</p>';

$Action{getthread} = &ThreadGet;
$Action{addthread} = &ThreadAdd;

sub ThreadGet {
  my $id = shift;
  my $thread = ThreadExtract($id);
  print GetHtmlHeader(T('Thread: %s', $id), '');
  ApplyRules($thread);
  print $q->end_html;
}

sub ThreadAdd {
  my $id = shift;
  ReportError(T('ID parameter is missing.'), '400 BAD REQUEST') unless $id;
  my $url = GetParam('url', '');
  ReportError(T('URL parameter is missing.'), '400 BAD REQUEST') unless $url;
  my $parent = GetParam('parent', '');
}

sub ThreadExtract {
  my $id = shift;
  ReportError(T('ID parameter is missing.'), '400 BAD REQUEST') unless $id;
  $page = GetPageContent($id);
  ReportError(Ts('Thread %s does not exist.', $id), '404 NOT FOUND') unless $page;
  # ignore all the stuff that gets processed anyway
  foreach my $tag ('nowiki', 'pre', 'code') {
    $page =~ s|<$tag>(.*\n)*?</$tag>||gi;
  }
  ReportError(Ts('Thread %s does not contain a thread.', $id), '404 NOT FOUND')
    unless $page =~ m/(^|\n)(\*(.*\n)+)/;
  return $1;
}
