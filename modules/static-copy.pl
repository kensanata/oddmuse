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

$ModulesDescription .= '<p>$Id: static-copy.pl,v 1.8 2004/10/13 18:30:42 as Exp $</p>';

$Action{static} = \&DoStatic;

use vars qw($StaticDir $StaticMimeTypes);

$StaticDir = '/tmp/static';
$StaticMimeTypes = '/etc/mime.types';

my %StaticMimeTypes;
my %StaticFiles;

sub DoStatic {
  return unless UserIsAdminOrError();
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain');
  } else {
    print GetHeader('', T('Static Copy'), '');
  }
  CreateDir($StaticDir);
  %StaticMimeTypes = StaticMimeTypes() unless %StaticMimeTypes;
  %StaticFiles = ();
  StaticWriteFiles();
  print '</p>' unless $raw;
  PrintFooter() unless $raw;
}

sub StaticMimeTypes {
  my %hash;
  # the default mapping matches the default @UploadTypes...
  open(F,$StaticMimeTypes) or return ('image/jpeg' => 'jpg', 'image/png' => 'png', );
  while (<F>) {
    s/\#.*//; # remove comments
    my($type, $ext) = split;
    $hash{$type} = $ext if $ext;
  }
  close(F);
  return %hash;
}

sub StaticWriteFiles {
  my $raw = GetParam('raw', 0);
  local *ScriptLink = *StaticScriptLink;
  local *GetDownloadLink = *StaticGetDownloadLink;
  foreach my $id (AllPagesList()) {
    StaticWriteFile($id);
  }
}

sub StaticScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey) = @_;
  my %params;
  if ($action !~ /=/) {
    $params{-href} = StaticFileName($action);
  }
  $params{'-class'} = $class  if $class;
  $params{'-name'} = UrlEncode($name)  if $name;
  $params{'-title'} = $title  if $title;
  $params{'-accesskey'} = $accesskey  if $accesskey;
  return $q->a(\%params, $text);
}

sub StaticGetDownloadLink {
  my ($name, $image, $revision, $alt) = @_; # ignore $revision
  $alt = $name unless $alt;
  my $id = FreeToNormal($name);
  AllPagesList();
  # if the page does not exist
  return '[' . ($image ? 'image' : 'link') . ':' . $name . ']' unless $IndexHash{$id};
  if ($image) {
    my $result = $q->img({-src=>StaticFileName($id), -alt=>$alt, -class=>'upload'});
    $result = ScriptLink($id, $result, 'image');
    return $result;
  } else {
    return ScriptLink($id, $alt, 'upload');
  }
}

sub StaticFileName {
  my $id = shift;
  $id =~ s/#.*//; # remove named anchors for the filename test
  return $StaticFiles{$id} if $StaticFiles{$id}; # cache filenames
  # Don't clober current open page so don't use OpenPage.  UrlDecode
  # the $id to open the file because when called from
  # StaticScriptLink, for example, the $action is already encoded.
  my ($status, $data) = ReadFile(GetPageFile(StaticUrlDecode($id)));
  print "cannot read " . GetPageFile(StaticUrlDecode($id)) . $q->br() unless $status;
  my %hash = ParseData($data);
  my $ext = '.html';
  if ($hash{text} =~ /#FILE ([^ \n]+)\n(.*)/s) {
    $ext = $StaticMimeTypes{$1};
    $ext = '.' . $ext if $ext;
  }
  $StaticFiles{$id} = $id . $ext;
  return $StaticFiles{$id};
}

sub StaticUrlDecode {
  my $str = shift;
  $str =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/ge;
  return $str;
}

sub StaticWriteFile {
  my $id = shift;
  my $raw = GetParam('raw', 0);
  my $filename = StaticFileName($id);
  OpenPage($id);
  open(F,"> $StaticDir/$filename") or ReportError(Ts('Cannot write %s', $filename));
  if ($Page{text} =~ /#FILE ([^ \n]+)\n(.*)/s) {
    StaticFile($id, $1, $2);
  } else {
    StaticHtml($id);
  }
  close(F);
  print $filename, $raw ? "\n" : $q->br();
}

sub StaticFile {
  my ($id, $type, $data) = @_;
  require MIME::Base64;
  binmode(F);
  print F MIME::Base64::decode($data);
}

sub StaticHtml {
  my $id = shift;
  print F <<"EOT";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-st\
rict.dtd">
<html>
<head>
<title>$SiteName: $id</title>
<link type="text/css" rel="stylesheet" href="static.css" />
<meta http-equiv="content-type" content="text/html; charset=$HttpCharset">
</head>
<body>
EOT
  my $header = '';
  # logo
  if ($LogoUrl) {
    my $logo = $LogoUrl;
    $logo =~ s|.*/||; # just the filename
    my $alt = T('[Home]');
    $header .= $q->img({-src=>$logo, -alt=>$alt, -class=>'logo'}) if $logo;
  }
  # top toolbar
  local $UserGotoBar = ''; # only allow @UserGotoBarPages
  my $toolbar = GetGotoBar($id);
  $header .= $toolbar if GetParam('toplinkbar', $TopLinkBar);
  # title
  my $name = $id;
  $name =~ s|_| |g;
  $header .= $q->h1($name);
  print F $q->div({-class=>'header'}, $header);
  # sidebar, if the module is loaded
  print F $q->div({-class=>'sidebar'}, PageHtml($SidebarName)) if $SidebarName;
  # content
  print F $q->div({-class=>'content'}, PageHtml($id)); # this reopens the page currently open
  # footer
  print F $q->div({-class=>'footer'}, $q->hr(), $toolbar,
		  $q->span({-class=>'time'}, GetFooterTimestamp($id)));
  # finish
  print F '</body></html>';
}
