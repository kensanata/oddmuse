#! /usr/bin/perl
# OddMuse (see $WikiDescription below)
# Copyright (C) 2001, 2002, 2003, 2004	Alex Schroeder <alex@emacswiki.org>
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
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

use vars qw(@RcDays $TempDir $LockDir $DataDir $KeepDir $PageDir
$RefererDir $RcOldFile $IndexFile $BannedContent $NoEditFile
$BannedHosts $ConfigFile $FullUrl $SiteName $HomePage $LogoUrl
$RcDefault $IndentLimit $RecentTop $RecentLink $EditAllowed $UseDiff
$KeepDays $KeepMajor $EmbedWiki $BracketText $UseConfig $UseLookup
$AdminPass $EditPass $NetworkFile $BracketWiki $FreeLinks $WikiLinks
$FreeLinkPattern $RCName $RunCGI $ShowEdits $LinkPattern $RssExclude
$InterLinkPattern $InterSitePattern $MaxPost $UrlPattern $UrlProtocols
$ImageExtensions $FS $CookieName $SiteBase $StyleSheet $NotFoundPg
$FooterNote $NewText $EditNote $HttpCharset $UserGotoBar $VisitorTime
$VisitorFile $RcFile $Visitors %Smilies %SpecialDays $InterWikiMoniker
$SiteDescription $RssImageUrl $RssPublisher $RssContributor $RssRights
$BannedCanRead $SurgeProtection $SurgeProtectionViews $TopLinkBar
$LanguageLimit $SurgeProtectionTime $DeletedPage %Languages $InterMap
$ValidatorLink $RefererTracking $RefererTimeLimit $RefererLimit
@LockOnCreation $RefererFilter $PermanentAnchorsFile $PermanentAnchors
@MyRules %CookieParameters $NewComment $StyleSheetPage $ConfigPage
@UserGotoBarPages $ScriptName @MyMacros $CommentsPrefix @UploadTypes
$DefaultStyleSheet $AllNetworkFiles $UsePathInfo $UploadAllowed
$LastUpdate $PageCluster $RssInterwikiTranslate $UseCache $ModuleDir
$HtmlHeaders $DebugInfo %InvisibleCookieParameters $FullUrlPattern
$FreeInterLinkPattern);

# Other global variables:
use vars qw(%Page %InterSite %IndexHash %Translate %OldCookie
%NewCookie $InterSiteInit $FootnoteNumber $OpenPageName @IndexList
$IndexInit $Message $q $Now %RecentVisitors @HtmlStack %Referers
$Monolithic $ReplaceForm %PermanentAnchors %PagePermanentAnchors
$CollectingJournal $WikiDescription $PrintedHeader %Locks $Fragment
@Blocks @Flags %NearSite %NearSource %NearLinksUsed $NearSiteInit
$NearDir $NearMap $SisterSiteLogoUrl %NearSearch @KnownLocks $first
$PermanentAnchorsInit $ModulesDescription %RuleOrder %Action $bol
%RssInterwikiTranslate $RssInterwikiTranslateInit);

# == Configuration ==

# Can be set outside the script: $DataDir, $UseConfig, $ConfigFile, $ModuleDir, $ConfigPage,
# $AdminPass, $EditPass, $ScriptName, $FullUrl, $RunCGI.

$UseConfig   = 1 unless defined $UseConfig; # 1 = load config file in the data directory
$DataDir     = $ENV{WikiDataDir} if $UseConfig and not $DataDir; # Main wiki directory
$DataDir   = '/tmp/oddmuse' unless $DataDir;
$ConfigPage  = '' unless $ConfigPage; # config page
$RunCGI	     = 1  unless defined $RunCGI; # 1 = Run script as CGI instead of being a library
$UsePathInfo = 1;   # 1 = allow page views using wiki.pl/PageName
$UseCache    = 2;   # -1 = disabled, 0 = 10s; 1 = partial HTML cache; 2 = HTTP/1.1 caching

# Basics
$SiteName    = 'Wiki';	   # Name of site (used for titles)
$HomePage    = 'HomePage'; # Home page
$CookieName  = 'Wiki';	   # Name for this wiki (for multi-wiki sites)

# Fix if defaults do not work
$SiteBase    = '';  # Full URL for <BASE> header
$MaxPost     = 1024 * 210; # Maximum 210K posts (about 200K for pages)
$HttpCharset = 'UTF-8'; # You are on your own if you change this!

# EyeCandy
$StyleSheet  = '';  # URL for CSS stylesheet (like '/wiki.css')
$StyleSheetPage = ''; # Page for CSS sheet
$LogoUrl     = '';  # URL for site logo ('' for no logo)
$NotFoundPg  = '';  # Page for not-found links ('' for blank pg)
$NewText     = "Describe the new page here.\n";	 # New page text
$NewComment  = "Add your comment here.\n";	 # New comment text

# HardSecurity
$EditAllowed = 1;   # 0 = no, 1 = yes, 2 = comments only
$AdminPass   = '' unless defined $AdminPass; # Whitespace separated passwords.
$EditPass    = '' unless defined $EditPass; # Whitespace separated passwords.
$BannedHosts = 'BannedHosts'; # Page for banned hosts
$BannedCanRead = 1; # 1 = banned cannot edit, 0 = banned cannot read
$BannedContent = 'BannedContent'; # Page for banned content (usually for link-ban)

# LinkPattern
$WikiLinks   = 1;   # 1 = LinkPattern is a link
$FreeLinks   = 1;   # 1 = [[some text]] is a link
$BracketText = 1;   # 1 = [URL desc] uses a description for the URL
$BracketWiki = 0;   # 1 = [WikiLink desc] uses a desc for the local link
$NetworkFile = 1;   # 1 = file: is a valid protocol for URLs
$AllNetworkFiles = 0; # 1 = file:///foo is allowed -- the default allows only file://foo
$PermanentAnchors = 1;	 # 1 = [::some text] defines permanent anchors (page aliases)
$InterMap    = 'InterMap'; # name of the intermap page
$NearMap     = 'NearMap';  # name of the nearmap page
$RssInterwikiTranslate = 'RssInterwikiTranslate'; # name of RSS interwiki translation page

# Diff
$ENV{PATH}   = '/usr/bin/'; # Path used to find 'diff'
$UseDiff     = 1;	    # 1 = use diff

# Visitors and SurgeProtection
$SurgeProtection      = 1;	# 1 = protect against leeches
$Visitors	      = 1;	# 1 = maintain list of recent visitors
$VisitorTime	      = 7200;	# Timespan to remember visitors in seconds
$SurgeProtectionTime  = 20;	# Size of the protected window in seconds
$SurgeProtectionViews = 10;	# How many page views to allow in this window
$RefererTracking      = 0;	# Keep track of referrals to your pages
$RefererTimeLimit     = 86400;	# How long referrals shall be remembered in seconds
$RefererLimit	      = 15;	# How many different referer shall be remembered
$RefererFilter = 'ReferrerFilter'; # name of the filter pg

# RecentChanges and KeptPages
$DeletedPage = 'DeletedPage';	# Pages starting with this can be deleted
$RCName	     = 'RecentChanges'; # Name of changes page
@RcDays	     = qw(1 3 7 30 90); # Days for links on RecentChanges
$RcDefault   = 30;  # Default number of RecentChanges days
$KeepDays    = 14;  # Days to keep old revisions
$KeepMajor   = 1;   # 1 = keep at least one major rev when expiring pages
$ShowEdits   = 0;   # 1 = major and show minor edits in recent changes
$UseLookup   = 1;   # 1 = lookup host names instead of using only IP numbers
$RecentTop   = 1;   # 1 = most recent entries at the top of the list
$RecentLink  = 1;   # 1 = link to usernames
$PageCluster = '';  # name of cluster page, eg. 'Cluster' to enable

# RSS and other Weblog Technology
$InterWikiMoniker = ''; # InterWiki prefix for this wiki for RSS
$SiteDescription  = ''; # RSS Description of this wiki
$RssImageUrl	  = ''; # URL to image to associate with your RSS feed
$RssPublisher	  = ''; # Name of RSS publisher
$RssContributor	  = ''; # List or description of the contributors
$RssRights	  = ''; # Copyright notice for RSS
$RssExclude       = 'RssExclude'; # name of the page that lists pages to be excluded from the feed

# File uploads
$UploadAllowed	  = 0;	# 1 = yes, 0 = administrators only
@UploadTypes	  = ('image/jpeg', 'image/png'); # MIME types allowed, all allowed if empty list

