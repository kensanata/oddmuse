# Copyright (C) 2004, 2005  Fletcher T. Penney <fletcher@freeshell.org>
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

$ModulesDescription .= '<p>$Id: slideshow.pl,v 1.2 2005/04/08 21:23:43 fletcherpenney Exp $</p>';

use vars qw($SlideShowDataFolder $SlideShowTheme $SlideShowHeader %SlideShowMeta);

my $InSlide = 0;
my $SlideShowBegun = 0;
my %SlideShowIndex;
my $SlideCounter = 0;

$SlideShowDataFolder = "/s5/v11b3";

$SlideShowHeader = <<'EOT' unless defined $SlideShowHeader;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
EOT

$SlideShowTheme = "i18n" unless defined $SlideShowTheme;

$SlideShowConfiguration = 
qq!<meta name="defaultView" content="slideshow" />
<meta name="controlVis" content="hidden" />

<link rel="stylesheet" href="$SlideShowDataFolder/$SlideShowTheme/slides.css" type="text/css" media="projection" id="slideProj" />
<link rel="stylesheet" href="$SlideShowDataFolder/default/outline.css" type="text/css" media="screen" id="outlineStyle" />
<link rel="stylesheet" href="$SlideShowDataFolder/default/print.css" type="text/css" media="print" id="slidePrint" />
<link rel="stylesheet" href="$SlideShowDataFolder/default/opera.css" type="text/css" media="projection" id="operaFix" />

<script src="$SlideShowDataFolder/default/slides.js" type="text/javascript"></script>!;

%SlideShowMeta = ( generator => "S5",
	version => "S5 1.1b2",
	presdate => "",
	author => "",
	company => "",
	authafill => "",
) unless defined %SlideShowMeta;

my $SlideShowTitle;

$Action{slideshow} = \&DoSlideShow;

sub DoSlideShow {
	my $id = shift;
	print GetSlideShowHeader($id, Ts('Slideshow:%s', $id));
	
	IndexSlideShow($id);
	
	push(@MyRules, \&SlideShowRule);
	*OldPrintWikiToHTML = *PrintWikiToHTML;
	*PrintWikiToHTML = *PrintSlideWikiToHTML;
	$IgnoreForTOC = 1;
	
	OpenPage($id);
	PrintPageHtml();
	print GetSlideShowFooter($id);
}


sub GetSlideShowHeader {
	my ($id, $title, $oldId, $nocache, $status) = @_;
	$title =~ s/_/ /g;
	$SlideShowTitle = $title;
	my $result = GetHttpHeader('text/html', $nocache ? $Now : 0, $status);
#	$result .= GetHtmlHeader($title, $id);
#	$result .= GetSlideShowHtmlHeader($title, $id);
	$result .= $SlideShowHeader;
	return $result;
}

sub GetSlideShowHtmlHeader {
	my ($title, $id) = @_;
	
	$html =  $q->head($q->title($q->escapeHTML($SlideShowTitle)) . "\n" . GetSlideShowMeta($id) . $SlideShowConfiguration);
	$html .= '
<body><div class="layout"><div id="controls"></div><div id="currentSlide"></div>';
	$html .= GetSlideHeader($id) . GetSlideFooter($id) . '</div>'
	. '<div class="presentation">';
	return $html;
}

sub GetSlideShowMeta {
	my ($id) = @_;
	my $html;
	
	foreach my $MetaKey (keys %SlideShowMeta) {
		next if $MetaKey =~ /^(footer[12])$/;
		$html .= qq!<meta name="$MetaKey" content="$SlideShowMeta{$MetaKey}" />\n!;
	}
	return $html;
}

sub GetSlideHeader {
	my ($id) = @_;
	my $html = '<div id="header">';
	
	$html .= '</div>';
	return $html;
}

sub GetSlideFooter {
	my ($id) = @_;
	my $html = '<div id="footer">';
	
	$html .= qq!<h1>$SlideShowMeta{footer1}</h1><h2>$SlideShowMeta{footer2}</h2>!;
	$html .= '</div>';
	return $html;
}

