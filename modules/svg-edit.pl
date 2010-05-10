# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use vars qw($SvgMimeType $SvgEditorUrl);

$SvgMimeType  = 'image/svg+xml';
$SvgEditorUrl = 'http://svg-edit.googlecode.com/svn/tags/stable/editor/svg-editor.html';

push (@MyInitVariables, \&SvgInitVariables);

sub SvgInitVariables {
  $UploadAllowed = 1;
  push (@UploadTypes, $SvgMimeType)
    unless grep {$_ eq $SvgMimeType} @UploadTypes;
}

*OldSvgGetDownloadLink = *GetDownloadLink;
*GetDownloadLink = *NewSvgGetDownloadLink;

sub NewSvgGetDownloadLink {
  my ($name, $image, $revision, $alt) = @_;
  return OldSvgGetDownloadLink(@_) if $name ne $OpenPageName;
  return OldSvgGetDownloadLink(@_) if $image != 1;
  my $data = $Page{text};
  return OldSvgGetDownloadLink(@_) unless SvgItIs($data);
  my ($width, $height) = SvgDimensions($data);
  # add 20 to compensate for scrollbars?
  return $q->iframe({-width => $width + 20, -height => $height + 20,
		     -src => OldSvgGetDownloadLink($name, 2)}, "");
}

sub SvgItIs {
  my ($type) = TextIsFile(shift);
  return $type eq $SvgMimeType;
}

sub SvgDimensions {
  my $data = shift;
  $data =~ s/.*\n//; # strip first line
  require MIME::Base64;
  $data = MIME::Base64::decode($data);
  # crude hack to avoid parsing the SVG XML
  my ($x) = $data =~ /width="(.*?)"/;
  my ($y) = $data =~ /height="(.*?)"/;
  return $x, $y;
}

*OldSvgGetEditForm = *GetEditForm;
*GetEditForm = *NewSvgGetEditForm;

sub NewSvgGetEditForm {
  my $html = OldSvgGetEditForm(@_);
  my $link = ScriptLink('action=svg;id=' . UrlEncode($OpenPageName),
			T('Edit image in the browser'),
			'svg');
  my $text1 = T('Replace this file with text');
  my $text2 = T('Replace this text with a file');
  $html =~ s!($text1|$text2)</a>!$1</a> $link!;
  return $html;
}

$Action{svg} = \&DoSvg;

sub DoSvg {
  my $id = shift;
  print GetHeader('', Ts('Editing %s', $id));
  print $q->iframe({-src => "$SvgEditorUrl?url=" . OldSvgGetDownloadLink($id, 2),
		    -width => "100%", -height => "500"}, "");
  PrintFooter($id, 'edit');
}