# Header and Footer, Notes, GotoBar
$EmbedWiki   = 0;	# 1 = no headers/footers
$FooterNote  = '';	# HTML for bottom of every page
$EditNote    = '';	# HTML notice above buttons on edit page
$TopLinkBar  = 1;	# 1 = add a goto bar at the top of the page
@UserGotoBarPages = (); # List of pagenames
$UserGotoBar = '';	# HTML added to end of goto bar
$ValidatorLink = 0;	# 1 = Link to the W3C HTML validator service
$CommentsPrefix = '';	# prefix for comment pages, eg. 'Comments_on_' to enable
$HtmlHeaders = '';	# Additional stuff to put in the HTML <head> section
$DefaultStyleSheet = q{
body { background-color:#FFF; color:#000; }
textarea { width:100%; }
a:link { color:#00F; }
a:visited { color:#A0A; }
a:active { color:#F00; }
a.definition:before { content:"[::"; }
a.definition:after { content:"]"; }
a.alias { text-decoration:none; border-bottom: thin dashed; }
a.near:link { color:#093; }
a.near:visited { color:#550; }
a.upload:before { content:"<"; }
a.upload:after { content:">"; }
a.outside:before { content:"["; }
a.outside:after { content:"]"; }
img.logo { float: right; clear: right; border-style:none; }
div.diff { padding-left:5%; padding-right:5%; }
div.old { background-color:#FFFFAF; }
div.new { background-color:#CFFFCF; }
div.refer { padding-left:5%; padding-right:5%; font-size:smaller; }
div.message { background-color:#FEE; }
div.journal h1 { font-size:large; }
table.history { border-style:none; }
td.history { border-style:none; }
span.result { font-size:larger; }
span.info { font-size:smaller; font-style:italic; }
div.rss { background-color:#EEF; }
div.sister { float:left; margin-right:1ex; background-color:#FFF; }
div.sister p { margin-top:0; }
div.sister img { border:none; }
div.near { background-color:#EFE; }
div.near p { margin-top:0; }
@media print {
 body { font:12pt sans-serif; }
 a, a:link, a:visited { color:#000; text-decoration:none; font-style:oblique; }
 h1 a, h2 a, h3 a, h4 a { font-style:normal; }
 a.edit, div.footer, div.refer, form, span.gotobar, a.number span { display:none; }
 a[class="url number"]:after, a[class="inter number"]:after { content:"[" attr(href) "]"; }
 a[class="local number"]:after { content:"[" attr(title) "]"; }
 img[smiley] { line-height: inherit; }
}
}; # the <!-- and --> is added at the end

# Display short comments below the GotoBar for special days
# Example: %SpecialDays = ('1-1' => 'New Year', '1-2' => 'Next Day');
%SpecialDays = ();

# Replace regular expressions with inlined images
# Example: %Smilies = (":-?D(?=\\W)" => '/pics/grin.png');
%Smilies = ();

# Detect page languages when saving edits
# Example: %Languages = ('de' => '\b(der|die|das|und|oder)\b');
%Languages = ();

@KnownLocks = qw(main diff index merge visitors refer_*); # locks to remove

%CookieParameters = (username=>'', pwd=>'', homepage=>'', theme=>'', css=>'', msg=>'',
		     lang=>'', toplinkbar=>$TopLinkBar, embed=>$EmbedWiki, );
%InvisibleCookieParameters = (msg=>1, pwd=>1,);

$IndentLimit = 20;		    # Maximum depth of nested lists
$LanguageLimit = 3;		    # Number of matches req. for each language
$PageDir     = "$DataDir/page";	    # Stores page data
$KeepDir     = "$DataDir/keep";	    # Stores kept (old) page data
$RefererDir  = "$DataDir/referer";  # Stores referer data
$TempDir     = "$DataDir/temp";	    # Temporary files and locks
$LockDir     = "$TempDir/lock";	    # DB is locked if this exists
$NoEditFile  = "$DataDir/noedit";   # Indicates that the site is read-only
$RcFile	     = "$DataDir/rc.log";   # New RecentChanges logfile
$RcOldFile   = "$DataDir/oldrc.log"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$VisitorFile = "$DataDir/visitors.log"; # List of recent visitors
$PermanentAnchorsFile = "$DataDir/permanentanchors"; # Store permanent anchors
$ConfigFile  = "$DataDir/config" unless $ConfigFile; # Config file with Perl code to execute
$ModuleDir   = "$DataDir/modules" unless $ModuleDir;  # For extensions (ending in .pm or .pl)
$NearDir     = "$DataDir/near";	    # For page indexes and .png files of other sites
$SisterSiteLogoUrl = 'file:///tmp/oddmuse/%s.png'; # URL format string for logos

%Action = ( rc => \&BrowseRc,		    rollback => \&DoRollback,
	    browse => \&BrowseResolvedPage, maintain => \&DoMaintain,
	    random => \&DoRandom,	    pagelock => \&DoPageLock,
	    history => \&DoHistory,	    editlock => \&DoEditLock,
	    edit => \&DoEdit,		    version => \&DoShowVersion,
	    download => \&DoDownload,	    rss => \&DoRss,
	    unlock => \&DoUnlock,	    password => \&DoPassword,
	    index => \&DoIndex,		    visitors => \&DoShowVisitors,
	    refer => \&DoPrintAllReferers,  all => \&DoPrintAllPages, );

# The 'main' program, called at the end of this script file (aka. as handler)
sub DoWikiRequest {
  Init();
  DoSurgeProtection();
  if (not $BannedCanRead and UserIsBanned() and not UserIsEditor()) {
    ReportError(T('Reading not allowed: user, ip, or network is blocked.'), '403 FORBIDDEN');
  }
  DoBrowseRequest();
}

sub ReportError { # fatal!
  my ($errmsg, $status, $log) = @_;
  print GetHttpHeader('text/html', 1, $status); # no caching
  print $q->h2($errmsg), $q->end_html;
  map { ReleaseLockDir($_); } keys %Locks;
  WriteStringToFile("$TempDir/error", $q->start_html . $q->h1("$status $errmsg")
		    . $q->Dump . $q->end_html) if $log;
  exit (1);
}

sub Init {
  $FS  = "\x1e";      # The FS character is the RECORD SEPARATOR control char in ASCII
  $Message = '';      # Warnings and non-fatal errors.
  InitLinkPatterns(); # Link pattern can be changed in config files
  if ($UseConfig and $ModuleDir and -d $ModuleDir) {
    foreach my $lib (glob("$ModuleDir/*.pm $ModuleDir/*.pl")) {
      do $lib unless $INC{$lib};
      $Message .= CGI::p("$lib: $@") if $@; # no $q exists, yet
    }
  }
  if ($UseConfig and $ConfigFile and -f $ConfigFile and not $INC{$ConfigFile}) {
    do $ConfigFile;
    $Message .= CGI::p("$ConfigFile: $@") if $@; # no $q exists, yet
  }
  InitRequest();      # get $q
  if ($ConfigPage) {  # $FS, $HttpCharset, $MaxPost must be set in config file!
    eval GetPageContent($ConfigPage);
    $Message .= $q->p("$ConfigPage: $@") if $@;
  }
  eval { local $SIG{__DIE__}; binmode(STDOUT, ":raw"); };
  InitVariables();    # Ater config file, to post-process some variables
  InitCookie();	      # After request, because $q is used
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
  $Now = time;	       # Reset in case script is persistent
  $LastUpdate = (stat($IndexFile))[9];
  $InterSiteInit = 0;
  %InterSite = ();
  $NearSiteInit = 0;
  %NearSite = ();
  %NearSearch = ();
  %NearSource = ();
  %NearLinksUsed = ();
  $RssInterwikiTranslateInit = 0;
  %RssInterwikiTranslate = ();
  %Locks = ();
  $IndexInit =0;
  @Blocks = ();
  @Flags = ();
  $Fragment = '';
  %RecentVisitors = ();
  %PagePermanentAnchors = ();
  $OpenPageName = '';  # Currently open page
  $PrintedHeader = 0;  # Error messages don't print headers unless necessary
  CreateDir($DataDir); # Create directory if it doesn't exist
  ReportError(Ts('Could not create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR')
    unless -d $DataDir;
  @UserGotoBarPages = ($HomePage, $RCName) unless @UserGotoBarPages;
  @LockOnCreation = ($BannedHosts, $RefererFilter, $StyleSheetPage, $ConfigPage, $InterMap,
		     $NearMap, $RssInterwikiTranslate, $BannedContent) unless @LockOnCreation;
  my $add_space = $CommentsPrefix =~ /[ \t_]$/;
  map { $$_ = FreeToNormal($$_); } # convert spaces to underscores on all configurable pagenames
    (\$HomePage, \$RCName, \$BannedHosts, \$InterMap, \$RefererFilter, \$StyleSheetPage, \$NearMap,
     \$ConfigPage, \$NotFoundPg, \$RssInterwikiTranslate, \$BannedContent, \$RssExclude,
     \$CommentsPrefix);
  $CommentsPrefix .= '_' if $add_space;
  unshift(@MyRules, \&MyRules) if defined(&MyRules) && (not @MyRules or $MyRules[0] != \&MyRules);
  @MyRules = sort {$RuleOrder{$a} <=> $RuleOrder{$b}} @MyRules; # default is 0
  $WikiDescription = $q->p($q->a({-href=>'http://www.oddmuse.org/'}, 'Oddmuse'))
    . $q->p(q{$Id: wiki.pl,v 1.506 2005/01/02 15:52:48 as Exp $});
  $WikiDescription .= $ModulesDescription if $ModulesDescription;
}

sub InitCookie {
  undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
  if ($q->cookie($CookieName)) {
    %OldCookie = split(/$FS/, $q->cookie($CookieName));
  } else {
    %OldCookie = ();
  }
  %NewCookie = %OldCookie;
  # Only valid usernames get stored in the new cookie.
  my $name = GetParam('username', '');
  $q->delete('username');
  delete $NewCookie{username};
  if (!$name) {
    # do nothing
  } elsif (!$FreeLinks && !($name =~ /^$LinkPattern$/)) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif ($FreeLinks && (!($name =~ /^$FreeLinkPattern$/))) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif (length($name) > 50) {  # Too long
    $Message .= $q->p(T('UserName must be 50 characters or less: not saved'));
  } else {
    SetParam('username', $name);
  }
}

sub GetParam {
  my ($name, $default) = @_;
  my $result = $q->param($name);
  $result = $NewCookie{$name} unless defined($result); # empty strings are defined!
  $result = $default unless defined($result);
  return $result;
}

sub SetParam {
  my ($name, $val) = @_;
  $NewCookie{$name} = $val;
}

# == Markup Code ==

sub InitLinkPatterns {
  my ($UpperLetter, $LowerLetter, $AnyLetter, $WikiWord, $QDelim);
  $QDelim = '(?:"")?';# Optional quote delimiter (removed from the output)
  $WikiWord = '[A-Z]+[a-z\x80-\xff]+[A-Z][A-Za-z\x80-\xff]*';
  $LinkPattern = "($WikiWord)$QDelim";
  $FreeLinkPattern = "([-,.()' _0-9A-Za-z\x80-\xff]+)";
  # Intersites must start with uppercase letter to avoid confusion with URLs.
  $InterSitePattern = '[A-Z\x80-\xff]+[A-Za-z\x80-\xff]+';
  $InterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x80-\xff_=!?#$@~`%&*+\\/:;.,]+[-a-zA-Z0-9\x80-\xff_=#$@~`%&*+\\/])$QDelim";
  $FreeInterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x80-\xff_=!?#$@~`%&*+\\/:;.,()' ]+)"; # plus space and other characters, and no restrictions on the end of the pattern
  $UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|prospero|telnet|gopher|irc';
  $UrlProtocols .= '|file'  if $NetworkFile;
  my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]'; # see RFC 2396
  my $EndChars = '[-a-zA-Z0-9/@=+$_~*]'; # no punctuation at the end of the url.
  $UrlPattern = "((?:$UrlProtocols):$UrlChars+$EndChars)";
  $FullUrlPattern="((?:$UrlProtocols):$UrlChars+)"; # when used in square brackets
  $ImageExtensions = '(gif|jpg|png|bmp|jpeg)';
}

sub Clean {
  my $block = shift;
  return 0 unless defined($block); # "0" must print
  return 1 if $block eq '';        # '' is the result of a dirty rule
  $Fragment .= $block;
  return 1;
}

sub Dirty { # arg 1 is the raw text; the real output must be printed instead
  if ($Fragment ne '') {
    $Fragment =~ s|<p></p>||g; # clean up extra paragraphs (see end of ApplyRules)
    print $Fragment;
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  push(@Blocks, (shift));
  push(@Flags, 1);
  $Fragment = '';
};

sub ApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks, $withanchors, $revision, @tags) = @_; # $revision is used for images
  NearInit() unless $NearSiteInit;
  $text =~ s/\r\n/\n/g; # DOS to Unix
  $text =~ s/\n+$//g;    # No trailing paragraphs
  return unless $text;
  local $Fragment = ''; # the clean HTML fragment not yet on @Blocks
  local @Blocks=();     # the list of cached HTML blocks
  local @Flags=();	# a list for each block, 1 = dirty, 0 = clean
  Clean(join('', map { AddHtmlEnvironment($_) } @tags));
  if ($text =~ m/^#FILE ([^ \n]+)\n/) {
    Clean($q->p(T('This page contains an uploaded file:'))
	  . $q->p(GetDownloadLink($OpenPageName, (substr($1, 0, 6) eq 'image/'), $revision)));
  } else {
    my $smileyregex = join "|", keys %Smilies;
    $smileyregex = qr/(?=$smileyregex)/;
    local $_ = $text;
    local $bol = 1;
    local $first = 1;
    while (1) {
      # Block level elements eat empty lines to prevent empty p elements.
      if ($bol && m/\G(\s*\n)*(\*+)[ \t]+/cg
	  or InElement('li') && m/\G(\s*\n)+(\*+)[ \t]+/cg) {
	Clean(CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ul',length($2))
	      . AddHtmlEnvironment('li'));
      } elsif ($bol && m/\G(\s*\n)+/cg) {
	Clean(CloseHtmlEnvironments() . AddHtmlEnvironment('p'));
      } elsif ($bol && m/\G(\&lt;include(\s+(text|with-anchors))?\s+"(.*)"\&gt;[ \t]*\n?)/cgi) {
	# <include "uri..."> includes the text of the given URI verbatim
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my ($oldpos, $type, $uri) = ((pos), $3, UnquoteHtml($4)); # remember, page content is quoted!
	if ($uri =~ /^$UrlProtocols:/o) {
	  if ($type eq 'text') {
	    print $q->pre({class=>"include $uri"},QuoteHtml(GetRaw($uri)));
	  } else { # never use local links for remote pages, with a starting tag
	    print $q->start_div({class=>"include $uri"});
	    ApplyRules(QuoteHtml(GetRaw($uri)), 0, ($type eq 'with-anchors'), undef, 'p');
	    print $q->end_div();
	  }
	} else {
	  local $OpenPageName = FreeToNormal($uri);
	  if ($type eq 'text') {
	    print $q->pre({class=>"include $uri"},QuoteHtml(GetPageContent($OpenPageName)));
	  } else {		# with a starting tag
	    print $q->start_div({class=>"include $uri"});
	    ApplyRules(QuoteHtml(GetPageContent($OpenPageName)), $locallinks, $withanchors, undef, 'p');
	    print $q->end_div();
	  }
	}
	print AddHtmlEnvironment('p');
	pos = $oldpos;		# restore \G after call to ApplyRules
      } elsif ($bol && m/\G(\&lt;journal(\s+(\d*))?(\s+"(.*)")?(\s+(reverse))?\&gt;[ \t]*\n?)/cgi) {
	# <journal 10 "regexp"> includes 10 pages matching regexp
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my $oldpos = pos;
	PrintJournal($3, $5, $7);
	print AddHtmlEnvironment('p');
	pos = $oldpos;		# restore \G after call to ApplyRules
      } elsif ($bol && m/\G(\&lt;rss(\s+(\d*))?\s+(.*?)\&gt;[ \t]*\n?)/cgis) {
	# <rss "uri..."> stores the parsed RSS of the given URI
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my $oldpos = pos;
	eval { local $SIG{__DIE__}; binmode(STDOUT, ":utf8"); } if $HttpCharset eq 'UTF-8';
	print RSS($3 ? $3 : 15, split(/\s+/, UnquoteHtml($4)));
	eval { local $SIG{__DIE__}; binmode(STDOUT, ":raw"); };
	print AddHtmlEnvironment('p');
	pos = $oldpos;
	# restore \G after call to RSS which uses the LWP module (for older copies of the module?)
      } elsif ($locallinks
	       and ($BracketText && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cog
		    or $BracketText && m/\G(\[\[$FreeInterLinkPattern\|([^\]]+?)\]\])/cog
		    or m/\G(\[$InterLinkPattern\])/cog or m/\G(\[\[\[$FreeInterLinkPattern\]\]\])/cog
		    or m/\G($InterLinkPattern)/cog or m/\G(\[\[$FreeInterLinkPattern\]\])/cog)) {
	# [InterWiki:FooBar text] or [InterWiki:FooBar] or
	# InterWiki:FooBar or [[InterWiki:foo bar|text]] or
	# [[InterWiki:foo bar]] or [[[InterWiki:foo bar]]]-- Interlinks
	# can change when the intermap changes (local config, therefore
	# depend on $locallinks).  The intermap is only read if
	# necessary, so if this not an interlink, we have to backtrack a
	# bit.
	my $bracket = (substr($1, 0, 1) eq '[')	# but \[\[$FreeInterLinkPattern\]\] it not bracket!
	  && !((substr($1, 0, 2) eq '[[') && (substr($1, 2, 1) ne '[') && index($1, '|') < 0);
	my $quote = (substr($1, 0, 2) eq '[[');
	my ($oldmatch, $output) = ($1, GetInterLink($2, $3, $bracket, $quote));	# $3 may be empty
	if ($oldmatch eq $output) { # no interlink
	  my ($site, $rest) = split(/:/, $oldmatch, 2);
	  Clean($site);
	  pos = (pos) - length($rest) - 1; # skip site, but reparse rest
	} else {
	  Dirty($oldmatch);
	  print $output;	# this is an interlink
	}
      } elsif ($BracketText && m/\G(\[$FullUrlPattern\s+([^\]]+?)\])/cog
	       or m/\G(\[$FullUrlPattern\])/cog or m/\G($UrlPattern)/cog) {
	# [URL text] makes [text] link to URL, [URL] makes footnotes [1]
	my $bracket = (substr($1, 0, 1) eq '[');
	if ($bracket and not $3) { # [URL] is dirty because the number may change
	  Dirty($1);
	  print GetUrl($2, '', 1);
	} else {
	  Clean(GetUrl($2, $3, $bracket, not $bracket)); # $2 may be empty
	}
      } elsif ($WikiLinks && m/\G!$LinkPattern/cog) {
	Clean($1);		# ! gets eaten
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
      } elsif ($locallinks && $FreeLinks && (m/\G(\[\[image:$FreeLinkPattern\]\])/cog
					     or m/\G(\[\[image:$FreeLinkPattern\|([^]|]+)\]\])/cog)) {
	# [[image:Free Link]], [[image:Free Link|alt text]]
	Dirty($1);
	print GetDownloadLink($2, 1, undef, $3);
      } elsif ($FreeLinks && $locallinks
	       && ($BracketWiki && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cog
		   or m/\G(\[\[\[$FreeLinkPattern\]\]\])/cog
		   or m/\G(\[\[$FreeLinkPattern\]\])/cog)) {
	# [[Free Link|text]], [[Free Link]]
	Dirty($1);
	my $bracket = (substr($1, 0, 3) eq '[[[');
	print GetPageOrEditLink($2, $3, $bracket, 1); # $3 may be empty
      } elsif ($bol && m/\G(&lt;&lt;&lt;&lt;&lt;&lt;&lt; )/cg) {
	my ($str, $count, $limit, $oldpos) = ($1, 0, 100, pos);
	while (m/\G(.*\n)/cg and $count++ < $limit) {
	  $str .= $1;
	  last if (substr($1, 0, 29) eq '&gt;&gt;&gt;&gt;&gt;&gt;&gt; ');
	}
	if ($count >= $limit) {
	  pos = $oldpos;
	  Clean('&lt;&lt;&lt;&lt;&lt;&lt;&lt; ');
	} else {
	  Clean(CloseHtmlEnvironments() . $q->pre({-class=>'conflict'}, $str) . AddHtmlEnvironment('p'));
	}
      } elsif (%Smilies && m/\G$smileyregex/cog && (Clean(SmileyReplace()))) {
      } elsif (Clean(RunMyRules())) {
      } elsif (m/\G\s*\n(s*\n)+/cg) { # paragraphs: at least two newlines
	Clean(CloseHtmlEnvironments() . AddHtmlEnvironment('p')); # another one like this further up
      } elsif (m/\G\s+/cg) {
	Clean(' ');
      } elsif (m/\G([A-Za-z\x80-\xff]+([ \t]+[a-z\x80-\xff]+)*[ \t]+)/cg # multiple words but
	     or m/\G([A-Za-z\x80-\xff]+)/cg or m/\G(\S)/cg) {
	Clean($1);		# do not match http://foo
      } else {
	last;
      }
      my $oldpos = pos;	# the following match causes smilies to fail at line beginnings!?
      $bol = m/\G(?<=\n)/cgs;
      pos = $oldpos; # therefore restore pos...  reason unknown (Perl v5.8.4).
      $first = 0;
    }
  }
  # last block -- close it, cache it
  Clean(CloseHtmlEnvironments());
  if ($Fragment ne '') {
    $Fragment =~ s|<p></p>||g; # clean up extra paragraphs (see end Dirty())
    print $Fragment;
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  # this can be stored in the page cache -- see PrintCache
  return (join($FS, @Blocks), join($FS, @Flags));
}

sub InElement {
  my ($code, $limit) = @_; # is $code in @HtmlStack, but not beyond $limit?
  my @stack = @HtmlStack;
  while (@stack) {
    my $tag = shift(@stack);
    return 1 if $tag eq $code;
    return 0 if $limit and $tag eq $limit;
  }
  return 0;
}

sub CloseHtmlEnvironment { # just close the current one
  my $code = shift;
  my $result;
  $result = shift(@HtmlStack) if not defined($code) or $HtmlStack[0] eq $code;
  return "</$result>" if $result;
  return "&lt;/$code&gt;";
}

sub CloseHtmlEnvironmentUntil { # close all environments until you get to $code
  my $code = shift;
  my $result = '';
  while (@HtmlStack and $HtmlStack[0] ne $code) {
    $result .= '</' . shift(@HtmlStack) . '>';
  }
  return $result;
}

sub AddHtmlEnvironment { # add a new one so that it will be closed!
  my ($code, $attr) = @_;
  if (@HtmlStack and $HtmlStack[0] ne $code or not @HtmlStack) {
    unshift(@HtmlStack, $code);
    return "<$code $attr>" if ($attr);
    return "<$code>";
  }
  return ''; # always return something
}

sub CloseHtmlEnvironments { # close all -- remember to use AddHtmlEnvironment('p') if required!
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
  $depth = $IndentLimit	 if ($depth > $IndentLimit); # requested depth 0 makes no sense
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
  foreach my $regexp (keys %Smilies) {
    if (m/\G($regexp)/cg) {
      return $q->img({-src=>$Smilies{$regexp}, -alt=>$1, -class=>'smiley'});
    }
  }
}

sub RunMyRules {
  foreach my $sub (@MyRules) {
    my $result = &$sub;
    SetParam('msg', $@) if $@;
    return $result if defined($result);
  }
  return undef;
}

sub PrintWikiToHTML {
  my ($pageText, $savecache, $revision, $islocked) = @_;
  $FootnoteNumber = 0;
  $pageText =~ s/$FS//g; # Remove separators (paranoia)
  $pageText = QuoteHtml($pageText);
  my ($blocks, $flags) = ApplyRules($pageText, 1, $savecache, $revision, 'p'); # p is start tag!
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

sub QuoteHtml {
  my $html = shift;
  $html =~ s/&/&amp;/g;
  $html =~ s/</&lt;/g;
  $html =~ s/>/&gt;/g;
  $html =~ s/&amp;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references
  return $html;
}

sub UnquoteHtml {
  my $html = shift;
  $html =~ s/&lt;/</g;
  $html =~ s/&gt;/>/g;
  $html =~ s/&amp;/&/g;
  return $html;
}

sub UrlEncode {
  my $str = shift;
  return '' unless $str;
  my @letters = split(//, $str);
  my @safe = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')', '#');
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
  return unless eval { require LWP::UserAgent; };
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($uri);
  return $response->content;
}

sub PrintJournal {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  my ($num, $regexp, $mode) = @_;
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
    local %Page;
    local $OpenPageName='';
    print $q->start_div({-class=>'journal'});
    PrintAllPages(1, 1, @pages);
    print $q->end_div();
  }
}

sub RSS {
  return if $CollectingJournal; # avoid infinite loops when using full=1
  local $CollectingJournal = 1;
  my $maxitems = shift;
  my @uris = @_;
  my %lines;
  eval { require XML::RSS;  } or return $q->div({-class=>'rss'},
	 $q->strong(T('XML::RSS is not available on this system.')));
  # All strings that are concatenated with strings returned by the RSS
  # feed must be decoded.  Without this decoding, 'diff' and 'history'
  # translations will be double encoded when printing the result.
  my $tDiff = T('diff');
  my $tHistory = T('history');
  if ($HttpCharset eq 'UTF-8' and ($tDiff ne 'diff' or $tHistory ne 'history')) {
    eval { local $SIG{__DIE__};
	   require Encode;
	   $tDiff = Encode::decode_utf8($tDiff);
	   $tHistory = Encode::decode_utf8($tHistory);
	 }
  }
  my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
  my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  my $str;
  foreach my $uri (@uris) {
    $uri =~ s/^"?(.*?)"?$/$1/;
    my $rss = new XML::RSS;
    my $data = GetRaw($uri);
    $str .= $q->p($q->strong(Ts('%s returned no data, or LWP::UserAgent is not available.',
				$q->a({-href=>$uri}, $uri)))) unless $data;
    eval { local $SIG{__DIE__}; $rss->parse($data); };
    $str .= $q->p($q->strong(Ts('RSS parsing failed for %s',
				$q->a({-href=>$uri}, $uri)) . ': ' . $@)) if $data and $@;
    my ($counter, $interwiki);
    if (@uris > 1) {
      RssInterwikiTranslateInit() unless $RssInterwikiTranslateInit;
      $interwiki = $rss->{channel}->{$wikins}->{interwiki};
      $interwiki =~ s/^\s+//; # when RDF is used, sometimes whitespace remains,
      $interwiki =~ s/\s+$//; # which breaks the test for an existing $interwiki below
      if (!$interwiki) {
	$interwiki = $rss->{channel}->{$rdfns}->{value};
      }
      $interwiki = $RssInterwikiTranslate{$interwiki} if $RssInterwikiTranslate{$interwiki};
      $interwiki = $RssInterwikiTranslate{$uri} unless $interwiki;
    }
    my $num = 999;
    $str .= $q->p($q->strong(Ts('No items found in %s.', $q->a({-href=>$uri}, $uri))))
      unless @{$rss->{items}};
    foreach my $i (@{$rss->{items}}) {
      my $line;
      my $date = $i->{dc}->{date};
      if (not $date and $i->{pubDate}) {
	$date = $i->{pubDate};
	my %mon = (Jan=>1, Feb=>2, Mar=>3, Apr=>4, May=>5, Jun=>6,
		   Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12);
	$date =~ s/^[A-Z][a-z][a-z], (\d\d) ([A-Z][a-z][a-z]) (\d\d(?:\d\d)?)/ # pubDate uses RFC 822
	  sprintf('%04d-%02d-%02d', ($3 < 100 ? 1900 + $3 : $3), $mon{$2}, $1)/e;
      }
      $date = sprintf("%03d", $num--) unless $date; # for RSS 0.91 feeds without date, descending
      my $title = $i->{title};
      my $description = $i->{description};
      if (not $title and $description) { # title may be missing in RSS 2.00
	$title = $description;
	$description = '';
      }
      $title = $i->{link} if not $title and $i->{link}; # if description and title are missing
      $line .= ' (' . $q->a({-href=>$i->{$wikins}->{diff}}, $tDiff) . ')'
	if $i->{$wikins}->{diff};
      $line .= ' (' . $q->a({-href=>$i->{$wikins}->{history}}, $tHistory) . ')'
	if $i->{$wikins}->{history};
      if ($title) {
	if ($i->{link}) {
	  $line .= ' ' . $q->a({-href=>$i->{link}, -title=>$date},
			       ($interwiki ? $interwiki . ':' : '') . $title);
	} else {
	  $line .= ' ' . $title;
	}
      }
      my $contributor = $i->{dc}->{contributor};
      $contributor =~ s/^\s+//;
      $contributor =~ s/\s+$//;
      if (!$contributor) {
	$contributor = $i->{$rdfns}->{value};
      }
      $line .= $q->span({-class=>'contributor'}, $q->span(T(' . . . . ')) . $contributor)
	if $contributor;
      $line .= ' ' . $q->strong({-class=>'description'}, '--', $description) if $description;
      while ($lines{$date}) { $date .= ' '; } # make sure this is unique
      $lines{$date} = $line;
    }
  }
  my @lines = sort { $b cmp $a } keys %lines;
  @lines = @lines[0..$maxitems-1] if $maxitems and $#lines > $maxitems;
  my $date;
  foreach my $key (@lines) {
    my $line = $lines{$key};
    if ($key =~ /(\d\d\d\d(?:-\d?\d)?(?:-\d?\d)?)(?:[T ](\d?\d:\d\d))?/) {
      my ($day, $time) = ($1, $2);
      if ($day ne $date) {
	$str .= '</ul>' if $date; # close ul except for the first time where no open ul exists
	$date = $day;
	$str .= $q->p($q->strong($day)) . '<ul>';
      }
      $line = $time . ' UTC ' . $line if $time;
    } elsif (not $date) {
      $str .= '<ul>'; # if the feed doesn't have any dates we need to start the list anyhow
      $date = $Now; # to ensure the list starts only once
    }
    $str .= $q->li($line);
  }
  $str .= '</ul>' if $date;
  return $q->div({-class=>'rss'}, $str);
}

sub RssInterwikiTranslateInit {
  $RssInterwikiTranslateInit = 1;
  foreach (split(/\n/, GetPageContent($RssInterwikiTranslate))) {
    if (/^ ([^ ]+)[ \t]+([^ ]+)$/) {
      $RssInterwikiTranslate{$1} = $2;
    }
  }
}

sub NearInit {
  InterInit() unless $InterSiteInit;
  $NearSiteInit = 1;
  foreach (split(/\n/, GetPageContent($NearMap))) {
    if (/^ ($InterSitePattern)[ \t]+([^ ]+)(?:[ \t]+([^ ]+))?$/) {
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

sub GetInterSiteUrl {
  my ($site, $page, $quote) = @_;
  return unless $page;
  $page = UrlEncode($page) if $quote; # Foo:bar+baz is not quoted, [[Foo:bar baz]] is quoted.
  my $url = $InterSite{$site} or return;
  $url =~ s/\%s/$page/g or $url .= $page;
  return $url;
}

sub BracketLink { # brackets can be removed via CSS
  return $q->span($q->span({class=>'bracket'}, '[') . (shift) . $q->span({class=>'bracket'}, ']'));
}

sub GetInterLink {
  my ($id, $text, $bracket, $quote) = @_;
  my ($site, $page) = split(/:/, $id, 2);
  $page =~ s/&amp;/&/g;	 # Unquote common URL HTML
  my $url = GetInterSiteUrl($site, $page, $quote);
  my $class = 'inter';
  if ($text && $bracket && !$url) {
    return "[$id $text]";
  } elsif ($bracket && !$url) {
    return "[$id]";
  } elsif (!$url) {
    return $id;
  } elsif ($bracket && !$text) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
  } elsif (!$text) {
    $text = $q->span({-class=>'site'}, $site) . ':' . $q->span({-class=>'page'}, $page);
  } elsif ($bracket) { # and $text is set
    $class .= ' outside';
  }
  return $q->a({-href=>$url, -class=>$class}, $text);
}

sub InterInit {
  $InterSiteInit = 1;
  foreach (split(/\n/, GetPageContent($InterMap))) {
    if (/^ ($InterSitePattern)[ \t]+([^ ]+)$/) {
      $InterSite{$1} = $2;
    }
  }
}

sub GetUrl {
  my ($url, $text, $bracket, $images) = @_;
  my $class = 'url';
  if ($NetworkFile && $url =~ m|^file:///| && !$AllNetworkFiles
      or !$NetworkFile && $url =~ m|^file:|) {
    # Only do remote file:// links. No file:///c|/windows.
    return $url;
  } elsif ($bracket && !$text) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
  } elsif (!$text) {
    $text = $url;
  } elsif ($bracket) { # and $text is set
    $class .= ' outside';
  }
  $url = UnquoteHtml($url); # links should be unquoted again
  if ($images && $url =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/i) {
    return $q->img({-src=>$url, -alt=>$url, -class=>$class});
  } else {
    return $q->a({-href=>$url, -class=>$class}, $text);
  }
}

sub GetPageOrEditLink { # use GetPageLink and GetEditLink if you know the result!
  my ($id, $text, $bracket, $free) = @_;
  $id = FreeToNormal($id);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if (!$text && $resolved && $bracket) {
    $text = BracketLink(++$FootnoteNumber); # s/_/ /g happens further down!
    $class .= ' number';
    $title = $id; # override title
    $title =~ s/_/ /g if $free;
  }
  if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
    $text = $id unless $text;
    $text =~ s/_/ /g if $free;
    return $q->a({-class=>$class, -href=>$resolved, -title=>$title}, $text) if $class eq 'near';
    return ScriptLink(UrlEncode($resolved), $text, $class, undef, $title);
  } else {
    # $free and $bracket usually exclude each other
    # $text and not $bracket exclude each other
    my $link = GetEditLink($id, '?');
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

sub GetPageLink { # use if you want to force a link to local pages, whether it exists or not
  my ($id, $name) = @_;
  $id = FreeToNormal($id);
  $name = $id unless $name;
  $name =~ s/_/ /g;
  return ScriptLink(UrlEncode($id), $name, 'local');
}

sub GetEditLink { # shortcut
  my ($id, $name, $upload, $accesskey) = @_;
  $id = FreeToNormal($id);
  $name =~ s/_/ /g;
  my $action = 'action=edit;id=' . UrlEncode($id);
  $action .= ';upload=1' if $upload;
  return ScriptLink($action, $name, 'edit', undef, T('Click to edit this page'), $accesskey);
}

sub ScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey) = @_;
  my %params;
  if ($UsePathInfo and !$Monolithic and $action !~ /=/) {
    $params{-href} = $ScriptName . '/' . $action;
  } elsif ($Monolithic) {
    $params{-href} = '#' . $action;
  } else {
    $params{-href} = $ScriptName . '?' . $action;
  }
  $params{'-class'} = $class  if $class;
  $params{'-name'} = UrlEncode($name)  if $name;
  $params{'-title'} = $title  if $title;
  $params{'-accesskey'} = $accesskey  if $accesskey;
  return $q->a(\%params, $text);
}

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
      $action = $ScriptName . '/' . $action;
    } else {
      $action = $ScriptName . '?' . $action;
    }
    my $result = $q->img({-src=>$action, -alt=>$alt, -class=>'upload'});
    $result = ScriptLink(UrlEncode($id), $result, 'image') unless $id eq $OpenPageName;
    return $result;
  } else {
    return ScriptLink($action, $alt, 'upload');
  }
}

sub PrintCache { # Use after OpenPage!
  my @blocks = split($FS,$Page{blocks});
  my @flags = split($FS,$Page{flags});
  $FootnoteNumber = 0;
  foreach my $block (@blocks) {
    if (shift(@flags)) {
      ApplyRules($block, 1, 1); # local links, anchors, current revision, no start tag
    } else {
      print $block;
    }
  }
}

sub PrintPageHtml { # print an open page
  if ($Page{blocks} && $Page{flags} && GetParam('cache', $UseCache) > 0) {
    PrintCache();
  } else {
    PrintWikiToHTML($Page{text}, 1); # save cache, current revision, no main lock
  }
}

sub PrintPageDiff { # print diff for open page
  my $diff = GetParam('diff', 0);
  if ($UseDiff && $diff) {
    PrintHtmlDiff($diff);
    print $q->hr();
  }
}

sub PageHtml {
  my $id = shift; # $id may no longer exist when using action=rss;full=1
  my $result = '';
  local *STDOUT;
  open(STDOUT, '>', \$result) or die "Can't open memory file: $!";
  OpenPage($id);
  PrintPageDiff();
  PrintPageHtml();
  return $result;
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
  $text =~ s/\%s/$string/ if defined($string);
  return $text;
}

sub Tss {
  my $text = $_[0];
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
  my $id = join('_', $q->keywords); # script?p+q -> p_q
  $id = $q->path_info if $UsePathInfo and not $id; # script/p/q -> p/q
  my $action = lc(GetParam('action', '')); # script?action=foo;id=bar
  SetParam('raw', 1) if ($id =~ s|raw/||); # script/raw/id
  $action = 'download' if ($id =~ s|download/|| and not $action); # script/download/id
  $id =~ s|.*/||; # script/ignore/id (ie. we can embed information in the path!)
  $id = GetParam('id', $id); # id=x overrides
  my $search = GetParam('search', '');
  if ($Action{$action}) {
    &{$Action{$action}}($id);
  } elsif ($action and defined &MyActions) {
    eval { local $SIG{__DIE__}; MyActions(); };
  } elsif ($action) {
    ReportError(Ts('Invalid action parameter %s', $action), '501 NOT IMPLEMENTED');
  } elsif (($search ne '') || (GetParam('dosearch', '') ne '')) {
    DoSearch($search);
  } elsif (GetParam('title', '')) {
    DoPost(GetParam('title', ''));
  } elsif ($id) {
    BrowseResolvedPage($id); # default action!
  } else {
    ReportError(T('Invalid URL.'), '400 BAD REQUEST');
  }
}

# == Id handling ==

sub ValidId {
  my $id = shift;
  return T('Page name is missing') unless $id;
  return Ts('Page name is too long: %s', $id)  if (length($id) > 120);
  if ($FreeLinks) {
    $id =~ s/ /_/g;
    return Ts('Invalid Page %s', $id)  if (!($id =~ m|^$FreeLinkPattern$|));
    return Ts('Invalid Page %s (must not end with .db)', $id)  if ($id =~ m|\.db$|);
    return Ts('Invalid Page %s (must not end with .lck)', $id)	if ($id =~ m|\.lck$|);
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
  ReportError($error, '400 BAD REQUEST') if $error;
  return 1;
}

sub ResolveId { # return css class, resolved id, title (eg. for popups), exist-or-not
  my $id = shift;
  AllPagesList();
  my $exists = $IndexHash{$id}; # if the page exists physically
  if (GetParam('anchor', $PermanentAnchors)) { # anchors are preferred
    ReadPermanentAnchors() unless $PermanentAnchorsInit;
    my $page = $PermanentAnchors{$id};
    return ('alias', $page . '#' . $id, $page, $exists) # $page used as link title
      if $page and $page ne $id;
  }
  return ('local', $id, '', $exists) if $exists;
  NearInit() unless $NearSiteInit;
  if ($NearSource{$id}) {
    $NearLinksUsed{$id} = 1;
    my $site = $NearSource{$id}[0];
    return ('near', GetInterSiteUrl($site, $id), $site); # return source as title attribute
  }
}

sub BrowseResolvedPage {
  my $id = FreeToNormal(shift);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if ($class eq 'near' && not GetParam('rcclusteronly', 0)) { # nearlink (is url)
    print $q->redirect({-uri=>$resolved});
  } elsif ($class eq 'alias') { # an anchor was found instead of a page
    ReBrowsePage($resolved, undef);
  } elsif (not $resolved and $NotFoundPg) { # custom page-not-found message
    BrowsePage($NotFoundPg);
  } elsif ($resolved) { # an existing page was found
    BrowsePage($resolved, GetParam('raw', 0));
  } else { # new page!
    BrowsePage($id, GetParam('raw', 0), undef, '404 NOT FOUND') if ValidIdOrDie($id);
  }
}

# == Browse page ==

sub BrowsePage {
  my ($id, $raw, $comment, $status) = @_;
  if ($q->http('HTTP_IF_MODIFIED_SINCE')
      and $q->http('HTTP_IF_MODIFIED_SINCE') eq gmtime($LastUpdate)
      and GetParam('cache', $UseCache) >= 2) {
    print $q->header(-status=>'304 NOT MODIFIED');
    return;
  }
  OpenPage($id);
  my ($text, $revision) = GetTextRevision(GetParam('revision', ''));
  # handle a single-level redirect
  my $oldId = GetParam('oldid', '');
  if (not $oldId and not $revision and (substr($text, 0, 10) eq '#REDIRECT ')) {
    if (($FreeLinks and $text =~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\]\]/)
	or ($WikiLinks and $text =~ /^\#REDIRECT\s+$LinkPattern/)) {
      ReBrowsePage(FreeToNormal($1), $id); # trim extra whitespace from $1, prevent loops with $id
      return;
    }
  }
  # shortcut if we only need the raw text: no caching, no diffs, no html.
  if ($raw) {
    print GetHttpHeader('text/plain');
    if ($raw == 2) {
      print $Page{ts} . " # Do not delete this line when editing!\n";
    }
    print $text;
    return;
  }
  # normal page view
  my $msg = GetParam('msg', '');
  $Message .= $q->p($msg) if $msg; # show message if the page is shown
  SetParam('msg', '');
  print GetHeader($id, QuoteHtml($id), $oldId, undef, $status);
  my $showDiff = GetParam('diff', 0);
  if ($UseDiff && $showDiff) {
    PrintHtmlDiff($showDiff, GetParam('diffrevision', $revision), $revision, $text);
    print $q->hr();
  }
  print $q->start_div({-class=>'content browse'});
  if ($revision eq '' and $Page{blocks} and $Page{flags} and GetParam('cache', $UseCache) > 0) {
    PrintCache();
  } else {
    my $savecache = ($Page{revision} > 0 and $revision eq ''); # new page not cached
    PrintWikiToHTML($text, $savecache, $revision); # unlocked, with anchors, unlocked
  }
  print $q->end_div();;
  if ($comment) {
    print $q->start_div({-class=>'preview'}), $q->hr();
    print $q->h2(T('Preview:'));
    PrintWikiToHTML(AddComment('', $comment)); # no caching, current revision, unlocked
    print $q->hr(), $q->h2(T('Preview only, not yet saved')), $q->end_div();;
  }
  my $embed = GetParam('embed', $EmbedWiki);
  SetParam('rcclusteronly', $id) if GetCluster($text) eq $id;
  if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)
      || GetParam('rcclusteronly', '')) {
    print $q->start_div({-class=>'rc'});;
    print $q->hr()  if (!$embed);
    DoRc(\&GetRcHtml);
    print $q->end_div();
  }
  if ($RefererTracking && !$embed) {
    my $referers = RefererTrack($id);
    print $referers if $referers;
  }
  PrintFooter($id, $revision, $comment);
}

sub ReBrowsePage {
  my ($id, $oldId) = map { UrlEncode($_); } @_; # encode before printing URL
  if ($oldId) {	# Target of #REDIRECT (loop breaking)
    print GetRedirectPage("action=browse;oldid=$oldId;id=$id", $id);
  } else {
    print GetRedirectPage($id, $id);
  }
}

sub GetRedirectPage {
  my ($action, $name) = @_;
  my ($url, $html);
  # shortcut if we only need the raw text: no redirect.
  if (GetParam('raw', 0)) {
    $html = GetHttpHeader('text/plain');
    $html .= Ts('Please go on to %s.', $action);
    return $html;
  }
  if ($UsePathInfo and $action !~ /=/) {
    $url = $ScriptName . '/' . $action;
  } else {
    $url = $ScriptName . '?' . $action;
  }
  my $nameLink = $q->a({-href=>$url}, $name);
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

sub BrowseRc {
  if (GetParam('raw', 0)) {
    DoRcText();
  } else {
    BrowsePage($RCName);
  }
}

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
  my $action;
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $lang) =
    map {
      my $val = GetParam($_, '');
      print $q->p($q->b('(' . Ts('for %s only', $val) . ')')) if $val;
      $action .= ";$_=$val" if $val; # remember these parameters later!
      $val;
    }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'lang');
  if ($clusterOnly) {
    $action = GetPageParameters('browse', $clusterOnly) . $action;
  } else {
    $action = "action=rc$action";
  }
  my $days = GetParam('days', $RcDefault);
  my $all = GetParam('all', 0);
  my $edits = GetParam('showedit', 0);
  my @menu;
  if ($all) {
    push(@menu, ScriptLink("$action;days=$days;all=0;showedit=$edits",
			   T('List latest change per page only')));
  } else {
    push(@menu, ScriptLink("$action;days=$days;all=1;showedit=$edits",
			   T('List all changes')));
  }
  if ($edits) {
    push(@menu, ScriptLink("$action;days=$days;all=$all;showedit=0",
			   T('List only major changes')));
  } else {
    push(@menu, ScriptLink("$action;days=$days;all=$all;showedit=1",
			   T('Include minor changes')));
  }
  print $q->p((map { ScriptLink("$action;days=$_;all=$all;showedit=$edits",
				($_ != 1) ? Ts('%s days', $_) : Ts('%s days', $_));
		   } @RcDays), $q->br(), @menu, $q->br(),
	      ScriptLink($action . ';from=' . ($LastUpdate + 1) . ";all=$all;showedit=$edits",
			 T('List later changes')));
}

sub GetFilterForm {
  my $form = $q->strong(T('Filters'));
  $form .= $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1}) if (GetParam('all', 0));
  $form .= $q->input({-type=>'hidden', -name=>'showedit', -value=>1}) if (GetParam('showedit', 0));
  $form .= $q->input({-type=>'hidden', -name=>'days', -value=>GetParam('days', $RcDefault)})
    if (GetParam('days', $RcDefault) != $RcDefault);
  my $table =
    $q->Tr($q->td(T('Username:')) . $q->td($q->textfield(-name=>'rcuseronly', -size=>20)))
    . $q->Tr($q->td(T('Host:')) . $q->td($q->textfield(-name=>'rchostonly', -size=>20)));
  $table .= $q->Tr($q->td(T('Language:')) . $q->td($q->textfield(-name=>'lang', -size=>10,
    -default=>GetParam('lang', '')))) if %Languages;
  return GetFormStart(undef, undef, 'filter') . $q->p($form) . $q->table($table)
    . $q->p($q->submit('dofilter', T('Go!'))) . $q->endform;
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
	push(@temprc, $rcline)	if (!$minor);
      } else {			# 2 = Only edits
	push(@temprc, $rcline)	if ($minor);
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
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $lang) =
    map { GetParam($_, ''); }
      ('rcidonly', 'rcuseronly', 'rchostonly', 'rcclusteronly',
       'rcfilteronly', 'lang');
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
    next if ($lang and @languages and not grep(/$lang/, @languages));
    if ($PageCluster) {
      ($cluster, $summary) = ($1, $2) if $summary =~ /^\[\[$FreeLinkPattern\]\] ?: *(.*)/
	or $summary =~ /^$LinkPattern ?: *(.*)/;
      next if ($clusterOnly and $clusterOnly ne $cluster);
      $cluster = '' if $clusterOnly; # don't show cluster if $clusterOnly eq $cluster
      if ($all < 2 and not $clusterOnly and $cluster) {
	next if grep(/^$cluster$/, @clusters);
	$summary = "$pagename: $summary"; # print the cluster instead of the page
	$pagename = $cluster;
	$revision = '';
	push(@clusters, $pagename);
      }
    } else {
      $cluster = '';
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
  my $tDiff = T('diff');
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
	my($pagename, $timestamp, $host, $username, $summary, $minor, $revision, $languages, $cluster) = @_;
	$host = QuoteHtml($host);
	my $author = GetAuthorLink($host, $username);
	my $sum = $q->strong('--', QuoteHtml($summary))	 if $summary;
	my $edit = $q->em($tEdit)  if $minor;
	my $lang = '[' . join(', ', @{$languages}) . ']'  if @{$languages};
	my ($pagelink, $history, $diff, $rollback);
	if ($all) {
	  $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	  if ($admin and RollbackPossible($timestamp)) {
	    $rollback = '(' . ScriptLink('action=rollback;to=' . $timestamp,
					 $tRollback, 'rollback') . ')';
	  }
	} elsif ($cluster) {
	  $pagelink = GetOldPageLink('browse', $pagename, $revision, $pagename, $cluster);
	} else {
	  $pagelink = GetPageLink($pagename, $cluster);
	  $history = '(' . GetHistoryLink($pagename, $tHistory) . ')';
	}
	if ($cluster and $PageCluster) {
	  $diff .= GetPageLink($PageCluster) . ':';
	} elsif ($UseDiff and GetParam('diffrclink', 1)) {
	  if ($revision == 1) {
	    $diff .= '(' . $q->span({-class=>'new'}, T('new')) . ')';
	  } elsif ($all) {
	    $diff .= '(' . ScriptLinkDiff(2, $pagename, $tDiff, '', $revision) . ')';
	  } else {
	    $diff .= '(' . ScriptLinkDiff($minor ? 2 : 1, $pagename, $tDiff, '') . ')';
	  }
	}
	$html .= $q->li(CalcTime($timestamp), $diff, $history, $rollback, $pagelink,
			T(' . . . . '), $author, $sum, $lang, $edit);
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
      my($pagename, $timestamp, $host, $username, $summary, $minor, $revision, $languages, $cluster) = @_;
      my $link = $ScriptName . (GetParam('all', 0)
				? '?' . GetPageParameters('browse', $pagename, $revision, $cluster)
				: ($UsePathInfo ? '/' : '?') . $pagename);
      $pagename =~ s/_/ /g;
      print "\n" . RcTextItem('title', $pagename)
      . RcTextItem('description', $summary)
      . RcTextItem('generator', $username ? $username . ' ' . Ts('from %s', $host) : $host)
      . RcTextItem('language', join(', ', @{$languages}))
      . RcTextItem('link', $link)
      . RcTextItem('last-modified', CalcDay($timestamp));
    },
    @_;
  return $text;
}

