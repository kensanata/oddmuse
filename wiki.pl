#! /usr/bin/env perl
# Copyright (C) 2001-2023
#     Alex Schroeder <alex@gnu.org>
# Copyright (C) 2014-2015
#     Alex Jakimenko <alex.jakimenko@gmail.com>
# Copyleft      2008 Brian Curry <http://www.raiazome.com>
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

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;
use strict;
use warnings;
no warnings 'numeric';
no warnings 'uninitialized';
use utf8; # in case anybody ever adds UTF8 characters to the source
use B;
use CGI qw/-utf8/;
use CGI::Carp qw(fatalsToBrowser);
use File::Glob ':glob';
use List::Util qw(all max);
use Encode qw(encode_utf8 decode_utf8);
use sigtrap 'handler' => \&HandleSignals, 'normal-signals', 'error-signals';
local $| = 1; # Do not buffer output (localized for mod_perl)

# Options:
our ($ScriptName, $FullUrl, $PageDir, $TempDir, $LockDir, $KeepDir, $RssDir,
     $RcFile, $RcOldFile, $IndexFile, $NoEditFile, $VisitorFile, $DeleteFile, $RssLicense,
     $FreeLinkPattern, $LinkPattern, $FreeInterLinkPattern, $InterLinkPattern,
     $UrlPattern, $FullUrlPattern, $InterSitePattern,
     $UrlProtocols, $ImageExtensions, $LastUpdate,
     %LockOnCreation, %PlainTextPages, %AdminPages,
     @MyAdminCode, @MyFormChanges, @MyInitVariables, @MyMacros, @MyMaintenance,
     $DocumentHeader, %HtmlEnvironmentContainers, $FS, $Counter, @Debugging);

# Internal variables:
our ($q, $bol, $OpenPageName, %Page, %Translate, %IndexHash, @IndexList,
     @HtmlStack, @HtmlAttrStack, @Blocks, @Flags,
     %Includes, $FootnoteNumber, $CollectingJournal, $HeaderIsPrinted,
     %Locks, $Fragment, $Today, $ModulesDescription, %RssInterwikiTranslate,
     $Message, $Now, %RecentVisitors, %MyInc, $WikiDescription, %InterSite, %OldCookie);

# Can be set outside the script: $DataDir, $UseConfig, $ConfigFile, $ModuleDir,
# $ConfigPage, $AdminPass, $EditPass, $ScriptName, $FullUrl, $RunCGI.

# 1 = load config file in the data directory
our $UseConfig //= 1;

# Main wiki directory
our $DataDir;
$DataDir    ||= decode_utf8($ENV{WikiDataDir}) if $UseConfig;
$DataDir    ||= '/tmp/oddmuse'; # FIXME: /var/opt/oddmuse/wiki ?
$DataDir    = "./$DataDir" unless $DataDir =~ m!^(/|\./)!;

our $ConfigFile;
$ConfigFile ||= $ENV{WikiConfigFile} if $UseConfig;
our $ModuleDir;
$ModuleDir  ||= $ENV{WikiModuleDir} if $UseConfig;

our $ConfigPage ||= '';

# 1 = Run script as CGI instead of loading as module
our $RunCGI    //= 1;

# 1 = allow page views using wiki.pl/PageName
our $UsePathInfo = 1;

# -1 = disabled, 0 = 10s; 1 = partial HTML cache; 2 = HTTP/1.1 caching
our $UseCache    = 2;

our $SiteName    = 'Wiki';          # Name of site (used for titles)
our $HomePage    = 'HomePage';      # Home page
our $CookieName  = 'Wiki';          # Name for this wiki (for multi-wiki sites)

our $MaxPost     = 1024 * 210;      # Maximum 210K posts (about 200K for pages)
our $StyleSheet  = '';              # URL for CSS stylesheet (like '/wiki.css')
our $StyleSheetPage = '';           # Page for CSS sheet
our $LogoUrl     = '';              # URL for site logo ('' for no logo)
our $NotFoundPg  = '';              # Page for not-found links ('' for blank pg)

our $EditAllowed = 1;               # 0 = no, 1 = yes, 2 = comments pages only, 3 = comments only
our $AdminPass //= '';              # Whitespace separated passwords.
our $EditPass  //= '';              # Whitespace separated passwords.
our $PassHashFunction //= '';       # Name of the function to create hashes
our $PassSalt  //= '';              # Salt will be added to any password before hashing

our $BannedHosts = 'BannedHosts';   # Page for banned hosts
our $BannedCanRead = 1;             # 1 = banned cannot edit, 0 = banned cannot read
our $BannedContent = 'BannedContent'; # Page for banned content (usually for link-ban)
our $WikiLinks   = '';              # 1 = LinkPattern is a link
our $FreeLinks   = 1;               # 1 = [[some text]] is a link
our $UseQuestionmark = 1;           # 1 = append questionmark to links to nonexisting pages
our $BracketText = 1;               # 1 = [URL desc] uses a description for the URL
our $BracketWiki = 1;               # 1 = [WikiLink desc] uses a desc for the local link
our $NetworkFile = 1;               # 1 = file: is a valid protocol for URLs
our $AllNetworkFiles = 0;           # 1 = file:///foo is allowed -- the default allows only file://foo
our $InterMap    = 'InterMap';      # name of the intermap page, '' = disable
our $RssInterwikiTranslate = 'RssInterwikiTranslate'; # name of RSS interwiki translation page, '' = disable
$ENV{PATH}   = '/bin:/usr/bin'; # Path used to find 'diff' and 'grep'
our $UseDiff     = 1;               # 1 = use diff
our $SurgeProtection      = 1;      # 1 = protect against leeches
our $SurgeProtectionTime  = 20;     # Size of the protected window in seconds
our $SurgeProtectionViews = 20;     # How many page views to allow in this window
our $DeletedPage = 'DeletedPage';   # Pages starting with this can be deleted
our $RCName      = 'RecentChanges'; # Name of changes page
our @RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
our $RcDefault   = 30;              # Default number of RecentChanges days
our $KeepHostDays = 4;              # Days to keep IP numbers for
our $KeepDays    = 0;               # Days to keep old revisions (0 means keep forever)
our $KeepMajor   = 1;               # 1 = keep at least one major rev when expiring pages
our $SummaryHours = 4;              # Hours to offer the old subject when editing a page
our $SummaryDefaultLength = 150;    # Length of default text for summary (0 to disable)
our $ShowEdits   = 0;               # 1 = major and show minor edits in recent changes
our $ShowAll     = 0;               # 1 = show multiple edits per page in recent changes
our $ShowRollbacks = 0;             # 1 = show rollbacks in recent changes
our $RecentLink  = 1;               # 1 = link to usernames
our $PageCluster = '';              # name of cluster page, eg. 'Cluster' to enable
our $InterWikiMoniker = '';        	# InterWiki prefix for this wiki for RSS
our $SiteDescription  = '';        	# RSS Description of this wiki
our $RssStrip = '^\d\d\d\d-\d\d-\d\d_'; # Regexp to strip from feed item titles
our $RssImageUrl      = $LogoUrl;  	# URL to image to associate with your RSS feed
our $RssRights        = '';        	# Copyright notice for RSS, usually an URL to the appropriate text
our $RssExclude       = 'RssExclude'; # name of the page that lists pages to be excluded from the feed
our $RssCacheHours    =  1;        	# How many hours to cache remote RSS files
our $RssStyleSheet    = '';        	# External style sheet for RSS files
our $UploadAllowed    =  0;        	# 1 = yes, 0 = administrators only
our @UploadTypes = ('image/jpeg', 'image/png'); # MIME types allowed, all allowed if empty list
our $EmbedWiki         = 0;        	# 1 = no headers/footers
our $FooterNote       = '';        	# HTML for bottom of every page
our $EditNote         = '';        	# HTML notice above buttons on edit page
our $TopLinkBar        = 1;        	# 0 = goto bar both at the top and bottom; 1 = top, 2 = bottom
our $TopSearchForm     = 1;         # 0 = search form both at the top and bottom; 1 = top, 2 = bottom
our $MatchingPages     = 0;         # 1 = search page content and page titles
our @UserGotoBarPages = ();        	# List of pagenames
our $UserGotoBar      = '';        	# HTML added to end of goto bar
our $CommentsPrefix   = '';        	# prefix for comment pages, eg. 'Comments_on_' to enable
our $CommentsPattern = undef;      	# regex used to match comment pages
our $HtmlHeaders      = '';        	# Additional stuff to put in the HTML <head> section
our $IndentLimit      = 20;        	# Maximum depth of nested lists
our $CurrentLanguage = 'en';		# Language of error messages etc
our $LanguageLimit     = 3;        	# Number of matches req. for each language
our $JournalLimit    = 200;        	# how many pages can be collected in one go?
our $PageNameLimit   = 120;        	# max length of page name in bytes
$DocumentHeader = "<!DOCTYPE html>\n<html>";
our @MyFooters = (\&GetCommentForm, \&WrapperEnd, \&DefaultFooter);
# Checkboxes at the end of the index.
our @IndexOptions = ();
# Display short comments below the GotoBar for special days
# Example: %SpecialDays = ('1-1' => 'New Year', '1-2' => 'Next Day');
our %SpecialDays = ();
# Replace regular expressions with inlined images
# Example: %Smilies = (":-?D(?=\\W)" => '/pics/grin.png');
our %Smilies = ();
# Detect page languages when saving edits
# Example: %Languages = ('de' => '\b(der|die|das|und|oder)\b');
our %Languages = ();
our @KnownLocks = qw(main diff index merge visitors); # locks to remove
our $LockExpiration = 60; # How long before expirable locks are expired
our %LockExpires = (diff=>1, index=>1, merge=>1, visitors=>1); # locks to expire after some time
our %LockCleaners = (); # What to do if a job under a lock gets a signal like SIGINT. e.g. 'diff' => \&CleanDiff
our %CookieParameters = (username=>'', pwd=>'', homepage=>'', theme=>'', css=>'', msg=>'', lang=>'', embed=>$EmbedWiki,
		     toplinkbar=>$TopLinkBar, topsearchform=>$TopSearchForm, matchingpages=>$MatchingPages, );
our %Action = (rc => \&BrowseRc,               rollback => \&DoRollback,
           browse => \&BrowseResolvedPage, maintain => \&DoMaintain,
           random => \&DoRandom,           pagelock => \&DoPageLock,
           history => \&DoHistory,         editlock => \&DoEditLock,
           edit => \&DoEdit,               version => \&DoShowVersion,
           download => \&DoDownload,       rss => \&DoRss,
           unlock => \&DoUnlock,           password => \&DoPassword,
           index => \&DoIndex,             admin => \&DoAdminPage,
           clear => \&DoClearCache,        debug => \&DoDebug,
           contrib => \&DoContributors,    more => \&DoJournal);
our @MyRules = (\&LinkRules, \&ListRule); # don't set this variable, add to it!
our %RuleOrder = (\&LinkRules => 0, \&ListRule => 0);

# The 'main' program, called at the end of this script file (aka. as handler)
sub DoWikiRequest {
  Init();
  DoSurgeProtection();
  if (not $BannedCanRead and UserIsBanned() and not UserIsEditor()) {
    ReportError(T('Reading not allowed: user, ip, or network is blocked.'), '403 FORBIDDEN',
		0, $q->p(ScriptLink('action=password', T('Login'), 'password')));
  }
  DoBrowseRequest();
}

sub ReportError {   # fatal!
  my ($errmsg, $status, $log, @html) = @_;
  InitRequest(); # make sure we can report errors before InitRequest
  print GetHttpHeader('text/html', 'nocache', $status), GetHtmlHeader(T('Error')),
    $q->start_div({class=>'error'}), $q->h1(QuoteHtml($errmsg)), @html, $q->end_div,
      $q->end_html, "\n\n"; # newlines for FCGI because of exit()
  WriteStringToFile("$TempDir/error", '<body>' . $q->h1("$status $errmsg") . $q->Dump) if $log;
  map { ReleaseLockDir($_); } keys %Locks;
  exit 2;
}

sub Init {
  binmode(STDOUT, ':encoding(UTF-8)'); # this is where the HTML gets printed
  binmode(STDERR, ':encoding(UTF-8)'); # just in case somebody prints debug info to stderr
  InitDirConfig();
  $FS = "\x1e"; # The FS character is the RECORD SEPARATOR control char in ASCII
  $Message = ''; # Warnings and non-fatal errors.
  InitLinkPatterns(); # Link pattern can be changed in config files
  InitModules(); # Modules come first so that users can change module variables in config
  InitConfig(); # Config comes as early as possible; remember $q is not available here
  InitRequest(); # get $q with $MaxPost; set these in the config file
  InitCookie(); # After InitRequest, because $q is used
  InitVariables(); # After config, to change variables, after InitCookie for GetParam
}

sub InitModules {
  if ($UseConfig and $ModuleDir and IsDir($ModuleDir)) {
    foreach my $lib (Glob("$ModuleDir/*.p[ml]")) {
      if (not $MyInc{$lib}) {
	$MyInc{$lib} = 1;   # Cannot use %INC in mod_perl settings
	my $file = encode_utf8($lib);
	do $file;
	$Message .= CGI::p("$lib: $@") if $@; # no $q exists, yet
      }
    }
  }
}

sub InitConfig {
  if ($UseConfig and $ConfigFile and not $INC{$ConfigFile} and IsFile($ConfigFile)) {
    do $ConfigFile; # these options must be set in a wrapper script or via the environment
    $Message .= CGI::p("$ConfigFile: $@") if $@; # remember, no $q exists, yet
  }
  if ($ConfigPage) { # $FS and $MaxPost must be set in config file!
    my ($status, $data) = ReadFile(GetPageFile(FreeToNormal($ConfigPage)));
    my $page = ParseData($data); # before InitVariables so GetPageContent won't work
    eval $page->{text} if $page->{text}; # perlcritic dislikes the use of eval here but we really mean it
    $Message .= CGI::p("$ConfigPage: $@") if $@;
  }
}

sub InitDirConfig {
  $PageDir     = "$DataDir/page";  # Stores page data
  $KeepDir     = "$DataDir/keep";  # Stores kept (old) page data
  $TempDir     = "$DataDir/temp";  # Temporary files and locks
  $LockDir     = "$TempDir/lock";  # DB is locked if this exists
  $NoEditFile  = "$DataDir/noedit"; # Indicates that the site is read-only
  $RcFile      = "$DataDir/rc.log"; # New RecentChanges logfile
  $RcOldFile   = "$DataDir/oldrc.log"; # Old RecentChanges logfile
  $IndexFile   = "$DataDir/pageidx";   # List of all pages
  $VisitorFile = "$DataDir/visitors.log"; # List of recent visitors
  $DeleteFile  = "$DataDir/delete.log"; # Deletion logfile
  $RssDir      = "$DataDir/rss";    # For rss feed cache
  $ConfigFile ||= "$DataDir/config";  # Config file with Perl code to execute
  $ModuleDir  ||= "$DataDir/modules"; # For extensions (ending in .pm or .pl)
}

sub InitRequest { # set up $q
  $CGI::POST_MAX = $MaxPost;
  $q ||= new CGI;
}

sub InitVariables {  # Init global session variables for mod_perl!
  $WikiDescription = $q->p($q->a({-href=>'https://www.oddmuse.org/'}, 'Oddmuse'),
			   $Counter++ > 0 ? Ts('%s calls', $Counter) : '');
  $WikiDescription .= $ModulesDescription if $ModulesDescription;
  $HeaderIsPrinted = 0; # print HTTP headers only once
  $ScriptName //= $q->url(); # URL used in links
  $FullUrl ||= $ScriptName; # URL used in forms
  %Locks = ();
  @Blocks = ();
  @Flags = ();
  $Fragment = '';
  %RecentVisitors = ();
  $OpenPageName = '';   # Currently open page
  my $add_space = $CommentsPrefix =~ /[ \t_]$/;
  $$_ = FreeToNormal($$_) for # convert spaces to underscores on all configurable pagenames
    (\$HomePage, \$RCName, \$BannedHosts, \$InterMap, \$StyleSheetPage, \$CommentsPrefix,
     \$ConfigPage, \$NotFoundPg, \$RssInterwikiTranslate, \$BannedContent, \$RssExclude, );
  $CommentsPrefix .= '_' if $add_space;
  $CommentsPattern = "^$CommentsPrefix(.*)" unless defined $CommentsPattern or not $CommentsPrefix;
  @UserGotoBarPages = ($HomePage, $RCName) unless @UserGotoBarPages;
  my @pages = sort($BannedHosts, $StyleSheetPage, $ConfigPage, $InterMap,
                   $RssInterwikiTranslate, $BannedContent);
  %AdminPages = map { $_ => 1} @pages, $RssExclude unless %AdminPages;
  %LockOnCreation = map { $_ => 1} @pages unless %LockOnCreation;
  %PlainTextPages = ($BannedHosts => 1, $BannedContent => 1,
		     $StyleSheetPage => 1, $ConfigPage => 1) unless %PlainTextPages;
  delete $PlainTextPages{''}; # $ConfigPage and others might be empty.
  CreateDir($DataDir);    # Create directory if it doesn't exist
  $Now = time;      # Reset in case script is persistent
  my $ts = Modified($IndexFile); # always stat for multiple server processes
  ReInit() if not $ts or $LastUpdate != $ts; # reinit if another process changed files (requires $DataDir)
  $LastUpdate = $ts;
  unshift(@MyRules, \&MyRules) if defined(&MyRules) && (not @MyRules or $MyRules[0] != \&MyRules);
  @MyRules = sort {$RuleOrder{$a} <=> $RuleOrder{$b}} @MyRules; # default is 0
  ReportError(Ts('Cannot create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR') unless IsDir($DataDir);
  @IndexOptions = (['pages', T('Include normal pages'), 1, \&AllPagesList]);
  foreach my $sub (@MyInitVariables) {
    my $result = $sub->();
    $Message .= $q->p($@) if $@;
  }
}

sub ReInit {   # init everything we need if we want to link to stuff
  my $id = shift; # when saving a page, what to do depends on the page being saved
  AllPagesList() unless $id;
  InterInit() if $InterMap and (not $id or $id eq $InterMap);
  %RssInterwikiTranslate = () if not $id or $id eq $RssInterwikiTranslate; # special since rarely used
}

sub InitCookie {
  undef $q->{'.cookies'};   # Clear cache if it exists (for SpeedyCGI)
  my $cookie = $q->cookie($CookieName);
  %OldCookie = split(/$FS/, UrlDecode($cookie));
  my %provided = map { $_ => 1 } $q->param;
  for my $key (keys %OldCookie) {
    SetParam($key, $OldCookie{$key}) unless $provided{$key};
  }
  CookieUsernameFix();
  CookieRollbackFix();
}

sub CookieUsernameFix {
  # Only valid usernames get stored in the new cookie.
  my $name = GetParam('username', '');
  $q->delete('username');
  if (not $name) {
    # do nothing
  } elsif ($WikiLinks and not $FreeLinks and $name !~ /^$LinkPattern$/) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif ($FreeLinks and $name !~ /^$FreeLinkPattern$/) {
    $Message .= $q->p(Ts('Invalid UserName %s: not saved.', $name));
  } elsif (length($name) > 50) { # Too long
    $Message .= $q->p(T('UserName must be 50 characters or less: not saved'));
  } else {
    SetParam('username', $name);
  }
}

sub CookieRollbackFix {
  my @rollback = grep(/rollback-(\d+)/, $q->param);
  if (@rollback and $rollback[0] =~ /(\d+)/) {
    SetParam('to', $1);
    $q->delete('action');
    SetParam('action', 'rollback');
  }
}

sub GetParam {
  my ($name, $default) = @_;
  my $result = $q->param(encode_utf8($name));
  $result //= $default;
  return QuoteHtml($result); # you need to unquote anything that can have <tags>
}

sub SetParam {
  my ($name, $val) = @_;
  $q->param($name, $val);
}

sub InitLinkPatterns {
  my ($WikiWord, $QDelim);
  $QDelim = '(?:"")?'; # Optional quote delimiter (removed from the output)
  $WikiWord = '\p{Uppercase}+\p{Lowercase}+\p{Uppercase}\p{Alphabetic}*';
  $LinkPattern = "($WikiWord)$QDelim";
  $FreeLinkPattern = "([-,.()'%&!?;<> _1-9A-Za-z\x{0080}-\x{fffd}]|[-,.()'%&!?;<> _0-9A-Za-z\x{0080}-\x{fffd}][-,.()'%&!?;<> _0-9A-Za-z\x{0080}-\x{fffd}]+)"; # disallow "0" and must match HTML and plain text (ie. > and &gt;)
  # Intersites must start with uppercase letter to avoid confusion with URLs.
  $InterSitePattern = '[A-Z\x{0080}-\x{fffd}]+[A-Za-z\x{0080}-\x{fffd}]+';
  $InterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x{0080}-\x{fffd}_=!?#\$\@~`\%&*+\\/:;.,]*[-a-zA-Z0-9\x{0080}-\x{fffd}_=#\$\@~`\%&*+\\/])$QDelim";
  $FreeInterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x{0080}-\x{fffd}_=!?#\$\@~`\%&*+\\/:;.,()' ]+)"; # plus space and other characters, and no restrictions on the end of the pattern
  $UrlProtocols = 'https?|ftp|afs|news|nntp|mid|cid|mailto|wais|prospero|telnet|gophers?|irc|feed';
  $UrlProtocols .= '|file' if $NetworkFile;
  my $UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]'; # see RFC 2396
  my $EndChars = '[-a-zA-Z0-9/@=+$_~*]'; # no punctuation at the end of the url.
  $UrlPattern = "((?:$UrlProtocols):$UrlChars+$EndChars)";
  $FullUrlPattern="((?:$UrlProtocols):$UrlChars+)"; # when used in square brackets
  $ImageExtensions = '(gif|jpg|jpeg|png|bmp|svg|webp)';
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
    $Fragment =~ s|<p>\s*</p>||g; # clean up extra paragraphs (see end of ApplyRules)
    print $Fragment;
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  push(@Blocks, shift);
  push(@Flags, 1);
  $Fragment = '';
}

