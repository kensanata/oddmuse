# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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


#	Original MarkdownRule by Alex Schroeder
#	Remainder by Fletcher Penney

#	NOTE:
#	In order to enable WikiWords and [[Free Links]] within OddMuse,
# 	you must insert the following lines (uncommented of course)
#	near the top of the markdown source (called markdown.pl)
#	Until I figure out how to do this from within this file, anyways...

#	*_RunSpanGamut = *OddMuse::NewRunSpanGamut;
#	*_DoHeaders = *OddMuse::NewDoHeaders;
#	*_EncodeCode = *OddMuse::NewEncodeCode;

#	To enable other features, I suggest you also check out:
#	MultiMarkdown <http://fletcher.freeshell.org/wiki/MultiMarkdown>


$ModulesDescription .= '<p>$Id: markdown.pl,v 1.4 2005/08/02 23:20:00 fletcherpenney Exp $</p>';

@MyRules = (\&MarkdownRule);

$RuleOrder{\&MarkdownRule} = -10;

$TempNoWikiWords = 0;

sub MarkdownRule {
  if (pos == 0) {
    my $pos = length($_); # fake matching entire file
    my $source = $_;
    # fake that we're blosxom!
    $blosxom::version = 1;
    require "$ModuleDir/Markdown/markdown.pl";
    # Set the base url for local links
    $Markdown::g_metadata{'Base Wiki Url'} = $FullUrl;
    
    # Do not allow raw HTML
    $source = SanitizeSource($source);
    
    my $result = Markdown::Markdown($source);
    
	$result = UnescapeWikiWords($result);
	

    pos = $pos;
    return $result;
  }
  return undef;
}

sub SanitizeSource {
	$text = shift;

	# We don't want to allow insertion of raw html into Wikis
	# for security reasons.
	# By converting all '<', we preclude inclusion of HTML tags.
	# We don't have to do the same for '>', which would screw up blockquotes.
	# Remember, on a wiki, we don't want to allow arbitrary HTML...
	# (in other words, this is not a bug)

	$text =~ s/\</&lt;/g;
	
	return $text;
}


# Replace certain core OddMuse routines for compatibility
*GetCluster = *MarkdownGetCluster;

sub MarkdownGetCluster {
  $_ = shift;
  return '' unless $PageCluster;
  return $1 if ( /^$LinkPattern\n/)
    or (/^\[\[$FreeLinkPattern\]\]\n/);
}


# Let Markdown handle special characters, rather than OddMuse
*QuoteHtml = *MarkdownQuoteHtml;

sub MarkdownQuoteHtml {
	my $html = shift;

	return $html;
}


# Change InterMap/NearLink to match >1 space, rather than exactly one
# So that Markdown can display as codeblock

*InterInit = *MarkdownInterInit;
*NearInit = *MarkdownNearInit;

sub MarkdownInterInit {
  $InterSiteInit = 1;
  foreach (split(/\n/, GetPageContent($InterMap))) {
    if (/^ +($InterSitePattern)[ \t]+([^ ]+)$/) {
      $InterSite{$1} = $2;
    }
  }
}


sub MarkdownNearInit {
  InterInit() unless $InterSiteInit;
  $NearSiteInit = 1;
  foreach (split(/\n/, GetPageContent($NearMap))) {
    if (/^ +($InterSitePattern)[ \t]+([^ ]+)(?:[ \t]+([^ ]+))?$/) {
      my ($site, $url, $search) = ($1, $2, $3);
      next unless $InterSite{$site};
      $NearSite{$site} = $url;
      $NearSearch{$site} = $search if $search;
      my ($status, $data) = ReadFile("$NearDir/$site");
      next unless $status;
      foreach my $page (split(/\n/, $data)) {
	push(@{$NearSource{$page}}, $site);
      }
    }
  }
}


# Modify the Markdown source to work with OddMuse

