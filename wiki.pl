#!/usr/bin/perl
# OddMuse (see $WikiDescription below)
# Copyright (C) 2001, 2002, 2003  Alex Schroeder <alex@emacswiki.org>
# ... including lots of patches from the UseModWiki site
# Copyright (C) 2001, 2002  various authors
# ... which was based on UseModWiki version 0.92 (April 21, 2001)
# Copyright (C) 2000, 2001  Clifford A. Adams
#    <caadams@frontiernet.net> or <usemod@usemod.com>
# ... which was based on the GPLed AtisWiki 0.3
# Copyright (C) 1998  Markus Denker <marcus@ira.uka.de>
# ... which was based on the LGPLed CVWiki CVS-patches
# Copyright (C) 1997  Peter Merel
# ... and The Original WikiWikiWeb
# Copyright (C) 1996, 1997  Ward Cunningham <ward@c2.com>
#     (code reused with permission)
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

package OddMuse;
use strict;
local $| = 1;  # Do not buffer output (localized for mod_perl)

# Configuration/constant variables:

use vars qw(@RcDays @HtmlTags $TempDir $LockDir $DataDir $KeepDir
$PageDir $RefererDir $RcFile $RcOldFile $IndexFile $NoEditFile
$BannedHosts $ConfigFile $FullUrl $SiteName $HomePage $LogoUrl
$RcDefault $IndentLimit $RecentTop $RecentLink $EditAllowed $UseDiff
$RawHtml $KeepDays $HtmlTags $HtmlLinks $KeepMajor $KeepAuthor
$EmbedWiki $BracketText $UseConfig $UseLookup $AdminPass $EditPass
$NetworkFile $BracketWiki $FreeLinks $WikiLinks $FreeLinkPattern
$RCName $RunCGI $ShowEdits $LinkPattern $InterLinkPattern
$InterSitePattern $UrlProtocols $UrlPattern $ImageExtensions
$RFCPattern $ISBNPattern $FS $FS0 $FS1 $FS2 $FS3 $CookieName $SiteBase
$StyleSheet $NotFoundPg $FooterNote $EditNote $MaxPost $NewText
$HttpCharset $UserGotoBar $VisitorTime $VisitorFile $Visitors %Smilies
%SpecialDays $InterWikiMoniker $SiteDescription $RssImageUrl
$RssPublisher $RssContributor $RssRights $WikiDescription
$BannedCanRead $SurgeProtection $SurgeProtectionViews
$SurgeProtectionTime $DeletedPage %Languages $LanguageLimit
$ValidatorLink $RefererTracking $RefererTimeLimit $RefererLimit
$TopLinkBar $NotifyTracker $InterMap @LockOnCreation $RefererFilter
$PermanentAnchorsFile $PermanentAnchors %CookieParameters
$StyleSheetPage @UserGotoBarPages $ConfigPage $ScriptName
$CommentsPrefix $NewComment $AllNetworkFiles $UsePathInfo);

# Other global variables:
use vars qw(%Page %Section %Text %InterSite %KeptRevisions %IndexHash
%Translate %OldCookie %NewCookie $InterSiteInit $FootnoteNumber
$OpenPageName @KeptList @IndexList $IndexInit $Message $q $Now
%RecentVisitors @HtmlStack %Referers $Monolithic $ReplaceForm
%PermanentAnchors %PagePermanentAnchors $CollectingJournal);

# == Configuration ==

# Can be set outside the script: $DataDir, $UseConfig, $ConfigFile,
# $ConfigPage, $AdminPass, $EditPass

$UseConfig   = 1 unless defined $UseConfig; # 1 = load config file in the data directory
$DataDir   = '/tmp/oddmuse' unless $DataDir; # Main wiki directory
$ConfigPage  = '' unless $ConfigPage; # config page
$RunCGI      = 1;   # 1 = Run script as CGI instead of being a library
$UsePathInfo = 1;   # 1 = allow page views using wiki.pl/PageName

# Basics
$SiteName    = 'Wiki';     # Name of site (used for titles)
$HomePage    = 'HomePage'; # Home page
$CookieName  = 'Wiki';     # Name for this wiki (for multi-wiki sites)

# Fix if defaults do not work
$SiteBase    = '';  # Full URL for <BASE> header
$FullUrl     = '';  # Set if the auto-detected URL is wrong
$HttpCharset = 'UTF-8'; # Charset for pages, eg. 'ISO-8859-1'
$MaxPost     = 1024 * 210; # Maximum 210K posts (about 200K for pages)
$WikiDescription =  # Version string
    '<p><a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl">OddMuse</a>'
  . '<p>$Id: wiki.pl,v 1.125 2003/08/16 12:34:16 as Exp $';

# EyeCandy
$StyleSheet  = '';  # URL for CSS stylesheet (like '/wiki.css')
$StyleSheetPage = ''; # Page for CSS sheet
$LogoUrl     = '';  # URL for site logo ('' for no logo)
$NotFoundPg  = '';  # Page for not-found links ('' for blank pg)
$NewText     = "Describe the new page here.\n";  # New page text
$NewComment  = "Add your comment here.\n";       # New comment text

# HardSecurity
$EditAllowed = 1;   # 0 = no, 1 = yes, 2 = comments only
$AdminPass   = '' unless defined $AdminPass; # Whitespace separated passwords.
$EditPass    = '' unless defined $EditPass; # Whitespace separated passwords.
$BannedHosts = 'BannedHosts'; # Page for banned hosts
$BannedCanRead = 1; # 1 = banned cannot edit, 0 = banned cannot read

# LinkPattern
$WikiLinks   = 1;   # 1 = LinkPattern is a link
$FreeLinks   = 1;   # 1 = [[some text]] is a link
$BracketText = 1;   # 1 = [URL desc] uses a description for the URL
$BracketWiki = 0;   # 1 = [WikiLink desc] uses a desc for the local link
$HtmlLinks   = 0;   # 1 = <a href="foo">desc</a> is a link
$NetworkFile = 1;   # 1 = file: is a valid protocol for URLs
$AllNetworkFiles = 0; # 1 = file:///foo is allowed -- the default allows only file://foo
$PermanentAnchors = 1;   # 1 = [::some text] creates a permanent anchor [##some text] link to the anchor
$InterMap    = 'InterMap'; # name of the intermap page

# TextFormattingRules
$HtmlTags    = 0;   # 1 = allow some 'unsafe' HTML tags
$RawHtml     = 0;   # 1 = allow <HTML> environment for raw HTML inclusion

# Diff
$ENV{PATH}   = '/usr/bin/'; # Path used to find 'diff' and 'merge'
$UseDiff     = 1;           # 1 = use diff and merge

# Visitors and SurgeProtection
$SurgeProtection = 1;      # 1 = protect against leeches
$Visitors        = 1;      # 1 = maintain list of recent visitors
$VisitorTime   = 120 * 60; # Timespan to remember visitors in seconds
$SurgeProtectionTime = 10; # Size of the protected window in seconds
$SurgeProtectionViews = 5; # How many page views to allow in this window
$RefererTracking = 0;      # Keep track of referrals to your pages
$RefererTimeLimit = 60 * 60 * 24; # How long referrals shall be remembered
$RefererLimit = 15;        # How many different referer shall be remembered
$RefererFilter = 'ReferrerFilter'; # name of the filter pg

# RecentChanges and KeptPages
$DeletedPage = 'DeletedPage';   # Pages starting with this can be deleted
$RCName      = 'RecentChanges'; # Name of changes page
@RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
$RcDefault   = 30;  # Default number of RecentChanges days
$KeepDays    = 14;  # Days to keep old revisions
$KeepMajor   = 1;   # 1 = keep at least one major rev when expiring pages
$KeepAuthor  = 1;   # 1 = keep at least one author rev when expiring pages
$ShowEdits   = 0;   # 1 = major and show minor edits in recent changes
$UseLookup   = 1;   # 1 = lookup host names instead of using only IP numbers
$RecentTop   = 1;   # 1 = most recent entries at the top of the list
$RecentLink  = 1;   # 1 = link to usernames

# RSS and other Weblog Technology
$InterWikiMoniker = '';    # InterWiki prefix for this wiki for RSS
$SiteDescription  = '';    # RSS Description of this wiki
$RssImageUrl      = '';    # URL to image to associate with your RSS feed
$RssPublisher     = '';    # Name of RSS publisher
$RssContributor   = '';    # List or description of the contributors
$RssRights        = '';    # Copyright notice for RSS
$NotifyTracker    = 0;     # 1 = send pings to weblogs.com for major changes

# Header and Footer, Notes, GotoBar
$EmbedWiki   = 0;   # 1 = no headers/footers
$FooterNote  = '';  # HTML for bottom of every page
$EditNote    = '';  # HTML notice above buttons on edit page
$TopLinkBar  = 1;   # 1 = add a goto bar at the top of the page
@UserGotoBarPages = (); # List of pagenames
$UserGotoBar = '';  # HTML added to end of goto bar
$ValidatorLink = 0; # 1 = Link to the W3C HTML validator service
$CommentsPrefix = ''; # prefix for comment pages, eg. 'Comments_on_' to enable

# Display short comments below the GotoBar for special days
# Example: %SpecialDays = ('1-1' => 'New Year', '1-2' => 'Next Day');
%SpecialDays = ();

# Replace regular expressions with inlined images
# Example: %Smilies = (":-?D(?=\\W)" => '/pics/grin.png');
%Smilies = ();

# Detect page languages when saving edits
# Example: %Languages = ('de' => '\b(der|die|das|und|oder)\b');
%Languages = ();

@LockOnCreation = ($BannedHosts, $InterMap, $RefererFilter, $StyleSheetPage,
		   $ConfigPage);

%CookieParameters = ('username' => '',
		     'pwd' => '',
		     'theme' => '',
		     'toplinkbar' => $TopLinkBar,
		     'embed' => $EmbedWiki);

$IndentLimit = 20;                  # Maximum depth of nested lists
$LanguageLimit = 3;                 # Number of matches req. for each language
$PageDir     = "$DataDir/page";     # Stores page data
$KeepDir     = "$DataDir/keep";     # Stores kept (old) page data
$RefererDir  = "$DataDir/referer";  # Stores referer data
$TempDir     = "$DataDir/temp";     # Temporary files and locks
$LockDir     = "$TempDir/lock";     # DB is locked if this exists
$NoEditFile  = "$DataDir/noedit";   # Indicates that the site is read-only
$RcFile      = "$DataDir/rclog";    # New RecentChanges logfile
$RcOldFile   = "$DataDir/oldrclog"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$VisitorFile = "$DataDir/visitors"; # List of recent visitors
$PermanentAnchorsFile = "$DataDir/permanentanchors"; # Store permanent anchors
$ConfigFile  = "$DataDir/config" unless $ConfigFile; # Config file with Perl code to execute

# The 'main' program, called at the end of this script file.
sub DoWikiRequest {
  Init();
  DoSurgeProtection();
  if (not $BannedCanRead and UserIsBanned() and not UserIsAdmin()) {
    DoBannedReading();
    return;
  }
  DoBrowseRequest();
}

sub DoBannedReading {
  ReportError(T('Reading not allowed: user, ip, or network is blocked.'));
}

sub Init {
  $FS  = "\x1e";      # The FS character is the RECORD SEPARATOR control char in ASCII
  $FS0 = "\xb3";      # The old FS character is a superscript "3" in Latin-1
  $FS1 = $FS . '1';   # The FS values are used to separate fields
  $FS2 = $FS . '2';   # in stored hashtables and other data structures.
  $FS3 = $FS . '3';   # The FS character is not allowed in user data.
  $Message = '';      # Warnings and non-fatal errors.
  InitLinkPatterns(); # Link pattern can be changed in config files
  if ($UseConfig and $ConfigFile and -f $ConfigFile) {
    do $ConfigFile;
    $Message .= "<p>$ConfigFile: $@</p>" if $@;
  } # FS character can only be changed in config *file*
  if ($ConfigPage) {
    eval GetPageContent($ConfigPage);
    $Message .= "<p>$ConfigPage: $@</p>" if $@;
  }
  InitRequest();      # After config files, because $HttpCharset is used
  InitCookie();       # After request, because $q is used
}

# == CGI startup, cookie ==

use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub InitRequest { # Init global session variables for mod_perl!
  $CGI::POST_MAX = $MaxPost;
  $CGI::DISABLE_UPLOADS = 1;  # no uploads
  $q = new CGI;
  $q->charset($HttpCharset) if $HttpCharset;
  $Now = time;                     # Reset in case script is persistent
  $ReplaceForm = 0;
  $ScriptName = $q->url() unless defined $ScriptName; # Name used in links
  $IndexInit = 0;                  # Must be reset for each request
  $InterSiteInit = 0;
  %InterSite = ();
  $OpenPageName = '';    # Currently open page
  CreateDir($DataDir);  # Create directory if it doesn't exist
  ReportError(Ts('Could not create %s', $DataDir) . ": $!") unless -d $DataDir;
  @UserGotoBarPages = ($HomePage, $RCName) unless @UserGotoBarPages;
  map { $$_ = FreeToNormal($$_); } # convert spaces to underscores on all configurable pagenames
    (\$HomePage, \$RCName, \$BannedHosts, \$InterMap, \$RefererFilter, \$StyleSheetPage, \$ConfigPage);
  if (not @HtmlTags) { # don't set if set in the config file -- must come after config file is read!
    if ($HtmlTags) {   # allow many tags
      @HtmlTags = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
		     em s strike strong tt var div center blockquote ol ul dl
		     table caption br p hr li dt dd tr td th);
    } else {	       # only allow a very small subset
      @HtmlTags = qw(b i u em strong tt);
    }
  }
}

sub InitCookie {
  undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
  %OldCookie = split(/$FS1/, $q->cookie($CookieName));
  %NewCookie = %OldCookie;
  # Only valid usernames get stored in the new cookie.
  my $name = GetParam('username', '');
  $q->delete('username');
  delete $NewCookie{'username'};
  if (!$name) {
    # do nothing
  } elsif (!$FreeLinks && !($name =~ /^$LinkPattern$/)) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif ($FreeLinks && (!($name =~ /^$FreeLinkPattern$/))) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif (length($name) > 50) {  # Too long
    $Message .= $q->p(T('UserName must be 50 characters or less: not saved'));
  } else {
    $NewCookie{'username'} = $name;
  }
}

sub GetParam {
  my ($name, $default) = @_;
  my $result;
  $result = $q->param($name);
  if (!defined($result)) {
    if (defined($NewCookie{$name})) {
      $result = $NewCookie{$name};
    } else {
      $result = $default;
    }
  }
  return $result;
}

# == Markup Code ==

sub InitLinkPatterns {
  my ($UpperLetter, $LowerLetter, $AnyLetter, $WikiWord, $QDelim);
  $QDelim = '(?:"")?';# Optional quote delimiter (removed from the output)
  $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
  $LinkPattern = "($WikiWord)";
  $LinkPattern .= $QDelim;
  # Inter-site convention: sites must start with uppercase letter.
  # This avoids confusion with URLs.
  $InterSitePattern = '[A-Z]+[A-Za-z\x80-\xff]+';
  $InterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x80-\xff_=!?#$@~`%&*+\\/:;.,]+[-a-zA-Z0-9\x80-\xff_=#$@~`%&*+\\/])$QDelim";
  $FreeLinkPattern = "([-,.()' _0-9A-Za-z\x80-\xff]+)$QDelim";
  $UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|'
                  . 'prospero|telnet|gopher';
  $UrlProtocols .= '|file'  if $NetworkFile;
  my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]'; # see RFC 2396
  my $EndChars = '[-a-zA-Z0-9/@=+$_~*]'; # no punctuation at the end of the url.
  $UrlPattern = "((?:$UrlProtocols):$UrlChars+$EndChars)";
  $ImageExtensions = '(gif|jpg|png|bmp|jpeg)';
  $RFCPattern = "RFC\\s?(\\d+)";
  $ISBNPattern = 'ISBN:?([0-9- xX]{10,})';
}