sub ApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks, $withanchors, $revision, @tags) = @_; # $revision is used for images
  $text =~ s/\r\n/\n/g;   # DOS to Unix
  $text =~ s/\n+$//g;   # No trailing paragraphs
  return if $text eq '';  # allow the text '0'
  local $Fragment = '';  # the clean HTML fragment not yet on @Blocks
  local @Blocks = ();  # the list of cached HTML blocks
  local @Flags = ();   # a list for each block, 1 = dirty, 0 = clean
  Clean(join('', map { AddHtmlEnvironment($_) } @tags));
  if ($OpenPageName and $PlainTextPages{$OpenPageName}) { # there should be no $PlainTextPages{''}
    Clean(CloseHtmlEnvironments() . $q->pre($text));
  } elsif (my ($type) = TextIsFile($text)) { # TODO? $type defined here??
    Clean(CloseHtmlEnvironments() . $q->p(T('This page contains an uploaded file:'))
	  . $q->p(GetDownloadLink($OpenPageName, (substr($type, 0, 6) eq 'image/'), $revision))
	  . (length $Page{summary} > 0 ? $q->blockquote(QuoteHtml($Page{summary})) : $q->p(T('No summary was provided for this file.'))));
  } else {
    my $smileyregex = join "|", keys %Smilies;
    $smileyregex = qr/(?=$smileyregex)/;
    local $_ = $text;
    local $bol = 1;
    while (1) {
      # Block level elements should eat trailing empty lines to prevent empty p elements.
      if ($bol and m/\G(\s*\n)+/cg) {
	Clean(CloseHtmlEnvironments() . AddHtmlEnvironment('p'));
      } elsif ($bol and m/\G(\&lt;include(\s+(text|with-anchors))?\s+"(.*)"\&gt;[ \t]*\n?)/cgi) {
	# <include "uri..."> includes the text of the given URI verbatim
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my ($oldpos, $old_, $type, $uri) = ((pos), $_, $3, UnquoteHtml($4)); # remember, page content is quoted!
	if ($uri =~ /^($UrlProtocols):/) {
	  if ($type eq 'text') {
	    print $q->pre({class=>"include $uri"}, QuoteHtml(GetRaw($uri)));
	  } else { # never use local links for remote pages, with a starting tag
	    print $q->start_div({class=>'include'});
	    ApplyRules(QuoteHtml(GetRaw($uri)), 0, ($type eq 'with-anchors'), undef, 'p');
	    print $q->end_div();
	  }
	} else {
	  $Includes{$OpenPageName} = 1;
	  local $OpenPageName = FreeToNormal($uri);
	  if ($type eq 'text') {
	    print $q->pre({class=>"include $OpenPageName"}, QuoteHtml(GetPageContent($OpenPageName)));
	  } elsif (not $Includes{$OpenPageName}) { # with a starting tag, watch out for recursion
	    print $q->start_div({class=>"include $OpenPageName"});
	    ApplyRules(QuoteHtml(GetPageContent($OpenPageName)), $locallinks, $withanchors, undef, 'p');
	    print $q->end_div();
	    delete $Includes{$OpenPageName};
	  } else {
	    print $q->p({-class=>'error'}, $q->strong(Ts('Recursive include of %s!', $OpenPageName)));
	  }
	}
	Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
	($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
      } elsif ($bol and m/\G(\&lt;(journal|titles):?(\d*)((\s+|:)(\d*),?(\d*))?(\s+"(.*?)")?(\s+(reverse|past|future))?(\s+search\s+(.*))?\&gt;[ \t]*\n?)/cgi) {
	# <journal 10 "regexp"> includes 10 pages matching regexp
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my ($oldpos, $old_) = (pos, $_); # remember these because of the call to PrintJournal()
	PrintJournal($6, $7, $9, $11, $3, $13, $2);
	Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
	($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
      } elsif ($bol and m/\G(\&lt;rss(\s+(\d*))?\s+(.*?)\&gt;[ \t]*\n?)/cgis) {
	# <rss "uri..."> stores the parsed RSS of the given URI
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my ($oldpos, $old_) = (pos, $_); # remember these because of the call to RSS()
	print RSS($3 || 15, split(/\s+/, UnquoteHtml($4)));
	Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
	($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
      } elsif (/\G(&lt;search (.*?)&gt;)/cgis) {
	# <search regexp>
	Clean(CloseHtmlEnvironments());
	Dirty($1);
	my ($oldpos, $old_) = (pos, $_);
	print $q->start_div({-class=>'search'});
	SearchTitleAndBody($2, \&PrintSearchResult, SearchRegexp($2));
	print $q->end_div;
	Clean(AddHtmlEnvironment('p')); # if dirty block is looked at later, this will disappear
	($_, pos) = ($old_, $oldpos); # restore \G (assignment order matters!)
      } elsif ($bol and m/\G(&lt;&lt;&lt;&lt;&lt;&lt;&lt; )/cg) {
	my ($str, $count, $limit, $oldpos) = ($1, 0, 100, pos);
	while (m/\G(.*\n)/cg and $count++ < $limit) {
	  $str .= $1;
	  last if (substr($1, 0, 29) eq '&gt;&gt;&gt;&gt;&gt;&gt;&gt; ');
	}
	if ($count >= $limit) {
	  pos = $oldpos; # reset because we did not find a match
	  Clean('&lt;&lt;&lt;&lt;&lt;&lt;&lt; ');
	} else {
	  Clean(CloseHtmlEnvironments() . $q->pre({-class=>'conflict'}, $str) . AddHtmlEnvironment('p'));
	}
      } elsif ($bol and m/\G#REDIRECT/cg) {
	Clean('#REDIRECT');
      } elsif (%Smilies and m/\G$smileyregex/cg and Clean(SmileyReplace())) {
      } elsif (Clean(RunMyRules($locallinks, $withanchors))) {
      } elsif (m/\G\s*\n(\s*\n)+/cg) { # paragraphs: at least two newlines
	Clean(CloseHtmlEnvironments() . AddHtmlEnvironment('p')); # another one like this further up
      } elsif (m/\G&amp;([A-Za-z]+|#[0-9]+|#x[A-Za-f0-9]+);/cg) { # entity references
	Clean("&$1;");
      } elsif (m/\G[ \t\r\n]+/cg) { # don't use \s because we want to honor NO-BREAK SPACE etc
	Clean(' ');
      } elsif (m/\G([A-Za-z\x{0080}-\x{fffd}]+([ \t]+[a-z\x{0080}-\x{fffd}]+)*[ \t]+)/cg
	       or m/\G([A-Za-z\x{0080}-\x{fffd}]+)/cg or m/\G(\S)/cg) {
	Clean($1);    # multiple words but do not match http://foo
      } else {
	last;
      }
      $bol = (substr($_, pos() - 1, 1) eq "\n");
    }
  }
  pos = length $_;  # notify module functions we've completed rule handling
  Clean(CloseHtmlEnvironments());  # last block -- close it, cache it
  if ($Fragment ne '') {
    $Fragment =~ s|<p>\s*</p>||g; # clean up extra paragraphs (see end Dirty())
    print $Fragment;
    push(@Blocks, $Fragment);
    push(@Flags, 0);
  }
  # this can be stored in the page cache -- see PrintCache
  return (join($FS, @Blocks), join($FS, @Flags));
}

sub ListRule {
  if ($bol && m/\G(\s*\n)*(\*+)[ \t]+/cg
      or InElement('li') && m/\G(\s*\n)+(\*+)[ \t]+/cg) {
    return CloseHtmlEnvironmentUntil('li')
      . OpenHtmlEnvironment('ul', length($2)) . AddHtmlEnvironment('li');
  }
  return;
}

sub LinkRules {
  my ($locallinks, $withanchors) = @_;
  if ($locallinks
      and ($BracketText && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cg
	   or $BracketText && m/\G(\[\[$FreeInterLinkPattern\|([^\]]+?)\]\])/cg
	   or m/\G(\[$InterLinkPattern\])/cg or m/\G(\[\[\[$FreeInterLinkPattern\]\]\])/cg
	   or m/\G($InterLinkPattern)/cg or m/\G(\[\[$FreeInterLinkPattern\]\])/cg)) {
    # [InterWiki:FooBar text] or [InterWiki:FooBar] or
    # InterWiki:FooBar or [[InterWiki:foo bar|text]] or
    # [[InterWiki:foo bar]] or [[[InterWiki:foo bar]]]-- Interlinks
    # can change when the intermap changes (local config, therefore
    # depend on $locallinks).  The intermap is only read if
    # necessary, so if this not an interlink, we have to backtrack a
    # bit.
    my $bracket = (substr($1, 0, 1) eq '[') # but \[\[$FreeInterLinkPattern\]\] it not bracket!
      && !((substr($1, 0, 2) eq '[[') && (substr($1, 2, 1) ne '[') && index($1, '|') < 0);
    my $quote = (substr($1, 0, 2) eq '[[');
    my ($oldmatch, $output) = ($1, GetInterLink($2, $3, $bracket, $quote)); # $3 may be empty
    if ($oldmatch eq $output) { # no interlink
      my ($site, $rest) = split(/:/, $oldmatch, 2);
      Clean($site);
      pos = (pos) - length($rest) - 1; # skip site, but reparse rest
    } else {
      Dirty($oldmatch);
      print $output;            # this is an interlink
    }
  } elsif ($BracketText && m/\G(\[$FullUrlPattern[|[:space:]]([^\]]+?)\])/cg
	   or $BracketText && m/\G(\[\[$FullUrlPattern[|[:space:]]([^\]]+?)\]\])/cg
	   or m/\G(\[$FullUrlPattern\])/cg or m/\G($UrlPattern)/cg) {
    # [URL text] makes [text] link to URL, [URL] makes footnotes [1]
    my ($str, $url, $text, $bracket, $rest) = ($1, $2, $3, (substr($1, 0, 1) eq '['), '');
    if ($url =~ /(&lt|&gt|&amp)$/) { # remove trailing partial named entitites and add them as
      $rest = $1;      # back again at the end as trailing text.
      $url =~ s/&(lt|gt|amp)$//;
    }
    if ($bracket and not defined $text) { # [URL] is dirty because the number may change
      Dirty($str);
      print GetUrl($url, $text, $bracket), $rest;
    } else {
      Clean(GetUrl($url, $text, $bracket, not $bracket) . $rest); # $text may be empty, no images in brackets
    }
  } elsif ($WikiLinks && m/\G!$LinkPattern/cg) {
    Clean($1);                  # ! gets eaten
  } elsif ($WikiLinks && $locallinks
	   && ($BracketWiki && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cg
	       or m/\G(\[$LinkPattern\])/cg or m/\G($LinkPattern)/cg)) {
    # [LocalPage text], [LocalPage], LocalPage
    Dirty($1);
    my $bracket = (substr($1, 0, 1) eq '[' and not $3);
    print GetPageOrEditLink($2, $3, $bracket);
  } elsif ($locallinks && $FreeLinks && (m/\G(\[\[image:$FreeLinkPattern\]\])/cg
					 or m/\G(\[\[image:$FreeLinkPattern\|([^]|]+)\]\])/cg)) {
    # [[image:Free Link]], [[image:Free Link|alt text]]
    Dirty($1);
    print GetDownloadLink(FreeToNormal($2), 1, undef, UnquoteHtml($3));
  } elsif ($FreeLinks && $locallinks
	   && ($BracketWiki && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cg
	       or m/\G(\[\[\[$FreeLinkPattern\]\]\])/cg
	       or m/\G(\[\[$FreeLinkPattern\]\])/cg)) {
    # [[Free Link|text]], [[[Free Link]]], [[Free Link]]
    Dirty($1);
    my $bracket = (substr($1, 0, 3) eq '[[[');
    print GetPageOrEditLink($2, $3, $bracket, 1); # $3 may be empty
  } else {
    return;   # nothing matched
  }
  return '';     # one of the dirty rules matched (and they all are)
}

sub SetHtmlEnvironmentContainer {
  my ($html_tag, $html_tag_attr) = @_;
  $HtmlEnvironmentContainers{$html_tag} = defined $html_tag_attr ? (
    $HtmlEnvironmentContainers{$html_tag} ? '|' . $HtmlEnvironmentContainers{$html_tag} : '')
      . $html_tag_attr : '';
}

sub InElement {  # is $html_tag in @HtmlStack?
  my ($html_tag, $html_tag_attr) = @_;
  my  $i = 0;
  foreach my $html_tag_current (@HtmlStack) {
    return 1 if $html_tag_current eq $html_tag and
               ($html_tag_attr ? $HtmlAttrStack[$i] =~ m/$html_tag_attr/ : 1);
    $i++;
  } return '';
}

sub AddOrCloseHtmlEnvironment {  # add $html_tag, if not already added; close, otherwise
  my ($html_tag, $html_tag_attr) = @_;
  return InElement        ($html_tag, '^' . $html_tag_attr . '$')
    ? CloseHtmlEnvironment($html_tag, '^' . $html_tag_attr . '$')
    : AddHtmlEnvironment  ($html_tag, $html_tag_attr);
}

sub AddHtmlEnvironment {  # add a new $html_tag
  my ($html_tag, $html_tag_attr) = @_;
  $html_tag_attr //= '';
  if ($html_tag and not (@HtmlStack and $HtmlStack[0] eq $html_tag and
			 ($html_tag_attr ? $HtmlAttrStack[0] =~ m/$html_tag_attr/ : 1))) {
    unshift(@HtmlStack,     $html_tag);
    unshift(@HtmlAttrStack, $html_tag_attr);
    return '<' . $html_tag . ($html_tag_attr ? ' ' . $html_tag_attr : '') . '>';
  } return '';  # always return something
}

sub OpenHtmlEnvironment {  # close the previous $html_tag and open a new one
  my ($html_tag, $depth, $html_tag_attr, $tag_regex) = @_;
  my ($html, $found, @stack) = ('', 0);  # always return something
  while (@HtmlStack and $found < $depth) { # determine new stack
    my $tag = pop(@HtmlStack);
    $found++ if ($tag_regex ? $tag =~ $tag_regex : $tag eq $html_tag);
    unshift(@stack, $tag);
  }
  unshift(@stack, pop(@HtmlStack)) if @HtmlStack and $found < $depth; # nested sublist coming up, keep list item
  @HtmlStack = @stack unless $found; # if starting a new list
  $html .= CloseHtmlEnvironments();  # close remaining elements (or all elements if a new list)
  @HtmlStack = @stack if $found; # if not starting a new list
  $depth = $IndentLimit if $depth > $IndentLimit; # requested depth 0 makes no sense
  $html_tag_attr = qq/class="$html_tag_attr"/ # backwards-compatibility hack: classically, the third argument to this function was a single CSS class, rather than string of HTML tag attributes as in the second argument to the "AddHtmlEnvironment" function. To allow both sorts, we conditionally change this string to 'class="$html_tag_attr"' when this string is a single CSS class.
    if $html_tag_attr and $html_tag_attr !~ m/=/;
  splice(@HtmlAttrStack, 0, @HtmlAttrStack - @HtmlStack); # truncate to size of @HtmlStack
  foreach ($found .. $depth - 1) {
    unshift(@HtmlStack,     $html_tag);
    unshift(@HtmlAttrStack, $html_tag_attr);
    $html .= $html_tag_attr ? "<$html_tag $html_tag_attr>" : "<$html_tag>";
  }
  return $html;
}

sub CloseHtmlEnvironments { # close all -- remember to use AddHtmlEnvironment('p') if required!
  return CloseHtmlEnvironmentUntil() if pos($_) == length($_);  # close all HTML environments if we're are at the end of this page
  my $html = '';
  while (@HtmlStack) {
    defined $HtmlEnvironmentContainers{$HtmlStack[0]} and  # avoid closing block level elements
           ($HtmlEnvironmentContainers{$HtmlStack[0]} ? $HtmlAttrStack[0] =~
          m/$HtmlEnvironmentContainers{$HtmlStack[0]}/ : 1) and return $html;
    shift(@HtmlAttrStack);
    $html .= '</' . shift(@HtmlStack) . '>';
  }
  return $html;
}

sub CloseHtmlEnvironment {  # close environments up to and including $html_tag
  my $html = (@_ and InElement(@_)) ? CloseHtmlEnvironmentUntil(@_) : undef;
  if (@HtmlStack and (not(@_) or defined $html)) {
    shift(@HtmlAttrStack);
    $html .= '</' . shift(@HtmlStack) . '>';
  }
  return $html || ''; # avoid returning undefined
}

sub CloseHtmlEnvironmentUntil {  # close environments up to but not including $html_tag
  my ($html_tag,  $html_tag_attr) = @_;
  my  $html = '';
  while (@HtmlStack && (pos($_) == length($_) ||  # while there is an HTML tag-stack and we are at the end of this page or...
    !($html_tag ? $HtmlStack[0] eq $html_tag &&   # the top tag is not the desired tag and...
     ($html_tag_attr ? $HtmlAttrStack[0] =~       # its attributes do not match,
    m/$html_tag_attr/ : 1) : ''))) {      # then...
    shift(@HtmlAttrStack);  # shift off the top tag and
    $html .= '</' . shift(@HtmlStack) . '>';  # append it to our HTML string.
  }
  return $html;
}

sub SmileyReplace {
  foreach my $regexp (keys %Smilies) {
    if (m/\G($regexp)/cg) {
      return $q->img({-src=>$Smilies{$regexp}, -alt=>UnquoteHtml($1), -class=>'smiley'});
    }
  }
}

sub RunMyRules {
  my ($locallinks, $withanchors) = @_;
  foreach my $sub (@MyRules) {
    my $result = $sub->($locallinks, $withanchors);
    SetParam('msg', $@) if $@;
    return $result if defined($result);
  }
  return;
}

sub RunMyMacros {
  $_ = shift;
  foreach my $macro (@MyMacros) { $macro->() };
  return $_;
}

sub PrintWikiToHTML {
  my ($markup, $is_saving_cache, $revision, $is_locked) = @_;
  my ($blocks, $flags);
  $FootnoteNumber = 0;
  $markup =~ s/$FS//g if $markup;  # Remove separators (paranoia)
  $markup = QuoteHtml($markup);
  ($blocks, $flags) = ApplyRules($markup, 1, $is_saving_cache, $revision, 'p');
  if ($is_saving_cache and not $revision and $Page{revision} # don't save revision 0 pages
      and $Page{blocks} ne $blocks and $Page{flags} ne $flags) {
    $Page{blocks} = $blocks;
    $Page{flags}  = $flags;
    if ($is_locked or RequestLockDir('main')) { # not fatal!
      SavePage();
      ReleaseLock() unless $is_locked;
    }
  }
}

sub DoClearCache {
  return unless UserIsAdminOrError();
  RequestLockOrError();
  print GetHeader('', T('Clear Cache')), $q->start_div({-class=>'content clear'}),
    $q->p(T('Main lock obtained.')), '<p>';
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    delete @Page{qw(blocks flags languages)};
    $Page{languages} = GetLanguages($Page{blocks}) unless TextIsFile($Page{blocks});
    SavePage();
    print $q->br(), GetPageLink($id);
  }
  print '</p>', $q->p(T('Main lock released.')), $q->end_div();
  utime time, time, $IndexFile; # touch index file
  ReleaseLock();
  PrintFooter();
}

sub QuoteHtml {
  my $html = shift;
  $html =~ s/&/&amp;/g;
  $html =~ s/</&lt;/g;
  $html =~ s/>/&gt;/g;
  $html =~ s/[\x00-\x08\x0b\x0c\x0e-\x1f]/ /g; # legal xml: #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
  return $html;
}

sub UnquoteHtml {
  my $html = shift;
  $html =~ s/&lt;/</g;
  $html =~ s/&gt;/>/g;
  $html =~ s/&amp;/&/g;
  $html =~ s/%26/&/g;
  return $html;
}

sub UrlEncode {
  my $str = shift;
  return '' unless $str;
  my @letters = split(//, encode_utf8($str));
  my %safe = map {$_ => 1} ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')', '#');
  foreach my $letter (@letters) {
    $letter = sprintf("%%%02x", ord($letter)) unless $safe{$letter};
  }
  return join('', @letters);
}

sub UrlDecode {
  my $str = shift;
  return decode_utf8($str) if $str =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/eig;
  return $str;
}

sub QuoteRegexp {
  my $re = shift;
  $re =~ s/([\\\[\]\$()^.])/\\$1/g;
  return $re;
}

sub GetRaw {
  my $uri = shift;
  return unless eval { require LWP::UserAgent; };
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($uri);
  return $response->decoded_content if $response->is_success;
}

sub DoJournal {
  print GetHeader(undef, T('Journal'));
  print $q->start_div({-class=>'content journal'});
  PrintJournal(map { GetParam($_, ''); } qw(num num regexp mode offset search variation));
  print $q->end_div();
  PrintFooter();
}

sub JournalSort { $b cmp $a }