sub GetRcRss {
  my $url = QuoteHtml($ScriptName);
  my $diffPrefix = $url . QuoteHtml("?action=browse;diff=1;id=");
  my $historyPrefix = $url . QuoteHtml("?action=history;id=");
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
  $year += 1900;
  my $date = sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00", $year, $mon+1, $mday, $hour, $min, $sec);
  my @excluded = ();
  if (GetParam('exclude', 1)) {
    foreach (split(/\n/, GetPageContent($RssExclude))) {
      if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
	push(@excluded, $1);
      }
    }
  }
  require XML::RSS;
  my $rss = new XML::RSS (version => '1.0', encoding => $HttpCharset);
  $rss->add_module(
    prefix => 'wiki',
    uri	   => 'http://purl.org/rss/1.0/modules/wiki/'
  );
  $rss->channel(
    title	  => QuoteHtml($SiteName),
    link	  => $url . ($UsePathInfo ? '/' : '?') . UrlEncode($RCName),
    description	  => QuoteHtml($SiteDescription),
    dc => {
      publisher	  => $RssPublisher,
      contributor => $RssContributor,
      date	  => $date,
      rights	  => $RssRights,
    },
    wiki => {
      interwiki	  => $InterWikiMoniker,
    },
  );
  $rss->image(
    title  => QuoteHtml($SiteName),
    url	   => $RssImageUrl,
    link   => $url,
  );
  # Now call GetRc with some blocks of code as parameters:
  GetRc
    # printDailyTear
    sub {},
    # printRCLine
    sub {
      my ($pagename, $timestamp, $host, $username, $summary, $minor, $revision, $languages, $cluster) = @_;
      return if grep(/$pagename/, @excluded);
      my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($timestamp);
      my $name = FreeToNormal($pagename);
      $name =~ s/_/ /g;
      if (GetParam('full', 0)) {
	$name .= ': ' . $summary;
	$summary = PageHtml($pagename);
      }
      $year += 1900;
      my $date = sprintf( "%4d-%02d-%02dT%02d:%02d:%02d+00:00",
	$year, $mon+1, $mday, $hour, $min, $sec);
      my $author = QuoteHtml($username);
      $author = $host unless $author;
      my %wiki = ( status      => (1 == $revision) ? 'new' : 'updated',
		   importance  => $minor ? 'minor' : 'major',
		   version     => $revision,
		   history     => $historyPrefix . $pagename, );
      $wiki{diff} = $diffPrefix . $pagename if $UseDiff and GetParam('diffrclink', 1);
      $rss->add_item( title	   => QuoteHtml($name),
		      link	   => $url
		      . (GetParam('all', 0)
			 ? '?' . GetPageParameters('browse', $pagename, $revision, $cluster)
			 : ($UsePathInfo ? '/' : '?') . UrlEncode($pagename)),
		      description  => QuoteHtml($summary),
		      dc => { date	  => $date,
			      contributor => $author, },
		      wiki => \%wiki, );
    },
    # RC Lines
    @_;
  my $limit = GetParam('rsslimit', 15); # Only take the first 15 entries
  if ($limit ne 'all' and $#{$rss->{items}} > $limit) {
    @{$rss->{items}} = @{$rss->{items}}[0..$limit-1];
  }
  return $rss->as_string;
}