sub DoWikiWords {
	# This is designed for OddMuse in particular
	
	my $text = shift;
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
	my $FreeLinkPattern = "([-,.()' _0-9A-Za-z\x80-\xff]+)";

	# WikiWords
	$text =~ s{
		([\s\>])($WikiWord)
	}{
		$1 . CreateWikiLink($2)
	}xsge;
	
	# Catch WikiWords at beginning of page
	$text =~ s{^($WikiWord)
	}{
		CreateWikiLink($1)
	}xse;
	
	# FreeLinks
	$text =~ s{
		\[\[($FreeLinkPattern)\]\]
	}{
		CreateWikiLink($1)
	}xsge;
	
	# Images - this is too convenient not to support...
	# Though it doesn't fit with Markdown syntax
	$text =~ s{
		(\[\[image:$FreeLinkPattern\]\])	
	}{
		GetDownloadLink($2, 1, undef, $3)
	}xsge;

	$text =~ s{
		(\[\[image:$FreeLinkPattern\|([^]|]+)\]\])	
	}{
		GetDownloadLink($2, 1, undef, $3)
	}xsge;
	
	
	return $text;
}

sub CreateWikiLink {
	my $title = shift;
	
	my $id = $title;
		$id =~ s/ /_/g;
		$id =~ s/__+/_/g;
		$id =~ s/^_//g;
		$id =~ s/_$//;

	#AllPagesList();
	#my $exists = $IndexHash{$id};

	my ($class, $resolved, $linktitle, $exists) = ResolveId($id);


	if ($resolved) {
		if ($class eq 'near') {
			return "[$title]($resolved)";
		}
		return "[$title](" . UrlEncode($resolved) . ")";
	} else {
		if ($title =~ / /) {
			return "[$title]\[?]($g_metadata{'Base Wiki Url'}?action=edit;id=$id)";
		} else {
			return "$title\[?]($g_metadata{'Base Wiki Url'}?action=edit;id=$id)";
		}
	}
}

sub UnescapeWikiWords {
	my $text = shift;
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
	
	# Unescape escaped WikiWords
	$text =~ s/\\($WikiWord)/$1/g;

	return $text;
}


sub NewRunSpanGamut {
#
# These are all the transformations that occur *within* block-level
# tags like paragraphs, headers, and list items.
#
	my $text = shift;
	
	$text = Markdown::_DoCodeSpans($text);

	$text = Markdown::_EscapeSpecialChars($text);

	# Process anchor and image tags. Images must come first,
	# because ![foo][f] looks like an anchor.
	$text = Markdown::_DoImages($text);
	$text = Markdown::_DoAnchors($text);

	# Process WikiWords
	if (!$TempNoWikiWords) {
		$text = DoWikiWords($text);

		# And then reprocess anchors and images
		$text = Markdown::_DoImages($text);
		$text = Markdown::_DoAnchors($text);
	}
	
	# Make links out of things like `<http://example.com/>`
	# Must come after _DoAnchors(), because you can use < and >
	# delimiters in inline links like [this](<url>).
	$text = Markdown::_DoAutoLinks($text);

	$text = Markdown::_EncodeAmpsAndAngles($text);
	
	$text = Markdown::_DoItalicsAndBold($text);

	# Do hard breaks:
	$text =~ s/ {2,}\n/$g_hardbreak/g;

	return $text;
}

# Don't do wiki words in headers

*OldDoHeaders = *Markdown::_DoHeaders;

sub NewDoHeaders {
	my $text = shift;
	
	$TempNoWikiWords = 1;
	
	$text = OldDoHeaders($text);
	
	$TempNoWikiWords = 0;
	
	return $text;
}

# Protect WikiWords in Code Blocks

*OldEncodeCode = *Markdown::_EncodeCode;

sub NewEncodeCode {
	my $text = shift;
	
	# Undo sanitization of '<'
	$text =~ s/&lt;/</g;
	
	$text = OldEncodeCode($text);
	
	# Protect Wiki Words
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
	$text =~ s!($WikiWord)!\\$1!gx;

	return $text;
}