sub PrintJournal {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  my ($num, $numMore, $regexp, $mode, $offset, $search, $variation) = @_;
  $variation ||= 'journal';
  $regexp ||= '^\d\d\d\d-\d\d-\d\d';
  $num ||= 10;
  $numMore = $num unless $numMore ne '';
  $offset ||= 0;
  # FIXME: Should pass filtered list of pages to SearchTitleAndBody to save time?
  my @pages = sort JournalSort (grep(/$regexp/, $search ? SearchTitleAndBody($search) : AllPagesList()));
  @pages = reverse @pages if $mode eq 'reverse' or $mode eq 'future';
  $b = $Today // CalcDay($Now);
  if ($mode eq 'future' || $mode eq 'past') {
    my $compare = $mode eq 'future' ? -1 : 1;
    for (my $i = 0; $i < @pages; $i++) {
      $a = $pages[$i];
      if (JournalSort() == $compare) {
	@pages = @pages[$i .. $#pages];
	last;
      }
    }
  }
  return unless $pages[$offset];
  print $q->start_div({-class=>'journal h-feed'});
  my $next = $offset + PrintAllPages(1, 1, $num, $variation, @pages[$offset .. $#pages]);
  print $q->end_div();
  $regexp = UrlEncode($regexp);
  $search = UrlEncode($search);
  if ($pages[$next] and $numMore != 0) {
    print $q->p({-class=>'more'}, ScriptLink("action=more;num=$numMore;regexp=$regexp;search=$search;mode=$mode;offset=$next;variation=$variation", T('More...'), 'more'));
  }
}

sub PrintAllPages {
  my ($links, $comments, $num, $variation, @pages) = @_;
  my $lang = GetParam('lang', 0);
  my ($i, $n) = 0;
  for my $id (@pages) {
    last if $n >= $JournalLimit and not UserIsAdmin() or $num and $n >= $num;
    $i++; # pages looked at
    local ($OpenPageName, %Page); # this is local!
    OpenPage($id);
    my @languages = split(/,/, $Page{languages});
    next if $lang and @languages and not grep(/$lang/, @languages);
    next if PageMarkedForDeletion();
    next if substr($Page{text}, 0, 10) eq '#REDIRECT ';
    print '<article class="h-entry">', $q->h1({-class => 'p-name'},
      $links ? GetPageLink($id) : $q->a({-name=>$id}, UrlEncode(FreeToNormal($id))));
    if ($variation ne 'titles') {
      PrintPageHtml();
      PrintPageCommentsLink($id, $comments);
    }
    print '</article>';
    $n++; # pages actually printed
  }
  return $i;
}

sub PrintPageCommentsLink {
  my ($id, $comments) = @_;
  if ($comments and $CommentsPattern and $id !~ /$CommentsPattern/) {
    print $q->p({-class=>'comment'},
                GetPageLink($CommentsPrefix . $id, T('Comments on this page')));
  }
}

sub RSS {
  return if $CollectingJournal; # avoid infinite loops when using full=1
  local $CollectingJournal = 1;
  my $maxitems = shift;
  my @uris = @_;
  my %lines;
  if (not eval { require XML::RSS; }) {
    my $err = $@;
    return $q->div({-class=>'rss'}, $q->p({-class=>'error'}, $q->strong(T('XML::RSS is not available on this system.')), $err));
  }
  # All strings that are concatenated with strings returned by the RSS
  # feed must be decoded.  Without this decoding, 'diff' and 'history'
  # translations will be double encoded when printing the result.
  my $tDiff = T('diff');
  my $tHistory = T('history');
  my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
  my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  @uris = map { my $x = $_; $x =~ s/^"?(.*?)"?$/$1/; $x; } @uris; # strip quotes of uris
  my ($str, %data) = GetRss(@uris);
  foreach my $uri (keys %data) {
    my $data = $data{$uri};
    if (not $data) {
      $str .= $q->p({-class=>'error'}, $q->strong(Ts('%s returned no data, or LWP::UserAgent is not available.',
						     $q->a({-href=>$uri}, $uri))));
    } else {
      my $rss = new XML::RSS;
      eval { local $SIG{__DIE__}; $rss->parse($data); };
      if ($@) {
	$str .= $q->p({-class=>'error'}, $q->strong(Ts('RSS parsing failed for %s', $q->a({-href=>$uri}, $uri)) . ': ' . $@));
      } else {
	my $interwiki;
	if (@uris > 1) {
	  RssInterwikiTranslateInit(); # not needed anywhere else thus init only now and not in ReInit
	  $interwiki = $rss->{channel}->{$wikins}->{interwiki};
	  $interwiki =~ s/^\s+//; # when RDF is used, sometimes whitespace remains,
	  $interwiki =~ s/\s+$//; # which breaks the test for an existing $interwiki below
	  $interwiki ||= $rss->{channel}->{$rdfns}->{value};
	  $interwiki = $RssInterwikiTranslate{$interwiki} if $RssInterwikiTranslate{$interwiki};
	  $interwiki ||= $RssInterwikiTranslate{$uri};
	}
	my $num = 999;
	$str .= $q->p({-class=>'error'}, $q->strong(Ts('No items found in %s.', $q->a({-href=>$uri}, $uri))))
	  unless @{$rss->{items}};
	foreach my $i (@{$rss->{items}}) {
	  my $line;
	  my $date = $i->{dc}->{date};
	  if (not $date and $i->{pubDate}) {
	    $date = $i->{pubDate};
	    my %mon = (Jan=>1, Feb=>2, Mar=>3, Apr=>4, May=>5, Jun=>6,
		       Jul=>7, Aug=>8, Sep=>9, Oct=>10, Nov=>11, Dec=>12);
	    $date =~ s/^(?:[A-Z][a-z][a-z], )?(\d\d?) ([A-Z][a-z][a-z]) (\d\d(?:\d\d)?)/ # pubDate uses RFC 822
	      sprintf('%04d-%02d-%02d', ($3 < 100 ? 1900 + $3 : $3), $mon{$2}, $1)/e;
	  }
	  $date ||= sprintf("%03d", $num--); # for RSS 0.91 feeds without date, descending
	  my $title = $i->{title};
	  my $description = $i->{description};
	  if (not $title and $description) { # title may be missing in RSS 2.00
	    $title = $description;
	    $description = '';
	  }
	  $title = $i->{link} if not $title and $i->{link}; # if description and title are missing
	  $line .= ' (' . $q->a({-href=>$i->{$wikins}->{diff}},    $tDiff) . ')'    if $i->{$wikins}->{diff};
	  $line .= ' (' . $q->a({-href=>$i->{$wikins}->{history}}, $tHistory) . ')' if $i->{$wikins}->{history};
	  if ($title) {
	    if ($i->{link}) {
	      $line .= ' ' . $q->a({-href=>$i->{link}, -title=>$date},
				   ($interwiki ? $interwiki . ':' : '') . $title);
	    } else {
	      $line .= ' ' . $title;
	    }
	  }
	  my $contributor = $i->{dc}->{contributor};
	  $contributor ||= $i->{$wikins}->{username};
	  $contributor =~ s/^\s+//;
	  $contributor =~ s/\s+$//;
	  $contributor ||= $i->{$rdfns}->{value};
	  $line .= $q->span({-class=>'contributor'}, $q->span(T(' . . . .') . ' ') . $contributor) if $contributor;
	  if ($description) {
	    if ($description =~ /</) {
	      $line .= $q->div({-class=>'description'}, $description);
	    } else {
	      $line .= $q->span({class=>'dash'}, ' &#8211; ') . $q->strong({-class=>'description'}, $description);
	    }
	  }
	  $date .= ' ' while ($lines{$date}); # make sure this is unique
	  $lines{$date} = $line;
	}
      }
    }
  }
  my @lines = sort { $b cmp $a } keys %lines;
  @lines = @lines[0 .. $maxitems-1] if $maxitems and $#lines > $maxitems;
  my $date = '';
  foreach my $key (@lines) {
    my $line = $lines{$key};
    if ($key =~ /(\d\d\d\d(?:-\d?\d)?(?:-\d?\d)?)(?:[T ](\d?\d:\d\d))?/) {
      my ($day, $time) = ($1, $2);
      if ($day ne $date) {
	$str .= '</ul>' if $date; # close ul except for the first time where no open ul exists
	$date = $day;
	$str .= $q->p($q->strong($day)) . '<ul>';
      }
      $line = $q->span({-class=>'time'}, $time . ' UTC ') . $line if $time;
    } elsif (not $date) {
      $str .= '<ul>'; # if the feed doesn't have any dates we need to start the list anyhow
      $date = $Now;   # to ensure the list starts only once
    }
    $str .= $q->li($line);
  }
  $str .= '</ul>' if $date;
  return $q->div({-class=>'rss'}, $str);
}

sub GetRss {
  my %todo = map {$_, GetRssFile($_)} @_;
  my %data = ();
  my $str = '';
  if (GetParam('cache', $UseCache) > 0) {
    foreach my $uri (keys %todo) { # read cached rss files if possible
      if ($Now - Modified($todo{$uri}) < $RssCacheHours * 3600) {
	$data{$uri} = ReadFile($todo{$uri});
	delete($todo{$uri});  # no need to fetch them below
      }
    }
  }
  my @need_cache = keys %todo;
  if (keys %todo > 1) {   # try parallel access if available
    eval { # see code example in LWP::Parallel, not LWP::Parallel::UserAgent (no callbacks here)
      require LWP::Parallel::UserAgent;
      my $pua = LWP::Parallel::UserAgent->new();
      foreach my $uri (keys %todo) {
	if (my $res = $pua->register(HTTP::Request->new('GET', $uri))) {
	  $str .= $res->error_as_HTML;
	}
      }
      %todo = (); # because the uris in the response may have changed due to redirects
      my $entries = $pua->wait();
      foreach (keys %$entries) {
	my $uri = $entries->{$_}->request->uri;
	$data{$uri} = $entries->{$_}->response->decoded_content;
      }
    }
  }
  foreach my $uri (keys %todo) { # default operation: synchronous fetching
    $data{$uri} = GetRaw($uri);
  }
  if (GetParam('cache', $UseCache) > 0) {
    CreateDir($RssDir);
    foreach my $uri (@need_cache) {
      my $data = $data{$uri};
      # possibly a Latin-1 file without encoding attribute will cause a problem?
      $data =~ s/encoding="[^"]*"/encoding="UTF-8"/; # content was converted
      WriteStringToFile(GetRssFile($uri), $data) if $data;
    }
  }
  return $str, %data;
}

sub GetRssFile {
  return $RssDir . '/' . UrlEncode(shift);
}

sub RssInterwikiTranslateInit {
  return unless $RssInterwikiTranslate;
  %RssInterwikiTranslate = ();
  foreach (split(/\n/, GetPageContent($RssInterwikiTranslate))) {
    if (/^ ([^ ]+)[ \t]+([^ ]+)$/) {
      $RssInterwikiTranslate{$1} = $2;
    }
  }
}

sub GetInterSiteUrl {
  my ($site, $page, $quote) = @_;
  return unless $page;
  $page = join('/', map { UrlEncode($_) } split(/\//, $page)) if $quote; # Foo:bar+baz is not quoted, [[Foo:bar baz]] is.
  my $url = $InterSite{$site} or return;
  $url =~ s/\%s/$page/g or $url .= $page;
  return $url;
}

sub BracketLink {   # brackets can be removed via CSS
  return $q->span($q->span({class=>'bracket'}, '[') . (shift) . $q->span({class=>'bracket'}, ']'));
}

sub GetInterLink {
  my ($id, $text, $bracket, $quote) = @_;
  my ($site, $page) = split(/:/, $id, 2);
  $page =~ s/&amp;/&/g;   # Unquote common URL HTML
  my $url = GetInterSiteUrl($site, $page, $quote);
  my $class = 'inter ' . $site;
  return "[$id $text]" if $text and $bracket and not $url;
  return "[$id]" if $bracket and not $url;
  return $id if not $url;
  if ($bracket and not $text) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
  } elsif (not $text) {
    $text = $q->span({-class=>'site'}, $site)
      . $q->span({-class=>'separator'}, ':')
      . $q->span({-class=>'interpage'}, $page);
  } elsif ($bracket) {    # and $text is set
    $class .= ' outside';
  }
  return $q->a({-href=>$url, -class=>$class}, $text);
}

sub InterInit {
  %InterSite = ();
  foreach (split(/\n/, GetPageContent($InterMap))) {
    if (/^ ($InterSitePattern)[ \t]+([^ ]+)$/) {
      $InterSite{$1} = $2;
    }
  }
}

sub GetUrl {
  my ($url, $text, $bracket, $images) = @_;
  $url =~ /^($UrlProtocols)/;
  my $class = "url $1";
  if ($NetworkFile && $url =~ m|^file:///| && !$AllNetworkFiles
      or !$NetworkFile && $url =~ m|^file:|) {
    # Only do remote file:// links. No file:///c|/windows.
    return $url;
  } elsif ($bracket and not defined $text) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
  } elsif (not defined $text) {
    $text = $url;
  } elsif ($bracket) {    # and $text is set
    $class .= ' outside';
  }
  $url = UnquoteHtml($url); # links should be unquoted again
  if ($images and $url =~ /^(http:|https:|ftp:).+\.$ImageExtensions$/i) {
    return $q->img({-src=>$url, -alt=>$url, -class=>$class, -loading=>'lazy'});
  } else {
    return $q->a({-href=>$url, -class=>$class}, $text);
  }
}

sub GetPageOrEditLink { # use GetPageLink and GetEditLink if you know the result!
  my ($id, $text, $bracket, $free) = @_;
  $id = FreeToNormal($id);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if (not $text and $resolved and $bracket) {
    $text = BracketLink(++$FootnoteNumber);
    $class .= ' number';
    $title = NormalToFree($id);
  }
  my $link = $text || NormalToFree($id);
  if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
    return ScriptLink(UrlEncode($resolved), $link, $class, undef, $title);
  } else {      # reproduce markup if $UseQuestionmark
    return GetEditLink($id, UnquoteHtml($bracket ? "[$link]" : $link)) unless $UseQuestionmark;
    $link = QuoteHtml($id) . GetEditLink($id, '?');
    $link .= ($free ? '|' : ' ') . $text if $text and FreeToNormal($text) ne $id;
    $link = "[[$link]]" if $free;
    $link = "[$link]" if $bracket or not $free and $text;
    return $link;
  }
}

sub GetPageLink { # use if you want to force a link to local pages, whether it exists or not
  my ($id, $name, $class, $accesskey) = @_;
  $id = FreeToNormal($id);
  $name ||= $id;
  $class .= ' ' if $class;
  return ScriptLink(UrlEncode($id), NormalToFree($name), $class . 'local',
		    undef, undef, $accesskey);
}

sub GetEditLink {   # shortcut
  my ($id, $name, $upload, $accesskey) = @_;
  $id = FreeToNormal($id);
  my $action = 'action=edit;id=' . UrlEncode($id);
  $action .= ';upload=1' if $upload;
  return ScriptLink($action, NormalToFree($name), 'edit', undef, T('Click to edit this page'), $accesskey);
}

sub ScriptUrl {
  my $action = shift;
  if ($action =~ /^($UrlProtocols)\%3a/ or $action =~ /^\%2f/) { # nearlinks and other URLs
    $action =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/eg; # undo urlencode
    # do nothing
  } else {
    $action = $ScriptName . (($UsePathInfo and index($action, '=') == -1) ? '/' : '?') . $action;
  }
  return $action unless wantarray;
  return ($action, index($action, '=') != -1);
}

sub ScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey) = @_;
  my ($url, $nofollow) = ScriptUrl($action);
  my %params;
  $params{-href} = $url;
  $params{'-rel'}   = 'nofollow' if $nofollow;
  $params{'-class'} = $class     if $class;
  $params{'-name'}  = $name      if $name;
  $params{'-title'} = $title     if $title;
  $params{'-accesskey'} = $accesskey  if $accesskey;
  return $q->a(\%params, $text);
}

sub GetDownloadLink {
  my ($id, $image, $revision, $alt) = @_;
  $alt ||= NormalToFree($id);
  # if the page does not exist
  return '[[' . ($image ? 'image' : 'download') . ':'
    . ($UseQuestionmark ? QuoteHtml($id) . GetEditLink($id, '?', 1)
       : GetEditLink($id, $id, 1)) . ']]'
      unless $IndexHash{$id};
  my $action;
  if ($revision) {
    $action = "action=download;id=" . UrlEncode($id) . ";revision=$revision";
  } elsif ($UsePathInfo) {
    $action = "download/" . UrlEncode($id);
  } else {
    $action = "action=download;id=" . UrlEncode($id);
  }
  if ($image) {
    $action = $ScriptName . (($UsePathInfo and not $revision) ? '/' : '?') . $action;
    return $action if $image == 2;
    my $result = $q->img({-src=>$action, -alt=>UnquoteHtml($alt), -title=>UnquoteHtml($alt),
			  -class=>'upload', -loading=>'lazy'});
    $result = ScriptLink(UrlEncode($id), $result, 'image') unless $id eq $OpenPageName;
    return $result;
  } else {
    return ScriptLink($action, $alt, 'upload');
  }
}

sub PrintCache {    # Use after OpenPage!
  my @blocks = split($FS, $Page{blocks});
  my @flags = split($FS, $Page{flags});
  $FootnoteNumber = 0;
  foreach my $block (@blocks) {
    if (shift(@flags)) {
      ApplyRules($block, 1, 1); # local links, anchors, current revision, no start tag
    } else {
      print $block;
    }
  }
}

sub PrintPageHtml {   # print an open page
  return unless GetParam('page', 1) and $Page{text};
  my $lang = (split /,/, $Page{languages})[0] || $CurrentLanguage;
  print qq{<div class="e-content" lang="$lang">};
  if ($Page{blocks} and defined $Page{flags} and GetParam('cache', $UseCache) > 0) {
    PrintCache();
  } else {
    PrintWikiToHTML($Page{text}, 1); # save cache, current revision, no main lock
  }
  print '</div>';
}

sub PrintPageDiff {   # print diff for open page
  my $diff = GetParam('diff', 0);
  if ($UseDiff and $diff) {
    PrintHtmlDiff($diff);
    print $q->hr() if GetParam('page', 1);
  }
}

sub ToString {
  my $sub_ref = shift;
  my $output;
  open(my $outputFH, '>:encoding(UTF-8)', \$output) or die "Can't open memory file: $!";
  my $oldFH = select $outputFH;
  $sub_ref->(@_);
  select $oldFH;
  close $outputFH;
  return decode_utf8($output);
}

sub PageHtml {
  my ($id, $limit, $error) = @_;
  OpenPage($id);
  my $diff = ToString \&PrintPageDiff;
  return $error if $limit and length($diff) > $limit;
  my $lang = (split /,/, $Page{languages})[0] // $CurrentLanguage;
  my $page .= ToString \&PrintPageHtml;
  return $diff . $q->p($error) if $limit and length($diff . $page) > $limit;
  return $diff . $page;
}

sub T {
  my $text = shift;
  return $Translate{$text} || $text;
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
  $text =~ s/\%([1-9])/$_[$1]/eg;
  return $text;
}