sub ApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks) = @_;
  $text =~ s/\r\n/\n/g; # DOS to Unix
  my $state = ''; # quote, list, or normal ('')
  my $fragment;   # the current HTML fragment to be printed
  my $block = ''; # the current HTML block to be cached
  my @blocks;     # the list of cached HTML blocks
  my @flags;      # a list for each block, 1 = dirty, 0 = clean
  my $htmlre = join('|',(@HtmlTags));
  my ($oldmatch, $rest);
  local $_ = $text;
  while(1) {
    # first block -- at the beginning of a line.  Note that block level elements eat empty lines to prevent empty p elements.
    undef($fragment);
    if (m/\G(?<=\n)/cg or m/\G^/cg) { # at the beginning of a line
      if (m/\G&lt;pre&gt;\n?(.*?\n)&lt;\/pre&gt;[ \t]*\n?/cgs) { # pre must be on column 1
	$fragment = CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1);
      } elsif (m/\G(\s*\n)*(\*+)[ \t]*/cg) {
	$fragment = OpenHtmlEnvironment('ul',length($2)) . '<li>';
      } elsif (m/\G(\s*\n)*(\#+)[ \t]*/cg) {
	$fragment = OpenHtmlEnvironment('ol',length($2)) . '<li>';
      } elsif (m/\G(\s*\n)*(\:+)[ \t]*/cg) {
	$fragment = OpenHtmlEnvironment('dl',length($2)) . '<dt><dd class="quote">'; # use blockquote instead?
      } elsif (m/\G(\s*\n)*(\=+)[ \t]*(.*?)[ \t]*(=+)[ \t]*\n?/cg) {
	$fragment = CloseHtmlEnvironments() . WikiHeading($2, $3);
      } elsif (m/\G(\s*\n)*----+[ \t]*\n?/cg) {
	$fragment = CloseHtmlEnvironments() . $q->hr();
      } elsif (m/\G(\s*\n)*(([ \t]+.*\n?)+)/cg) {
	$fragment = OpenHtmlEnvironment('pre',1) . $2; # always level 1
      } elsif (m/\G(\s*\n)*(\;+)[ \t]*(?=.*\:)/cg) {
	$fragment = OpenHtmlEnvironment('dl',length($2))
	  . AddHtmlEnvironment('dt'); # the `:' needs special treatment, later
      } elsif (m/\G(\s*\n)*((\|\|)+)[ \t]*(?=.*\|\|[ \t]*$)/cgm) {
	$fragment = OpenHtmlEnvironment('table',1,'user') # `||' needs special treatment, later
	  . AddHtmlEnvironment('tr');
	if (length($2) == 2) {
	  $fragment .= AddHtmlEnvironment('td');
	} else {
	  $fragment .= AddHtmlEnvironment('td', 'colspan="' . length($2)/2 . '"');
	}
      } elsif (m/\G(\s*\n)+/cg) {
	$fragment = CloseHtmlEnvironments() . '<p>'; # there is another one like this further down
      } elsif (m/\G(\&lt;include +"(.*)"\&gt;[ \t]*\n?)/cgi) { # <include "uri..."> includes the text of the given URI verbatim
	$oldmatch = $1;
	my $oldpos = pos;
	my $uri = $2;
	if ($uri =~ /^$UrlProtocols:/) {
	  ApplyRules(QuoteHtml(GetRaw($uri)),0);
	} else {
	  ApplyRules(QuoteHtml(GetPageContent(FreeToNormal($uri))), 1);
	}
	pos = $oldpos; # restore \G after call to ApplyRules
	DirtyBlock($oldmatch, \$block, \$fragment, \@blocks, \@flags);
      } elsif (m/\G(\&lt;journal( +(\d*))?( +"(.*)")?\&gt;[ \t]*\n?)/cgi) { # <journal 10 "regexp"> includes 10 pages matching regexp
	DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
	my $oldpos = pos;
	PrintJournal($3, $5);
	pos = $oldpos; # restore \G after call to ApplyRules
      } elsif (m/\G(\&lt;rss +"(.*)"\&gt;[ \t]*\n?)/cgi) { # <rss "uri..."> stores the parsed RSS of the given URI
	my $oldpos = pos;
	DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
	print &RSS($2);
	pos = $oldpos; # restore \G after call to RSS which uses the LWP module (for older copies of the module?)
      }
      if (defined $fragment) {
	print $fragment;
	$block .= $fragment;
	next; # skipt the remaining tests
      }
    }
    # second block -- remaining hilighting
    if ($HtmlStack[0] eq 'dt' && m/\G:/cg) {
      $fragment = OpenHtmlEnvironment('dd');
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)[ \t]*/cgm) {
      $fragment = '</td></tr><tr>' . ((length($3) == 2) ? '<td>' : ('<td colspan="' . length($3)/2 . '">'));
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*(?!(\n|$))/cgm) { # continued
      $fragment = '</td>' . ((length($1) == 2) ? '<td>' : ('<td colspan="' . length($1)/2 . '">'));
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*/cgm) { # at the end of the table
      $fragment = CloseHtmlEnvironments();
    } elsif (m/\G\&lt;nowiki\&gt;(.*?)\&lt;\/nowiki\&gt;/cgis) {
      $fragment = $1;
    } elsif (m/\G\&lt;code\&gt;(.*?)\&lt;\/code\&gt;/cgis) {
      $fragment = $q->code($1);
    } elsif ($RawHtml && m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgis) {
      $fragment = UnquoteHtml($1);
    } elsif (m/\G$RFCPattern/cg) { # RFC 1234 gets linked
      $fragment = &RFC($1);
    } elsif (m/\G$ISBNPattern/cg) { # ISBN 1234567890 gets linked
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print ISBN($1);
    } elsif (m/\G'''/cg) { # traditional wiki syntax with '''strong'''
      if ($HtmlStack[0] eq 'strong') {
	$fragment = CloseHtmlEnvironment();
      } else {
	$fragment = AddHtmlEnvironment('strong');
      }
    } elsif (m/\G''/cg) {     #  traditional wiki syntax with ''emph''
      if ($HtmlStack[0] eq 'em') {
	$fragment = CloseHtmlEnvironment();
      } else {
	$fragment = AddHtmlEnvironment('em');
      }
    } elsif (m/\G\&lt;($htmlre)\&gt;/cgi) { # opening
      $fragment = AddHtmlEnvironment($1);
    } elsif (m/\G\&lt;\/($htmlre)\&gt;/cgi) { # closing tags
      $fragment = CloseHtmlEnvironment($1);
    } elsif (m/\G\&lt;($htmlre) *\/\&gt;/cgi) { # empty tags
      $fragment = "<$1 />";
    } elsif ($HtmlLinks && m/\G\&lt;a(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/cgi) { # <a ...>text</a>
      $fragment = "<a$1>$2</a>";
    } elsif ($BracketText && $locallinks && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cg) { # [InterLink text]
      # Interlinks can change when the intermap changes (local config, therefore depend on $locallinks).
      # The intermap is only read if necessary, so if this not an interlink, we have to backtrack a bit.
      $oldmatch = $1;
      $fragment = GetInterLink($2, $3, 1);
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	print $fragment;
	DirtyBlock($oldmatch, \$block, \$fragment, \@blocks, \@flags);
      }
    } elsif ($locallinks && m/\G(\[$InterLinkPattern\])/cog) { # [InterWiki:FooBar] makes footnotes [1]
      $oldmatch = $1;
      $fragment = GetInterLink($2, '', 1);
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	print $fragment;
	DirtyBlock($oldmatch, \$block, \$fragment, \@blocks, \@flags);
      }
    } elsif ($locallinks && m/\G$InterLinkPattern/cog) { # InterWiki:FooBar
      $oldmatch = $1;
      $fragment = GetInterLink($oldmatch, '', 0);
      # we have to backtrack a bit.
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	print $fragment;
	DirtyBlock($oldmatch, \$block, \$fragment, \@blocks, \@flags);
      }
    } elsif ($BracketText && m/\G\[$UrlPattern\s+([^\]]+?)\]/cg) { # [URL text] makes [text] link to URL
      $fragment = GetUrl($1, $2, 1, 0);
    } elsif (m/\G\[$UrlPattern\]/cog) { # [URL] makes footnotes [1]
      $fragment = GetUrl($1, '', 1, 0);
    } elsif (m/\G$UrlPattern/cg) { # plain URLs after all $UrlPattern, such that [$UrlPattern text] has priority
      $fragment = GetUrl($1, '', 0, 1);
    } elsif ($WikiLinks && $BracketWiki && $locallinks && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cg) { # [LocalPage text]
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPageOrEditLink($2, $3, 1);
    } elsif ($WikiLinks && $locallinks && m/\G(\[$LinkPattern\])/cg) { # [LocalPage]
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPageOrEditLink($2, '', 1);
    } elsif ($WikiLinks && $locallinks && m/\G$LinkPattern/cg) { # LocalPage
      # LinkPattern after all $UrlPattern, such that http//:...?FooBar
      # will not get an additional ? if FooBar is undefined.
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPageOrEditLink($1, '');
    }  elsif ($PermanentAnchors && m/\G(\[::$FreeLinkPattern\])/cg) { #[::Free Link] permanent anchor create
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPermanentAnchor($2);
    } elsif ($PermanentAnchors && m/\G(\[\#\#$FreeLinkPattern\])/cg) { #[##Free Link] permanent anchor link
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPermanentAnchorLink($2);
    } elsif ($FreeLinks && $BracketWiki && $locallinks && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cg) { # [[Free Link|text]]
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPageOrEditLink($2, $3, 0 , 1);
    } elsif ($FreeLinks && $locallinks && m/\G(\[\[$FreeLinkPattern\]\])/cg) { # [[Free Link]]
      DirtyBlock($1, \$block, \$fragment, \@blocks, \@flags);
      print GetPageOrEditLink($2, '', 0, 1);
    } elsif (%Smilies && ($fragment = SmileyReplace())) {
      # $fragment already set
    } elsif ( eval {     local $SIG{__DIE__}; $fragment = MyRules(\$block, \@blocks, \@flags); } ) {
      # $fragment already set
    } elsif (m/\G\s*\n(s*\n)+/cg) { # paragraphs -- whitespace including at least two newlines
      $fragment = CloseHtmlEnvironments() . '<p>'; # there is another one like this further up
    } elsif (m/\G\s+/cgs) { # whitespace -- including (max one) newlines due to previous rules
      $fragment = ' ';
    } elsif (m/\G(\w+)/cgi) { # word -- cannot use \S here because that eats following markup, too: word<b> for example.
      $fragment = $1;
    } elsif (m/\G(\S)/cg) { # punctuation and other stuff, if not matched by previous markup rule.  Gotta move slowly, eg. word.</b>
      $fragment = $1;
    } else {
      last;
    }
    if (defined $fragment) {
      print $fragment;
      $block .= $fragment;
    }
  }
  # last block -- close it, cache it
  $fragment = CloseHtmlEnvironments();
  if (defined $fragment) {
    print $fragment;
    $block .= $fragment;
  }
  if ($block) {
    push(@blocks,$block);
    push(@flags,0);
  }
  # this can be stored in the page cache -- see PrintCache
  return join($FS3,@blocks) . $FS2 . join($FS3,@flags);
}

sub CloseHtmlEnvironment { # just close the current one
  my $code = shift;
  my $result = shift(@HtmlStack)  if not defined($code) or $HtmlStack[0] eq $code;
  return "</$result>" if $result;
  return "&lt;/$code&gt;";
}

sub AddHtmlEnvironment { # add a new one so that it will be closed!
  my ($code, $attr) = @_;
  if ($HtmlStack[0] ne $code) {
    unshift(@HtmlStack, $code);
    if ($attr) {
      return "<$code $attr>";
    } else {
      return "<$code>";
    }
  }
  return ''; # always return something
}

sub CloseHtmlEnvironments { # close all
  my $text = ''; # always return something
  while (@HtmlStack > 0) {
    $text .=  '</' . shift(@HtmlStack) . '>';
  }
  return $text;
}

sub OpenHtmlEnvironment { # close the previous one and open a new one instead
  my ($code, $depth, $class) = @_;
  my $oldCode;
  my $text = ''; # always return something
  $depth = @HtmlStack unless defined($depth);
  while (@HtmlStack > $depth) { # Close tags as needed
    $text .=  '</' . shift(@HtmlStack) . '>';
  }
  if ($depth > 0) {
    $depth = $IndentLimit  if ($depth > $IndentLimit);
    if (@HtmlStack) {  # Non-empty stack
      $oldCode = shift(@HtmlStack);
      if ($oldCode ne $code) {
	if ($class) {
	  $text .= "</$oldCode><$code class=\"$class\">";
	} else {
	  $text .= "</$oldCode><$code>";
	}
      }
      unshift(@HtmlStack, $code);
    }
    while (@HtmlStack < $depth) {
      unshift(@HtmlStack, $code);
      if ($class) {
	$text .= "<$code class=\"$class\">";
      } else {
	$text .= "<$code>";
      }
    }
  }
  return $text;
}

sub DirtyBlock {
  my ($block, $old, $fragment, $blocks, $flags) = @_;
  if ($$old) {
    push(@$blocks,$$old);
    push(@$flags,0);
    $$old = '';
  }
  push(@$blocks,$block);
  push(@$flags,1);
  $$fragment = '';
}

sub SmileyReplace {
  my $match = 0;
  foreach my $regexp (keys %Smilies) {
    if (m/\G($regexp)/cg) {
      $match = "<img src=\"$Smilies{$regexp}\" alt=\"$1\">";
      last;
    }
  }
  return $match;
}

sub PrintWikiToHTML {
  my ($pageText, $revision) = @_;
  $FootnoteNumber = 0;
  $pageText =~ s/$FS//g;              # Remove separators (paranoia)
  $pageText = QuoteHtml($pageText);
  my $cache = ApplyRules($pageText,1);
  if ($revision eq '') {
    SetPageCache('blocks', $cache);
    if (RequestLock()) {
      SavePage(1);
      ReleaseLock();
    }
  }
}

sub QuoteHtml {
  my ($html) = @_;
  $html =~ s/&/&amp;/g;
  $html =~ s/</&lt;/g;
  $html =~ s/>/&gt;/g;
  $html =~ s/&amp;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references
  return $html;
}

sub UnquoteHtml {
  my ($html) = @_;
  $html =~ s/&lt;/</g;
  $html =~ s/&gt;/>/g;
  $html =~ s/&amp;/&/g;
  return $html;
}

sub UrlEncode {
  my @letters = split(//,shift);
  my @safe = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')');
  foreach my $letter (@letters) {
    my $pattern = quotemeta($letter);
    if (not grep(/$pattern/, @safe)) {
      $letter = sprintf("%%%02x", ord($letter));
    }
  }
  return join('', @letters);
}

sub GetRaw {
  my $uri = shift;
  require LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  # consider setting $ua->max_size(50000);
  # consider setting $ua->timeout(20);
  my $request = HTTP::Request->new('GET', $uri);
  my $response = $ua->request($request);
  return $response->content;
}

sub PrintJournal {
  my ($num, $regexp) = @_;
  if (!$CollectingJournal) {
    $CollectingJournal = 1;
    $regexp = '^\d\d\d\d-\d\d-\d\d' unless $regexp;
    $num = 10 unless $num;
    my @pages = (grep(/$regexp/, AllPagesList()));
    if (defined &JournalSort) {
      @pages = sort JournalSort @pages;
    } else {
      @pages = sort {$b cmp $a} @pages;
    }
    @pages = @pages[0 .. $num - 1] if $#pages >= $num;
    if (@pages) {
      # Now save information required for saving the cache of the current page.
      local (%Page, $OpenPageName);
      print '<div class="journal">';
      PrintAllPages(1, @pages);
      print '</div>';
    }
    $CollectingJournal = 0;
  }
}

sub RSS {
  require XML::RSS;
  require LWP::UserAgent;
  my ($uri) = @_;
  my $rss = new XML::RSS;
  my $ua = LWP::UserAgent->new;
  my $request = HTTP::Request->new('GET', $uri);
  my $response = $ua->request($request);
  my $data = $response->content;
  my $maxitems = 15; # recommended max. by the validator
  eval {
    local $SIG{__DIE__}; # work around some broken XML::Parser stuff
    $rss->parse($data);
  };
  if ($@) {
    return $q->p($q->strong("[RSS parsing failed for $uri]"));
  } else {
    my $counter = 0;
    my $str;
    for my $i (@{$rss->{items}}) {
      $counter++;
      last if $counter == $maxitems;
      my $line = $q->a({-href=>$i->{'link'}},"[$i->{'title'}]");
      $line .= qq{ -- $i->{'description'}} if $i->{'description'};
      $str .= $q->li($line);
    }
    $str = $q->div({-class=>'rss'},$q->ul($str));
    my $charset = uc($HttpCharset); # charsets are case insensitive
    if ($charset eq '' or $charset eq 'UTF-8') {
      return $str;
    } elsif ($charset eq 'ISO-8859-1') {
      require Unicode::String;
      my $u = Unicode::String->new($str);
      return $u->latin1;
    } else {
      # FIXME: This is perhaps broken.
      require Unicode::String;
      require Unicode::Map8;
      my $u = Unicode::String->new($str);
      my $m = Unicode::Map8->new($charset);
      return $m->to8($u->ucs2);
    }
  }
}

sub GetInterLink {
  my ($id, $text, $bracket) = @_;
  my ($site, $page) = split(/:/, $id, 2);
  $page =~ s/&amp;/&/g;  # Unquote common URL HTML
  my $url;
  $url = GetSiteUrl($site) if $page;
  if ($text && $bracket && !$url) {
    return "[$id $text]";
  } elsif ($bracket && !$url) {
    return "[$id]";
  } elsif (!$url) {
    return $id;
  } elsif ($bracket && !$text) {
    $text = ++$FootnoteNumber;
  } elsif (!$text) {
    $text = $id;
  }
  if ($bracket) {
    $text = "[$text]";
  }
  $url .= $page;
  return $q->a({-href=>$url}, $text);
}

sub GetSiteUrl {
  my $site = shift;
  if (!$InterSiteInit) {
    $InterSiteInit = 1;
    foreach (split(/\n/, GetPageContent($InterMap))) {
      if (/^ ($InterSitePattern)[ \t]+([^ ]+)$/) {
	$InterSite{$1} = $2;
      }
    }
  }
  my $url = $InterSite{$site}  if (defined($InterSite{$site}));
  return $url;
}

sub GetUrl {
  my ($url, $text, $bracket, $images) = @_;
  if ($NetworkFile && $url =~ m|^file:///| && !$AllNetworkFiles
      or !$NetworkFile && $url =~ m|^file:|) {
    # Only do remote file:// links. No file:///c|/windows.
    return $url;
  } elsif ($bracket && !$text) {
    $text = ++$FootnoteNumber;
  } elsif (!$text) {
    $text = $url;
  }
  $url = UnquoteHtml($url); # links should be unquoted again
  if ($bracket) {
    return $q->a({-href=>$url}, "[$text]");
  } elsif ($images && $url =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/) {
    return $q->img({-src=>$url, -alt=>$url});
  } else {
    return $q->a({-href=>$url}, $text);
  }
}

sub GetPageOrEditLink { # use GetPageLink and GetEditLink if you know the result!
  my ($id, $text, $bracket, $free) = @_;
  $id =~ s/^\s+//;      # Trim extra spaces
  $id =~ s/\s+$//;
  $id = FreeToNormal($id) if $free;
  AllPagesList() unless $IndexInit;
  my $exists = $IndexHash{$id};
  if (!$text && $exists && $bracket) {
    $text = ++$FootnoteNumber;
  }
  if ($exists) {
    $text = $id unless $text;
    $text =~ s/_/ /g if $free;
    $text = "[$text]" if $bracket;
    return ScriptLink(UrlEncode($id), $text);
  } else {
    # $free and $bracket usually exclude each other
    # $text and not $bracket exclude each other
    my $link = ScriptLink('action=edit&id=' . UrlEncode($id), '?');
    if ($bracket && $text) {
      return "[$id$link $text]";
    } elsif ($bracket) {
      return "[$id$link]";
    } elsif ($free && $text) {
      $id =~ s/_/ /g;
      $text =~ s/_/ /g;
      return "[$id$link $text]";
    } elsif ($free) {
      $text = $id;
      $text = "[$text]" if $text =~ /_/;
      $text =~ s/_/ /g;
      return $text . $link;
    } else { # plain, no text
      return $id . $link;
    }
  }
}

sub GetPageLink { # shortcut
  my ($id, $name) = @_;
  $name = $id unless $name;
  if ($FreeLinks) {
    $id = FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return ScriptLink(UrlEncode($id), $name);
}

sub GetEditLink { # shortcut
  my ($id, $name) = @_;
  if ($FreeLinks) {
    $id = FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return ScriptLink('action=edit&id=' . UrlEncode($id), $name);
}

sub ScriptLink {
  my ($action, $text, $class, $name) = @_;
  my %params;
  if ($UsePathInfo and !$Monolithic and $action !~ /=/) {
    $params{-href} = $ScriptName . '/' . $action;
  } elsif ($Monolithic) {
    $params{-href} = '#' . $action;
  } else {
    $params{-href} = $ScriptName . '?' . $action;
  }
  $params{'-class'} = $class  if $class;
  $params{'-name'} = $name  if $name;
  return $q->a(\%params, $text);
}

sub RFC {
  my $num = shift;
  return $q->a({-href=>"http://www.faqs.org/rfcs/rfc${num}.html"}, "RFC $num");
}

sub ISBN {
  my $rawnum = shift;
  my ($rawprint, $html, $num, $first, $second, $third);
  $num = $rawnum;
  $rawprint = $rawnum;
  $rawprint =~ s/ +$//;
  $num =~ s/[- ]//g;
  if (length($num) != 10) {
    return "ISBN $rawnum";
  }
  $first  = $q->a({-href => Ts('http://shop.barnesandnoble.com/bookSearch/isbnInquiry.asp?isbn=%s', $num)},
		  "ISBN " . $rawprint);
  $second = $q->a({-href => Ts('http://www.amazon.com/exec/obidos/ISBN=%s', $num)},
		  T('alternate'));
  $third  = $q->a({-href => Ts('http://www.pricescan.com/books/BookDetail.asp?isbn=%s', $num)},
		  T('search'));
  $html  = "$first ($second, $third)";
  $html .= ' '  if ($rawnum =~ / $/);  # Add space if old ISBN had space.
  return $html;
}

sub WikiHeading {
  my ($depth, $text) = @_;
  $depth = length($depth);
  $depth = 6  if ($depth > 6);
  return "<h$depth>$text</h$depth>";
}

sub PrintCache {
  my $raw = shift;
  my ($rawblocks, $rawflags) = split(/$FS2/, $raw);
  my @blocks = split($FS3,$rawblocks);
  my @flags = split($FS3,$rawflags);
  foreach my $block (@blocks) {
    if (shift(@flags)) {
      ApplyRules($block,1);
    } else {
      print $block;
    }
  }
}

# == Translating ==

sub T {
  my ($text) = @_;
  if (1) {   # Later make translation optional?
    if (defined($Translate{$text}) && ($Translate{$text} ne ''))  {
      return $Translate{$text};
    }
  }
  return $text;
}

sub Ts {
  my ($text, $string) = @_;
  $text = T($text);
  $text =~ s/\%s/$string/;
  return $text;
}

# == Choosing action

sub DoBrowseRequest {
  my ($id, $action, $text, $search);
  if (not $q->param and not ($UsePathInfo and $q->path_info)) {
    BrowsePage($HomePage);
    return 1;
  }
  $id = join('_', $q->keywords);
  $id = $q->path_info() if not $id and $UsePathInfo;
  $id =~ s|.*/||;
  if ($id) {                    # Just script?PageName
    if ($FreeLinks && (!-f GetPageFile($id))) {
      $id = FreeToNormal($id);
    }
    if (($NotFoundPg ne '') && (!-f GetPageFile($id))) {
      $id = $NotFoundPg;
    }
    BrowsePage($id)  if ValidIdOrDie($id);
    return 1;
  }
  $action = lc(GetParam('action', ''));
  $id = GetParam('id', '');
  $search = GetParam('search', '');
  if ($action eq 'anchor') {
    ReadPermanentAnchors();
    $id = $PermanentAnchors{FreeToNormal($id)};
    $id = '' unless $id;
    $action = 'browse'; #not so nice trick to reuse browse
  }
  if ($action eq 'browse') {
    if ($FreeLinks && (!-f GetPageFile($id))) {
      $id = FreeToNormal($id);
    }
    if (($NotFoundPg ne '') && (!-f GetPageFile($id))) {
      $id = $NotFoundPg;
    }
    BrowsePage($id, GetParam('raw', 0))  if ValidIdOrDie($id);
  } elsif ($action eq 'rc') {
    if (GetParam('raw', 0)) {
      DoRcText();
    } else {
      BrowsePage($RCName);
    }
  } elsif ($action eq 'random') {
    DoRandom();
  } elsif ($action eq 'history') {
    DoHistory($id)   if ValidIdOrDie($id);
  } elsif ($action eq 'edit') {
    DoEdit($id, 0, 0, '', 0)  if ValidIdOrDie($id);
  } elsif ($action eq 'unlock') {
    DoUnlock();
  } elsif ($action eq 'index') {
    DoIndex(GetParam('raw', 0));
  } elsif ($action eq 'links') {
    DoLinks();
  } elsif ($action eq 'all') {
    DoPrintAllPages();
  } elsif ($action eq 'maintain') {
    DoMaintain();
  } elsif ($action eq 'convert') {
    DoConvert();
  } elsif ($action eq 'pagelock') {
    DoPageLock();
  } elsif ($action eq 'editlock') {
    DoEditLock();
  } elsif ($action eq 'version') {
    DoShowVersion();
  } elsif ($action eq 'rss') {
    DoRss();
  } elsif ($action eq 'password') {
    DoPassword();
  } elsif ($action eq 'visitors') {
    DoShowVisitors();
  } elsif ($action eq 'refer') {
    DoPrintAllReferers();
  } elsif ($action eq 'ping') {
    DoPingTracker();
  } elsif (($search ne '') || (GetParam('dosearch', '') ne '')) {
    DoSearch($search);
  } elsif (GetParam('oldtime', '') or (GetParam('raw', 0) == 2)) { # after edit
    $id = GetParam('title', '');
    DoPost()  if ValidIdOrDie($id);
  } else {
    if ($action) {
      ReportError(Ts('Invalid action parameter %s', $action));
    } else {
      ReportError(T('Invalid URL.'));
    }
  }
}

# == Browse page ==

sub BrowsePage {
  my ($id, $raw) = @_;
  my $rc = (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName));
  OpenPage($id);
  OpenDefaultText($id);
  # Handle a single-level redirect
  my $oldId = GetParam('oldid', '');
  if (($oldId eq '') && (substr($Text{'text'}, 0, 10) eq '#REDIRECT ')) {
    $oldId = $id;
    if (($FreeLinks) && ($Text{'text'} =~ /\#REDIRECT\s+\[\[.+\]\]/)) {
      ($id) = ($Text{'text'} =~ /\#REDIRECT\s+\[\[(.+)\]\]/);
      $id = FreeToNormal($id);
    } else {
      ($id) = ($Text{'text'} =~ /\#REDIRECT\s+(\S+)/);
    }
    if (ValidId($id) eq '') {
      # Later consider revision in rebrowse?
      ReBrowsePage($id, $oldId, 0);
      return;
    } else {  # Not a valid target, so continue as normal page
      $id = $oldId;
      $oldId = '';
    }
  }
  # shortcut if we only need the raw text: no caching, no diffs, no html.
  if ($raw) {
    print GetHttpHeader('text/plain');
    if ($raw == 2) {
      print $Section{'ts'} . " # Do not delete this line when editing!\n";
    }
    print $Text{'text'};
    return;
  }
  # handle subtitle for old revisions, if these exist, and open keep file
  my $openKept = 0;
  my $revision = GetParam('revision', '');
  $revision =~ s/\D//g; # Remove non-numeric chars
  my $goodRevision = $revision;
  if ($revision ne '' and $revision ne $Section{'revision'}) {
    OpenKeptRevisions('text_default');
    $openKept = 1;
    if (!defined($KeptRevisions{$revision})) {
      $goodRevision = ''; # reset if requested revision is not available
      $Message .= $q->p(Ts('Revision %s not available', $revision)
			. ' (' . T('showing current revision instead') . ')');
    } else {
      OpenKeptRevision($revision);
      $Message .= $q->p(Ts('Showing revision %s', $goodRevision));
    }
  }
  # print header
  print GetHeader($id, QuoteHtml($id), $oldId);
  # print diff, if required
  my $showDiff = GetParam('diff', 0);
  if ($UseDiff && $showDiff) {
    my $diffRevision = GetParam('diffrevision', $goodRevision);
    # Later try to avoid the following keep-loading if possible?
    OpenKeptRevisions('text_default')  if (!$openKept);
    PrintHtmlDiff($showDiff, $id, $diffRevision, $revision, $Text{'text'});
    print $q->hr();
  }
  # print HTML of the main text
  print '<div class="content">';
  if ($revision eq '' && GetPageCache('blocks') && GetParam('cache',1)) {
    PrintCache(GetPageCache('blocks'));
  } else {
    $revision = 'default' if $revision eq '' and $Section{'revision'} == 0;
    PrintWikiToHTML($Text{'text'}, $revision);
  }
  print '</div>';
  my $embed = GetParam('embed', $EmbedWiki);
  if ($rc) {
    print '<div class="rc">';
    print $q->hr()  if (!$embed);
    DoRc(\&GetRcHtml);
    print '</div>';
  }
  if ($RefererTracking && !$embed) {
    my $referers = RefererTrack($id);
    print $referers if $referers;
  }
  PrintFooter($id, $goodRevision);
}

sub ReBrowsePage {
  my ($id, $oldId, $minor) = @_;
  if ($oldId ne '') {   # Target of #REDIRECT (loop breaking)
    print GetRedirectPage("action=browse&id=$id&oldid=$oldId",
                           $id, $minor);
  } else {
    print GetRedirectPage($id, $id, $minor);
  }
}

# == Recent changes and RSS

sub DoRcText {
  print GetHttpHeader('text/plain');
  DoRc(\&GetRcText);
}

sub DoRc {
  my ($GetRC) = @_;
  my ($fileData, $rcline, $i, $daysago, $lastTs, $ts, $idOnly);
  my (@fullrc, $status, $oldFileData, $firstTs, $errorText);
  my $starttime = 0;
  my $showbar = 0;
  my $showHTML = $GetRC eq \&GetRcHtml; # Special (normative) case
  if (GetParam('from', 0)) {
    $starttime = GetParam('from', 0);
   if( $showHTML ) {
      print $q->h2(Ts('Updates since %s', TimeToText($starttime)));
    }
  } else {
    $daysago = GetParam('days', 0);
    if ($daysago) {
      $starttime = $Now - ((24*60*60)*$daysago);
      if( $showHTML ) {
	print $q->h2(Ts('Updates in the last %s day'
			. (($daysago != 1)?'s':''), $daysago));
      }
      # Note: must have two translations (for "day" and "days")
      # Following comment line is for translation helper script
      # Ts('Updates in the last %s days', '');
    }
  }
  if ($starttime == 0) {
    $starttime = $Now - ((24*60*60)*$RcDefault);
    if( $showHTML ) {
      print $q->h2(Ts('Updates in the last %s day'
		      . (($RcDefault != 1)?'s':''), $RcDefault));
    }
    # Translation of above line is identical to previous version
  }
  # Read rclog data (and oldrclog data if needed)
  ($status, $fileData) = ReadFile($RcFile);
  $errorText = '';
  if (!$status) {
    # Save error text if needed.
    $errorText = $q->p($q->strong(Ts('Could not open %s log file', $RCName)
				  . ':') . ' ' . $RcFile)
      . $q->p(T('Error was') . ':')
      . $q->pre($!)
      . $q->p(T('Note: This error is normal if no changes have been made.'));
  }
  @fullrc = split(/\n/, $fileData);
  $firstTs = 0;
  if (@fullrc > 0) {  # Only false if no lines in file
    ($firstTs) = split(/$FS3/, $fullrc[0]);
  }
  if (($firstTs == 0) || ($starttime <= $firstTs)) {
    ($status, $oldFileData) = ReadFile($RcOldFile);
    if ($status) {
      @fullrc = split(/\n/, $oldFileData . $fileData);
    } else {
      if ($errorText ne '') {  # could not open either rclog file
	print $errorText;
	print $q->p($q->strong(Ts('Could not open old %s log file', $RCName)
				  . ':') . ' ' . $RcOldFile)
	  . $q->p(T('Error was') . ':')
	  . $q->pre($!);
        return;
      }
    }
  }
  $lastTs = 0;
  if (@fullrc > 0) {  # Only false if no lines in file
    ($lastTs) = split(/$FS3/, $fullrc[$#fullrc]);
  }
  $lastTs++  if (($Now - $lastTs) > 5);  # Skip last unless very recent
  $idOnly = GetParam('rcidonly', '');
  if ($idOnly && $showHTML) {
    print '<b>(' . Ts('for %s only', ScriptLink(UrlEncode($idOnly), $idOnly))
	  . ')</b><br>';
  }
  if( $showHTML ) {
    foreach $i (@RcDays) {
      print ' | '  if $showbar;
      $showbar = 1;
      print ScriptLink("action=rc&days=$i",
			Ts('%s day' . (($i != 1)?'s':''), $i));
	# Note: must have two translations (for 'day' and 'days')
	# Following comment line is for translation helper script
	# Ts('%s days', '');
    }
    print '<br>' . ScriptLink("action=rc&from=$lastTs",
			       T('List new changes starting from'));
    print " " . TimeToText($lastTs) . "<br>\n";
  }
  # Later consider a binary search?
  $i = 0;
  while ($i < @fullrc) {  # Optimization: skip old entries quickly
    ($ts) = split(/$FS3/, $fullrc[$i]);
    if ($ts >= $starttime) {
      $i -= 1000  if ($i > 0);
      last;
    }
    $i += 1000;
  }
  $i -= 1000  if (($i > 0) && ($i >= @fullrc));
  for (; $i < @fullrc ; $i++) {
    ($ts) = split(/$FS3/, $fullrc[$i]);
    last if ($ts >= $starttime);
  }
  if ($i == @fullrc && $showHTML) {
    print '<br><strong>' . Ts('No updates since %s',
			      TimeToText($starttime)) . "</strong><br>\n";
  } else {
    splice(@fullrc, 0, $i);  # Remove items before index $i
    # Later consider an end-time limit (items older than X)
    print &$GetRC(@fullrc);
  }
  print '<p>' . Ts('Page generated %s', TimeToText($Now)), "<br>\n" if $showHTML;
}

sub GetRc {
  my $printDailyTear = shift;
  my $printRCLine = shift;
  my @outrc = @_;
  my ($rcline, $date, $newtop, $showedit, $all, $idOnly, $langFilter);
  my ($ts, $pagename, $summary, $minor, $host, $kind, $extraTemp);
  my %extra = ();
  my %changetime = ();
  my @languages;
  # Slice minor edits
  $showedit = GetParam('showedit', $ShowEdits);
  $langFilter = GetParam('rclang', '');
  # Filter out some entries if not showing all changes
  if ($showedit != 1) {
    my @temprc = ();
    foreach $rcline (@outrc) {
      ($ts, $pagename, $summary, $minor, $host) = split(/$FS3/, $rcline);
      if ($showedit == 0) {  # 0 = No edits
	push(@temprc, $rcline)  if (!$minor);
      } else {               # 2 = Only edits
	push(@temprc, $rcline)  if ($minor);
      }
      $changetime{$pagename} = $ts;
    }
    @outrc = @temprc;
  }
  foreach $rcline (@outrc) {
    ($ts, $pagename) = split(/$FS3/, $rcline);
    $changetime{$pagename} = $ts;
  }
  $date = '';
  $all = GetParam('all', 0);
  $newtop = GetParam('newtop', $RecentTop);
  $idOnly = GetParam('rcidonly', '');
  @outrc = reverse @outrc if ($newtop);
  foreach $rcline (@outrc) {
    ($ts, $pagename, $summary, $minor, $host, $kind, $extraTemp)
      = split(/$FS3/, $rcline);
    # Later: need to change $all for new-RC?
    next  if (not $all and $ts < $changetime{$pagename});
    next  if ($idOnly and $idOnly ne $pagename);
    %extra = split(/$FS2/, $extraTemp, -1);
    @languages = split(/$FS1/, $extra{'languages'});
    next  if ($langFilter and not grep(/$langFilter/, @languages));
    if ($date ne CalcDay($ts)) {
      $date = CalcDay($ts);
      &$printDailyTear($date);
    }
    &$printRCLine( $pagename, $ts, $host, $extra{'name'},
		   $summary, $minor, $extra{'revision'}, \@languages);
  }
}

sub GetRcHtml {
  my ($html, $inlist);
  # Optimize param fetches out of main loop
  my $all = GetParam('all', 0);
  my $rcchangehist = GetParam('rcchangehist', 1);
  # Optimize translations out of main loop
  my $tEdit    = T('(minor)');
  my $tDiff    = T('(diff)');
  my $tHistory = T('history');
  GetRc
    # printDailyTear
    sub {
      my $date = shift;
      if ($inlist) {
	$html .= '</ul>';
	$inlist = 0;
      }
      $html .= $q->p($q->strong($date));
      if (!$inlist) {
	$html .= '<ul>';
	$inlist = 1;
      }
    },
    # printRCLine
    sub {
      my($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages) = @_;
      my($author, $sum, $edit, $count, $link, $lang);
      $host = QuoteHtml($host);
      $author = GetAuthorLink($host, $userName);
      $sum = $q->strong('[' . QuoteHtml($summary) . ']')  if $summary;
      $edit = $q->em($tEdit)  if $minor;
      if (!$all) {
	$count = '(' . GetHistoryLink($pagename, $tHistory) . ')';
      }
      $lang = '[' . join(', ', @{$languages}) . ']'  if @{$languages};
      if ($UseDiff && GetParam('diffrclink', 1)) {
	if ($minor) {
	  $link .= ScriptLinkDiff(2, $pagename, $tDiff, ''); # minor
	} else {
	  $link .= ScriptLinkDiff(1, $pagename, $tDiff, ''); # major
	}
      }
      $html .= $q->li($link, GetPageLink($pagename), CalcTime($timestamp),
		      $count, $edit, $sum, $lang, '. . . . .', $author, "\n");
    },
    @_;
  $html .= '</ul>' if ($inlist);
  return $html;
}

sub RcTextItem {
  my ($name, $value) = @_;
  $value =~ s/\n+$//;
  $value =~ s/\n+/\n /;
  return $name . ': ' . $value . "\n" if $value;
}

sub GetRcText {
  my ($text);
  local $RecentLink = 0;
  print RcTextItem('title', $SiteName)
    . RcTextItem('description', $SiteDescription)
    . RcTextItem('link', $ScriptName)
    . RcTextItem('generator', 'OddMuse')
    . RcTextItem('creator', $RssPublisher)
    . RcTextItem('rights', $RssRights);
  # Now call GetRc with some blocks of code as parameters:
  GetRc
    sub {},
    sub {
      my($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages) = @_;
      my $uri = $ScriptName . (GetParam('all', 0)
			       ? "?action=browse\&revision=$revision\&id=$pagename"
			       : "/$pagename");
      $pagename =~ s/_/ /g;
      print "\n" . RcTextItem('title', $pagename)
      . RcTextItem('description', $summary)
      . RcTextItem('generator', $userName ? $userName . ' ' . Ts('from %s', $host) : $host)
      . RcTextItem('language', join(', ', @{$languages}))
      . RcTextItem('uri', $uri)
      . RcTextItem('last-modified', CalcDay($timestamp));
    },
    @_;
  return $text;
}

sub GetRcRss {
  my ($QuotedFullUrl, $ChannelAbout, $diffPrefix, $historyPrefix);
  # Normally get URL from script, but allow override.
  $FullUrl = $q->url(-full=>1)  if ($FullUrl eq '');
  $QuotedFullUrl = QuoteHtml($FullUrl);
  $diffPrefix = $QuotedFullUrl . QuoteHtml("?action=browse\&diff=1\&id=");
  $historyPrefix = $QuotedFullUrl . QuoteHtml("?action=history\&id=");
  $SiteDescription = QuoteHtml($SiteDescription);
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
  $year += 1900;
  my $date = sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00",
		   $year, $mon+1, $mday, $hour, $min, $sec);
  require XML::RSS;
  my $rss = new XML::RSS (version => '1.0', encoding => $HttpCharset);
  $rss->add_module(
    prefix => 'wiki',
    uri    => 'http://purl.org/rss/1.0/modules/wiki/'
  );
  $rss->channel(
    title         => QuoteHtml($SiteName),
    link          => $QuotedFullUrl . QuoteHtml("?$RCName"),
    description   => $SiteDescription,
    dc => {
      publisher   => $RssPublisher,
      contributor => $RssContributor,
      date        => $date,
      rights      => $RssRights,
    },
    wiki => {
      interwiki   => $InterWikiMoniker,
    },
  );
  $rss->image(
    title  => QuoteHtml($SiteName),
    url    => $RssImageUrl,
    link   => $QuotedFullUrl,
  );
  # Now call GetRc with some blocks of code as parameters:
  GetRc
    # printDailyTear
    sub {},
    # printRCLine
    sub {
      # ignore languages for the moment
      my( $pagename, $timestamp, $host, $userName, $summary, $minor, $revision ) = @_;
      my( $description, $author, $status, $importance, $date );
      my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($timestamp);
      my $name = FreeToNormal($pagename);
      $name =~ s/_/ /g;
      $year += 1900;
      $date = sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00",
	$year, $mon+1, $mday, $hour, $min, $sec);
      if ($summary ne '') {
	$description = QuoteHtml($summary);
      }
      if( $userName ) {
	$author = QuoteHtml($userName);
      } else {
	$author = $host;
      }
      $status = (1 == $revision) ? 'new' : 'updated';
      $importance = $minor ? 'minor' : 'major';
      $rss->add_item(
        title         => QuoteHtml($name),
	link          => $QuotedFullUrl . '?action=browse'
		                        . '&amp;id=' . $pagename
		                        . '&amp;revision=' . $revision,
	description   => $description,
	dc => {
          date        => $date,
	  contributor => $author,
	},
	wiki => {
	  status      => $status,
	  importance  => $importance,
	  diff        => $diffPrefix . $pagename,
	  version     => $revision,
	  history     => $historyPrefix . $pagename,
	},
      );
    },
    # RC Lines
    @_;
  # Only take the first 15 entries
  my $limit = GetParam('rsslimit', 14);
  @{$rss->{'items'}} = @{$rss->{'items'}}[0..$limit]  unless $limit == 'all';
  return $rss->as_string;
}

sub DoRss {
  print GetHttpHeader('text/plain');
  DoRc(\&GetRcRss);
}

# == Random ==

sub DoRandom {
  my ($id, @pageList);
  @pageList = AllPagesList();
  $id = $pageList[int(rand($#pageList + 1))];
  ReBrowsePage($id, '', 0);
}

# History

sub DoHistory {
  my $id = shift;
  my ($html, $row, $newText);
  print GetHeader('',QuoteHtml(Ts('History of %s', $id)), '') . '<br>';
  OpenPage($id);
  OpenDefaultText();
  if( $UseDiff ) {
    print <<EOF ;
<form action='$ScriptName' METHOD='GET'>
<input type='hidden' name='action' value='browse'/>
<input type='hidden' name='diff' value='1'/>
<input type='hidden' name='id' value='$id'/>
<table class="history">
EOF
  }
  $html = GetHistoryLine($id, $Page{'text_default'}, $row++);
  OpenKeptRevisions('text_default');
  foreach (reverse sort {$a <=> $b} keys %KeptRevisions) {
    next  if ($_ eq '');  # (needed?)
    $html .= GetHistoryLine($id, $KeptRevisions{$_}, $row++);
  }
  print $html;
  if( $UseDiff )
    {
      my $label = T('Compare');
      print "<tr><td align='center'><input type='submit' value='$label'/></td></table></form><hr>";
      PrintHtmlDiff( 1, $id, '', '', $newText );
    }
  PrintFooter($id, 'history');
}

sub GetHistoryLine {
  my ($id, $section, $row) = @_;
  my ($html, $expirets, $rev, $summary, $host, $user, $ts, $minor);
  my (%sect, %revtext);
  %sect = split(/$FS2/, $section, -1);
  %revtext = split(/$FS3/, $sect{'data'});
  $rev = $sect{'revision'};
  $summary = $revtext{'summary'};
  if ((defined($sect{'host'})) && ($sect{'host'} ne '')) {
    $host = $sect{'host'};
  } else {
    $host = $sect{'ip'};
  }
  $user = $sect{'username'};
  $ts = $sect{'ts'};
  if ($revtext{'minor'}) {
    $minor = '<i>' . T('(minor)') . '</i> ';
  } else {
    $minor = T(' . . . . ');
  }
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  if ($UseDiff) {
    my ($c1, $c2);
    $c1 = 'checked="checked"' if 1 == $row;
    $c2 = 'checked="checked"' if 0 == $row;
    $html .= "<tr><td align='center'><input type='radio' name='diffrevision' value='$rev' $c1/> ";
    $html .= "<input type='radio' name='revision' value='$rev' $c2/></td><td>";
  }
  if (0 == $row) { # current revision
    $html .= GetPageLink($id, Ts('Revision %s', $rev)) . ' ';
  } else {
    $html .= GetOldPageLink('browse', $id, $rev, Ts('Revision %s', $rev)) . ' ';
  }
  $html .= $minor . ' ' . TimeToText($ts) . ' ' . T('by') . ' ' . GetAuthorLink($host, $user) . ' ';
  if (defined($summary) && ($summary ne '')) {
    $summary = QuoteHtml($summary);   # Thanks Sunir! :-)
    $html .= "<b>[$summary]</b> ";
  }
  $html .= $UseDiff ? "</tr>\n" : "<br>\n";
  return $html;
}

# == HTML and page-oriented functions ==

sub GetOldPageParameters {
  my ($kind, $id, $revision) = @_;
  $id = FreeToNormal($id) if $FreeLinks;
  return "action=$kind&revision=$revision&id=" . UrlEncode($id);
}

sub GetOldPageLink {
  my ($kind, $id, $revision, $name) = @_;
  $name =~ s/_/ /g if $FreeLinks;
  return ScriptLink(GetOldPageParameters($kind, $id, $revision), $name);
}

sub GetSearchLink {
  my $id = shift;
  my $name = $id;
  if ($FreeLinks) {
    $name =~ s/_/ /g;  # Display with spaces
    $id =~ s/_/+/g;    # Search for url-escaped spaces
  }
  return ScriptLink('search=' . UrlEncode($id), $name);
}

sub ScriptLinkDiff {
  my ($diff, $id, $text, $rev) = @_;
  $rev = "&revision=$rev"  if ($rev ne '');
  return ScriptLink("action=browse&diff=$diff$rev&id=" . UrlEncode($id), $text);
}

sub GetAuthorLink {
  my ($host, $userName) = @_;
  my ($html, $title, $userNameShow);
  $userNameShow = $userName;
  if ($FreeLinks) {
    $userName     =~ s/ /_/g;
    $userNameShow =~ s/_/ /g;
  }
  if (ValidId($userName) ne '') {  # Invalid under current rules
    $userName = '';  # Just pretend it isn't there.
  }
  if ($userName and $RecentLink) {
    $html = $q->span({-class=>'author'},
		     $q->a({-href=>"$ScriptName?$userName",
			    -title=>Ts('from %s', $host)}, $userNameShow));
  } elsif ($userName) {
    $html = $q->span({-class=>'author'}, $userNameShow)
      . ' ' . Ts('from %s', $host);
  } else {
    $html = $host;
  }
  return $html;
}

sub GetHistoryLink {
  my ($id, $text) = @_;
  if ($FreeLinks) {
    $id =~ s/ /_/g;
  }
  return ScriptLink('action=history&amp;id=' . UrlEncode($id), $text);
}

sub GetHeader {
  my ($id, $title, $oldId) = @_;
  my $result = '';
  my $embed = GetParam('embed', $EmbedWiki);
  my $altText = T('[Home]');
  $result = GetHttpHeader();
  if ($FreeLinks) {
    $title =~ s/_/ /g;   # Display as spaces
  }
  if ($oldId ne '') {
    $Message .= $q->p('(' . Ts('redirected from %s', GetEditLink($oldId, $oldId)) . ')');
  }
  $result .= GetHtmlHeader("$SiteName: $title", $id);
  if ($embed) {
    $result .= $q->div({-class=>'header'}, $q->div({-class=>'message'}, $Message))  if $Message;
    return $result;
  }
  $result .= '<div class="header">';
  if ((!$embed) && ($LogoUrl ne '')) {
    $result .= ScriptLink($HomePage, "<img src=\"$LogoUrl\" alt=\"$altText\" class=\"logo\">");
  }
  if (GetParam('toplinkbar', $TopLinkBar)) {
    $result .= GetGotoBar($id);
    if (%SpecialDays) {
      my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
      if ($SpecialDays{($mon + 1) . '-' . $mday}) {
	$result .= $q->br() . $q->span({-class=>'specialdays'},
				       $SpecialDays{($mon + 1) . '-' . $mday});
      }
    }
  }
  $result .= $q->div({-class=>'message'}, $Message)  if $Message;
  if ($id ne '') {
    $result .= $q->h1(GetSearchLink($id));
  } else {
    $result .= $q->h1($title);
  }
  $result .= '</div>';
  return $result;
}

sub GetHttpHeader {
  my ($type) = @_;
  my ($now, $name, $pwd, %headers);
  $now = gmtime;
  $type = 'text/html'  unless $type;
  %headers = (-pragma=>'no-cache',
	      -cache_control=>'no-cache',
	      -last_modified=>"$now",
	      -expires=>"+10s");
  if ($HttpCharset ne '') {
    $headers{-type} = "$type; charset=$HttpCharset";
  } else {
    $headers{-type} = $type;
  }
  my $cookie = Cookie();
  $headers{-cookie} = $cookie  if $cookie;
  return $q->header(%headers);
}

sub Cookie {
  my %params;
  my $changed = 0;
  foreach (keys %CookieParameters) {
    my $default = $CookieParameters{$_};
    my $value = GetParam($_, $default);
    $params{$_} = $value  if $value ne $default;
    $changed = 1  if $value ne $OldCookie{$_} and ($OldCookie{$_} ne '' or $value ne $default);
    # $Message .= "<p>$_: $value ($default), old: $OldCookie{$_}";
  }
  if ($changed) {
    my $cookie = join($FS1, map {$_ . $FS1 . $params{$_}} keys(%params));
    my $result = $q->cookie(-name=>$CookieName,
			    -value=>$cookie,
			    -expires=>'+2y');
    $Message .= $q->p(T('Cookie: ') . $result);
    return $result;
  }
  return '';
}

sub GetHtmlHeader {
  my ($title, $id) = @_;
  my $html = '';
  $html .= $q->base({-href=>$SiteBase}) if $SiteBase;
  if ($StyleSheet ne '') {
    $html .= qq(<link type="text/css" rel="stylesheet" href="$StyleSheet">\n);
  } elsif ($StyleSheetPage ne '') {
    $html .= $q->style({-type=>'text/css'}, GetPageContent($StyleSheetPage));
  } else {
    $html .= $q->style({-type=>'text/css'},<<EOT);
<!--
body { background-color:#FFF; color:#000; }
a:link { background-color:#FFF; color:#00F; }
a:visited { background-color:#FFF; color:#A0A; }
a:active { background-color:#FFF; color:#F00; }
img.logo { float: right; clear: right; border-style:none; }
div.diff { padding-left:5%; padding-right:5%; }
div.old { background-color:#FFFFAF; color:#000; }
div.new { background-color:#CFFFCF; color:#000; }
div.refer { padding-left:5%; padding-right:5%; font-size:smaller; }
div.message { background-color:#FEE; color:#000; }
table.history { border-style:none; }
td.history { border-style:none; }
table.user { border-style:solid; border-width:thin; }
table.user tr td { border-style:solid; border-width:thin; padding:5px; text-align:center; }
span.result { font-size:larger; }
span.info { font-size:smaller; font-style:italic; }
div.rss { background-color:#EEF; color:#000; }
div.rss a:link { background-color:#EEF; color:#00F; }
div.rss a:visited { background-color:#EEF; color:#A0A; }
div.rss a:active { background-color:#EEF; color:#F00; }
a.definition:before { content:"[::"; }
a.definition:after { content:"]"; }
a.link:before { content:"[##"; }
a.link:after { content:"]" }
-->
EOT
  }
  # robot FOLLOW tag for RecentChanges only
  # robot INDEX tag for wiki pages only
  # Note that we need to allow INDEX for RecentChanges, else new pages
  # will never be added
  if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)) {
    $html .= '<meta name="robots" content="INDEX,FOLLOW">';
  } elsif ($id eq '') {
    $html .= '<meta name="robots" content="NOINDEX,NOFOLLOW">';
  } else {
    $html .= '<meta name="robots" content="INDEX,NOFOLLOW">';
  }
  # finish
  my $theme = GetParam('theme',$q->url());
  $html = qq(<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n<html>)
    . $q->head($q->title($q->escapeHTML($title)) . $html)
    . '<body class="' . $theme . '">';
  return $html;
}

sub PrintFooter {
  my ($id, $rev) = @_;
  if (GetParam('embed', $EmbedWiki)) {
    print $q->end_html;
    return;
  }
 if ($CommentsPrefix ne '' and $id and $rev ne 'history' and $rev ne 'edit')  {
    if ($OpenPageName =~ /^$CommentsPrefix/) {
      my $userName = GetParam('username', '');
      print $q->div({-class=>'comment'}, '<p>'
		    . GetFormStart()
		    . GetHiddenValue("title", $OpenPageName)
		    . GetHiddenValue("oldtime", $Now + 3600) # one hour
		    . GetHiddenValue("oldconflict", 0)
		    . GetHiddenValue("summary" , T("new comment"))
		    . GetHiddenValue("recent_edit", "on")
		    . GetTextArea('aftertext', $NewComment)
		    . '<p>' . T('Username:')
		    . $q->textfield(-name=>'username',
				    -default=>$userName, -override=>1,
				    -size=>20, -maxlength=>50)
		    . $q->p($q->submit(-name=>'Save', -value=>T('Save')))
		    . $q->endform());
    }
  }
  print '<div class="footer">';
  print $q->hr() . GetGotoBar($id);
  # other revisions
  my $revisions;
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    if (UserCanEdit($CommentsPrefix . $id, 0)
	and $OpenPageName !~ /^$CommentsPrefix/) {
      $revisions .= ScriptLink($CommentsPrefix . UrlEncode($OpenPageName),
			       T("Comments on this page"));
    }
    $revisions .= ' | ' if $revisions;
    if (UserCanEdit($id, 0)) {
      if ($rev) { # showing old revision
	$revisions .= GetOldPageLink('edit', $id, $rev,
				   Ts('Edit revision %s of this page', $rev));
      } else { # showing current revision
	$revisions .= GetEditLink($id, T('Edit text of this page'));
      }
    } else { # no permission or generated page
      $revisions .= T('This page is read-only');
    }
  }
  if ($id and $rev ne 'history') {
    $revisions .= ' | ' if $revisions;
    $revisions .= GetHistoryLink($id, T('View other revisions'));
  }
  if ($rev ne '') {
    $revisions .= ' | ' if $revisions;
    $revisions .= GetPageLink($id, T('View current revision'));
  }
  if ($CommentsPrefix and $id =~ /^$CommentsPrefix(.*)/) {
    $revisions .= ' | ' if $revisions;
    $revisions .= GetPageLink($1, T('View original'));
  }
  print $q->br() . $revisions  if $revisions;
  # time stamps
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    print $q->br();
    if ($rev eq '') {		# Only for most current rev
      print T('Last edited');
    } else {
      print T('Edited');
    }
    print ' ' . TimeToText($Section{ts});
    if ($UseDiff) {
      print ' ' . ScriptLinkDiff(1, $id, T('(diff)'), $rev);
    }
  }
  # search
  print $q->br() . GetSearchForm();
  if ($DataDir =~ m|/tmp/|) {
    print $q->br() . $q->strong(T('Warning') . ': ')
      . Ts('Database is stored in temporary directory %s', $DataDir);
  }
  if ($FooterNote ne '') {
    print T($FooterNote);  # Allow local translations
  }
  if (GetParam('validate', $ValidatorLink)) {
    print $q->p(GetValidatorLink());
  }
  if (GetParam('time',0)) {
    print $q->p(Ts('%s seconds', (time - $Now)));
  }
  print '</div>';
  eval {
    local $SIG{__DIE__};
    PrintMyContent($id);
  };
  print $q->end_html;
}

sub GetFormStart {
  return $q->startform('POST', "$ScriptName",
                       "application/x-www-form-urlencoded");
}

sub GetSearchForm {
  my $form = GetFormStart . T('Search:') . ' '
    . $q->textfield(-name=>'search', -size=>20) . ' ';
  if ($ReplaceForm) {
    $form .= T('Replace:') . ' '
      . $q->textfield(-name=>'replace', -size=>20) . ' ';
  }
  return $form . $q->submit('dosearch', T('Go!')) . $q->endform;
}

sub GetValidatorLink {
  my $uri = UrlEncode($q->self_url);
  return $q->a({-href => 'http://validator.w3.org/check?uri=' . $uri},
	       T('Validate HTML'))
    . ' '
    . $q->a({-href => 'http://jigsaw.w3.org/css-validator/validator?uri=' . $uri},
	    T('Validate CSS'));
}

sub GetGotoBar {
  my $id = shift;
  my $bartext;
  $bartext .= join(' | ', map { GetPageLink($_) } @UserGotoBarPages);
  $bartext .= ' | ' . $UserGotoBar  if $UserGotoBar ne '';
  return $q->span({-class=>'gotobar'}, $bartext);
}

sub GetRedirectPage {
  my ($newid, $name, $minor) = @_;
  my ($url, $html);
  my ($nameLink);
  # shortcut if we only need the raw text: no redirect.
  if (GetParam('raw', 0)) {
    $html = GetHttpHeader('text/plain');
    $html .= Ts('Please go on to %s.', $newid);
    return $html;
  }
  # Normally get URL from script, but allow override.
  $FullUrl = $q->url(-full=>1)  if ($FullUrl eq '');
  $url = $FullUrl . '?' . $newid;
  $nameLink = "<a href=\"$url\">$name</a>";
  # NOTE: do NOT use -method (does not work with old CGI.pm versions)
  # Thanks to Daniel Neri for fixing this problem.
  my %headers = (-uri=>$url);
  my $cookie = Cookie;
  if ($cookie) {
    $headers{-cookie} = $cookie;
  }
  return $q->redirect(%headers);
}

# == Difference markup and HTML ==

sub PrintHtmlDiff {
  my ($diffType, $id, $revOld, $revNew, $newText) = @_;
  my ($diffText, $diffTextTwo, $priorName, $links, $usecomma);
  my ($major, $minor, $author, $useMajor, $useMinor, $useAuthor, $cacheName);
  $links = '(';
  $usecomma = 0;
  $major  = ScriptLinkDiff(1, $id, T('major diff'), '');
  $minor  = ScriptLinkDiff(2, $id, T('minor diff'), '');
  $author = ScriptLinkDiff(3, $id, T('author diff'), '');
  $useMajor  = 1;
  $useMinor  = 1;
  $useAuthor = 1;
  if ($diffType == 1) {
    $priorName = T('major');
    $cacheName = 'major';
    $useMajor  = 0;
  } elsif ($diffType == 2) {
    $priorName = T('minor');
    $cacheName = 'minor';
    $useMinor  = 0;
  } elsif ($diffType == 3) {
    $priorName = T('author');
    $cacheName = 'author';
    $useAuthor = 0;
  }
  if ($revOld ne '') {
    # Note: OpenKeptRevisions must have been done by caller.
    # Later optimize if same as cached revision
    $diffText = GetKeptDiff($newText, $revOld, 1);  # 1 = get lock
    if ($diffText eq '') {
      $diffText = T('(The revisions are identical or unavailable.)');
    }
  } else {
    $diffText  = GetCacheDiff($cacheName);
  }
  $useMajor  = 0  if ($useMajor  && ($diffText eq GetCacheDiff('major')));
  $useMinor  = 0  if ($useMinor  && ($diffText eq GetCacheDiff('minor')));
  $useAuthor = 0  if ($useAuthor && ($diffText eq GetCacheDiff('author')));
  $useMajor  = 0  if ((!defined(GetPageCache('oldmajor'))) ||
                      (GetPageCache('oldmajor') < 1));
  $useAuthor = 0  if ((!defined(GetPageCache('oldauthor'))) ||
                      (GetPageCache('oldauthor') < 1));
  if ($useMajor) {
    $links .= $major;
    $usecomma = 1;
  }
  if ($useMinor) {
    $links .= ', '  if ($usecomma);
    $links .= $minor;
    $usecomma = 1;
  }
  if ($useAuthor) {
    $links .= ', '  if ($usecomma);
    $links .= $author;
  }
  if (!($useMajor || $useMinor || $useAuthor)) {
    $links .= T('no other diffs');
  }
  $links .= ')';
  if ((!defined($diffText)) || ($diffText eq '')) {
    $diffText = T('No diff available.');
  }
  print '<div class="diff">';
  if ($revOld ne '') {
    my $currentRevision = T('current revision');
    $currentRevision = Ts('revision %s', $revNew) if $revNew;
      print '<p><b>'
      . Ts('Difference (from revision %s', $revOld)
      . Ts(' to %s)', $currentRevision)
      . "</b> $links "
      . $diffText;
  } else {
    if (($diffType != 2) &&
        ((!defined(GetPageCache("old$cacheName"))) ||
         (GetPageCache("old$cacheName") < 1))) {
      print '<p><b>'
	. Ts('No diff available--this is the first %s revision.', $priorName)
	. "</b> $links";
    } else {
      print '<p><b>'
	. Ts('Difference (from prior %s revision)', $priorName)
        . "</b> $links "
        . $diffText;
    }
  }
  print '</div>';
}

sub GetCacheDiff {
  my ($type) = @_;
  my ($diffText);
  $diffText = GetPageCache("diff_default_$type");
  $diffText = GetCacheDiff('minor')  if ($diffText eq '1');
  $diffText = GetCacheDiff('major')  if ($diffText eq '2');
  return $diffText;
}

# Must be done after minor diff is set and OpenKeptRevisions called
sub GetKeptDiff {
  my ($newText, $oldRevision, $lock) = @_;
  my (%sect, %data, $oldText);
  $oldText = '';
  if (defined($KeptRevisions{$oldRevision})) {
    %sect = split(/$FS2/, $KeptRevisions{$oldRevision}, -1);
    %data = split(/$FS3/, $sect{'data'}, -1);
    $oldText = $data{'text'};
  }
  return ''  if ($oldText eq '');  # Old revision not found
  return GetDiff($oldText, $newText, $lock);
}

sub GetDiff {
  my ($old, $new, $lock) = @_;
  my ($diff_out, $oldName, $newName);
  $old =~ s/[\r\n]+/\n/g;
  $new =~ s/[\r\n]+/\n/g;
  CreateDir($TempDir);
  $oldName = "$TempDir/old_diff";
  $newName = "$TempDir/new_diff";
  if ($lock) {
    RequestLockDir('diff') or return '';
    $oldName .= '_locked';
    $newName .= '_locked';
  }
  WriteStringToFile($oldName, $old);
  WriteStringToFile($newName, $new);
  $diff_out = `diff $oldName $newName`;
  $diff_out =~ s/\\ No newline.*\n//g;   # Get rid of common complaint.
  $diff_out = ImproveDiff($diff_out);
  ReleaseLockDir('diff') if ($lock);
  # No need to unlink temp files--next diff will just overwrite.
  return $diff_out;
}

sub ImproveDiff {
  my $diff = QuoteHtml(shift);
  $diff =~ tr/\r//d;
  my ($tChanged, $tRemoved, $tAdded);
  $tChanged = T('Changed:');
  $tRemoved = T('Removed:');
  $tAdded   = T('Added:');
  my @hunks = split (/^(\d+,?\d*[adc]\d+,?\d*\n)/m, $diff);
  my $result = shift (@hunks);	# intro
  while ($#hunks > 0)		# at least one header and a real hunk
    {
      my $header = shift (@hunks);
      $header =~ s|^(\d+.*c.*)|<p><strong>$tChanged $1</strong>|g
      or $header =~ s|^(\d+.*d.*)|<p><strong>$tRemoved $1</strong>|g
      or $header =~ s|^(\d+.*a.*)|<p><strong>$tAdded $1</strong>|g;
      $result .= $header;
      my $chunk = shift (@hunks);
      my ($old, $new) = split (/^---\n/m, $chunk, 2);
      if ($old and $new) {
	($old, $new) = DiffMarkWords($old, $new);
	$result .= $old . $q->p(T('to')) . "\n" . $new;
      } else {
	if (substr($chunk,0,2) eq '&g') {
	  $result .= DiffAddPrefix(DiffStripPrefix($chunk), '&gt; ', 'new');
	} else {
	  $result .= DiffAddPrefix(DiffStripPrefix($chunk), '&lt; ', 'old');
	}
      }
    }
  return $result;
}

sub DiffMarkWords {
  my $old = DiffStripPrefix(shift);
  my $new = DiffStripPrefix(shift);
  my $oldwords = join("\n",split(/\s+/,$old));
  my $newwords = join("\n",split(/\s+/,$new));
  open(A,">$TempDir/a");
  open(B,">$TempDir/b");
  print A $oldwords;
  print B $newwords;
  close(A);
  close(B);
  my $diff = `diff $TempDir/a $TempDir/b`;
  my $offset = 0; # for every chung this increases
  while ($diff =~ /^(\d+),?(\d*)([adc])(\d+),?(\d*)$/mg) {
    my ($start1,$end1,$type,$start2,$end2) = ($1,$2,$3,$4,$5);
    # changes are like additons + deletions
    if ($type eq 'd' or $type eq 'c') {
      $end1 = $start1 unless $end1;
      $old = DiffHtmlMarkWords($old,$start1+$offset,$end1+$offset);
    }
    if ($type eq 'a' or $type eq 'c') {
      $end2 = $start2 unless $end2;
      $new = DiffHtmlMarkWords($new,$start2+$offset,$end2+$offset);
    }
    $offset++;
  }
  return (DiffAddPrefix($old, '&lt; ', 'old'),
	  DiffAddPrefix($new, '&gt; ', 'new'));
}

sub DiffStripPrefix {
  my $str = shift;
  $str =~ s/^&[lg]t; //gm;
  return $str;
}

sub DiffAddPrefix {
  my ($str, $prefix, $class) = @_;
  my @lines = split(/\n/,$str);
  for my $line (@lines) {
    $line = $prefix . $line;
  }
  return $q->div({-class=>$class},$q->p(join('<br>',@lines)));
}

sub DiffHtmlMarkWords {
  my ($text,$start,$end) = @_;
  my $first = $start - 1;
  my $words = 1 + $end - $start;
  $text =~ s|^((\S+\s*){$first})((\S+\s*?){$words})|$1<strong class="changes">$3</strong>|;
  return $text;
}

# == Database (Page, Section, Text, Kept, User) functions ==

sub OpenNewPage {
  my $id = shift;
  %Page = ();
  $Page{'version'} = 3;      # Data format version
  $Page{'revision'} = 0;     # Number of edited times
  $Page{'tscreate'} = $Now;  # Set once at creation
  $Page{'ts'} = $Now;        # Updated every edit
}

sub OpenNewSection {
  my ($name, $data) = @_;
  %Section = ();
  $Section{'name'} = $name;
  $Section{'version'} = 1;      # Data format version
  $Section{'revision'} = 0;     # Number of edited times
  $Section{'tscreate'} = $Now;  # Set once at creation
  $Section{'ts'} = $Now;        # Updated every edit
  $Section{'ip'} = $ENV{REMOTE_ADDR};
  $Section{'host'} = '';        # Updated only for real edits (can be slow)
  $Section{'username'} = GetParam('username', '');
  $Section{'data'} = $data;
  $Page{$name} = join($FS2, %Section);  # Replace with save?
}

sub OpenNewText {
  my $name = shift;  # Name of text (usually 'default')
  %Text = ();
  if (not $CommentsPrefix or $OpenPageName !~ /^$CommentsPrefix(.*)/) {
    $Text{'text'} = T($NewText);
  }
  $Text{'text'} .= "\n"  if $Text{'text'} !~ /^\n$/;
  $Text{'minor'} = 0;      # Default as major edit
  $Text{'newauthor'} = 1;  # Default as new author
  $Text{'summary'} = '';
  OpenNewSection("text_$name", join($FS3, %Text));
}

sub GetPageDirectory {
  my $id = shift;
  if ($id =~ /^([a-zA-Z])/) {
    return uc($1);
  }
  return 'other';
}

sub GetPageFile {
  my $id = shift;
  return $PageDir . '/' . GetPageDirectory($id) . "/$id.db";
}

sub OpenPage {
  my $id = shift;
  my ($fname, $data);
  if ($OpenPageName eq $id) {
    return;
  }
  %Section = ();
  %Text = ();
  $fname = GetPageFile($id);
  if (-f $fname) {
    $data = ReadFileOrDie($fname);
    %Page = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  } else {
    OpenNewPage($id);
  }
  if ($Page{'version'} != 3) {
    UpdatePageVersion();
  }
  $OpenPageName = $id;
}

sub OpenSection {
  my $name = shift;
  if (!defined($Page{$name})) {
    OpenNewSection($name, '');
  } else {
    %Section = split(/$FS2/, $Page{$name}, -1);
  }
}

sub OpenText {
  my $name = shift;
  if (!defined($Page{"text_$name"})) {
    OpenNewText($name);
  } else {
    OpenSection("text_$name");
    %Text = split(/$FS3/, $Section{'data'}, -1);
  }
}

sub OpenDefaultText {
  my $id = shift;
  OpenText('default');
  # show README for first timers
  if ($Section{'revision'} == 0 and $id eq $HomePage
      and (open(F,'README') or open(F,"$DataDir/README"))) {
    local $/ = undef;   # Read complete files
    $Text{'text'} = <F>;
    close F;
  }
}

sub GetPageContent {
  my $id = shift;
  my $fname = GetPageFile($id);
  if (-f $fname) {
    my $data = ReadFileOrDie($fname);
    my %tempPage = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
    my %tempSection = split(/$FS2/, $tempPage{'text_default'}, -1);
    my %tempText = split(/$FS3/, $tempSection{'data'}, -1);
    return $tempText{'text'};
  }
}

# Called after OpenKeptRevisions
sub OpenKeptRevision {
  my ($revision) = @_;
  %Section = split(/$FS2/, $KeptRevisions{$revision}, -1);
  %Text = split(/$FS3/, $Section{'data'}, -1);
}

sub GetPageCache {
  my $name = shift;
  return $Page{"cache_$name"};
}

# Always call SavePage within a lock.
sub SavePage {
  my $quiet = shift;
  my $file = GetPageFile($OpenPageName);
  if (not $quiet) {
    $Page{'revision'} += 1;    # Number of edited times
    $Page{'ts'} = $Now;        # Updated every edit
  }
  CreatePageDir($PageDir, $OpenPageName);
  WriteStringToFile($file, join($FS1, %Page));
}

sub SaveSection {
  my ($name, $data) = @_;
  $Section{'revision'} += 1;   # Number of edited times
  $Section{'ts'} = $Now;       # Updated every edit
  $Section{'ip'} = $ENV{REMOTE_ADDR};
  $Section{'username'} = GetParam('username', '');
  $Section{'data'} = $data;
  $Page{$name} = join($FS2, %Section);
}

sub SaveText {
  my $name = shift;
  SaveSection("text_$name", join($FS3, %Text));
}

sub SaveDefaultText {
  SaveText('default');
}

sub SetPageCache {
  my ($name, $data) = @_;
  $Page{"cache_$name"} = $data;
}

sub UpdatePageVersion {
  ReportError(T('Bad page version (or corrupt page).'));
}

sub GetKeepFile {
  my $id = shift;
  return $KeepDir . '/' . GetPageDirectory($id) . "/$id.kp";
}

sub KeepFileName {
  return GetKeepFile($OpenPageName);
}

sub SaveKeepSection {
  my $file = KeepFileName();
  my $data;
  return  if ($Section{'revision'} < 1);  # Don't keep 'empty' revision
  $Section{'keepts'} = $Now;
  $data = $FS1 . join($FS2, %Section);
  CreatePageDir($KeepDir, $OpenPageName);
  AppendStringToFile($file, $data);
}

sub ExpireKeepFile {
  my ($fname, $data, @kplist, %tempSection, $expirets);
  my ($anyExpire, $anyKeep, $expire, %keepFlag, $sectName, $sectRev);
  my ($oldMajor, $oldAuthor);
  return unless $KeepDays;
  $fname = KeepFileName();
  return  if (!(-f $fname));
  $data = ReadFileOrDie($fname);
  @kplist = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  return  if (length(@kplist) < 1);  # Also empty
  shift(@kplist)  if ($kplist[0] eq '');  # First can be empty
  return  if (length(@kplist) < 1);  # Also empty
  %tempSection = split(/$FS2/, $kplist[0], -1);
  if (!defined($tempSection{'keepts'})) {
#   die('Bad keep file.' . join('|', %tempSection));
    return;
  }
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return  if ($tempSection{'keepts'} >= $expirets);  # Nothing old enough
  $anyExpire = 0;
  $anyKeep   = 0;
  %keepFlag  = ();
  $oldMajor  = GetPageCache('oldmajor');
  $oldAuthor = GetPageCache('oldauthor');
  foreach (reverse @kplist) {
    %tempSection = split(/$FS2/, $_, -1);
    $sectName = $tempSection{'name'};
    $sectRev = $tempSection{'revision'};
    $expire = 0;
    if ($sectName eq 'text_default') {
      if (($KeepMajor  && ($sectRev == $oldMajor)) ||
          ($KeepAuthor && ($sectRev == $oldAuthor))) {
        $expire = 0;
      } elsif ($tempSection{'keepts'} < $expirets) {
        $expire = 1;
      }
    } else {
      if ($tempSection{'keepts'} < $expirets) {
        $expire = 1;
      }
    }
    if (!$expire) {
      $keepFlag{$sectRev . ',' . $sectName} = 1;
      $anyKeep = 1;
    } else {
      $anyExpire = 1;
    }
  }
  if (!$anyKeep) {  # Empty, so remove file
    unlink($fname);
    return;
  }
  return  if (!$anyExpire);  # No sections expired
  open (OUT, ">$fname") or die (Ts('cant write %s', $fname) . ": $!");
  foreach (@kplist) {
    %tempSection = split(/$FS2/, $_, -1);
    $sectName = $tempSection{'name'};
    $sectRev = $tempSection{'revision'};
    if ($keepFlag{$sectRev . ',' . $sectName}) {
      print OUT $FS1, $_;
    }
  }
  close(OUT);
}

sub OpenKeptList {
  my ($fname, $data);
  @KeptList = ();
  $fname = KeepFileName();
  return  if (!(-f $fname));
  $data = ReadFileOrDie($fname);
  @KeptList = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
}

sub OpenKeptRevisions {
  my $name = shift;  # Name of section
  my (%tempSection);
  %KeptRevisions = ();
  OpenKeptList();
  foreach (@KeptList) {
    %tempSection = split(/$FS2/, $_, -1);
    next  if ($tempSection{'name'} ne $name);
    $KeptRevisions{$tempSection{'revision'}} = $_;
  }
}

sub GetTextAtTime {
  my ($ts) = @_;
  my (%tempSection, %tempText, $revision);
  # OpenPage() was already called
  OpenKeptList; # sets @KeptList
  OpenKeptRevisions('text_default'); # sets $KeptRevisions{<revision>} = <section>
  foreach $revision (keys %KeptRevisions) {
    %tempSection = split(/$FS2/, $KeptRevisions{$revision}, -1);
    if ($tempSection{'ts'} eq $ts) {
      %tempText = split(/$FS3/, $tempSection{'data'}, -1);
      return $tempText{'text'};
    }
  }
  return '';
}

# == Misc. functions ==

sub ReportError {
  my ($errmsg) = @_;
  print $q->header, '<H2>', $errmsg, '</H2>', $q->end_html;
}

sub ValidId {
  my $id = shift;
  if (length($id) > 120) {
    return Ts('Page name is too long: %s', $id);
  }
  if ($id =~ m| |) {
    return Ts('Page name may not contain space characters: %s', $id);
  }
  if ($FreeLinks) {
    $id =~ s/ /_/g;
    if (!($id =~ m|^$FreeLinkPattern$|)) {
      return Ts('Invalid Page %s', $id);
    }
    if ($id =~ m|\.db$|) {
      return Ts('Invalid Page %s (must not end with .db)', $id);
    }
    if ($id =~ m|\.lck$|) {
      return Ts('Invalid Page %s (must not end with .lck)', $id);
    }
    return '';
  } else {
    if (!($id =~ /^$LinkPattern$/)) {
      return Ts('Invalid Page %s', $id);
    }
  }
  return '';
}

sub ValidIdOrDie {
  my $id = shift;
  my $error;
  $error = ValidId($id);
  if ($error ne '') {
    ReportError($error);
    return 0;
  }
  return 1;
}

# == Lock files ==

sub GetLockedPageFile {
  my $id = shift;
  return $PageDir . '/' . GetPageDirectory($id) . "/$id.lck";
}

sub RequestLockDir {
  my ($name, $tries, $wait, $errorDie) = @_;
  my ($lockName, $n);
  $tries = 4 unless $tries;
  $wait = 2 unless $wait;
  $errorDie = 0 unless $errorDie;
  CreateDir($TempDir);
  $lockName = $LockDir . $name;
  $n = 0;
  while (mkdir($lockName, 0555) == 0) {
    if ($! != 17) {
      die(Ts('can not make %s', $LockDir) . ": $!\n")  if $errorDie;
      return 0;
    }
    return 0  if ($n++ >= $tries);
    sleep($wait);
  }
  return 1;
}

sub ReleaseLockDir {
  my $name = shift;
  rmdir($LockDir . $name);
}

sub RequestLock {
  # 10 tries, 3 second wait, die on error
  return RequestLockDir('main', 10, 3, 1);
}

sub ReleaseLock {
  ReleaseLockDir('main');
}

sub ForceReleaseLock {
  my ($pattern) = @_;
  my $forced;
  foreach my $name (glob $pattern) {
    # First try to obtain lock (in case of normal edit lock)
    $forced = 1 if !RequestLockDir($name, 5, 3, 0);
    ReleaseLockDir($name);  # Release the lock, even if we didn't get it.
  }
  return $forced;
}

sub DoUnlock {
  my $message = '';
  print GetHeader('', T('Unlocking'), '');
  print $q->p(T('This operation may take several seconds...')) . "\n";
  for my $lock (qw(main diff index merge visitors refer_*)) {
    if (ForceReleaseLock($lock)) {
      $message .= $q->p(Ts('Forced unlock of %s lock.', $lock)) . "\n";
    }
  }
  if ($message) {
    print $message;
  } else {
    print $q->p(T('No unlock required.'));
  }
  PrintFooter();
}

# == File operations

sub ReadFile {
  my ($fileName) = @_;
  my ($data);
  local $/ = undef;   # Read complete files
  if (open(IN, "<$fileName")) {
    $data=<IN>;
    close IN;
    return (1, $data);
  }
  return (0, '');
}

sub ReadFileOrDie {
  my ($fileName) = @_;
  my ($status, $data);
  ($status, $data) = ReadFile($fileName);
  if (!$status) {
    die(Ts('Can not open %s', $fileName) . ": $!");
  }
  return $data;
}

sub WriteStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">$file") or die(Ts('cant write %s', $file) . ": $!");
  print OUT  $string;
  close(OUT);
}

sub AppendStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">>$file") or die(Ts('cant write %s', $file) . ": $!");
  print OUT  $string;
  close(OUT);
}

sub CreateDir {
  my ($newdir) = @_;
  mkdir($newdir, 0775)  if (!(-d $newdir));
}

sub CreatePageDir {
  my ($dir, $id) = @_;
  my $subdir;
  CreateDir($dir);  # Make sure main page exists
  $subdir = $dir . '/' . GetPageDirectory($id);
  CreateDir($subdir);
  if ($id =~ m|([^/]+)/|) {
    $subdir = $subdir . '/' . $1;
    CreateDir($subdir);
  }
}

sub GenerateAllPagesList {
  my (@pages, @dirs, $id, $dir, @pageFiles, $subId);
  @pages = ();
  # The following was inspired by the FastGlob code by Marc W. Mengel.
  # Thanks to Bob Showalter for pointing out the improvement.
  opendir(PAGELIST, $PageDir);
  @dirs = readdir(PAGELIST);
  closedir(PAGELIST);
  @dirs = sort(@dirs);
  foreach $dir (@dirs) {
    next  if (($dir eq '.') || ($dir eq '..'));
    opendir(PAGELIST, "$PageDir/$dir");
    @pageFiles = readdir(PAGELIST);
    closedir(PAGELIST);
    foreach $id (@pageFiles) {
      next  if (($id eq '.') || ($id eq '..'));
      if (substr($id, -3) eq '.db') {
	push(@pages, substr($id, 0, -3));
      }
    }
  }
  return sort(@pages);
}

sub AllPagesList {
  my ($rawIndex, $refresh, $status);
  $refresh = GetParam('refresh', 0);
  if ($IndexInit && !$refresh) {
    # Note for mod_perl: $IndexInit is reset for each query
    # Eventually consider some timestamp-solution to keep cache?
    return @IndexList;
  }
  if ((!$refresh) && (-f $IndexFile)) {
    ($status, $rawIndex) = ReadFile($IndexFile);
    if ($status) {
      %IndexHash = split(/\s+/, $rawIndex);
      @IndexList = sort(keys %IndexHash);
      $IndexInit = 1;
      return @IndexList;
    }
    # If open fails just refresh the index
  }
  @IndexList = ();
  %IndexHash = ();
  @IndexList = GenerateAllPagesList();
  foreach (@IndexList) {
    $IndexHash{$_} = 1;
  }
  $IndexInit = 1;  # Initialized for this run of the script
  # Try to write out the list for future runs
  RequestLockDir('index') or return @IndexList;
  WriteStringToFile($IndexFile, join(' ', %IndexHash));
  ReleaseLockDir('index');
  return @IndexList;
}

sub CalcDay {
  my ($ts) = @_;
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($ts);
  return sprintf('%4d-%02d-%02d', $year+1900, $mon+1, $mday);
}

sub CalcTime {
  my ($ts) = @_;
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($ts);
  return sprintf('%2d:%02d UTC', $hour, $min);
}

sub TimeToText {
  my ($t) = @_;
  return CalcDay($t) . ' ' . CalcTime($t);
}

sub GetHiddenValue {
  my ($name, $value) = @_;
  $q->param($name, $value);
  return $q->hidden($name);
}

sub GetRemoteHost {
  my ($rhost, $iaddr);
  $rhost = $ENV{REMOTE_HOST};
  if ($UseLookup && ($rhost eq '')) {
    # Catch errors (including bad input) without aborting the script
    eval 'use Socket; $iaddr = inet_aton($ENV{REMOTE_ADDR});'
         . '$rhost = gethostbyaddr($iaddr, AF_INET)';
  }
  if ($rhost eq '') {
    $rhost = $ENV{REMOTE_ADDR};
  }
  return $rhost;
}

sub FreeToNormal {
  my $id = shift;
  $id =~ s/ /_/g;
  if (index($id, '_') > -1) {  # Quick check for any space/underscores
    $id =~ s/__+/_/g;
    $id =~ s/^_//;
    $id =~ s/_$//;
  }
  return $id;
}

# == Page-editing and other special-action code ==

sub DoEdit {
  my ($id, $isConflict, $oldTime, $newText, $preview) = @_;
  my ($header, $userName, $revision, $oldText);
  my ($summary, $minor, $pageTime);
  if (!UserCanEdit($id, 1)) {
    print GetHeader('', T('Editing Denied'), '');
    if (UserIsBanned()) {
      print $q->p(T('Editing not allowed: user, ip, or network is blocked.'));
      print $q->p(T('Contact the wiki administrator for more information.'));
    } else {
      print $q->p(Ts('Editing not allowed: %s is read-only.', $SiteName));
    }
    PrintFooter();
    return;
  }
  OpenPage($id);
  OpenDefaultText();
  $pageTime = $Section{'ts'};
  $header = Ts('Editing %s', $id);
  # Old revision handling
  $revision = GetParam('revision', '');
  $revision =~ s/\D//g;  # Remove non-numeric chars
  if ($revision ne '') {
    OpenKeptRevisions('text_default');
    if (!defined($KeptRevisions{$revision})) {
      $revision = '';
      # Later look for better solution, like error message?
    } else {
      OpenKeptRevision($revision);
      $header = Ts('Editing revision %s of', $revision) . ' ' . $id;
    }
  }
  $oldText = $Text{'text'};
  if ($preview && !$isConflict) {
    $oldText = $newText;
  }
  print GetHeader('', QuoteHtml($header), ''), "\n";
  if ($revision ne '') {
    print $q->strong(Ts('Editing old revision %s.', $revision) . '  '
		   . T('Saving this page will replace the latest revision with this text.'))
  }
  if ($isConflict) {
    print $q->h1(T('Edit Conflict!'));
    if ($isConflict>1) {
      # The main purpose of a new warning is to display more text
      # and move the save button down from its old location.
      print $q->h2(T('(This is a new conflict)'));
    }
    print $q->p($q->strong(T('Someone saved this page after you started editing.') . ' '
			 . T('The top textbox contains the saved text.') . ' '
			 . T('Only the text in the top textbox will be saved.')));
    if ($UseDiff) {
      print $q->p(T('Scroll down to see your text with conflict markers.'));
    } else {
      print $q->p(T('Scroll down to see your edited text.'));
    }
    print $q->p(T('Last save time:') . ' ' . TimeToText($oldTime)
		. ' (' . T('Current time is:') . ' ' . TimeToText($Now) . ')');
  }
  print GetFormStart();
  print GetHiddenValue("title", $id),
        GetHiddenValue("oldtime", $pageTime),
        GetHiddenValue("oldconflict", $isConflict);
  if ($revision ne '') {
    print GetHiddenValue('revision', $revision);
  }
  print GetTextArea('text', $oldText);
  $summary = GetParam('summary', '');
  print $q->p(T('Summary:'),
	      $q->textfield(-name=>'summary', -default=>$summary, -override=>1, -size=>60));
  if (GetParam('recent_edit') eq 'on') {
    print $q->p($q->checkbox(-name=>'recent_edit', -checked=>1,
			     -label=>T('This change is a minor edit.')));
  } else {
    print $q->p($q->checkbox(-name=>'recent_edit',
			     -label=>T('This change is a minor edit.')));
  }
  if ($EditNote ne '') {
    print T($EditNote);  # Allow translation, must be a block level element (paragraph, list, table, etc.)
  }
  $userName = GetParam('username', '');
  print $q->p(T('Username:')
	      . $q->textfield(-name=>'username',
			      -default=>$userName, -override=>1,
			      -size=>20, -maxlength=>50));
  print $q->p($q->submit(-name=>'Save', -value=>T('Save')) . ' '
	      . $q->submit(-name=>'Preview', -value=>T('Preview')));
  if ($isConflict) {
    print $q->hr();
    if ($UseDiff) {
      print $q->p($q->strong(T('This is the text with conflict markers:')));
    } else {
      print $q->p($q->strong(T('This is the text you submitted:')));
    }
    print $q->p(GetTextArea('newtext', $newText));
  }
  print $q->endform();
  if ($preview) {
    print '<div class="preview">', $q->hr();
    print $q->h2(T('Preview:'));
    if ($isConflict) {
      print $q->strong(T('NOTE: This preview shows the revision of the other author.'))
	. $q->hr();
    }
    PrintWikiToHTML($oldText, 'preview');
    print $q->hr(), $q->h2(T('Preview only, not yet saved')), '</div>';
  }
  PrintFooter($id, 'edit');
}

sub GetTextArea {
  my ($name, $text) = @_;
  return $q->textarea(-name=>$name, -default=>$text, -rows=>25, -columns=>78, -override=>1);
}

# == Passwords ==

sub DoPassword {
  print GetHeader('',T('Password'), '');
  print $q->p(T('Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.'));
  if (UserIsAdmin()) {
    print $q->p(T('You are currently an administrator on this site.'));
  } elsif (UserIsEditor()) {
    print $q->p(T('You are currently an editor on this site.'));
  } else {
    print $q->p(T('You are a normal user on this site.'));
    if ($AdminPass or $EditPass) {
      print $q->p(T('Your password does not match any of the  administrator or editor passwords.'));
    }
  }
  if ($AdminPass or $EditPass) {
    print GetFormStart() . GetHiddenValue('action', 'password')
      . $q->p(T('Password:') . ' ' . $q->password_field(-name=>'pwd', -size=>20, -maxlength=>50))
      . $q->submit(-name=>'Save', -value=>T('Save')) . $q->endform;
  } else {
    print $q->p(T('This site does not use admin or editor passwords.'));
  }
  PrintFooter();
}

sub UserIsEditorOrError {
  if (!UserIsEditor()) {
    print $q->p(T('This operation is restricted to site editors only...'));
    PrintFooter();
    return 0;
  }
  return 1;
}

sub UserIsAdminOrError {
  if (!UserIsAdmin()) {
    print $q->p(T('This operation is restricted to administrators only...'));
    PrintFooter();
    return 0;
  }
  return 1;
}

sub UserCanEdit {
  my ($id, $editing) = @_;
  return 1 if UserIsAdmin();
  return 0 if $id ne '' and -f GetLockedPageFile($id);
  return 1 if UserIsEditor();
  return 0 if !$EditAllowed or -f $NoEditFile;
  return 0 if $editing and UserIsBanned(); # this call is more expensive
  return 0 if $EditAllowed == 2 and (not $CommentsPrefix or $id !~ /^$CommentsPrefix/);
  return 1;
}

sub UserIsBanned {
  my ($host, $ip);
  $ip = $ENV{'REMOTE_ADDR'};
  $host = GetRemoteHost();
  foreach (split(/\n/, GetPageContent($BannedHosts))) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $host = $1;
      return 1  if ($ip   =~ /$host/i);
      return 1  if ($host =~ /$host/i);
    }
  }
  return 0;
}

sub UserIsAdmin {
  return 0  if ($AdminPass eq '');
  my $pwd = GetParam('pwd', '');
  return 0  if ($pwd eq '');
  foreach (split(/\s+/, $AdminPass)) {
    next  if ($_ eq '');
    return 1  if ($pwd eq $_);
  }
  return 0;
}

sub UserIsEditor {
  return 1  if (UserIsAdmin());         # Admin includes editor
  return 0  if ($EditPass eq '');
  my $pwd = GetParam('pwd', '');        # Used for both
  return 0  if ($pwd eq '');
  foreach (split(/\s+/, $EditPass)) {
    next  if ($_ eq '');
    return 1  if ($pwd eq $_);
  }
  return 0;
}

# == Index ==

sub DoIndex {
  my ($raw) = @_;
  my ($name);
  if ($raw) {
    print GetHttpHeader('text/plain');
    foreach $name (AllPagesList()) {
      print "$name\n"
    }
    return;
  }
  print GetHeader('', T('Index of all pages'), '');
  PrintPageList(AllPagesList());
  PrintFooter();
}

# == Searching ==

sub DoSearch {
  my $string = shift;
  my $replacement = GetParam('replace','');
  if ($string eq '') {
    DoIndex();
    return;
  }
  return  if $replacement and !UserIsAdminOrError();
  if ($replacement) {
    print GetHeader('', QuoteHtml(Ts('Replaced: %s', $string)), '');
    Replace($string,$replacement);
    $string = $replacement;
  } else {
    print GetHeader('', QuoteHtml(Ts('Search for: %s', $string)), '');
    $ReplaceForm = UserIsAdmin(); # only show on new searches for admins
  }
  if (GetParam('context',1)) {
    PrintSearchResults($string,SearchTitleAndBody($string)) ;
  } else {
    PrintPageList(SearchTitleAndBody($string));
  }
  PrintFooter();
}

sub SearchTitleAndBody {
  my ($string) = @_;
  my ($name, $freeName, @found);
  foreach $name (AllPagesList()) {
    OpenPage($name);
    OpenDefaultText();
    if (($Text{'text'} =~ /$string/i) || ($name =~ /$string/i)) {
      push(@found, $name);
    } elsif ($FreeLinks && ($name =~ m/_/)) {
      $freeName = $name;
      $freeName =~ s/_/ /g;
      if ($freeName =~ /$string/i) {
        push(@found, $name);
      }
    }
  }
  return @found;
}

sub PrintSearchResults {
  my ($searchstring, @results) = @_ ;  #  inputs
  my ($name, $pageText, $t, $j, $jsnippet, $start, $end, $htmlre);
  my ($snippetlen, $maxsnippets) = (100, 4) ; #  these seem nice.
  print $q->h2(Ts('%s pages found:', ($#results + 1)));
  foreach $name (@results) {
    #  get the page, filter it, remove all tags (since we're presenting in
    #  plaintext, not HTML, a la google(tm)).
    OpenPage($name);
    OpenDefaultText();
    $pageText = QuoteHtml($Text{'text'});
    $pageText =~ s/$FS//g;  # Remove separators (paranoia)
    $pageText =~ s/[\s]+/ /g;  #  Shrink whitespace
    $pageText =~ s/([-_=\\*\\.]){10,}/$1$1$1$1$1/g ; # e.g. shrink "----------"
    $htmlre = join('|',(@HtmlTags, 'pre', 'nowiki', 'code'));
    $pageText =~ s/\<\/?($htmlre)(\s[^<>]+?)?\>//gi;
    #  entry header
    print '<p>';
    print '... '  if ($name =~ m|/|);
    print $q->span({-class=>'result'}, GetPageLink($name)), $q->br();
    #  show a snippet from the top of the document
    $j = index( $pageText, ' ', $snippetlen ) ;  #  end on word boundary
    print substr( $pageText, 0, $j ), ' ', $q->b('...');
    $pageText = substr( $pageText, $j ) ;  #  to avoid rematching
    #  search for occurrences of searchstring
    $jsnippet = 0 ;
    while ( $jsnippet < $maxsnippets
           &&  $pageText =~ m/($searchstring)/i ) {  #  captures match as $1
      $jsnippet++ ;  #  paranoid about looping
      if ( ($j = index( $pageText, $1 )) > -1 ) {  #  get index of match
        #  get substr containing (start of) match, ending on word boundaries
        $start = index( $pageText, ' ', $j-($snippetlen/2) ) ;
        $start = 0  if ( $start == -1 ) ;
        $end = index( $pageText, ' ', $j+($snippetlen/2) ) ;
        $end = length( $pageText )  if ( $end == -1 ) ;
        $t = substr( $pageText, $start, $end-$start ) ;
        #  highlight occurrences and tack on to output stream.
        $t =~ s/($searchstring)/<strong>\1<\/strong>/gi ;
        print $t, ' ', $q->b('...');
        #  truncate text to avoid rematching the same string.
        $pageText = substr( $pageText, $end ) ;
      }
    }
    #  entry trailer
    print $q->br(),
      $q->span({-class=>'info'},
	       int((length($pageText)/1024)+1) . 'K - '
	       . T('last updated') . ' '
	       . TimeToText($Section{ts}) . ' ' . T('by') . ' '
	       . GetAuthorLink($Section{'host'}, $Section{'username'})),
      '</p>';
  }
}

sub PrintPageList {
  my $pagename;
  print $q->h2(Ts('%s pages found:', ($#_ + 1))), '<p>';
  foreach $pagename (@_) {
    print '.... '  if ($pagename =~ m|/|);
    print GetPageLink($pagename), $q->br();
  }
  print '</p>';
}

sub Replace {
  my ($from, $to) = @_;
  if (RequestLock()) {
    foreach my $id (AllPagesList()) {
      OpenPage($id);
      OpenDefaultText();
      my $new = $Text{'text'};
      if ($new =~ s/$from/$to/gi) {
	Save($id, $new, $from . ' -> ' . $to, 1,
	     ($Section{'ip'} ne $ENV{REMOTE_ADDR}));
      }
    }
  }
  ReleaseLock();
}

# == Links ==

sub DoLinks {
  print GetHeader('', QuoteHtml(T('Full Link List')), '');
  print "<pre>\n\n\n\n\n";  # Extra lines to get below the logo
  PrintLinkList(GetFullLinkList());
  print "</pre>\n";
  PrintFooter();
}

sub PrintLinkList {
  my ($pagelines, $page, $names, $editlink);
  my ($link, @links, %pgExists);
  %pgExists = ();
  foreach $page (AllPagesList()) {
    $pgExists{$page} = 1;
  }
  $names = GetParam('names', 1);
  $editlink = GetParam('editlink', 0);
  foreach $pagelines (@_) {
    @links = ();
    foreach $page (split(' ', $pagelines)) {
      if ($page =~ /\:/) {  # URL or InterWiki form
        if ($page =~ /$UrlPattern/) {
          $link = GetUrl($page, '', 0, 0);
        } else {
          $link = GetInterLink($page);
        }
      } else {
        if ($pgExists{$page}) {
          $link = GetPageLink($page);
        } else {
          $link = $page;
          if ($editlink) {
            $link .= GetEditLink($page, '?');
          }
        }
      }
      push(@links, $link);
    }
    if (!$names) {
      shift(@links);
    }
    print join(' ', @links), "\n";
  }
}

sub GetFullLinkList {
  my $unique = GetParam('unique', 1);
  my $sort = GetParam('sort', 1);
  my $pagelink = GetParam('page', 1);
  my $interlink = GetParam('inter', 0);
  my $urllink = GetParam('url', 0);
  my $exists = GetParam('exists', 2);
  my $empty = GetParam('empty', 0);
  my $search = GetParam('search', '');
  if (($interlink == 2) || ($urllink == 2)) {
    $pagelink = 0;
  }
  my (%pgExists, %seen, @found);
  my @pglist = AllPagesList();
  foreach my $name (@pglist) {
    $pgExists{$name} = 1;
  }
  foreach my $name (@pglist) {
    my @newlinks = ();
    if ($unique != 2) {
      %seen = ();
    }
    my @links = GetPageLinks($name, $pagelink, $interlink, $urllink);
    foreach my $link (@links) {
      $seen{$link}++;
      if (($unique > 0) && ($seen{$link} != 1)) {
        next;
      }
      if (($exists == 0) && ($pgExists{$link} == 1)) {
        next;
      }
      if (($exists == 1) && ($pgExists{$link} != 1)) {
        next;
      }
      if (($search ne '') && !($link =~ /$search/)) {
        next;
      }
      push(@newlinks, $link);
    }
    @links = @newlinks;
    if ($sort) {
      @links = sort(@links);
    }
    unshift (@links, $name);
    if ($empty || ($#links > 0)) {  # If only one item, list is empty.
      push(@found, join(' ', @links));
    }
  }
  return @found;
}

sub GetPageLinks {
  my ($name, $pagelink, $interlink, $urllink) = @_;
  my ($text, @links);
  @links = ();
  OpenPage($name);
  OpenDefaultText();
  $text = $Text{'text'};
  $text =~ s/<html>((.|\n)*?)<\/html>/ /ig;
  $text =~ s/<nowiki>(.|\n)*?\<\/nowiki>/ /ig;
  $text =~ s/<pre>(.|\n)*?\<\/pre>/ /ig;
  $text =~ s/<code>(.|\n)*?\<\/code>/ /ig;
  if ($interlink) {
    $text =~ s/''+/ /g;  # Quotes can adjacent to inter-site links
    $text =~ s/$InterLinkPattern/push(@links, $1), ' '/ge;
  } else {
    $text =~ s/$InterLinkPattern/ /g;
  }
  if ($urllink) {
    $text =~ s/''+/ /g;  # Quotes can adjacent to URLs
    $text =~ s/$UrlPattern/push(@links, $1), ' '/ge;
  } else {
    $text =~ s/$UrlPattern/ /g;
  }
  if ($pagelink) {
    if ($FreeLinks) {
      my $fl = $FreeLinkPattern;
      $text =~ s/\[\[$fl\|[^\]]+\]\]/push(@links, FreeToNormal($1)), ' '/ge;
      $text =~ s/\[\[$fl\]\]/push(@links, FreeToNormal($1)), ' '/ge;
    }
    if ($WikiLinks) {
      $text =~ s/$LinkPattern/push(@links, $1), ' '/ge;
    }
  }
  return @links;
}

# == Monolithic output ==

sub DoPrintAllPages {
  $Monolithic = 1; # changes how ScriptLink works
  print GetHeader('', T('Complete Content'), '')
    . $q->p(Ts('The main page is %s.', $q->a({-href=>'#' . $HomePage}, $HomePage)));
  PrintAllPages(0, AllPagesList());
  PrintFooter();
}

sub PrintAllPages {
  my $links = shift;
  for my $id (@_) {
    OpenPage($id); # After this call, don't save cache!
    OpenDefaultText($id);
    print $q->hr . $q->h1($links ? GetPageLink($id) : $q->a({-name=>$id},$id));
    if (GetPageCache('blocks') && GetParam('cache',1)) {
      PrintCache(GetPageCache('blocks'));
    } else {
      PrintWikiToHTML($Text{'text'});
    }
  }
}

# == Posting new pages ==

sub DoPost {
  my $id = GetParam('title', '');
  if (!UserCanEdit($id, 1)) {
    # This is an internal interface--we don't need to explain
    ReportError(Ts('Editing not allowed for %s.', $id));
    return;
  } elsif (($id eq 'SampleUndefinedPage') or ($id eq T('SampleUndefinedPage'))) {
    ReportError(Ts('%s cannot be defined.', $id));
    return;
  } elsif (($id eq 'Sample_Undefined_Page') or ($id eq T('Sample_Undefined_Page'))) {
    ReportError(Ts('[[%s]] cannot be defined.', $id));
    return;
  } elsif (grep(/^$id$/, @LockOnCreation) and !UserIsAdmin() and not -f GetPageFile($id)) {
    ReportError(Ts('Only an administrator can create %s', $id));
    return;
  }
  # Handle raw edits with the meta info on the first line
  my $string = GetParam('text', undef);
  my $oldtime = GetParam('oldtime', '');
  my $raw = GetParam('raw', 0);
  if ($raw == 2) {
    if (not $string =~ /^([0-9]+).*\n/) {
      ReportError(Ts('Cannot find timestamp on the first line.'));
      return;
    }
    $oldtime = $1;
    $string = $';
  }
  # Lock before getting old page to prevent races
  RequestLock() or die(T('Could not get main lock'));
  OpenPage($id);
  OpenDefaultText();
  my $old = $Text{'text'};
  my $oldrev = $Section{'revision'};
  my $pgtime = $Section{'ts'};
  my $preview = 0;
  $preview = 1  if (GetParam('Preview', '') ne '');
  my $comment = GetParam('aftertext', undef);
  if (defined $comment) {
    $comment =~ s/\r//g;  # Remove "\r"-s (0x0d) from the string
    if ($comment ne '' and $comment ne $NewComment) {
      $string = $old  . "----\n" if $old and $old ne "\n";
      $string .= $comment . ' -- ' .  GetParam('username', T('Anonymous'))
	. ' ' . TimeToText($Now) . "\n\n";
    } else {
      $string = $old;
    }
  }
  # Massage the string
  $string =~ s/\r//g;
  $string .= "\n"  if ($string !~ /\n$/);
  $string =~ s/$FS//g;
  my $summary = GetParam('summary', '');
  $summary =~ s/$FS//g;
  $summary =~ s/[\r\n]//g;
  # rebrowse if no changes
  if (!$preview && (($old eq $string) or ($oldrev == 0 and $string eq $NewText))) {
    ReleaseLock(); # No changes -- just show the same page again
    ReBrowsePage($id, '', 1);
    return;
  }
  my $authorAddr = $ENV{REMOTE_ADDR};
  my $newAuthor;
  $newAuthor = 1  if ($Section{'ip'} ne $authorAddr);  # hostname fallback
  $newAuthor = 1  if ($oldrev == 0);  # New page
  $newAuthor = 0  if (!$newAuthor);   # Standard flag form, not empty
  # Handle editing conflicts.  If possible, merge automatically.
  my $oldconflict = GetParam('oldconflict', '');
  if (($oldrev > 0) && ($newAuthor && ($oldtime < $pgtime))) {
    my $conflict = 1;
    if ($UseDiff) {
      # merge all changes that lead from file2 to file3 into file1.
      $string = MergeRevisions($string, GetTextAtTime($oldtime), $old);
      $conflict = 0  unless ($string =~ /<<<<<<</ and $string =~ />>>>>>>/);
    }
    if ($conflict) {
      ReleaseLock();
      DoEdit($id, ($oldconflict > 0 ? 2 : 1), $pgtime, $string, $preview);
      return;
    }
  }
  if ($preview) {
    ReleaseLock();
    DoEdit($id, 0, $pgtime, $string, 1);
    return;
  }
  Save($id, $string, $summary, (GetParam('recent_edit', '') eq 'on'),
	$newAuthor);
  ReleaseLock();
  DeletePermanentAnchors();
  if (GetParam('recent_edit', '') ne 'on' and $NotifyTracker) {
    PingTracker($id);
  }
  ReBrowsePage($id, '', 1);
}

sub Save { # call within lock, with opened page
  my ($id, $new, $summary, $minor, $newAuthor) = @_;
  my $old = $Text{'text'};
  my $user = GetParam('username', '');
  if (!$minor) {
    SetPageCache('oldmajor', $Section{'revision'});
  }
  if ($newAuthor) {
    SetPageCache('oldauthor', $Section{'revision'});
  }
  SaveKeepSection();
  ExpireKeepFile();
  if ($UseDiff) {
    UpdateDiffs($id, $old, $new, $minor, $newAuthor);
  }
  $Text{'text'} = $new;
  $Text{'minor'} = $minor;
  $Text{'newauthor'} = $newAuthor;
  $Text{'summary'} = $summary;
  $Section{'host'} = GetRemoteHost();
  SaveDefaultText();
  SetPageCache('blocks','');
  SavePage();
  WriteRcLog($id, $summary, $minor, $Section{'revision'}, $user,
	      $Section{'host'}, GetLanguages($Text{'text'}));
  if ($Page{'revision'} == 1) {
    unlink($IndexFile);  # Regenerate index on next request
    if (grep(/^$id$/, @LockOnCreation)) {
      WriteStringToFile(GetLockedPageFile($id), 'editing locked.');
    }
  }
}

sub GetLanguages {
  my ($text) = @_;
  my @result;
  my $count;
  for my $lang (keys %Languages) {
    $count = 0;
    while ($text =~ /$Languages{$lang}/ig) {
      if (++$count > $LanguageLimit) {
	push(@result, $lang);
	last;
      }
    }
  }
  return \@result;
}

sub MergeRevisions {
  my ($file1, $file2, $file3) = @_;
  my ($name1, $name2, $name3, $output);
  CreateDir($TempDir);
  $name1 = "$TempDir/file1";
  $name2 = "$TempDir/file2";
  $name3 = "$TempDir/file3";
  RequestLockDir('merge') or return T('Could not get a lock to merge!');
  WriteStringToFile($name1, $file1);
  WriteStringToFile($name2, $file2);
  WriteStringToFile($name3, $file3);
  $output = `merge -p -L you -L ancestor -L other $name1 $name2 $name3`;
  ReleaseLockDir('merge');
  # No need to unlink temp files--next merge will just overwrite.
  return $output;
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
  my ($id, $summary, $minor, $revision, $name, $rhost, $languages) = @_;
  my ($extraTemp, %extra);
  %extra = ();
  $extra{'name'} = $name  if ($name ne '');
  $extra{'revision'} = $revision if ($revision ne '');
  $extra{'languages'} = join($FS1, @{$languages}) if $languages;
  $extraTemp = join($FS2, %extra);
  # The two fields at the end of a line are kind and extension-hash
  my $rc_line = join($FS3, $Now, $id, $summary,
                     $minor, $rhost, '0', $extraTemp);
  if (!open(OUT, ">>$RcFile")) {
    die(Ts('%s log error:', $RCName) . " $!");
  }
  print OUT  $rc_line . "\n";
  close(OUT);
}

sub UpdateDiffs {
  my ($id, $old, $new, $minor, $newAuthor) = @_;
  my ($editDiff, $oldMajor, $oldAuthor);
  $editDiff  = GetDiff($old, $new, 0);     # 0 = already in lock
  $oldMajor  = GetPageCache('oldmajor');
  $oldAuthor = GetPageCache('oldauthor');
  SetPageCache('diff_default_minor', $editDiff);
  if ($minor || !$newAuthor) {
    OpenKeptRevisions('text_default');
  }
  if (!$minor) {
    SetPageCache('diff_default_major', '1');
  } else {
    SetPageCache('diff_default_major', GetKeptDiff($new, $oldMajor, 0));
  }
  if ($newAuthor) {
    SetPageCache('diff_default_author', '1');
  } elsif ($oldMajor == $oldAuthor) {
    SetPageCache('diff_default_author', '2');
  } else {
    SetPageCache('diff_default_author', GetKeptDiff($new, $oldAuthor, 0));
  }
}

# == Weblog Tracking ==

sub PingTracker {
  my $id = shift;
  if ($q->url(-base=>1) !~ m|^http://localhost|) {
    my $url = UrlEncode($q->url . '/' . $id);
    my $name = UrlEncode($SiteName . ': ' . $id);
    my $rss = UrlEncode($q->url . '?action=rss');
    # my $uri = "http://newhome.weblogs.com/pingSiteForm?name=$id&url=$url";
    # my $uri = "http://www.blogrolling.com/ping.php?pingform=single&title=$name&url_1=$url&submit=Ping";
    my $uri = "http://ping.blo.gs/?name=$name&url=$url&rssUrl=$rss&direct=1";
    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new('GET', $uri);
    return $ua->request($request);
  }
}

sub DoPingTracker {
  print GetHeader('', T('Ping'), '');
  return  if (!UserIsAdminOrError());
  my $response = PingTracker(GetParam('id', $RCName));
  if ($response) {
    print $q->pre($response->request->uri, "\n",
		  $response->status_line, "\n");
  } else {
    print $q->p(T('No response.'));
  }
  PrintFooter();
}

# == Maintenance ==

sub DoMaintain {
  my ($name, $fname, @rc, @temp, $starttime, $days, $status, $data, $i, $ts);
  print GetHeader('', T('Maintenance on all pages'), '');
  $fname = "$DataDir/maintain";
  if (!UserIsAdmin()) {
    if ((-f $fname) && ((-M $fname) < 0.5)) {
      print $q->p(T('Maintenance not done.') . ' '
		  . T('(Maintenance can only be done once every 12 hours.)')
		  . ' ', T('Remove the "maintain" file or wait.'));
      PrintFooter();
      return;
    }
  }
  RequestLock() or die(T('Could not get main lock'));
  print $q->p(T('Main lock obtained.'));
  print '<p>' . T('Expiring keep files and deleting pages marked for deletion');
  # Expire all keep files
  foreach $name (AllPagesList()) {
    print $q->br();
    print '.... '  if ($name =~ m|/|);
    print GetPageLink($name);
    OpenPage($name);
    OpenDefaultText();
    my $delete = PageDeletable($name);
    if ($delete) {
      DeletePage($OpenPageName, 1, 1);
      print ' ' . T('deleted');
    } else {
      ExpireKeepFile();
    }
  }
  print '</p>';
  print $q->p(Ts('Moving part of the %s log file.', $RCName));
  # Determine the number of days to go back
  $days = 0;
  foreach (@RcDays) {
    $days = $_ if $_ > $days;
  }
  $starttime = $Now - $days * 24 * 60 * 60;
  # Read the current file
  ($status, $data) = ReadFile($RcFile);
  if (!$status) {
    print $q->p($q->strong(Ts('Could not open %s log file', $RCName) . ':') . ' '
		. $RcFile)
      . $q->p(T('Error was') . ':')
      . $q->pre($!)
      . $q->p(T('Note: This error is normal if no changes have been made.'));
  }
  # Move the old stuff from rc to temp
  @rc = split(/\n/, $data);
  for ($i = 0; $i < @rc ; $i++) {
    ($ts) = split(/$FS3/, $rc[$i]);
    last if ($ts >= $starttime);
  }
  print $q->p(Ts('Moving %s log entries.', $i));
  @temp = splice(@rc, 0, $i);
  # Write new files, and backups
  AppendStringToFile($RcOldFile, join("\n",@temp) . "\n");
  WriteStringToFile($RcFile . '.old', $data);
  WriteStringToFile($RcFile, join("\n",@rc) . "\n");
  # Write timestamp
  WriteStringToFile($fname, 'Maintenance done at ' . TimeToText($Now));
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

sub DoConvert {
  print GetHeader('', T('Converting all files'), '');
  if (!$FS0 or $FS0 eq $FS) {
    print $q->p(T('No conversion required.'));
    return;
  }
  return  if (!UserIsAdminOrError());
  RequestLock() or die(T('Could not get main lock'));
  print '<p>' . T('Main lock obtained.');
  foreach my $name (AllPagesList()) {
    ConvertFile (GetPageFile($name));
    ConvertFile (GetKeepFile($name));
    ConvertFile (GetRefererFile($name));
  }
  foreach my $name ($RcFile, $RcOldFile, $VisitorFile) {
    ConvertFile ($name);
  }
  print '</p>';
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

sub ConvertFile {
  my $file = shift;
  print $q->br() . $file . ' ';
  if (-f $file) {
    my ($status, $data) = ReadFile($file);
    if ($status) {
      if ($data =~ /$FS0/ and $data !~ /$FS/) {
	$data =~ s/$FS0/$FS/go;
	WriteStringToFile($file, $data);
	print T('converted');
      } else {
	print T('no conversion required');
      }
    } else {
      print Ts('Can not open %s', $file) . ": $!";
    }
  } else {
    print T('has no file');
  }
}

# == Deleting pages ==

sub PageDeletable {
  my ($expirets);
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return 0 unless $Page{'ts'} < $expirets;
  return $DeletedPage && $Text{'text'} =~ /^\s*$DeletedPage\b/o;
}

# Delete and rename must be done inside locks.
sub DeletePage {
  my ($page, $doRC, $doText) = @_;
  my ($fname, $status);
  $page =~ s/ /_/g;
  $page =~ s/\[+//;
  $page =~ s/\]+//;
  $status = ValidId($page);
  if ($status ne '') {
    print "Delete-Page: page $page is invalid, error is: $status<br>\n";
    return;
  }
  $fname = GetPageFile($page);
  unlink($fname)  if (-f $fname);
  $fname = $KeepDir . '/' . GetPageDirectory($page) .  "/$page.kp";
  unlink($fname)  if (-f $fname);
  unlink($IndexFile);
  DeletePermanentAnchors();
  EditRecentChanges(1, $page, '')  if ($doRC);  # Delete page
  # Currently don't do anything with page text
}

sub EditRecentChanges {
  my ($action, $old, $new) = @_;
  EditRecentChangesFile($RcFile,    $action, $old, $new);
  EditRecentChangesFile($RcOldFile, $action, $old, $new);
}

sub EditRecentChangesFile {
  my ($fname, $action, $old, $new) = @_;
  my ($status, $fileData, $errorText, $rcline, @rclist);
  my ($outrc, $ts, $page, $junk);
  ($status, $fileData) = ReadFile($fname);
  if (!$status) {
    # Save error text if needed.
    $errorText = "<p><strong>Could not open $RCName log file:"
                 . "</strong> $fname<p>Error was:\n<pre>$!</pre>\n";
    print $errorText;   # Maybe handle differently later?
    return;
  }
  $outrc = '';
  @rclist = split(/\n/, $fileData);
  foreach $rcline (@rclist) {
    ($ts, $page, $junk) = split(/$FS3/, $rcline);
    if ($page eq $old) {
      if ($action == 1) {  # Delete
        ; # Do nothing (don't add line to new RC)
      } elsif ($action == 2) {
        $junk = $rcline;
        $junk =~ s/^(\d+$FS3)$old($FS3)/"$1$new$2"/ge;
        $outrc .= $junk . "\n";
      }
    } else {
      $outrc .= $rcline . "\n";
    }
  }
  WriteStringToFile($fname . '.old', $fileData);  # Backup copy
  WriteStringToFile($fname, $outrc);
}

# == Page locking ==

sub DoEditLock {
  my ($fname);
  print GetHeader('', T('Set or Remove global edit lock'), '');
  return  if (!UserIsAdminOrError());
  $fname = "$NoEditFile";
  if (GetParam("set", 1)) {
    WriteStringToFile($fname, 'editing locked.');
  } else {
    unlink($fname);
  }
  if (-f $fname) {
    print $q->p(T('Edit lock created.'));
  } else {
    print $q->p(T('Edit lock removed.'));
  }
  PrintFooter();
}

sub DoPageLock {
  my ($fname, $id);
  print GetHeader('', T('Set or Remove page edit lock'), '');
  # Consider allowing page lock/unlock at editor level?
  return  if (!UserIsAdminOrError());
  $id = GetParam('id', '');
  if ($id eq '') {
    print $q->p(T('Missing page id to lock/unlock...'));
    return;
  }
  return  if (!ValidIdOrDie($id));       # Later consider nicer error?
  $fname = GetLockedPageFile($id);
  if (GetParam('set', 1)) {
    WriteStringToFile($fname, 'editing locked.');
  } else {
    unlink($fname);
  }
  if (-f $fname) {
    print $q->p(Ts('Lock for %s created.', $id));
  } else {
    print $q->p(Ts('Lock for %s removed.', $id));
  }
  PrintFooter();
}

# == Version ==

sub DoShowVersion {
  print GetHeader('', T('Displaying Wiki Version'), '');
  print $WikiDescription;
  PrintFooter();
}

# == Maintaining a list of recent visitors plus surge protection ==

sub DoSurgeProtection {
  if ($SurgeProtection or $Visitors) {
    my $name = GetParam('username','');
    $name = $ENV{'REMOTE_ADDR'} if not $name and $SurgeProtection;
    if ($name) {
      RequestLockDir('visitors');
      ReadRecentVisitors();
      AddRecentVisitor($name);
      WriteRecentVisitors();
      ReleaseLockDir('visitors');
      if ($SurgeProtection and DelayRequired($name)) {
	ReportError(Ts('Too many connections by %s',$name));
	exit;
      }
    }
  }
}

sub DelayRequired {
  my $name = shift;
  my @entries = @{$RecentVisitors{$name}};
  my $ts = $entries[$SurgeProtectionViews - 1];
  return 0 if not $ts;
  return 0 if ($Now - $ts) > $SurgeProtectionTime;
  return 1;
}

sub AddRecentVisitor {
  my $name = shift;
  my $value = $RecentVisitors{$name};
  my @entries;
  if ($value) {
    @entries = @{$value};
    unshift(@entries, $Now);
  } else {
    @entries = ($Now);
  }
  $RecentVisitors{$name} = \@entries;
}

sub ReadRecentVisitors {
  my ($status, $data) = ReadFile($VisitorFile);
  %RecentVisitors = ();
  return  unless $status;
  foreach (split(/$FS1/,$data)) {
    my @entries = split /$FS2/;
    my $name = shift(@entries);
    $RecentVisitors{$name} = \@entries;
  }
}

sub WriteRecentVisitors {
  my $data = '';
  my $limit = $Now - $VisitorTime;
  foreach my $name (keys %RecentVisitors) {
    # for performance, we do not check wether $name is a valid page name
    if ($SurgeProtection or ($Visitors and $name =~ /\./)) {
      my @entries = @{$RecentVisitors{$name}};
      if ($entries[0] >= $limit) {
	# save the data
	if ($SurgeProtection) {
	  $data .= $name . $FS2 . join($FS2, @entries[0 .. $SurgeProtectionViews - 1]) . $FS1;
	} else {
	  $data .= $name . $FS2 . $entries[0] . $FS1;
	}
      }
    }
  }
  WriteStringToFile($VisitorFile, $data);
}

sub DoShowVisitors {
  print GetHeader('', T('Recent Visitors'), '');
  ReadRecentVisitors();
  print '<p><ul>';
  foreach my $name (sort {@{$RecentVisitors{$b}}[0] <=> @{$RecentVisitors{$a}}[0]} (keys %RecentVisitors)) {
    my $time = @{$RecentVisitors{$name}}[0];
    my $total = $Now - $time;
    my $str;
    if ($total >= 7200) {
      $str = Ts('%s hours ago',int($total/3600))
    } elsif ($total >= 3600) {
      $str = T('1 hour ago');
    } elsif ($total >= 120) {
      $str = Ts('%s minutes ago',int($total/60))
    } elsif ($total >= 60) {
      $str = T('1 minute ago');
    } elsif ($total >= 2) {
      $str = Ts('%s seconds ago',int($total))
    } elsif ($total == 1) {
      $str = T('1 second ago');
    } else {
      $str = T('just now');
    }
    print '<li>';
    if (!$name or ($SurgeProtection and $name =~ /\./)) {
      print T('Anonymous');
    } else {
      print GetPageLink($name);
    }
    print ', ', $str, '</li>';
  }
  print '</ul>';
  PrintFooter();
}

# == Track Back ==

sub GetRefererFile {
  my $id = shift;
  return $RefererDir . '/' . GetPageDirectory($id) . "/$id.rb";
}

sub ReadReferers {
  my $file = GetRefererFile(shift);
  %Referers = ();
  if (-f $file) {
    my ($status, $data) = ReadFile($file);
    %Referers = split(/$FS1/, $data, -1) if $status;
  }
}

sub GetReferers {
  my $result = join(' ', map { $q->a({-href=>$_}, $_) } map {QuoteHtml($_)} keys %Referers);
  $result = $q->div({-class=>'refer'}, $q->p(T('Referrers') . ': ' . $result)) if $result;
  return $result;
}

sub UpdateReferers {
  my $self = $q->url();
  my $referer = $q->referer();
  return  unless $referer and $referer !~ /$self/;
  foreach (split(/\n/,GetPageContent($RefererFilter))) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $regexp = $1;
      return  if $referer =~ /$regexp/i;
    }
  }
  my $data = GetRaw($referer);
  return  unless $data =~ /$self/;
  $Referers{$referer} = $Now;
  if ($RefererTimeLimit) {
    foreach (keys %Referers) {
      if ($Now - $Referers{$_} > $RefererTimeLimit) {
	delete $Referers{$_};
      }
    }
  }
  if ($RefererLimit) {
    my @list = sort {$Referers{$a} cmp $Referers{$b}} keys %Referers;
    @list = @list[$RefererLimit .. @list-1];
    foreach (@list) {
      delete $Referers{$_};
    }
  }
  return 1;
}

sub WriteReferers {
  my $id = shift;
  my $data = join($FS1, map { $_ . $FS1 . $Referers{$_} } keys %Referers);
  my $file = GetRefererFile($id);
  RequestLockDir('refer_' . $id);
  CreatePageDir($RefererDir, $id);
  WriteStringToFile($file, $data);
  ReleaseLockDir('refer_' . $id);
}

sub RefererTrack {
  my $id = shift;
  ReadReferers($id);
  if (UpdateReferers($id)) {
    WriteReferers($id);
  }
  my $refs = GetReferers();
  return $q->hr() . $refs if $refs;
}

sub DoPrintAllReferers {
  print GetHeader('', T('All Referrers'), '');
  PrintAllReferers(AllPagesList());
  PrintFooter();
}

sub PrintAllReferers {
  for my $id (@_) {
    ReadReferers($id);
    if (%Referers) {
      print $q->p(ScriptLink(UrlEncode($id),$id));
      print GetReferers();
    }
  }
}

# == Permanent Anchors ==

sub ReadPermanentAnchors {
  my ($status, $data) = ReadFile($PermanentAnchorsFile);
  %PermanentAnchors = ();
  return  unless $status;
  foreach (split(/\n/,$data)) {
    my @entries = split /$FS/;
    my $name = $entries[0];
    $PermanentAnchors{$name} = $entries[1];
  }
}

sub WritePermanentAnchors {
  my $data = '';
  foreach my $name (keys %PermanentAnchors) {
    $data .= $name. $FS . $PermanentAnchors{$name} ."\n";
  }
  WriteStringToFile($PermanentAnchorsFile, $data);
}

sub GetPermanentAnchor {
  my ($id) =  @_;
  $id =~ s/^\s+//;      # Trim extra spaces
  $id =~ s/\s+$//;
  $id = FreeToNormal($id);
  my $text = $id;
  $text =~ s/_/ /g;
  RequestLockDir('permanentanchors', 2, 2, 0);
  ReadPermanentAnchors();
  if ( $PermanentAnchors{$id} ) {
    if ($PermanentAnchors{$id} ne $OpenPageName) {
      ReleaseLockDir('permanentanchors');
      return '[' . T('anchor first defined here') . ' ' . GetPermanentAnchorLink($id) .']';
    }
  } else {
    $PermanentAnchors{$id}=$OpenPageName;
     WritePermanentAnchors();
   }
  ReleaseLockDir('permanentanchors');
  $PagePermanentAnchors{$id} = 1; # add to the list of anchors in page
  $id = UrlEncode($id);
  return ScriptLink("action=anchor&id=$id#$id",$text,'definition',$id);
}

sub GetPermanentAnchorLink {
  my ($id)=@_;
  my $text;
  $id =~ s/^\s+//;      # Trim extra spaces
  $id =~ s/\s+$//;
  $id = FreeToNormal($id);
  $text = $id;
  $text =~ s/_/ /g;
  ReadPermanentAnchors();
  if ( $PermanentAnchors{$id} ) {
    $id = UrlEncode($id);
    return ScriptLink("$PermanentAnchors{$id}#$id",$text,'link');
  }
  return "[## $id]";
}

sub DeletePermanentAnchors {
  RequestLockDir('permanentanchors', 2, 2, 0);
  ReadPermanentAnchors();
  foreach (keys %PermanentAnchors) {
    if ($PermanentAnchors{$_} eq $OpenPageName and !$PagePermanentAnchors{$_}) {
      delete($PermanentAnchors{$_}) ;
    }
  }
  WritePermanentAnchors();
  ReleaseLockDir('permanentanchors');
}

DoWikiRequest()  if ($RunCGI && ($_ ne 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere

# == End of the OddMuse script. ==
