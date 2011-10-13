# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: static-copy.pl,v 1.29 2011/10/13 23:46:21 as Exp $</p>';

$Action{static} = \&DoStatic;

use vars qw($StaticDir $StaticAlways %StaticMimeTypes $StaticUrl);

$StaticDir = '/tmp/static';
$StaticUrl = '';           # change this!
$StaticAlways = 0;         # 1 = uploaded files only, 2 = all pages

my $StaticMimeTypes = '/etc/mime.types';
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
  %StaticFiles = ();
  StaticWriteFiles();
  print '</p>' unless $raw;
  PrintFooter() unless $raw;
}

sub StaticMimeTypes {
  my %hash;
  # the default mapping matches the default @UploadTypes...
  open(F,$StaticMimeTypes)
    or return ('image/jpeg' => 'jpg', 'image/png' => 'png', );
  while (<F>) {
    s/\#.*//;                   # remove comments
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
    # the page might not exist, eg. if called via GetAuthorLink
    $params{-href} = StaticFileName($action) if $IndexHash{$action};
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
  $alt =~ s/_/ /g;
  my $id = FreeToNormal($name);
  # if the page does not exist
  return '[' . ($image ? 'image' : 'link') . ':' . $name . ']' unless $IndexHash{$id};
  if ($image) {
    return StaticFileName($id) if $image == 2;
    my $result = $q->img({-src=>StaticFileName($id), -alt=>$alt, -class=>'upload'});
    $result = ScriptLink($id, $result, 'image');
    return $result;
  } else {
    return ScriptLink($id, $alt, 'upload');
  }
}

sub StaticFileName {
  my $id = shift;
  $id =~ s/#.*//;         # remove named anchors for the filename test
  return $StaticFiles{$id} if $StaticFiles{$id}; # cache filenames
  # Don't clober current open page so don't use OpenPage.  UrlDecode
  # the $id to open the file because when called from
  # StaticScriptLink, for example, the $action is already encoded.
  my ($status, $data) = ReadFile(GetPageFile(UrlDecode($id)));
  # If the link points to a wanted page, we cannot make this static.
  return $id unless $status;
  my %hash = ParseData($data);
  my $ext = '.html';
  if ($hash{text} =~ /^\#FILE ([^ \n]+ ?[^ \n]*)\n(.*)/s) {
    %StaticMimeTypes = StaticMimeTypes() unless %StaticMimeTypes;
    $ext = $StaticMimeTypes{"$1"};
    $ext = '.' . $ext if $ext;
  }
  $StaticFiles{$id} = $id . $ext;
  return $StaticFiles{$id};
}

sub StaticWriteFile {
  my $id = shift;
  my $raw = GetParam('raw', 0);
  my $html = GetParam('html', 1);
  my $filename = StaticFileName($id);
  OpenPage($id);
  my ($mimetype, $encoding, $data) = $Page{text} =~ /^\#FILE ([^ \n]+) ?([^ \n]*)\n(.*)/s;
  return unless $html or $data;
  open(F,"> $StaticDir/$filename") or ReportError(Ts('Cannot write %s', $filename));
  if ($data) {
    StaticFile($id, $mimetype, $data);
  } elsif ($html) {
    StaticHtml($id);
  }
  close(F);
  chmod 0644,"$StaticDir/$filename";
  print $filename, $raw ? "\n" : $q->br();
}

sub StaticFile {
  my ($id, $type, $data) = @_;
  require MIME::Base64;
  binmode(F);
  print F MIME::Base64::decode($data);
}

sub StaticHtml {
  my $id = shift; # assume open page
  # redirect
  if (($FreeLinks and $Page{text} =~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\]\]/)
      or ($WikiLinks and $Page{text} =~ /^\#REDIRECT\s+$LinkPattern/)) {
    my $target = StaticFileName($1);
    print F <<"EOT";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>$SiteName: $id</title>
<link type="text/css" rel="stylesheet" href="static.css" />
<meta http-equiv="refresh" content="0; url=$target">
<meta http-equiv="content-type" content="text/html; charset=$HttpCharset">
</head>
<body>
<p>Redirected to <a href="$target">$1</a>.</p>
</body>
</html>
EOT
    return;
  }
  print F <<"EOT";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
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
    $logo =~ s|.*/||;           # just the filename
    my $alt = T('[Home]');
    $header .= $q->img({-src=>$logo, -alt=>$alt, -class=>'logo'}) if $logo;
  }
  # top toolbar
  local $UserGotoBar = '';      # only allow @UserGotoBarPages
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
  my $links = '';
  if ($OpenPageName !~ /^$CommentsPrefix/) { # fails if $CommentsPrefix is empty!
    $links .= ScriptLink(UrlEncode($CommentsPrefix . $OpenPageName),
                         T('Comments on this page'));
  }
  if ($CommentsPrefix and $id =~ /^$CommentsPrefix(.*)/) {
    $links .= ' | ' if $links;
    $links .= Ts('Back to %s', GetPageLink($1, $1));
  }
  $links = $q->br() . $links if $links;
  print F $q->div({-class=>'footer'}, $q->hr(), $toolbar,
                  $q->span({-class=>'edit'}, $links),
                  $q->span({-class=>'time'}, GetFooterTimestamp($id)));
  # finish
  print F '</body></html>';
}