sub GetId {
  my $id = UnquoteHtml(GetParam('id', GetParam('title', ''))); # id=x or title=x -> x
  if (not $id and $q->keywords) {
    $id = decode_utf8(join('_', $q->keywords)); # script?p+q -> p_q
  }
  if ($UsePathInfo and $q->path_info) {
    my @path = map { decode_utf8($_) } split(/\//, $q->path_info);
    $id ||= pop(@path); # script/p/q -> q
    foreach my $p (@path) {
      SetParam($p, 1);    # script/p/q -> p=1
    }
  }
  return FreeToNormal($id);
}

sub DoBrowseRequest {
  # We can use the error message as the HTTP error code
  ReportError(Ts('CGI Internal error: %s', $q->cgi_error), $q->cgi_error) if $q->cgi_error;
  print $q->header(-status=>'304 NOT MODIFIED') and return if PageFresh(); # return value is ignored
  my $id = GetId();
  my $action = lc(GetParam('action', '')); # script?action=foo;id=bar
  $action = 'download' if GetParam('download', '') and not $action; # script/download/id
  if ($Action{$action}) {
    &{$Action{$action}}($id);
  } elsif ($action and defined &MyActions) {
    eval { local $SIG{__DIE__}; MyActions(); };
  } elsif ($action) {
    ReportError(Ts('Invalid action parameter %s', $action), '501 NOT IMPLEMENTED');
  } elsif (GetParam('search', '') ne '') { # allow search for "0"
    SetParam('action', 'search'); # make sure this gets a NOINDEX
    DoSearch();
  } elsif (GetParam('match', '') ne '') {
    SetParam('action', 'index'); # make sure this gets a NOINDEX
    DoIndex();
  } elsif (GetParam('title', '') and not GetParam('Cancel', '')) {
    DoPost(GetParam('title', ''));
  } else {
    BrowseResolvedPage($id || $HomePage);  # default action!
  }
}

sub ValidId { # hack alert: returns error message if invalid, and unfortunately the empty string if valid!
  my $id = FreeToNormal(shift);
  return T('Page name is missing') unless $id;
  require bytes;
  return Ts('Page name is too long: %s', $id) if bytes::length($id) > $PageNameLimit;
  return Ts('Invalid Page %s (must not end with .db)', $id) if $id =~ m|\.db$|;
  return Ts('Invalid Page %s (must not end with .lck)', $id) if $id =~ m|\.lck$|;
  return Ts('Invalid Page %s', $id) if $FreeLinks ? $id !~ m|^$FreeLinkPattern$| : $id !~ m|^$LinkPattern$|;
}

sub ValidIdOrDie {
  my $id = shift;
  my $error = ValidId($id);
  ReportError($error, '400 BAD REQUEST') if $error;
  return 1;
}

sub ResolveId { # return css class, resolved id, title (eg. for popups), exist-or-not
  my $id = shift;
  return ('local', $id, '', 1) if $IndexHash{$id};
  return ('', '', '', '');
}

sub BrowseResolvedPage {
  my $id = FreeToNormal(shift);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if ($class and $class eq 'near' and not GetParam('rcclusteronly', 0)) { # nearlink (is url)
    print $q->redirect({-uri=>$resolved});
  } elsif ($class and $class eq 'alias') { # an anchor was found instead of a page
    ReBrowsePage($resolved);
  } elsif (not $resolved and $NotFoundPg and $id !~ /$CommentsPattern/) { # custom page-not-found message
    BrowsePage($NotFoundPg);
  } elsif ($resolved or $id =~ /$CommentsPattern/ and $1 and $IndexHash{$1}) { # an existing page
    BrowsePage(($resolved or $id), GetParam('raw', 0));
  } else {      # new page!
    BrowsePage($id, GetParam('raw', 0), undef, '404 NOT FOUND') if ValidIdOrDie($id);
  }
}

sub NewText { # only if no revision is available
  my $id = shift;
  if ($CommentsPrefix and $id =~ /^($CommentsPrefix)/) {
    return T('There are no comments, yet. Be the first to leave a comment!');
  } elsif ($id eq $HomePage) {
    return T('Welcome!');
  } else {
    return Ts('This page does not exist, but you can %s.',
              '[' . ScriptUrl('action=edit;id=' . UrlEncode($id)) . ' '
              . T('create it now') . ']');
  }
}

sub BrowsePage {
  my ($id, $raw, $comment, $status) = @_;
  OpenPage($id);
  my ($revisionPage, $revision) = GetTextRevision(GetParam('revision', ''));
  my $text    = $revisionPage->{text};
  $text = NewText($id) unless $revision or $Page{revision} or $comment; # new text for new pages
  # handle a single-level redirect
  my $oldId = GetParam('oldid', '');
  if ((substr($text, 0, 10) eq '#REDIRECT ')) {
    if ($oldId) {
      $Message .= $q->p(T('Too many redirections'));
    } elsif ($revision) {
      $Message .= $q->p(T('No redirection for old revisions'));
    } elsif (($FreeLinks and $text =~ /^\#REDIRECT\s+\[\[$FreeLinkPattern\]\]/)
       or ($WikiLinks and $text =~ /^\#REDIRECT\s+$LinkPattern/)) {
      return ReBrowsePage(FreeToNormal($1), $id);
    } else {
      $Message .= $q->p(T('Invalid link pattern for #REDIRECT'));
    }
  }
  # shortcut if we only need the raw text: no caching, no diffs, no html.
  if ($raw) {
    print GetHttpHeader('text/plain', $Page{ts}, $IndexHash{$id} ? undef : '404 NOT FOUND');
    print $Page{ts} . " # Do not delete this line when editing!\n" if $raw == 2;
    print $text;
    return;
  }
  # normal page view
  my $msg = GetParam('msg', '');
  $Message .= $q->p($msg) if $msg; # show message if the page is shown
  SetParam('msg', '');
  print GetHeader($id, NormalToFree($id), $oldId, undef, $status);
  my $showDiff = GetParam('diff', 0);
  if ($UseDiff and $showDiff) {
    PrintHtmlDiff($showDiff, GetParam('diffrevision'), $revisionPage, $Page{revision});
    print $q->hr();
  }
  PrintPageContent($text, $revision, $comment);
  SetParam('rcclusteronly', $id) if FreeToNormal(GetCluster($text)) eq $id; # automatically filter by cluster
  PrintRcHtml($id);
  PrintFooter($id, $revision, $comment, $revisionPage);
}

sub ReBrowsePage {
  my ($id, $oldId) = map { UrlEncode($_); } @_; # encode before printing URL
  if ($oldId) {     # Target of #REDIRECT (loop breaking)
    print GetRedirectPage("action=browse;oldid=$oldId;id=$id", $id);
  } else {
    print GetRedirectPage($id, $id);
  }
}

sub GetRedirectPage {
  my ($action, $name) = @_;
  my ($url, $html);
  if (GetParam('raw', 0)) {
    $html = GetHttpHeader('text/plain');
    $html .= Ts('Please go on to %s.', $action); # no redirect
    return $html;
  }
  $url = $ScriptName . (($UsePathInfo and $action !~ /=/) ? '/' : '?') . $action;
  my $nameLink = $q->a({-href=>$url}, $name);
  my %headers = (-uri=>$url);
  my $cookie = Cookie();
  $headers{-cookie} = $cookie if $cookie;
  return $q->redirect(%headers);
}

sub DoRandom {
  my @pages = AllPagesList();
  ReBrowsePage($pages[int(rand($#pages + 1))]);
}

sub PageFresh { # pages can depend on other pages (ie. last update), admin status, and css
  return 1 if $q->http('HTTP_IF_NONE_MATCH') and GetParam('cache', $UseCache) >= 2
    and $q->http('HTTP_IF_NONE_MATCH') eq PageEtag();
}

sub PageEtag {
  my ($changed, %params) = CookieData();
  return UrlEncode(join($FS, $LastUpdate||$Now, sort(values %params))); # no CTL in field values
}

sub FileFresh { # old files are never stale, current files are stale when the page was modified
  return 1 if $q->http('HTTP_IF_NONE_MATCH') and GetParam('cache', $UseCache) >= 2
    and (GetParam('revision', 0) or $q->http('HTTP_IF_NONE_MATCH') eq $Page{ts});
}

sub BrowseRc {
  my $id = shift;
  if (GetParam('raw', 0)) {
    print GetHttpHeader('text/plain');
    PrintRcText();
  } else {
    PrintRcHtml($id || $RCName, 1);
  }
}

sub GetRcLines { # starttime, hash of seen pages to use as a second return value
  my $starttime = shift || GetParam('from', 0) ||
    $Now - GetParam('days', $RcDefault) * 86400; # 24*60*60
  my $filterOnly = GetParam('rcfilteronly', '');
  # these variables apply accross logfiles
  my %match = $filterOnly ? map { $_ => 1 } SearchTitleAndBody($filterOnly) : ();
  my %following = ();
  my @result = ();
  my $ts;
  # check the first timestamp in the default file, maybe read old log file
  if (open(my $F, '<:encoding(UTF-8)', encode_utf8($RcFile))) {
    my $line = <$F>;
    ($ts) = split(/$FS/, $line); # the first timestamp in the regular rc file
  }
  if (not $ts or $ts > $starttime) { # we need to read the old rc file, too
    push(@result, GetRcLinesFor($RcOldFile, $starttime, \%match, \%following));
  }
  push(@result, GetRcLinesFor($RcFile, $starttime, \%match, \%following));
  # GetRcLinesFor is trying to save memory space, but some operations
  # can only happen once we have all the data.
  return LatestChanges(StripRollbacks(@result));
}

sub LatestChanges {
  my $all = GetParam('all', $ShowAll);
  my @result = @_;
  my %seen = ();
  for (my $i = $#result; $i >= 0; $i--) {
    my $id = $result[$i][1];
    if ($all) {
      $result[$i][9] = 1 unless $seen{$id}; # mark latest edit
    } else {
      splice(@result, $i, 1) if $seen{$id}; # remove older edits
    }
    $seen{$id} = 1;
  }
  my $to = GetParam('upto', 0);
  if ($to) {
    for (my $i = 0; $i < $#result; $i++) {
      if ($result[$i][0] > $to) {
	splice(@result, $i);
	last;
      }
    }
  }
  return reverse @result;
}

sub StripRollbacks {
  my @result = @_;
  if (not (GetParam('all', $ShowAll) or GetParam('rollback', $ShowRollbacks))) { # strip rollbacks
    my (%rollback); # used for single-page rollbacks
    for (my $i = $#result; $i >= 0; $i--) {
      # some fields have a different meaning if looking at rollbacks
      my ($ts, $id, $target_ts, $target_id) = @{$result[$i]};
      # if this is a rollback marker
      if ($id eq '[[rollback]]') {
        # if this is a single page rollback marker, strip it
	if ($target_id) {
          # if this page is not already being rolled back, remember the target
          # id and target ts so that those lines can be stripped below
          if (not $rollback{$target_id} or $target_ts < $rollback{$target_id}) {
            $rollback{$target_id} = $target_ts;
          }
          # the marker is always stripped
	  splice(@result, $i, 1);
	} else {
          # if this is a global rollback, things are different: we're going to
          # find the correct timestamp and strip all of those lines immediately
	  my $end = $i;
	  $i-- while $i > 0 and $target_ts < $result[$i-1][0];
          # splice the lines found
          splice(@result, $i, $end - $i + 1);
	}
      } elsif ($rollback{$id} and $ts > $rollback{$id}) {
	splice(@result, $i, 1); # strip rolled back single pages
      }
    }
  } else { # if rollbacks are not not shown, just strip the markers
    for (my $i = $#result; $i >= 0; $i--) {
      splice(@result, $i, 1) if $result[$i][1] eq '[[rollback]]'; # id
    }
  }
  return @result;
}

sub GetRcLinesFor {
  my $file = shift;
  my $starttime = shift;
  my %match = %{$_[0]}; # deref
  my %following = %{$_[1]}; # deref
  # parameters
  my $showminoredit = GetParam('showedit', $ShowEdits); # show minor edits
  my $all = GetParam('all', $ShowAll);
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly, $match, $lang,
      $followup) = map { UnquoteHtml(GetParam($_, '')); }
	qw(rcidonly rcuseronly rchostonly
        rcclusteronly rcfilteronly match lang followup);
  # parsing and filtering
  my @result = ();
  open(my $F, '<:encoding(UTF-8)', encode_utf8($file)) or return ();
  while (my $line = <$F>) {
    chomp($line);
    my ($ts, $id, $minor, $summary, $host, $username, $revision,
	$languages, $cluster) = split(/$FS/, $line);
    next if $ts < $starttime;
    $following{$id} = $ts if $followup and $followup eq $username;
    next if $followup and (not $following{$id} or $ts <= $following{$id});
    next if $idOnly and $idOnly ne $id;
    next if $filterOnly and not $match{$id};
    next if ($userOnly and $userOnly ne $username);
    next if $minor == 1 and not $showminoredit; # skip minor edits (if [[rollback]] this is bogus)
    next if not $minor and $showminoredit == 2; # skip major edits
    next if $match and $id !~ /$match/i;
    next if $hostOnly and $host !~ /$hostOnly/i;
    my @languages = split(/,/, $languages);
    next if $lang and @languages and not grep(/$lang/, @languages);
    if ($PageCluster) {
      ($cluster, $summary) = ($1, $2) if $summary =~ /^\[\[$FreeLinkPattern\]\] ?: *(.*)/
	or $summary =~ /^$LinkPattern ?: *(.*)/;
      next if ($clusterOnly and $clusterOnly ne $cluster);
      $cluster = '' if $clusterOnly; # don't show cluster if $clusterOnly eq $cluster
      if ($all < 2 and not $clusterOnly and $cluster) {
	$summary = "$id: $summary"; # print the cluster instead of the page
	$id = $cluster;
	$revision = '';
      }
    } else {
      $cluster = '';
    }
    $following{$id} = $ts if $followup and $followup eq $username;
    push(@result, [$ts, $id, $minor, $summary, $host, $username, $revision,
		   \@languages, $cluster]);
  }
  return @result;
}

sub ProcessRcLines {
  my ($printDailyTear, $printRCLine) = @_; # code references
  # needed for output
  my $date = '';
  for my $line (GetRcLines()) {
    my ($ts, $id, $minor, $summary, $host, $username, $revision, $languageref,
	$cluster, $last) = @$line;
    if ($date ne CalcDay($ts)) {
      $date = CalcDay($ts);
      $printDailyTear->($date);
    }
    $printRCLine->($id, $ts, $host, $username, $summary, $minor, $revision,
      $languageref, $cluster, $last);
  }
}

sub RcHeader {
  my ($from, $upto, $html) = (GetParam('from', 0), GetParam('upto', 0), '');
  my $days = GetParam('days') + 0 || $RcDefault; # force numeric $days
  my $all = GetParam('all', $ShowAll);
  my $edits = GetParam('showedit', $ShowEdits);
  my $rollback = GetParam('rollback', $ShowRollbacks);
  if ($from) {
    $html .= $q->h2(Ts('Updates since %s', TimeToText(GetParam('from', 0))) . ' '
		    . ($upto ? Ts('up to %s', TimeToText($upto)) : ''));
  } else {
    $html .= $q->h2((GetParam('days', $RcDefault) != 1)
		    ? Ts('Updates in the last %s days', $days)
		    : Ts('Updates in the last day'));
  }
  my $action = '';
  my ($idOnly, $userOnly, $hostOnly, $clusterOnly, $filterOnly,
      $match, $lang, $followup) =
	  map {
	    my $val = GetParam($_, '');
	    $html .= $q->p($q->b('(' . Ts('for %s only', $val) . ')')) if $val;
	    $action .= ";$_=$val" if $val; # remember these parameters later!
	    $val;
      } qw(rcidonly rcuseronly rchostonly rcclusteronly rcfilteronly
       match lang followup);
  my $rss = "action=rss$action;days=$days;all=$all;showedit=$edits";
  if ($clusterOnly) {
    $action = GetPageParameters('browse', $clusterOnly) . $action;
  } else {
    $action = "action=rc$action";
  }
  my @menu;
  if ($all) {
    push(@menu, ScriptLink("$action;days=$days;all=0;showedit=$edits",
			   T('List latest change per page only')));
  } else {
    push(@menu, ScriptLink("$action;days=$days;all=1;showedit=$edits",
			   T('List all changes')));
    if ($rollback) {
      push(@menu, ScriptLink("$action;days=$days;all=0;rollback=0;"
			     . "showedit=$edits", T('Skip rollbacks')));
    } else {
      push(@menu, ScriptLink("$action;days=$days;all=0;rollback=1;"
			     . "showedit=$edits", T('Include rollbacks')));
    }
  }
  if ($edits) {
    push(@menu, ScriptLink("$action;days=$days;all=$all;showedit=0",
			   T('List only major changes')));
  } else {
    push(@menu, ScriptLink("$action;days=$days;all=$all;showedit=1",
			   T('Include minor changes')));
  }
  $html .= $q->p(join(' | ', (map { ScriptLink("$action;days=$_;all=$all;showedit=$edits", $_); } @RcDays)),
          T('days'), $q->br(), @menu, $q->br(),
	  ScriptLink($action . ';from=' . ($LastUpdate + 1)
		     . ";all=$all;showedit=$edits", T('List later changes')),
	  ScriptLink($rss, T('RSS'), 'rss nopages nodiff'),
	  ScriptLink("$rss;full=1", T('RSS with pages'), 'rss pages nodiff'),
	  ScriptLink("$rss;full=1;diff=1", T('RSS with pages and diff'),
		     'rss pages diff'));
  $html .= $q->p({-class => 'documentation'}, T('Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.')) if UserIsAdmin() and GetParam('all', $ShowAll);
  return $html;
}

sub RcOtherParameters {
  my $more = '';
  foreach (@_, qw(page diff full all showedit rollback rcidonly rcuseronly rchostonly rcclusteronly rcfilteronly match lang followup)) {
    my $val = GetParam($_, '');
    $more .= ";$_=" . UrlEncode($val) if $val;
  }
  return $more;
}

sub RcSelfWebsite {
  my $action = 'rc';
  return "action=$action" . RcOtherParameters(qw(from upto days));
}

sub RcSelfAction {
  my $action = GetParam('action', 'rc');
  return "action=$action" . RcOtherParameters(qw(from upto days));
}

sub RcPreviousAction {
  my $action = GetParam('action', 'rc');
  my $interval = GetParam('days', $RcDefault) * 86400;
  # use delta between from and upto, or use days, whichever is available
  my $to = GetParam('from', GetParam('upto', $Now - $interval));
  my $from = $to - (GetParam('upto') ? GetParam('upto') - GetParam('from') : $interval);
  return "action=$action;from=$from;upto=$to" . RcOtherParameters();
}

sub RcLastAction {
  my $action = GetParam('action', 'rc');
  my $more = "action=$action";
  my $days = GetParam('days', $RcDefault);
  $more .= ";days=$days" if $days != $RcDefault;
  return $more . RcOtherParameters();
}

sub GetFilterForm {
  my $form = $q->strong(T('Filters'));
  $form .= $q->input({-type=>'hidden', -name=>'action', -value=>'rc'});
  $form .= $q->input({-type=>'hidden', -name=>'all', -value=>1}) if (GetParam('all', $ShowAll));
  $form .= $q->input({-type=>'hidden', -name=>'showedit', -value=>1}) if (GetParam('showedit', $ShowEdits));
  if (GetParam('days', $RcDefault) != $RcDefault) {
    $form .= $q->input({-type=>'hidden', -name=>'days', -value=>GetParam('days', $RcDefault)});
  }
  my $table = '';
  foreach my $h (['match' => T('Title:')],
     ['rcfilteronly' => T('Title and Body:')],
     ['rcuseronly' => T('Username:')], ['rchostonly' => T('Host:')],
     ['followup' => T('Follow up to:')]) {
    $table .= $q->Tr($q->td($q->label({-for=>$h->[0]}, $h->[1])),
		     $q->td($q->textfield(-name=>$h->[0], -id=>$h->[0], -size=>20)));
  }
  if (%Languages) {
    $table .= $q->Tr($q->td($q->label({-for=>'rclang'}, T('Language:')))
		     . $q->td($q->textfield(-name=>'lang', -id=>'rclang', -size=>10,
					    -default=>GetParam('lang', ''))));
  }
  return GetFormStart(undef, 'get', 'filter') . $q->p($form) . $q->table($table)
    . $q->p($q->submit('dofilter', T('Go!'))) . $q->end_form;
}

sub RcHtml {
  my ($html, $inlist) = ('', 0);
  # Optimize param fetches and translations out of main loop
  my $all = GetParam('all', $ShowAll);
  my $admin = UserIsAdmin();
  my $rollback_was_possible = 0;
  my $printDailyTear = sub {
    my $date = shift;
    if ($inlist) {
      $html .= '</ul>';
      $inlist = 0;
    }
    $html .= $q->p($q->strong($date));
    if (not $inlist) {
      $html .= '<ul>';
      $inlist = 1;
    }
  };
  my $printRCLine = sub {
    my($id, $ts, $host, $username, $summary, $minor, $revision,
       $languages, $cluster, $last) = @_;
    my $all_revision = $last ? undef : $revision; # no revision for the last one
    $host = QuoteHtml($host);
    my $author = GetAuthorLink($username, $host);
    my $sum = $summary ? $q->span({class=>'dash'}, ' &#8211; ')
      . $q->strong(QuoteHtml($summary)) : '';
    my $edit = $minor ? $q->em({class=>'type'}, T('(minor)')) : '';
    my $lang = @{$languages}
      ? $q->span({class=>'lang'}, '[' . join(', ', @{$languages}) . ']') : '';
    my ($pagelink, $history, $diff, $rollback) = ('', '', '', '');
    if ($all) {
      $pagelink = GetOldPageLink('browse', $id, $all_revision, $id, $cluster);
      my $rollback_is_possible = RollbackPossible($ts);
      if ($admin and ($rollback_is_possible or $rollback_was_possible)) {
	$rollback = $q->submit("rollback-$ts", T('rollback'));
	$rollback_was_possible = $rollback_is_possible;
      } else {
	$rollback_was_possible = 0;
      }
    } elsif ($cluster) {
      $pagelink = GetOldPageLink('browse', $id, $revision, $id, $cluster);
    } else {
      $pagelink = GetPageLink($id, $cluster);
      $history = '(' . GetHistoryLink($id, T('history')) . ')';
    }
    if ($cluster and $PageCluster) {
      $diff .= GetPageLink($PageCluster) . ':';
    } elsif ($UseDiff and GetParam('diffrclink', 1)) {
      if ($revision == 1) {
	$diff .= '(' . $q->span({-class=>'new'}, T('new')) . ')';
      } elsif ($all) {
	$diff .= '(' . ScriptLinkDiff(2, $id, T('diff'), $all_revision) .')';
      } else {
	$diff .= '(' . ScriptLinkDiff($minor ? 2 : 1, $id, T('diff')) . ')';
      }
    }
    $html .= $q->li($q->span({-class=>'time'}, CalcTime($ts)), $diff, $history,
		    $rollback, $pagelink, T(' . . . .'), $author, $sum, $lang,
		    $edit);
  };
  ProcessRcLines($printDailyTear, $printRCLine);
  $html .= '</ul>' if $inlist;
  $html .= $q->p({-class=>'more'}, ScriptLink(RcPreviousAction(), T('More...'), 'more'));
  return GetFormStart(undef, 'get', 'rc') . $html . $q->end_form;
}

sub PrintRcHtml { # to append RC to existing page, or action=rc directly
  my ($id, $standalone) = @_;
  my $rc = ($id eq $RCName or $id eq T($RCName) or T($id) eq $RCName);
  if ($standalone) {
    print GetHeader('', $rc ? NormalToFree($id) : Ts('All changes for %s', NormalToFree($id)));
  }
  if ($standalone or $rc or GetParam('rcclusteronly', '')) {
    print $q->start_div({-class=>'rc'});
    print $q->hr() unless $standalone or GetParam('embed', $EmbedWiki);
    print RcHeader() . RcHtml() . GetFilterForm() . $q->end_div();
  }
  PrintFooter($id) if $standalone;
}

sub RcTextItem {
  my ($name, $value) = @_;
  $value = UnquoteHtml($value);
  $value =~ s/\n+$//;
  $value =~ s/\n+/\n /g;
  return $value ? $name . ': ' . $value . "\n" : '';
}

sub RcTextRevision {
  my($id, $ts, $host, $username, $summary, $minor, $revision,
     $languages, $cluster, $last) = @_;
  my $link = $ScriptName
    . (GetParam('all', $ShowAll) && ! $last
       ? '?' . GetPageParameters('browse', $id, $revision, $cluster, $last)
       : ($UsePathInfo ? '/' : '?') . UrlEncode($id));
  $summary = GetPageContent($id) if GetParam('full', 0);
  print "\n", RcTextItem('title', NormalToFree($id)),
    RcTextItem('description', $summary),
    RcTextItem('generator', GetAuthor($username, $host)),
    RcTextItem('language', join(', ', @{$languages})), RcTextItem('link', $link),
    RcTextItem('last-modified', TimeToW3($ts)),
    RcTextItem('revision', $revision),
    RcTextItem('minor', $minor);
}

sub PrintRcText { # print text rss header and call ProcessRcLines
  local $RecentLink = 0;
  print RcTextItem('title', $SiteName),
    RcTextItem('description', $SiteDescription), RcTextItem('link', $ScriptName),
    RcTextItem('generator', 'Oddmuse'), RcTextItem('rights', $RssRights);
  ProcessRcLines(sub {}, \&RcTextRevision);
}

sub GetRcRss {
  my $date = TimeToRFC822($LastUpdate);
  my @excluded = ();
  if (GetParam("exclude", 1)) {
    foreach (split(/\n/, GetPageContent($RssExclude))) {
      if (/^ ([^ ]+)[ \t]*$/) { # only read lines with one word after one space
	push(@excluded, $1);
      }
    }
  }
  my $rss = qq{<?xml version="1.0" encoding="UTF-8"?>\n};
  if ($RssStyleSheet =~ /\.(xslt?|xml)$/) {
    $rss .= qq{<?xml-stylesheet type="text/xml" href="$RssStyleSheet" ?>\n};
  } elsif ($RssStyleSheet) {
    $rss .= qq{<?xml-stylesheet type="text/css" href="$RssStyleSheet" ?>\n};
  }
  $rss .= qq{<rss version="2.0"
    xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:cc="http://web.resource.org/cc/"
    xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<docs>http://blogs.law.harvard.edu/tech/rss</docs>
};
  my $title = QuoteHtml($SiteName) . ': ' . GetParam('title', QuoteHtml(NormalToFree($HomePage)));
  $rss .= "<title>$title</title>\n";
  $rss .= "<link>$ScriptName?" . RcSelfWebsite() . "</link>\n";
  $rss .= qq{<atom:link href="$ScriptName?} . RcSelfAction() . qq{" rel="self" type="application/rss+xml" />\n};
  $rss .= qq{<atom:link href="$ScriptName?} . RcPreviousAction() . qq{" rel="previous" type="application/rss+xml" />\n};
  $rss .= qq{<atom:link href="$ScriptName?} . RcLastAction() . qq{" rel="last" type="application/rss+xml" />\n};
  if ($SiteDescription) {
    $rss .= "<description>" . QuoteHtml($SiteDescription) . "</description>\n"
  }
  $rss .= "<pubDate>$date</pubDate>\n";
  $rss .= "<lastBuildDate>$date</lastBuildDate>\n";
  $rss .= "<generator>Oddmuse</generator>\n";
  $rss .= "<copyright>$RssRights</copyright>\n" if $RssRights;
  if ($RssLicense) {
    $rss .= join('', map {"<cc:license>" . QuoteHtml($_) . "</cc:license>\n"}
		 (ref $RssLicense eq 'ARRAY' ? @$RssLicense : $RssLicense))
  }
  $rss .= "<wiki:interwiki>$InterWikiMoniker</wiki:interwiki>\n" if $InterWikiMoniker;
  if ($RssImageUrl) {
    $rss .= "<image>\n";
    $rss .= "<url>$RssImageUrl</url>\n";
    $rss .= "<title>$title</title>\n";    # the same as the channel
    $rss .= "<link>$ScriptName?" . RcSelfWebsite() . "</link>\n"; # the same as the channel
    $rss .= "</image>\n";
  }
  my $limit = GetParam("rsslimit", 15); # Only take the first 15 entries
  my $count = 0;
  ProcessRcLines(sub {}, sub {
       my $id = shift;
       return if grep { $id =~ /$_/ } @excluded or ($limit ne 'all' and $count++ >= $limit);
       $rss .= "\n" . RssItem($id, @_);
     });
  $rss .= "</channel>\n</rss>\n";
  return $rss;
}

sub RssItem {
  my ($id, $ts, $host, $username, $summary, $minor, $revision,
      $languages, $cluster, $last) = @_;
  my $name = ItemName($id);
  if (GetParam('full', 0)) { # full page means summary is not shown
    $summary = PageHtml($id, 50 * 1024, T('This page is too big to send over RSS.'));
  } else {
    $summary = QuoteHtml($summary); # page summary must be quoted
  }
  my $date = TimeToRFC822($ts);
  $username = QuoteHtml($username);
  my $rss = "<item>\n";
  $rss .= "<title>$name</title>\n";
  my $link = ScriptUrl(GetParam('all', $cluster)
             ? GetPageParameters('browse', $id, $revision, $cluster, $last)
             : UrlEncode($id));
  $rss .= "<link>$link</link>\n<guid>$link</guid>\n";
  $rss .= "<description>" . QuoteHtml($summary) . "</description>\n" if $summary;
  $rss .= "<pubDate>" . $date . "</pubDate>\n";
  $rss .= "<comments>" . ScriptUrl($CommentsPrefix . UrlEncode($id))
    . "</comments>\n" if $CommentsPattern and $id !~ /$CommentsPattern/;
  $rss .= "<dc:contributor>" . $username . "</dc:contributor>\n" if $username;
  $rss .= "<wiki:status>" . (1 == $revision ? 'new' : 'updated') . "</wiki:status>\n";
  $rss .= "<wiki:importance>" . ($minor ? 'minor' : 'major') . "</wiki:importance>\n";
  $rss .= "<wiki:version>" . $revision . "</wiki:version>\n";
  $rss .= "<wiki:history>" . ScriptUrl("action=history;id=" . UrlEncode($id))
    . "</wiki:history>\n";
  $rss .= "<wiki:diff>" . ScriptUrl("action=browse;diff=1;id=" . UrlEncode($id))
    . "</wiki:diff>\n" if $UseDiff and GetParam('diffrclink', 1);
  return $rss . "</item>\n";
}

sub DoRss {
  print GetHttpHeader('application/xml');
  print GetRcRss();
}

sub DoHistory {
  my $id = shift;
  ValidIdOrDie($id);
  OpenPage($id);
  if (GetParam('raw', 0)) {
    DoRawHistory($id);
  } else {
    DoHtmlHistory($id);
  }
}

sub DoRawHistory {
  my ($id) = @_;
  print GetHttpHeader('text/plain'),
  RcTextItem('title', Ts('History of %s', NormalToFree($OpenPageName))),
  RcTextItem('date', TimeToText($Now)),
  RcTextItem('link', ScriptUrl("action=history;id=$OpenPageName;raw=1")),
  RcTextItem('generator', 'Oddmuse');
  SetParam('all', 1);
  my @languages = split(/,/, $Page{languages});
  RcTextRevision($id, $Page{ts}, $Page{host}, $Page{username}, $Page{summary},
		 $Page{minor}, $Page{revision}, \@languages, undef, 1);
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    @languages = split(/,/, $keep->{languages});
    RcTextRevision($id, $keep->{ts}, $keep->{host}, $keep->{username},
		   $keep->{summary}, $keep->{minor}, $keep->{revision}, \@languages);
  }
}

sub DoHtmlHistory {
  my ($id) = @_;
  print GetHeader('', Ts('History of %s', NormalToFree($id)));
  my $row = 0;
  my $rollback = UserCanEdit($id, 0) && (GetParam('username', '') or UserIsEditor());
  my $date = CalcDay($Page{ts});
  my @html = (GetFormStart(undef, 'get', 'history'));
  push(@html, $q->p({-class => 'documentation'}, T('Using the ｢rollback｣ button on this page will reset the page to that particular point in time, undoing any later changes to this page.'))) if $rollback;
  push(@html, $q->p(# don't use $q->hidden here!
		    $q->input({-type=>'hidden', -name=>'action', -value=>'browse'}),
		    $q->input({-type=>'hidden', -name=>'diff', -value=>'1'}),
		    $q->input({-type=>'hidden', -name=>'id', -value=>$id})));
  # list of rows with revisions, starting with current revision
  push(@html, $q->p($q->submit({-name=>T('Compare')}))) if $UseDiff;
  my @rows = (GetHistoryLine($id, \%Page, $row++, $rollback, $date, 1));
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    my $new = CalcDay($keep->{ts});
    push(@rows, GetHistoryLine($id, $keep, $row++, $rollback, $new, $new ne $date));
    $date = $new;
  }
  # if we can use diff, add radio-buttons and compare buttons if $UseDiff
  if ($UseDiff) {
    push(@html, $q->table({-class=>'history'}, @rows),
	 $q->p($q->submit({-name=>T('Compare')})), $q->end_form());
  } else {
    push(@html, @rows);
  }
  if ($KeepDays and $rollback and $Page{revision}) {
    push(@html, $q->p(ScriptLink('title=' . UrlEncode($id) . ';text='
				 . UrlEncode($DeletedPage) . ';summary='
				 . UrlEncode(T('Deleted')),
				 T('Mark this page for deletion'))));
  }
  print $q->div({-class=>'content history'}, @html);
  PrintFooter($id, 'history');
}

sub GetHistoryLine {
  my ($id, $dataref, $row, $rollback, $date, $newday) = @_;
  my %data = %$dataref;
  my $revision = $data{revision};
  return $q->p(T('No other revisions available')) unless $revision;
  my $html = CalcTime($data{ts});
  if ($row == 0) {    # current revision
    $html .= ' (' . T('current') . ')' if $rollback;
    $html .= ' ' . GetPageLink($id, Ts('Revision %s', $revision));
  } else {
    $html .= ' ' . $q->submit("rollback-$data{ts}", T('rollback')) if $rollback;
    $html .= ' ' . GetOldPageLink('browse', $id, $revision,
          Ts('Revision %s', $revision));
  }
  $html .= T(' . . . .') . ' ' . GetAuthorLink($data{username});
  $html .= $q->span({class=>'dash'}, ' &#8211; ')
    . $q->strong(QuoteHtml($data{summary})) if $data{summary};
  $html .= ' ' . $q->em({class=>'type'}, T('(minor)')) . ' ' if $data{minor};
  if ($UseDiff) {
    my %attr1 = (-type=>'radio', -name=>'diffrevision', -value=>$revision);
    $attr1{-checked} = 'checked' if $row == 1;
    my %attr2 = (-type=>'radio', -name=>'revision', -value=> $row ? $revision : '');
    $attr2{-checked} = 'checked' if $row == 0; # first row is special
    $html = $q->Tr($q->td($q->input(\%attr1)), $q->td($q->input(\%attr2)), $q->td($html));
    $html = $q->Tr($q->td({-colspan=>3}, $q->strong($date))) . $html if $newday;
  } else {
    $html .= $q->br();
    $html = $q->strong($date) . $q->br() . $html if $newday;
  }
  return $html;
}

sub DoContributors {
  my $id = shift;
  SetParam('rcidonly', $id);
  SetParam('all', 1);
  print GetHeader('', Ts('Contributors to %s', NormalToFree($id || $SiteName)));
  my %contrib = ();
  for my $line (GetRcLines(1)) {
    my ($ts, $pagename, $minor, $summary, $host, $username) = @$line;
    $contrib{$username}++ if $username;
  }
  print $q->div({-class=>'content contrib'},
		$q->p(map { GetPageLink($_) } sort(keys %contrib)));
  PrintFooter();
}

sub RollbackPossible {
  my $ts = shift; # there can be no rollback to the most recent change(s) made (1s resolution!)
  return $ts != $LastUpdate && (!$KeepDays || ($Now - $ts) < $KeepDays * 86400); # 24*60*60
}

sub DoRollback {
  my $page = shift;
  my $to = GetParam('to', 0);
  ReportError(T('Missing target for rollback.'), '400 BAD REQUEST') unless $to;
  ReportError(T('Target for rollback is too far back.'), '400 BAD REQUEST') unless $page or RollbackPossible($to);
  ReportError(T('A username is required for ordinary users.'), '403 FORBIDDEN') unless GetParam('username', '') or UserIsEditor();
  my @ids = ();
  if (not $page) {      # cannot just use list length because of ('')
    return unless UserIsAdminOrError(); # only admins can do mass changes
    SetParam('showedit', 1); # make GetRcLines return minor edits as well
    SetParam('all', 1);      # prevent LatestChanges from interfering
    SetParam('rollback', 1); # prevent StripRollbacks from interfering
    my %ids = map { my ($ts, $id) = @$_; $id => 1; } # make unique via hash
      GetRcLines($to); # list all the pages edited since $to
    @ids = keys %ids;
  } else {
    @ids = ($page);
  }
  RequestLockOrError();
  print GetHeader('', T('Rolling back changes')),
    $q->start_div({-class=>'content rollback'}), $q->start_p();
  foreach my $id (@ids) {
    OpenPage($id);
    my ($text, $minor, $ts) = GetTextAtTime($to);
    if ($Page{text} eq $text) {
      print T("The two revisions are the same."), $q->br() if $page; # no message when doing mass revert
    } elsif (not UserCanEdit($id, 1)) {
      print Ts('Editing not allowed: %s is read-only.', $id), $q->br();
    } elsif (not UserIsEditor() and my $rule = BannedContent($text)) {
      print Ts('Rollback of %s would restore banned content.', $id), $rule, $q->br();
    } else {
      Save($id, $text, Ts('Rollback to %s', TimeToText($to)), $minor, ($Page{host} ne $q->remote_addr()));
      print Ts('%s rolled back', GetPageLink($id)), ($ts ? ' ' . Ts('to %s', TimeToText($to)) : ''), $q->br();
    }
  }
  WriteRcLog('[[rollback]]', $page, $to); # leave marker
  print $q->end_p() . $q->end_div();
  ReleaseLock();
  PrintFooter($page, 'edit');
}

sub DoAdminPage {
  my ($id, @rest) = @_;
  my @menu = ();
  push(@menu, ScriptLink('action=index',    T('Index of all pages'), 'index')) if $Action{index};
  push(@menu, ScriptLink('action=version',  T('Wiki Version'),     'version')) if $Action{version};
  push(@menu, ScriptLink('action=password', T('Password'), 'password')) if $Action{password};
  push(@menu, ScriptLink('action=maintain', T('Run maintenance'), 'maintain')) if $Action{maintain};
  my @locks;
  for my $pattern (@KnownLocks) {
    for my $name (Glob($pattern)) {
      if (IsDir($LockDir . $name)) {
	push(@locks, $name);
      }
    }
  }
  if (@locks and $Action{unlock}) {
    push(@menu, ScriptLink('action=unlock', T('Unlock Wiki'), 'unlock') . ' (' . join(', ', @locks) . ')');
  };
  if (UserIsAdmin()) {
    if ($Action{editlock}) {
      if (IsFile("$DataDir/noedit")) {
	push(@menu, ScriptLink('action=editlock;set=0', T('Unlock site'), 'editlock 0'));
      } else {
	push(@menu, ScriptLink('action=editlock;set=1', T('Lock site'),   'editlock 1'));
      }
    }
    if ($id and $Action{pagelock}) {
      my $title = NormalToFree($id);
      if (IsFile(GetLockedPageFile($id))) {
	push(@menu, ScriptLink('action=pagelock;set=0;id=' . UrlEncode($id),
			       Ts('Unlock %s', $title), 'pagelock 0'));
      } else {
	push(@menu, ScriptLink('action=pagelock;set=1;id=' . UrlEncode($id),
			       Ts('Lock %s',   $title), 'pagelock 1'));
      }
    }
    push(@menu, ScriptLink('action=clear', T('Clear Cache'), 'clear')) if $Action{clear};
  }
  foreach my $sub (@MyAdminCode) {
    $sub->($id, \@menu, \@rest);
    $Message .= $q->p($@) if $@; # since this happens before GetHeader is called, the message will be shown
  }
  print GetHeader('', T('Administration')),
    $q->div({-class=>'content admin'}, $q->p(T('Actions:')), $q->ul($q->li(\@menu)),
      $q->p(T('Important pages:')) . $q->ul(map { $q->li(GetPageOrEditLink($_, NormalToFree($_))) if $_;
                  } sort keys %AdminPages),
      $q->p(Ts('To mark a page for deletion, put <strong>%s</strong> on the first line.',
	       $DeletedPage)), @rest);
  PrintFooter();
}

sub GetPageParameters {
  my ($action, $id, $revision, $cluster, $last) = @_;
  $id = FreeToNormal($id);
  my $link = "action=$action;id=" . UrlEncode($id);
  $link .= ";revision=$revision" if $revision and not $last;
  $link .= ';rcclusteronly=' . UrlEncode($cluster) if $cluster;
  return $link;
}

sub GetOldPageLink {
  my ($action, $id, $revision, $name, $cluster, $last) = @_;
  return ScriptLink(GetPageParameters($action, $id, $revision, $cluster, $last),
		    NormalToFree($name), 'revision');
}

sub GetSearchLink {
  my ($text, $class, $name, $title) = @_;
  my $id = UrlEncode(QuoteRegexp('"' . $text . '"'));
  $name = UrlEncode($name);
  $text = NormalToFree($text);
  $id =~ s/_/+/g;   # Search for url-escaped spaces
  return ScriptLink('search=' . $id, $text, $class, $name, $title);
}

sub ScriptLinkDiff {
  my ($diff, $id, $text, $new, $old) = @_;
  my $action = 'action=browse;diff=' . $diff . ';id=' . UrlEncode($id);
  $action .= ";diffrevision=$old" if $old;
  $action .= ";revision=$new"     if $new;
  return ScriptLink($action, $text, 'diff');
}

sub Code {
  my ($str) = @_;
  my $num = unpack("L",B::hash($str)); # 32-bit integer
  my $code = sprintf("%o", $num); # octal is 0-7
  return substr($code, 0, 4); # four numbers
}

sub ColorCode {
  my $code = Code(@_);
  my @indexes = split(//, $code); # four numbers
  my @colors = qw/red orange yellow green blue indigo violet white/;
  return $q->span({-class => 'ip-code', -title => T('Anonymous')},
		  join('', map { $q->span({-class => $colors[$_]}, $_) }
		       @indexes));
}

sub GetAuthor {
  my ($username, $host) = @_;
  return $username if $username;
  return T('Anonymous') if $host eq 'Anonymous';
  return Code($host);
}

sub GetAuthorLink {
  my ($username, $host) = @_;
  $username = FreeToNormal($username);
  my $name = NormalToFree($username);
  if (ValidId($username) ne '') { # ValidId() returns error string
    $username = '';     # Just pretend it isn't there.
  }
  if ($username and $RecentLink) {
    return ScriptLink(UrlEncode($username), $name, 'author');
  } elsif ($username) {
    return $q->span({-class=>'author'}, $name);
  }
  return T('Anonymous') if $host eq 'Anonymous';
  return ColorCode($host);
}

sub GetHistoryLink {
  my ($id, $text) = @_;
  my $action = 'action=history;id=' . UrlEncode(FreeToNormal($id));
  return ScriptLink($action, $text, 'history');
}

sub GetRCLink {
  my ($id, $text) = @_;
  return ScriptLink('action=rc;all=1;from=1;showedit=1;rcidonly='
		    . UrlEncode(FreeToNormal($id)), $text, 'rc');
}

sub GetHeader {
  my ($id, $title, $oldId, $nocache, $status) = @_;
  my $embed = GetParam('embed', $EmbedWiki);
  my $result = GetHttpHeader('text/html', $nocache, $status);
  if ($oldId) {
    $Message .= $q->p('(' . Ts('redirected from %s', GetEditLink($oldId, $oldId)) . ')');
  }
  $result .= GetHtmlHeader(Ts('%s:', $SiteName) . ' ' . UnWiki($title), $id);
  if ($embed) {
    $result .= $q->div({-class=>'header'}, $q->div({-class=>'message'}, $Message)) if $Message;
    return $result;
  }
  $result .= GetHeaderDiv($id, $title, $oldId, $embed);
  return $result . $q->start_div({-class=>'wrapper'});
}

sub GetHeaderDiv {
  my ($id, $title, $oldId, $embed) = @_;
  my $result .= '<header>';
  if (not $embed and $LogoUrl) {
    my $url = $IndexHash{$LogoUrl} ? GetDownloadLink($LogoUrl, 2) : $LogoUrl;
    $result .= ScriptLink(UrlEncode($HomePage), $q->img({-src=>$url, -alt=>T('[Home]'), -class=>'logo'}), 'logo');
  }
  $result .= '<nav>';
  if (GetParam('toplinkbar', $TopLinkBar) != 2) {
    $result .= GetGotoBar($id);
    if (%SpecialDays) {
      my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
      if ($SpecialDays{($mon + 1) . '-' . $mday}) {
	$result .= $q->br() . $q->span({-class=>'specialdays'},
				       $SpecialDays{($mon + 1) . '-' . $mday});
      }
    }
  }
  $result .= GetSearchForm() if GetParam('topsearchform', $TopSearchForm) != 2;
  $result .= '</nav>';
  $result .= $q->div({-class=>'message'}, $Message) if $Message;
  $result .= GetHeaderTitle($id, $title, $oldId);
  $result .= '</header>';
  return $result;
}

sub GetHeaderTitle {
  my ($id, $title, $oldId) = @_;
  return $q->h1($title) if $id eq '';
  return $q->h1(GetSearchLink($id, '', '', T('Click to search for references to this page')));
}

sub GetHttpHeader {
  return if $HeaderIsPrinted; # When calling ReportError, we don't know whether HTTP headers have
  $HeaderIsPrinted = 1;       # already been printed. We want them printed just once.
  my ($type, $ts, $status, $encoding) = @_;
  $q->charset($type =~ m!^(text/|application/xml)! ? 'utf-8' : ''); # text/plain, text/html, application/xml: UTF-8
  my %headers = (-cache_control=>($UseCache < 0 ? 'no-cache' : 'max-age=10'));
  # Set $ts when serving raw content that cannot be modified by cookie
  # parameters; or 'nocache'; or undef. If you provide a $ts, the last-modified
  # header generated will by used by HTTP/1.0 clients. If you provide no $ts,
  # the etag header generated will be used by HTTP/1.1 clients. In this
  # situation, cookie parameters can influence the look of the page and we
  # cannot rely on $LastUpdate. HTTP/1.0 clients will ignore etags. See RFC 2616
  # section 13.3.4.
  if (GetParam('cache', $UseCache) >= 2 and $ts ne 'nocache') {
    $headers{'-last-modified'} = TimeToRFC822($ts) if $ts;
    $headers{-etag} = PageEtag();
  }
  $headers{-type} = GetParam('mime-type', $type);
  $headers{-status} = $status if $status;
  $headers{-Content_Encoding} = $encoding if $encoding;
  my $cookie = Cookie();
  $headers{-cookie} = $cookie if $cookie;
  if ($q->request_method() eq 'HEAD') {
    print $q->header(%headers), "\n\n"; # add newlines for FCGI because of exit()
    exit; # total shortcut -- HEAD never expects anything other than the header!
  }
  return $q->header(%headers);
}

sub CookieData {
  my ($changed, %params);
  foreach my $key (keys %CookieParameters) {
    my $default = $CookieParameters{$key};
    my $value = GetParam($key, $default);
    $params{$key} = $value if $value ne $default;
    # The cookie is considered to have changed under the following
    # condition: If the value was already set, and the new value is
    # not the same as the old value, or if there was no old value, and
    # the new value is not the default.
    my $change = (defined $OldCookie{$key} ? ($value ne $OldCookie{$key}) : ($value ne $default));
    $changed = 1 if $change; # note if any parameter changed and needs storing
  }
  return $changed, %params;
}

sub Cookie {
  my ($changed, %params) = CookieData(); # params are URL encoded
  if ($changed) {
    my $cookie = join(UrlEncode($FS), %params); # no CTL in field values
    return $q->cookie(-name=>$CookieName, -value=>$cookie, -expires=>'+2y', secure=>$ENV{'HTTPS'}, httponly=>1);
  }
  return '';
}

sub GetHtmlHeader {   # always HTML!
  my ($title, $id) = @_;
  my $edit_link = $id ? '<link rel="alternate" type="application/wiki" title="'
      . T('Edit this page') . '" href="' . ScriptUrl('action=edit;id=' . UrlEncode($id)) . '" />' : '';
  my $theme = GetParam('theme', 'default');
  return $DocumentHeader
      . $q->head($q->title($title) . $edit_link
		 . GetCss() . GetRobots() . GetFeeds() . $HtmlHeaders
		 . '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />')
      . qq{<body class="$theme" lang="$CurrentLanguage">};
}

sub GetRobots { # NOINDEX for non-browse pages.
  if (GetParam('action', 'browse') eq 'browse' and not GetParam('revision', '')) {
    return '<meta name="robots" content="INDEX,FOLLOW" />';
  } else {
    return '<meta name="robots" content="NOINDEX,FOLLOW" />';
  }
}

sub GetFeeds {      # default for $HtmlHeaders
  my $html = '<link rel="alternate" type="application/rss+xml" title="'
    . QuoteHtml($SiteName) . '" href="' . $ScriptName . '?action=rss" />';
  my $id = GetId(); # runs during Init, not during DoBrowseRequest
  $html .= '<link rel="alternate" type="application/rss+xml" title="'
    . QuoteHtml("$SiteName: $id") . '" href="' . $ScriptName
    . '?action=rss;rcidonly=' . UrlEncode(FreeToNormal($id)) . '" />' if $id;
  my $username = GetParam('username', '');
  $html .= '<link rel="alternate" type="application/rss+xml" '
    . 'title="Follow-ups for ' . NormalToFree($username) . '" '
    . 'href="' . ScriptUrl('action=rss;followup=' . UrlEncode($username))
    . '" />' if $username;
  return $html;
}

sub GetCss {      # prevent javascript injection
  my @css = map { my $x = $_; $x =~ s/\".*//; $x; } split(/\s+/, GetParam('css', ''));
  push (@css, ref $StyleSheet ? @$StyleSheet : $StyleSheet) if $StyleSheet and not @css;
  if ($IndexHash{$StyleSheetPage} and not @css) {
    push (@css, "$ScriptName?action=browse;id=" . UrlEncode($StyleSheetPage) . ";raw=1;mime-type=text/css")
  }
  push (@css, 'https://oddmuse.org/default.css') unless @css;
  return join('', map { qq(<link type="text/css" rel="stylesheet" href="$_" />) } @css);
}

sub PrintPageContent {
  my ($text, $revision, $comment) = @_;
  print $q->start_div({-class=>'content browse', -lang=>GetLanguage($text)});
  # This is a lot like PrintPageHtml except that it also works for older revisions
  if ($revision eq '' and $Page{blocks} and GetParam('cache', $UseCache) > 0) {
    PrintCache();
  } else {
    my $savecache = ($Page{revision} > 0 and $revision eq ''); # new page not cached
    PrintWikiToHTML($text, $savecache, $revision); # unlocked, with anchors, unlocked
  }
  if ($comment) {
    print $q->start_div({-class=>'preview'}), $q->hr();
    print $q->h2(T('Preview:'));
    # no caching, current revision, unlocked
    PrintWikiToHTML(AddComment('', $comment));
    print $q->hr(), $q->h2(T('Preview only, not yet saved')), $q->end_div();
  }
  print $q->end_div();
}

sub PrintFooter {
  my ($id, $rev, $comment, $page) = @_;
  if (GetParam('embed', $EmbedWiki)) {
    print $q->end_html, "\n";
    return;
  }
  PrintMyContent($id) if defined(&PrintMyContent);
  foreach my $sub (@MyFooters) {
    print $sub->(@_);
  }
  print $q->end_html, "\n";
}

sub WrapperEnd { # called via @MyFooters
  return $q->start_div({-class=>'wrapper close'}) . $q->end_div() . $q->end_div(); # closes content
}

sub DefaultFooter { # called via @MyFooters
  my ($id, $rev, $comment, $page) = @_;
  my $html = $q->hr();
  $html .= GetGotoBar($id) if GetParam('toplinkbar', $TopLinkBar) != 1;
  $html .= GetFooterLinks($id, $rev);
  $html .= GetFooterTimestamp($id, $rev, $page);
  $html .= GetSearchForm() if GetParam('topsearchform', $TopSearchForm) != 1;
  if ($DataDir =~ m|/tmp/|) {
    $html .= $q->p($q->strong(T('Warning') . ': ')
    . Ts('Database is stored in temporary directory %s', $DataDir));
  }
  $html .= T($FooterNote) if $FooterNote;
  $html .= $q->p(Ts('%s seconds', (time - $Now))) if GetParam('timing', 0);
  return "<footer>$html</footer>";
}

sub GetFooterTimestamp {
  my ($id, $rev, $page) = @_;
  $page //= \%Page;
  if ($id and $rev ne 'history' and $rev ne 'edit' and $page->{revision}) {
    my @elements = (($rev eq '' ? T('Last edited') : T('Edited')), TimeToText($page->{ts}),
		    Ts('by %s', GetAuthorLink($page->{username})));
    push(@elements, ScriptLinkDiff(2, $id, T('(diff)'), $rev)) if $UseDiff and $page->{revision} > 1;
    return $q->div({-class=>'time'}, @elements);
  }
  return '';
}

sub GetFooterLinks {
  my ($id, $rev) = @_;
  my @elements;
  if ($id and $rev ne 'history' and $rev ne 'edit') {
    if ($CommentsPattern) {
      if ($id =~ /$CommentsPattern/) {
	push(@elements, GetPageLink($1, undef, 'original', T('a'))) if $1;
      } else {
	push(@elements, GetPageLink($CommentsPrefix . $id, undef, 'comment', T('c')));
      }
    }
    if (UserCanEdit($id, 0)) {
      if ($rev) {		# showing old revision
	push(@elements, GetOldPageLink('edit', $id, $rev, Ts('Edit revision %s of this page', $rev)));
      } else {			# showing current revision
	push(@elements, GetEditLink($id, T('Edit this page'), undef, T('e')));
      }
    } else {			# no permission or generated page
      push(@elements, ScriptLink('action=password', T('This page is read-only'), 'password'));
    }
  }
  push(@elements, GetHistoryLink($id, T('View other revisions'))) if $Action{history} and $id and $rev ne 'history';
  push(@elements, GetPageLink($id, T('View current revision')),
       GetRCLink($id, T('View all changes'))) if $Action{history} and $rev ne '';
  if ($Action{contrib} and $id and $rev eq 'history') {
    push(@elements, ScriptLink("action=contrib;id=" . UrlEncode($id), T('View contributors'), 'contrib'));
  }
  if ($Action{admin} and GetParam('action', '') ne 'admin') {
    my $action = 'action=admin';
    $action .= ';id=' . UrlEncode($id) if $id;
    push(@elements, ScriptLink($action, T('Administration'), 'admin'));
  }
  return @elements ? $q->div({-class=>'edit bar'}, @elements) : '';
}

sub GetCommentForm {
  my ($id, $rev, $comment) = @_;
  if ($CommentsPattern ne '' and $id and $rev ne 'history' and $rev ne 'edit'
      and $id =~ /$CommentsPattern/ and UserCanEdit($id, 0, 1)) {
    my $html = $q->div({-class=>'comment'},
		       GetFormStart(undef, undef, 'comment'),
		       $q->p(GetHiddenValue('title', $id),
			     $q->label({-for=>'aftertext', -accesskey=>T('c')},
				       T('Add your comment here:')), $q->br(),
			     GetTextArea('aftertext', $comment, 10)),
		       $EditNote,
		       $q->p($q->span({-class=>'username'},
				      $q->label({-for=>'username'}, T('Username:')), ' ',
				      $q->textfield(-name=>'username', -id=>'username',
						    -default=>GetParam('username', ''),
						    -override=>1, -size=>20, -maxlength=>50)),
			     $q->span({-class=>'homepage'},
				      $q->label({-for=>'homepage'}, T('Homepage URL:')), ' ',
				      $q->textfield(-name=>'homepage', -id=>'homepage',
						    -default=>GetParam('homepage', ''),
						    -override=>1, -size=>40, -maxlength=>100))),
		       $q->p($q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save')), ' ',
			     $q->submit(-name=>'Preview', -accesskey=>T('p'), -value=>T('Preview'))),
		       $q->end_form());
    foreach my $sub (@MyFormChanges) {
      $html = $sub->($html, 'comment');
    }
    return $html;
  }
  return '';
}

sub GetFormStart {
  my ($ignore, $method, $class) = @_;
  $method ||= 'post';
  $class  ||= 'form';
  return $q->start_multipart_form(-method=>$method, -action=>$FullUrl,
				  -accept_charset=>'utf-8', -class=>$class);
}

sub GetSearchForm {
  my $html = GetFormStart(undef, 'get', 'search');
  my $replacing = (GetParam('search') ne '' and UserIsAdmin());
  $html .= $q->start_p({-class => ($replacing ? 'replace' : 'search')});
  $html .= $q->span({-class=>'search'},
                    $q->label({-for=>'search'}, T('Search:')) . ' '
                    . $q->textfield(-name=>'search', -id=>'search', -size=>15, -accesskey=>T('f'))) . ' ';
  if ($replacing) { # see DoBrowseRequest
    $html .= $q->span({-class=>'replace'},
                      $q->label({-for=>'replace'}, T('Replace:')) . ' '
                      . $q->textfield(-name=>'replace', -id=>'replace', -size=>20)) . ' '
        . $q->span({-class=>'delete'},
                   $q->label({-for=>'delete', -title=>'If you want to replace matches with the empty string'}, T('Delete')) . ' '
                   . $q->input({-type=>'checkbox', -name=>'delete'})) . ' '
	. $q->submit('preview', T('Preview')) . ' ';
  }
  if (GetParam('matchingpages', $MatchingPages)) {
    $html .= $q->span({-class=>'match'},
                      $q->label({-for=>'matchingpage'}, T('Filter:')) . ' '
                      . $q->textfield(-name=>'match', -id=>'matchingpage', -size=>15)) . ' ';
  }
  if (%Languages) {
    $html .= $q->span({-class=>'lang'},
                      $q->label({-for=>'searchlang'}, T('Language:')) . ' '
                      . $q->textfield(-name=>'lang', -id=>'searchlang', -size=>5, -default=>GetParam('lang', ''))) . ' ';
  }
  $html .= $q->submit('dosearch', T('Go!')) . $q->end_p . $q->end_form;
  return $html;
}

sub GetGotoBar { # ignore $id parameter
  return $q->span({-class=>'gotobar bar'}, (map { GetPageLink($_) } @UserGotoBarPages), $UserGotoBar);
}

# return list of summaries between two revisions, assuming the open page is the upper one
sub DiffSummary {
  my ($current, $from, $to) = @_;
  my @summaries = ($current); # the current summary is not in a kept file
  unshift(@summaries, map { GetKeptRevision($_)->{summary} } ($from + 1 .. $to - 1)) if $from and $to;
  my ($last, @result);
  for my $summary (@summaries) {
    $summary =~ s/^\s+//; # squish leading whitespace
    next unless $summary; # not empty
    next if $summary eq $last; # not a repeat
    push(@result, QuoteHtml($summary));
    $last = $summary;
  }
  return '' unless @result;
  return $q->p({-class=>'summary'}, T('Summary:'), $result[0]) if @result == 1;
  return $q->div({-class=>'summary'}, $q->p(T('Summary:')), $q->ul($q->li(\@result)));
}

sub PrintHtmlDiff {
  my ($type, $old, $page, $current) = @_;
  $page //= \%Page;
  $current //= $page->{revision};
  $type = 2 if $old or $page->{revision} != $current; # explicit revisions means minor diffs!
  $old //= $page->{$type == 1 ? 'lastmajor' : 'revision'} - 1; # default diff revision if none given
  my ($diff, $summary);
  my $intro = T('Last edit');
  # use the cached diff and summary if possible
  if ($old == $page->{$type == 1 ? 'lastmajor' : 'revision'} - 1) {
    $diff = GetCacheDiff($type == 1 ? 'major' : 'minor', $page);
    # just add the last diff in the right format
    $summary = DiffSummary($page->{$type == 1 ? 'lastmajorsummary' : 'summary'});
  }
  # if there was no cached diff: compute it, and new intro
  if (not $diff and $old > 0) {
    ($diff, my $keptPage) = GetKeptDiff($page->{text}, $old);
    my $to = $page->{revision} != $current ? Ts('revision %s', $page->{revision}) : T('current revision');
    $intro = Tss('Difference between revision %1 and %2', $old, $to);
    $summary = DiffSummary($page->{summary}, $old, $page->{revision});
  }
  # if this is the last major diff and there are minor diffs to look at, and we
  # didn't request a particular old revision
  if ($type == 1 and $page->{lastmajor} and $page->{lastmajor} != $current) {
    $intro = Ts('Last major edit (%s)', ScriptLinkDiff(2, $OpenPageName, T('later minor edits'),
						       undef, $page->{lastmajor} || 1));
  }
  $diff =~ s!<p><strong>(.*?)</strong></p>!'<p><strong>' . T($1) . '</strong></p>'!eg;
  $diff ||= T('No diff available.');
  print $q->div({-class=>'diff'}, $q->p($q->b($intro)), $summary, $diff);
}

sub GetCacheDiff {
  my ($type, $page) = @_;
  my $diff = $page->{"diff-$type"};
  $diff = $page->{"diff-minor"} if $diff eq '1'; # if major eq minor diff
  return $diff;
}

sub GetKeptDiff {
  my ($new, $revision) = @_;
  $revision ||= 1;
  my ($revisionPage, $rev) = GetTextRevision($revision, 1);
  return '', $revisionPage unless $rev;
  return T("The two revisions are the same."), $revisionPage if $revisionPage->{text} eq $new;
  return GetDiff($revisionPage->{text}, $new, $rev), $revisionPage;
}

sub DoDiff {      # Actualy call the diff program
  CreateDir($TempDir);
  my $oldName = "$TempDir/old";
  my $newName = "$TempDir/new";
  RequestLockDir('diff') or return '';
  WriteStringToFile($oldName, $_[0]);
  WriteStringToFile($newName, $_[1]);
  my $command = encode_utf8("diff -- \Q$oldName\E \Q$newName\E");
  my $diff_out = decode_utf8(qx($command));
  ReleaseLockDir('diff');
  $diff_out =~ s/\n\K\\ No newline.*\n//g; # Get rid of common complaint.
  # No need to unlink temp files--next diff will just overwrite.
  return $diff_out;
}

sub GetDiff {
  my ($old, $new, $revision) = @_;
  my $old_is_file = (TextIsFile($old))[0] || '';
  my $old_is_image = ($old_is_file =~ /^image\//);
  my $new_is_file = TextIsFile($new);
  if ($old_is_file or $new_is_file) {
    return $q->p($q->strong(T('Old revision:')))
      . $q->div({-class=>'old'}, # don't pring new revision, because that's the one that gets shown!
    $q->p($old_is_file ? GetDownloadLink($OpenPageName, $old_is_image, $revision) : $old))
    }
  $old =~ s/[\r\n]+/\n/g;
  $new =~ s/[\r\n]+/\n/g;
  return ImproveDiff(DoDiff($old, $new));
}

sub ImproveDiff {      # NO NEED TO BE called within a diff lock
  my $diff = QuoteHtml(shift);
  $diff =~ tr/\r//d;
  my @hunks = split (/^(\d+,?\d*[adc]\d+,?\d*\n)/m, $diff);
  my $result = shift (@hunks);  # intro
  while ($#hunks > 0) {         # at least one header and a real hunk
    my $header = shift (@hunks);
    $header =~ s|^(\d+.*c.*)|<p><strong>Changed:</strong></p>| # T('Changed:')
      or $header =~ s|^(\d+.*d.*)|<p><strong>Deleted:</strong></p>| # T('Deleted:')
	or $header =~ s|^(\d+.*a.*)|<p><strong>Added:</strong></p>|; # T('Added:')
    $result .= $header;
    my $chunk = shift (@hunks);
    my ($old, $new) = split (/\n---\n/, $chunk, 2);
    if ($old and $new) {
      ($old, $new) = DiffMarkWords($old, $new);
      $result .= "$old<p><strong>to</strong></p>\n$new"; # T('to')
    } else {
      if (substr($chunk, 0, 2) eq '&g') {
	$result .= DiffAddPrefix(DiffStripPrefix($chunk), '&gt; ', 'new');
      } else {
	$result .= DiffAddPrefix(DiffStripPrefix($chunk), '&lt; ', 'old');
      }
    }
  }
  return $result;
}

sub DiffMarkWords {
  my ($old, $new) = map { DiffStripPrefix($_) } @_;
  my @diffs = grep(/^\d/, split(/\n/, DoDiff(join("\n", split(/\s+|\b/, $old)) . "\n",
					     join("\n", split(/\s+|\b/, $new)) . "\n")));
  foreach my $diff (reverse @diffs) { # so that new html tags don't confuse word counts
    my ($start1, $end1, $type, $start2, $end2) = $diff =~ /^(\d+),?(\d*)([adc])(\d+),?(\d*)$/gm;
    if ($type eq 'd' or $type eq 'c') {
      $end1 ||= $start1;
      $old = DiffHtmlMarkWords($old, $start1, $end1);
    }
    if ($type eq 'a' or $type eq 'c') {
      $end2 ||= $start2;
      $new = DiffHtmlMarkWords($new, $start2, $end2);
    }
  }
  return (DiffAddPrefix($old, '&lt; ', 'old'),
	  DiffAddPrefix($new, '&gt; ', 'new'));
}

sub DiffHtmlMarkWords {
  my ($text, $start, $end) = @_;
  my @fragments = split(/(\s+|\b)/, $text);
  splice(@fragments, 2 * ($start - 1), 0, '<strong class="changes">');
  splice(@fragments, 2 * $end, 0, '</strong>');
  my $result = join('', @fragments);
  $result =~ s!&<(/?)strong([^>]*)>(amp|[gl]t);!<$1strong$2>&$3;!g;
  $result =~ s!&(amp|[gl]t)<(/?)strong([^>]*)>;!&$1;<$2strong$3>!g;
  return $result;
}

sub DiffStripPrefix {
  my $str = shift;
  $str =~ s/^&[lg]t; //gm;
  return $str;
}

sub DiffAddPrefix {
  my ($str, $prefix, $class) = @_;
  my @lines = split(/\n/, $str);
  for my $line (@lines) {
    $line = $prefix . $line;
  }
  return $q->div({-class=>$class}, $q->p(join($q->br(), @lines)));
}

sub ParseData {
  my $data = shift;
  my %result;
  while ($data =~ /(\S+?): (.*?)(?=\n[^ \t]|\Z)/gs) {
    my ($key, $value) = ($1, $2);
    $value =~ s/\n\t/\n/g;
    $result{$key} = $value;
  }
  # return unless %result; # undef instead of empty hash # TODO should we do that?
  return wantarray ? %result : \%result; # return list sometimes for compatibility
}

sub OpenPage {      # Sets global variables
  my $id = shift;
  return if $OpenPageName eq $id;
  if ($IndexHash{$id}) {
    %Page = %{ParseData(ReadFileOrDie(GetPageFile($id)))};
  } else {
    %Page = ();
    $Page{ts} = $Now;
    $Page{revision} = 0;
  }
  $OpenPageName = $id;
}

sub GetTextAtTime { # call with opened page, return $minor if all pages between now and $ts are minor!
  my $ts = shift;
  my $minor = $Page{minor};
  return ($Page{text}, $minor, 0) if $Page{ts} <= $ts; # current page is old enough
  return ($DeletedPage, $minor, 0) if $Page{revision} == 1 and $Page{ts} > $ts; # created after $ts
  my $keep = {};    # info may be needed after the loop
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    $keep = GetKeptRevision($revision);
    # $minor = 0 unless defined $keep; # TODO?
    $minor = 0 if not $keep->{minor} and $keep->{ts} >= $ts; # ignore keep{minor} if keep{ts} is too old
    return ($keep->{text}, $minor, 0) if $keep->{ts} <= $ts;
  }
  return ($DeletedPage, $minor, 0) if $keep->{revision} == 1; # then the page was created after $ts!
  return ($keep->{text}, $minor, $keep->{ts}); # the oldest revision available is not old enough
}

sub GetTextRevision {
  my ($revision, $quiet) = @_;
  $revision =~ s/\D//g;   # Remove non-numeric chars
  return wantarray ? (\%Page, $revision) : \%Page unless $revision and $revision ne $Page{revision};
  my $keep = GetKeptRevision($revision);
  if (not defined $keep) {
    $Message .= $q->p(Ts('Revision %s not available', $revision)
		      . ' (' . T('showing current revision instead') . ')') unless $quiet;
    return wantarray ? (\%Page, '') : \%Page;
  }
  $Message .= $q->p(Ts('Showing revision %s', $revision)) unless $quiet;
  return wantarray ? ($keep, $revision) : $keep;
}

sub GetPageContent {
  my $id = shift;
  return ParseData(ReadFileOrDie(GetPageFile($id)))->{text} if $IndexHash{$id};
  return '';
}

sub GetKeptRevision {   # Call after OpenPage
  my ($status, $data) = ReadFile(GetKeepFile($OpenPageName, (shift)));
  return unless $status;
  return ParseData($data);
}

sub GetPageFile {
  my ($id) = @_;
  return  "$PageDir/$id.pg";
}

sub GetKeepFile {
  my ($id, $revision) = @_; die "No revision for $id" unless $revision; #FIXME
  return GetKeepDir($id) . "/$revision.kp";
}

sub GetKeepDir {
  my $id = shift; die 'No id' unless $id; #FIXME
  return "$KeepDir/$id";
}

sub GetKeepFiles {
  return Glob(GetKeepDir(shift) . '/*.kp'); # files such as 1.kp, 2.kp, etc.
}

sub GetKeepRevisions {
  my @result = sort {$b <=> $a} map { m/([0-9]+)\.kp$/; $1; } GetKeepFiles(shift);
  return @result;
}

# Always call SavePage within a lock.
sub SavePage { # updating the cache will not change timestamp and revision!
  ReportError(T('Cannot save a nameless page.'),         '400 BAD REQUEST', 1) unless $OpenPageName;
  ReportError(T('Cannot save a page without revision.'), '400 BAD REQUEST', 1) unless $Page{revision};
  CreateDir($PageDir);
  WriteStringToFile(GetPageFile($OpenPageName), EncodePage(%Page));
}

sub SaveKeepFile {
  return if ($Page{revision} < 1); # Don't keep 'empty' revision
  delete $Page{blocks};      # delete some info from the page
  delete $Page{flags};
  delete $Page{'diff-major'};
  delete $Page{'diff-minor'};
  $Page{'keep-ts'} = $Now;  # expire only $KeepDays from $Now!
  CreateDir($KeepDir);
  CreateDir(GetKeepDir($OpenPageName));
  WriteStringToFile(GetKeepFile($OpenPageName, $Page{revision}), EncodePage(%Page));
}

sub EncodePage {
  my @data = @_;
  my $result = '';
  $result .= (shift @data) . ': ' . EscapeNewlines(shift @data) . "\n" while (@data);
  return $result;
}

sub EscapeNewlines {
  $_[0] =~ s/\n/\n\t/g;   # modify original instead of copying
  return $_[0];
}

sub ExpireAllKeepFiles {
  foreach my $name (AllPagesList()) {
    print $q->br(), GetPageLink($name);
    OpenPage($name);
    my $delete = PageDeletable();
    if ($delete) {
      my $status = DeletePage($OpenPageName);
      print ' ', ($status ? T('not deleted:') . ' ' . $status : T('deleted'));
    } else {
      ExpireKeepFiles();
    }
  }
}

sub ExpireKeepFiles {   # call with opened page
  return unless $KeepDays;
  my $expirets = $Now - ($KeepDays * 86400); # 24*60*60
  foreach my $revision (GetKeepRevisions($OpenPageName)) {
    my $keep = GetKeptRevision($revision);
    next if $keep->{'keep-ts'} >= $expirets;
    next if $KeepMajor and $keep->{revision} == $Page{lastmajor};
    Unlink(GetKeepFile($OpenPageName, $revision));
  }
}

sub ReadFile {
  if (open(my $IN, '<:encoding(UTF-8)', encode_utf8(shift))) {
    local $/ = undef; # Read complete files
    my $data=<$IN>;
    close $IN;
    return (1, $data);
  }
  return (0, '');
}

sub ReadFileOrDie  {
  my ($file) = @_;
  my ($status, $data);
  ($status, $data) = ReadFile($file);
  if (not $status) {
    ReportError(Ts('Cannot open %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
  }
  return $data;
}

sub WriteStringToFile {
  my ($file, $string) = @_;
  open(my $OUT, '>:encoding(UTF-8)', encode_utf8($file))
    or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
  print $OUT  $string;
  close($OUT);
}

sub AppendStringToFile {
  my ($file, $string) = @_;
  open(my $OUT, '>>:encoding(UTF-8)', encode_utf8($file))
    or ReportError(Ts('Cannot write %s', $file) . ": $!", '500 INTERNAL SERVER ERROR');
  print $OUT  $string;
  close($OUT);
}

sub IsFile    { return -f encode_utf8(shift); }
sub IsDir     { return -d encode_utf8(shift); }
sub ZeroSize  { return -z encode_utf8(shift); }
sub Unlink    { return unlink(map { encode_utf8($_) } @_); }
sub Modified  { return (stat(encode_utf8(shift)))[9]; }
sub Glob      { return map { decode_utf8($_) } bsd_glob(encode_utf8(shift)); }
sub ChangeMod { return chmod(shift, map { encode_utf8($_) } @_); }
sub Rename    { return rename(encode_utf8($_[0]), encode_utf8($_[1])); }
sub RemoveDir { return rmdir(encode_utf8(shift)); }
sub ChangeDir { return chdir(encode_utf8(shift)); }

sub CreateDir {
  my ($newdir) = @_;
  return if IsDir($newdir);
  mkdir(encode_utf8($newdir), 0775)
    or ReportError(Ts('Cannot create %s', $newdir) . ": $!", '500 INTERNAL SERVER ERROR');
}

sub GetLockedPageFile {
  my $id = shift;
  return "$PageDir/$id.lck";
}

sub RequestLockDir {
  my ($name, $tries, $wait, $error, $retried) = @_;
  $tries ||= 4;
  $wait ||= 2;
  CreateDir($TempDir);
  my $lock = $LockDir . $name;
  my $n = 0;
  # Cannot use CreateDir because we don't want to skip mkdir if the directory
  # already exists.
  while (mkdir(encode_utf8($lock), 0555) == 0) {
    if ($n++ >= $tries) {
      my $ts = Modified($lock);
      if ($Now - $ts > $LockExpiration and $LockExpires{$name} and not $retried) { # XXX should we remove this now?
	ReleaseLockDir($name); # try to expire lock (no checking)
	return 1 if RequestLockDir($name, undef, undef, undef, 1);
      }
      return 0 unless $error;
      ReportError(Ts('Could not get %s lock', $name) . ": $!. ",
		  '503 SERVICE UNAVAILABLE', undef,
		  Ts('The lock was created %s.', CalcTimeSince($Now - $ts))
		  . ($retried && ' ' . T('Maybe the user running this script is no longer allowed to remove the lock directory?'))
		  . ' ' . T('Sometimes locks are left behind if a job crashes.') . ' '
		  . ($Now - $ts < 600 ? T('After ten minutes, you could try to unlock the wiki.')
		     : ScriptLink('action=unlock', T('Unlock Wiki'), 'unlock')));
    }
    sleep($wait);
  }
  $Locks{$name} = 1;
  return 1;
}

sub HandleSignals {
  my ($signal) = @_; # TODO should we pass it to CleanLock?
  CleanLock($_) foreach keys %Locks;
  exit; # let's count it as graceful exit
}

sub CleanLock {
  my ($name) = @_;
  $LockCleaners{$name}->() if exists $LockCleaners{$name};
  ReleaseLockDir($name); # TODO should we log this?
}

sub ReleaseLockDir {
  my $name = shift;            # We don't check whether we succeeded.
  RemoveDir($LockDir . $name); # Before fixing, make sure we only call this
  delete $Locks{$name};        # when we know the lock exists.
}

sub RequestLockOrError {
  return RequestLockDir('main', 10, 3, 1); # 10 tries, 3 second wait, die on error
}

sub ReleaseLock {
  ReleaseLockDir('main');
}

sub ForceReleaseLock {
  my $pattern = shift;
  my $forced;
  foreach my $name (Glob($pattern)) {
    # First try to obtain lock (in case of normal edit lock)
    $forced = 1 unless RequestLockDir($name, 5, 3, 0);
    ReleaseLockDir($name); # Release the lock, even if we didn't get it. This should not happen.
  }
  return $forced;
}

sub DoUnlock {
  my $message = '';
  print GetHeader('', T('Unlock Wiki'), undef, 'nocache');
  print $q->p(T('This operation may take several seconds...'));
  for my $lock (@KnownLocks) {
    if (ForceReleaseLock($lock)) {
      $message .= $q->p(Ts('Forced unlock of %s lock.', $lock));
    }
  }
  print $message || $q->p(T('No unlock required.'));
  PrintFooter();
}

sub CalcDay {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%4d-%02d-%02d', $year + 1900, $mon + 1, $mday);
}

sub CalcTime {
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift);
  return sprintf('%02d:%02d UTC', $hour, $min);
}

sub CalcTimeSince {
  my $total = shift;
  return Ts('%s hours ago', int($total/3600)) if ($total >= 7200);
  return T('1 hour ago')                      if ($total >= 3600);
  return Ts('%s minutes ago', int($total/60)) if ($total >= 120);
  return T('1 minute ago')                    if ($total >= 60);
  return Ts('%s seconds ago', int($total))    if ($total >= 2);
  return T('1 second ago')                    if ($total == 1);
  return T('just now');
}

sub TimeToText {
  my $t = shift;
  return CalcDay($t) . ' ' . CalcTime($t);
}

sub TimeToW3 { # Complete date plus hours and minutes: YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)
  my ($sec, $min, $hour, $mday, $mon, $year) = gmtime(shift); # use special UTC designator ("Z")
  return sprintf('%4d-%02d-%02dT%02d:%02dZ', $year + 1900, $mon + 1, $mday, $hour, $min);
}

sub TimeToRFC822 {
  my ($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime(shift); # Sat, 07 Sep 2002 00:00:01 GMT
  return sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", qw(Sun Mon Tue Wed Thu Fri Sat)[$wday], $mday,
		 qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon], $year + 1900, $hour, $min, $sec);
}

sub GetHiddenValue {
  my ($name, $value) = @_;
  return $q->input({-type=>"hidden", -name=>$name, -value=>$value});
}

sub FreeToNormal {    # trim all spaces and convert them to underlines
  my $id = shift;
  return '' unless $id;
  $id =~ s/ /_/g;
  $id =~ s/__+/_/g;
  $id =~ s/^_//;
  $id =~ s/_$//;
  return UnquoteHtml($id);
}

sub ItemName {
  my $id = shift; # id
  return NormalToFree($id) unless GetParam('short', 1) and $RssStrip;
  my $comment = $id =~ s/^($CommentsPrefix)//; # strip first so that ^ works
  $id =~ s/^$RssStrip//;
  $id = $CommentsPrefix . $id if $comment;
  return NormalToFree($id);
}

sub NormalToFree { # returns HTML quoted title with spaces
  my $title = shift;
  $title =~ s/_/ /g;
  return QuoteHtml($title);
}

sub UnWiki {
  my $str = shift;
  return $str unless $WikiLinks and $str =~ /^$LinkPattern$/;
  $str =~ s/([[:lower:]])([[:upper:]])/$1 $2/g;
  return $str;
}

sub DoEdit {
  my ($id, $newText, $preview) = @_;
  UserCanEditOrDie($id);
  my $upload = GetParam('upload', undef);
  if ($upload and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  OpenPage($id);
  my ($revisionPage, $revision) = GetTextRevision(GetParam('revision', ''), 1); # maybe revision reset!
  my $oldText = $preview ? $newText : $revisionPage->{text};
  my $isFile = TextIsFile($oldText);
  $upload //= $isFile;
  if ($upload and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  if ($upload) {    # shortcut lots of code
    $revision = '';
    $preview = 0;
  } elsif ($isFile) {
    $oldText = '';
  }
  my $header;
  if ($revision and not $upload) {
    $header = Ts('Editing revision %s of', $revision) . ' ' . NormalToFree($id);
  } else {
    $header = Ts('Editing %s', NormalToFree($id));
  }
  print GetHeader('', $header), $q->start_div({-class=>'content edit'});
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
  print GetEditForm($id, $upload, $oldText, $revision), $q->end_div();
  PrintFooter($id, 'edit');
}

sub GetEditForm {
  my ($page_name, $upload, $oldText, $revision) = @_;
  my $html = GetFormStart(undef, undef, $upload ? 'edit upload' : 'edit text') # protected by questionasker
    .$q->p(GetHiddenValue("title", $page_name),
	   ($revision ? GetHiddenValue('revision', $revision) : ''),
           GetHiddenValue('oldtime', GetParam('oldtime', $Page{ts})), # prefer parameter over actual timestamp
	   ($upload ? GetUpload() : GetTextArea('text', $oldText)));
  my $summary = UnquoteHtml(GetParam('summary', ''))
    || ($Now - $Page{ts} < ($SummaryHours * 3600) ? $Page{summary} : '');
  $html .= $q->p(T('Summary:').$q->br().GetTextArea('summary', $summary, 2))
    .$q->p($q->checkbox(-name=>'recent_edit', -checked=>(GetParam('recent_edit', '') eq 'on'),
                        -label=>T('This change is a minor edit.')));
  $html .= T($EditNote) if $EditNote; # Allow translation
  my $username = GetParam('username', '');
  $html .= $q->p($q->label({-for=>'username'}, T('Username:')).' '
    .$q->textfield(-name=>'username', -id=>'username', -default=>$username,
                   -override=>1, -size=>20, -maxlength=>50))
    .$q->p($q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save')),
           ($upload ? '' : ' ' . $q->submit(-name=>'Preview', -accesskey=>T('p'), -value=>T('Preview'))).
           ' '.$q->submit(-name=>'Cancel', -value=>T('Cancel')));
  if ($upload) {
    $html .= $q->p(ScriptLink('action=edit;upload=0;id=' . UrlEncode($page_name), T('Replace this file with text'),   'upload'));
  } elsif ($UploadAllowed or UserIsAdmin()) {
    $html .= $q->p(ScriptLink('action=edit;upload=1;id=' . UrlEncode($page_name), T('Replace this text with a file'), 'upload'));
  }
  $html .= $q->end_form();
  foreach my $sub (@MyFormChanges) {
    $html = $sub->($html, 'edit', $upload);
  }
  return $html;
}

sub GetTextArea {
  my ($name, $text, $rows) = @_;
  return $q->textarea(-id=>$name, -name=>$name, -default=>$text, -rows=>$rows || 25, -columns=>78, -override=>1);
}

sub GetUpload {
  return T('File to upload:') . ' ' . $q->filefield(-name=>'file', -size=>50, -maxlength=>100);
}

sub DoDownload {
  my $id = shift;
  OpenPage($id) if ValidIdOrDie($id);
  print $q->header(-status=>'304 NOT MODIFIED') and return if FileFresh(); # FileFresh needs an OpenPage!
  my ($revisionPage, $revision) = GetTextRevision(GetParam('revision', '')); # maybe revision reset!
  my $text = $revisionPage->{text};
  if (my ($type, $encoding) = TextIsFile($text)) {
    my ($data) = $text =~ /^[^\n]*\n(.*)/s;
    my %allowed = map {$_ => 1} @UploadTypes;
    if (@UploadTypes and not $allowed{$type}) {
      ReportError(Ts('Files of type %s are not allowed.', $type), '415 UNSUPPORTED MEDIA TYPE');
    }
    print GetHttpHeader($type, $Page{ts}, undef, $encoding);
    require MIME::Base64;
    binmode(STDOUT, ":pop:raw"); # need to pop utf8 for Windows users!?
    print MIME::Base64::decode($data);
  } else {
    print GetHttpHeader('text/plain', $Page{ts});
    print $text;
  }
}

sub DoPassword {
  my $id = shift;
  print GetHeader('', T('Password')), $q->start_div({-class=>'content password'});
  print $q->p(T('Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.'));
  if (not $AdminPass and not $EditPass) {
    print $q->p(T('This site does not use admin or editor passwords.'));
  } else {
    if (UserIsAdmin()) {
      print $q->p(T('You are currently an administrator on this site.'));
    } elsif (UserIsEditor()) {
      print $q->p(T('You are currently an editor on this site.'));
    } else {
      print $q->p(T('You are a normal user on this site.'));
      if (not GetParam('pwd')) {
	print $q->p(T('You do not have a password set.'));
      } else {
	print $q->p(T('Your password does not match any of the administrator or editor passwords.'));
      }
    }
    print GetFormStart(undef, undef, 'password'),
      $q->p(GetHiddenValue('action', 'password'), T('Password:'), ' ',
	    $q->password_field(-name=>'pwd', -size=>20, -maxlength=>64),
	    $q->hidden(-name=>'id', -value=>$id),
	    $q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save'))),
      $q->end_form;
  }
  if ($id) {
    print $q->p(ScriptLink('action=browse;id=' . UrlEncode($id) . ';time=' . time,
			   Ts('Return to %s', NormalToFree($id))));
  }
  print $q->end_div();
  PrintFooter();
}

sub UserIsEditorOrError {
  UserIsEditor()
    or ReportError(T('This operation is restricted to site editors only...'), '403 FORBIDDEN');
  return 1;
}

sub UserIsAdminOrError {
  UserIsAdmin()
    or ReportError(T('This operation is restricted to administrators only...'), '403 FORBIDDEN');
  return 1;
}

sub UserCanEditOrDie {
  my $id = shift;
  ValidIdOrDie($id);
  if (not UserCanEdit($id, 1)) {
    my $rule = UserIsBanned();
    if ($rule) {
      ReportError(T('Edit Denied'), '403 FORBIDDEN', undef,
		  $q->p(T('Editing not allowed: user, ip, or network is blocked.')),
		  $q->p(T('Contact the wiki administrator for more information.')),
		  $q->p(Ts('The rule %s matched for you.', $rule) . ' '
			. Ts('See %s for more information.', GetPageLink($BannedHosts))));
    } else {
      ReportError(T('Edit Denied'), '403 FORBIDDEN', undef,
		  $q->p(Ts('Editing not allowed: %s is read-only.', NormalToFree($id))));
    }
  }
}

sub UserCanEdit {
  my ($id, $editing, $comment) = @_;
  return 0 if $id eq 'SampleUndefinedPage' or $id eq T('SampleUndefinedPage')
    or $id eq 'Sample_Undefined_Page' or $id eq T('Sample_Undefined_Page');
  return 1 if UserIsAdmin();
  return 0 if $id ne '' and IsFile(GetLockedPageFile($id));
  return 0 if $LockOnCreation{$id} and not IsFile(GetPageFile($id)); # new page
  return 1 if UserIsEditor();
  return 0 if not $EditAllowed or IsFile($NoEditFile);
  return 0 if $editing and UserIsBanned(); # this call is more expensive
  return 0 if $EditAllowed >= 2 and (not $CommentsPattern or $id !~ /$CommentsPattern/);
  return 1 if $EditAllowed >= 3 and GetParam('recent_edit', '') ne 'on' # disallow minor comments
			and ($comment or (GetParam('aftertext', '') and not GetParam('text', '')));
  return 0 if $EditAllowed >= 3;
  return 1;
}

sub UserIsBanned {
  return 0 if GetParam('action', '') eq 'password'; # login is always ok
  my $host = $q->remote_addr();
  foreach (split(/\n/, GetPageContent($BannedHosts))) {
    if (/^\s*([^#]\S+)/) { # all lines except empty lines and comments, trim whitespace
      my $regexp = $1;
      return $regexp if ($host =~ /$regexp/i);
    }
  }
  return 0;
}

sub UserIsAdmin {
  return UserHasPassword(GetParam('pwd', ''), $AdminPass);
}

sub UserIsEditor {
  return 1 if UserIsAdmin();  # Admin includes editor
  return UserHasPassword(GetParam('pwd', ''), $EditPass);
}

sub UserHasPassword {
  my ($pwd, $pass) = @_;
  return 0 unless $pass;
  if ($PassHashFunction ne '') {
    no strict 'refs'; # TODO this is kept for compatibility. Feel free to remove it later (comment written on 2015-07-14)
    $pwd = $PassHashFunction->($pwd . $PassSalt);
  }
  foreach (split(/\s+/, $pass)) {
    return 1 if $pwd eq $_;
  }
  return 0;
}

sub BannedContent {
  my $str = shift;
  my @urls = $str =~ /$FullUrlPattern/g;
  foreach (split(/\n/, GetPageContent($BannedContent))) {
    next unless m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/;
    my ($regexp, $comment, $re) = ($1, $4, undef);
    foreach my $url (@urls) {
      eval { $re = qr/$regexp/i; };
      if (defined($re) and $url =~ $re) {
	return Tss('Rule "%1" matched "%2" on this page.', $regexp, $url) . ' '
	  . ($comment ? Ts('Reason: %s.', $comment) : T('Reason unknown.')) . ' '
	  . Ts('See %s for more information.', GetPageLink($BannedContent));
      }
    }
  }
  return 0;
}

sub SortIndex {
  my ($A, $B) = ($a, $b);
  my $aIsComment = $A =~ s/^$CommentsPrefix//;
  $B =~ s/^$CommentsPrefix//;
  return $aIsComment ? 1 : -1 if $A eq $B;
  $A cmp $B;
}

sub DoIndex {
  my $raw = GetParam('raw', 0);
  my $limit = GetParam('n', '');
  my @pages = ();
  my @menu = ($q->label({-for=>'indexmatch'}, T('Filter:')) . ' '
	      . $q->textfield(-name=>'match', -id=>'indexmatch', -size=>20));
  foreach my $data (@IndexOptions) {
    my ($option, $text, $default, $sub) = @$data;
    my $value = GetParam($option, $default); # HTML checkbox warning!
    $value = 0 if GetParam('manual', 0) and $value ne 'on';
    push(@pages, $sub->()) if $value;
    push(@menu, $q->checkbox(-name=>$option, -checked=>$value, -label=>$text));
  }
  @pages = Matched(GetParam('match', ''), @pages);
  @pages = sort SortIndex @pages;
  @pages = @pages[0 .. $limit - 1] if $limit;
  if ($raw) {
    print GetHttpHeader('text/plain'); # and ignore @menu
  } else {
    print GetHeader('', T('Index of all pages'));
    push(@menu, GetHiddenValue('manual', 1) . $q->submit(-value=>T('Go!')));
    push(@menu, $q->b(Ts('(for %s)', GetParam('lang', '')))) if GetParam('lang', '');
    print $q->start_div({-class=>'content index'}),
      GetFormStart(undef, 'get', 'index'), GetHiddenValue('action', 'index'),
      $q->p(join($q->br(), @menu)), $q->end_form(),
      $q->h2(Ts('%s pages found.', ($#pages + 1))), $q->start_p();
  }
  PrintPage($_) foreach (@pages);
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
    if (GetParam('search', '') and GetParam('context', 1)) {
      print "title: $id\n\n"; # for near links without full search
    } else {
      print $id, "\n";
    }
  } else {
    print GetPageOrEditLink($id, NormalToFree($id)), $q->br();
  }
}

sub AllPagesList {
  my $refresh = GetParam('refresh', 0);
  return @IndexList if @IndexList and not $refresh;
  SetParam('refresh', 0) if $refresh;
  return @IndexList if not $refresh and IsFile($IndexFile) and ReadIndex();
  # If open fails just refresh the index
  RefreshIndex();
  return @IndexList;
}

sub ReadIndex {
  my ($status, $rawIndex) = ReadFile($IndexFile); # not fatal
  if ($status) {
    @IndexList = split(/ /, $rawIndex);
    %IndexHash = map {$_ => 1} @IndexList;
    return @IndexList;
  }
  return;
}

sub WriteIndex {
  WriteStringToFile($IndexFile, join(' ', @IndexList));
}

sub RefreshIndex {
  @IndexList = ();
  %IndexHash = ();
  # If file exists and cannot be changed, error!
  my $locked = RequestLockDir('index', undef, undef, IsFile($IndexFile));
  foreach (Glob("$PageDir/*.pg"), Glob("$PageDir/.*.pg")) {
    next unless m|/.*/(.+)\.pg$|;
    my $id = $1;
    push(@IndexList, $id);
    $IndexHash{$id} = 1;
  }
  WriteIndex() if $locked;
  ReleaseLockDir('index') if $locked;
}

sub AddToIndex {
  my ($id) = @_;
  $IndexHash{$id} = 1;
  @IndexList = sort(keys %IndexHash);
  WriteIndex();
}

sub DoSearch {
  my $string = shift || GetParam('search', '');
  my $re = UnquoteHtml($string);
  return DoIndex() if $string eq '';
  eval { qr/$re/ } or $re = quotemeta($re);
  my $replacement = GetParam('replace', undef);
  my $raw = GetParam('raw', '');
  my @results;
  if ($replacement or GetParam('delete', 0)) {
    return unless UserIsAdminOrError();
    if (GetParam('preview', '')) { # Preview button was used
      print GetHeader('', Ts('Preview: %s', $string . " &#x2192; " . $replacement));
      print $q->start_div({-class=>'content replacement'});
      print GetFormStart(undef, 'post', 'replace');
      print GetHiddenValue('search', $string);
      print GetHiddenValue('replace', $replacement);
      print GetHiddenValue('delete', GetParam('delete', 0));
      print $q->submit(-value=>T('Go!')) . $q->end_form();
      @results = ReplaceAndDiff($re, UnquoteHtml($replacement));
    } else {
      print GetHeader('', Ts('Replaced: %s', $string . " &#x2192; " . $replacement));
      print $q->start_div({-class=>'content replacement'});
      @results = ReplaceAndSave($re, UnquoteHtml($replacement));
      foreach (@results) {
	PrintSearchResult($_, quotemeta($replacement || $re)); # the replacement is not a valid regex
      }
    }
  } else {
    if ($raw) {
      print GetHttpHeader('text/plain');
      print RcTextItem('title', Ts('Search for: %s', $string)), RcTextItem('date', TimeToText($Now)),
	RcTextItem('link', $q->url(-path_info=>1, -query=>1)), "\n" if GetParam('context', 1);
    } else {
      print GetHeader('', Ts('Search for: %s', $string)), $q->start_div({-class=>'content search'});
      print $q->p({-class=>'links'}, SearchMenu($string));
    }
    @results = SearchTitleAndBody($re, \&PrintSearchResult, SearchRegexp($re));
  }
  print SearchResultCount($#results + 1), $q->end_div() unless $raw;
  PrintFooter() unless $raw;
}

sub SearchMenu {
  return ScriptLink('action=rc;rcfilteronly=' . UrlEncode(shift),
		    T('View changes for these pages'));
}

sub SearchResultCount { $q->p({-class=>'result'}, Ts('%s pages found.', (shift))); }

sub PageIsUploadedFile {
  my $id = shift;
  return if $OpenPageName eq $id;
  if ($IndexHash{$id}) {
    my $file = GetPageFile($id);
    open(my $FILE, '<:encoding(UTF-8)', encode_utf8($file))
      or ReportError(Ts('Cannot open %s', GetPageFile($id))
		     . ": $!", '500 INTERNAL SERVER ERROR');
    while (defined($_ = <$FILE>) and $_ !~ /^text: /) {
    }          # read lines until we get to the text key
    close $FILE;
    return unless length($_) > 6;
    return TextIsFile(substr($_, 6)); # pass "#FILE image/png\n" to the test
  }
}

sub SearchTitleAndBody {
  my ($regex, $func, @args) = @_;
  my @found;
  my $lang = GetParam('lang', '');
  foreach my $id (Filtered($regex, AllPagesList())) {
    my $name = NormalToFree($id);
    my ($text) = PageIsUploadedFile($id); # set to mime-type if this is an uploaded file
    local ($OpenPageName, %Page); # this is local!
    if (not $text) { # not uploaded file, therefore allow searching of page body
      OpenPage($id); # this opens a page twice if it is not uploaded, but that's ok
      if ($lang) {
	my @languages = split(/,/, $Page{languages});
	next if (@languages and not grep(/$lang/, @languages));
      }
      $text = $Page{text};
    }
    if (SearchString($regex, $name . "\n" . $text)) { # the real search code
      push(@found, $id);
      $func->($id, @args) if $func;
    }
  }
  return @found;
}

# Filter the pages to be searched for $string. The default implementation
# ignores $string and uses $match instead, just in case the user used both
# search and match parameters. This is overwritten in extensions such as tags.pl
# which extract tags from $string and use that to filter the pages.
sub Filtered {
  my ($string, @pages) = @_;
  return Matched(GetParam('match', ''), @pages);
}

sub Matched { # strictly for page titles
  my ($string, @pages) = @_;
  return @pages unless $string;
  my @terms = grep { $_ } split(/[ _]+/, $string);
  return grep {
    my $id = $_;
    all { $id =~ /$_/i } @terms;
  } @pages;
}

sub SearchString {
  my ($string, $data) = @_;
  my @strings = grep /./, $string =~ /\"([^\"]+)\"|(\S+)/g; # skip null entries
  foreach my $str (@strings) {
    return 0 unless ($data =~ /$str/i);
  }
  return 1;
}

sub SearchRegexp {
  my $regexp = join '|', map { index($_, '|') == -1 ? $_ : "($_)" }
    grep /./, shift =~ /\"([^\"]+)\"|(\S+)/g; # this acts as OR
  $regexp =~ s/\\s/[[:space:]]/g;
  return $regexp;
}

sub PrintSearchResult {
  my ($name, $regex) = @_;
  return PrintPage($name) if not GetParam('context', 1);
  OpenPage($name);     # should be open already, just making sure!
  my $text = $Page{text};
  my ($type) = TextIsFile($text); # MIME type if an uploaded file
  my %entry;
  #  get the page, filter it, remove all tags
  $text =~ s/$FS//g;   # Remove separators (paranoia)
  $text =~ s/[\s]+/ /g;   #  Shrink whitespace
  $text =~ s/([-_=\\*\\.]){10,}/$1$1$1$1$1/g ; # e.g. shrink "----------"
  $entry{title} = $name;
  $entry{description} =  $type || SearchHighlight(QuoteHtml(SearchExtract($text, $regex)), QuoteHtml($regex));
  $entry{size} = int((length($text) / 1024) + 1) . 'K';
  $entry{'last-modified'} = TimeToText($Page{ts});
  $entry{username} = $Page{username};
  PrintSearchResultEntry(\%entry);
}

sub PrintSearchResultEntry {
  my %entry = %{(shift)}; # get value from reference
  if (GetParam('raw', 0)) {
    $entry{generator} = GetAuthor($entry{username});
    foreach my $key (qw(title description size last-modified generator username)) {
      print RcTextItem($key, $entry{$key});
    }
    print RcTextItem('link', "$ScriptName?$entry{title}"), "\n";
  } else {
    my $author = GetAuthorLink($entry{username});
    $author ||= $entry{generator};
    my $id = $entry{title};
    my ($class, $resolved, $title, $exists) = ResolveId($id);
    my $text = NormalToFree($id);
    my $result = $q->span({-class=>'result'}, ScriptLink(UrlEncode($resolved), $text, $class, undef, $title));
    my $description = $entry{description};
    $description = $q->br() . $description if $description;
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
  $data =~ s/($regex)/<strong>$1<\/strong>/gi unless GetParam('raw');
  return $data;
}

sub SearchExtract {
  my ($data, $regex) = @_;
  my ($snippetlen, $maxsnippets) = (100, 4); #  these seem nice.
  # show a snippet from the beginning of the document
  my $j = index($data, ' ', $snippetlen); # end on word boundary
  my $t = substr($data, 0, $j);
  my $result = $t . ' . . .';
  $data = substr($data, $j);  # to avoid rematching
  my $jsnippet = 0 ;
  while ($jsnippet < $maxsnippets and $data =~ m/($regex)/i) {
    $jsnippet++;
    if (($j = index($data, $1)) > -1 ) {
      # get substr containing (start of) match, ending on word boundaries
      my $start = index($data, ' ', $j - $snippetlen / 2);
      $start = 0 if $start == -1;
      my $end = index($data, ' ', $j + $snippetlen / 2);
      $end = length($data) if $end == -1;
      $t = substr($data, $start, $end - $start);
      $result .= $t . ' . . .';
      # truncate text to avoid rematching the same string.
      $data = substr($data, $end);
    }
  }
  return $result;
}

sub ReplaceAndSave {
  my ($from, $to) = @_;
  RequestLockOrError();   # fatal
  my @result = Replace($from, $to, 1, sub {
    my ($id, $new) = @_;
    Save($id, $new, $from . ' → ' . $to, 1);
  });
  ReleaseLock();
  return @result;
}

sub ReplaceAndDiff {
  my ($from, $to) = @_;
  my @found = Replace($from, $to, 0, sub {
    my ($id, $new) = @_;
    print $q->h2(GetPageLink($id)), $q->div({-class=>'diff'}, ImproveDiff(DoDiff($Page{text}, $new)));
		      });
  if (@found > GetParam('offset', 0) + GetParam('num', 10)) {
    my $more = "search=" . UrlEncode($from) . ";preview=1"
	. ";offset=" . (GetParam('num', 10) + GetParam('offset', 0))
	. ";num=" . GetParam('num', 10);
    $more .= ";replace=" . UrlEncode($to) if $to;
    $more .= ";delete=1" unless $to;
    print $q->p({-class=>'more'}, ScriptLink($more, T('More...'), 'more'));
  }
  return @found;
}

sub Replace {
  my ($from, $to, $all, $func) = @_; # $func takes $id and $new text
  my $lang = GetParam('lang', '');
  my $num = GetParam('num', 10);
  my $offset = GetParam('offset', 0);
  my @result;
  foreach my $id (AllPagesList()) {
    OpenPage($id);
    if ($lang) {
      my @languages = split(/,/, $Page{languages});
      next if (@languages and not grep(/$lang/, @languages));
    }
    $_ = $Page{text};
    my $replacement = sub {
      my ($o1, $o2, $o3, $o4, $o5, $o6, $o7, $o8, $o9) = ($1, $2, $3, $4, $5, $6, $7, $8, $9);
      my $str = $to;
      $str =~ s/\$([1-9])/'$o' . $1/eeg;
      $str
    };
    if (s/$from/$replacement->()/egi) { # allows use of backreferences
      push (@result, $id);
      $func->($id, $_) if $all or @result > $offset and @result <= $offset + $num;
    }
  }
  return @result;
}

sub DoPost {
  my $id = FreeToNormal(shift);
  UserCanEditOrDie($id);
  # Lock before getting old page to prevent races
  RequestLockOrError();		# fatal
  OpenPage($id);
  my $old = $Page{text};
  my $string = UnquoteHtml(GetParam('text', undef));
  $string =~ s/(\r|$FS)//g;
  my ($type) = TextIsFile($string); # MIME type if an uploaded file
  my $filename = GetParam('file', undef);
  if (($filename or $type) and not $UploadAllowed and not UserIsAdmin()) {
    ReportError(T('Only administrators can upload files.'), '403 FORBIDDEN');
  }
  my $comment = UnquoteHtml(GetParam('aftertext', undef));
  $comment =~ s/(\r|$FS)//g;
  if (defined $comment and $comment eq '') {
    ReleaseLock();
    return ReBrowsePage($id);
  }
  if ($filename) {		# upload file
    my $file = $q->upload('file');
    if (not $file and $q->cgi_error) {
      ReportError(Ts('Transfer Error: %s', $q->cgi_error), '500 INTERNAL SERVER ERROR');
    }
    ReportError(T('Browser reports no file info.'), '500 INTERNAL SERVER ERROR') unless $q->uploadInfo($filename);
    $type = $q->uploadInfo($filename)->{'Content-Type'};
    ReportError(T('Browser reports no file type.'), '415 UNSUPPORTED MEDIA TYPE') unless $type;
    local $/ = undef;		# Read complete files
    my $content = <$file>; # Apparently we cannot count on <$file> to always work within the eval!?
    my $encoding = substr($content, 0, 2) eq "\x1f\x8b" ? 'gzip' : '';
    eval { require MIME::Base64; $_ = MIME::Base64::encode($content) };
    $string = "#FILE $type $encoding\n" . $_;
  } else {			# ordinary text edit
    $string = AddComment($old, $comment) if defined $comment;
    if ($comment and substr($string, 0, length($DeletedPage)) eq $DeletedPage) { # look ma, no regexp!
      $string = substr($string, length($DeletedPage)); # undelete pages when adding a comment
    }
    $string .= "\n" if ($string !~ /\n$/); # add trailing newline
    $string = RunMyMacros($string); # run macros on text pages only
  }
  my %allowed = map {$_ => 1} @UploadTypes;
  if (@UploadTypes and $type and not $allowed{$type}) {
    ReportError(Ts('Files of type %s are not allowed.', $type), '415 UNSUPPORTED MEDIA TYPE');
  }
  # Banned Content
  my $summary = GetSummary();
  if (not UserIsEditor()) {
    my $rule = BannedContent(NormalToFree($id)) || BannedContent($string) || BannedContent($summary);
    ReportError(T('Edit Denied'), '403 FORBIDDEN', undef, $q->p(T('The page contains banned text.')),
		$q->p(T('Contact the wiki administrator for more information.')), $q->p($rule)) if $rule;
  }
  # rebrowse if no changes
  my $oldrev = $Page{revision};
  if (GetParam('Preview', '')) { # Preview button was used
    ReleaseLock();
    if (defined $comment) {
      BrowsePage($id, 0, RunMyMacros($comment)); # show macros in preview
    } else {
      DoEdit($id, $string, 1);
    }
    return;
  } elsif ($old eq $string) {
    ReleaseLock();	 # No changes -- just show the same page again
    return ReBrowsePage($id);
  } elsif ($oldrev == 0 and $string eq "\n") {
    ReportError(T('No changes to be saved.'), '400 BAD REQUEST'); # don't fake page creation because of webdav
  }
  my $newAuthor = 0;
  if ($oldrev) { # the first author (no old revision) is not considered to be "new"
    $newAuthor = 1 if not $Page{username} or $Page{username} ne GetParam('username', '');
  }
  my $oldtime = $Page{ts};
  my $myoldtime = GetParam('oldtime', ''); # maybe empty!
  # Handle raw edits with the meta info on the first line
  if (GetParam('raw', 0) == 2 and $string =~ /^([0-9]+).*\n((.*\n)*.*)/) {
    $myoldtime = $1;
    $string = $2;
  }
  my $generalwarning = 0;
  if ($newAuthor and $oldtime ne $myoldtime and not defined $comment) {
    if ($myoldtime) {
      my ($ancestor) = GetTextAtTime($myoldtime);
      if ($ancestor and $old ne $ancestor) {
	my $new = MergeRevisions($string, $ancestor, $old);
	if ($new) {
	  $string = $new;
	  if ($new =~ /^<<<<<<</m and $new =~ /^>>>>>>>/m) {
	    SetParam('msg', Ts('This page was changed by somebody else %s.',
			       CalcTimeSince($Now - $Page{ts}))
		     . ' ' . T('The changes conflict.  Please check the page again.'));
	  }			# else no conflict
	} else {
	  $generalwarning = 1;
	}  # else merge revision didn't work
      }    # else nobody changed the page in the mean time (same text)
    } else {
      $generalwarning = 1;
    }			# no way to be sure since myoldtime is missing
  } # same author or nobody changed the page in the mean time (same timestamp)
  if ($generalwarning and ($Now - $Page{ts}) < 600) {
    SetParam('msg', Ts('This page was changed by somebody else %s.',
		       CalcTimeSince($Now - $Page{ts}))
	     . ' ' . T('Please check whether you overwrote those changes.'));
  }
  Save($id, $string, $summary, (GetParam('recent_edit', '') eq 'on'), $filename);
  ReleaseLock();
  ReBrowsePage($id);
}

sub GetSummary {
  my $text = GetParam('aftertext',  '') || ($Page{revision} > 0 ? '' : GetParam('text', ''));
  return '' if $text =~ /^#FILE /;
  if ($SummaryDefaultLength and length($text) > $SummaryDefaultLength) {
    $text = substr($text, 0, $SummaryDefaultLength);
    $text =~ s/\s*\S*$/ . . ./;
  }
  my $summary = GetParam('summary', '') || $text; # not GetParam('summary', $text) work because '' is defined
  $summary =~ s/$FS|[\r\n]+/ /g; # remove linebreaks and separator characters
  $summary =~ s/\[$FullUrlPattern\s+(.*?)\]/$2/g; # fix common annoyance when copying text to summary
  $summary =~ s/\[$FullUrlPattern\]//g;
  $summary =~ s/\[\[$FreeLinkPattern\]\]/$1/g;
  return UnquoteHtml($summary);
}

sub AddComment {
  my ($string, $comment) = @_;
  $comment =~ s/\r//g;    # Remove "\r"-s (0x0d) from the string
  $comment =~ s/\s+$//g;  # Remove whitespace at the end
  if ($comment ne '') {
    my $author = GetParam('username', T('Anonymous'));
    my $homepage = GetParam('homepage', '');
    $homepage = 'http://' . $homepage if $homepage and $homepage !~ /^($UrlProtocols):/;
    $author = "[$homepage $author]" if $homepage;
    $string .= "\n----\n\n" if $string and $string ne "\n";
    $string .= $comment . "\n\n"
      . '-- ' . $author . ' ' . TimeToText($Now) . "\n\n";
  }
  return $string;
}

sub Save {      # call within lock, with opened page
  my ($id, $new, $summary, $minor, $upload) = @_;
  my $user = GetParam('username', '');
  my $revision = $Page{revision} + 1;
  my $old = $Page{text};
  my $olddiff = $Page{'diff-major'} == '1' ? $Page{'diff-minor'} : $Page{'diff-major'};
  if ($revision == 1 and IsFile($IndexFile) and not Unlink($IndexFile)) { # regenerate index on next request
    SetParam('msg', Ts('Cannot delete the index file %s.', $IndexFile)
	     . ' ' . T('Please check the directory permissions.')
	     . ' ' . T('Your changes were not saved.'));
    return 0;
  }
  ReInit($id);
  TouchIndexFile();
  SaveKeepFile(); # deletes blocks, flags, diff-major, and diff-minor, and sets keep-ts
  ExpireKeepFiles();
  $Page{lastmajor} = $revision unless $minor;
  $Page{lastmajorsummary} = $summary unless $minor;
  @Page{qw(ts revision summary username minor text)} =
      ($Now, $revision, $summary, $user, $minor, $new);
  if ($UseDiff and $UseCache > 1 and $revision > 1 and not $upload and not TextIsFile($old)) {
    UpdateDiffs($old, $new, $olddiff); # sets diff-major and diff-minor
  }
  my $languages;
  $languages = GetLanguages($new) unless $upload;
  $Page{languages} = $languages;
  SavePage();
  if ($revision == 1 and $LockOnCreation{$id}) {
    WriteStringToFile(GetLockedPageFile($id), 'LockOnCreation');
  }
  my $host = $q->remote_addr();
  WriteRcLog($id, $summary, $minor, $revision, $user, $host, $languages, GetCluster($new));
  AddToIndex($id) if ($revision == 1);
}

sub TouchIndexFile {
  my $ts = time;
  utime $ts, $ts, $IndexFile;
  $LastUpdate = $Now = $ts;
}

sub GetLanguages {
  my $text = shift;
  my %result;
  for my $lang (keys %Languages) {
    my @matches = $text =~ /$Languages{$lang}/gi;
    $result{$lang} = @matches if @matches >= $LanguageLimit;
  }
  return join(',', sort { $result{$b} <=> $result{$a} } keys %result);
}

sub GetLanguage { # the first language, or the default language
  return ((split /,/, GetLanguages(@_))[0] or $CurrentLanguage);
}

sub GetCluster {
  $_ = shift;
  return '' unless $PageCluster;
  return $1 if ($WikiLinks && /^$LinkPattern\n/)
    or ($FreeLinks && /^\[\[$FreeLinkPattern\]\]\n/);
}

sub MergeRevisions {   # merge change from file2 to file3 into file1
  my ($file1, $file2, $file3) = @_;
  my ($name1, $name2, $name3) = ("$TempDir/file1", "$TempDir/file2", "$TempDir/file3");
  CreateDir($TempDir);
  RequestLockDir('merge') or return T('Could not get a lock to merge!');
  WriteStringToFile($name1, $file1);
  WriteStringToFile($name2, $file2);
  WriteStringToFile($name3, $file3);
  my ($you, $ancestor, $other) = (T('you'), T('ancestor'), T('other'));
  my $output = decode_utf8(`diff3 -m -L \Q$you\E -L \Q$ancestor\E -L \Q$other\E -- \Q$name1\E \Q$name2\E \Q$name3\E`);
  ReleaseLockDir('merge'); # don't unlink temp files--next merge will just overwrite.
  return $output;
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
  my ($id, $summary, $minor, $revision, $username, $host, $languages, $cluster) = @_;
  my $line = join($FS, $Now, $id, $minor, $summary, $host,
		  $username, $revision, $languages, $cluster);
  AppendStringToFile($RcFile, $line . "\n");
}

sub UpdateDiffs { # this could be optimized, but isn't frequent enough
  my ($old, $new, $olddiff) = @_;
  $Page{'diff-minor'} = GetDiff($old, $new); # create new diff-minor
  # 1 is a special value for GetCacheDiff telling it to use diff-minor
  $Page{'diff-major'} = $Page{lastmajor} == $Page{revision} ? 1 : $olddiff;
}

sub DoMaintain {
  print GetHeader('', T('Run Maintenance')), $q->start_div({-class=>'content maintain'});
  my $fname = "$DataDir/maintain";
  if (not UserIsAdmin()) {
    if (IsFile($fname) and $Now - Modified($fname) < 12 * 60 * 60) {
      print $q->p(T('Maintenance not done.') . ' ' . T('(Maintenance can only be done once every 12 hours.)')
		  . ' ', T('Remove the "maintain" file or wait.')), $q->end_div();
      PrintFooter();
      return;
    }
  }
  print '<p>', T('Expiring keep files and deleting pages marked for deletion');
  ExpireAllKeepFiles();
  print '</p>';
  RequestLockOrError();
  print $q->p(T('Main lock obtained.'));
  print $q->p(Ts('Moving part of the %s log file.', $RCName));
  # Determine the number of days to go back, default is largest of @RcDays
  my $days = 0;
  foreach (@RcDays) {
    $days = $_ if $_ > $days;
  }
  my $starttime = $Now - $days * 86400; # 24*60*60
  # Read the current file
  my ($status, $data) = ReadFile($RcFile);
  if (not $status) {
    print $q->p($q->strong(Ts('Could not open %s log file', $RCName) . ':') . ' ' . $RcFile),
      $q->p(T('Error was') . ':'), $q->pre($!), $q->p(T('Note: This error is normal if no changes have been made.'));
  } else {
    WriteStringToFile($RcFile . '.old', $data);
  }
  # Move the old stuff from rc to temp
  my @rc = split(/\n/, $data);
  my @tmp = ();
  my $line;
  my $changed = 0;
  while ($line = shift(@rc)) {
    my ($ts, $id, $minor, $summary, $host, @rest) = split(/$FS/, $line);
    last if $ts >= $starttime;
    push(@tmp, join($FS, $ts, $id, $minor, $summary, 'Anonymous', @rest));
    $changed = 1;
  }
  unshift(@rc, $line) if $line; # this one ended the loop
  print $q->p(Ts('Moving %s log entries.', scalar(@tmp)));
  AppendStringToFile($RcOldFile, join("\n", @tmp) . "\n") if @tmp;
  # remove IP numbers from all but the last few days
  $starttime = $Now - $KeepHostDays * 86400; # 24*60*60
  @tmp = ();
  while ($line = shift(@rc)) {
    my ($ts, $id, $minor, $summary, $host, @rest) = split(/$FS/, $line);
    last if $ts >= $starttime;
    push(@tmp, join($FS, $ts, $id, $minor, $summary, 'Anonymous', @rest));
    $changed = 1;
  }
  unshift(@rc, $line) if $line; # this one ended the loop
  unshift(@rc, @tmp) if @tmp;
  print $q->p(Ts('Removing IP numbers from %s log entries.', scalar(@tmp)));
  WriteStringToFile($RcFile, @rc ? join("\n", @rc) . "\n" : '') if $changed;
  if (opendir(DIR, $RssDir)) {  # cleanup if they should expire anyway
    foreach (readdir(DIR)) {
      Unlink("$RssDir/$_") if $Now - Modified($_) > $RssCacheHours * 3600;
    }
    closedir DIR;
  }
  foreach my $func (@MyMaintenance) {
    $func->();
  }
  WriteStringToFile($fname, 'Maintenance done at ' . TimeToText($Now));
  ReleaseLock();
  print $q->p(T('Main lock released.')), $q->end_div();
  PrintFooter();
}

sub PageDeletable {
  return unless $KeepDays;
  my $expirets = $Now - ($KeepDays * 86400); # 24*60*60
  return 0 if $Page{ts} >= $expirets;
  return PageMarkedForDeletion();
}

sub PageMarkedForDeletion {
  # Only pages explicitly marked for deletion or whitespace-only pages
  # are deleted; taking into account the very rare possiblity of a
  # read error and the page text being undefined.
  return 1 if defined $Page{text} and $Page{text} =~ /^\s*$/;
  return $DeletedPage && substr($Page{text}, 0, length($DeletedPage)) eq $DeletedPage;
}

sub DeletePage {    # Delete must be done inside locks.
  my $id = shift;
  ValidIdOrDie($id);
  AppendStringToFile($DeleteFile, "$id\n");
  foreach my $name (GetPageFile($id), GetKeepFiles($id), GetKeepDir($id), GetLockedPageFile($id), $IndexFile) {
    Unlink($name) if IsFile($name);
    RemoveDir($name) if IsDir($name);
  }
  ReInit($id);
  delete $IndexHash{$id};
  @IndexList = sort(keys %IndexHash);
  return '';      # no error
}

sub DoEditLock {
  return unless UserIsAdminOrError();
  print GetHeader('', T('Set or Remove global edit lock'));
  my $fname = "$NoEditFile";
  if (GetParam("set", 1)) {
    WriteStringToFile($fname, 'editing locked.');
  } else {
    Unlink($fname);
  }
  utime time, time, $IndexFile; # touch index file
  print $q->p(IsFile($fname) ? T('Edit lock created.') : T('Edit lock removed.'));
  PrintFooter();
}

sub DoPageLock {
  return unless UserIsAdminOrError();
  print GetHeader('', T('Set or Remove page edit lock'));
  my $id = GetParam('id', '');
  ValidIdOrDie($id);
  my $fname = GetLockedPageFile($id);
  if (GetParam('set', 1)) {
    WriteStringToFile($fname, 'editing locked.');
  } else {
    Unlink($fname);
  }
  utime time, time, $IndexFile; # touch index file
  print $q->p(IsFile($fname) ? Ts('Lock for %s created.', GetPageLink($id))
	      : Ts('Lock for %s removed.', GetPageLink($id)));
  PrintFooter();
}

sub DoShowVersion {
  print GetHeader('', T('Displaying Wiki Version')), $q->start_div({-class=>'content version'});
  print $WikiDescription, $q->p($q->server_software()),
    $q->p(sprintf('Perl v%vd', $^V)),
      $q->p($ENV{MOD_PERL} ? $ENV{MOD_PERL} : "no mod_perl"), $q->p('CGI: ', $CGI::VERSION),
  $q->p('LWP::UserAgent ', eval { local $SIG{__DIE__}; require LWP::UserAgent; $LWP::UserAgent::VERSION; }),
    $q->p('XML::RSS: ', eval { local $SIG{__DIE__}; require XML::RSS; $XML::RSS::VERSION; }),
      $q->p('XML::Parser: ', eval { local $SIG{__DIE__}; $XML::Parser::VERSION; });
  print $q->p('diff: ' . (`diff --version` || $!)), $q->p('diff3: ' . (`diff3 --version` || $!)) if $UseDiff;
  print $q->end_div();
  PrintFooter();
}

sub DoDebug {
  print GetHeader('', T('Debugging Information')),
    $q->start_div({-class=>'content debug'});
  foreach my $func (@Debugging) { $func->() }
  print $q->end_div();
  PrintFooter();
}

sub DoSurgeProtection {
  return unless $SurgeProtection;
  my $name = GetParam('username', $q->remote_addr());
  return unless $name;
  ReadRecentVisitors();
  AddRecentVisitor($name);
  if (RequestLockDir('visitors')) { # not fatal
    WriteRecentVisitors();
    ReleaseLockDir('visitors');
    if (DelayRequired($name)) {
      ReportError(Ts('Too many connections by %s', $name)
		  . ': ' . Tss('Please do not fetch more than %1 pages in %2 seconds.',
			       $SurgeProtectionViews, $SurgeProtectionTime),
		  '503 SERVICE UNAVAILABLE');
    }
  } elsif (GetParam('action', '') ne 'unlock') {
    ReportError(Ts('Could not get %s lock', 'visitors') . ': ' . Ts('Check whether the web server can create the directory %s and whether it can create files in it.', $TempDir), '503 SERVICE UNAVAILABLE');
  }
}

sub DelayRequired {
  my $name = shift;
  my @entries = @{$RecentVisitors{$name}};
  my $ts = $entries[$SurgeProtectionViews];
  return ($Now - $ts) < $SurgeProtectionTime;
}

sub AddRecentVisitor {
  my $name = shift;
  my $value = $RecentVisitors{$name};
  my @entries = ($Now);
  push(@entries, @{$value}) if $value;
  $RecentVisitors{$name} = \@entries;
}

sub ReadRecentVisitors {
  my ($status, $data) = ReadFile($VisitorFile);
  %RecentVisitors = ();
  return unless $status;
  foreach (split(/\n/, $data)) {
    my @entries = split /$FS/;
    my $name = shift(@entries);
    $RecentVisitors{$name} = \@entries if $name;
  }
}

sub WriteRecentVisitors {
  my $data = '';
  my $limit = $Now - $SurgeProtectionTime;
  foreach my $name (keys %RecentVisitors) {
    my @entries = @{$RecentVisitors{$name}};
    if ($entries[0] >= $limit) { # if the most recent one is too old, do not keep
      $data .=  join($FS, $name, @entries[0 .. $SurgeProtectionViews - 1]) . "\n";
    }
  }
  WriteStringToFile($VisitorFile, $data);
}

sub TextIsFile { $_[0] =~ /^#FILE (\S+) ?(\S+)?\n/; }

sub AddModuleDescription { # cannot use $q here because this is module init time
  my ($filename, $page, $dir, $tag) = @_;
  my $src = "https://alexschroeder.ch/cgit/oddmuse/tree/modules/$dir" . UrlEncode($filename) . ($tag ? '?' . $tag : '');
  my $doc = 'https://www.oddmuse.org/wiki/' . UrlEncode(FreeToNormal($page));
  $ModulesDescription .= "<p><a href=\"$src\">" . QuoteHtml($filename) . "</a>" . ($tag ? " ($tag)" : '');
  $ModulesDescription .= T(', see') . " <a href=\"$doc\">" . QuoteHtml($page) . "</a>" if $page;
  $ModulesDescription .= "</p>";
}

DoWikiRequest() if $RunCGI and not exists $ENV{MOD_PERL}; # Do everything.
1; # In case we are loaded from elsewhere