sub GetSlideShowFooter{
	my ($id) = @_;
	my $html = '</div></body></html>';
	
	if ($InSlide) {
		$html = '</div>' . $html;
	}
	return $html;
}


sub SlideShowRule {
# Don't put slide div's in HtmlEnvironment so they don't get closed
	if (m/\G(\s*\n)*\&lt;slide[ \t]+([^\n]*?)([ \t]*class\=([^\n]*?))?\&gt;/icg) {
		my $CloseDiv = "";
		my $class = "slide";
		
		$CloseDiv .= "</div>" if ($InSlide);
		$CloseDiv .= "</div>" if ($InHandout);
		$InSlide = 1;
		$InHandout = 0;
		$class = $4 if ($4 ne "");
		
		if ($SlideShowBegun) {
			return CloseHtmlEnvironments() . $CloseDiv . qq!<div class="$class">! . AddHtmlEnvironment('h1','') . $2 . CloseHtmlEnvironment();
		} else {
			$SlideShowBegun = 1;
			return GetSlideShowHtmlHeader() . $CloseDiv . qq!<div class="slide">! . AddHtmlEnvironment('h1','') . $2 . CloseHtmlEnvironment(); }
	}

	if (m/\G(\s*\n)*\&lt;slidelink\s*(.*?)\=(.*?)\&gt;[\s\t\n]*/icg) {
		return qq!<a href="#slide$SlideShowIndex{$2}">$3</a>!;
	}

	if (m/\G(\s*\n)*\&lt;handout([^\n]*)([ \t]*class\=([^\n]*?))?\&gt;/icg) {
		$InHandout = 1;
		my $class = "handout";
		$class = $4 if ($4 ne "");
		
		return CloseHtmlEnvironments() . qq!<div class="$class">!;
	}

	if (m/\G(\s*\n)*\&lt;image\s*(.*?)\=(.*?)\&gt;[\s\t\n]*/icg) {
		return OpenHtmlEnvironment('div',1,'imagebox') . qq!<img src="$3" alt="$2">!;
	}

	if (m/\G(\s*\n)*\&lt;inc[ \t]*image\s*(.*?)\=(.*?)\&gt;[\s\t\n]*/icg) {
		return OpenHtmlEnvironment('div',1,'imagebox') . qq!<img src="$3" alt="$2" class="incremental">!;
	}

	if (m/\G(\s*\n)*\&lt;meta\s*(.*?)\=(.*?)\&gt;[\s\t\n]*/icg) {
		$SlideShowMeta{$2}=$3;
		return "";
	}

	if ( m/\G(\s*\n)*(inc\*+)[ \t]/cg
		or InElement('li') && m/\G(\s*\n)+(inc\*+)[ \t]/cg) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ul',length($2)-3, 'incremental')
      . AddHtmlEnvironment('li');
  }
	return undef;
}


sub PrintSlideWikiToHTML {
  my ($pageText, $savecache, $revision, $islocked) = @_;
  $FootnoteNumber = 0;
  $pageText =~ s/$FS//g; # Remove separators (paranoia)
  $pageText = QuoteHtml($pageText);
  my ($blocks, $flags) = ApplyRules($pageText, 1, $savecache, $revision); # p is start tag!
  # local links, anchors if cache ok
  if ($savecache and not $revision) {
    $Page{blocks} = $blocks;
    $Page{flags} = $flags;
    if ($islocked or RequestLockDir('main')) { # not fatal!
      SavePage();
      ReleaseLock() unless $islocked;
    }
  }
}

sub IndexSlideShow {
	my ($id) = @_;

	my $page = GetPageContent($id);
	
	while ($page =~ /\<slide[ \t]+([^\n]*)\>/isg ) {
		$SlideShowIndex{$1}=$SlideCounter;
		$SlideCounter++;
	}
}