*StaticFilesOldSave = *Save;
*Save = *StaticFilesNewSave;

sub StaticFilesNewSave {
  my ($id, $new) = @_;
  StaticFilesOldSave(@_);
  if ($StaticAlways) {
    # always delete
    StaticDeleteFile($id);
    if ($new =~ /^\#FILE / # if a file was uploaded
        or $StaticAlways > 1) {
      CreateDir($StaticDir);
      StaticWriteFile($OpenPageName);
    }
  }
}

*StaticOldDeletePage = *DeletePage;
*DeletePage = *StaticNewDeletePage;

sub StaticNewDeletePage {
  my $id = shift;
  StaticDeleteFile($id) if ($StaticAlways);
  return StaticOldDeletePage($id);
}

sub StaticDeleteFile {
  my $id = shift;
  %StaticMimeTypes = StaticMimeTypes() unless %StaticMimeTypes;
  # we don't care if the files or $StaticDir don't exist -- just delete!
  for my $f (map { "$StaticDir/$id.$_" } (values %StaticMimeTypes, 'html')) {
    unlink $f;               # delete copies with different extensions
  }
}

# override the default!
sub GetDownloadLink {
  my ($name, $image, $revision, $alt) = @_;
  $alt = $name unless $alt;
  my $id = FreeToNormal($name);
  AllPagesList();
  # if the page does not exist
  return '[' . ($image ? T('image') : T('download')) . ':' . $name
    . ']' . GetEditLink($id, '?', 1) unless $IndexHash{$id};
  my $action;
  if ($revision) {
    $action = "action=download;id=" . UrlEncode($id) . ";revision=$revision";
  } elsif ($UsePathInfo) {
    $action = "download/" . UrlEncode($id);
  } else {
    $action = "action=download;id=" . UrlEncode($id);
  }
  if ($image) {
    if ($UsePathInfo and not $revision) {
      if ($StaticAlways and $StaticUrl) {
        my $url = $StaticUrl;
        my $img = UrlEncode(StaticFileName($id));
        $url =~ s/\%s/$img/g or $url .= $img;
        $action = $url;
      } else {
        $action = $ScriptName . '/' . $action;
      }
    } else {
      $action = $ScriptName . '?' . $action;
    }
    return $action if $image == 2;
    my $result = $q->img({-src=>$action, -alt=>$alt, -class=>'upload'});
    $result = ScriptLink(UrlEncode($id), $result, 'image') unless $id eq $OpenPageName;
    return $result;
  } else {
    return ScriptLink($action, $alt, 'upload');
  }
}

# override function from Image Extension to support advanced image tags
sub ImageGetInternalUrl {
  my $id = FreeToNormal(shift);
  if ($UsePathInfo) {
    if ($StaticAlways and $StaticUrl) {
      my $url = $StaticUrl;
      my $img = UrlEncode(StaticFileName($id));
      $url =~ s/\%s/$img/g or $url .= $img;
      return $url;
    } else {
      return $ScriptName . '/download/' . UrlEncode($id);
    }
  }
  return $ScriptName . '?action=download;id=' . UrlEncode($id);
}
