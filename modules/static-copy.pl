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

$ModulesDescription .= '<p>$Id: static-copy.pl,v 1.3 2004/08/31 15:05:04 as Exp $</p>';

$Action{static} = \&DoStatic;

use vars qw($StaticDir);

$StaticDir = '/tmp/static';

sub DoStatic {
  return unless UserIsAdminOrError();
  local *ScriptLink = *StaticScriptLink;
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain');
  } else {
    print GetHeader('', T('Static Copy'), '');
  }
  CreateDir($StaticDir);
  foreach my $id (AllPagesList()) {
    print $id, ($raw ? "\n" : $q->br());
    open(F,"> $StaticDir/$id.html") or ReportError(Ts('Cannot write %s', "$StaticDir/$id"));
    print F <<"EOT";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-st\
rict.dtd">
<html>
<head>
<title>$SiteName: $id</title>
<link type="text/css" rel="stylesheet" href="$StyleSheet" />
</head>
<body>
<div class="content">
EOT
    print F PageHtml($id);
    print F << "EOT";
</div>
</body>
</html>
EOT
    close(F);
  }
  print '</p>' unless $raw;
  PrintFooter() unless $raw;
}

sub StaticScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey) = @_;
  my %params;
  if ($action !~ /=/) {
    $params{-href} = $action . ".html";
  }
  $params{'-class'} = $class  if $class;
  $params{'-name'} = UrlEncode($name)  if $name;
  $params{'-title'} = $title  if $title;
  $params{'-accesskey'} = $accesskey  if $accesskey;
  return $q->a(\%params, $text);
}
