# Copyright (C) 2005-2007  Fletcher T. Penney <fletcher@fletcherpenney.net>
# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
#
# Portions of Markdown code Copyright (C) 2004 John Gruber
# 	<http://daringfireball.net/projects/markdown/>
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

#	To enable other features, I suggest you also check out:
#	MultiMarkdown <http://fletcherpenney.net/MultiMarkdown>

#	Requires MultiMarkdown 2.0.a2 or higher

#	TODO: auto links in codespans should not be interpreted  (e.g. `<http://somelink/>`)

$ModulesDescription .= '<p>$Id: markdown.pl,v 1.44 2007/09/12 05:02:13 fletcherpenney Exp $</p>';

use vars qw!%MarkdownRuleOrder @MyMarkdownRules $MarkdownEnabled $SmartyPantsEnabled!;

$MarkdownEnabled = 1;
$SmartyPantsEnabled = 1;

@MyRules = (\&MarkdownRule);

$RuleOrder{\&MarkdownRule} = -10;

$TempNoWikiWords = 0;

sub MarkdownRule {
	# Allow journal pages	
	if (m/\G(&lt;journal(\s+(\d*))?(\s+"(.*)")?(\s+(reverse))?\>[ \t]*\n?)/cgi) {
       # <journal 10 "regexp"> includes 10 pages matching regexp
        Clean(CloseHtmlEnvironments());
        Dirty($1);
        my $oldpos = pos;
        PrintJournal($3, $5, $7);
        Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
        pos = $oldpos;          # restore \G after call to ApplyRules
        return;
      }
      
  if (pos == 0) {
    my $pos = length($_); # fake matching entire file
    my $source = $_;
    # fake that we're blosxom!
    $blosxom::version = 1;
    require "$ModuleDir/Markdown/MultiMarkdown.pl";

	*Markdown::_RunSpanGamut = *NewRunSpanGamut;
	*Markdown::_DoHeaders = *NewDoHeaders;
	*Markdown::_EncodeCode = *NewEncodeCode;
	*Markdown::_DoAutoLinks = *NewDoAutoLinks;
    *Markdown::_ParseMetaData = *NewParseMetaData;

    # Do not allow raw HTML
    $source = SanitizeSource($source);
    
	# Allow other Modules to process raw text before Markdown
	# This allows other modules to be "Markdown Compatible"
	@MyMarkdownRules = sort {$MarkdownRuleOrder{$a} <=> $MarkdownRuleOrder{$b}} @MyMarkdownRules; # default is 0
	foreach my $sub (@MyMarkdownRules) {
		$source = &$sub($source);
	}
	
    my $result = Markdown::Markdown($source);
 
	if ($SmartyPantsEnabled) {
		require "$ModuleDir/Markdown/SmartyPants.pl";
		$result = SmartyPants::SmartyPants($result,"2",undef);
	}
   
	$result = UnescapeWikiWords($result);
	
	$result = AntiSpam($result);

    pos = $pos;

	# Encode '<' and '>' for RSS feeds
    # Otherwise, "full" does not work
    if (GetParam("action",'') =~ /^(rss|journal)$/) {
    	$result =~ s/\</&lt;/g;
    	$result =~ s/\>/&gt;/g;    	
    }
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
	if (( /^$LinkPattern\n/)
		or (/^\[\[$FreeLinkPattern\]\]\n/)) {
		return $1
	};
}


# Let Markdown handle special characters, rather than OddMuse

# This opened up a security flaw whereby a user's input (e.g. search string)
# would be displayed as raw HTML).
#
# It also appears that Alex has changed the way Oddmuse works, so I can't seem
# to provide a workaround at this time. I don't remember why I had to add this
# routine, so I am disabling it for now, and will have to "re-fix things" when
# I figure out if anything is now broken....

*oldQuoteHtml = *QuoteHtml;
*QuoteHtml = *MarkdownQuoteHtml;

sub MarkdownQuoteHtml {
	my $html = shift;

	$html =~ s/&/&amp;/g;
	$html =~ s/</&lt;/g;
#	$html =~ s/>/&gt;/g;
	$html =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]/ /g; # legal xml: #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]

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
	
	my $text = shift;
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
	my $FreeLinkPattern = "([-,.()' _0-9A-Za-z\x80-\xff]+)";

	if ($FreeLinks) {
		# FreeLinks
		$text =~ s{
			\[\[($FreeLinkPattern)\]\]
		}{
			my $label = $1;
			$label =~ s{
				([\s\&gt;])($WikiWord)
			}{
				$1 ."\\" . $2
			}xsge;
			
			CreateWikiLink($label)
		}xsge;

		# Images - this is too convenient not to support...
		# Though it doesn't fit with Markdown syntax
		$text =~ s{
			(\[\[image:$FreeLinkPattern\]\])	
		}{
			my $link = GetDownloadLink($2, 1, undef, $3);
			$link =~ s/_/&#95;/g;
			$link
		}xsge;
	
		$text =~ s{
			(\[\[image:$FreeLinkPattern\|([^]|]+)\]\])	
		}{
			my $link = GetDownloadLink($2, 1, undef, $3);
			$link =~ s/_/&#95;/g;
			$link
		}xsge;
		
		# And Same thing for downloads
		
		$text =~ s{
			(\[\[download:$FreeLinkPattern\|?(.*)\]\])
		}{
			my $link = GetDownloadLink($2, undef, undef, $3);
			$link =~ s/_/&#95;/g;
			$link
		}xsge;
	}
	
	# WikiWords
	if ($WikiLinks) {
		$text =~ s{
			([\s\&gt;])($WikiWord\b)
		}{
			$1 . CreateWikiLink($2)
		}xsge;
		
		# Catch WikiWords at beginning of page (ie PageCluster)
		$text =~ s{^($WikiWord)
		}{
			CreateWikiLink($1)
		}xse;
	}
	
	
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

	my $resolvable = $id;
	$resolvable =~ s/\\//g;
	
	my ($class, $resolved, $linktitle, $exists) = ResolveId($resolvable);


	if ($resolved) {
		if ($class eq 'near') {
			return "[$title]($ScriptName/$resolved)";
		}
		return "[$title]($ScriptName/" . UrlEncode($resolved) . ")";
	} else {
		if ($title =~ / /) {
			return "[$title]\[?]($ScriptName/?action=edit;id=$id)";
		} else {
			return "$title\[?]($ScriptName/?action=edit;id=$id)";
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

	$text = Markdown::_EscapeSpecialCharsWithinTagAttributes($text);

	# Process anchor and image tags. Images must come first,
	# because ![foo][f] looks like an anchor.
	$text = Markdown::_DoImages($text);
	$text = NewDoAnchors($text);

	# Process WikiWords
	if (!$TempNoWikiWords) {
		$text = DoWikiWords($text);

		# And then reprocess anchors and images
		$text = Markdown::_DoImages($text);
		$text = NewDoAnchors($text);
	}
	
	# Make links out of things like `<http://example.com/>`
	# Must come after _DoAnchors(), because you can use < and >
	# delimiters in inline links like [this](<url>).
	$text = Markdown::_DoAutoLinks($text);

	$text = Markdown::_EncodeAmpsAndAngles($text);
	
	$text = Markdown::_DoItalicsAndBold($text);

	# Do hard breaks:
	$text =~ s/ {2,}\n/$Markdown::g_hardbreak/g;

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
	
	# Undo sanitization of '<, >, and &' (necessary due to a change in how Oddmuse works)
	$text =~ s/&lt;/</g;
#	$text =~ s/&gt;/>/g;
	$text =~ s/&amp;/&/g;
	
	$text = OldEncodeCode($text);
	
	# Protect Wiki Words
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
	$text =~ s!($WikiWord)!\\$1!gx;

	return $text;
}


sub AntiSpam {
	my $text = shift;
	my $EmailRegExp = '[\w\.\-]+@([\w\-]+\.)+[\w]+';

	$text =~ s {
		($EmailRegExp)
	}{
		my $masked="";
		my @decimal = unpack('C*', $1);
		foreach $i (@decimal) {
			$masked.="&#".$i.";";
		}
		$masked
	}xsge;
	
	return $text;
}

sub NewDoAutoLinks {
	my $text = shift;

	# Added > to the excluded characters list for Oddmuse compatibility
	$text =~ s{&lt;((https?|ftp|dict):[^'"<>\s]+)\>}{<a href="$1">$1</a>}gi; 

	# Email addresses: <address@domain.foo>
	$text =~ s{
		&lt;
        (?:mailto:)?
		(
			[-.\w]+
			\@
			[-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+
		)
		>
	}{
		Markdown::_EncodeEmailAddress( Markdown::_UnescapeSpecialChars($1) );
	}egix;

	return $text;
}


# Fix problem with validity - Oddmuse forced a page to start with <p>,
# which screws up Markdown

*PrintWikiToHTML = *MarkdownPrintWikiToHTML;

sub MarkdownPrintWikiToHTML {
  my ($pageText, $savecache, $revision, $islocked) = @_;
  $FootnoteNumber = 0;
  $pageText =~ s/$FS//g; # Remove separators (paranoia)
  $pageText = QuoteHtml($pageText);
  my ($blocks, $flags) = ApplyRules($pageText, 1, $savecache, $revision); # p is start tag!
  # local links, anchors if cache ok
  if ($savecache and not $revision and $Page{revision} # don't save revision 0 pages
      and $Page{blocks} ne $blocks and $Page{flags} ne $flags) {
    $Page{blocks} = $blocks;
    $Page{flags} = $flags;
    if ($islocked or RequestLockDir('main')) { # not fatal!
      SavePage();
      ReleaseLock() unless $islocked;
    }
  }
}

*AddComment = *MarkdownAddComment;

sub MarkdownAddComment {
  my ($old, $comment) = @_;
  my $string = $old;
  $comment =~ s/\r//g;	# Remove "\r"-s (0x0d) from the string
  $comment =~ s/\s+$//g;    # Remove whitespace at the end
  if ($comment ne '' and $comment ne $NewComment) {
    my $author = GetParam('username', T('Anonymous'));
    my $homepage = GetParam('homepage', '');
    $homepage = 'http://' . $homepage if $homepage and not substr($homepage,0,7) eq 'http://';
    $author = "[$author]($homepage)" if $homepage;
    $string .= "\n----\n\n" if $string and $string ne "\n";
    $string .= $comment . "\n\n-- " . $author . ' ' . TimeToText($Now) . "\n\n";
  }
  return $string;
}

sub NewDoAnchors {
	my $text = shift;
	my $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
		
	return Markdown::_DoAnchors($text);
}

sub NewParseMetaData {
	# Attempting to parse metadata screws up Oddmuse
	# if there is a colon in the first line (or a link)
	my $text = shift;
	return $text;
}