sub DoRss {
  print GetHttpHeader('application/rss+xml');
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
  ValidIdOrDie($id);
  print GetHeader('',QuoteHtml(Ts('History of %s', $id)), '');
  OpenPage($id);
  my $row = 0;
  my @html = (GetHistoryLine($id, \%Page, $row++));
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my %keep = GetKeptRevision($revision);
    push(@html, GetHistoryLine($id, \%keep, $row++));
  }
  if ($UseDiff) {
    @html = (GetFormStart(undef, undef, 'history'),
	     $q->p( # don't use $q->hidden here, the sticky action value will be used instead
		   $q->input({-type=>'hidden', -name=>'action', -value=>'browse'}),
		   $q->input({-type=>'hidden', -name=>'diff', -value=>'1'}),
		   $q->input({-type=>'hidden', -name=>'id', -value=>$id})),
	     $q->table({-class=>'history'}, @html),
	     $q->p($q->submit({-name=>T('Compare')})), $q->end_form());
  }
  print $q->div({-class=>'content history'}, @html);
  PrintFooter($id, 'history');
}

sub GetHistoryLine {
  my ($id, $dataref, $row) = @_;
  my %data = %$dataref;
  my $revision = $data{revision};
  my $html;
  if (0 == $row) { # current revision
    $html .= GetPageLink($id, Ts('Revision %s', $revision));
  } else {
    $html .= GetOldPageLink('browse', $id, $revision, Ts('Revision %s', $revision));
  }
  $html .= T(' . . . . ') . TimeToText($data{ts}) . ' ';
  my $host = $data{host};
  $host = $data{ip} unless $host;
  $html .= T('by') . ' ' . GetAuthorLink($host, $data{username});
  $html .= ' ' . $q->strong('--', QuoteHtml($data{summary})) if $data{summary};
  $html .= ' ' . $q->i(T('(minor)')) . ' ' if $data{minor};
  if ($UseDiff) {
    my %attr1 = (-type=>'radio', -name=>'diffrevision', -value=>$revision);
    $attr1{-checked} = 'checked' if 1==$row;
    my %attr2 = (-type=>'radio', -name=>'revision', -value=>$revision);
    $attr2{-checked} = 'checked' if 0==$row;
    $html = $q->Tr($q->td($q->input(\%attr1)), $q->td($q->input(\%attr2)), $q->td($html));
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
  ReportError(T('Missing target for rollback.'), '400 BAD REQUEST') unless $to;
  ReportError(T('Target for rollback is too far back.'), '400 BAD REQUEST') unless RollbackPossible($to);
  RequestLockOrError();
  print $q->start_div({-class=>'content rollback'}) . $q->start_p();
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    my ($text, $minor) = GetTextAtTime($to);
    if ($text and $Page{text} ne $text) {
      Save($id, $text, Ts('Rollback to %s', TimeToText($to)), $minor, ($Page{ip} ne $ENV{REMOTE_ADDR}));
      print Ts('%s rolled back', $id), $q->br();
    }
  }
  print $q->end_p() . $q->end_div();
  ReleaseLock();
  PrintFooter();
}

