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
use CGI;
use CGI::Carp qw(fatalsToBrowser);
local $| = 1;  # Do not buffer output (localized for mod_perl)

# Configuration/constant variables:

use vars qw(@RcDays @HtmlTags $TempDir $LockDir $DataDir $KeepDir
$PageDir $RefererDir $RcFile $RcOldFile $IndexFile $NoEditFile
$BannedHosts $ConfigFile $FullUrl $SiteName $HomePage $LogoUrl
$RcDefault $IndentLimit $RecentTop $RecentLink $EditAllowed $UseDiff
$RawHtml $KeepDays $HtmlTags $HtmlLinks $KeepMajor $EmbedWiki
$BracketText $UseConfig $UseLookup $AdminPass $EditPass $NetworkFile
$BracketWiki $FreeLinks $WikiLinks $FreeLinkPattern $RCName $RunCGI
$ShowEdits $LinkPattern $InterLinkPattern $InterSitePattern $MaxPost
$UrlPattern $UrlProtocols $ImageExtensions $RFCPattern $ISBNPattern
$FS $CookieName $SiteBase $StyleSheet $NotFoundPg $FooterNote $NewText
$EditNote $HttpCharset $UserGotoBar $VisitorTime $VisitorFile
$Visitors %Smilies %SpecialDays $InterWikiMoniker $SiteDescription
$RssImageUrl $RssPublisher $RssContributor $RssRights $BannedCanRead
$SurgeProtection $SurgeProtectionViews $TopLinkBar $LanguageLimit
$SurgeProtectionTime $DeletedPage %Languages $InterMap $ValidatorLink
$RefererTracking $RefererTimeLimit $RefererLimit $NotifyTracker
@LockOnCreation $RefererFilter $PermanentAnchorsFile $PermanentAnchors
%CookieParameters $NewComment $StyleSheetPage @UserGotoBarPages
$ConfigPage $ScriptName @MyMacros $CommentsPrefix $AllNetworkFiles
$UsePathInfo $UploadAllowed @UploadTypes $LastUpdate $PageCluster
%NotifyJournalPage);

# Other global variables:
use vars qw(%Page %InterSite %IndexHash %Translate %OldCookie
%NewCookie $InterSiteInit $FootnoteNumber $OpenPageName @IndexList
$IndexInit $Message $q $Now %RecentVisitors @HtmlStack %Referers
$Monolithic $ReplaceForm %PermanentAnchors %PagePermanentAnchors
$CollectingJournal $WikiDescription $PrintedHeader %Locks $Fragment
@Blocks @Flags);

# == Configuration ==

# Can be set outside the script: $DataDir, $UseConfig, $ConfigFile,
# $ConfigPage, $AdminPass, $EditPass, $ScriptName, $FullUrl

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
$HttpCharset = 'UTF-8'; # Charset for pages, eg. 'ISO-8859-1'
$MaxPost     = 1024 * 210; # Maximum 210K posts (about 200K for pages)

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
$PermanentAnchors = 1;   # 1 = [::some text] defines permanent anchors (page aliases)
$InterMap    = 'InterMap'; # name of the intermap page

# Other TextFormattingRules
$HtmlTags    = 0;   # 1 = allow some 'unsafe' HTML tags
$RawHtml     = 0;   # 1 = allow <HTML> environment for raw HTML inclusion

# Diff
$ENV{PATH}   = '/usr/bin/'; # Path used to find 'diff'
$UseDiff     = 1;           # 1 = use diff

# Visitors and SurgeProtection
$SurgeProtection      = 1;      # 1 = protect against leeches
$Visitors             = 1;      # 1 = maintain list of recent visitors
$VisitorTime          = 7200;   # Timespan to remember visitors in seconds
$SurgeProtectionTime  = 20;     # Size of the protected window in seconds
$SurgeProtectionViews = 10;     # How many page views to allow in this window
$RefererTracking      = 0;      # Keep track of referrals to your pages
$RefererTimeLimit     = 86400;  # How long referrals shall be remembered in seconds
$RefererLimit         = 15;     # How many different referer shall be remembered
$RefererFilter = 'ReferrerFilter'; # name of the filter pg

# RecentChanges and KeptPages
$DeletedPage = 'DeletedPage';   # Pages starting with this can be deleted
$RCName      = 'RecentChanges'; # Name of changes page
@RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
$RcDefault   = 30;  # Default number of RecentChanges days
$KeepDays    = 14;  # Days to keep old revisions
$KeepMajor   = 1;   # 1 = keep at least one major rev when expiring pages
$ShowEdits   = 0;   # 1 = major and show minor edits in recent changes
$UseLookup   = 1;   # 1 = lookup host names instead of using only IP numbers
$RecentTop   = 1;   # 1 = most recent entries at the top of the list
$RecentLink  = 1;   # 1 = link to usernames
$PageCluster = '';  # name of cluster page, eg. 'Cluster' to enable

# RSS and other Weblog Technology
$InterWikiMoniker = '';    # InterWiki prefix for this wiki for RSS
$SiteDescription  = '';    # RSS Description of this wiki
$RssImageUrl      = '';    # URL to image to associate with your RSS feed
$RssPublisher     = '';    # Name of RSS publisher
$RssContributor   = '';    # List or description of the contributors
$RssRights        = '';    # Copyright notice for RSS
$NotifyTracker    = 0;     # 1 = send pings to weblogs.com for major changes
%NotifyJournalPage = ();   # $NotifyJournalPage{'\d\d\d\d-\d\d-\d\d'}='Diary';

# File uploads
$UploadAllowed    = 0;     # 1 = yes, 0 = administrators only
@UploadTypes      = ('image/jpeg', 'image/png'); # MIME types allowed

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

@LockOnCreation = ($BannedHosts, $InterMap, $RefererFilter, $StyleSheetPage, $ConfigPage);

%CookieParameters = ('username'=>'', 'pwd'=>'', 'theme'=>'', 'css'=>'', 'msg'=>'',
		     'toplinkbar'=>$TopLinkBar, 'embed'=>$EmbedWiki);

$IndentLimit = 20;                  # Maximum depth of nested lists
$LanguageLimit = 3;                 # Number of matches req. for each language
$PageDir     = "$DataDir/page";     # Stores page data
$KeepDir     = "$DataDir/keep";     # Stores kept (old) page data
$RefererDir  = "$DataDir/referer";  # Stores referer data
$TempDir     = "$DataDir/temp";     # Temporary files and locks
$LockDir     = "$TempDir/lock";     # DB is locked if this exists
$NoEditFile  = "$DataDir/noedit";   # Indicates that the site is read-only
$RcFile      = "$DataDir/rc.log";    # New RecentChanges logfile
$RcOldFile   = "$DataDir/oldrc.log"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$VisitorFile = "$DataDir/visitors.log"; # List of recent visitors
$PermanentAnchorsFile = "$DataDir/permanentanchors"; # Store permanent anchors
$ConfigFile  = "$DataDir/config" unless $ConfigFile; # Config file with Perl code to execute

# The 'main' program, called at the end of this script file.
sub DoWikiRequest {
  Init();
  DoSurgeProtection();
  if (not $BannedCanRead and UserIsBanned() and not UserIsAdmin()) {
    ReportError(T('Reading not allowed: user, ip, or network is blocked.'));
  }
  DoBrowseRequest();
}

sub ReportError { # fatal!
  my $errmsg = shift;
  print GetHttpHeader('text/html', 1); # no caching
  print $q->h2($errmsg), $q->end_html;
  map { ReleaseLockDir($_); } keys %Locks;
  exit (1);
}

sub Init {
  $FS  = "\x1e";      # The FS character is the RECORD SEPARATOR control char in ASCII
  $Message = '';      # Warnings and non-fatal errors.
  InitLinkPatterns(); # Link pattern can be changed in config files
  if ($UseConfig and $ConfigFile and -f $ConfigFile) {
    do $ConfigFile;
    $Message .= CGI::p("$ConfigFile: $@") if $@; # no $q exists, yet
  }
  InitRequest();      # get $q
  if ($ConfigPage) {  # $FS, $HttpCharset, $MaxPost must be set in config file!
    eval GetPageContent($ConfigPage);
    $Message .= $q->p("$ConfigPage: $@") if $@;
  }
  InitVariables();    # Ater config file, to post-process some variables
  InitCookie();       # After request, because $q is used
}

sub InitRequest {
  $CGI::POST_MAX = $MaxPost;
  $q = new CGI;
  $q->charset($HttpCharset) if $HttpCharset;
}

sub InitVariables {    # Init global session variables for mod_perl!
  $ReplaceForm = 0;    # Only admins may search and replace
  $ScriptName = $q->url() unless defined $ScriptName; # URL used in links
  $FullUrl = $ScriptName unless $FullUrl; # URL used in forms
  $Now = time;         # Reset in case script is persistent
  if (not $LastUpdate) { # mod_perl: stat should be unnecessary since LastUpdate persists.
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($IndexFile);
    $LastUpdate = $mtime;
  }
  $InterSiteInit = 0;
  %InterSite = ();
  %Locks = ();
  $OpenPageName = '';  # Currently open page
  $PrintedHeader = 0;  # Error messages don't print headers unless necessary
  CreateDir($DataDir); # Create directory if it doesn't exist
  ReportError(Ts('Could not create %s', $DataDir) . ": $!") unless -d $DataDir;
  @UserGotoBarPages = ($HomePage, $RCName) unless @UserGotoBarPages;
  map { $$_ = FreeToNormal($$_); } # convert spaces to underscores on all configurable pagenames
    (\$HomePage, \$RCName, \$BannedHosts, \$InterMap, \$RefererFilter, \$StyleSheetPage,
     \$ConfigPage, \$NotFoundPg);
  if (not @HtmlTags) { # do not override settings in the config file
    if ($HtmlTags) {   # allow many tags
      @HtmlTags = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
		     em s strike strong tt var div center blockquote ol ul dl
		     table caption br p hr li dt dd tr td th);
    } else {	       # only allow a very small subset
      @HtmlTags = qw(b i u em strong tt);
    }
  }
  $WikiDescription = $q->p($q->a({-href=>'http://www.oddmuse.org/'}, 'Oddmuse'))
    . $q->p('$Id: wiki.pl,v 1.255 2003/11/11 17:09:05 as Exp $');
}

