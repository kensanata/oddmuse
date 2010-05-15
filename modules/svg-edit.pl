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
  return OldSvgGetDownloadLink(@_) if $image != 1;
  # determine if this is SVG data we need to show in an iframe
  my $data;
  local (%Page, $OpenPageName);
  OpenPage($name);
  if ($revision) {
    ($data) = GetTextRevision($revision); # ignore revision reset
  } else {
    $data = $Page{text};
  }
  return OldSvgGetDownloadLink(@_) unless SvgItIs($data);
  my ($width, $height) = SvgDimensions($data);
  # add 20 to compensate for scrollbars?
  return $q->iframe({-width => $width + 20, -height => $height + 20,
		     -src => OldSvgGetDownloadLink($name, 2, $revision)}, "");
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
  my $action = 'action=svg;id=' . UrlEncode($OpenPageName);
  $action .= ";revision=" . GetParam('revision', '')
    if GetParam('revision', '');
  my $link = ScriptLink($action, T('Edit image in the browser'), 'svg');
  my $text1 = T('Replace this file with text');
  my $text2 = T('Replace this text with a file');
  $html =~ s!($text1|$text2)</a>!$1</a> $link!;
  return $html;
}

$Action{svg} = \&DoSvg;

sub DoSvg {
  my $id = shift;
  my $summary = T('Summary of your changes: ');
  $HtmlHeaders .= qq{
<script type="text/javascript">

var keyStr =
    "ABCDEFGHIJKLMNOP" +
    "QRSTUVWXYZabcdef" +
    "ghijklmnopqrstuv" +
    "wxyz0123456789+/" +
    "=";

function encode64(input) {
    var output = "";
    var chr1, chr2, chr3 = "";
    var enc1, enc2, enc3, enc4 = "";
    var i = 0;

    do {
        chr1 = input.charCodeAt(i++);
        chr2 = input.charCodeAt(i++);
        chr3 = input.charCodeAt(i++);

        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;

        if (isNaN(chr2)) {
	    enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
	    enc4 = 64;
        }

        output = output +
	    keyStr.charAt(enc1) +
	    keyStr.charAt(enc2) +
	    keyStr.charAt(enc3) +
	    keyStr.charAt(enc4);
        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";
    } while (i < input.length);

    return output;
}

function oddmuseSaveHandler (window, svg) {
    window.show_save_warning = false;
    var summary = prompt("$summary");
    frames['svgeditor'].jQuery.post('$FullUrl', { title: '$id', raw: 1,
                                                  summary: summary,
                                                  question: 1,
						  text: '#FILE $SvgMimeType\\n'
						  + encode64(svg) } );
}

function oddmuseInit () {
    if (frames['svgeditor'].svgCanvas != null) {
	frames['svgeditor'].svgCanvas.bind("saved", oddmuseSaveHandler);
	var elem = document.getElementsByTagName("div");
	for (i=0; i<elem.length; i++) {
	  if (elem[i].className=="sidebar") {
	    elem[i].style.display='none';
	  }
	}
    } else {
	window.setTimeout("oddmuseInit()", 1000);
    }
}

window.setTimeout("oddmuseInit()", 1000);

</script>
};
  print GetHeader('', Ts('Editing %s', $id));
  # This only works if editor and file are on the same site, I think.
  my $url = GetDownloadLink($id, 2, GetParam('revision', ''));
  my $src = $SvgEditorUrl . '?url=' . UrlEncode($url);
  print $q->iframe({-src => $src,
		    -name => 'svgeditor',
		    -width => "100%",
		    -height => "500"}, "");
  PrintFooter($id, 'edit');
}