# == HTML and page-oriented functions ==

sub GetPageParameters {
  my ($action, $id, $revision, $cluster) = @_;
  $id = FreeToNormal($id);
  my $link = "action=$action;id=" . UrlEncode($id);
  $link .= ";revision=$revision" if $revision;
  $link .= ';rcclusteronly=' . UrlEncode($cluster) if $cluster;
  return $link;
}

sub GetOldPageLink {
  my ($action, $id, $revision, $name, $cluster) = @_;
  $name =~ s/_/ /g if $FreeLinks;
  return ScriptLink(GetPageParameters($action, $id, $revision, $cluster), $name, 'revision');
}

sub GetSearchLink {
  my ($text, $class, $name, $title) = @_;
  my $id = UrlEncode($text);
  $name = UrlEncode($name);
  if ($FreeLinks) {
    $text =~ s/_/ /g;  # Display with spaces
    $id =~ s/_/+/g;    # Search for url-escaped spaces
  }
  return ScriptLink('search=' . $id, $text, $class, $name, $title);
}

sub ScriptLinkDiff {
  my ($diff, $id, $text, $new, $old) = @_;
  my $action = 'action=browse;diff=' . $diff . ';id=' . UrlEncode($id);
  $action .= ";diffrevision=$old"  if ($old and $old ne '');
  $action .= ";revision=$new"  if ($new and $new ne '');
  return ScriptLink($action, $text, 'diff');
}

sub GetAuthorLink {
  my ($host, $username) = @_;
  $username = FreeToNormal($username);
  my $name = $username;
  $name =~ s/_/ /g;
  if (ValidId($username) ne '') {  # Invalid under current rules
    $username = '';  # Just pretend it isn't there.
  }
  if ($username and $RecentLink) {
    return ScriptLink(UrlEncode($username), $name, 'author', undef, Ts('from %s', $host));
  } elsif ($username) {
    return $q->span({-class=>'author'}, $name) . ' ' . Ts('from %s', $host);
  }
  return $host;
}

sub GetHistoryLink {
  my ($id, $text) = @_;
  if ($FreeLinks) {
    $id =~ s/ /_/g;
  }
  return ScriptLink('action=history;id=' . UrlEncode($id), $text, 'history');
}

sub GetRCLink {
  my ($id, $text) = @_;
  if ($FreeLinks) {
    $id =~ s/ /_/g;
  }
  return ScriptLink('action=rc;all=1;from=1;showedit=1;rcidonly=' . UrlEncode($id), $text, 'rc');
}

sub GetHeader {
  my ($id, $title, $oldId, $nocache, $status) = @_;
  my $embed = GetParam('embed', $EmbedWiki);
  my $altText = T('[Home]');
  my $result = GetHttpHeader('text/html', $nocache ? $Now : 0, $status);
  $title =~ s/_/ /g;	 # Display as spaces
  if ($oldId ne '') {
    $Message .= $q->p('(' . Ts('redirected from %s', GetEditLink($oldId, $oldId)) . ')');
  }
  $result .= GetHtmlHeader("$SiteName: $title", $id);
  if ($embed) {
    $result .= $q->div({-class=>'header'}, $q->div({-class=>'message'}, $Message))  if $Message;
    return $result;
  }
  $result .= $q->start_div({-class=>'header'});
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
    $result .= $q->h1(GetSearchLink($id, '', '', T('Click to search for references to this page')));
  } else {
    $result .= $q->h1($title);
  }
  return $result . $q->end_div();
}

sub GetHttpHeader {
  return if $PrintedHeader;
  $PrintedHeader = 1;
  my ($type, $modified, $status) = @_;
  $modified = $LastUpdate unless $modified;
  my $time = $modified ? gmtime($modified) : gmtime;
  my %headers = (-cache_control=>($UseCache < 0 ? 'no-cache' : 'max-age=10'));
  $headers{-last_modified} = $time if GetParam('cache', $UseCache) >= 2;
  if ($HttpCharset ne '') {
    $headers{-type} = "$type; charset=$HttpCharset";
  } else {
    $headers{-type} = $type;
  }
  $headers{-status} = $status if $status;
  my $cookie = Cookie();
  $headers{-cookie} = $cookie  if $cookie;
  return $q->header(%headers);
}

sub Cookie {
  my ($changed, $visible, %params);
  foreach my $key (keys %CookieParameters) {
    my $default = $CookieParameters{$key};
    my $value = GetParam($key, $default);
    $params{$key} = $value  if $value ne $default;
    # The  cookie is  considered to  have changed  under  he following
    # condition: If the value was already set, and the new value is not
    # the same as the old value, or  if there was no old alue, and the
    # new value is not the default.
    my $change = (defined $OldCookie{$key} ? ($value ne $OldCookie{$key}) : ($value ne $default));
    $visible = 1 if $change and not $InvisibleCookieParameters{$key};
    $changed = 1 if $change; # note if any parameter changed and needs storing
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
      $html .= qq(<link type="text/css" rel="stylesheet" href="$sheet" />);
    }
  } elsif ($StyleSheet) {
    $html .= qq(<link type="text/css" rel="stylesheet" href="$StyleSheet" />);
  } elsif ($StyleSheetPage) {
    $html .= $q->style({-type=>'text/css'}, GetPageContent($StyleSheetPage));
  } else {
    $html .= $q->style({-type=>'text/css'}, "<!--$DefaultStyleSheet-->");
  }
  # INDEX,NOFOLLOW tag for wiki pages only so that the robot doesn't index
  # history pages.  INDEX,FOLLOW tag for RecentChanges and the index of all
  # pages.  We need the INDEX here so that the spider comes back to these
  # pages, since links from ordinary pages to RecentChanges or the index will
  # not be followed.
  if (($id eq $RCName) or (T($RCName) eq $id) or (T($id) eq $RCName)
      or (lc (GetParam('action', '')) eq 'index')) {
    $html .= '<meta name="robots" content="INDEX,FOLLOW" />';
  } elsif ($id eq '') {
    $html .= '<meta name="robots" content="NOINDEX,NOFOLLOW" />';
  } else {
    $html .= '<meta name="robots" content="INDEX,NOFOLLOW" />';
  }
  if (not $HtmlHeaders) {
    $html .= '<link rel="alternate" type="application/rss+xml" title="' . QuoteHtml($SiteName)
      . '" href="' . $ScriptName . '?action=rss" />';
    $html .= '<link rel="alternate" type="application/rss+xml" title="' . QuoteHtml("$SiteName: $id")
      . '" href="' . $ScriptName . '?action=rss;rcidonly=' . $id . '" />' if $id;
  }
  # finish
  $html = qq(<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n<html>)
    . $q->head($q->title($q->escapeHTML($title)) . $html . $HtmlHeaders)
    . '<body class="' . GetParam('theme', $ScriptName) . '">';
  return $html;
}

sub PrintFooter {
  my ($id, $rev, $comment) = @_;
  if (GetParam('embed', $EmbedWiki)) {
    print $q->end_html;
    return;
  }
  print GetCommentForm($id, $rev, $comment);
  print $q->start_div({-class=>'footer'}) . $q->hr();
  print GetGotoBar($id), GetFooterLinks($id, $rev);
  print GetAdminBar($id, $rev) if UserIsAdmin();
  print GetFooterTimestamp($id, $rev), GetSearchForm();
  if ($DataDir =~ m|/tmp/|) {
    print $q->p($q->strong(T('Warning') . ': ')
		. Ts('Database is stored in temporary directory %s', $DataDir));
  }
  print T($FooterNote) if $FooterNote;
  print $q->p(GetValidatorLink()) if GetParam('validate', $ValidatorLink);
  print $q->p(Ts('%s seconds', (time - $Now))) if GetParam('timing',0);
  print $q->end_div(), GetSisterSites($id), GetNearLinksUsed($id);
  eval { local $SIG{__DIE__}; PrintMyContent($id); };
  print $q->end_html;
}

sub GetSisterSites {
  my $id = shift;
  NearInit() unless $NearSiteInit;
  if ($id and $NearSource{$id}) {
    my $sistersites = T('The same page on other sites:') . $q->br();
    foreach my $site (@{$NearSource{$id}}) {
      my $logo = $SisterSiteLogoUrl;
      $logo =~ s/\%s/$site/g;
      $sistersites .= $q->a({-href=>GetInterSiteUrl($site, $id), -title=>"$site:$id"},
		     $q->img({-src=>$logo, -alt=>"$site:$id"}));
    }
    return $q->hr(), $q->div({-class=>'sister'}, $q->p($sistersites));
  }
  return '';
}

sub GetNearLinksUsed {
  if (%NearLinksUsed) {
    return $q->div({-class=>'near'}, $q->p(GetPageLink(T('EditNearLinks')) . ':',
					   map { GetEditLink($_, $_); } keys %NearLinksUsed));
  }
  return '';
}

sub GetFooterTimestamp {
  my ($id, $rev) = @_;
  if ($id and $rev ne 'history' and $rev ne 'edit' and $Page{revision}) {
    my @elements = ($q->br(), ($rev eq '' ? T('Last edited') : T('Edited')), TimeToText($Page{ts}),
		    Ts('by %s', GetAuthorLink($Page{host}, $Page{username})));
    push(@elements, ScriptLinkDiff(1, $id, T('(diff)'), $rev)) if $UseDiff;
    return $q->span({-class=>'time'}, @elements);
  }
  return '';
}

sub GetAdminBar {
  my ($id, $rev) = @_;
  my @elements = ($q->br(), ScriptLink('action=maintain', T('Run maintenance')));
  if (-f "$DataDir/noedit") {
    push(@elements, ScriptLink('action=editlock;set=0', T('Unlock site')));
  } else {
    push(@elements, ScriptLink('action=editlock;set=1', T('Lock site')));
  }
  if (-f GetLockedPageFile($id)) {
    push(@elements, ScriptLink('action=pagelock;set=0;id=' . UrlEncode($id), T('Unlock page')));
  } else {
    push(@elements, ScriptLink('action=pagelock;set=1;id=' . UrlEncode($id), T('Lock page')));
  }
  foreach my $page (@LockOnCreation) {
    push(@elements, GetPageLink($page)) if $page;
  }
  return $q->span({-class=>'admin bar'}, @elements) if @elements;
}

sub GetFooterLinks {
  my ($id, $rev) = @_;
  my @elements;
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    if ($CommentsPrefix) {
      if ($OpenPageName =~ /^$CommentsPrefix(.*)/) {
	push(@elements, GetPageLink($1));
      } else {
	push(@elements, GetPageLink($CommentsPrefix . $OpenPageName));
      }
    }
    if (UserCanEdit($id, 0)) {
      if ($rev) { # showing old revision
	push(@elements, GetOldPageLink('edit', $id, $rev,
				       Ts('Edit revision %s of this page', $rev)));
      } else { # showing current revision
	push(@elements, GetEditLink($id, T('Edit this page'), undef, T('e')));
      }
    } else { # no permission or generated page
      push(@elements, ScriptLink('action=password', T('This page is read-only')));
    }
  }
  if ($id and $rev ne 'history') {
    push(@elements, GetHistoryLink($id, T('View other revisions')));
  }
  if ($rev ne '') {
    push(@elements, GetPageLink($id, T('View current revision')),
	 GetRCLink($id, T('View all changes')));
  }
  return @elements ? $q->span({-class=>'edit bar'}, $q->br(), @elements) : '';
}