sub InitCookie {
  undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
  %OldCookie = split(/$FS/, $q->cookie($CookieName));
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
  $LinkPattern = "($WikiWord)$QDelim";
  # Inter-site convention: sites must start with uppercase letter.
  # This avoids confusion with URLs.
  $InterSitePattern = '[A-Z\x80-\xff]+[A-Za-z\x80-\xff]+';
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

sub Clean {
  my $block = (shift);
  return 0 if $block eq ''; # "0" must print!
  print $block;
  $Fragment .= $block;
  return 1; # if the result of Clean() is used in a test
}

sub Dirty { # arg 1 is the raw text; the real output must be printed instead
  if ($Fragment ne '') {
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  push(@Blocks, (shift));
  push(@Flags, 1);
  $Fragment = '';
};

sub ApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks, $withanchors, $revision) = @_;
  $text =~ s/\r\n/\n/g; # DOS to Unix
  my $state = ''; # quote, list, or normal ('')
  local $Fragment = ''; # the clean HTML fragment not yet on @Blocks
  local @Blocks;  # the list of cached HTML blocks
  local @Flags;   # a list for each block, 1 = dirty, 0 = clean
  my $htmlre = join('|',(@HtmlTags));
  local $_ = $text;
  while(1) {
    my $bol = m/\G^/cgsm;
    # Block level elements eat empty lines to prevent empty p elements.
    if (pos == 0 and m/^#FILE ([^ \n]+)\n(.*)/cgs) {
      Clean(Upload($OpenPageName, (substr($1, 0, 6) eq 'image/'), $revision));
    } elsif ($bol && m/\G&lt;pre&gt;\n?(.*?\n)&lt;\/pre&gt;[ \t]*\n?/cgs) {
      Clean(CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1));
    } elsif ($bol && m/\G(\s*\n)*(\*+)[ \t]*/cg) {
      Clean(OpenHtmlEnvironment('ul',length($2)) . AddHtmlEnvironment('li'));
    } elsif ($bol && m/\G(\s*\n)*(\#+)[ \t]*/cg) {
      Clean(OpenHtmlEnvironment('ol',length($2)) . AddHtmlEnvironment('li'));
    } elsif ($bol && m/\G(\s*\n)*(\:+)[ \t]*/cg) { # blockquote instead?
      Clean(OpenHtmlEnvironment('dl',length($2), 'quote')
	    . $q->dt() . AddHtmlEnvironment('dd'));
    } elsif ($bol && m/\G(\s*\n)*(\=+)[ \t]*(.*?)[ \t]*(=+)[ \t]*\n?/cg) {
      Clean(CloseHtmlEnvironments() . WikiHeading($2, $3));
    } elsif ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg) {
      Clean(CloseHtmlEnvironments() . $q->hr());
    } elsif ($bol && m/\G(\s*\n)*(([ \t]+.*\n?)+)/cg) {
      Clean(OpenHtmlEnvironment('pre',1) . $2); # always level 1
    } elsif ($bol && m/\G(\s*\n)*(\;+)[ \t]*(?=.*\:)/cg) {
      Clean(OpenHtmlEnvironment('dl',length($2))
	    . AddHtmlEnvironment('dt')); # `:' needs special treatment, later
    } elsif ($bol && m/\G(\s*\n)*((\|\|)+)[ \t]*(?=.*\|\|[ \t]*(\n|$))/cg) {
      Clean(OpenHtmlEnvironment('table',1,'user') # `||' needs special treatment, later
	    . AddHtmlEnvironment('tr')
	    . ((length($2) == 2)
	       ? AddHtmlEnvironment('td')
	       : AddHtmlEnvironment('td', 'colspan="' . length($2)/2 . '"')));
    } elsif ($bol && m/\G(\s*\n)+/cg) {
      Clean(CloseHtmlEnvironments() . '<p>');
    } elsif ($bol && m/\G(\&lt;include(\s+(text|with-anchors))?\s+"(.*)"\&gt;[ \t]*\n?)/cgi) {
      # <include "uri..."> includes the text of the given URI verbatim
      Dirty($1);
      my ($oldpos, $type, $uri) = ((pos), $3, $4);
      if ($uri =~ /^$UrlProtocols:/) {
	if ($type eq 'text') {
	  print $q->pre(QuoteHtml(GetRaw($uri)));
	} else {
	  ApplyRules(QuoteHtml(GetRaw($uri)), 0, ($type eq 'with-anchors')); # no local links
	}
      } else {
	if ($type eq 'text') {
	  print $q->pre(QuoteHtml(GetPageContent(FreeToNormal($uri))));
	} else {
	  ApplyRules(QuoteHtml(GetPageContent(FreeToNormal($uri))),
		     $locallinks, $withanchors, $revision);
	}
      }
      pos = $oldpos;		# restore \G after call to ApplyRules
    } elsif ($bol && m/\G(\&lt;journal(\s+(\d*))?(\s+"(.*)")?(\s+(reverse))?\&gt;[ \t]*\n?)/cgi) {
      # <journal 10 "regexp"> includes 10 pages matching regexp
      Dirty($1);
      my $oldpos = pos;
      PrintJournal($3, $5, $7);
      pos = $oldpos;		# restore \G after call to ApplyRules
    } elsif ($bol && m/\G(\&lt;rss(\s+(\d*))?\s+(.*?)\&gt;[ \t]*\n?)/cgis) {
      # <rss "uri..."> stores the parsed RSS of the given URI
      Dirty($1);
      my $oldpos = pos;
      # the string returned will be converted to latin-1 unless we tell perl
      binmode(STDOUT, ":encoding($HttpCharset)");
      print RSS($3 ? $3 : 15, split(/ +/, $4));
      binmode(STDOUT, ":bytes");
      pos = $oldpos;
      # restore \G after call to RSS which uses the LWP module (for older copies of the module?)
    } elsif ($HtmlStack[0] eq 'dt' && m/\G:/cg) {
      Clean(CloseHtmlEnvironment() . AddHtmlEnvironment('dd'));
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)[ \t]*/cg) {
      Clean('</td></tr><tr>' . ((length($3) == 2)
				? '<td>' : ('<td colspan="' . length($3)/2 . '">')));
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*(?!(\n|$))/cg) { # continued
      Clean('</td>' . ((length($1) == 2) ? '<td>' : ('<td colspan="' . length($1)/2 . '">')));
    } elsif ($HtmlStack[0] eq 'td' && m/\G[ \t]*((\|\|)+)[ \t]*/cg) { # at the end of the table
      Clean(CloseHtmlEnvironments());
    } elsif (m/\G\&lt;nowiki\&gt;(.*?)\&lt;\/nowiki\&gt;/cgis) { Clean($1);
    } elsif (m/\G\&lt;code\&gt;(.*?)\&lt;\/code\&gt;/cgis) { Clean($q->code($1));
    } elsif ($RawHtml && m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgis) { Clean(UnquoteHtml($1));
    } elsif (m/\G$RFCPattern/cg) { Clean(&RFC($1));
    } elsif (m/\G($ISBNPattern)/cg) { Dirty($1); print ISBN($2);
    } elsif (m/\G'''/cg) { # traditional wiki syntax with '''strong'''
      Clean(($HtmlStack[0] eq 'strong') ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong'));
    } elsif (m/\G''/cg) {     #  traditional wiki syntax with ''emph''
      Clean(($HtmlStack[0] eq 'em') ? CloseHtmlEnvironment() : AddHtmlEnvironment('em'));
    } elsif (m/\G\&lt;($htmlre)\&gt;/cgi) { Clean(AddHtmlEnvironment($1));
    } elsif (m/\G\&lt;\/($htmlre)\&gt;/cgi) { Clean(CloseHtmlEnvironment($1));
    } elsif (m/\G\&lt;($htmlre) *\/\&gt;/cgi) { Clean("<$1 />");
    } elsif ($HtmlLinks && m/\G\&lt;a(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/cgi) { # <a ...>text</a>
      Clean("<a$1>$2</a>");
    } elsif ($locallinks
	     and ($BracketText && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cog
		  or m/\G(\[$InterLinkPattern\])/cog or m/\G($InterLinkPattern)/cog)) {
      # [InterWiki:FooBar text] or [InterWiki:FooBar] or InterWiki:FooBar -- Interlinks can change
      # when the intermap changes (local config, therefore depend on $locallinks).  The intermap
      # is only read if necessary, so if this not an interlink, we have to backtrack a bit.
      my $bracket = (substr($1, 0, 1) eq '[');
      my ($oldmatch, $output) = ($1, GetInterLink($2, $3, $bracket)); # $3 may be empty
      if ($oldmatch eq $output) { # no interlink
	my ($site, $rest) = split(/:/, $oldmatch, 2);
	Clean($site);
	pos = (pos) - length($rest) - 1; # skip site, but reparse rest
      } else {
	print $output; # this is an interlink
	Dirty($oldmatch);
      }
    } elsif ($BracketText && m/\G(\[$UrlPattern\s+([^\]]+?)\])/cog
	    or m/\G(\[$UrlPattern\])/cog or m/\G($UrlPattern)/cog) {
      # [URL text] makes [text] link to URL, [URL] makes footnotes [1]
      my $bracket = (substr($1, 0, 1) eq '[');
      Clean(GetUrl($2, $3, $bracket, not $bracket)); # $2 may be empty
    } elsif ($WikiLinks && m/\G!$LinkPattern/cog) { Clean($1); # ! gets eaten
    } elsif ($PermanentAnchors && m/\G(\[::$FreeLinkPattern\])/cog) {
      #[::Free Link] permanent anchor create only $withanchors
      Dirty($1);
      if ($withanchors) {
	print GetPermanentAnchor($2);
      } else {
	print $q->span({-class=>'permanentanchor'}, $2);
      }
    } elsif ($WikiLinks && $locallinks
	     && ($BracketWiki && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cog
		 or m/\G(\[$LinkPattern\])/cog or m/\G($LinkPattern)/cog)) {
      # [LocalPage text], [LocalPage], LocalPage
      Dirty($1);
      my $bracket = (substr($1, 0, 1) eq '[');
      print GetPageOrEditLink($2, $3, $bracket);
    } elsif ($FreeLinks && $locallinks
	     && ($BracketWiki && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cog
		 or m/\G(\[\[$FreeLinkPattern\]\])/cog)) {
      # [[Free Link|text]], [[Free Link]]
      Dirty($1);
      print GetPageOrEditLink($2, $3, 0 , 1); # $3 may be empty
    } elsif (%Smilies && (Clean(SmileyReplace()))) {
    } elsif (eval { local $SIG{__DIE__}; Clean(MyRules()); }) {
    } elsif (m/\G\s*\n(s*\n)+/cg) { # paragraphs: at least two newlines
      Clean(CloseHtmlEnvironments() . '<p>'); # there is another one like this further up
    } elsif (m/\G\s+/cgs) { Clean(' ');
    } elsif (m/\G(\w+)/cgi or m/\G(\S)/cg) { Clean($1); # one block at a time, consider word<b>!
    } else { last;
    }
  }
  # last block -- close it, cache it
  Clean(CloseHtmlEnvironments());
  if ($Fragment ne '') {
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  # this can be stored in the page cache -- see PrintCache
  return (join($FS, @Blocks), join($FS, @Flags));
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
    return "<$code $attr>" if ($attr);
    return "<$code>";
  }
  return ''; # always return something
}

sub CloseHtmlEnvironments { # close all
  my $text = ''; # always return something
  $text .=  '</' . shift(@HtmlStack) . '>'  while (@HtmlStack > 0);
  return $text;
}

sub OpenHtmlEnvironment { # close the previous one and open a new one instead
  my ($code, $depth, $class) = @_;
  my $text = '';		# always return something
  my @stack;
  my $found = 0;
  while (@HtmlStack and $found < $depth) { # determine new stack
    my $tag = pop(@HtmlStack);
    $found++ if $tag eq $code;
    unshift(@stack,$tag);
  }
  if (@HtmlStack and $found < $depth) { # nested sublist coming up, keep list item
    unshift(@stack, pop(@HtmlStack));
  }
  if (not $found) { # if starting a new list
    @HtmlStack = @stack;
    @stack = ();
  }
  while (@HtmlStack) { # close remaining elements (or all elements if a new list)
    $text .=  '</' . shift(@HtmlStack) . '>';
  }
  @HtmlStack = @stack;
  $depth = $IndentLimit  if ($depth > $IndentLimit); # requested depth 0 makes no sense
  for (my $i = $found; $i < $depth; $i++) {
    unshift(@HtmlStack, $code);
    if ($class) {
      $text .= "<$code class=\"$class\">";
    } else {
      $text .= "<$code>";
    }
  }
  return $text;
}

sub SmileyReplace {
  my $match = '';
  foreach my $regexp (keys %Smilies) {
    if (m/\G($regexp)/cg) {
      $match = $q->img({-src=>$Smilies{$regexp}, -alt=>$1, -class=>'smiley'});
      last;
    }
  }
  return $match;
}

sub PrintWikiToHTML {
  my ($pageText, $savecache, $revision, $islocked) = @_;
  $FootnoteNumber = 0;
  $pageText =~ s/$FS//g; # Remove separators (paranoia)
  $pageText = QuoteHtml($pageText);
  my ($blocks, $flags) = ApplyRules($pageText, 1, $savecache, $revision);
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
  my ($num, $regexp, $mode) = @_;
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
    if ($mode eq 'reverse') {
      @pages = reverse @pages;
    }
    @pages = @pages[0 .. $num - 1] if $#pages >= $num;
    if (@pages) {
      # Now save information required for saving the cache of the current page.
      local (%Page, $OpenPageName);
      print '<div class="journal">';
      PrintAllPages(1, 1, @pages);
      print '</div>';
    }
    $CollectingJournal = 0;
  }
}

sub RSS {
  my $maxitems = shift;
  my @uris = @_;
  my %lines;
  require XML::RSS;
  require LWP::UserAgent;
  my $tDiff = T('(diff)');
  my $tHistory = T('history');
  my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
  my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  foreach my $uri (@uris) {
    $uri =~ s/^"?(.*?)"?$/$1/;
    my $rss = new XML::RSS;
    my $ua = new LWP::UserAgent;
    my $request = HTTP::Request->new('GET', $uri);
    my $response = $ua->request($request);
    my $data = $response->content;
    eval { local $SIG{__DIE__}; $rss->parse($data); };
    return $q->p($q->strong("[RSS parsing failed for $uri]")) if $@;
    my ($counter, $interwiki);
    if (@uris > 1) {
      $interwiki = $rss->{channel}->{$wikins}->{interwiki};
      $interwiki =~ s/^\s+//; # when RDF is used, sometimes whitespace remains,
      $interwiki =~ s/\s+$//; # which breaks the test for an existing $interwiki below
      if (!$interwiki) {
	$interwiki = $rss->{channel}->{$rdfns}->{value};
      }
    }
    foreach my $i (@{$rss->{items}}) {
      my $line;
      my $date = $i->{'dc'}->{'date'};
      $date = $i->{'pubdate'} unless $date;
      $line .= $q->a({-href=>$i->{$wikins}->{diff}}, $tDiff)
	if $i->{$wikins}->{diff};
      $line .= ' ' . $q->a({-href=>$i->{'link'}, -title=>$date},
			   $interwiki ? "$interwiki:$i->{'title'}" : "[$i->{'title'}]")
	if $i->{'title'} and $i->{'link'};
      $line .= ' ' . $q->a({-href=>$i->{guid}, -title=>$date}, $i->{guid})
	if $i->{guid}; # for RSS 2.0
      $line .= ' ' . $q->a({-href=>$i->{$wikins}->{history}}, "($tHistory)")
	if $i->{$wikins}->{history};
      $line .= ' -- ' . $q->span({-class=>'description'}, $i->{description})
	if $i->{description};
      my $contributor = $i->{dc}->{contributor};
      $contributor =~ s/^\s+//;
      $contributor =~ s/\s+$//;
      if (!$contributor) {
	$contributor = $i->{$rdfns}->{value};
      }
      $line .= $q->span({-class=>'contributor'}, $q->span(' . . . . . ') . $contributor)
	if $contributor;
      my $key = $date;
      $key = $i->{'title'} unless $key;
      $key = $i->{'guid'} unless $key;
      $lines{$key} = $line;
    }
  }
  my @lines = sort { $b cmp $a } keys %lines;
  @lines = @lines[0..$maxitems-1] if $maxitems and $#lines > $maxitems;
  my $str;
  foreach my $i (@lines) { $str .= $q->li($lines{$i}); }
  return $q->div({-class=>'rss'}, $q->ul($str));
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
  $url =~ s/\%s/$page/ or $url .= $page;
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
  $id = FreeToNormal($id) if $FreeLinks;
  my ($class, $exists, $title) = ResolveId($id);
  if (!$text && $exists && $bracket) {
    $text = ++$FootnoteNumber;
  }
  if ($exists) {
    $text = $id unless $text;
    $text =~ s/_/ /g if $free;
    $text = "[$text]" if $bracket;
    return ScriptLink(UrlEncode($id), $text, $class, '', $title);
  } else {
    # $free and $bracket usually exclude each other
    # $text and not $bracket exclude each other
    my $link = ScriptLink('action=edit;id=' . UrlEncode($id), '?');
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
  return ScriptLink('action=edit;id=' . UrlEncode($id), $name);
}

sub ScriptLink {
  my ($action, $text, $class, $name, $title) = @_;
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
  $params{'-title'} = $title  if $title;
  return $q->a(\%params, $text);
}

sub Upload {
  my ($id, $image, $revision) = @_;
  AllPagesList();
  my $action = "action=download;id=$id";
  $action .= ";revision=$revision" if $revision;
  if (not $IndexHash{$id}) { # page does not exist
    return '[' . ($image ? 'image' : 'link') . ':' . $id . ']';
  } elsif ($image) {
    return $q->img({-src=>"$ScriptName?$action", -alt=>$id, -class=>'upload'});
  } else {
    return ScriptLink($action, $id, 'upload');
  }
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

sub PrintCache { # Use after OpenPage!
  my @blocks = split($FS,$Page{blocks});
  my @flags = split($FS,$Page{flags});
  foreach my $block (@blocks) {
    if (shift(@flags)) {
      ApplyRules($block, 1, 1); # local links, anchors, current revision
    } else {
      print $block;
    }
  }
}

# == Translating ==

sub T {
  my $text = shift;
  return $Translate{$text} if $Translate{$text};
  return $text;
}

sub Ts {
  my ($text, $string) = @_;
  $text = T($text);
  $text =~ s/\%s/$string/;
  return $text;
}

sub Tss {
  my $text = @_[0];
  $text = T($text);
  $text =~ s/\%([1-9])/$_[$1]/ge;
  return $text;
}

# == Choosing action

sub DoBrowseRequest {
  if (not $q->param and not ($UsePathInfo and $q->path_info)) {
    BrowsePage($HomePage);
    return 1;
  }
  my $id = join('_', $q->keywords);
  $id = $q->path_info() if not $id and $UsePathInfo;
  $id =~ s|.*/||;
  return BrowseResolvedPage($id) if $id; # script?PageName or script/PageName
  $id = GetParam('id', '');
  my $action = lc(GetParam('action', ''));
  my $search = GetParam('search', '');
  if ($action eq 'browse') {
    BrowseResolvedPage($id);
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
    DoEdit($id)  if ValidIdOrDie($id);
  } elsif ($action eq 'download') {
    DoDownload($id)  if ValidIdOrDie($id);
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
  } elsif ($action eq 'rollback') {
    DoRollback();
  } elsif (($search ne '') || (GetParam('dosearch', '') ne '')) {
    DoSearch($search);
  } elsif (GetParam('title', '')) {
    DoPost(GetParam('title', ''));
  } elsif ($action and defined &MyActions) {
    eval { local $SIG{__DIE__}; MyActions(); };
  } else {
    if ($action) {
      ReportError(Ts('Invalid action parameter %s', $action));
    } else {
      ReportError(T('Invalid URL.'));
    }
  }
}

# == Id handling ==

sub ValidId {
  my $id = shift;
  return Ts('Page name is too long: %s', $id)  if (length($id) > 120);
  if ($FreeLinks) {
    $id =~ s/ /_/g;
    return Ts('Invalid Page %s', $id)  if (!($id =~ m|^$FreeLinkPattern$|));
    return Ts('Invalid Page %s (must not end with .db)', $id)  if ($id =~ m|\.db$|);
    return Ts('Invalid Page %s (must not end with .lck)', $id)  if ($id =~ m|\.lck$|);
  } else {
    return Ts('Page name may not contain space characters: %s', $id) if ($id =~ m| |);
    return Ts('Invalid Page %s', $id)  if (!($id =~ /^$LinkPattern$/));
  }
  return '';
}

sub ValidIdOrDie {
  my $id = shift;
  my $error;
  $error = ValidId($id);
  ReportError($error) if $error;
  return 1;
}

sub ResolveId {
  my $id = shift;
  AllPagesList();
  return ('local', $id) if $IndexHash{$id}; # page exists
  if ($PermanentAnchors) {
    ReadPermanentAnchors();
    my $anchor = $PermanentAnchors{$id};
    return ('alias', $anchor) if $anchor; # permanent anchor exists
  }
}

sub BrowseResolvedPage {
  my $id = shift;
  $id = FreeToNormal($id) if $FreeLinks; # needed even if page does not exist
  my ($class, $resolved) = ResolveId($id);
  if ($class eq 'alias') { # an anchor was found instead of a page
    ReBrowsePage($resolved . '#' . $id);
  } elsif (not $resolved and $NotFoundPg) { # custom page-not-found message
    BrowsePage($NotFoundPg);
  } else {
    BrowsePage($id, GetParam('raw', 0)) if ValidIdOrDie($id);
  }
}

# == Browse page ==

sub BrowsePage {
  my ($id, $raw) = @_;
  if ($q->http('HTTP_IF_MODIFIED_SINCE') eq gmtime($LastUpdate)) {
    print $q->header(-status=>'304 NOT MODIFIED');
    return;
  }
  OpenPage($id);
  my $text = $Page{text};
  # Handle a single-level redirect
  my $oldId = GetParam('oldid', '');
  if (($oldId eq '') && (substr($text, 0, 10) eq '#REDIRECT ')) {
    if ($FreeLinks and $text =~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\]\]/) {
      ReBrowsePage(FreeToNormal($1), $id);
      return;
    } elsif ($WikiLinks and $text =~ /^\#REDIRECT\s+$LinkPattern/) {
      ReBrowsePage($1, $id);
      return;
    }
  }
  # shortcut if we only need the raw text: no caching, no diffs, no html.
  if ($raw) {
    print GetHttpHeader('text/plain');
    if ($raw == 2) {
      print $Page{'ts'} . " # Do not delete this line when editing!\n";
    }
    print $text;
    return;
  }
  my $msg = GetParam('msg', '');
  $Message .= $q->p($msg) if $msg; # show message if the page is shown
  $NewCookie{'msg'} = '';
  # handle subtitle for old revisions, if these exist, and open keep file
  my $revision = GetParam('revision', ''); # default empty string
  $revision =~ s/\D//g; # Remove non-numeric chars
  my $goodRevision; # empty string if no specific revision specified
  $goodRevision = $revision if $revision ne $Page{'revision'};
  if ($goodRevision) {
    my %keep = GetKeptRevision($goodRevision);
    if (not %keep) {
      $goodRevision = ''; # reset if requested revision is not available
      $Message .= $q->p(Ts('Revision %s not available', $revision)
			. ' (' . T('showing current revision instead') . ')');
    } else {
      $Message .= $q->p(Ts('Showing revision %s', $goodRevision));
      $text = $keep{text};
    }
  }
  # print header
  print GetHeader($id, QuoteHtml($id), $oldId);
  # print diff, if required
  my $showDiff = GetParam('diff', 0);
  if ($UseDiff && $showDiff) {
    my $diffRevision = GetParam('diffrevision', $goodRevision);
    PrintHtmlDiff($showDiff, $id, $diffRevision, $revision, $text);
    print $q->hr();
  }
  # print HTML of the main text
  print '<div class="content">';
  if ($revision eq '' && $Page{blocks} && $Page{flags} && GetParam('cache',1)) {
    PrintCache();
  } else {
    my $savecache = ($Page{'revision'} > 0 and $revision eq ''); # new page not cached
    PrintWikiToHTML($text, $savecache, $revision); # unlocked, with anchors, unlocked
  }
  print '</div>';
  my $embed = GetParam('embed', $EmbedWiki);
  if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)
      || GetParam('rcclusteronly', '')) {
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
  my ($id, $oldId) = @_;
  if ($oldId ne '') {   # Target of #REDIRECT (loop breaking)
    print GetRedirectPage("action=browse;oldid=$oldId;id=$id", $id);
  } else {
    print GetRedirectPage($id, $id);
  }
}

sub GetRedirectPage {
  my ($action, $name) = @_;
  my ($url, $html);
  my ($nameLink);
  # shortcut if we only need the raw text: no redirect.
  if (GetParam('raw', 0)) {
    $html = GetHttpHeader('text/plain');
    $html .= Ts('Please go on to %s.', $action);
    return $html;
  }
  if ($UsePathInfo and $action !~ /=/) {
    $url = $FullUrl . '/' . $action;
  } else {
    $url = $FullUrl . '?' . $action;
  }
  $nameLink = $q->a({-href=>$url}, $name);
  # NOTE: do NOT use -method (does not work with old CGI.pm versions)
  # Thanks to Daniel Neri for fixing this problem.
  my %headers = (-uri=>$url);
  my $cookie = Cookie();
  if ($cookie) {
    $headers{-cookie} = $cookie;
  }
  return $q->redirect(%headers);
}

# == Recent changes and RSS

sub DoRcText {
  print GetHttpHeader('text/plain');
  DoRc(\&GetRcText);
}

sub DoRc {
  my $GetRC = shift;
  my $showHTML = $GetRC eq \&GetRcHtml; # optimized for HTML
  my $starttime = 0;
  if (GetParam('from', 0)) {
    $starttime = GetParam('from', 0);
  } else {
    $starttime = $Now - GetParam('days', $RcDefault) * 86400; # 24*60*60
  }
  # Read rclog data (and oldrclog data if needed)
  my $errorText = '';
  my ($status, $fileData) = ReadFile($RcFile);
  if (!$status) {
    # Save error text if needed.
    $errorText = $q->p($q->strong(Ts('Could not open %s log file', $RCName)
				  . ':') . ' ' . $RcFile)
      . $q->p(T('Error was') . ':')
      . $q->pre($!)
      . $q->p(T('Note: This error is normal if no changes have been made.'));
  }
  my @fullrc = split(/\n/, $fileData);
  my $firstTs = 0;
  if (@fullrc > 0) {  # Only false if no lines in file
    ($firstTs) = split(/$FS/, $fullrc[0]); # just look at the first element
  }
  if (($firstTs == 0) || ($starttime <= $firstTs)) {
    my ($status, $oldFileData) = ReadFile($RcOldFile);
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
  RcHeader(@fullrc) if $showHTML;
  my $i = 0;
  while ($i < @fullrc) { # Optimization: skip old entries quickly
    my ($ts) = split(/$FS/, $fullrc[$i]); # just look at the first element
    if ($ts >= $starttime) {
      $i -= 1000  if ($i > 0);
      last;
    }
    $i += 1000;
  }
  $i -= 1000  if (($i > 0) && ($i >= @fullrc));
  for (; $i < @fullrc ; $i++) {
    my ($ts) = split(/$FS/, $fullrc[$i]); # just look at the first element
    last if ($ts >= $starttime);
  }
  if ($i == @fullrc && $showHTML) {
    print $q->p($q->strong(Ts('No updates since %s', TimeToText($starttime))));
  } else {
    splice(@fullrc, 0, $i);  # Remove items before index $i
    print &$GetRC(@fullrc);
  }
  print GetFilterForm() if $showHTML;
}

sub RcHeader {
  if (GetParam('from', 0)) {
    print $q->h2(Ts('Updates since %s', TimeToText(GetParam('from', 0))));
  } else {
    print $q->h2((GetParam('days', $RcDefault) != 1)
	  ? Ts('Updates in the last %s days', GetParam('days', $RcDefault))
	  : Ts('Updates in the last %s day', GetParam('days', $RcDefault)))
  }
  my ($action);
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $langFilter) =
    map {
      my $val = GetParam($_, '');
      print $q->p($q->b('(' . Ts('for %s only', $val) . ')')) if $val;
      $action .= ";$_=$val" if $val; # remember these parameters later!
      $val;
    }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'rclang');
  if ($clusterOnly) {
    $action = GetPageParameters('browse', $clusterOnly) . $action;
  } else {
    $action = "action=rc$action";
  }
  my ($all, $edits, $days, $switches) = (GetParam('all', 0), GetParam('showedit', 0));
  $days = ";days=" . GetParam('days', 0) if GetParam('days', $RcDefault) != $RcDefault;
  if ($all and $edits) {
    $switches = ScriptLink("$action$days;showedit=1", T('List latest change per page only'))
      . ' | ' . ScriptLink("$action$days;all=1", T('List only major changes'));
    $action .= ';all=1;showedit=1';
  } elsif ($all) {
    $switches = ScriptLink("$action$days", T('List latest change per page only'))
      . ' | ' . ScriptLink("$action$days;all=1;showedit=1", T('Include minor changes'));
    $action .= ';all=1';
  } elsif ($edits) {
    $switches = ScriptLink("$action$days;all=1;showedit=1", T('List all changes'))
      . ' | ' . ScriptLink("$action$days", T('List only major changes'));
    $action .= ';showedit=1';
  } else {
    $switches = ScriptLink("$action$days;all=1", T('List all changes'))
      . ' | ' . ScriptLink("$action$days;showedit=1", T('Include minor changes'));
  }
  print $q->p(join(' | ', map { ScriptLink("$action;days=$_",
					   ($_ != 1) ? Ts('%s days', $_) : Ts('%s days', $_));
			      } @RcDays) . $q->br() . $switches . $q->br()
	      . ScriptLink($action . ';from=' . ($LastUpdate + 1), T('List later changes')));
}

sub GetFilterForm {
  my $form = GetFormStart() . $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1}) if (GetParam('all', 0));
  $form .= $q->input({-type=>'hidden', -name=>'showedit', -value=>1}) if (GetParam('showedit', 0));
  $form .= $q->input({-type=>'hidden', -name=>'days', -value=>GetParam('days', $RcDefault)})
    if (GetParam('days', $RcDefault) != $RcDefault);
  my $table =
    $q->Tr($q->td(T('Username:')) . $q->td($q->textfield(-name=>'rcuseronly', -size=>20)))
    . $q->Tr($q->td(T('Host:')) . $q->td($q->textfield(-name=>'rchostonly', -size=>20)));
  $table .= $q->Tr($q->td(T('Language:')) . $q->td($q->textfield(-name=>'rclang', -size=>10)))
    if %Languages;
  $form .= $q->strong(T('Filters')) . $q->table($table);
  return $form . $q->submit('dofilter', T('Go!')) . $q->endform;
}

sub GetRc {
  my $printDailyTear = shift;
  my $printRCLine = shift;
  my @outrc = @_;
  my %extra = ();
  my %changetime = ();
  # Slice minor edits
  my $showedit = GetParam('showedit', $ShowEdits);
  # Filter out some entries if not showing all changes
  if ($showedit != 1) {
    my @temprc = ();
    foreach my $rcline (@outrc) {
      my ($ts, $pagename, $minor) = split(/$FS/, $rcline); # skip remaining fields
      if ($showedit == 0) {	# 0 = No edits
	push(@temprc, $rcline)  if (!$minor);
      } else {			# 2 = Only edits
	push(@temprc, $rcline)  if ($minor);
      }
      $changetime{$pagename} = $ts;
    }
    @outrc = @temprc;
  }
  foreach my $rcline (@outrc) {
    my ($ts, $pagename, $minor) = split(/$FS/, $rcline);
    $changetime{$pagename} = $ts;
  }
  my $date = '';
  my $all = GetParam('all', 0);
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $langFilter) =
    map { GetParam($_, ''); }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'rclang');
  @outrc = reverse @outrc if GetParam('newtop', $RecentTop);
  my @clusters;
  my @filters;
  @filters = SearchTitleAndBody($filterOnly) if $filterOnly;
  foreach my $rcline (@outrc) {
    my ($ts, $pagename, $minor, $summary, $host, $username, $revision, $languages, $cluster)
      = split(/$FS/, $rcline);
    next if not $all and $ts < $changetime{$pagename};
    next if $idOnly and $idOnly ne $pagename;
    next if $hostOnly and $host !~ /$hostOnly/;
    next if $filterOnly and not grep(/^$pagename$/, @filters);
    next if ($userOnly and $userOnly ne $username);
    my @languages = split(/,/, $languages);
    next if ($langFilter and not grep(/$langFilter/, @languages));
    next if ($PageCluster and $clusterOnly and $clusterOnly ne $cluster);
    $cluster = '' if $clusterOnly or not $PageCluster; # since now $clusterOnly eq $cluster
    if ($PageCluster and $all < 2 and not $clusterOnly and $cluster) {
      next if grep(/^$cluster$/, @clusters);
      $pagename = $cluster;
      $summary = '';
      $minor = 0;
      $revision = '';
      push(@clusters, $pagename);
    }
    if ($date ne CalcDay($ts)) {
      $date = CalcDay($ts);
      &$printDailyTear($date);
    }
    &$printRCLine($pagename, $ts, $host, $username, $summary, $minor, $revision,
		  \@languages, $cluster);
  }
}

sub GetRcHtml {
  my ($html, $inlist);
  # Optimize param fetches and translations out of main loop
  my $all = GetParam('all', 0);
  my $admin = UserIsAdmin();
  my $tEdit = T('(minor)');
  my $tDiff = T('(diff)');
  my $tHistory = T('history');
  my $tRollback = T('rollback');
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
	my($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages, $cluster) = @_;
	$host = QuoteHtml($host);
	my $author = GetAuthorLink($host, $userName);
	my $sum = $q->strong('[' . QuoteHtml($summary) . ']')  if $summary;
	my $edit = $q->em($tEdit)  if $minor;
	my $lang = '[' . join(', ', @{$languages}) . ']'  if @{$languages};
	my ($pagelink, $count, $link, $rollback);
	if ($all) {
	  $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	  if ($admin and RollbackPossible($timestamp)) {
	    $rollback = '(' . ScriptLink('action=rollback;to=' . $timestamp, $tRollback) . ')';
	  }
	} elsif ($cluster) {
	  $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	} else {
	  $pagelink = GetPageLink($pagename, $cluster);
	  $count = '(' . GetHistoryLink($pagename, $tHistory) . ')';
	}
	if ($cluster and $PageCluster) {
	  $link .= GetPageLink($PageCluster) . ':';
	} elsif ($UseDiff and GetParam('diffrclink', 1)) {
	  if ($all) {
	    $link .= ScriptLinkDiff(2, $pagename, $tDiff, '', $revision);
	  } else {
	    $link .= ScriptLinkDiff($minor ? 2 : 1, $pagename, $tDiff, '');
	  }
	}
	$html .= $q->li($link, $pagelink, CalcTime($timestamp), $rollback,
			$count, $edit, $sum, $lang, '. . . . .', $author);
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
      my($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages, $cluster) = @_;
      my $uri = $ScriptName . (GetParam('all', 0)
			       ? GetPageParameters('browse', $pagename, $revision, $cluster)
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
  my $quotedFullUrl = QuoteHtml($FullUrl);
  my $diffPrefix = $quotedFullUrl . QuoteHtml("?action=browse;diff=1;id=");
  my $historyPrefix = $quotedFullUrl . QuoteHtml("?action=history;id=");
  my $quotedSiteDescription = QuoteHtml($SiteDescription);
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
    link          => $quotedFullUrl . QuoteHtml("?$RCName"),
    description   => $quotedSiteDescription,
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
    link   => $quotedFullUrl,
  );
  # Now call GetRc with some blocks of code as parameters:
  GetRc
    # printDailyTear
    sub {},
    # printRCLine
    sub {
      my ($pagename, $timestamp, $host, $userName, $summary, $minor, $revision, $languages, $cluster) = @_;
      my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($timestamp);
      my $name = FreeToNormal($pagename);
      $name =~ s/_/ /g;
      $year += 1900;
      my $date = sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00",
	$year, $mon+1, $mday, $hour, $min, $sec);
      my ($description, $author);
      if ($summary ne '') {
	$description = QuoteHtml($summary);
      }
      if( $userName ) {
	$author = QuoteHtml($userName);
      } else {
	$author = $host;
      }
      my $status = (1 == $revision) ? 'new' : 'updated';
      my $importance = $minor ? 'minor' : 'major';
      my $link = $quotedFullUrl
	. '?' . GetPageParameters('browse', $pagename, $revision, $cluster);
      my %wiki = ( status      => $status,
		   importance  => $importance,
		   version     => $revision,
		   history     => $historyPrefix . $pagename, );
      $wiki{diff} = $diffPrefix . $pagename if $UseDiff and GetParam('diffrclink', 1);
      $rss->add_item(
        title         => QuoteHtml($name),
	link          => $link,
	description   => $description,
	dc => {
          date        => $date,
	  contributor => $author,
	},
	wiki => \%wiki,
      );
    },
    # RC Lines
    @_;
  my $limit = GetParam('rsslimit', 15); # Only take the first 15 entries
  if ($limit ne 'all' and $#{$rss->{'items'}} > $limit) {
    @{$rss->{'items'}} = @{$rss->{'items'}}[0..$limit-1];
  }
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
  ReBrowsePage($id);
}

# == History ==

sub DoHistory {
  my $id = shift;
  my ($html, $row);
  print GetHeader('',QuoteHtml(Ts('History of %s', $id)), '');
  OpenPage($id);
  $html = GetHistoryLine($id, \%Page, $row++);
  my @revisions = sort {$b <=> $a} map { m|/([0-9]+).kp$|; $1; } GetKeepFiles($OpenPageName);
  foreach my $revision (@revisions) {
    my %keep = GetKeptRevision($revision);
    $html .= GetHistoryLine($id, \%keep, $row++);
  }
  if ($UseDiff) {
    $html = $q->start_form(-method=>'GET', -action=>$ScriptName)
      # don't use $q->hidden here, because then the sticky action value is used instead
      . $q->input({-type=>'hidden', -name=>'action', -value=>'browse'})
      . $q->input({-type=>'hidden', -name=>'diff', -value=>'1'})
      . $q->input({-type=>'hidden', -name=>'id', -value=>$id})
      . $q->table({-class=>'history'}, $html)
      . $q->submit({-name=>T('Compare')})
      . $q->end_form();
  }
  print $html;
  PrintFooter($id, 'history');
}

sub GetHistoryLine {
  my ($id, $dataref, $row) = @_;
  my %data = %$dataref;
  my $revision = $data{revision};
  my $html;
  if (0 == $row) { # current revision
    $html = GetPageLink($id, Ts('Revision %s', $revision));
  } else {
    $html = GetOldPageLink('browse', $id, $revision, Ts('Revision %s', $revision));
  }
  if ($data{minor}) {
    $html .= ' ' . $q->i(T('(minor)')) . ' ';
  } else {
    $html .= T(' . . . . ');
  }
  $html .= TimeToText($data{ts}) . ' ';
  my $host = $data{host};
  $host = $data{ip} unless $host;
  $html .= T('by') . ' ' . GetAuthorLink($host, $data{username});
  $html .= ' ' . $q->b('[' . QuoteHtml($data{summary}) . ']') if ($data{summary});
  if ($UseDiff) {
    my %attr1 = (-type=>'radio', -name=>'diffrevision', -value=>$revision);
    $attr1{-checked} = 'checked' if 1==$row;
    my %attr2 = (-type=>'radio', -name=>'revision', -value=>$revision);
    $attr2{-checked} = 'checked' if 0==$row;
    $html = $q->Tr($q->td($q->input(\%attr1)), $q->td($q->input(\%attr2)),
		   $q->td($html));
  } else {
    $html .= $q->br();
  }
  return $html;
}

# == Rollback ==

sub RollbackPossible {
  my $ts = shift;
  return ($Now - $ts) < $KeepDays * 24 * 60 * 60;
}

sub DoRollback {
  my $to = GetParam('to', 0);
  print GetHeader('', T('Rolling back changes'), '');
  return unless UserIsAdminOrError();
  ReportError(T('Missing target for rollback.')) unless $to;
  ReportError(T('Target for rollback is too far back.')) unless RollbackPossible($to);
  RequestLockOrError();
  print '<p>';
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    my $text = GetTextAtTime($to);
    OpenDefaultText();
    if ($text ne $text) {
      Save($id, $text, Ts('Rollback to %s', TimeToText($to)), 1,
	   ($Page{'ip'} ne $ENV{REMOTE_ADDR}));
      print Ts('%s rolled back', $id), $q->br();
    }
  }
  print '</p>';
  ReleaseLock();
  PrintFooter();
}

# == HTML and page-oriented functions ==

sub GetPageParameters {
  my ($action, $id, $revision, $cluster) = @_;
  $id = FreeToNormal($id) if $FreeLinks;
  my $link = "action=$action;id=" . UrlEncode($id);
  $link .= ";revision=$revision" if $revision;
  $link .= ";rcclusteronly=$cluster" if $cluster;
  return $link;
}

sub GetOldPageLink {
  my ($action, $id, $revision, $name, $cluster) = @_;
  $name =~ s/_/ /g if $FreeLinks;
  return ScriptLink(GetPageParameters($action, $id, $revision, $cluster), $name);
}

sub GetSearchLink {
  my ($text, $class, $name, $title) = @_;
  my $id = UrlEncode($text);
  if ($FreeLinks) {
    $text =~ s/_/ /g;  # Display with spaces
    $id =~ s/_/+/g;    # Search for url-escaped spaces
  }
  return ScriptLink('search=' . $id, $text, $class, $name, $title);
}

sub ScriptLinkDiff {
  my ($diff, $id, $text, $new, $old) = @_;
  my $action = 'action=browse;diff=' . $diff . ';id=' . UrlEncode($id);
  $action .= ";diffrevision=$old"  if ($old ne '');
  $action .= ";revision=$new"  if ($new ne '');
  return ScriptLink($action, $text);
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
  return ScriptLink('action=history;id=' . UrlEncode($id), $text);
}

sub GetRCLink {
  my ($id, $text) = @_;
  if ($FreeLinks) {
    $id =~ s/ /_/g;
  }
  return ScriptLink('action=rc;all=1;from=1;showedit=1;rcidonly=' . UrlEncode($id), $text);
}

sub GetHeader {
  my ($id, $title, $oldId, $nocache) = @_;
  my $result = '';
  my $embed = GetParam('embed', $EmbedWiki);
  my $altText = T('[Home]');
  $result = GetHttpHeader('text/html', $nocache ? $Now : 0);
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
    $result .= ScriptLink($HomePage, $q->img({-src=>$LogoUrl, -alt=>$altText, -class=>'logo'}));
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
    $result .= $q->h1(GetSearchLink($id, '', '',
				    T('Click to search for references to this page')));
  } else {
    $result .= $q->h1($title);
  }
  $result .= '</div>';
  return $result;
}

sub GetHttpHeader {
  return if $PrintedHeader;
  $PrintedHeader = 1;
  my ($type, $modified) = @_;
  my $mod = gmtime($modified or $LastUpdate);
  my %headers = (-last_modified=>$mod, -cache_control=>'max-age=10'); # HTTP/1.1 headers only
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
  my ($changed, $visible, %params);
  foreach (keys %CookieParameters) {
    my $default = $CookieParameters{$_};
    my $value = GetParam($_, $default);
    $params{$_} = $value  if $value ne $default;
    my $change = ($value ne $OldCookie{$_} and ($OldCookie{$_} ne '' or $value ne $default));
    $visible = 1  if $change and $_ ne 'msg'; # changes to the msg parameter are invisible
    $changed = 1  if $change; # note if any parameter changed and needs storing
  }
  if ($changed) {
    my $cookie = join($FS, %params);
    my $result = $q->cookie(-name=>$CookieName,
			    -value=>$cookie,
			    -expires=>'+2y');
    $Message .= $q->p(T('Cookie: ') . $CookieName . ', '
		      . join(', ', map {$_ . '=' . $params{$_}} keys(%params))) if $visible;
    return $result;
  }
  return '';
}

sub GetHtmlHeader {
  my ($title, $id) = @_;
  my $html;
  $html = $q->base({-href=>$SiteBase}) if $SiteBase;
  my $css = GetParam('css', '');
  if ($css) {
    foreach my $sheet (split(/\s+/, $css)) {
      $html .= qq(<link type="text/css" rel="stylesheet" href="$sheet">);
    }
  } elsif ($StyleSheet) {
    $html .= qq(<link type="text/css" rel="stylesheet" href="$StyleSheet">);
  } elsif ($StyleSheetPage) {
    $html .= $q->style({-type=>'text/css'}, GetPageContent($StyleSheetPage));
  } else {
    $html .= $q->style({-type=>'text/css'},<<EOT);
<!--
body { background-color:#FFF; color:#000; }
a:link { color:#00F; }
a:visited { color:#A0A; }
a:active { color:#F00; }
a.definition:before { content:"[::"; }
a.definition:after { content:"]"; }
a.alias { text-decoration:none; border-bottom: thin dashed; }
a.upload:before { content:"<"; }
a.upload:after { content:">"; }
img.logo { float: right; clear: right; border-style:none; }
div.diff { padding-left:5%; padding-right:5%; }
div.old { background-color:#FFFFAF; }
div.new { background-color:#CFFFCF; }
div.refer { padding-left:5%; padding-right:5%; font-size:smaller; }
div.message { background-color:#FEE; }
div.journal h1 { font-size:large; }
table.history { border-style:none; }
td.history { border-style:none; }
table.user { border-style:solid; border-width:thin; }
table.user tr td { border-style:solid; border-width:thin; padding:5px; text-align:center; }
span.result { font-size:larger; }
span.info { font-size:smaller; font-style:italic; }
div.rss { background-color:#EEF; }
-->
EOT
  }
  # INDEX,NOFOLLOW tag for wiki pages only so that the robot doesn't index
  # history pages.  INDEX,FOLLOW tag for RecentChanges and the index of all
  # pages.  We need the INDEX here so that the spider comes back to these
  # pages, since links from ordinary pages to RecentChanges or the index will
  # not be followed.
  if (($id eq $RCName) or (T($RCName) eq $id) or (T($id) eq $RCName)
      or (lc (GetParam('action', '')) eq 'index')) {
    $html .= '<meta name="robots" content="INDEX,FOLLOW">';
  } elsif ($id eq '') {
    $html .= '<meta name="robots" content="NOINDEX,NOFOLLOW">';
  } else {
    $html .= '<meta name="robots" content="INDEX,NOFOLLOW">';
  }
  $html .= '<link rel="alternate" type="application/rss+xml" title="RSS" href="'
    . $ScriptName . '?action=rss">';
  # finish
  $html = qq(<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">\n<html>)
    . $q->head($q->title($q->escapeHTML($title)) . $html)
    . '<body class="' . GetParam('theme', $q->url()) . '">';
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
		    . GetHiddenValue("summary" , T("new comment"))
		    . GetHiddenValue("recent_edit", "on")
		    . GetTextArea('aftertext', $NewComment)
		    . '<p>' . T('Username:') . ' '
		    . $q->textfield(-name=>'username',
				    -default=>$userName, -override=>1,
				    -size=>20, -maxlength=>50)
		    . $q->p($q->submit(-name=>'Save', -value=>T('Save')))
		    . $q->endform());
    }
  }
  my $html = $q->hr() . GetGotoBar($id);
  # other revisions
  my $revisions;
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    if (UserCanEdit($CommentsPrefix . $id, 0)
	and $OpenPageName !~ /^$CommentsPrefix/) {
      $revisions .= ScriptLink($CommentsPrefix . UrlEncode($OpenPageName),
			       T('Comments on this page'));
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
    $revisions .= GetPageLink($id, T('View current revision'))
      . ' | ' . GetRCLink($id, T('View all changes'));
  }
  if ($CommentsPrefix and $id =~ /^$CommentsPrefix(.*)/) {
    $revisions .= ' | ' if $revisions;
    $revisions .= GetPageLink($1, T('View original'));
  }
  $html .= $q->br() . $revisions  if $revisions;
  # time stamps
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    $html .= $q->br();
    if ($rev eq '') {		# Only for most current rev
      $html .= T('Last edited');
    } else {
      $html .= T('Edited');
    }
    $html .= ' ' . TimeToText($Page{ts}) . ' '
      . Ts('by %s', &GetAuthorLink($Page{'host'}, $Page{'username'}, $Page{'id'}));
    if ($UseDiff) {
      $html .= ' ' . ScriptLinkDiff(1, $id, T('(diff)'), $rev);
    }
  }
  # search
  $html .= GetSearchForm();
  if ($DataDir =~ m|/tmp/|) {
    $html .= $q->p($q->strong(T('Warning') . ': ')
		. Ts('Database is stored in temporary directory %s', $DataDir));
  }
  if ($FooterNote ne '') {
    $html .= T($FooterNote);  # Allow local translations
  }
  if (GetParam('validate', $ValidatorLink)) {
    $html .= $q->p(GetValidatorLink());
  }
  if (GetParam('time',0)) {
    $html .= $q->p(Ts('%s seconds', (time - $Now)));
  }
  print $q->div({-class=>'footer'}, $html);
  eval { local $SIG{__DIE__}; PrintMyContent($id); };
  print $q->end_html;
}

sub GetFormStart {
  my $encoding = (shift) ? 'multipart/form-data' : 'application/x-www-form-urlencoded';
  return $q->start_form(-method=>'post', -action=>$FullUrl, -enctype=>$encoding);
}

sub GetSearchForm {
  my $form = GetFormStart() . T('Search:') . ' '
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
  my $bartext = join(' | ', map { GetPageLink($_) } @UserGotoBarPages);
  $bartext .= ' | ' . $UserGotoBar  if $UserGotoBar ne '';
  return $q->span({-class=>'gotobar'}, $bartext);
}

# == Difference markup and HTML ==

sub PrintHtmlDiff {
  my ($diffType, $id, $revOld, $revNew, $newText) = @_;
  my ($diffText, $intro);
  if ($revOld) {
    $diffText = GetKeptDiff($newText, $revOld);
    $intro = Tss('Difference (from revision %1 to %2)', $revOld,
		 $revNew ? Ts('revision %s', $revNew) : T('current revision'));
  } else {
    $diffText = GetCacheDiff($diffType == 1 ? 'major' : 'minor');
    $intro = Ts('Difference (from prior %s revision)',
		$diffType == 1 ? T('major') : T('minor'));
  }
  $diffText = T('No diff available.') unless $diffText;
  print $q->div({-class=>'diff'}, $q->p($q->b($intro)), $diffText);
}

sub GetCacheDiff {
  my $type = shift;
  my $diff = $Page{"diff-$type"};
  $diff = $Page{"diff-minor"} if ($diff eq '1'); # if major eq minor diff
  return $diff;
}

sub GetKeptDiff {
  my ($newText, $oldRevision) = @_;
  die 'No old revision' unless $oldRevision; # FIXME
  my %keep = GetKeptRevision($oldRevision);
  return '' unless $keep{text};
  return GetDiff($keep{text}, $newText);
}

sub GetDiff {
  my ($old, $new) = @_;
  my ($diff_out, $oldName, $newName);
  $old =~ s/[\r\n]+/\n/g;
  $new =~ s/[\r\n]+/\n/g;
  CreateDir($TempDir);
  $oldName = "$TempDir/old";
  $newName = "$TempDir/new";
  RequestLockDir('diff') or return '';
  WriteStringToFile($oldName, $old);
  WriteStringToFile($newName, $new);
  $diff_out = `diff $oldName $newName`;
  $diff_out =~ s/\\ No newline.*\n//g;   # Get rid of common complaint.
  $diff_out = ImproveDiff($diff_out);
  ReleaseLockDir('diff');
  # No need to unlink temp files--next diff will just overwrite.
  return $diff_out;
}

sub ImproveDiff { # called within a diff lock
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

sub DiffHtmlMarkWords { # this code seem brittle and has been known to crash!
  my ($text,$start,$end) = @_;
  return $text if $end - $start > 50;
  my $first = $start - 1;
  my $words = 1 + $end - $start;
  $text =~ s|^((\S+\s*){$first})((\S+\s*?){$words})|$1<strong class="changes">$3</strong>|;
  return $text;
}

# == Database functions ==

sub ParseData {
  my $data = shift;
  my %result;
  while ($data =~ /(\S+?): (.*?)(?=\n[^\t]|\Z)/sg) {
    my ($key, $value) = ($1, $2);
    $value =~ s/\n\t/\n/g;
    $result{$key} = $value;
  }
  return %result;
}

sub OpenPage { # Sets global variables
  my $id = shift;
  if ($OpenPageName eq $id) {
    return;
  }
  AllPagesList(); # set IndexHash
  if ($IndexHash{$id}) {
    %Page = ParseData(ReadFileOrDie(GetPageFile($id)));
  } else {
    $Page{ts} = $Now;
    $Page{revision} = 0;
    if ($id eq $HomePage and (open(F,'README') or open(F,"$DataDir/README"))) {
      local $/ = undef;
      $Page{text} = <F>;
      close F;
    } else {
      $Page{text} = $NewText;
    }
  }
  $OpenPageName = $id;
}

sub GetTextAtTime {
  my $ts = shift;
  my @keeps = GetKeepFiles($OpenPageName);
  foreach my $keep (@keeps) {
    my ($status, $data) = ReadFile($keep);
    next unless $status;
    my %field = ParseData($data);
    if ($field{ts} == $ts) {
      return $field{text};
    }
  }
  return '';
}

sub GetPageContent {
  my $id = shift;
  AllPagesList(); # set IndexHash
  if ($IndexHash{$id}) {
    my %data = ParseData(ReadFileOrDie(GetPageFile($id)));
    return $data{text};
  }
  return '';
}

sub GetKeptRevision { # Call after OpenPage
  my ($status, $data) = ReadFile(GetKeepFile($OpenPageName, (shift)));
  return () unless $status;
  return ParseData($data);
}

sub GetPageFile {
  my ($id, $revision) = @_;
  return $PageDir . '/' . GetPageDirectory($id) . "/$id.pg";
}

sub GetKeepFile {
  my ($id, $revision) = @_; die 'No revision' unless $revision; #FIXME
  return $KeepDir . '/' . GetPageDirectory($id) . "/$id/$revision.kp";
}

sub GetKeepDir {
  my $id = shift; die 'No id' unless $id; #FIXME
  return $KeepDir . '/' . GetPageDirectory($id) . '/' . $id;
}

sub GetKeepFiles {
  return glob(GetKeepDir(shift) . '/*.kp');
}

sub GetPageDirectory {
  my $id = shift;
  if ($id =~ /^([a-zA-Z])/) {
    return uc($1);
  }
  return 'other';
}

# Always call SavePage within a lock.
sub SavePage { # updating the cache will not change timestamp and revision!
  ReportError(T('Cannot save an nameless page.')) unless $OpenPageName;
  CreatePageDir($PageDir, $OpenPageName);
  WriteStringToFile(GetPageFile($OpenPageName), EncodePage(%Page));
}

sub SaveKeepFile {
  return if ($Page{revision} < 1);  # Don't keep 'empty' revision
  delete $Page{blocks}; # delete some info from the page
  delete $Page{flags};
  delete $Page{'diff-major'};
  delete $Page{'diff-minor'};
  CreateKeepDir($KeepDir, $OpenPageName);
  WriteStringToFile(GetKeepFile($OpenPageName, $Page{revision}), EncodePage(%Page));
}

sub EncodePage {
  my $data;
  while (@_) { # don't copy @_ into private variables, use it directly
    $data .= (shift @_) . ': ' . EscapeNewlines(shift @_) . "\n";
  }
  return $data;
}

sub EscapeNewlines {
  $_[0] =~ s/\n/\n\t/g; # modify original instead of copying
  return $_[0];
}

sub ExpireKeepFiles {
  return unless $KeepDays;
  my @keeps = GetKeepFiles($OpenPageName);
  my $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  foreach my $keep (@keeps) {
    my ($status, $data) = ReadFile($keep);
    next unless $status;
    my %field = ParseData($data);
    next if $field{ts} >= $expirets;
    next if $KeepMajor && ($field{revision} == $Page{oldmajor});
    unlink $keep;
  }
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
    ReportError(Ts('Cannot open %s', $fileName) . ": $!");
  }
  return $data;
}

sub WriteStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">$file")
    or ReportError(Ts('Cannot write %s', $file) . ": $!");
  print OUT  $string;
  close(OUT);
}

sub AppendStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">>$file")
    or ReportError(Ts('Cannot write %s', $file) . ": $!");
  print OUT  $string;
  close(OUT);
}

sub CreateDir {
  my ($newdir) = @_;
  mkdir($newdir, 0775)  if (!(-d $newdir));
}

sub CreatePageDir {
  my ($dir, $id) = @_;
  CreateDir($dir);
  CreateDir($dir . '/' . GetPageDirectory($id));
}

sub CreateKeepDir {
  my ($dir, $id) = @_;
  CreatePageDir($dir, $id);
  CreateDir($dir . '/' . GetPageDirectory($id) . '/' . $id);
}

# == Lock files ==

sub GetLockedPageFile {
  my $id = shift;
  return $PageDir . '/' . GetPageDirectory($id) . "/$id.lck";
}

sub RequestLockDir {
  my ($name, $tries, $wait, $error) = @_;
  my ($lockName, $n);
  $tries = 4 unless $tries;
  $wait = 2 unless $wait;
  CreateDir($TempDir);
  $lockName = $LockDir . $name;
  $n = 0;
  while (mkdir($lockName, 0555) == 0) {
    if ($n++ >= $tries) {
      return 0 unless $error;
      ReportError(Ts('Could not get %s lock', $name) . ": $!\n");
    }
    sleep($wait);
  }
  $Locks{$name} = 1;
  return 1;
}

sub ReleaseLockDir {
  my $name = shift;
  rmdir($LockDir . $name);
  delete $Locks{$name};
}

sub RequestLockOrError {
  # 10 tries, 3 second wait, die on error
  return RequestLockDir('main', 10, 3, 1);
}

sub ReleaseLock {
  ReleaseLockDir('main');
}

sub ForceReleaseLock {
  my $pattern = shift;
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
  print $q->p(T('This operation may take several seconds...'));
  for my $lock (qw(main diff index merge visitors refer_*)) {
    if (ForceReleaseLock($lock)) {
      $message .= $q->p(Ts('Forced unlock of %s lock.', $lock));
    }
  }
  if ($message) {
    print $message;
  } else {
    print $q->p(T('No unlock required.'));
  }
  PrintFooter();
}

# == Helpers ==

sub CalcDay {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%4d-%02d-%02d', $year+1900, $mon+1, $mday);
}

sub CalcTime {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%2d:%02d UTC', $hour, $min);
}

sub CalcTimeSince {
  my $total = shift;
  if    ($total >= 7200) { return Ts('%s hours ago',int($total/3600)) }
  elsif ($total >= 3600) { return T('1 hour ago'); }
  elsif ($total >= 120)  { return Ts('%s minutes ago',int($total/60)) }
  elsif ($total >= 60)   { return T('1 minute ago'); }
  elsif ($total >= 2)    { return Ts('%s seconds ago',int($total)) }
  elsif ($total == 1)    { return T('1 second ago'); }
  else                   { return T('just now'); }
}

sub TimeToText {
  my $t = shift;
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
  my ($id, $newText, $preview) = @_;
  my $upload = GetParam('upload', undef);
  if (!UserCanEdit($id, 1)) {
    print GetHeader('', T('Editing Denied'), '');
    my $rule = UserIsBanned();
    if ($rule) {
      print $q->p(T('Editing not allowed: user, ip, or network is blocked.'));
      print $q->p(T('Contact the wiki administrator for more information.'));
      print $q->p(Ts('The rule %s matched for you.', $rule) . ' '
		  . Ts('See %s for more information.', GetPageLink($BannedHosts)));
    } else {
      print $q->p(Ts('Editing not allowed: %s is read-only.', $SiteName));
    }
    PrintFooter();
    return;
  } elsif ($upload and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'));
  }
  OpenPage($id);
  my $text = $Page{text};
  # Old revision handling (adapted from to BrowsePage!)
  my $header; # set header only when sure that this is not an upload
  my $revision = GetParam('revision', '');
  $revision =~ s/\D//g;  # Remove non-numeric chars
  if ($revision) {
    my %keep = GetKeptRevision($revision);
    if (not %keep) {
      $revision = ''; # reset if requested revision is not available
    } else {
      $text = $keep{text};
      $header = Ts('Editing revision %s of', $revision) . ' ' . $id;
    }
  }
  my $oldText = $text;
  my $isFile = ($oldText =~ m/^#FILE ([^ \n]+)\n(.*)/s);
  $upload = $isFile if not defined $upload;
  if ($upload and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'));
  }
  if ($upload) { # shortcut lots of code
    $revision = '';
    $preview = 0;
  } elsif ($isFile and not $upload) {
    $oldText = '';
  }
  $header = Ts('Editing %s', $id) if $upload or not $header; # maybe it was set earlier
  $oldText = $newText if $preview;
  print GetHeader('', QuoteHtml($header), '');
  if ($revision) {
    print $q->strong(Ts('Editing old revision %s.', $revision) . '  '
		     . T('Saving this page will replace the latest revision with this text.'))
  }
  print GetFormStart($upload);
  print GetHiddenValue("title", $id);
  print GetHiddenValue('revision', $revision) if $revision;
  print GetHiddenValue('oldtime', $Page{'ts'});
  if ($upload) {
    print GetUpload();
  } else {
    print GetTextArea('text', $oldText);
  }
  my $summary = GetParam('summary', '');
  print $q->p(T('Summary:'),
	      $q->textfield(-name=>'summary', -default=>$summary, -override=>1, -size=>60));
  if (GetParam('recent_edit') eq 'on') {
    print $q->p($q->checkbox(-name=>'recent_edit', -checked=>1,
			     -label=>T('This change is a minor edit.')));
  } else {
    print $q->p($q->checkbox(-name=>'recent_edit',
			     -label=>T('This change is a minor edit.')));
  }
  print T($EditNote) if $EditNote; # Allow translation
  my $userName = GetParam('username', '');
  print $q->p(T('Username:') . ' '
	      . $q->textfield(-name=>'username',
			      -default=>$userName, -override=>1,
			      -size=>20, -maxlength=>50));
  print $q->p($q->submit(-name=>'Save', -value=>T('Save'))
	      . ($upload ? '' :  ' ' . $q->submit(-name=>'Preview', -value=>T('Preview'))));
  if ($upload) {
    print $q->p(ScriptLink('action=edit;upload=0;id=' . $id, T('Replace this file with text.')));
  } elsif ($UploadAllowed or UserIsAdmin()) {
    print $q->p(ScriptLink('action=edit;upload=1;id=' . $id, T('Replace this text with a file.')));
  }
  print $q->endform();
  if ($preview and not $upload) {
    print '<div class="preview">', $q->hr();
    print $q->h2(T('Preview:'));
    PrintWikiToHTML($oldText); # no caching, current revision, unlocked
    print $q->hr(), $q->h2(T('Preview only, not yet saved')), '</div>';
  }
  PrintFooter($id, 'edit');
}

sub GetTextArea {
  my ($name, $text) = @_;
  return $q->textarea(-name=>$name, -default=>$text, -rows=>25, -columns=>78, -override=>1);
}

sub GetUpload {
  return $q->p(T('File to upload: ') . $q->filefield(-name=>'file', -size=>50, -maxlength=>100));
}

sub DoDownload {
  my $id = shift;
  my $ts;
  my $revision = GetParam('revision', '');
  OpenPage($id);
  if ($revision && $revision ne $Page{'revision'}) {
    OpenKeptRevisions('text_default');
    OpenKeptRevision($revision);
  } else {
    if ($Page{'ts'} eq $q->http('HTTP_IF_MODIFIED_SINCE')) {
      print $q->header(-status=>'304 NOT MODIFIED');
      return;
    }
    $ts = $Page{'ts'};
  }
  if ($Page{'text'} =~ /#FILE ([^ \n]+)\n(.*)/s) {
    my ($type, $data) = ($1, $2);
    if (not grep(/^$type$/, @UploadTypes)) {
      ReportError (Ts('Files of type %s are not allowed.', $type));
    }
    print GetHttpHeader($type, $ts);
    require MIME::Base64;
    print MIME::Base64::decode($data);
  } else {
    print GetHttpHeader('text/plain', $ts);
    print $Page{'text'};
  }
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
  UserIsAdmin() or ReportError(T('This operation is restricted to administrators only...'));
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
      my $rule = $1;
      return $rule  if ($ip   =~ /$rule/i);
      return $rule  if ($host =~ /$rule/i);
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
  if (shift) {
    print GetHttpHeader('text/plain');
    foreach my $name (AllPagesList()) {
      print "$name\n"
    }
  } else {
    my @pages;
    my $anchors = GetParam('permanentanchors', 1);
    print GetHeader('', T('Index of all pages'), '');
    print $q->p($q->b('(including permanent anchors)')) if $anchors == 1;
    print $q->p($q->b('(permanent anchors only)')) if $anchors == 2;
    ReadPermanentAnchors() if $anchors and not %PermanentAnchors;
    push(@pages, AllPagesList()) if $anchors < 2;
    push(@pages, keys %PermanentAnchors) if $anchors > 0;
    PrintPageList(@pages);
    PrintFooter();
  }
}

sub PrintPageList {
  my $pagename;
  print $q->h2(Ts('%s pages found:', ($#_ + 1))), '<p>';
  foreach $pagename (@_) {
    print GetPageLink($pagename), $q->br();
  }
  print '</p>';
}

sub AllPagesList {
  my ($rawIndex, $refresh, $status);
  $refresh = GetParam('refresh', 0);
  if ($IndexInit && !$refresh) {
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
  foreach (sort(glob("$PageDir/*/*.pg"))) { # sort of DoIndex etc.
    next unless m|/.*/(.+)\.pg$|;
    push @IndexList, $1;
    $IndexHash{$1} = 1;
  }
  $IndexInit = 1;  # Initialized for this run of the script
  # Try to write out the list for future runs
  RequestLockDir('index') or return @IndexList; # not fatal
  WriteStringToFile($IndexFile, join(' ', %IndexHash));
  ReleaseLockDir('index');
  return @IndexList;
}

# == Searching ==

sub DoSearch {
  my $string = shift;
  my $replacement = GetParam('replace','');
  if ($string eq '') {
    DoIndex();
    return;
  }
  if ($replacement) {
    print GetHeader('', QuoteHtml(Ts('Replaced: %s', "$string -> $replacement")), '');
    return  if (!UserIsAdminOrError());
    Replace($string,$replacement);
    $string = $replacement;
  } else {
    print GetHeader('', QuoteHtml(Ts('Search for: %s', $string)), '');
    $ReplaceForm = UserIsAdmin(); # only show on new searches for admins
    print $q->p(ScriptLink('action=rc;rcfilteronly=' . UrlEncode($string),
			   Ts('View changes for these pages'))); }
  if (GetParam('context',1)) {
    PrintSearchResults($string,SearchTitleAndBody($string)) ;
  } else {
    PrintPageList(SearchTitleAndBody($string));
  }
  PrintFooter();
}

sub SearchTitleAndBody {
  my $string = shift;
  my $and = T('and');
  my $or = T('or');
  my @strings = split(/ +$and +/, $string);
  my @found;
  foreach my $name (AllPagesList()) {
    OpenPage($name);
    next if ($Page{'text'} =~ /^#FILE / and $string !~ /^\^#FILE/); # skip files unless requested
    my $found = 1; # assume found
    foreach my $str (@strings) {
      my @temp = split(/ +$or +/, $str);
      $str = join('|', @temp);
      if (not ($Page{'text'} =~ /$str/i)) {
	$found = 0;
	last;
      }
    }
    if ($found or $name =~ /$string/i) {
      push(@found, $name);
    } elsif ($FreeLinks && ($name =~ m/_/)) {
      my $freeName = $name;
      $freeName =~ s/_/ /g;
      if ($freeName =~ /$string/i) {
	push(@found, $name);
      }
    }
  }
  return @found;
}

sub PrintSearchResults {
  my ($searchstring, @results) = @_ ;
  my $and = T('and');
  my $or = T('or');
  my $searchstring = join('|', split(/ +(?:$and|$or) +/, $searchstring));
  my ($snippetlen, $maxsnippets) = (100, 4) ; #  these seem nice.
  print $q->h2(Ts('%s pages found:', ($#results + 1)));
  my $files = ($searchstring =~ /^\^#FILE/); # usually skip files
  foreach my $name (@results) {
    OpenPage($name);
    my $pageText = QuoteHtml($Page{'text'});
    #  get the page, filter it, remove all tags
    $pageText =~ s/$FS//g;	# Remove separators (paranoia)
    $pageText =~ s/[\s]+/ /g;	#  Shrink whitespace
    $pageText =~ s/([-_=\\*\\.]){10,}/$1$1$1$1$1/g ; # e.g. shrink "----------"
    my $htmlre = join('|',(@HtmlTags, 'pre', 'nowiki', 'code'));
    $pageText =~ s/\<\/?($htmlre)(\s[^<>]+?)?\>//gi;
    #  entry header
    print '<p>' . $q->span({-class=>'result'}, GetPageLink($name)), $q->br();
    if ($files) {
      $pageText =~ /^#FILE ([^ ]+)/;
      print $1;
    } else {
      # show a snippet from the top of the document
      my $j = index($pageText, ' ', $snippetlen); # end on word boundary
      my $t = substr($pageText, 0, $j);
      $t =~ s/($searchstring)/<strong>\1<\/strong>/gi;
      print $t, ' ', $q->b('...');
      $pageText = substr($pageText, $j); # to avoid rematching
      # search for occurrences of searchstring
      my $jsnippet = 0 ;
      while ($jsnippet < $maxsnippets && $pageText =~ m/($searchstring)/i) {
	$jsnippet++;
	if (($j = index($pageText, $1)) > -1 ) {
	  # get substr containing (start of) match, ending on word boundaries
	  my $start = index($pageText, ' ', $j-($snippetlen/2));
	  $start = 0 if ($start == -1);
	  my $end = index($pageText, ' ', $j+($snippetlen/2));
	  $end = length($pageText ) if ($end == -1);
	  $t = substr($pageText, $start, $end-$start);
	  # highlight occurrences and tack on to output stream.
	  $t =~ s/($searchstring)/<strong>\1<\/strong>/gi;
	  print $t, ' ', $q->b('...');
	  # truncate text to avoid rematching the same string.
	  $pageText = substr($pageText, $end);
	}
      }
    }
    #  entry trailer
    print $q->br(), $q->span({-class=>'info'},
      int((length($pageText)/1024)+1) . 'K - ' . T('last updated') . ' '
      . TimeToText($Page{ts}) . ' ' . T('by') . ' '
      . GetAuthorLink($Page{'host'}, $Page{'username'})), '</p>';
  }
}

sub Replace {
  my ($from, $to) = @_;
  RequestLockOrError(); # fatal
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    $_ = $Page{'text'};
    if (eval "s/$from/$to/gi") { # allows use of backreferences
      Save($id, $_, $from . ' -> ' . $to, 1,
	   ($Page{'ip'} ne $ENV{REMOTE_ADDR}));
    }
  }
  ReleaseLock();
}

# == Links ==

sub DoLinks {
  if (GetParam('raw', 0)) {
    print GetHttpHeader('text/plain');
    PrintLinkList(GetFullLinkList());
  } else {
    print GetHeader('', QuoteHtml(T('Full Link List')), '');
    PrintLinkList(GetFullLinkList());
    PrintFooter();
  }
}

sub PrintLinkList {
  my %links = %{(shift)};
  my $existingonly = GetParam('exists', 0);
  if (GetParam('raw', 0)) {
    foreach my $page (sort keys %links) {
      foreach my $link (@{$links{$page}}) {
	print "\"$page\" -> \"$link\"\n" if not $existingonly or $IndexHash{$link};
      }
    }
  } else {
    foreach my $page (sort keys %links) {
      print $q->p(GetPageLink($page) . ': ' . join(' ', @{$links{$page}}));
    }
  }
}

sub GetFullLinkList {
  my @pglist = AllPagesList();
  my %result;
  my $raw = GetParam('raw', 0);
  my $url = GetParam('url', 0);
  foreach my $name (@pglist) {
    OpenPage($name);
    my @blocks = split($FS, $Page{blocks});
    my @flags = split($FS, $Page{flags});
    my %links;
    foreach my $block (@blocks) {
      if (shift(@flags)) { # dirty blocks
	if ($url < 2) {    # list normal links
	  if ($BracketText && $block =~ m/(\[$InterLinkPattern\s+([^\]]+?)\])/o
	      or $block =~ m/(\[$InterLinkPattern\])/o
	      or $block =~ m/($InterLinkPattern)/o) {
	    $links{$raw ? $2 : GetInterLink($2)} = 1;
	  } elsif (($WikiLinks and $block !~ m/!$LinkPattern/o
		    and ($BracketWiki && $block =~ m/(\[$LinkPattern\s+([^\]]+?)\])/o
			 or $block =~ m/(\[$LinkPattern\])/o
			 or $block =~ m/($LinkPattern)/o))
		   or ($FreeLinks
		       and ($BracketWiki && $block =~ m/(\[\[$FreeLinkPattern\|([^\]]+)\]\])/o
			    or $block =~ m/(\[\[$FreeLinkPattern\]\])/cg))) {
	    $links{$raw ? $2 : GetPageOrEditLink($2, $2)} = 1;
	  }
	}
      } elsif ($url > 0) { # clean blocks, urls
	while ($block =~ m/$UrlPattern/go) {
	  $links{$raw ? $1 : GetUrl($1)} = 1;
	}
      }
    }
    @{$result{$name}} = sort keys %links if %links;
  }
  return \%result;
}

# == Monolithic output ==

sub DoPrintAllPages {
  $Monolithic = 1; # changes how ScriptLink works
  print GetHeader('', T('Complete Content'), '')
    . $q->p(Ts('The main page is %s.', $q->a({-href=>'#' . $HomePage}, $HomePage)));
  PrintAllPages(0, 0, AllPagesList());
  PrintFooter();
}

sub PrintAllPages {
  my $links = shift;
  my $comments = shift;
  for my $id (@_) {
    OpenPage($id); # After this call, don't save cache!
    print $q->hr . $q->h1($links ? GetPageLink($id) : $q->a({-name=>$id},$id));
    if ($Page{blocks} && $Page{flags} && GetParam('cache',1)) {
      PrintCache();
    } else {
      PrintWikiToHTML($Page{'text'}, 1); # cache, current, not locked
    }
    if ($comments and UserCanEdit($CommentsPrefix . $id, 0) and $id !~ /^$CommentsPrefix/) {
      print $q->p({-class=>'comment'}, ScriptLink($CommentsPrefix . UrlEncode($id),
						  T('Comments on this page')));
    }
  }
}

# == Posting new pages ==

sub DoPost {
  my $id = shift;
  $id = FreeToNormal($id) if $FreeLinks;
  ValidIdOrDie($id);
  if (!UserCanEdit($id, 1)) {
    ReportError(Ts('Editing not allowed for %s.', $id));
  } elsif (($id eq 'SampleUndefinedPage') or ($id eq T('SampleUndefinedPage'))) {
    ReportError(Ts('%s cannot be defined.', $id));
  } elsif (($id eq 'Sample_Undefined_Page') or ($id eq T('Sample_Undefined_Page'))) {
    ReportError(Ts('[[%s]] cannot be defined.', $id));
  } elsif (grep(/^$id$/, @LockOnCreation) and !UserIsAdmin() and not -f GetPageFile($id)) {
    ReportError(Ts('Only an administrator can create %s', $id));
  }
  my $filename = GetParam('file', undef);
  if ($filename and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'));
  }
  # Lock before getting old page to prevent races
  RequestLockOrError(); # fatal
  OpenPage($id);
  my $old = $Page{'text'};
  $_ = GetParam('text', undef);
  foreach my $macro (@MyMacros) { &$macro; }
  my $string = $_;
  my $preview = 0;
  # Upload file
  if ($filename) {
    require MIME::Base64;
    my $file = $q->upload('file');
    if (not $file and $q->cgi_error) {
      ReportError (Ts('Transfer Error: %s', $q->cgi_error));
    }
    ReportError(T('Browser reports no file info.')) unless $q->uploadInfo($filename);
    my $type = $q->uploadInfo($filename)->{'Content-Type'};
    ReportError(T('Browser reports no file type.')) unless $type;
    if (not grep(/^$type$/, @UploadTypes)) {
      ReportError (Ts('Files of type %s are not allowed.', $type));
    }
    local $/ = undef;   # Read complete files
    eval { $_ = MIME::Base64::encode(<$file>) };
    $string = '#FILE ' . $type . "\n" . $_;
  } else {
    $preview = 1  if (GetParam('Preview', ''));
    my $comment = GetParam('aftertext', undef);
    if (defined $comment) {
      $comment =~ s/\r//g;	# Remove "\r"-s (0x0d) from the string
      $comment =~ s/\s+$//g;    # Remove whitespace at the end
      if ($comment ne '' and $comment ne $NewComment) {
	$string = $old  . "----\n" if $old and $old ne "\n";
	$string .= $comment . "\n\n-- " .  GetParam('username', T('Anonymous'))
	  . ' ' . TimeToText($Now) . "\n\n";
      } else {
	$string = $old;
      }
    }
    # Massage the string
    $string =~ s/\r//g;
    $string .= "\n"  if ($string !~ /\n$/);
    $string =~ s/$FS//g;
  }
  my $summary = GetParam('summary', '');
  $summary =~ s/$FS//g;
  $summary =~ s/[\r\n]+/ /g;
  # rebrowse if no changes
  my $oldrev = $Page{'revision'};
  if (!$preview && (($old eq $string) or ($oldrev == 0 and $string eq $NewText))) {
    ReleaseLock(); # No changes -- just show the same page again
    ReBrowsePage($id);
    return;
  }
  if ($preview) {
    ReleaseLock();
    DoEdit($id, $string, 1);
    return;
  }
  my $newAuthor = 0;
  if (GetParam('username', '')) { # prefer usernames for potential newAuthor detection
    $newAuthor = 1 if GetParam('username', '') ne $Page{'username'};
  } elsif ($ENV{REMOTE_ADDR} ne $Page{'ip'}) {
    $newAuthor = 1;
  }
  my $oldtime = $Page{'ts'};
  my $myoldtime = GetParam('oldtime', ''); # maybe empty!
  # Handle raw edits with the meta info on the first line
  if (GetParam('raw',0) == 2 and $string =~ /^([0-9]+).*\n(.*)/s) {
    $myoldtime = $1;
    $string = $2;
  }
  my $generalwarning = 0;
  if ($newAuthor and $oldtime ne $myoldtime) {
    if ($myoldtime) {
      my $ancestor = GetTextAtTime($myoldtime);
      if ($ancestor and $old ne $ancestor) {
	my $new = MergeRevisions($string, $ancestor, $old);
	if ($new) {
	  $string = $new;
	  if ($new =~ /^<<<<<<</m and $new =~ /^>>>>>>>/m) {
	    $NewCookie{'msg'} = Ts('This page was changed by somebody else %s.',
				   CalcTimeSince($Now - $Page{'ts'}))
	      . ' ' . T('The changes conflict.  Please check the page again.');
	    $string =~ s/^<<<<<<</\n\n<pre><<<<<<</mg;
	    $string =~ s/^>>>>>>>(.*)/>>>>>>>$1\n<\/pre>\n/mg;
	  } # else no conflict
	} else { $generalwarning = 1; } # else merge revision didn't work
      } # else nobody changed the page in the mean time (same text)
    } else { $generalwarning = 1; } # no way to be sure since myoldtime is missing
  } # same author or nobody changed the page in the mean time (same timestamp)
  if ($generalwarning and ($Now - $Page{'ts'}) < 600) {
    $NewCookie{'msg'} = Ts('This page was changed by somebody else %s.',
			   CalcTimeSince($Now - $Page{'ts'}))
      . ' ' . T('Please check whether you overwrote those changes.');
  }
  Save($id, $string, $summary, (GetParam('recent_edit', '') eq 'on'), $filename);
  ReleaseLock();
  DeletePermanentAnchors();
  if (GetParam('recent_edit', '') ne 'on' and $NotifyTracker) {
    PingTracker($id);
  }
  ReBrowsePage($id);
}

sub Save { # call within lock, with opened page
  my ($id, $new, $summary, $minor, $upload) = @_;
  my $old = $Page{'text'}; # copy before it gets encoded
  my $user = GetParam('username', '');
  my $host = GetRemoteHost();
  my $revision = $Page{revision} + 1;
  SaveKeepFile(); # deletes clean, dirty, diff-major, and diff-minor, encode multiline content
  ExpireKeepFiles();
  $Page{ts} = $Now;
  $Page{revision} = $revision;
  $Page{summary} = $summary;
  $Page{username} = $user;
  $Page{ip} = $ENV{REMOTE_ADDR};
  $Page{host} = $host;
  $Page{minor} = $minor;
  $Page{oldmajor} = $revision unless $minor; # if a minor rev, this stores the last major rev
  $Page{text} = $new; # this is the only multiline content right now, and it is not encoded
  if ($UseDiff and $revision > 1 and not $upload and $old !~ /^#FILE /) {
    UpdateDiffs($id, $old, $new, $minor); # more multiline, non-encoded content
  }
  SavePage();
  my $languages;
  $languages = GetLanguages($new) unless $upload;
  WriteRcLog($id, $summary, $minor, $revision, $user, $host, $languages, GetCluster($new));
  if ($revision == 1) {
    unlink($IndexFile);  # Regenerate index on next request
    $IndexInit = 0; # mod_perl: this variable may persist accross sessions
    if (grep(/^$id$/, @LockOnCreation)) {
      WriteStringToFile(GetLockedPageFile($id), 'editing locked.');
    }
  } else {
    utime undef, undef, $IndexFile; # touch index file
  }
  $LastUpdate = $Now; # for mod_perl
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

sub GetCluster {
  $_ = shift;
  return unless $PageCluster;
  return $1 if ($WikiLinks && /^$LinkPattern\n/)
    or ($FreeLinks && m/^\[\[$FreeLinkPattern\]\]\n/);
}

sub MergeRevisions { # merge change from file2 to file3 into file1
  my ($file1, $file2, $file3) = @_;
  my ($name1, $name2, $name3) = ("$TempDir/file1", "$TempDir/file2", "$TempDir/file3");
  CreateDir($TempDir);
  RequestLockDir('merge') or return T('Could not get a lock to merge!');
  WriteStringToFile($name1, $file1);
  WriteStringToFile($name2, $file2);
  WriteStringToFile($name3, $file3);
  my ($you,$ancestor,$other) = (T('you'), T('ancestor'), T('other'));
  my $output = `diff3 -m -L $you -L $ancestor -L $other $name1 $name2 $name3`;
  ReleaseLockDir('merge');
  # No need to unlink temp files--next merge will just overwrite.
  return $output;
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
  my ($id, $summary, $minor, $revision, $username, $host, $langref, $cluster) = @_;
  my $languages;
  $languages = join(',', @$langref) if $langref;
  my $rc_line = join($FS, $Now, $id, $minor, $summary, $host,
		     $username, $revision, $languages, $cluster);
  AppendStringToFile($RcFile, $rc_line . "\n");
}

sub UpdateDiffs {
  my ($id, $old, $new, $minor) = @_;
  my $editDiff  = GetDiff($old, $new);
  $Page{'diff-minor'} = $editDiff;
  if ($minor and $Page{oldmajor}) {
    $Page{'diff-major'} = GetKeptDiff($new, $Page{oldmajor});
  } else {
    $Page{'diff-major'} = '1'; # special value, used in GetCacheDiff
  }
}

# == Weblog Tracking ==

sub PingTracker {
  my $id = shift;
  foreach my $regexp (keys %NotifyJournalPage) {
    if ($id =~ m/$regexp/) {
      $id = $NotifyJournalPage{$regexp};
      last;
    }
  }
  if ($q->url(-base=>1) !~ m|^http://localhost|) {
    my $url = UrlEncode($q->url . '/' . $id);
    my $name = UrlEncode($SiteName . ': ' . $id);
    my $rss = UrlEncode($q->url . '?action=rss');
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
  print GetHeader('', T('Maintenance on all pages'), '');
  my $fname = "$DataDir/maintain";
  if (!UserIsAdmin()) {
    if ((-f $fname) && ((-M $fname) < 0.5)) {
      print $q->p(T('Maintenance not done.') . ' '
		  . T('(Maintenance can only be done once every 12 hours.)')
		  . ' ', T('Remove the "maintain" file or wait.'));
      PrintFooter();
      return;
    }
  }
  my $cache = GetParam('cache', 0);
  RequestLockOrError();
  print $q->p(T('Main lock obtained.'));
  print '<p>' . T('Expiring keep files and deleting pages marked for deletion');
  if ($cache) {
    print T('and refreshing HTML cache');
    $IndexInit = 0; # mod_perl: this variable may persist accross sessions
    unlink($IndexFile);
    unlink($PermanentAnchorsFile);
  }
  # Expire all keep files
  foreach my $name (AllPagesList()) {
    print $q->br();
    print GetPageLink($name);
    OpenPage($name);
    my $delete = PageDeletable($name);
    if ($delete) {
      DeletePage($OpenPageName);
      print ' ' . T('deleted');
    } else {
      ExpireKeepFiles();
      ReadReferers($OpenPageName); # clean up even if disabled
      WriteReferers($OpenPageName);
      if ($cache) {
	local *STDOUT;
	open (STDOUT, "> /dev/null");
	PrintWikiToHTML($Page{'text'}, 1, '', 1) if ($cache); # cache, current, locked
      }
    }
  }
  print '</p>';
  print $q->p(Ts('Moving part of the %s log file.', $RCName));
  # Determine the number of days to go back
  my $days = 0;
  foreach (@RcDays) {
    $days = $_ if $_ > $days;
  }
  my $starttime = $Now - $days * 24 * 60 * 60;
  # Read the current file
  my ($status, $data) = ReadFile($RcFile);
  if (!$status) {
    print $q->p($q->strong(Ts('Could not open %s log file', $RCName) . ':') . ' '
		. $RcFile)
      . $q->p(T('Error was') . ':')
      . $q->pre($!)
      . $q->p(T('Note: This error is normal if no changes have been made.'));
  }
  # Move the old stuff from rc to temp
  my @rc = split(/\n/, $data);
  my $i;
  for ($i = 0; $i < @rc ; $i++) {
    my ($ts) = split(/$FS/, $rc[$i]);
    last if ($ts >= $starttime);
  }
  print $q->p(Ts('Moving %s log entries.', $i));
  if ($i) {
    my @temp = splice(@rc, 0, $i);
    # Write new files, and backups
    AppendStringToFile($RcOldFile, join("\n",@temp) . "\n");
    WriteStringToFile($RcFile . '.old', $data);
    WriteStringToFile($RcFile, join("\n",@rc) . "\n");
  }
  WriteStringToFile($fname, 'Maintenance done at ' . TimeToText($Now));
  ReleaseLock();
  print $q->p(T('Main lock released.'));
  PrintFooter();
}

# == Deleting pages ==

sub PageDeletable {
  my ($expirets);
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return 0 unless $Page{'ts'} < $expirets;
  return $DeletedPage && $Page{'text'} =~ /^\s*$DeletedPage\b/o;
}

sub DeletePage { # Delete must be done inside locks.
  my ($page) = @_;
  my ($fname, $status);
  $page =~ s/ /_/g;
  $page =~ s/\[+//;
  $page =~ s/\]+//;
  $status = ValidId($page);
  if ($status ne '') {
    print "DeletePage: page $page is invalid, error is: $status<br>\n";
    return;
  }
  foreach my $fname (GetPageFile($page), GetKeepFiles($page), GetKeepDir($page),
		     GetRefererFile($page), $IndexFile) {
    unlink($fname) if (-f $fname);
  }
  DeletePermanentAnchors();
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
  $fname = GetLockedPageFile($id) if ValidIdOrDie($id);
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
  if (GetParam('dependencies', 0)) {
    print $q->p('CGI: ', $CGI::VERSION,
		'XML::RSS: ', eval { local $SIG{__DIE__}; require XML::RSS; $XML::RSS::VERSION; },
		'XML::Parser: ', eval { local $SIG{__DIE__}; $XML::Parser::VERSION; }, );
  }
  PrintFooter();
}

# == Maintaining a list of recent visitors plus surge protection ==

sub DoSurgeProtection {
  if ($SurgeProtection or $Visitors) {
    my $name = GetParam('username','');
    $name = $ENV{'REMOTE_ADDR'} if not $name and $SurgeProtection;
    if ($name) {
      ReadRecentVisitors();
      AddRecentVisitor($name);
      if (RequestLockDir('visitors')) { # not fatal
	WriteRecentVisitors();
	ReleaseLockDir('visitors');
	if ($SurgeProtection and DelayRequired($name)) {
	  ReportError(Ts('Too many connections by %s',$name));
	}
      } elsif ($SurgeProtection and GetParam('action', '') ne 'unlock') {
	ReportError(Ts('Could not get %s lock', 'visitors'));
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
  foreach (split(/\n/,$data)) {
    my @entries = split /$FS/;
    my $name = shift(@entries);
    $RecentVisitors{$name} = \@entries if $name;
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
	  $data .=  join($FS, $name, @entries[0 .. $SurgeProtectionViews - 1]) . "\n";
	} else {
	  $data .= $name . $FS . $entries[0] . "\n";
	}
      }
    }
  }
  WriteStringToFile($VisitorFile, $data);
}

sub DoShowVisitors {
  print GetHeader('', T('Recent Visitors'), '', 1); # no caching
  ReadRecentVisitors();
  print '<p><ul>';
  foreach my $name (sort {@{$RecentVisitors{$b}}[0] <=> @{$RecentVisitors{$a}}[0]} (keys %RecentVisitors)) {
    my $time = @{$RecentVisitors{$name}}[0];
    my $total = $Now - $time;
    my $who;
    if (!$name or ($SurgeProtection and $name =~ /\./)) {
      $who = T('Anonymous');
    } else {
      $who = GetPageLink($name);
    }
    print $q->li($who . ', ' . CalcTimeSince($total));
  }
  print '</ul>';
  PrintFooter();
}

# == Track Back ==

sub GetRefererFile {
  my $id = shift;
  return $RefererDir . '/' . GetPageDirectory($id) . "/$id.rf";
}

sub ReadReferers {
  my $file = GetRefererFile(shift);
  %Referers = ();
  if (-f $file) {
    my ($status, $data) = ReadFile($file);
    %Referers = split(/$FS/, $data, -1) if $status;
  }
  ExpireReferers();
}

sub ExpireReferers { # no need to save the pruned list if nothing else changes
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
}

sub GetReferers {
  my $result = join(' ', map { $q->a({-href=>$_}, QuoteHtml($_)) } keys %Referers);
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
  return 1;
}

sub WriteReferers {
  my $id = shift;
  return unless RequestLockDir('refer_' . $id); # not fatal
  my $data = join($FS, %Referers);
  my $file = GetRefererFile($id);
  if ($data) {
    CreatePageDir($RefererDir, $id);
    WriteStringToFile($file, $data);
  } else {
    unlink $file; # just try it, doesn't matter if it fails
  }
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
  my $id = FreeToNormal(shift); # Trims extra spaces, too
  my $text = $id;
  $text =~ s/_/ /g;
  my ($class, $resolved) = ResolveId($id);
  if ($class eq 'local' and $resolved ne $OpenPageName) { # exists already
    return '[' . Ts('anchor first defined here: %s', GetPageLink($id)) . ']';
  } elsif ($PermanentAnchors{$id} ne $OpenPageName
	   and RequestLockDir('permanentanchors')) { # not fatal
    $PermanentAnchors{$id}=$OpenPageName;
    WritePermanentAnchors();
    ReleaseLockDir('permanentanchors');
  }
  $PagePermanentAnchors{$id} = 1; # add to the list of anchors in page
  return GetSearchLink($id, 'definition', $id,
		       T('Click to search for references to this permanent anchor'));
}

sub DeletePermanentAnchors {
  ReadPermanentAnchors();
  foreach (keys %PermanentAnchors) {
    if ($PermanentAnchors{$_} eq $OpenPageName and !$PagePermanentAnchors{$_}) {
      delete($PermanentAnchors{$_}) ;
    }
  }
  return unless RequestLockDir('permanentanchors'); # not fatal
  WritePermanentAnchors();
  ReleaseLockDir('permanentanchors');
}

DoWikiRequest()  if ($RunCGI && ($_ ne 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere

# == End of the OddMuse script. ==