sub GetCommentForm {
  my ($id, $rev, $comment) = @_;
  if ($CommentsPrefix ne '' and $id and $rev ne 'history' and $rev ne 'edit'
      and $OpenPageName =~ /^$CommentsPrefix/) {
    return $q->div({-class=>'comment'}, GetFormStart(undef, undef, 'comment'),
		   $q->p(GetHiddenValue('title', $OpenPageName),
			 GetHiddenValue('summary' , T('new comment')),
			 GetTextArea('aftertext', $comment ? $comment : $NewComment)),
		   $q->p(T('Username:'), ' ',
			 $q->textfield(-name=>'username', -default=>GetParam('username', ''),
				       -override=>1, -size=>20, -maxlength=>50),
			 T('Homepage URL:'), ' ',
			 $q->textfield(-name=>'homepage', -default=>GetParam('homepage', ''),
				       -override=>1, -size=>40, -maxlength=>100)),
		   $q->p($q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save')), ' ',
			 $q->submit(-name=>'Preview', -value=>T('Preview'))),
		   $q->endform());
  }
  return '';
}

sub GetFormStart {
  my $encoding = (shift) ? 'multipart/form-data' : 'application/x-www-form-urlencoded';
  my $method = (shift) ? 'get' : 'post';
  my $class = (shift) || $method;
  return $q->start_form(-method=>$method, -action=>$FullUrl, -enctype=>$encoding);
}

sub GetSearchForm {
  my $form = T('Search:') . ' '
    . $q->textfield(-name=>'search', -size=>20, -accesskey=>T('f')) . ' ';
  if ($ReplaceForm) {
    $form .= T('Replace:') . ' '
      . $q->textfield(-name=>'replace', -size=>20) . ' ';
  }
  if (%Languages) {
    $form .= T('Language:') . ' '
      . $q->textfield(-name=>'lang', -size=>10, -default=>GetParam('lang', '')) . ' ';
  }
  return GetFormStart(0, 1, 'search') . $q->p($form . $q->submit('dosearch', T('Go!'))) . $q->endform;
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
  return $q->span({-class=>'gotobar bar'}, (map { GetPageLink($_) } @UserGotoBarPages), $UserGotoBar);
}

# == Difference markup and HTML ==

sub PrintHtmlDiff {
  my ($diffType, $revOld, $revNew, $newText) = @_;
  my ($diffText, $intro);
  if (not $revOld and GetParam('cache', $UseCache) < 1) {
    if ($diffType == 1) {
      $revOld = $Page{'diff-major'};
    } else {
      $revOld = $revNew - 1;
    }
  }
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
  return GetDiff($keep{text}, $newText, $oldRevision);
}

sub GetDiff {
  my ($old, $new, $oldRevision) = @_;
  $old =~ m/^#FILE ([^ \n]+)\n/;
  my $old_is_file = ($1 ? substr($1, 0, 6) : 0);
  my $old_is_image = ($old_is_file eq 'image/');
  $new =~ m/^#FILE ([^ \n]+)\n/;
  my $new_is_file = ($1 ? substr($1, 0, 6) : 0);
  my $new_is_image = ($new_is_file eq 'image/');
  if ($old_is_file or $new_is_file) {
    return $q->p($q->strong(T('Old revision:')))
      . $q->div({-class=>'old'}, # don't pring new revision, because that's the one that gets shown!
		$q->p($old_is_file ? GetDownloadLink($OpenPageName, $old_is_file, $oldRevision) : $old))
  }
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
  $diff_out =~ s/\\ No newline.*\n//g;	 # Get rid of common complaint.
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
      $header =~ s|^(\d+.*c.*)|<p><strong>$tChanged $1</strong></p>|g
      or $header =~ s|^(\d+.*d.*)|<p><strong>$tRemoved $1</strong></p>|g
      or $header =~ s|^(\d+.*a.*)|<p><strong>$tAdded $1</strong></p>|g;
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
  WriteStringToFile("$TempDir/a", join("\n",split(/\s+/,$old)) . "\n"); # avoid "No newline at end of file"
  WriteStringToFile("$TempDir/b", join("\n",split(/\s+/,$new)) . "\n");
  my $diff = `diff $TempDir/a $TempDir/b`;
  my $offset = 0; # for every chunk this increases
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
  return $q->div({-class=>$class},$q->p(join($q->br(), @lines)));
}

sub DiffHtmlMarkWords { # this code seems brittle and has been known to crash!
  my ($text,$start,$end) = @_;
  return $text if $end - $start > 50 or $end > 100; # don't mark long chunks to avoid crashing
  my $first = $start - 1;
  my $words = 1 + $end - $start;
  $text =~ s|^((\S+\s*){$first})((\S+\s*?){$words})|$1<strong class="changes">$3</strong>|;
  return $text;
}

# == Database functions ==

sub ParseData {
  my $data = shift;
  my %result;
  while ($data =~ /(\S+?): (.*?)(?=\n[^ \t]|\Z)/sg) {
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
    %Page = ();
    $Page{ts} = $Now;
    $Page{revision} = 0;
    if ($id eq $HomePage and (open(F,'README') or open(F,"$DataDir/README"))) {
      local $/ = undef;
      $Page{text} = <F>;
      close F;
    } elsif ($CommentsPrefix and $id =~ /^$CommentsPrefix(.*)/) { # do nothing
    } else {
      $Page{text} = $NewText;
    }
  }
  $OpenPageName = $id;
}

sub GetTextAtTime { # call with opened page
  my $ts = shift;
  my $minor = $Page{minor};
  return ($Page{text}, $minor) if $Page{ts} <= $ts; # current page is old enough
  return ($DeletedPage, $minor) if $Page{revision} == 1 and $Page{ts} > $ts; # created after $ts
  my %keep = (); # info may be needed after the loop
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    %keep = GetKeptRevision($revision);
    return ($keep{text}, $minor) if $keep{ts} <= $ts;
  }
  return ($DeletedPage, $minor) if $keep{revision} == 1; # then the page was created after $ts!
  return ($keep{text}, $minor);
}

sub GetTextRevision {
  my ($revision, $quiet) = @_;
  $revision =~ s/\D//g; # Remove non-numeric chars
  return ($Page{text}, $revision) unless $revision and $revision ne $Page{revision};
  my %keep = GetKeptRevision($revision);
  if (not %keep) {
    $Message .= $q->p(Ts('Revision %s not available', $revision)
		      . ' (' . T('showing current revision instead') . ')') unless $quiet;
    return ($Page{text}, '');
  }
  $Message .= $q->p(Ts('Showing revision %s', $revision)) unless $quiet;
  return ($keep{text}, $revision);
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
  return glob(GetKeepDir(shift) . '/*.kp'); # files such as 1.kp, 2.kp, etc.
}

sub GetKeepRevisions {
  return sort {$b <=> $a} map { m/([0-9]+)\.kp$/; $1; } GetKeepFiles(shift);
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
  ReportError(T('Cannot save a nameless page.'), '400 BAD REQUEST', 1) unless $OpenPageName;
  ReportError(T('Cannot save a page without revision.'), '400 BAD REQUEST', 1) unless $Page{revision};
  CreatePageDir($PageDir, $OpenPageName);
  WriteStringToFile(GetPageFile($OpenPageName), EncodePage(%Page));
}

sub SaveKeepFile {
  return if ($Page{revision} < 1);  # Don't keep 'empty' revision
  delete $Page{blocks}; # delete some info from the page
  delete $Page{flags};
  delete $Page{'diff-major'};
  delete $Page{'diff-minor'};
  $Page{'keep-ts'} = $Now; # expire only $KeepDays from $Now!
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

sub ExpireKeepFiles { # call with opened page
  return unless $KeepDays;
  my $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my %keep = GetKeptRevision($revision);
    next if $keep{'keep-ts'} >= $expirets;
    next if $KeepMajor && ($keep{revision} == $Page{oldmajor});
    unlink GetKeepFile($OpenPageName, $revision);
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
    ReportError(Ts('Cannot open %s', $fileName) . ": $!", '500 INTERNAL SERVER ERROR');
  }
  return $data;
}

sub WriteStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">$file")
    or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
  print OUT  $string;
  close(OUT);
}

sub AppendStringToFile {
  my ($file, $string) = @_;
  open (OUT, ">>$file")
    or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
  print OUT  $string;
  close(OUT);
}

sub CreateDir {
  my ($newdir) = @_;
  mkdir($newdir, 0775)	if (!(-d $newdir));
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
      ReportError(Ts('Could not get %s lock', $name) . ": $!\n", '503 SERVICE UNAVAILABLE');
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
  for my $lock (@KnownLocks) {
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
  return sprintf('%02d:%02d UTC', $hour, $min);
}

sub CalcTimeSince {
  my $total = shift;
  if	($total >= 7200) { return Ts('%s hours ago',int($total/3600)) }
  elsif ($total >= 3600) { return T('1 hour ago'); }
  elsif ($total >= 120)	 { return Ts('%s minutes ago',int($total/60)) }
  elsif ($total >= 60)	 { return T('1 minute ago'); }
  elsif ($total >= 2)	 { return Ts('%s seconds ago',int($total)) }
  elsif ($total == 1)	 { return T('1 second ago'); }
  else			 { return T('just now'); }
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

sub GetRemoteHost {               # when testing, these variables are undefined.
  my $rhost = $ENV{REMOTE_HOST};  # tests are written to avoid -w warnings.
  if (not $rhost and $UseLookup and $ENV{REMOTE_ADDR}) {
    # Catch errors (including bad input) without aborting the script
    eval 'use Socket; my $iaddr = inet_aton($ENV{REMOTE_ADDR});'
	 . '$rhost = gethostbyaddr($iaddr, AF_INET) if $iaddr;';
  }
  if (not $rhost) {
    $rhost = $ENV{REMOTE_ADDR};
  }
  return $rhost;
}

sub FreeToNormal { # trim all spaces and convert them to underlines
  my $id = shift;
  return '' unless $id;
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
  ValidIdOrDie($id);
  my $upload = GetParam('upload', undef);
  if (!UserCanEdit($id, 1)) {
    print GetHeader('', T('Editing Denied'), undef, undef, '403 FORBIDDEN');
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
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  OpenPage($id);
  my ($text, $revision) = GetTextRevision(GetParam('revision', ''), 1); # maybe revision reset!
  my $oldText = $preview ? $newText : $text;
  my $isFile = ($oldText =~ m/^#FILE ([^ \n]+)\n(.*)/s);
  $upload = $isFile if not defined $upload;
  if ($upload and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  if ($upload) { # shortcut lots of code
    $revision = '';
    $preview = 0;
  } elsif ($isFile and not $upload) {
    $oldText = '';
  }
  my $header;
  if ($revision and not $upload) {
    $header = Ts('Editing revision %s of', $revision) . ' ' . $id;
  } else {
    $header = Ts('Editing %s', $id);
  }
  print GetHeader('', QuoteHtml($header), ''), $q->start_div({-class=>'content edit'});;
  if ($preview and not $upload) {
    print $q->start_div({-class=>'preview'});
    print $q->h2(T('Preview:'));
    PrintWikiToHTML($oldText); # no caching, current revision, unlocked
    print $q->hr(), $q->h2(T('Preview only, not yet saved')), $q->end_div();
  }
  if ($revision) {
    print $q->strong(Ts('Editing old revision %s.', $revision) . '  '
		     . T('Saving this page will replace the latest revision with this text.'))
  }
  print GetFormStart($upload, undef, $upload ? 'edit upload' : 'edit text'),
    $q->p(GetHiddenValue("title", $id), ($revision ? GetHiddenValue('revision', $revision) : ''),
	  GetHiddenValue('oldtime', $Page{ts}),
	  ($upload ? GetUpload() : GetTextArea('text', $oldText)));
  my $summary = GetParam('summary', '');
  print $q->p(T('Summary:'), $q->textfield(-name=>'summary', -default=>$summary,
					   -override=>1, -size=>60));
  if (GetParam('recent_edit') eq 'on') {
    print $q->p($q->checkbox(-name=>'recent_edit', -checked=>1,
			     -label=>T('This change is a minor edit.')));
  } else {
    print $q->p($q->checkbox(-name=>'recent_edit',
			     -label=>T('This change is a minor edit.')));
  }
  print T($EditNote) if $EditNote; # Allow translation
  my $username = GetParam('username', '');
  print $q->p(T('Username:') . ' '
	      . $q->textfield(-name=>'username',
			      -default=>$username, -override=>1,
			      -size=>20, -maxlength=>50));
  print $q->p($q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save'))
	      . ($upload ? '' :	 ' ' . $q->submit(-name=>'Preview', -value=>T('Preview'))));
  if ($upload) {
    print $q->p(ScriptLink('action=edit;upload=0;id=' . UrlEncode($id), T('Replace this file with text.')));
  } elsif ($UploadAllowed or UserIsAdmin()) {
    print $q->p(ScriptLink('action=edit;upload=1;id=' . UrlEncode($id), T('Replace this text with a file.')));
  }
  print $q->endform(), $q->end_div();;
  PrintFooter($id, 'edit');
}

sub GetTextArea {
  my ($name, $text) = @_;
  return $q->textarea(-name=>$name, -default=>$text, -rows=>25, -columns=>78, -override=>1);
}

sub GetUpload {
  return T('File to upload: ') . $q->filefield(-name=>'file', -size=>50, -maxlength=>100);
}

sub DoDownload {
  my $id = shift;
  OpenPage($id) if ValidIdOrDie($id);
  if ($q->http('HTTP_IF_MODIFIED_SINCE') eq gmtime($Page{revision})
      and GetParam('cache', $UseCache) >= 2) {
    print $q->header(-status=>'304 NOT MODIFIED');
    return;
  }
  my ($text, $revision) = GetTextRevision(GetParam('revision', '')); # maybe revision reset!
  my $ts = $Page{ts};
  if ($text =~ /^#FILE ([^ \n]+)\n(.*)/s) {
    my ($type, $data) = ($1, $2);
    my $regexp = quotemeta($type);
    if (@UploadTypes and not grep(/^$regexp$/, @UploadTypes)) {
      ReportError(Ts('Files of type %s are not allowed.', $type), '415 UNSUPPORTED MEDIA TYPE');
    }
    print GetHttpHeader($type, $ts);
    require MIME::Base64;
    print MIME::Base64::decode($data);
  } else {
    print GetHttpHeader('text/plain', $ts);
    print $text;
  }
}

# == Passwords ==

sub DoPassword {
  print GetHeader('',T('Password'), ''), $q->start_div({-class=>'content password'});
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
    print GetFormStart(undef, undef, 'password'),
      $q->p(GetHiddenValue('action', 'password'), T('Password:'), ' ',
	    $q->password_field(-name=>'pwd', -size=>20, -maxlength=>50),
	    $q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save'))), $q->endform;
  } else {
    print $q->p(T('This site does not use admin or editor passwords.'));
  }
  print $q->end_div();
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
  UserIsAdmin()
    or ReportError(T('This operation is restricted to administrators only...'), '403 FORBIDDEN');
  return 1;
}

sub UserCanEdit {
  my ($id, $editing) = @_;
  return 1 if UserIsAdmin();
  return 0 if $id ne '' and -f GetLockedPageFile($id);
  return 0 if grep(/^$id$/, @LockOnCreation);
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
  return 1  if (UserIsAdmin());		# Admin includes editor
  return 0  if ($EditPass eq '');
  my $pwd = GetParam('pwd', '');	# Used for both
  return 0  if ($pwd eq '');
  foreach (split(/\s+/, $EditPass)) {
    next  if ($_ eq '');
    return 1  if ($pwd eq $_);
  }
  return 0;
}

sub BannedContent {
  my $str = shift;
  foreach (split(/\n/, GetPageContent($BannedContent))) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $rule = $1;
      if ($str =~ /($rule)/i) {
	my $match = $1;
	return Tss('Rule "%1" matched "%2" on this page.', $rule, $match);
      }
    }
  }
  return 0;
}

# == Index ==

sub DoIndex {
  my $raw = GetParam('raw', 0);
  my @pages;
  my $pages = GetParam('pages', 1);
  my $anchors = GetParam('permanentanchors', 1);
  my $near = GetParam('near', 0);
  if ($raw) {
    print GetHttpHeader('text/plain');
  } else {
    print GetHeader('', T('Index of all pages'), ''), $q->start_div({-class=>'content index'});
    my @for;
    push(@for, T('all pages')) if $pages;
    push(@for, T('permanent anchors')) if $anchors;
    push(@for, T('near links')) if $near;
    push(@for, GetParam('lang', '')) if GetParam('lang', '');
    print $q->p($q->b(Ts('(for %s)', join(', ', @for))));
  }
  ReadPermanentAnchors() if $anchors and not $PermanentAnchorsInit;
  NearInit() if $near and not $NearSiteInit;
  push(@pages, AllPagesList()) if $pages;
  push(@pages, keys %PermanentAnchors) if $anchors;
  push(@pages, keys %NearSource) if $near;
  @pages = sort @pages;
  print $q->h2(Ts('%s pages found.', ($#pages + 1))), $q->start_p() unless $raw;
  map { PrintPage($_); } @pages;
  print $q->end_p(), $q->end_div() unless $raw;
  PrintFooter() unless $raw;
}

sub PrintPage {
  my $id = shift;
  my $lang = GetParam('lang', 0);
  if ($lang) {
    OpenPage($id);
    my @languages = split(/,/, $Page{languages});
    next if (@languages and not grep(/$lang/, @languages));
  }
  if (GetParam('raw', 0)) {
    if (GetParam('search', '') and GetParam('context',1)) {
      print "title: $id\n\n"; # for near links without full search
    } else {
      print $id, "\n";
    }
  } else {
    my $title = $id;
    $title =~ s/_/ /g;
    print GetPageOrEditLink($id, $title), $q->br();
  }
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
  foreach (glob("$PageDir/*/*.pg $PageDir/*/.*.pg")) { # find .dotfiles, too
    next unless m|/.*/(.+)\.pg$|;
    push(@IndexList, $1);
    $IndexHash{$1} = 1;
  }
  $IndexInit = 1;  # Initialized for this run of the script
  # Try to write out the list for future runs.  If file exists and cannot be changed, error!
  RequestLockDir('index', undef, undef, -f $IndexFile) or return @IndexList;
  WriteStringToFile($IndexFile, join(' ', %IndexHash));
  ReleaseLockDir('index');
  return @IndexList;
}

# == Searching ==

sub DoSearch {
  my $string = shift;
  my $replacement = GetParam('replace','');
  my $raw = GetParam('raw','');
  if ($string eq '') {
    DoIndex();
    return;
  }
  if ($replacement) {
    print GetHeader('', QuoteHtml(Ts('Replaced: %s', "$string -> $replacement")), ''),
      $q->start_div({-class=>'content replacement'});
    return  if (!UserIsAdminOrError());
    Replace($string,$replacement);
    $string = $replacement;
  } elsif ($raw) {
    print GetHttpHeader('text/plain');
    print RcTextItem('title', Ts('Search for: %s', $string)), RcTextItem('date', TimeToText($Now)),
      RcTextItem('link', $q->url(-path_info=>1, -query=>1)), "\n" if GetParam('context',1);
  } else {
    print GetHeader('', QuoteHtml(Ts('Search for: %s', $string)), ''),
      $q->start_div({-class=>'content search'});
    $ReplaceForm = UserIsAdmin();
    NearInit();
    my @elements = (ScriptLink('action=rc;rcfilteronly=' . UrlEncode($string),
			       T('View changes for these pages')));
    push(@elements, ScriptLink('near=2;search=' . UrlEncode($string),
				Ts('Search sites on the %s as well', $NearMap)))
      if %NearSearch and GetParam('near', 1) < 2;
    print $q->p(@elements);
  }
  my @results;
  if (GetParam('context',1)) {
    @results = SearchTitleAndBody($string, \&PrintSearchResult, HighlightRegex($string));
  } else {
    @results = SearchTitleAndBody($string, \&PrintPage);
  }
  @results = SearchNearPages($string, @results) if GetParam('near', 1); # adds more
  if (not $raw) {
    print $q->p(Ts('%s pages found.', ($#results + 1))), $q->end_div();
    PrintFooter();
  }
}

sub SearchTitleAndBody {
  my ($string, $func, @args) = @_;
  my @found;
  my $lang = GetParam('lang', '');
  foreach my $name (AllPagesList()) {
    OpenPage($name);
    next if ($Page{text} =~ /^#FILE / and $string !~ /^\^#FILE/); # skip files unless requested
    if ($lang) {
      my @languages = split(/,/, $Page{languages});
      next if (@languages and not grep(/$lang/, @languages));
    }
    my $freeName = $name;
    $freeName =~ s/_/ /g;
    if (SearchString($string, $Page{text}) or SearchString($string, $freeName)) {
      push(@found, $name);
      &$func($name, @args) if $func;
    }
  }
  return @found;
}

sub SearchString {
  my ($string, $data) = @_;
  my $and = T('and');
  my $or = T('or');
  my @strings = split(/ +$and +/, $string);
  foreach my $str (@strings) {
    my @temp = split(/ +$or +/, $str);
    $str = join('|', @temp);
    return 0 unless ($data =~ /$str/i);
  }
  return 1;
}

sub HighlightRegex {
  my $and = T('and');
  my $or = T('or');
  return join('|', split(/ +(?:$and|$or) +/, shift));
}

sub SearchNearPages {
  my $string = shift;
  my %found;
  foreach (@_) { $found{$_} = 1; }; # to avoid using grep on the list
  my $regex = HighlightRegex($string);
  NearInit();
  if (%NearSearch and GetParam('near', 1) > 1 and GetParam('context',1)) {
    foreach my $site (keys %NearSearch) {
      my $url = $NearSearch{$site};
      $url =~ s/\%s/UrlEncode($string)/ge or $url .= UrlEncode($string);
      print $q->hr(), $q->p(Ts('Fetching results from %s:', $q->a({-href=>$url}, $site)))
	unless GetParam('raw', 0);
      my $data = GetRaw($url);
      my @entries = split(/\n\n+/, $data);
      shift @entries; # skip head
      foreach my $entry (@entries) {
	my %entry = ParseData($entry); # need to pass reference
	my $name = $entry{title};
	next if $found{$name}; # do not duplicate local pages
	$found{$name} = 1;
	PrintSearchResultEntry(\%entry, $regex); # with context and full search!
      }
    }
  }
  if (%NearSource and (GetParam('near', 1) or GetParam('context',1) == 0)) {
    my $intro = 0;
    foreach my $name (sort keys %NearSource) {
      next if $found{$name}; # do not duplicate local pages
      my $freeName = $name;
      $freeName =~ s/_/ /g;
      if (SearchString($string, $freeName)) {
	$found{$name} = 1;
	print $q->hr() . $q->p(T('Near pages:')) unless GetParam('raw', 0) or $intro;
	$intro = 1;
	PrintPage($name); # without context!
      }
    }
  }
  return keys(%found);
}

sub PrintSearchResult {
  my ($name, $regex) = @_;
  my $raw = GetParam('raw', 0);
  my $files = ($regex =~ /^\^#FILE/); # usually skip files
  OpenPage($name); # should be open already, just making sure!
  my $pageText = $Page{text};
  my %entry;
  #  get the page, filter it, remove all tags
  $pageText =~ s/$FS//g;	# Remove separators (paranoia)
  $pageText =~ s/[\s]+/ /g;	#  Shrink whitespace
  $pageText =~ s/([-_=\\*\\.]){10,}/$1$1$1$1$1/g ; # e.g. shrink "----------"
  $entry{title} = $name;
  if ($files) {
    $pageText =~ /^#FILE ([^ ]+)/;
    $entry{description} = $1;
  } else {
    $entry{description} = SearchExtract(QuoteHtml($pageText), $regex);
  }
  $entry{size} = int((length($pageText)/1024)+1) . 'K';
  $entry{'last-modified'} = TimeToText($Page{ts});
  $entry{username} = $Page{username};
  $entry{host} = $Page{host};
  PrintSearchResultEntry(\%entry, $regex);
}

sub PrintSearchResultEntry {
  my %entry = %{(shift)}; # get value from reference
  my $regex = shift;
  if (GetParam('raw', 0)) {
    $entry{generator} = $entry{username} . ' ' if $entry{username};
    $entry{generator} .= Ts('from %s', $entry{host}) if $entry{host};
    foreach my $key (qw(title description size last-modified generator username host)) {
      print RcTextItem($key, $entry{$key});
    }
    print RcTextItem('link', "$ScriptName?$entry{title}"), "\n";
  } else {
    my $author = GetAuthorLink($entry{host}, $entry{username});
    $author = $entry{generator} unless $author;
    my $id = $entry{title};
    my ($class, $resolved, $title, $exists) = ResolveId($id);
    my $text = $id;
    $text =~ s/_/ /g;
    my $action = UrlEncode($resolved); # watch out when passing this on!
    $action = 'action=browse;id=' . $action if $action =~ /\%2f/;
    my $result = $q->span({-class=>'result'}, ScriptLink($action, $text, $class, undef, $title));
    my $description = $entry{description};
    $description = $q->br() . SearchHighlight($description, $regex) if $description;
    my $info = $entry{size};
    $info .= ' - ' if $info;
    $info .= T('last updated') . ' ' . $entry{'last-modified'} if $entry{'last-modified'};
    $info .= ' ' . T('by') . ' ' . $author if $author;
    $info = $q->br() . $q->span({-class=>'info'}, $info) if $info;
    print $q->p($result, $description, $info);
  }
}

sub SearchHighlight {
  my ($data, $regex) = @_;
  $data =~ s/($regex)/<strong>$1<\/strong>/gi;
  return $data;
}

sub SearchExtract {
  my ($data, $string) = @_;
  my ($snippetlen, $maxsnippets) = (100, 4) ; #	 these seem nice.
  # show a snippet from the beginning of the document
  my $j = index($data, ' ', $snippetlen); # end on word boundary
  my $t = substr($data, 0, $j);
  my $result = $t . ' . . .';
  $data = substr($data, $j); # to avoid rematching
  my $jsnippet = 0 ;
  while ($jsnippet < $maxsnippets && $data =~ m/($string)/i) {
    $jsnippet++;
    if (($j = index($data, $1)) > -1 ) {
      # get substr containing (start of) match, ending on word boundaries
      my $start = index($data, ' ', $j-($snippetlen/2));
      $start = 0 if ($start == -1);
      my $end = index($data, ' ', $j+($snippetlen/2));
      $end = length($data ) if ($end == -1);
      $t = substr($data, $start, $end-$start);
      $result .= $t . ' . . .';
      # truncate text to avoid rematching the same string.
      $data = substr($data, $end);
    }
  }
  return $result;
}

sub Replace {
  my ($from, $to) = @_;
  my $lang = GetParam('lang', '');
  RequestLockOrError(); # fatal
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    if ($lang) {
      my @languages = split(/,/, $Page{languages});
      next if (@languages and not grep(/$lang/, @languages));
    }
    $_ = $Page{text};
    if (eval "s/$from/$to/gi") { # allows use of backreferences
      Save($id, $_, $from . ' -> ' . $to, 1,
	   ($Page{ip} ne $ENV{REMOTE_ADDR}));
    }
  }
  ReleaseLock();
}

# == Monolithic output ==

sub DoPrintAllPages {
  return  if (!UserIsAdminOrError());
  $Monolithic = 1; # changes how ScriptLink works
  print GetHeader('', T('Complete Content'), '')
    . $q->p(Ts('The main page is %s.', $q->a({-href=>'#' . $HomePage}, $HomePage)));
  print $q->p($q->b(Ts('(for %s)', GetParam('lang', 0)))) if GetParam('lang', 0);
  PrintAllPages(0, 0, AllPagesList());
  PrintFooter();
}

sub PrintAllPages {
  my $links = shift;
  my $comments = shift;
  my $lang = GetParam('lang', 0);
  for my $id (@_) {
    OpenPage($id);
    my @languages = split(/,/, $Page{languages});
    @languages = GetLanguages($Page{text}) unless GetParam('cache', $UseCache); # maybe refresh!
    next if $lang and @languages and not grep(/$lang/, @languages);
    my $title = $id;
    $title =~ s/_/ /g;	 # Display as spaces
    print $q->start_div({-class=>'page'}) . $q->hr
      . $q->h1($links ? GetPageLink($id, $title) : $q->a({-name=>$id},$title));
    PrintPageHtml();
    if ($comments and UserCanEdit($CommentsPrefix . $id, 0) and $id !~ /^$CommentsPrefix/) {
      print $q->p({-class=>'comment'},
		  GetPageLink($CommentsPrefix . $id, T('Comments on this page')));
    }
    print $q->end_div();;
  }
}

# == Posting new pages ==

sub DoPost {
  my $id = FreeToNormal(shift);
  ValidIdOrDie($id);
  if (!UserCanEdit($id, 1)) {
    ReportError(Ts('Editing not allowed for %s.', $id), '403 FORBIDDEN');
  } elsif (($id eq 'SampleUndefinedPage') or ($id eq T('SampleUndefinedPage'))) {
    ReportError(Ts('%s cannot be defined.', $id), '403 FORBIDDEN');
  } elsif (($id eq 'Sample_Undefined_Page') or ($id eq T('Sample_Undefined_Page'))) {
    ReportError(Ts('[[%s]] cannot be defined.', $id), '403 FORBIDDEN');
  } elsif (grep(/^$id$/, @LockOnCreation) and !UserIsAdmin() and not -f GetPageFile($id)) {
    ReportError(Ts('Only an administrator can create %s.', $id), '403 FORBIDDEN');
  }
  my $filename = GetParam('file', undef);
  if ($filename and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  # Lock before getting old page to prevent races
  RequestLockOrError(); # fatal
  OpenPage($id);
  my $old = $Page{text};
  $_ = GetParam('text', undef);
  foreach my $macro (@MyMacros) { &$macro; }
  my $string = $_;
  my $comment = GetParam('aftertext', undef);
  # Upload file
  if ($filename) {
    require MIME::Base64;
    my $file = $q->upload('file');
    if (not $file and $q->cgi_error) {
      ReportError(Ts('Transfer Error: %s', $q->cgi_error), '500 INTERNAL SERVER ERROR');
    }
    ReportError(T('Browser reports no file info.'), '500 INTERNAL SERVER ERROR')
      unless $q->uploadInfo($filename);
    my $type = $q->uploadInfo($filename)->{'Content-Type'};
    my $regexp = quotemeta($type);
    ReportError(T('Browser reports no file type.'), '415 UNSUPPORTED MEDIA TYPE') unless $type;
    if (@UploadTypes and not grep(/^$regexp$/, @UploadTypes)) {
      ReportError(Ts('Files of type %s are not allowed.', $type), '415 UNSUPPORTED MEDIA TYPE');
    }
    local $/ = undef;	# Read complete files
    eval { $_ = MIME::Base64::encode(<$file>) };
    $string = '#FILE ' . $type . "\n" . $_;
  } else {
    $string = AddComment($old, $comment) if $comment;
    $string =~ s/^$DeletedPage// if $comment;
    # Massage the string
    $string =~ s/\r//g;
    $string .= "\n"  if ($string !~ /\n$/);
    $string =~ s/$FS//g;
  }
  # Banned Content
  if (not UserIsEditor()) {
    my $rule = BannedContent($string);
    if ($rule) {
      print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
      print $q->p(T('The page contains banned text.'));
      print $q->p(T('Contact the wiki administrator for more information.'));
      print $q->p($rule . ' ' . Ts('See %s for more information.', GetPageLink($BannedContent)));
      ReleaseLock();
      return;
    }
  }
  my $summary = GetParam('summary', '');
  $summary =~ s/$FS//g;
  $summary =~ s/[\r\n]+/ /g;
  # rebrowse if no changes
  my $oldrev = $Page{revision};
  if (GetParam('Preview', '')) {
    ReleaseLock();
    if ($comment) {
      BrowsePage($id, 0, $comment);
    } else {
      DoEdit($id, $string, 1);
    }
    return;
  } elsif (($old eq $string) or ($oldrev == 0 and $string eq $NewText)) {
    ReleaseLock(); # No changes -- just show the same page again
    ReBrowsePage($id);
    return;
  }
  my $newAuthor = 0;
  if ($oldrev) { # the first author (no old revision) is not considered to be "new"
    if (GetParam('username', '')) { # prefer usernames for potential new author detection
      $newAuthor = 1 if GetParam('username', '') ne $Page{username};
    } elsif ($ENV{REMOTE_ADDR} ne $Page{ip}) {
      $newAuthor = 1;
    }
  }
  my $oldtime = $Page{ts};
  my $myoldtime = GetParam('oldtime', ''); # maybe empty!
  # Handle raw edits with the meta info on the first line
  if (GetParam('raw',0) == 2 and $string =~ /^([0-9]+).*\n((.*\n)*.*)/) {
    $myoldtime = $1;
    $string = $2;
  }
  my $generalwarning = 0;
  if ($newAuthor and $oldtime ne $myoldtime and not $comment) {
    if ($myoldtime) {
      my ($ancestor, $minor) = GetTextAtTime($myoldtime);
      if ($ancestor and $old ne $ancestor) {
	my $new = MergeRevisions($string, $ancestor, $old);
	if ($new) {
	  $string = $new;
	  if ($new =~ /^<<<<<<</m and $new =~ /^>>>>>>>/m) {
	    SetParam('msg', Ts('This page was changed by somebody else %s.',
			       CalcTimeSince($Now - $Page{ts}))
		     . ' ' . T('The changes conflict.  Please check the page again.'));
	  } # else no conflict
	} else { $generalwarning = 1; } # else merge revision didn't work
      } # else nobody changed the page in the mean time (same text)
    } else { $generalwarning = 1; } # no way to be sure since myoldtime is missing
  } # same author or nobody changed the page in the mean time (same timestamp)
  if ($generalwarning and ($Now - $Page{ts}) < 600) {
    SetParam('msg', Ts('This page was changed by somebody else %s.',
		       CalcTimeSince($Now - $Page{ts}))
	     . ' ' . T('Please check whether you overwrote those changes.'));
  }
  Save($id, $string, $summary, (GetParam('recent_edit', '') eq 'on'), $filename);
  ReleaseLock();
  DeletePermanentAnchors();
  ReBrowsePage($id);
}

sub AddComment {
  my ($old, $comment) = @_;
  my $string = $old;
  $comment =~ s/\r//g;	# Remove "\r"-s (0x0d) from the string
  $comment =~ s/\s+$//g;    # Remove whitespace at the end
  if ($comment ne '' and $comment ne $NewComment) {
    my $author = GetParam('username', T('Anonymous'));
    my $homepage = GetParam('homepage', '');
    $homepage = 'http://' . $homepage if $homepage and not substr($homepage,0,7) eq 'http://';
    $author = "[$homepage $author]" if $homepage;
    $string .= "\n----\n\n" if $string and $string ne "\n";
    $string .= $comment . "\n\n-- " . $author . ' ' . TimeToText($Now) . "\n\n";
  }
  return $string;
}

sub Save { # call within lock, with opened page
  my ($id, $new, $summary, $minor, $upload) = @_;
  my $old = $Page{text}; # copy before it gets encoded
  my $user = GetParam('username', '');
  my $host = GetRemoteHost();
  my $revision = $Page{revision} + 1;
  if ($revision == 1 and -e $IndexFile and not unlink($IndexFile)) { # regenerate index on next request
    SetParam('msg', Ts('Cannot delete the index file %s.', $IndexFile)
	     . ' ' . T('Please check the directory permissions.')
	     . ' ' . T('Your changes were not saved.'));
    return;
  } else {
    utime time, time, $IndexFile; # touch index file
  }
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
  my $languages;
  $languages = GetLanguages($new) unless $upload;
  $Page{languages} = $languages;
  SavePage();
  if ($revision == 1 and grep(/^$id$/, @LockOnCreation)) {
    WriteStringToFile(GetLockedPageFile($id), 'editing locked.');
  }
  WriteRcLog($id, $summary, $minor, $revision, $user, $host, $languages, GetCluster($new));
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
  return join(',', @result);
}

sub GetCluster {
  $_ = shift;
  return '' unless $PageCluster;
  return $1 if ($WikiLinks && /^$LinkPattern\n/)
            or ($FreeLinks && /^\[\[$FreeLinkPattern\]\]\n/);
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
  ReleaseLockDir('merge'); # don't unlink temp files--next merge will just overwrite.
  return $output;
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
  my ($id, $summary, $minor, $revision, $username, $host, $languages, $cluster) = @_;
  my $rc_line = join($FS, $Now, $id, $minor, $summary, $host,
		     $username, $revision, $languages, $cluster);
  AppendStringToFile($RcFile, $rc_line . "\n");
}

sub UpdateDiffs {
  my ($id, $old, $new, $minor) = @_;
  my $editDiff	= GetDiff($old, $new);
  $Page{'diff-minor'} = $editDiff;
  if ($minor and $Page{oldmajor}) {
    $Page{'diff-major'} = GetKeptDiff($new, $Page{oldmajor});
  } else {
    $Page{'diff-major'} = '1'; # special value, used in GetCacheDiff
  }
}

# == Maintenance ==

sub DoMaintain {
  print GetHeader('', T('Maintenance on all pages'), ''), $q->start_div({-class=>'content maintain'});
  my $fname = "$DataDir/maintain";
  if (!UserIsAdmin()) {
    if ((-f $fname) && ((-M $fname) < 0.5)) {
      print $q->p(T('Maintenance not done.') . ' '
		  . T('(Maintenance can only be done once every 12 hours.)')
		  . ' ', T('Remove the "maintain" file or wait.')), $q->end_div();
      PrintFooter();
      return;
    }
  }
  RequestLockOrError();
  print $q->p(T('Main lock obtained.'));
  print '<p>', T('Expiring keep files and deleting pages marked for deletion');
  # Expire all keep files
  foreach my $name (AllPagesList()) {
    print $q->br();
    print GetPageLink($name);
    OpenPage($name);
    my $delete = PageDeletable($name);
    if ($delete) {
      my $status = DeletePage($OpenPageName);
      if ($status) {
	print ' ' . T('not deleted: ') . $status;
      } else {
	print ' ' . T('deleted');
      }
    } else {
      ExpireKeepFiles();
      ReadReferers($OpenPageName); # clean up even if disabled
      WriteReferers($OpenPageName);
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
  NearInit() unless $NearSiteInit;
  if (%NearSite) {
    CreateDir($NearDir);
    foreach my $site (keys %NearSite) {
      print $q->p(Ts('Getting page index file for %s.', $site));
      my $data = GetRaw($NearSite{$site});
      print $q->p($q->strong(Ts('%s returned no data, or LWP::UserAgent is not available.',
				$q->a({-href=>$NearSite{$site}}, $NearSite{$site})))) unless $data;
      WriteStringToFile("$NearDir/$site", $data);
    }
  }
  WriteStringToFile($fname, 'Maintenance done at ' . TimeToText($Now));
  ReleaseLock();
  print $q->p(T('Main lock released.')), $q->end_div();
  PrintFooter();
}

# == Deleting pages ==

sub PageDeletable {
  return unless $KeepDays;
  my $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return 0 unless $Page{ts} < $expirets;
  return $DeletedPage && $Page{text} =~ /^\s*$DeletedPage\b/o;
}

sub DeletePage { # Delete must be done inside locks.
  my $id = shift;
  my $status = ValidId($id);
  return $status if $status;
  foreach my $fname (GetPageFile($id), GetKeepFiles($id), GetKeepDir($id),
		     GetRefererFile($id), $IndexFile) {
    unlink($fname) if (-f $fname);
  }
  DeletePermanentAnchors();
  return '';
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
  print GetHeader('', T('Displaying Wiki Version'), ''), $q->start_div({-class=>'content version'});
  print $WikiDescription;
  if (GetParam('dependencies', 0)) {
    print $q->p($q->server_software()),
      $q->p(sprintf('Perl v%vd', $^V)),
      $q->p('CGI: ', $CGI::VERSION),
      $q->p('LWP::UserAgent ', eval { local $SIG{__DIE__}; require LWP::UserAgent; $LWP::UserAgent::VERSION; }),
      $q->p('XML::RSS: ', eval { local $SIG{__DIE__}; require XML::RSS; $XML::RSS::VERSION; }),
      $q->p('XML::Parser: ', eval { local $SIG{__DIE__}; $XML::Parser::VERSION; }),
      $q->p('diff: ' . (`diff --version` || $!)),
      $q->p('diff3: ' . (`diff3 --version` || $!));
  } else {
    print $q->p(ScriptLink('action=version;dependencies=1', T('Show dependencies')));
  }
  if (GetParam('links', 0)) {
    NearInit() unless $NearSiteInit;
    print $q->h2(T('Inter links:')), $q->p(join(', ', sort keys %InterSite));
    print $q->h2(T('Near links:')),
      $q->p(join($q->br(), map { $_ . ': ' . join(', ', @{$NearSource{$_}})}
		 sort keys %NearSource));
  } else {
    print $q->p(ScriptLink('action=version;links=1', T('Show parsed link data')));
  }
  print $q->end_div();
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
	  ReportError(Ts('Too many connections by %s',$name)
		      . ': ' . Tss('Please do not fetch more than %1 pages in %2 seconds.',
				   $SurgeProtectionViews, $SurgeProtectionTime),
		      '503 SERVICE UNAVAILABLE');
	}
      } elsif ($SurgeProtection and GetParam('action', '') ne 'unlock') {
	ReportError(Ts('Could not get %s lock', 'visitors')
		    . ': ' . Ts('Check whether the web server can create the directory %s and whether it can create files in it.', $TempDir), '503 SERVICE UNAVAILABLE');
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

sub DoShowVisitors { # no caching of this page!
  print GetHeader('', T('Recent Visitors'), '', 1), $q->start_div({-class=>'content visitors'});
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
  print '</ul>' . $q->end_div();
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
  my $result = join(' ', map {
    my $title = QuoteHtml($_);
    $title =~ s/\%([0-9a-f][0-9a-f])/chr(hex($1))/egi;
    $q->a({-href=>$_}, $title); } keys %Referers);
  return $q->div({-class=>'refer'}, $q->hr(), $q->p(T('Referrers') . ': ' . $result)) if $result;
}

sub UpdateReferers {
  my $self = $ScriptName;
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
  WriteReferers($id) if UpdateReferers($id);
  return GetReferers();
}

sub DoPrintAllReferers {
  print GetHeader('', T('All Referrers'), ''), $q->start_div({-class=>'content refer'});
  PrintAllReferers(AllPagesList());
  print $q->end_div();
  PrintFooter();
}

sub PrintAllReferers {
  for my $id (@_) {
    ReadReferers($id);
    print $q->p(ScriptLink(UrlEncode($id),$id)), GetReferers() if %Referers;
  }
}

# == Permanent Anchors ==

sub ReadPermanentAnchors {
  $PermanentAnchorsInit = 1;
  my ($status, $data) = ReadFile($PermanentAnchorsFile);
  return unless $status; # not fatal
  %PermanentAnchors = split(/\n| |$FS/,$data); # FIXME: $FS was used in 1.417 and earlier
}

sub WritePermanentAnchors {
  my $data = '';
  foreach my $name (keys %PermanentAnchors) {
    $data .= $name . ' ' . $PermanentAnchors{$name} ."\n";
  }
  WriteStringToFile($PermanentAnchorsFile, $data);
}

sub GetPermanentAnchor {
  my $id = FreeToNormal(shift);
  my $text = $id;
  $text =~ s/_/ /g;
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if ($class eq 'alias' and $title ne $OpenPageName) {
    return '[' . Ts('anchor first defined here: %s',
		    ScriptLink(UrlEncode($resolved), $text, 'alias')) . ']';
  } elsif ($PermanentAnchors{$id} ne $OpenPageName
	   and RequestLockDir('permanentanchors')) { # not fatal
    $PermanentAnchors{$id} = $OpenPageName;
    WritePermanentAnchors();
    ReleaseLockDir('permanentanchors');
  }
  $PagePermanentAnchors{$id} = 1; # add to the list of anchors in page
  my $html = GetSearchLink($id, 'definition', $id,
			   T('Click to search for references to this permanent anchor'));
  $html .= ' [' . Ts('the page %s also exists', ScriptLink("action=browse;anchor=0;id="
    . UrlEncode($id), $id, 'local')) . ']' if $exists;
  return $html;
}

sub DeletePermanentAnchors {
  ReadPermanentAnchors() unless $PermanentAnchorsInit;
  foreach (keys %PermanentAnchors) {
    if ($PermanentAnchors{$_} eq $OpenPageName and !$PagePermanentAnchors{$_}) {
      delete($PermanentAnchors{$_}) ;
    }
  }
  return unless RequestLockDir('permanentanchors'); # not fatal
  WritePermanentAnchors();
  ReleaseLockDir('permanentanchors');
}

DoWikiRequest()	 if $RunCGI;   # Do everything.
1; # In case we are loaded from elsewhere
