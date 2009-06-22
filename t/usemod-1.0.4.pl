#!/usr/bin/perl
# UseModWiki version 1.0.4 (December 1, 2007)
# Copyright (C) 2000-2003 Clifford A. Adams  <caadams@usemod.com>
# Copyright (C) 2002-2003 Sunir Shah  <sunir@sunir.org>
# Based on the GPLed AtisWiki 0.3  (C) 1998 Markus Denker
#    <marcus@ira.uka.de>
# ...which was based on
#    the LGPLed CVWiki CVS-patches (C) 1997 Peter Merel
#    and The Original WikiWikiWeb  (C) Ward Cunningham
#        <ward@c2.com> (code reused with permission)
# Email and ThinLine options by Jim Mahoney <mahoney@marlboro.edu>
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

package UseModWiki;
use strict;
local $| = 1;  # Do not buffer output (localized for mod_perl)

# Configuration/constant variables:
use vars qw(@RcDays @HtmlPairs @HtmlSingle
  $TempDir $LockDir $DataDir $HtmlDir $UserDir $KeepDir $PageDir
  $InterFile $RcFile $RcOldFile $IndexFile $FullUrl $SiteName $HomePage
  $LogoUrl $RcDefault $IndentLimit $RecentTop $EditAllowed $UseDiff
  $UseSubpage $UseCache $RawHtml $SimpleLinks $NonEnglish $LogoLeft
  $KeepDays $HtmlTags $HtmlLinks $UseDiffLog $KeepMajor $KeepAuthor
  $FreeUpper $EmailNotify $SendMail $EmailFrom $FastGlob $EmbedWiki
  $ScriptTZ $BracketText $UseAmPm $UseConfig $UseIndex $UseLookup
  $RedirType $AdminPass $EditPass $UseHeadings $NetworkFile $BracketWiki
  $FreeLinks $WikiLinks $AdminDelete $FreeLinkPattern $RCName $RunCGI
  $ShowEdits $ThinLine $LinkPattern $InterLinkPattern $InterSitePattern
  $UrlProtocols $UrlPattern $ImageExtensions $RFCPattern $ISBNPattern
  $FS $FS1 $FS2 $FS3 $CookieName $SiteBase $StyleSheet $NotFoundPg
  $FooterNote $EditNote $MaxPost $NewText $NotifyDefault $HttpCharset
  $UserGotoBar $DeletedPage $ReplaceFile @ReplaceableFiles $TableSyntax
  $MetaKeywords $NamedAnchors $InterWikiMoniker $SiteDescription $RssLogoUrl
  $NumberDates $EarlyRules $LateRules $NewFS $KeepSize $SlashLinks $BGColor
  $UpperFirst $AdminBar $RepInterMap $DiffColor1 $DiffColor2 $ConfirmDel
  $MaskHosts $LockCrash $ConfigFile $HistoryEdit $OldThinLine 
  @IsbnNames @IsbnPre @IsbnPost $EmailFile $FavIcon $RssDays $UserHeader
  $UserBody $StartUID $ParseParas $AuthorFooter $UseUpload $AllUpload
  $UploadDir $UploadUrl $LimitFileUrl $MaintTrimRc $SearchButton 
  $EditNameLink $UseMetaWiki @ImageSites $BracketImg );
# Note: $NotifyDefault is kept because it was a config variable in 0.90
# Other global variables:
use vars qw(%Page %Section %Text %InterSite %SaveUrl %SaveNumUrl
  %KeptRevisions %UserCookie %SetCookie %UserData %IndexHash %Translate
  %LinkIndex $InterSiteInit $SaveUrlIndex $SaveNumUrlIndex $MainPage
  $OpenPageName @KeptList @IndexList $IndexInit $TableMode
  $q $Now $UserID $TimeZoneOffset $ScriptName $BrowseCode $OtherCode
  $AnchoredLinkPattern @HeadingNumbers $TableOfContents $QuotedFullUrl
  $ConfigError $UploadPattern );

# == Configuration =====================================================
$DataDir     = "/tmp/mywikidb"; # Main wiki directory
$UseConfig   = 1;       # 1 = use config file,    0 = do not look for config
$ConfigFile  = "$DataDir/config";   # Configuration file

# Default configuration (used if UseConfig is 0)
$CookieName  = "Wiki";          # Name for this wiki (for multi-wiki sites)
$SiteName    = "Wiki";          # Name of site (used for titles)
$HomePage    = "HomePage";      # Home page (change space to _)
$RCName      = "RecentChanges"; # Name of changes page (change space to _)
$LogoUrl     = "/wiki.gif";     # URL for site logo ("" for no logo)
$ENV{PATH}   = "/usr/bin/";     # Path used to find "diff"
$ScriptTZ    = "";              # Local time zone ("" means do not print)
$RcDefault   = 30;              # Default number of RecentChanges days
@RcDays      = qw(1 3 7 30 90); # Days for links on RecentChanges
$KeepDays    = 14;              # Days to keep old revisions
$SiteBase    = "";              # Full URL for <BASE> header
$FullUrl     = "";              # Set if the auto-detected URL is wrong
$RedirType   = 1;               # 1 = CGI.pm, 2 = script, 3 = no redirect
$AdminPass   = "";              # Set to non-blank to enable password(s)
$EditPass    = "";              # Like AdminPass, but for editing only
$StyleSheet  = "";              # URL for CSS stylesheet (like "/wiki.css")
$NotFoundPg  = "";              # Page for not-found links ("" for blank pg)
$EmailFrom   = "Wiki";          # Text for "From: " field of email notes.
$SendMail    = "/usr/sbin/sendmail";  # Full path to sendmail executable
$FooterNote  = "";              # HTML for bottom of every page
$EditNote    = "";              # HTML notice above buttons on edit page
$MaxPost     = 1024 * 210;      # Maximum 210K posts (about 200K for pages)
$NewText     = "";              # New page text ("" for default message)
$HttpCharset = "";              # Charset for pages, like "iso-8859-2"
$UserGotoBar = "";              # HTML added to end of goto bar
$InterWikiMoniker = '';         # InterWiki moniker for this wiki. (for RSS)
$SiteDescription  = $SiteName;  # Description of this wiki. (for RSS)
$RssLogoUrl  = '';              # Optional image for RSS feed
$EarlyRules  = '';              # Local syntax rules for wiki->html (evaled)
$LateRules   = '';              # Local syntax rules for wiki->html (evaled)
$KeepSize    = 0;               # If non-zero, maximum size of keep file
$BGColor     = 'white';         # Background color ('' to disable)
$DiffColor1  = '#ffffaf';       # Background color of old/deleted text
$DiffColor2  = '#cfffcf';       # Background color of new/added text
$FavIcon     = '';              # URL of bookmark/favorites icon, or ''
$RssDays     = 7;               # Default number of days in RSS feed
$UserHeader  = '';              # Optional HTML header additional content
$UserBody    = '';              # Optional <BODY> tag additional content
$StartUID    = 1001;            # Starting number for user IDs
$UploadDir   = '';              # Full path (like /foo/www/uploads) for files
$UploadUrl   = '';              # Full URL (like http://foo.com/uploads)
@ImageSites  = qw();            # Url prefixes of good image sites: ()=all

# Major options:
$UseSubpage  = 1;           # 1 = use subpages,       0 = do not use subpages
$UseCache    = 0;           # 1 = cache HTML pages,   0 = generate every page
$EditAllowed = 1;           # 1 = editing allowed,    0 = read-only
$RawHtml     = 0;           # 1 = allow <HTML> tag,   0 = no raw HTML in pages
$HtmlTags    = 0;           # 1 = "unsafe" HTML tags, 0 = only minimal tags
$UseDiff     = 1;           # 1 = use diff features,  0 = do not use diff
$FreeLinks   = 1;           # 1 = use [[word]] links, 0 = LinkPattern only
$WikiLinks   = 1;           # 1 = use LinkPattern,    0 = use [[word]] only
$AdminDelete = 1;           # 1 = Admin only deletes, 0 = Editor can delete
$RunCGI      = 1;           # 1 = Run script as CGI,  0 = Load but do not run
$EmailNotify = 0;           # 1 = use email notices,  0 = no email on changes
$EmbedWiki   = 0;           # 1 = no headers/footers, 0 = normal wiki pages
$DeletedPage = 'DeletedPage';   # 0 = disable, 'PageName' = tag to delete page
$ReplaceFile = 'ReplaceFile';   # 0 = disable, 'PageName' = indicator tag
@ReplaceableFiles = ();     # List of allowed server files to replace
$TableSyntax = 1;           # 1 = wiki syntax tables, 0 = no table syntax
$NewFS       = 0;           # 1 = new multibyte $FS,  0 = old $FS
$UseUpload   = 0;           # 1 = allow uploads,      0 = no uploads

# Minor options:
$LogoLeft     = 0;      # 1 = logo on left,       0 = logo on right
$RecentTop    = 1;      # 1 = recent on top,      0 = recent on bottom
$UseDiffLog   = 1;      # 1 = save diffs to log,  0 = do not save diffs
$KeepMajor    = 1;      # 1 = keep major rev,     0 = expire all revisions
$KeepAuthor   = 1;      # 1 = keep author rev,    0 = expire all revisions
$ShowEdits    = 0;      # 1 = show minor edits,   0 = hide edits by default
$HtmlLinks    = 0;      # 1 = allow A HREF links, 0 = no raw HTML links
$SimpleLinks  = 0;      # 1 = only letters,       0 = allow _ and numbers
$NonEnglish   = 0;      # 1 = extra link chars,   0 = only A-Za-z chars
$ThinLine     = 0;      # 1 = fancy <hr> tags,    0 = classic wiki <hr>
$BracketText  = 1;      # 1 = allow [URL text],   0 = no link descriptions
$UseAmPm      = 1;      # 1 = use am/pm in times, 0 = use 24-hour times
$UseIndex     = 0;      # 1 = use index file,     0 = slow/reliable method
$UseHeadings  = 1;      # 1 = allow = h1 text =,  0 = no header formatting
$NetworkFile  = 1;      # 1 = allow remote file:, 0 = no file:// links
$BracketWiki  = 0;      # 1 = [WikiLnk txt] link, 0 = no local descriptions
$UseLookup    = 1;      # 1 = lookup host names,  0 = skip lookup (IP only)
$FreeUpper    = 1;      # 1 = force upper case,   0 = do not force case
$FastGlob     = 1;      # 1 = new faster code,    0 = old compatible code
$MetaKeywords = 1;      # 1 = Google-friendly,    0 = search-engine averse
$NamedAnchors = 1;      # 0 = no anchors, 1 = enable anchors,
                        # 2 = enable but suppress display
$SlashLinks   = 0;      # 1 = use script/action links, 0 = script?action
$UpperFirst   = 1;      # 1 = free links start uppercase, 0 = no ucfirst
$AdminBar     = 1;      # 1 = admins see admin links, 0 = no admin bar
$RepInterMap  = 0;      # 1 = intermap is replacable, 0 = not replacable
$ConfirmDel   = 1;      # 1 = delete link confirm page, 0 = immediate delete
$MaskHosts    = 0;      # 1 = mask hosts/IPs,      0 = no masking
$LockCrash    = 0;      # 1 = crash if lock stuck, 0 = auto clear locks
$HistoryEdit  = 0;      # 1 = edit links on history page, 0 = no edit links
$OldThinLine  = 0;      # 1 = old ==== thick line, 0 = ------ for thick line
$NumberDates  = 0;      # 1 = 2003-6-17 dates,     0 = June 17, 2003 dates
$ParseParas   = 0;      # 1 = new paragraph markup, 0 = old markup
$AuthorFooter = 1;      # 1 = show last author in footer, 0 = do not show
$AllUpload    = 0;      # 1 = anyone can upload,   0 = only editor/admins
$LimitFileUrl = 1;      # 1 = limited use of file: URLs, 0 = no limits
$MaintTrimRc  = 0;      # 1 = maintain action trims RC, 0 = only maintainrc
$SearchButton = 0;      # 1 = search button on page, 0 = old behavior
$EditNameLink = 0;      # 1 = edit links use name (CSS), 0 = '?' links
$UseMetaWiki  = 0;      # 1 = add MetaWiki search links, 0 = no MW links
$BracketImg   = 1;      # 1 = [url url.gif] becomes image link, 0 = no img

# Names of sites.  (The first entry is used for the number link.)
@IsbnNames = ('bn.com', 'amazon.com', 'search');
# Full URL of each site before the ISBN
@IsbnPre = ('http://search.barnesandnoble.com/booksearch/isbninquiry.asp?isbn=',
            'http://www.amazon.com/exec/obidos/ISBN=',
            'http://www.pricescan.com/books/BookDetail.asp?isbn=');
# Rest of URL of each site after the ISBN (usually '')
@IsbnPost = ('', '', '');

# HTML tag lists, enabled if $HtmlTags is set.
# Scripting is currently possible with these tags,
# so they are *not* particularly "safe".
# Tags that must be in <tag> ... </tag> pairs:
@HtmlPairs = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
  em s strike strong tt var div center blockquote ol ul dl table caption);
# Single tags (that do not require a closing /tag)
@HtmlSingle = qw(br p hr li dt dd tr td th);
@HtmlPairs = (@HtmlPairs, @HtmlSingle);  # All singles can also be pairs

# == You should not have to change anything below this line. =============
$IndentLimit = 20;                  # Maximum depth of nested lists
$PageDir     = "$DataDir/page";     # Stores page data
$HtmlDir     = "$DataDir/html";     # Stores HTML versions
$UserDir     = "$DataDir/user";     # Stores user data
$KeepDir     = "$DataDir/keep";     # Stores kept (old) page data
$TempDir     = "$DataDir/temp";     # Temporary files and locks
$LockDir     = "$TempDir/lock";     # DB is locked if this exists
$InterFile   = "$DataDir/intermap"; # Interwiki site->url map
$RcFile      = "$DataDir/rclog";    # New RecentChanges logfile
$RcOldFile   = "$DataDir/oldrclog"; # Old RecentChanges logfile
$IndexFile   = "$DataDir/pageidx";  # List of all pages
$EmailFile   = "$DataDir/emails";   # Email notification lists

if ($RepInterMap) {
  push @ReplaceableFiles, $InterFile;
}

# The "main" program, called at the end of this script file.
sub DoWikiRequest {
  if ($UseConfig && (-f $ConfigFile)) {
    $ConfigError = '';
    if (!do $ConfigFile) {   # Some error occurred
      $ConfigError = $@;
      if ($ConfigError eq '') {
        # Unfortunately, if the last expr returns 0, one will get a false
        # error above.  To remain compatible with existing installs the
        # wiki must not report an error unless there is error text in $@.
        # (Errors in "use strict" may not have error text.)
        # Uncomment the line below if you want to catch use strict errors.
#       $ConfigError = T('Unknown Error (no error text)');
      }
    }
  }
  &InitLinkPatterns();
  if (!&DoCacheBrowse()) {
    eval $BrowseCode;
    &InitRequest() or return;
    if (!&DoBrowseRequest()) {
      eval $OtherCode;
      &DoOtherRequest();
    }
  }
}

# == Common and cache-browsing code ====================================
sub InitLinkPatterns {
  my ($UpperLetter, $LowerLetter, $AnyLetter, $LpA, $LpB, $QDelim);

  # Field separators are used in the URL-style patterns below.
  if ($NewFS) {
    $FS  = "\x1e\xff\xfe\x1e";    # An unlikely sequence for any charset
  } else {
    $FS  = "\xb3";    # The FS character is a superscript "3"
  }
  $FS1 = $FS . "1";   # The FS values are used to separate fields
  $FS2 = $FS . "2";   # in stored hashtables and other data structures.
  $FS3 = $FS . "3";   # The FS character is not allowed in user data.
  $UpperLetter = "[A-Z";
  $LowerLetter = "[a-z";
  $AnyLetter   = "[A-Za-z";
  if ($NonEnglish) {
    $UpperLetter .= "\xc0-\xde";
    $LowerLetter .= "\xdf-\xff";
    if ($NewFS) {
      $AnyLetter   .= "\x80-\xff";
    } else {
      $AnyLetter   .= "\xc0-\xff";
    }
  }
  if (!$SimpleLinks) {
    $AnyLetter .= "_0-9";
  }
  $UpperLetter .= "]"; $LowerLetter .= "]"; $AnyLetter .= "]";
  # Main link pattern: lowercase between uppercase, then anything
  $LpA = $UpperLetter . "+" . $LowerLetter . "+" . $UpperLetter
         . $AnyLetter . "*";
  # Optional subpage link pattern: uppercase, lowercase, then anything
  $LpB = $UpperLetter . "+" . $LowerLetter . "+" . $AnyLetter . "*";
  if ($UseSubpage) {
    # Loose pattern: If subpage is used, subpage may be simple name
    $LinkPattern = "((?:(?:$LpA)?\\/$LpB)|$LpA)";
    # Strict pattern: both sides must be the main LinkPattern
    # $LinkPattern = "((?:(?:$LpA)?\\/)?$LpA)";
  } else {
    $LinkPattern = "($LpA)";
  }
  $QDelim = '(?:"")?';     # Optional quote delimiter (not in output)
  $AnchoredLinkPattern = $LinkPattern . '#(\\w+)' . $QDelim if $NamedAnchors;
  $LinkPattern .= $QDelim;
  # Inter-site convention: sites must start with uppercase letter
  # (Uppercase letter avoids confusion with URLs)
  $InterSitePattern = $UpperLetter . $AnyLetter . "+";
  $InterLinkPattern = "((?:$InterSitePattern:[^\\]\\s\"<>$FS]+)$QDelim)";
  if ($FreeLinks) {
    # Note: the - character must be first in $AnyLetter definition
    if ($NonEnglish) {
      if ($NewFS) {
        $AnyLetter = "[-,.()' _0-9A-Za-z\x80-\xff]";
      } else {
        $AnyLetter = "[-,.()' _0-9A-Za-z\xc0-\xff]";
      }
    } else {
      $AnyLetter = "[-,.()' _0-9A-Za-z]";
    }
  }
  $FreeLinkPattern = "($AnyLetter+)";
  if ($UseSubpage) {
    $FreeLinkPattern = "((?:(?:$AnyLetter+)?\\/)?$AnyLetter+)";
  }
  $FreeLinkPattern .= $QDelim;
  # Url-style links are delimited by one of:
  #   1.  Whitespace                           (kept in output)
  #   2.  Left or right angle-bracket (< or >) (kept in output)
  #   3.  Right square-bracket (])             (kept in output)
  #   4.  A single double-quote (")            (kept in output)
  #   5.  A $FS (field separator) character    (kept in output)
  #   6.  A double double-quote ("")           (removed from output)
  $UrlProtocols = "http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|"
                  . "prospero|telnet|gopher";
  $UrlProtocols .= '|file'  if ($NetworkFile || !$LimitFileUrl);
  $UrlPattern = "((?:(?:$UrlProtocols):[^\\]\\s\"<>$FS]+)$QDelim)";
  $ImageExtensions = "(gif|jpg|png|bmp|jpeg|ico|tiff?)";
  $RFCPattern = "RFC\\s?(\\d+)";
  $ISBNPattern = "ISBN:?([0-9- xX]{10,})";
  $UploadPattern = "upload:([^\\]\\s\"<>$FS]+)$QDelim";
}

# Simple HTML cache
sub DoCacheBrowse {
  my ($query, $idFile, $text);

  return 0  if (!$UseCache);
  $query = $ENV{'QUERY_STRING'};
  if (($query eq "") && ($ENV{'REQUEST_METHOD'} eq "GET")) {
    $query = $HomePage;  # Allow caching of home page.
  }
  if (!($query =~ /^$LinkPattern$/)) {
    if (!($FreeLinks && ($query =~ /^$FreeLinkPattern$/))) {
      return 0;  # Only use cache for simple links
    }
  }
  $idFile = &GetHtmlCacheFile($query);
  if (-f $idFile) {
    local $/ = undef;   # Read complete files
    open(INFILE, "<$idFile") or return 0;
    $text = <INFILE>;
    close INFILE;
    print $text;
    return 1;
  }
  return 0;
}

sub GetHtmlCacheFile {
  my ($id) = @_;

  return $HtmlDir . "/" . &GetPageDirectory($id) . "/$id.htm";
}

sub GetPageDirectory {
  my ($id) = @_;

  if ($id =~ /^([a-zA-Z])/) {
    return uc($1);
  }
  return "other";
}

sub T {
  my ($text) = @_;

  if (defined($Translate{$text}) && ($Translate{$text} ne ''))  {
    return $Translate{$text};
  }
  return $text;
}

sub Ts {
  my ($text, $string, $noquote) = @_;

  $string = &QuoteHtml($string) unless $noquote;
  $text = T($text);
  $text =~ s/\%s/$string/;
  return $text;
}

sub Tss {
  my $text = $_[0];
  my @args = @_;

  @args = map {
    $_ = &QuoteHtml($_);
  } @args;
  $text = T($text);
  $text =~ s/\%([1-9])/$args[$1]/ge;
  return $text;
}

sub QuoteHtml {
  my ($html) = @_;

  $html =~ s/&/&amp;/g;
  $html =~ s/</&lt;/g;
  $html =~ s/>/&gt;/g;
  $html =~ s/&amp;([#a-zA-Z0-9]+);/&$1;/g;  # Allow character references
  return $html;
}

# == Normal page-browsing and RecentChanges code =======================
$BrowseCode = ""; # Comment next line to always compile (slower)
#$BrowseCode = <<'#END_OF_BROWSE_CODE';
use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub InitRequest {
  my @ScriptPath = split('/', "$ENV{SCRIPT_NAME}");

  $CGI::POST_MAX = $MaxPost;
  if ($UseUpload) {
    $CGI::DISABLE_UPLOADS = 0;  # allow uploads
  } else {
    $CGI::DISABLE_UPLOADS = 1;  # no uploads
  }
  $q = new CGI;
  # Fix some issues with editing UTF8 pages (if charset specified)
  if ($HttpCharset ne '') {
    $q->charset($HttpCharset);
  }
  $Now = time;                     # Reset in case script is persistent
  $ScriptName = pop(@ScriptPath);  # Name used in links
  $IndexInit = 0;                  # Must be reset for each request
  $InterSiteInit = 0;
  %InterSite = ();
  $MainPage = ".";       # For subpages only, the name of the top-level page
  $OpenPageName = "";    # Currently open page
  &CreateDir($DataDir);  # Create directory if it doesn't exist
  if (!-d $DataDir) {
    &ReportError(Ts('Could not create %s', $DataDir) . ": $!");
    return 0;
  }
  &InitCookie();         # Reads in user data
  return 1;
}

sub InitCookie {
  %SetCookie = ();
  $TimeZoneOffset = 0;
  undef $q->{'.cookies'};  # Clear cache if it exists (for SpeedyCGI)
  %UserData = ();          # Fix for persistent environments.
  %UserCookie = $q->cookie($CookieName);
  $UserID = $UserCookie{'id'};
  $UserID =~ s/\D//g;  # Numeric only
  if ($UserID < 200) {
    $UserID = 111;
  } else {
    &LoadUserData($UserID);
  }
  if ($UserID > 199) {
    if (($UserData{'id'}       != $UserCookie{'id'})      ||
        ($UserData{'randkey'}  != $UserCookie{'randkey'})) {
      $UserID = 113;
      %UserData = ();   # Invalid.  Consider warning message.
    }
  }
  if ($UserData{'tzoffset'} != 0) {
    $TimeZoneOffset = $UserData{'tzoffset'} * (60 * 60);
  }
}

sub DoBrowseRequest {
  my ($id, $action, $text);

  if (!$q->param) {             # No parameter
    &BrowsePage($HomePage);
    return 1;
  }
  $id = &GetParam('keywords', '');
  if ($id) {                    # Just script?PageName
    if ($FreeLinks && (!-f &GetPageFile($id))) {
      $id = &FreeToNormal($id);
    }
    if (($NotFoundPg ne '') && (!-f &GetPageFile($id))) {
      $id = $NotFoundPg;
    }
    &BrowsePage($id)  if &ValidIdOrDie($id);
    return 1;
  }
  $action = lc(&GetParam('action', ''));
  $id = &GetParam('id', '');
  if ($action eq 'browse') {
    if ($FreeLinks && (!-f &GetPageFile($id))) {
      $id = &FreeToNormal($id);
    }
    if (($NotFoundPg ne '') && (!-f &GetPageFile($id))) {
      $id = $NotFoundPg;
    }
    &BrowsePage($id)  if &ValidIdOrDie($id);
    return 1;
  } elsif ($action eq 'rc') {
    &BrowsePage($RCName);
    return 1;
  } elsif ($action eq 'random') {
    &DoRandom();
    return 1;
  } elsif ($action eq 'history') {
    &DoHistory($id)   if &ValidIdOrDie($id);
    return 1;
  }
  return 0;  # Request not handled
}

sub BrowsePage {
  my ($id) = @_;
  my ($fullHtml, $oldId, $allDiff, $showDiff, $openKept);
  my ($revision, $goodRevision, $diffRevision, $newText);

  &OpenPage($id);
  &OpenDefaultText();
  $openKept = 0;
  $revision = &GetParam('revision', '');
  $revision =~ s/\D//g;           # Remove non-numeric chars
  $goodRevision = $revision;      # Non-blank only if exists
  if ($revision ne '') {
    &OpenKeptRevisions('text_default');
    $openKept = 1;
    if (!defined($KeptRevisions{$revision})) {
      $goodRevision = '';
    } else {
      &OpenKeptRevision($revision);
    }
  }
  # Raw mode: just untranslated wiki text
  if (&GetParam('raw', 0)) {
     print &GetHttpHeader('text/plain');
     print $Text{'text'};
     return;
  }
  $newText = $Text{'text'};     # For differences
  # Handle a single-level redirect
  $oldId = &GetParam('oldid', '');
  if (($oldId eq '') && (substr($Text{'text'}, 0, 10) eq '#REDIRECT ')) {
    $oldId = $id;
    if (($FreeLinks) && ($Text{'text'} =~ /\#REDIRECT\s+\[\[.+\]\]/)) {
      ($id) = ($Text{'text'} =~ /\#REDIRECT\s+\[\[(.+)\]\]/);
      $id = &FreeToNormal($id);
    } else {
      ($id) = ($Text{'text'} =~ /\#REDIRECT\s+(\S+)/);
    }
    if (&ValidId($id) eq '') {
      # Consider revision in rebrowse?
      &ReBrowsePage($id, $oldId, 0);
      return;
    } else {  # Not a valid target, so continue as normal page
      $id = $oldId;
      $oldId = '';
    }
  }
  $MainPage = $id;
  $MainPage =~ s|/.*||;  # Only the main page name (remove subpage)
  $fullHtml = &GetHeader($id, &QuoteHtml($id), $oldId, 1);
  if ($revision ne '') {
    if (($revision eq $Page{'revision'}) || ($goodRevision ne '')) {
      $fullHtml .= '<b>' . Ts('Showing revision %s', $revision) . "</b><br>";
    } else {
      $fullHtml .= '<b>' . Ts('Revision %s not available', $revision)
                   . ' (' . T('showing current revision instead')
                   . ')</b><br>';
    }
  }
  $allDiff  = &GetParam('alldiff', 0);
  if ($allDiff != 0) {
    $allDiff = &GetParam('defaultdiff', 1);
  }
  if ((($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName))
      && &GetParam('norcdiff', 1)) {
    $allDiff = 0;  # Only show if specifically requested
  }
  $showDiff = &GetParam('diff', $allDiff);
  if ($UseDiff && $showDiff) {
    $diffRevision = $goodRevision;
    $diffRevision = &GetParam('diffrevision', $diffRevision);
    # Eventually try to avoid the following keep-loading if possible?
    &OpenKeptRevisions('text_default')  if (!$openKept);
    $fullHtml .= &GetDiffHTML($showDiff, $id, $diffRevision,
                              $revision, $newText);
    $fullHtml .= "<hr class=wikilinediff>\n";
  }
  $fullHtml .= '<div class=wikitext>';
  $fullHtml .= &WikiToHTML($Text{'text'});
  $fullHtml .= '</div>';
  if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)) {
    print $fullHtml;
    print "<hr class=wikilinerc>\n";
    print '<div class=wikirc>';
    &DoRc(1);
    print '</div>';
    print &GetFooterText($id, $goodRevision);
    return;
  }
  $fullHtml .= &GetFooterText($id, $goodRevision);
  print $fullHtml;
  return  if ($showDiff || ($revision ne ''));  # Don't cache special version
  &UpdateHtmlCache($id, $fullHtml)  if ($UseCache && ($oldId eq ''));
}

sub ReBrowsePage {
  my ($id, $oldId, $isEdit) = @_;

  if ($oldId ne "") {   # Target of #REDIRECT (loop breaking)
    print &GetRedirectPage("action=browse&id=$id&oldid=$oldId",
                           $id, $isEdit);
  } else {
    print &GetRedirectPage($id, $id, $isEdit);
  }
}

sub DoRc {
  my ($rcType) = @_;   # 0 = RSS, 1 = HTML
  my ($fileData, $rcline, $i, $daysago, $lastTs, $ts, $idOnly);
  my (@fullrc, $status, $oldFileData, $firstTs, $errorText, $showHTML);
  my $starttime = 0;
  my $showbar = 0;

  if (0 == $rcType) {
    $showHTML = 0;
  } else {
    $showHTML = 1;
  }
  if (&GetParam("from", 0)) {
    $starttime = &GetParam("from", 0);
    if ($showHTML) {
      print "<h2>" . Ts('Updates since %s', &TimeToText($starttime))
            . "</h2>\n";
    }
  } else {
    $daysago = &GetParam("days", 0);
    $daysago = &GetParam("rcdays", 0)  if ($daysago == 0);
    if ($daysago) {
      $starttime = $Now - ((24*60*60)*$daysago);
      if ($showHTML) {
        print "<h2>" . Ts('Updates in the last %s day'
                          . (($daysago != 1)?"s":""), $daysago) . "</h2>\n";
      }
      # Note: must have two translations (for "day" and "days")
      # Following comment line is for translation helper script
      # Ts('Updates in the last %s days', '');
    }
  }
  if ($starttime == 0) {
    if (0 == $rcType) {
      $starttime = $Now - ((24*60*60)*$RssDays);
    } else {
      $starttime = $Now - ((24*60*60)*$RcDefault);
    }
    if ($showHTML) {
      print "<h2>" . Ts('Updates in the last %s day'
                        . (($RcDefault != 1)?"s":""), $RcDefault) . "</h2>\n";
    }
    # Translation of above line is identical to previous version
  }
  # Read rclog data (and oldrclog data if needed)
  ($status, $fileData) = &ReadFile($RcFile);
  $errorText = "";
  if (!$status) {
    # Save error text if needed.
    $errorText = '<p><strong>' . Ts('Could not open %s log file', $RCName)
                 . ":</strong> $RcFile<p>"
                 . T('Error was') . ":\n<pre>$!</pre>\n" . '<p>'
    . T('Note: This error is normal if no changes have been made.') . "\n";
  }
  @fullrc = split(/\n/, $fileData);
  $firstTs = 0;
  if (@fullrc > 0) {  # Only false if no lines in file
    ($firstTs) = split(/$FS3/, $fullrc[0]);
  }
  if (($firstTs == 0) || ($starttime <= $firstTs)) {
    ($status, $oldFileData) = &ReadFile($RcOldFile);
    if ($status) {
      @fullrc = split(/\n/, $oldFileData . $fileData);
    } else {
      if ($errorText ne "") {  # could not open either rclog file
        print $errorText;
        print "<p><strong>"
              . Ts('Could not open old %s log file', $RCName)
              . ":</strong> $RcOldFile<p>"
              . T('Error was') . ":\n<pre>$!</pre>\n";
        return;
      }
    }
  }
  $lastTs = 0;
  if (@fullrc > 0) {  # Only false if no lines in file
    ($lastTs) = split(/$FS3/, $fullrc[$#fullrc]);
  }
  $lastTs++  if (($Now - $lastTs) > 5);  # Skip last unless very recent

  $idOnly = &GetParam("rcidonly", "");
  if ($idOnly && $showHTML) {
    print '<b>(' . Ts('for %s only', &ScriptLink($idOnly, &QuoteHtml($idOnly)), 1)
          . ')</b><br>';
  }
  if ($showHTML) {
    foreach $i (@RcDays) {
      print " | "  if $showbar;
      $showbar = 1;
      print &ScriptLink("action=rc&days=$i",
                        Ts('%s day' . (($i != 1)?'s':''), $i));
        # Note: must have two translations (for "day" and "days")
        # Following comment line is for translation helper script
        # Ts('%s days', '');
    }
    print "<br>" . &ScriptLink("action=rc&from=$lastTs",
                               T('List new changes starting from'));
    print " " . &TimeToText($lastTs) . "<br>\n";
  }
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
                              &TimeToText($starttime)) . "</strong><br>\n";
  } else {
    splice(@fullrc, 0, $i);  # Remove items before index $i
    # Consider an end-time limit (items older than X)
    if (0 == $rcType) {
      print &GetRcRss(@fullrc);
    } else {
      print &GetRcHtml(@fullrc);
    }
  }
  if ($showHTML) {
    print '<p>' . Ts('Page generated %s', &TimeToText($Now)), "<br>\n";
  }
}

sub GetRc {
  my $rcType = shift;
  my @outrc = @_;
  my ($rcline, $date, $newtop, $author, $inlist, $result);
  my ($showedit, $link, $all, $idOnly, $headItem, $item);
  my ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp);
  my ($rcchangehist, $tEdit, $tChanges, $tDiff);
  my ($headList, $pagePrefix, $historyPrefix, $diffPrefix);
  my %extra = ();
  my %changetime = ();
  my %pagecount = ();

  # Slice minor edits
  $showedit = &GetParam("rcshowedit", $ShowEdits);
  $showedit = &GetParam("showedit", $showedit);
  if ($showedit != 1) {
    my @temprc = ();
    foreach $rcline (@outrc) {
      ($ts, $pagename, $summary, $isEdit, $host) = split(/$FS3/, $rcline);
      if ($showedit == 0) {  # 0 = No edits
        push(@temprc, $rcline)  if (!$isEdit);
      } else {               # 2 = Only edits
        push(@temprc, $rcline)  if ($isEdit);
      }
    }
    @outrc = @temprc;
  }
  # Optimize param fetches out of main loop
  $rcchangehist = &GetParam("rcchangehist", 1);
  # Optimize translations out of main loop
  $tEdit    = T('(edit)');
  $tDiff    = T('(diff)');
  $tChanges = T('changes');
  $pagePrefix = $QuotedFullUrl . &ScriptLinkChar();
  $diffPrefix = $pagePrefix . &QuoteHtml("action=browse&diff=4&id=");
  $historyPrefix = $pagePrefix . &QuoteHtml("action=history&id=");
  foreach $rcline (@outrc) {
    ($ts, $pagename) = split(/$FS3/, $rcline);
    $pagecount{$pagename}++;
    $changetime{$pagename} = $ts;
  }
  $date = "";
  $all = &GetParam("rcall", 0);
  $all = &GetParam("all", $all);
  $newtop = &GetParam("rcnewtop", $RecentTop);
  $newtop = &GetParam("newtop", $newtop);
  $idOnly = &GetParam("rcidonly", "");
  $inlist = 0;
  $headList = '';
  $result = '';
  @outrc = reverse @outrc if ($newtop);
  foreach $rcline (@outrc) {
    ($ts, $pagename, $summary, $isEdit, $host, $kind, $extraTemp)
      = split(/$FS3/, $rcline);
    next  if ((!$all) && ($ts < $changetime{$pagename}));
    next  if (($idOnly ne "") && ($idOnly ne $pagename));
    %extra = split(/$FS2/, $extraTemp, -1);
    if ($date ne &CalcDay($ts)) {
      $date = &CalcDay($ts);
      if (1 == $rcType) {  # HTML
        # add date, properly closing lists first
        if ($inlist) {
          $result .= "</UL>\n";
          $inlist = 0;
        }
        $result .= "<p><strong>" . $date . "</strong></p>\n";
        if (!$inlist) {
          $result .= "<UL>\n";
          $inlist = 1;
        }
      }
    }
    if (0 == $rcType) {  # RSS
      ($headItem, $item) = &GetRssRcLine($pagename, $ts, $host,
                              $extra{'name'}, $extra{'id'}, $summary, $isEdit,
                              $pagecount{$pagename}, $extra{'revision'},
                              $diffPrefix, $historyPrefix, $pagePrefix);
      $headList .= $headItem;
      $result   .= $item;
    } else {  # HTML
      $result .= &GetHtmlRcLine($pagename, $ts, $host, $extra{'name'},
                         $extra{'id'}, $summary, $isEdit,
                         $pagecount{$pagename}, $extra{'revision'},
                         $tEdit, $tDiff, $tChanges, $all, $rcchangehist);
    }
  }
  if (1 == $rcType) {
    $result .= "</UL>\n"  if ($inlist);  # Close final tag
  }
  return ($headList, $result);  # Just ignore headList for HTML
}

sub GetRcHtml {
  my ($html, $extra);

  ($extra, $html) = &GetRc(1, @_);
  return $html;
}

sub GetHtmlRcLine {
  my ($pagename, $timestamp, $host, $userName, $userID, $summary,
      $isEdit, $pagecount, $revision, $tEdit, $tDiff, $tChanges, $all,
      $rcchangehist) = @_;
  my ($author, $sum, $edit, $count, $link, $html);

  $html = '';
  $host = &QuoteHtml($host);
  if (defined($userName) && defined($userID)) {
    $author = &GetAuthorLink($host, $userName, $userID);
  } else {
    $author = &GetAuthorLink($host, "", 0);
  }
  $sum = "";
  if (($summary ne "") && ($summary ne "*")) {
    $summary = &QuoteHtml($summary);
    $sum = "<strong>[$summary]</strong> ";
  }
  $edit = "";
  $edit = "<em>$tEdit</em> "  if ($isEdit);
  $count = "";
  if ((!$all) && ($pagecount > 1)) {
    $count = "($pagecount ";
    if ($rcchangehist) {
      $count .= &GetHistoryLink($pagename, $tChanges);
    } else {
      $count .= $tChanges;
    }
    $count .= ") ";
  }
  $link = "";
  if ($UseDiff && &GetParam("diffrclink", 1)) {
    $link .= &ScriptLinkDiff(4, $pagename, $tDiff, "") . "  ";
  }
  $link .= &GetPageLink($pagename);
  $html .= "<li>$link ";
  $html .=  &CalcTime($timestamp) . " $count$edit" . " $sum";
  $html .= ". . . . . $author\n";
  return $html;
}

sub GetRcRss {
  my ($rssHeader, $headList, $items);

  # Normally get URL from script, but allow override
  $FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
  $QuotedFullUrl = &QuoteHtml($FullUrl);
  $SiteDescription = &QuoteHtml($SiteDescription);

  my $ChannelAbout = &QuoteHtml($FullUrl . &ScriptLinkChar()
                                . $ENV{QUERY_STRING});
  $rssHeader = <<RSS ;
<?xml version="1.0" encoding="ISO-8859-1"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns="http://purl.org/rss/1.0/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:wiki="http://purl.org/rss/1.0/modules/wiki/"
>
    <channel rdf:about="$ChannelAbout">
        <title>${\(&QuoteHtml($SiteName))}</title>
        <link>${\($QuotedFullUrl . &ScriptLinkChar() . &QuoteHtml("$RCName"))}</link>
        <description>${\(&QuoteHtml($SiteDescription))}</description>
        <wiki:interwiki>
            <rdf:Description link="$QuotedFullUrl">
                <rdf:value>$InterWikiMoniker</rdf:value>
            </rdf:Description>
        </wiki:interwiki>
        <items>
            <rdf:Seq>
RSS
  ($headList, $items) = &GetRc(0, @_);
  $rssHeader .= $headList;
  return <<RSS ;
$rssHeader
            </rdf:Seq>
        </items>
    </channel>
    <image rdf:about="${\(&QuoteHtml($RssLogoUrl))}">
        <title>${\(&QuoteHtml($SiteName))}</title>
        <url>$RssLogoUrl</url>
        <link>$QuotedFullUrl</link>
    </image>
$items
</rdf:RDF>
RSS
}

sub GetRssRcLine{
  my ($pagename, $timestamp, $host, $userName, $userID, $summary, $isEdit,
      $pagecount, $revision, $diffPrefix, $historyPrefix, $pagePrefix) = @_;
  my ($pagenameEsc, $itemID, $description, $authorLink, $author, $status,
      $importance, $date, $item, $headItem);

  $pagenameEsc = CGI::escape($pagename);
  # Add to list of items in the <channel/>
  $itemID = $FullUrl . &ScriptLinkChar()
            . &GetOldPageParameters('browse', $pagenameEsc, $revision);
  $itemID = &QuoteHtml($itemID);
  $headItem = "                <rdf:li rdf:resource=\"$itemID\"/>\n";
  # Add to list of items proper.
  if (($summary ne "") && ($summary ne "*")) {
    $description = &QuoteHtml($summary);
  }
  $host = &QuoteHtml($host);
  if ($userName) {
    $author = &QuoteHtml($userName);
    $authorLink = 'link="' . $QuotedFullUrl . &ScriptLinkChar() . $author . '"';
  } else {
    $author = $host;
  }
  $status = (1 == $revision) ? 'new' : 'updated';
  $importance = $isEdit ? 'minor' : 'major';
  $timestamp += $TimeZoneOffset;
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime($timestamp);
  $year += 1900;
  $date = sprintf("%4d-%02d-%02dT%02d:%02d:%02d+%02d:00",
    $year, $mon+1, $mday, $hour, $min, $sec, $TimeZoneOffset/(60*60));
  $pagename = &QuoteHtml($pagename);
  # Write it out longhand
  $item = <<RSS ;
    <item rdf:about="$itemID">
        <title>$pagename</title>
        <link>$pagePrefix$pagenameEsc</link>
        <description>$description</description>
        <dc:date>$date</dc:date>
        <dc:contributor>
            <rdf:Description wiki:host="$host" $authorLink>
                <rdf:value>$author</rdf:value>
            </rdf:Description>
        </dc:contributor>
        <wiki:status>$status</wiki:status>
        <wiki:importance>$importance</wiki:importance>
        <wiki:diff>$diffPrefix$pagenameEsc</wiki:diff>
        <wiki:version>$revision</wiki:version>
        <wiki:history>$historyPrefix$pagenameEsc</wiki:history>
    </item>
RSS
  return ($headItem, $item);
}

sub DoRss {
  print "Content-type: text/xml\n\n";
  &DoRc(0);
}

sub DoRandom {
  my ($id, @pageList);

  @pageList = &AllPagesList();  # Optimize?
  $id = $pageList[int(rand($#pageList + 1))];
  &ReBrowsePage($id, "", 0);
}

sub DoHistory {
  my ($id) = @_;
  my ($html, $canEdit, $row, $newText);

  print &GetHeader('', Ts('History of %s', $id), '') . '<br>';
  &OpenPage($id);
  &OpenDefaultText();
  $newText = $Text{'text'};
  $canEdit = 0;
  $canEdit = &UserCanEdit($id)  if ($HistoryEdit);
  if ($UseDiff) {
    print <<EOF ;
      <form action="$ScriptName" METHOD="GET">
          <input type="hidden" name="action" value="browse"/>
          <input type="hidden" name="diff" value="1"/>
          <input type="hidden" name="id" value="$id"/>
      <table border="0" width="100%"><tr>
EOF
  }
  $html = &GetHistoryLine($id, $Page{'text_default'}, $canEdit, $row++);
  &OpenKeptRevisions('text_default');
  foreach (reverse sort {$a <=> $b} keys %KeptRevisions) {
    next  if ($_ eq "");  # (needed?)
    $html .= &GetHistoryLine($id, $KeptRevisions{$_}, $canEdit, $row++);
  }
  print $html;
  if ($UseDiff) {
    my $label = T('Compare');
    print "<tr><td align='center'><input type='submit' "
          . "value='$label'/>&nbsp;&nbsp;</td></table></form>\n";
    print "<hr class=wikilinediff>\n";
    print &GetDiffHTML(&GetParam('defaultdiff', 1), $id, '', '', $newText);
  }
  print &GetCommonFooter();
}

sub GetMaskedHost {
  my ($text) = @_;
  my ($logText);

  if (!$MaskHosts) {
    return $text;
  }
  $logText = T('(logged)');
  if (!($text =~ s/\d+$/$logText/)) { # IP address (ending numbers masked)
    $text =~ s/^[^\.\(]+/$logText/;   # Host name: mask until first .
  }
  return $text;
}

sub GetHistoryLine {
  my ($id, $section, $canEdit, $row) = @_;
  my ($html, $expirets, $rev, $summary, $host, $user, $uid, $ts, $minor);
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
  $host = &GetMaskedHost($host);
  $user = $sect{'username'};
  $uid = $sect{'id'};
  $ts = $sect{'ts'};
  $minor = '';
  $minor = '<i>' . T('(edit)') . '</i> '  if ($revtext{'minor'});
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  if ($UseDiff) {
    my ($c1, $c2);
    $c1 = 'checked="checked"' if 1 == $row;
    $c2 = 'checked="checked"' if 0 == $row;
    $html .= "<tr><td align='center'><input type='radio' "
             . "name='diffrevision' value='$rev' $c1/> ";
    $html .= "<input type='radio' name='revision' value='$rev' $c2/></td><td>";
  }
  if (0 == $row) { # current revision
    $html .= &GetPageLinkText($id, Ts('Revision %s', $rev)) . ' ';
    if ($canEdit) {
      $html .= &GetEditLink($id, T('Edit')) . ' ';
    }
  } else {
    $html .= &GetOldPageLink('browse', $id, $rev,
                             Ts('Revision %s', $rev)) . ' ';
    if ($canEdit) {
      $html .= &GetOldPageLink('edit',   $id, $rev, T('Edit')) . ' ';
    }
  }
  $html .= ". . " . $minor . &TimeToText($ts) . " ";
  $html .= T('by') . ' ' . &GetAuthorLink($host, $user, $uid) . " ";
  if (defined($summary) && ($summary ne "") && ($summary ne "*")) {
    $summary = &QuoteHtml($summary);   # Thanks Sunir! :-)
    $html .= "<b>[$summary]</b> ";
  }
  $html .= $UseDiff ? "</tr>\n" : "<br>\n";
  return $html;
}

# ==== HTML and page-oriented functions ====
sub ScriptLinkChar {
  if ($SlashLinks) {
    return '/';
  }
  return '?';
}

sub ScriptLink {
  my ($action, $text) = @_;

  return '<a href="' . $ScriptName . &ScriptLinkChar() . &UriEscape($action)
         . "\">$text</a>";
}

sub ScriptLinkClass {
  my ($action, $text, $class) = @_;

  return '<a href="' . $ScriptName . &ScriptLinkChar() . &UriEscape($action)
         . '" class="' . $class . "\">$text</a>";
}

sub GetPageLinkText {
  my ($id, $name) = @_;

  $id =~ s|^/|$MainPage/|;
  if ($FreeLinks) {
    $id = &FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return &ScriptLinkClass($id, $name, 'wikipagelink');
}

sub GetPageLink {
  my ($id) = @_;

  return &GetPageLinkText($id, $id);
}

sub GetEditLink {
  my ($id, $name) = @_;

  if ($FreeLinks) {
    $id = &FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return &ScriptLinkClass("action=edit&id=$id", $name, 'wikipageedit');
}

sub GetDeleteLink {
  my ($id, $name, $confirm) = @_;

  if ($FreeLinks) {
    $id = &FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return &ScriptLink("action=delete&id=$id&confirm=$confirm", $name);
}

sub GetOldPageParameters {
  my ($kind, $id, $revision) = @_;

  $id = &FreeToNormal($id) if $FreeLinks;
  return "action=$kind&id=$id&revision=$revision";
}

sub GetOldPageLink {
  my ($kind, $id, $revision, $name) = @_;

  $name =~ s/_/ /g if $FreeLinks;
  return &ScriptLink(&GetOldPageParameters($kind, $id, $revision), $name);
}

sub GetPageOrEditAnchoredLink {
  my ($id, $anchor, $name) = @_;
  my (@temp, $exists);

  if ($name eq "") {
    $name = $id;
    if ($FreeLinks) {
      $name =~ s/_/ /g;
    }
  }
  $id =~ s|^/|$MainPage/|;
  if ($FreeLinks) {
    $id = &FreeToNormal($id);
  }
  $exists = 0;
  if ($UseIndex) {
    if (!$IndexInit) {
      @temp = &AllPagesList();          # Also initializes hash
    }
    $exists = 1  if ($IndexHash{$id});
  } elsif (-f &GetPageFile($id)) {      # Page file exists
    $exists = 1;
  }
  if ($exists) {
    $id = "$id#$anchor"  if $anchor;
    $name = "$name#$anchor"  if $anchor && $NamedAnchors != 2;
    return &GetPageLinkText($id, $name);
  }
  if ($FreeLinks && !$EditNameLink) {
    if ($name =~ m| |) {  # Not a single word
      $name = "[$name]";  # Add brackets so boundaries are obvious
    }
  }
  if ($EditNameLink) {
    return &GetEditLink($id, $name);
  } else {
    return $name . &GetEditLink($id, '?');
  }
}

sub GetPageOrEditLink {
    my ($id, $name) = @_;
    return &GetPageOrEditAnchoredLink($id, "", $name);
}

sub GetBackLinksSearchLink {
  my ($id) = @_;
  my $name = $id;

  $id =~ s|.+/|/|;   # Subpage match: search for just /SubName
  if ($FreeLinks) {
    $name =~ s/_/ /g;  # Display with spaces
    $id =~ s/_/+/g;    # Search for url-escaped spaces
  }
  return &ScriptLink("back=$id", $name);
}

sub GetPrefsLink {
  return &ScriptLink("action=editprefs", T('Preferences'));
}

sub GetRandomLink {
  return &ScriptLink("action=random", T('Random Page'));
}

sub ScriptLinkDiff {
  my ($diff, $id, $text, $rev) = @_;

  $rev = "&revision=$rev"  if ($rev ne "");
  $diff = &GetParam("defaultdiff", 1)  if ($diff == 4);
  return &ScriptLink("action=browse&diff=$diff&id=$id$rev", $text);
}

sub ScriptLinkDiffRevision {
  my ($diff, $id, $rev, $text) = @_;

  $rev = "&diffrevision=$rev"  if ($rev ne "");
  $diff = &GetParam("defaultdiff", 1)  if ($diff == 4);
  return &ScriptLink("action=browse&diff=$diff&id=$id$rev", $text);
}

sub GetUploadLink {
  return &ScriptLink('action=upload', T('Upload'));
}

sub ScriptLinkTitle {
  my ($action, $text, $title) = @_;

  if ($FreeLinks) {
    $action =~ s/ /_/g;
  }
  return '<a href="' . $ScriptName . &ScriptLinkChar() . &UriEscape($action)
         . "\" title=\"$title\">$text</a>";
}

sub GetAuthorLink {
  my ($host, $userName, $uid) = @_;
  my ($html, $title, $userNameShow);

  $userNameShow = $userName;
  if ($FreeLinks) {
    $userName     =~ s/ /_/g;
    $userNameShow =~ s/_/ /g;
  }
  if (&ValidId($userName) ne "") {  # Invalid under current rules
    $userName = "";  # Just pretend it isn't there.
  }
  if (($uid > 0) && ($userName ne "")) {
    $html = &ScriptLinkTitle($userName, $userNameShow,
            Ts('ID %s', $uid) . ' ' . Ts('from %s', $host));
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
  return &ScriptLink("action=history&id=$id", $text);
}

sub GetHeader {
  my ($id, $title, $oldId, $backlinks) = @_;
  my $header = "";
  my $logoImage = "";
  my $result = "";
  my $embed = &GetParam('embed', $EmbedWiki);
  my $altText = T('[Home]');

  $result = &GetHttpHeader('');
  if ($FreeLinks) {
    $title =~ s/_/ /g;   # Display as spaces
  }
  $result .= &GetHtmlHeader("$SiteName: $title");
  return $result  if ($embed);

  $result .= '<div class=wikiheader>';
  if ($oldId ne '') {
    $result .= $q->h3('(' . Ts('redirected from %s', 
                               &GetEditLink($oldId, &QuoteHtml($oldId)), 1) . ')');
  }
  if ((!$embed) && ($LogoUrl ne "")) {
    $logoImage = "img src=\"$LogoUrl\" alt=\"$altText\" border=0";
    if (!$LogoLeft) {
      $logoImage .= " align=\"right\"";
    }
    $header = &ScriptLink($HomePage, "<$logoImage>");
  }
  if ($id and $backlinks) {
    $result .= $q->h1($header . &GetBackLinksSearchLink($id));
  } else {
    $result .= $q->h1($header . $title);
  }
  if (&GetParam("toplinkbar", 1)) {
    $result .= &GetGotoBar($id) . "<hr class=wikilineheader>";
  }
  $result .= '</div>';
  return $result;
}

sub GetHttpHeader {
  my ($type) = @_;
  my $cookie;

  $type = 'text/html'  if ($type eq '');
  if (defined($SetCookie{'id'})) {
    $cookie = "$CookieName="
            . "rev&" . $SetCookie{'rev'}
            . "&id&" . $SetCookie{'id'}
            . "&randkey&" . $SetCookie{'randkey'};
    $cookie .= ";expires=Fri, 08-Sep-2013 19:48:23 GMT";
    if ($HttpCharset ne '') {
      return $q->header(-cookie=>$cookie,
                        -type=>"$type; charset=$HttpCharset");
    }
    return $q->header(-cookie=>$cookie);
  }
  if ($HttpCharset ne '') {
    return $q->header(-type=>"$type; charset=$HttpCharset");
  }
  return $q->header(-type=>$type);
}

sub GetHtmlHeader {
  my ($title) = @_;
  my ($dtd, $html, $bodyExtra, $stylesheet);

  $html = '';
  $dtd = '-//IETF//DTD HTML//EN';
  $html = qq(<!DOCTYPE HTML PUBLIC "$dtd">\n);
  $title = $q->escapeHTML($title);
  $html .= "<HTML><HEAD><TITLE>$title</TITLE>\n";
  if ($FavIcon ne '') {
    $html .= '<LINK REL="SHORTCUT ICON" HREF="' . $FavIcon . '">' 
  }
  if ($MetaKeywords) {
      my $keywords = $OpenPageName;
      $keywords =~ s/([a-z])([A-Z])/$1, $2/g;
      $html .= "<META NAME='KEYWORDS' CONTENT='$keywords'/>\n" if $keywords;
  }
  # we don't want robots indexing our history or other admin pages
  my $action = lc(&GetParam('action', ''));
  unless (!$action or $action eq "rc" or $action eq "index") {
    $html .= "<META NAME='robots' CONTENT='noindex,nofollow'>\n";
  }
  if ($SiteBase ne "") {
    $html .= qq(<BASE HREF="$SiteBase">\n);
  }
  $stylesheet = &GetParam('stylesheet', $StyleSheet);
  $stylesheet = $StyleSheet  if ($stylesheet eq '');
  $stylesheet = ''  if ($stylesheet eq '*');  # Allow removing override
  if ($stylesheet ne '') {
    $html .= qq(<LINK REL="stylesheet" HREF="$stylesheet">\n);
  }
  $html .= $UserHeader;
  $bodyExtra = '';
  if ($UserBody ne '') {
    $bodyExtra = ' ' . $UserBody;
  }
  if ($BGColor ne '') {
    $bodyExtra .= qq( BGCOLOR="$BGColor");
  }
  $html .= "</HEAD><BODY$bodyExtra>\n";
  return $html;
}

sub GetFooterText {
  my ($id, $rev) = @_;
  my $result;

  if (&GetParam('embed', $EmbedWiki)) {
    return $q->end_html;
  }
  $result = '<div class=wikifooter>';
  $result .= "<hr class=wikilinefooter>\n";
  $result .= &GetFormStart();
  $result .= &GetGotoBar($id);
  if (&UserCanEdit($id, 0)) {
    if ($rev ne '') {
      $result .= &GetOldPageLink('edit',   $id, $rev,
                                 Ts('Edit revision %s of this page', $rev));
    } else {
      $result .= &GetEditLink($id, T('Edit text of this page'));
    }
  } else {
    $result .= T('This page is read-only');
  }
  $result .= ' | ';
  $result .= &GetHistoryLink($id, T('View other revisions'));
  if ($rev ne '') {
    $result .= ' | ';
    $result .= &GetPageLinkText($id, T('View current revision'));
  }
  if ($UseMetaWiki) {
    $result .= ' | <a href="http://sunir.org/apps/meta.pl?' . &UriEscape($id) . '">'
               . T('Search MetaWiki') . '</a>';
  }
  if ($Section{'revision'} > 0) {
    $result .= '<br>';
    if ($rev eq '') {  # Only for most current rev
      $result .= T('Last edited');
    } else {
      $result .= T('Edited');
    }
    $result .= ' ' . &TimeToText($Section{ts});
    if ($AuthorFooter) {
      $result .= ' ' . Ts('by %s', &GetAuthorLink($Section{'host'},
                                     $Section{'username'}, $Section{'id'}), 1);
    }
  }
  if ($UseDiff) {
    $result .= ' ' . &ScriptLinkDiff(4, $id, T('(diff)'), $rev);
  }
  $result .= '<br>' . &GetSearchForm();
  if ($AdminBar && &UserIsAdmin()) {
    $result .= '<br>' . &GetAdminBar($id);
  }
  if ($DataDir =~ m|/tmp/|) {
    $result .= '<br><b>' . T('Warning') . ':</b> '
               . Ts('Database is stored in temporary directory %s',
                    $DataDir) . '<br>';
  }
  if ($ConfigError ne '') {
    $result .= '<br><b>' . T('Config file error:') . '</b> '
               . $ConfigError . '<br>';
  }
  $result .= $q->endform;
  if ($FooterNote ne '') {
    $result .= T($FooterNote);
  }
  $result .= '</div>';
  $result .= &GetMinimumFooter();
  return $result;
}

sub GetCommonFooter {
  my ($html);

  $html = '<div class=wikifooter>' . '<hr class=wikilinefooter>'
          . &GetFormStart() . &GetGotoBar('')
          . &GetSearchForm() . $q->endform;
  if ($FooterNote ne '') {
    $html .= T($FooterNote);
  }
  $html .= '</div>' . $q->end_html;
  return $html;
}

sub GetMinimumFooter {
  return $q->end_html;
}

sub GetFormStart {
  return $q->startform("POST", "$ScriptName",
                       "application/x-www-form-urlencoded");
}

sub GetGotoBar {
  my ($id) = @_;
  my ($main, $bartext);

  $bartext  = &GetPageLink($HomePage);
  if ($id =~ m|/|) {
    $main = $id;
    $main =~ s|/.*||;  # Only the main page name (remove subpage)
    $bartext .= " | " . &GetPageLink($main);
  }
  $bartext .= " | " . &GetPageLink($RCName);
  $bartext .= " | " . &GetPrefsLink();
  if ($UseUpload && &UserCanUpload()) {
    $bartext .= " | " . &GetUploadLink();
  }
  if (&GetParam("linkrandom", 0)) {
    $bartext .= " | " . &GetRandomLink();
  }
  if ($UserGotoBar ne '') {
    $bartext .= " | " . $UserGotoBar;
  }
  $bartext .= "<br>\n";
  return $bartext;
}

# Admin bar contributed by ElMoro (with some changes)
sub GetPageLockLink {
  my ($id, $status, $name) = @_;

  if ($FreeLinks) {
    $id = &FreeToNormal($id);
  }
  return &ScriptLink("action=pagelock&set=$status&id=$id", $name);
}

sub GetAdminBar {
  my ($id) = @_;
  my ($result);

  $result = T('Administration') . ': ';
  if (-f &GetLockedPageFile($id))   { 
    $result .= &GetPageLockLink($id, 0, T('Unlock page'));
  }
  else  {
    $result .= &GetPageLockLink($id, 1, T('Lock page'));
  }
  $result .= " | " . &GetDeleteLink($id, T('Delete this page'), 0);
  $result .= " | " . &ScriptLink("action=editbanned", T("Edit Banned List"));
  $result .= " | " . &ScriptLink("action=maintain", T("Run Maintenance"));
  $result .= " | " . &ScriptLink("action=editlinks", T("Edit/Rename pages")); 
  if (-f "$DataDir/noedit") {
    $result .= " | " . &ScriptLink("action=editlock&set=0", T("Unlock site")); 
  } else {
    $result .= " | " . &ScriptLink("action=editlock&set=1", T("Lock site"));
  }
  return $result;
}

sub GetSearchForm {
  my ($result);

  $result = T('Search:') . ' ' . $q->textfield(-name=>'search', -size=>20);
  if ($SearchButton) {
    $result .= $q->submit('dosearch', T('Go!'));
  } else {  
    $result .= &GetHiddenValue("dosearch", 1);
  }
  return $result;
}

sub GetRedirectPage {
  my ($newid, $name, $isEdit) = @_;
  my ($url, $html);
  my ($nameLink);

  # Normally get URL from script, but allow override.
  $FullUrl = $q->url(-full=>1)  if ($FullUrl eq "");
  $url = $FullUrl . &ScriptLinkChar() . &UriEscape($newid);
  $nameLink = "<a href=\"$url\">$name</a>";
  if ($RedirType < 3) {
    if ($RedirType == 1) {             # Use CGI.pm
      # NOTE: do NOT use -method (does not work with old CGI.pm versions)
      # Thanks to Daniel Neri for fixing this problem.
      $html = $q->redirect(-uri=>$url);
    } else {                           # Minimal header
      $html  = "Status: 302 Moved\n";
      $html .= "Location: $url\n";
      $html .= "Content-Type: text/html\n";  # Needed for browser failure
      $html .= "\n";
    }
    $html .= "\n" . Ts('Your browser should go to the %s page.', $newid);
    $html .= ' ' . Ts('If it does not, click %s to continue.', $nameLink);
  } else {
    if ($isEdit) {
      $html  = &GetHeader('', T('Thanks for editing...'), '');
      $html .= Ts('Thank you for editing %s.', $nameLink);
    } else {
      $html  = &GetHeader('', T('Link to another page...'), '');
    }
    $html .= "\n<p>";
    $html .= Ts('Follow the %s link to continue.', $nameLink);
    $html .= &GetMinimumFooter();
  }
  return $html;
}

# ==== Common wiki markup ====
sub RestoreSavedText {
  my ($text) = @_;

  1 while $text =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
  return $text;
}

sub RemoveFS {
  my ($text) = @_;

  # Note: must remove all $FS, and $FS may be multi-byte/char separator
  $text =~ s/($FS)+(\d)/$2/g;
  return $text;
}

sub WikiToHTML {
  my ($pageText) = @_;
  $TableMode = 0;

  %SaveUrl = ();
  %SaveNumUrl = ();
  $SaveUrlIndex = 0;
  $SaveNumUrlIndex = 0;
  $pageText = &RemoveFS($pageText);
  if ($RawHtml) {
    $pageText =~ s/<html>((.|\n)*?)<\/html>/&StoreRaw($1)/ige;
  }
  $pageText = &QuoteHtml($pageText);
  $pageText =~ s/\\ *\r?\n/ /g;          # Join lines with backslash at end
  if ($ParseParas) {
    # Note: The following 3 rules may span paragraphs, so they are
    #       copied from CommonMarkup
    $pageText =~
        s/\&lt;nowiki\&gt;((.|\n)*?)\&lt;\/nowiki\&gt;/&StoreRaw($1)/ige;
    $pageText =~
        s/\&lt;pre\&gt;((.|\n)*?)\&lt;\/pre\&gt;/&StorePre($1, "pre")/ige;
    $pageText =~
        s/\&lt;code\&gt;((.|\n)*?)\&lt;\/code\&gt;/&StorePre($1, "code")/ige;
    $pageText =~ s/((.|\n)+?\n)\s*(\n|$)/&ParseParagraph($1)/geo;
    $pageText =~ s/(.*)<\/p>(.+)$/$1.&ParseParagraph($2)/seo;
  } else {
    $pageText = &CommonMarkup($pageText, 1, 0);   # Multi-line markup
    $pageText = &WikiLinesToHtml($pageText);      # Line-oriented markup
  }
  while (@HeadingNumbers) {
    pop @HeadingNumbers;
    $TableOfContents .= "</dd></dl>\n\n";
  }
  $pageText =~ s/&lt;toc&gt;/$TableOfContents/gi;
  if ($LateRules ne '') {
    $pageText = &EvalLocalRules($LateRules, $pageText, 0);
  }
  return &RestoreSavedText($pageText);
}

sub CommonMarkup {
  my ($text, $useImage, $doLines) = @_;
  local $_ = $text;

  if ($doLines < 2) { # 2 = do line-oriented only
    # The <nowiki> tag stores text with no markup (except quoting HTML)
    s/\&lt;nowiki\&gt;((.|\n)*?)\&lt;\/nowiki\&gt;/&StoreRaw($1)/ige;
    # The <pre> tag wraps the stored text with the HTML <pre> tag
    s/\&lt;pre\&gt;((.|\n)*?)\&lt;\/pre\&gt;/&StorePre($1, "pre")/ige;
    s/\&lt;code\&gt;((.|\n)*?)\&lt;\/code\&gt;/&StorePre($1, "code")/ige;
    if ($EarlyRules ne '') {
      $_ = &EvalLocalRules($EarlyRules, $_, !$useImage);
    }
    s/\[\#(\w+)\]/&StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
    if ($HtmlTags) {
      my ($t);
      foreach $t (@HtmlPairs) {
        s/\&lt;$t(\s[^<>]+?)?\&gt;(.*?)\&lt;\/$t\&gt;/<$t$1>$2<\/$t>/gis;
      }
      foreach $t (@HtmlSingle) {
        s/\&lt;$t(\s[^<>]+?)?\&gt;/<$t$1>/gi;
      }
    } else {
      # Note that these tags are restricted to a single line
      s/\&lt;b\&gt;(.*?)\&lt;\/b\&gt;/<b>$1<\/b>/gi;
      s/\&lt;i\&gt;(.*?)\&lt;\/i\&gt;/<i>$1<\/i>/gi;
      s/\&lt;strong\&gt;(.*?)\&lt;\/strong\&gt;/<strong>$1<\/strong>/gi;
      s/\&lt;em\&gt;(.*?)\&lt;\/em\&gt;/<em>$1<\/em>/gi;
    }
    s/\&lt;tt\&gt;(.*?)\&lt;\/tt\&gt;/<tt>$1<\/tt>/gis;  # <tt> (MeatBall)
    s/\&lt;br\&gt;/<br>/gi;  # Allow simple line break anywhere
    if ($HtmlLinks) {
      s/\&lt;A(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/&StoreHref($1, $2)/gise;
    }
    if ($FreeLinks) {
      # Consider: should local free-link descriptions be conditional?
      # Also, consider that one could write [[Bad Page|Good Page]]?
      s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/&StorePageOrEditLink($1, $2)/geo;
      s/\[\[$FreeLinkPattern\]\]/&StorePageOrEditLink($1, "")/geo;
    }
    if ($BracketText) {  # Links like [URL text of link]
      s/\[$UrlPattern\s+([^\]]+?)\]/&StoreBracketUrl($1, $2, $useImage)/geos;
      s/\[$InterLinkPattern\s+([^\]]+?)\]/&StoreBracketInterPage($1, $2,
                                                             $useImage)/geos;
      if ($WikiLinks && $BracketWiki) {  # Local bracket-links
        s/\[$LinkPattern\s+([^\]]+?)\]/&StoreBracketLink($1, $2)/geos;
        s/\[$AnchoredLinkPattern\s+([^\]]+?)\]/&StoreBracketAnchoredLink($1,
                                               $2, $3)/geos if $NamedAnchors;
      }
    }
    s/\[$UrlPattern\]/&StoreBracketUrl($1, "", 0)/geo;
    s/\[$InterLinkPattern\]/&StoreBracketInterPage($1, "", 0)/geo;
    s/\b$UrlPattern/&StoreUrl($1, $useImage)/geo;
    s/\b$InterLinkPattern/&StoreInterPage($1, $useImage)/geo;
    if ($UseUpload) {
      s/$UploadPattern/&StoreUpload($1)/geo;
    }
    if ($WikiLinks) {
      s/$AnchoredLinkPattern/&StoreRaw(&GetPageOrEditAnchoredLink($1,
                             $2, ""))/geo if $NamedAnchors;
      # CAA: Putting \b in front of $LinkPattern breaks /SubPage links
      #      (subpage links without the main page)
      s/$LinkPattern/&GetPageOrEditLink($1, "")/geo;
    }
    s/\b$RFCPattern/&StoreRFC($1)/geo;
    s/\b$ISBNPattern/&StoreISBN($1)/geo;
    if ($ThinLine) {
      if ($OldThinLine) {  # Backwards compatible, conflicts with headers
        s/====+/<hr noshade class=wikiline size=2>/g;
      } else {             # New behavior--no conflict
        s/------+/<hr noshade class=wikiline size=2>/g;
      }
      s/----+/<hr noshade class=wikiline size=1>/g;
    } else {
      s/----+/<hr class=wikiline>/g;
    }
  }
  if ($doLines) { # 0 = no line-oriented, 1 or 2 = do line-oriented
    # The quote markup patterns avoid overlapping tags (with 5 quotes)
    # by matching the inner quotes for the strong pattern.
    s/('*)'''(.*?)'''/$1<strong>$2<\/strong>/g;
    s/''(.*?)''/<em>$1<\/em>/g;
    if ($UseHeadings) {
      s/(^|\n)\s*(\=+)\s+([^\n]+)\s+\=+/&WikiHeading($1, $2, $3)/geo;
    }
    if ($TableMode) {
      s/((\|\|)+)/"<\/TD><TD COLSPAN=\"" . (length($1)\/2) . "\">"/ge;
    }
  }
  return $_;
}

sub EmptyCellsToNbsp {
  my ($row) = @_;

  $row =~ s/(?<=\|\|)\s+(?=\|\|)/&nbsp;/g;
  $row =~ s/^\s+(?=\|\|)/&nbsp;/;
  $row =~ s/(?<=\|\|)\s+$/&nbsp;/;
  return $row;
}

sub WikiLinesToHtml {
  my ($pageText) = @_;
  my ($pageHtml, @htmlStack, $code, $codeAttributes, $depth, $oldCode);

  @htmlStack = ();
  $depth = 0;
  $pageHtml = "";
  foreach (split(/\n/, $pageText)) {  # Process lines one-at-a-time
    $code = '';
    $codeAttributes = '';
    $TableMode = 0;
    $_ .= "\n";
    if (s/^(\;+)([^:]+\:?)\:/<dt>$2<dd>/) {
      $code = "DL";
      $depth = length $1;
    } elsif (s/^(\:+)/<dt><dd>/) {
      $code = "DL";
      $depth = length $1;
    } elsif (s/^(\*+)/<li>/) {
      $code = "UL";
      $depth = length $1;
    } elsif (s/^(\#+)/<li>/) {
      $code = "OL";
      $depth = length $1;
    } elsif ($TableSyntax &&
             s/^((\|\|)+)(.*)\|\|\s*$/"<TR VALIGN='CENTER' "
                                      . "ALIGN='CENTER'><TD colspan='"
                               . (length($1)\/2) . "'>" . EmptyCellsToNbsp($3) . "<\/TD><\/TR>\n"/e) {
      $code = 'TABLE';
      $codeAttributes = "BORDER='1'";
      $TableMode = 1;
      $depth = 1;
    } elsif (/^[ \t].*\S/) {
      $code = "PRE";
      $depth = 1;
    } else {
      $depth = 0;
    }
    while (@htmlStack > $depth) {   # Close tags as needed
      $pageHtml .=  "</" . pop(@htmlStack) . ">\n";
    }
    if ($depth > 0) {
      $depth = $IndentLimit  if ($depth > $IndentLimit);
      if (@htmlStack) {  # Non-empty stack
        $oldCode = pop(@htmlStack);
        if ($oldCode ne $code) {
          $pageHtml .= "</$oldCode><$code>\n";
        }
        push(@htmlStack, $code);
      }
      while (@htmlStack < $depth) {
        push(@htmlStack, $code);
        $pageHtml .= "<$code $codeAttributes>\n";
      }
    }
    if (!$ParseParas) {
      s/^\s*$/<p>\n/;                      # Blank lines become <p> tags
    }
    $pageHtml .= &CommonMarkup($_, 1, 2);  # Line-oriented common markup
  }
  while (@htmlStack > 0) {       # Clear stack
    $pageHtml .=  "</" . pop(@htmlStack) . ">\n";
  }
  return $pageHtml;
}

sub EvalLocalRules {
  my ($rules, $origText, $isDiff) = @_;
  my ($text, $reportError, $errorText);

  $text = $origText;
  $reportError = 1;
  # Basic idea: the $rules should change $text, possibly with different
  # behavior if $isDiff is true (no images or color changes?)
  # Note: for fun, the $rules could also change $reportError and $origText
  if (!eval $rules) {
    $errorText = $@;
    if ($errorText eq '') {
      # Search for "Unknown Error" for the reason the next line is commented
#     $errorText = T('Unknown Error (no error text)');
    }
    if ($errorText ne '') {
      $text = $origText;    # Consider: should partial results be kept?
      if ($reportError) {
        $text .= '<hr><b>' . T('Local rule error:') . '</b><br>'
                 . &QuoteHtml($errorText);
      }
    }
  }
  return $text;
}
 
sub UriEscape {
  my ($uri) = @_;
  $uri =~ s/([\x00-\x1f\x7f-\xff])/sprintf("%%%02X", ord($1))/ge;
  $uri =~ s/\&/\&amp;/g;
  return $uri;
}

sub ParseParagraph {
  my ($text) = @_;

  $text = &CommonMarkup($text, 1, 0);   # Multi-line markup
  $text = &WikiLinesToHtml($text);      # Line-oriented markup
  return "<p>$text</p>\n";
}

sub StoreInterPage {
  my ($id, $useImage) = @_;
  my ($link, $extra);

  ($link, $extra) = &InterPageLink($id, $useImage);
  # Next line ensures no empty links are stored
  $link = &StoreRaw($link)  if ($link ne "");
  return $link . $extra;
}

sub InterPageLink {
  my ($id, $useImage) = @_;
  my ($name, $site, $remotePage, $url, $punct);

  ($id, $punct) = &SplitUrlPunct($id);
  $name = $id;
  ($site, $remotePage) = split(/:/, $id, 2);
  $url = &GetSiteUrl($site);
  return ("", $id . $punct)  if ($url eq "");
  $remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
  $url .= $remotePage;
  return (&UrlLinkOrImage($url, $name, $useImage), $punct);
}

sub StoreBracketInterPage {
  my ($id, $text, $useImage) = @_;
  my ($site, $remotePage, $url, $index);

  ($site, $remotePage) = split(/:/, $id, 2);
  $remotePage =~ s/&amp;/&/g;  # Unquote common URL HTML
  $url = &GetSiteUrl($site);
  if ($text ne "") {
    return "[$id $text]"  if ($url eq "");
  } else {
    return "[$id]"  if ($url eq "");
    $text = &GetBracketUrlIndex($id);
  }
  $url .= $remotePage;
  if ($BracketImg && $useImage && &ImageAllowed($text)) {
    $text = "<img src=\"$text\">";
  } else {
    $text = "[$text]";
  }
  return &StoreRaw("<a href=\"$url\">$text</a>");
}

sub GetBracketUrlIndex {
  my ($id) = @_;
  my ($index, $key);

  # Consider plain array?
  if ($SaveNumUrl{$id} > 0) {
    return $SaveNumUrl{$id};
  }
  $SaveNumUrlIndex++;  # Start with 1
  $SaveNumUrl{$id} = $SaveNumUrlIndex;
  return $SaveNumUrlIndex;
}

sub GetSiteUrl {
  my ($site) = @_;
  my ($data, $status);

  if (!$InterSiteInit) {
    ($status, $data) = &ReadFile($InterFile);
    if ($status) {
      %InterSite = split(/\s+/, $data);  # Consider defensive code
    }
    # Check for definitions to allow file to override automatic settings
    if (!defined($InterSite{'LocalWiki'})) {
      $InterSite{'LocalWiki'} = $ScriptName . &ScriptLinkChar();
    }
    if (!defined($InterSite{'Local'})) {
      $InterSite{'Local'} = $ScriptName . &ScriptLinkChar();
    }
    $InterSiteInit = 1;  # Init only once per request
  }
  return $InterSite{$site}  if (defined($InterSite{$site}));
  return '';
}

sub StoreRaw {
  my ($html) = @_;

  $SaveUrl{$SaveUrlIndex} = $html;
  return $FS . $SaveUrlIndex++ . $FS;
}

sub StorePre {
  my ($html, $tag) = @_;

  return &StoreRaw("<$tag>" . $html . "</$tag>");
}

sub StoreHref {
  my ($anchor, $text) = @_;

  return "<a" . &StoreRaw($anchor) . ">$text</a>";
}

sub StoreUrl {
  my ($name, $useImage) = @_;
  my ($link, $extra);

  ($link, $extra) = &UrlLink($name, $useImage);
  # Next line ensures no empty links are stored
  $link = &StoreRaw($link)  if ($link ne "");
  return $link . $extra;
}

sub UrlLink {
  my ($rawname, $useImage) = @_;
  my ($name, $punct);

  ($name, $punct) = &SplitUrlPunct($rawname);
  if ($LimitFileUrl && ($NetworkFile && $name =~ m|^file:|)) {
    # Only do remote file:// links. No file:///c|/windows.
    if ($name =~ m|^file://[^/]|) {
      return ("<a href=\"$name\">$name</a>", $punct);
    }
    return ($rawname, '');
  }
  return (&UrlLinkOrImage($name, $name, $useImage), $punct);
}

sub UrlLinkOrImage {
  my ($url, $name, $useImage) = @_;

  # Restricted image URLs so that mailto:foo@bar.gif is not an image
  if ($useImage && &ImageAllowed($url)) {
    return "<img src=\"$url\">";
  }
  return "<a href=\"$url\">$name</a>";
}

sub ImageAllowed {
  my ($url) = @_;
  my ($site, $imagePrefixes);

  $imagePrefixes = 'http:|https:|ftp:';
  $imagePrefixes .= '|file:'  if (!$LimitFileUrl);
  return 0  unless ($url =~ /^($imagePrefixes).+\.$ImageExtensions$/i);
  return 0  if ($url =~ /"/);      # No HTML-breaking quotes allowed
  return 1  if (@ImageSites < 1);  # Most common case: () means all allowed
  return 0  if ($ImageSites[0] eq 'none');  # Special case: none allowed
  foreach $site (@ImageSites) {
    return 1  if ($site eq substr($url, 0, length($site)));  # Match prefix
  }
  return 0;
}

sub StoreBracketUrl {
  my ($url, $text, $useImage) = @_;

  if ($text eq "") {
    $text = &GetBracketUrlIndex($url);
  } elsif ($text =~ /^$InterLinkPattern$/) {
    my @interlink = split(/:/, $text, 2);
    $text = &GetSiteUrl($interlink[0]) . $interlink[1];
  }
  if ($BracketImg && $useImage && &ImageAllowed($text)) {
    $text = "<img src=\"$text\">";
  } else {
    $text = "[$text]";
  }
  return &StoreRaw("<a href=\"$url\">$text</a>");
}

sub StoreBracketLink {
  my ($name, $text) = @_;

  return &StoreRaw(&GetPageLinkText($name, "[$text]"));
}

sub StoreBracketAnchoredLink {
  my ($name, $anchor, $text) = @_;

  return &StoreRaw(&GetPageLinkText("$name#$anchor", "[$text]"));
}

sub StorePageOrEditLink {
  my ($page, $name) = @_;

  if ($FreeLinks) {
    $page =~ s/^\s+//;      # Trim extra spaces
    $page =~ s/\s+$//;
    $page =~ s|\s*/\s*|/|;  # ...also before/after subpages
  }
  $name =~ s/^\s+//;
  $name =~ s/\s+$//;
  return &StoreRaw(&GetPageOrEditLink($page, $name));
}

sub StoreRFC {
  my ($num) = @_;

  return &StoreRaw(&RFCLink($num));
}

sub RFCLink {
  my ($num) = @_;

  return "<a href=\"http://www.faqs.org/rfcs/rfc${num}.html\">RFC $num</a>";
}

sub StoreUpload {
  my ($url) = @_;

  return &StoreRaw(&UploadLink($url));
}

sub UploadLink {
  my ($filename) = @_;
  my ($html, $url);
 
  return $filename  if ($UploadUrl eq '');  # No bad links if misconfigured
  $UploadUrl .= '/'  if (substr($UploadUrl, -1, 1) ne '/');  # End with /
  $url = $UploadUrl . $filename;
  $html = '<a href="' . $url . '">';
  if (&ImageAllowed($url)) {
    $html .= '<img src="' . $url . '" alt="upload:' . $filename . '">';
  } else {
    $html .= 'upload:' . $filename;
  }
  $html .= '</a>';
  return $html;
}

sub StoreISBN {
  my ($num) = @_;

  return &StoreRaw(&ISBNLink($num));
}

sub ISBNALink {
  my ($num, $pre, $post, $text) = @_;

  return '<a href="' . $pre . $num . $post . '">' . $text . '</a>';
}

sub ISBNLink {
  my ($rawnum) = @_;
  my ($rawprint, $html, $num, $numSites, $i);

  $num = $rawnum;
  $rawprint = $rawnum;
  $rawprint =~ s/ +$//;
  $num =~ s/[- ]//g;
  $numSites = scalar @IsbnNames;  # Number of entries
  if ((length($num) != 10) || ($numSites < 1)) {
    return "ISBN $rawnum";
  }
  $html = &ISBNALink($num, $IsbnPre[0], $IsbnPost[0], 'ISBN ' . $rawprint);
  if ($numSites > 1) {
    $html .= ' (';
    $i = 1;
    while ($i < $numSites) {
      $html .= &ISBNALink($num, $IsbnPre[$i], $IsbnPost[$i], $IsbnNames[$i]);
      if ($i < ($numSites - 1)) {  # Not the last site
        $html .= ', ';
      }
      $i++;
    }
    $html .= ')';
  }
  $html .= " "  if ($rawnum =~ / $/);  # Add space if old ISBN had space.
  return $html;
}

sub SplitUrlPunct {
  my ($url) = @_;
  my ($punct);

  if ($url =~ s/\"\"$//) {
    return ($url, "");   # Delete double-quote delimiters here
  }
  $punct = "";
  if ($NewFS) {
    ($punct) = ($url =~ /([^a-zA-Z0-9\/\x80-\xff]+)$/);
    $url =~ s/([^a-zA-Z0-9\/\x80-\xff]+)$//;
  } else {
    ($punct) = ($url =~ /([^a-zA-Z0-9\/\xc0-\xff]+)$/);
    $url =~ s/([^a-zA-Z0-9\/\xc0-\xff]+)$//;
  }
  return ($url, $punct);
}

sub StripUrlPunct {
  my ($url) = @_;
  my ($junk);

  ($url, $junk) = &SplitUrlPunct($url);
  return $url;
}

sub WikiHeadingNumber {
    my ($depth, $text) = @_;
    my ($anchor, $number);

    return '' unless --$depth > 0;  # Don't number H1s because it looks stupid
    while (scalar @HeadingNumbers < ($depth-1)) {
        push @HeadingNumbers, 1;
        $TableOfContents .= '<dl><dt> </dt><dd>';
    }
    if (scalar @HeadingNumbers < $depth) {
        push @HeadingNumbers, 0;
        $TableOfContents .= '<dl><dt> </dt><dd>';
    }
    while (scalar @HeadingNumbers > $depth) {
        pop @HeadingNumbers;
        $TableOfContents .= "</dd></dl>\n\n";
    }
    $HeadingNumbers[$#HeadingNumbers]++;
    $number = (join '.', @HeadingNumbers) . '. ';
    # Remove embedded links. THIS IS FRAGILE!
    $text = &RestoreSavedText($text);
    $text =~ s/\<a\s[^\>]*?\>\?\<\/a\>//si; # No such page syntax
    $text =~ s/\<a\s[^\>]*?\>(.*?)\<\/a\>/$1/si;
    # Cook anchor by canonicalizing $text.
    $anchor = $text;
    $anchor =~ s/\<.*?\>//g; 
    $anchor =~ s/\W/_/g;   
    $anchor =~ s/__+/_/g;
    $anchor =~ s/^_//;
    $anchor =~ s/_$//;
    # Last ditch effort
    $anchor = '_' . (join '_', @HeadingNumbers) unless $anchor;
    $TableOfContents .= $number . &ScriptLink("$OpenPageName#$anchor",$text)
                        . "</dd>\n<dt> </dt><dd>";
    return &StoreHref(" name=\"$anchor\"") . $number;
}

sub WikiHeading {
  my ($pre, $depth, $text) = @_;

  $depth = length($depth);
  $depth = 6  if ($depth > 6);
  $text =~ s/^\s*#\s+/&WikiHeadingNumber($depth,$')/e; # $' == $POSTMATCH
  return $pre . "<H$depth>$text</H$depth>\n";
}

# ==== Difference markup and HTML ====
sub GetDiffHTML {
  my ($diffType, $id, $revOld, $revNew, $newText) = @_;
  my ($html, $diffText, $diffTextTwo, $priorName, $links, $usecomma);
  my ($major, $minor, $author, $useMajor, $useMinor, $useAuthor, $cacheName);

  $links = "(";
  $usecomma = 0;
  $major  = &ScriptLinkDiff(1, $id, T('major diff'), "");
  $minor  = &ScriptLinkDiff(2, $id, T('minor diff'), "");
  $author = &ScriptLinkDiff(3, $id, T('author diff'), "");
  $useMajor  = 1;
  $useMinor  = 1;
  $useAuthor = 1;
  $diffType = &GetParam("defaultdiff", 1)  if ($diffType == 4);
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
  if ($revOld ne "") {
    # Note: OpenKeptRevisions must have been done by caller.
    # Eventually optimize if same as cached revision
    $diffText = &GetKeptDiff($newText, $revOld, 1);  # 1 = get lock
    if ($diffText eq "") {
      $diffText = T('(The revisions are identical or unavailable.)');
    }
  } else {
    $diffText  = &GetCacheDiff($cacheName);
  }
  $useMajor  = 0  if ($useMajor  && ($diffText eq &GetCacheDiff("major")));
  $useMinor  = 0  if ($useMinor  && ($diffText eq &GetCacheDiff("minor")));
  $useAuthor = 0  if ($useAuthor && ($diffText eq &GetCacheDiff("author")));
  $useMajor  = 0  if ((!defined(&GetPageCache('oldmajor'))) ||
                      (&GetPageCache("oldmajor") < 1));
  $useAuthor = 0  if ((!defined(&GetPageCache('oldauthor'))) ||
                      (&GetPageCache("oldauthor") < 1));
  if ($useMajor) {
    $links .= $major;
    $usecomma = 1;
  }
  if ($useMinor) {
    $links .= ", "  if ($usecomma);
    $links .= $minor;
    $usecomma = 1;
  }
  if ($useAuthor) {
    $links .= ", "  if ($usecomma);
    $links .= $author;
  }
  if (!($useMajor || $useMinor || $useAuthor)) {
    $links .= T('no other diffs');
  }
  $links .= ")";
  if ((!defined($diffText)) || ($diffText eq "")) {
    $diffText = T('No diff available.');
  }
  if ($revOld ne "") {
    my $currentRevision = T('current revision');
    $currentRevision = Ts('revision %s', $revNew) if $revNew;
    $html = '<b>'
      . Tss("Difference (from revision %1 to %2)", $revOld, $currentRevision)
      . "</b>\n" . "$links<br>" . &DiffToHTML($diffText);
  } else {
    if (($diffType != 2) &&
        ((!defined(&GetPageCache("old$cacheName"))) ||
         (&GetPageCache("old$cacheName") < 1))) {
      $html = '<b>'
              . Ts('No diff available--this is the first %s revision.',
                   $priorName) . "</b>\n$links";
    } else {
      $html = '<b>'
              . Ts('Difference (from prior %s revision)', $priorName)
              . "</b>\n$links<br>" . &DiffToHTML($diffText);
    }
  }
  @HeadingNumbers = ();
  $TableOfContents = '';
  return $html;
}

sub GetCacheDiff {
  my ($type) = @_;
  my ($diffText);

  $diffText = &GetPageCache("diff_default_$type");
  $diffText = &GetCacheDiff('minor')  if ($diffText eq "1");
  $diffText = &GetCacheDiff('major')  if ($diffText eq "2");
  return $diffText;
}

# Must be done after minor diff is set and OpenKeptRevisions called
sub GetKeptDiff {
  my ($newText, $oldRevision, $lock) = @_;
  my (%sect, %data, $oldText);

  $oldText = "";
  if (defined($KeptRevisions{$oldRevision})) {
    %sect = split(/$FS2/, $KeptRevisions{$oldRevision}, -1);
    %data = split(/$FS3/, $sect{'data'}, -1);
    $oldText = $data{'text'};
  }
  return ""  if ($oldText eq "");  # Old revision not found
  return &GetDiff($oldText, $newText, $lock);
}

sub GetDiff {
  my ($old, $new, $lock) = @_;
  my ($diff_out, $oldName, $newName);

  &CreateDir($TempDir);
  $oldName = "$TempDir/old_diff";
  $newName = "$TempDir/new_diff";
  if ($lock) {
    &RequestDiffLock() or return "";
    $oldName .= "_locked";
    $newName .= "_locked";
  }
  &WriteStringToFile($oldName, $old);
  &WriteStringToFile($newName, $new);
  $diff_out = `diff $oldName $newName`;
  &ReleaseDiffLock()  if ($lock);
  $diff_out =~ s/\\ No newline.*\n//g;   # Get rid of common complaint.
  # No need to unlink temp files--next diff will just overwrite.
  return $diff_out;
}

sub DiffToHTML {
  my ($html) = @_;
  my ($tChanged, $tRemoved, $tAdded);

  $tChanged = T('Changed:');
  $tRemoved = T('Removed:');
  $tAdded   = T('Added:');
  $html =~ s/\n--+//g;
  # Note: Need spaces before <br> to be different from diff section.
  $html =~ s/(^|\n)(\d+.*c.*)/$1 <br><strong>$tChanged $2<\/strong><br>/g;
  $html =~ s/(^|\n)(\d+.*d.*)/$1 <br><strong>$tRemoved $2<\/strong><br>/g;
  $html =~ s/(^|\n)(\d+.*a.*)/$1 <br><strong>$tAdded $2<\/strong><br>/g;
  $html =~ s/\n((<.*\n)+)/&ColorDiff($1, $DiffColor1, 0)/ge;
  $html =~ s/\n((>.*\n)+)/&ColorDiff($1, $DiffColor2, 1)/ge;
  return $html;
}

sub ColorDiff {
  my ($diff, $color, $type) = @_;
  my ($colorHtml, $classHtml);

  $diff =~ s/(^|\n)[<>]/$1/g;
  $diff = &QuoteHtml($diff);
  # Do some of the Wiki markup rules:
  %SaveUrl = ();
  %SaveNumUrl = ();
  $SaveUrlIndex = 0;
  $SaveNumUrlIndex = 0;
  $diff = &RemoveFS($diff);
  $diff = &CommonMarkup($diff, 0, 1);      # No images, all patterns
  if ($LateRules ne '') {
    $diff = &EvalLocalRules($LateRules, $diff, 1);
  }
  1 while $diff =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
  $diff =~ s/\r?\n/<br>/g;
  $colorHtml = '';
  if ($color ne '') {
    $colorHtml = " bgcolor=$color";
  }
  if ($type) {
    $classHtml = ' class=wikidiffnew';
  } else {
    $classHtml = ' class=wikidiffold';
  }
  return "<table width=\"95\%\"$colorHtml$classHtml><tr><td>\n" . $diff
         . "</td></tr></table>\n";
}

# ==== Database (Page, Section, Text, Kept, User) functions ====
sub OpenNewPage {
  my ($id) = @_;

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
  $Section{'id'} = $UserID;
  $Section{'username'} = &GetParam("username", "");
  $Section{'data'} = $data;
  $Page{$name} = join($FS2, %Section);  # Replace with save?
}

sub OpenNewText {
  my ($name) = @_;  # Name of text (usually "default")
  %Text = ();
  if ($NewText ne '') {
    $Text{'text'} = T($NewText);
  } else {
    $Text{'text'} = T('Describe the new page here.') . "\n";
  }
  $Text{'text'} .= "\n"  if (substr($Text{'text'}, -1, 1) ne "\n");
  $Text{'minor'} = 0;      # Default as major edit
  $Text{'newauthor'} = 1;  # Default as new author
  $Text{'summary'} = '';
  &OpenNewSection("text_$name", join($FS3, %Text));
}

sub GetPageFile {
  my ($id) = @_;

  return $PageDir . "/" . &GetPageDirectory($id) . "/$id.db";
}

sub OpenPage {
  my ($id) = @_;
  my ($fname, $data);

  if ($OpenPageName eq $id) {
    return;
  }
  %Section = ();
  %Text = ();
  $fname = &GetPageFile($id);
  if (-f $fname) {
    $data = &ReadFileOrDie($fname);
    %Page = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  } else {
    &OpenNewPage($id);
  }
  if ($Page{'version'} != 3) {
    &UpdatePageVersion();
  }
  $OpenPageName = $id;
}

sub OpenSection {
  my ($name) = @_;

  if (!defined($Page{$name})) {
    &OpenNewSection($name, "");
  } else {
    %Section = split(/$FS2/, $Page{$name}, -1);
  }
}

sub OpenText {
  my ($name) = @_;

  if (!defined($Page{"text_$name"})) {
    &OpenNewText($name);
  } else {
    &OpenSection("text_$name");
    %Text = split(/$FS3/, $Section{'data'}, -1);
  }
}

sub OpenDefaultText {
  &OpenText('default');
}

# Called after OpenKeptRevisions
sub OpenKeptRevision {
  my ($revision) = @_;

  %Section = split(/$FS2/, $KeptRevisions{$revision}, -1);
  %Text = split(/$FS3/, $Section{'data'}, -1);
}

sub GetPageCache {
  my ($name) = @_;

  return $Page{"cache_$name"};
}

# Always call SavePage within a lock.
sub SavePage {
  my $file = &GetPageFile($OpenPageName);

  $Page{'revision'} += 1;    # Number of edited times
  $Page{'ts'} = $Now;        # Updated every edit
  &CreatePageDir($PageDir, $OpenPageName);
  &WriteStringToFile($file, join($FS1, %Page));
}

sub SaveSection {
  my ($name, $data) = @_;

  $Section{'revision'} += 1;   # Number of edited times
  $Section{'ts'} = $Now;       # Updated every edit
  $Section{'ip'} = $ENV{REMOTE_ADDR};
  $Section{'id'} = $UserID;
  $Section{'username'} = &GetParam("username", "");
  $Section{'data'} = $data;
  $Page{$name} = join($FS2, %Section);
}

sub SaveText {
  my ($name) = @_;

  &SaveSection("text_$name", join($FS3, %Text));
}

sub SaveDefaultText {
  &SaveText('default');
}

sub SetPageCache {
  my ($name, $data) = @_;

  $Page{"cache_$name"} = $data;
}

sub UpdatePageVersion {
  &ReportError(T('Bad page version (or corrupt page).'));
}

sub KeepFileName {
  return $KeepDir . "/" . &GetPageDirectory($OpenPageName)
         . "/$OpenPageName.kp";
}

sub SaveKeepSection {
  my $file = &KeepFileName();
  my $data;

  return  if ($Section{'revision'} < 1);  # Don't keep "empty" revision
  $Section{'keepts'} = $Now;
  $data = $FS1 . join($FS2, %Section);
  &CreatePageDir($KeepDir, $OpenPageName);
  &AppendStringToFileLimited($file, $data, $KeepSize);
}

sub ExpireKeepFile {
  my ($fname, $data, @kplist, %tempSection, $expirets);
  my ($anyExpire, $anyKeep, $expire, %keepFlag, $sectName, $sectRev);
  my ($oldMajor, $oldAuthor);

  $fname = &KeepFileName();
  return  if (!(-f $fname));
  $data = &ReadFileOrDie($fname);
  @kplist = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  return  if (length(@kplist) < 1);  # Also empty
  shift(@kplist)  if ($kplist[0] eq "");  # First can be empty
  return  if (length(@kplist) < 1);  # Also empty
  %tempSection = split(/$FS2/, $kplist[0], -1);
  if (!defined($tempSection{'keepts'})) {
    return;  # Bad keep file
  }
  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return  if ($tempSection{'keepts'} >= $expirets);  # Nothing old enough
  $anyExpire = 0;
  $anyKeep   = 0;
  %keepFlag  = ();
  $oldMajor  = &GetPageCache('oldmajor');
  $oldAuthor = &GetPageCache('oldauthor');
  foreach (reverse @kplist) {
    %tempSection = split(/$FS2/, $_, -1);
    $sectName = $tempSection{'name'};
    $sectRev = $tempSection{'revision'};
    $expire = 0;
    if ($sectName eq "text_default") {
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
      $keepFlag{$sectRev . "," . $sectName} = 1;
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
    if ($keepFlag{$sectRev . "," . $sectName}) {
      print OUT $FS1, $_;
    }
  }
  close(OUT);
}

sub OpenKeptList {
  my ($fname, $data);

  @KeptList = ();
  $fname = &KeepFileName();
  return  if (!(-f $fname));
  $data = &ReadFileOrDie($fname);
  @KeptList = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
}

sub OpenKeptRevisions {
  my ($name) = @_;  # Name of section
  my ($fname, $data, %tempSection);

  %KeptRevisions = ();
  &OpenKeptList();
  foreach (@KeptList) {
    %tempSection = split(/$FS2/, $_, -1);
    next  if ($tempSection{'name'} ne $name);
    $KeptRevisions{$tempSection{'revision'}} = $_;
  }
}

sub LoadUserData {
  my ($data, $status);

  %UserData = ();
  ($status, $data) = &ReadFile(&UserDataFilename($UserID));
  if (!$status) {
    $UserID = 112;  # Could not open file.  Consider warning message?
    return;
  }
  %UserData = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
}

sub UserDataFilename {
  my ($id) = @_;

  return ""  if ($id < 1);
  return $UserDir . "/" . ($id % 10) . "/$id.db";
}

# ==== Misc. functions ====
sub ReportError {
  my ($errmsg) = @_;

  print $q->header, $q->start_html, "<H2>", &QuoteHtml($errmsg), "</H2>", $q->end_html;
}

sub ValidId {
  my ($id) = @_;

  if (length($id) > 120) {
    return Ts('Page name is too long: %s', $id);
  }
  if ($id =~ m| |) {
    return Ts('Page name may not contain space characters: %s', $id);
  }
  if ($UseSubpage) {
    if ($id =~ m|.*/.*/|) {
      return Ts('Too many / characters in page %s', $id);
    }
    if ($id =~ /^\//) {
      return Ts('Invalid Page %s (subpage without main page)', $id);
    }
    if ($id =~ /\/$/) {
      return Ts('Invalid Page %s (missing subpage name)', $id);
    }
  }
  if ($FreeLinks) {
    $id =~ s/ /_/g;
    if (!$UseSubpage) {
      if ($id =~ /\//) {
        return Ts('Invalid Page %s (/ not allowed)', $id);
      }
    }
    if (!($id =~ m|^$FreeLinkPattern$|)) {
      return Ts('Invalid Page %s', $id);
    }
    if ($id =~ m|\.db$|) {
      return Ts('Invalid Page %s (must not end with .db)', $id);
    }
    if ($id =~ m|\.lck$|) {
      return Ts('Invalid Page %s (must not end with .lck)', $id);
    }
    return "";
  } else {
    if (!($id =~ /^$LinkPattern$/)) {
      return Ts('Invalid Page %s', $id);
    }
  }
  return "";
}

sub ValidIdOrDie {
  my ($id) = @_;
  my $error;

  $error = &ValidId($id);
  if ($error ne "") {
    &ReportError($error);
    return 0;
  }
  return 1;
}

sub UserCanEdit {
  my ($id, $deepCheck) = @_;

  # Optimized for the "everyone can edit" case (don't check passwords)
  if (($id ne "") && (-f &GetLockedPageFile($id))) {
    return 1  if (&UserIsAdmin());  # Requires more privledges
    # Consider option for editor-level to edit these pages?
    return 0;
  }
  if (!$EditAllowed) {
    return 1  if (&UserIsEditor());
    return 0;
  }
  if (-f "$DataDir/noedit") {
    return 1  if (&UserIsEditor());
    return 0;
  }
  if ($deepCheck) {   # Deeper but slower checks (not every page)
    return 1  if (&UserIsEditor());
    return 0  if (&UserIsBanned());
  }
  return 1;
}

sub UserIsBanned {
  my ($host, $ip, $data, $status);

  ($status, $data) = &ReadFile("$DataDir/banlist");
  return 0  if (!$status);  # No file exists, so no ban
  $data =~ s/\r//g;
  $ip = $ENV{'REMOTE_ADDR'};
  $host = &GetRemoteHost(0);
  foreach (split(/\n/, $data)) {
    next  if ((/^\s*$/) || (/^#/));  # Skip empty, spaces, or comments
    return 1  if ($ip   =~ /$_/i);
    return 1  if ($host =~ /$_/i);
  }
  return 0;
}

sub UserIsAdmin {
  my (@pwlist, $userPassword);

  return 0  if ($AdminPass eq "");
  $userPassword = &GetParam("adminpw", "");
  return 0  if ($userPassword eq "");
  foreach (split(/\s+/, $AdminPass)) {
    next  if ($_ eq "");
    return 1  if ($userPassword eq $_);
  }
  return 0;
}

sub UserIsEditor {
  my (@pwlist, $userPassword);

  return 1  if (&UserIsAdmin());             # Admin includes editor
  return 0  if ($EditPass eq "");
  $userPassword = &GetParam("adminpw", "");  # Used for both
  return 0  if ($userPassword eq "");
  foreach (split(/\s+/, $EditPass)) {
    next  if ($_ eq "");
    return 1  if ($userPassword eq $_);
  }
  return 0;
}

sub UserCanUpload {
  return 1  if (&UserIsEditor());
  return $AllUpload;
}

sub GetLockedPageFile {
  my ($id) = @_;

  return $PageDir . "/" . &GetPageDirectory($id) . "/$id.lck";
}

sub RequestLockDir {
  my ($name, $tries, $wait, $errorDie) = @_;
  my ($lockName, $n);

  &CreateDir($TempDir);
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
  my ($name) = @_;

  rmdir($LockDir . $name);
}

sub RequestLock {
  # 10 tries, 3 second wait, possibly die on error
  return &RequestLockDir("main", 10, 3, $LockCrash);
}

sub ReleaseLock {
  &ReleaseLockDir('main');
}

sub ForceReleaseLock {
  my ($name) = @_;
  my $forced;

  # First try to obtain lock (in case of normal edit lock)
  # 5 tries, 3 second wait, do not die on error
  $forced = !&RequestLockDir($name, 5, 3, 0);
  &ReleaseLockDir($name);  # Release the lock, even if we didn't get it.
  return $forced;
}

sub RequestCacheLock {
  # 4 tries, 2 second wait, do not die on error
  return &RequestLockDir('cache', 4, 2, 0);
}

sub ReleaseCacheLock {
  &ReleaseLockDir('cache');
}

sub RequestDiffLock {
  # 4 tries, 2 second wait, do not die on error
  return &RequestLockDir('diff', 4, 2, 0);
}

sub ReleaseDiffLock {
  &ReleaseLockDir('diff');
}

# Index lock is not very important--just return error if not available
sub RequestIndexLock {
  # 1 try, 2 second wait, do not die on error
  return &RequestLockDir('index', 1, 2, 0);
}

sub ReleaseIndexLock {
  &ReleaseLockDir('index');
}

sub ReadFile {
  my ($fileName) = @_;
  my ($data);
  local $/ = undef;   # Read complete files

  if (open(IN, "<$fileName")) {
    $data=<IN>;
    close IN;
    return (1, $data);
  }
  return (0, "");
}

sub ReadFileOrDie {
  my ($fileName) = @_;
  my ($status, $data);

  ($status, $data) = &ReadFile($fileName);
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

sub AppendStringToFileLimited {
  my ($file, $string, $limit) = @_;

  if (($limit < 1) || (((-s $file) + length($string)) <= $limit)) {
    &AppendStringToFile($file, $string);
  }
}

sub CreateDir {
  my ($newdir) = @_;

  mkdir($newdir, 0775)  if (!(-d $newdir));
}

sub CreatePageDir {
  my ($dir, $id) = @_;
  my $subdir;

  &CreateDir($dir);  # Make sure main page exists
  $subdir = $dir . "/" . &GetPageDirectory($id);
  &CreateDir($subdir);
  if ($id =~ m|([^/]+)/|) {
    $subdir = $subdir . "/" . $1;
    &CreateDir($subdir);
  }
}

sub UpdateHtmlCache {
  my ($id, $html) = @_;
  my $idFile;

  $idFile = &GetHtmlCacheFile($id);
  &CreatePageDir($HtmlDir, $id);
  if (&RequestCacheLock()) {
    &WriteStringToFile($idFile, $html);
    &ReleaseCacheLock();
  }
}

sub GenerateAllPagesList {
  my (@pages, @dirs, $id, $dir, @pageFiles, @subpageFiles, $subId);

  @pages = ();
  if ($FastGlob) {
    # The following was inspired by the FastGlob code by Marc W. Mengel.
    # Thanks to Bob Showalter for pointing out the improvement.
    opendir(PAGELIST, $PageDir);
    @dirs = readdir(PAGELIST);
    closedir(PAGELIST);
    @dirs = sort(@dirs);
    foreach $dir (@dirs) {
      next  if (substr($dir, 0, 1) eq '.');   # No ., .., or .dirs or files
      opendir(PAGELIST, "$PageDir/$dir");
      @pageFiles = readdir(PAGELIST);
      closedir(PAGELIST);
      foreach $id (@pageFiles) {
        next  if (($id eq '.') || ($id eq '..'));
        if (substr($id, -3) eq '.db') {
          push(@pages, substr($id, 0, -3));
        } elsif (substr($id, -4) ne '.lck') {
          opendir(PAGELIST, "$PageDir/$dir/$id");
          @subpageFiles = readdir(PAGELIST);
          closedir(PAGELIST);
          foreach $subId (@subpageFiles) {
            if (substr($subId, -3) eq '.db') {
              push(@pages, "$id/" . substr($subId, 0, -3));
            }
          }
        }
      }
    }
  } else {
    # Old slow/compatible method.
    @dirs = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z other);
    foreach $dir (@dirs) {
      if (-e "$PageDir/$dir") {  # Thanks to Tim Holt
        while (<$PageDir/$dir/*.db $PageDir/$dir/*/*.db>) {
          s|^$PageDir/||;
          m|^[^/]+/(\S*).db|;
          $id = $1;
          push(@pages, $id);
        }
      }
    }
  }
  return sort(@pages);
}

sub AllPagesList {
  my ($rawIndex, $refresh, $status);

  if (!$UseIndex) {
    return &GenerateAllPagesList();
  }
  $refresh = &GetParam("refresh", 0);
  if ($IndexInit && !$refresh) {
    # Note for mod_perl: $IndexInit is reset for each query
    # Eventually consider some timestamp-solution to keep cache?
    return @IndexList;
  }
  if ((!$refresh) && (-f $IndexFile)) {
    ($status, $rawIndex) = &ReadFile($IndexFile);
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
  @IndexList = &GenerateAllPagesList();
  foreach (@IndexList) {
    $IndexHash{$_} = 1;
  }
  $IndexInit = 1;  # Initialized for this run of the script
  # Try to write out the list for future runs
  &RequestIndexLock() or return @IndexList;
  &WriteStringToFile($IndexFile, join(" ", %IndexHash));
  &ReleaseIndexLock();
  return @IndexList;
}

sub CalcDay {
  my ($ts) = @_;

  $ts += $TimeZoneOffset;
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime($ts);
  if ($NumberDates) {
    return ($year + 1900) . '-' . ($mon+1) . '-' . $mday;
  }
  return ("January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November",
          "December")[$mon]. " " . $mday . ", " . ($year+1900);
}

sub CalcTime {
  my ($ts) = @_;
  my ($ampm, $mytz);

  $ts += $TimeZoneOffset;
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime($ts);
  $mytz = "";
  if (($TimeZoneOffset == 0) && ($ScriptTZ ne "")) {
    $mytz = " " . $ScriptTZ;
  }
  $ampm = "";
  if ($UseAmPm) {
    $ampm = " am";
    if ($hour > 11) {
      $ampm = " pm";
      $hour = $hour - 12;
    }
    $hour = 12   if ($hour == 0);
  }
  $min = "0" . $min   if ($min<10);
  return $hour . ":" . $min . $ampm . $mytz;
}

sub TimeToText {
  my ($t) = @_;

  return &CalcDay($t) . " " . &CalcTime($t);
}

sub GetParam {
  my ($name, $default) = @_;
  my $result;

  $result = $q->param($name);
  if (!defined($result)) {
    if (defined($UserData{$name})) {
      $result = $UserData{$name};
    } else {
      $result = $default;
    }
  }
  return $result;
}

sub GetHiddenValue {
  my ($name, $value) = @_;

  $q->param($name, $value);
  return $q->hidden($name);
}

sub GetRemoteHost {
  my ($doMask) = @_;
  my ($rhost, $iaddr);

  $rhost = $ENV{REMOTE_HOST};
  if ($UseLookup && ($rhost eq "")) {
    # Catch errors (including bad input) without aborting the script
    eval 'use Socket; $iaddr = inet_aton($ENV{REMOTE_ADDR});'
         . '$rhost = gethostbyaddr($iaddr, AF_INET)';
  }
  if ($rhost eq "") {
    $rhost = $ENV{REMOTE_ADDR};
  }
  $rhost = &GetMaskedHost($rhost)  if ($doMask);
  return $rhost;
}

sub FreeToNormal {
  my ($id) = @_;

  $id =~ s/ /_/g;
  $id = ucfirst($id)  if ($UpperFirst || $FreeUpper);
  if (index($id, '_') > -1) {  # Quick check for any space/underscores
    $id =~ s/__+/_/g;
    $id =~ s/^_//;
    $id =~ s/_$//;
    if ($UseSubpage) {
      $id =~ s|_/|/|g;
      $id =~ s|/_|/|g;
    }
  }
  if ($FreeUpper) {
    # Note that letters after ' are *not* capitalized
    if ($id =~ m|[-_.,\(\)/][a-z]|) {    # Quick check for non-canonical case
      $id =~ s|([-_.,\(\)/])([a-z])|$1 . uc($2)|ge;
    }
  }
  return $id;
}
#END_OF_BROWSE_CODE

# == Page-editing and other special-action code ========================
$OtherCode = ""; # Comment next line to always compile (slower)
#$OtherCode = <<'#END_OF_OTHER_CODE';

sub DoOtherRequest {
  my ($id, $action, $text, $search);

  $action = &GetParam("action", "");
  $id = &GetParam("id", "");
  if ($action ne "") {
    $action = lc($action);
    if      ($action eq "edit") {
      &DoEdit($id, 0, 0, "", 0)  if &ValidIdOrDie($id);
    } elsif ($action eq "unlock") {
      &DoUnlock();
    } elsif ($action eq "index") {
      &DoIndex();
    } elsif ($action eq "links") {
      &DoLinks();
    } elsif ($action eq "maintain") {
      &DoMaintain();
    } elsif ($action eq "pagelock") {
      &DoPageLock();
    } elsif ($action eq "editlock") {
      &DoEditLock();
    } elsif ($action eq "editprefs") {
      &DoEditPrefs();
    } elsif ($action eq "editbanned") {
      &DoEditBanned();
    } elsif ($action eq "editlinks") {
      &DoEditLinks();
    } elsif ($action eq "login") {
      &DoEnterLogin();
    } elsif ($action eq "newlogin") {
      $UserID = 0;
      &DoEditPrefs();  # Also creates new ID
    } elsif ($action eq "version") {
      &DoShowVersion();
    } elsif ($action eq "rss") {
      &DoRss();
    } elsif ($action eq "delete") {
      &DoDeletePage($id);
    } elsif ($UseUpload && ($action eq "upload")) {
      &DoUpload();
    } elsif ($action eq "maintainrc") {
      &DoMaintainRc();
    } elsif ($action eq "convert") {
      &DoConvert();
    } elsif ($action eq "trimusers") {
      &DoTrimUsers();
    } else {
      &ReportError(Ts('Invalid action parameter %s', $action));
    }
    return;
  }
  if (&GetParam("edit_prefs", 0)) {
    &DoUpdatePrefs();
    return;
  }
  if (&GetParam("edit_ban", 0)) {
    &DoUpdateBanned();
    return;
  }
  if (&GetParam("enter_login", 0)) {
    &DoLogin();
    return;
  }
  if (&GetParam("edit_links", 0)) {
    &DoUpdateLinks();
    return;
  }
  if ($UseUpload && (&GetParam("upload", 0))) {
    &SaveUpload();
    return;
  }
  $search = &GetParam("search", "");
  if (($search ne "") || (&GetParam("dosearch", "") ne "")) {
    &DoSearch($search);
    return;
  } else {
    $search = &GetParam("back","");
    if ($search ne "") {
      &DoBackLinks($search);
      return;
    }
  }
  # Handle posted pages
  if (&GetParam("oldtime", "") ne "") {
    $id = &GetParam("title", "");
    &DoPost()  if &ValidIdOrDie($id);
    return;
  }
  &ReportError(T('Invalid URL.'));
}

sub DoEdit {
  my ($id, $isConflict, $oldTime, $newText, $preview) = @_;
  my ($header, $editRows, $editCols, $userName, $revision, $oldText);
  my ($summary, $isEdit, $pageTime);

  if ($FreeLinks) {
    $id = &FreeToNormal($id);  # Take care of users like Markus Lude :-)
  }
  if (!&UserCanEdit($id, 1)) {
    print &GetHeader('', T('Editing Denied'), '');
    if (&UserIsBanned()) {
      print T('Editing not allowed: user, ip, or network is blocked.');
      print "<p>";
      print T('Contact the wiki administrator for more information.');
    } else {
      print Ts('Editing not allowed: %s is read-only.', $SiteName);
    }
    print &GetCommonFooter();
    return;
  }
  # Consider sending a new user-ID cookie if user does not have one
  &OpenPage($id);
  &OpenDefaultText();
  $pageTime = $Section{'ts'};
  $header = Ts('Editing %s', $id);
  # Old revision handling
  $revision = &GetParam('revision', '');
  $revision =~ s/\D//g;  # Remove non-numeric chars
  if ($revision ne '') {
    &OpenKeptRevisions('text_default');
    if (!defined($KeptRevisions{$revision})) {
      $revision = '';
      # Consider better solution like error message?
    } else {
      &OpenKeptRevision($revision);
      $header = Ts('Editing revision %s of ', $revision ) . $id;
    }
  }
  $oldText = $Text{'text'};
  if ($preview && !$isConflict) {
    $oldText = $newText;
  }
  $editRows = &GetParam("editrows", 20);
  $editCols = &GetParam("editcols", 65);
  print &GetHeader($id, &QuoteHtml($header), '');
  if ($revision ne '') {
    print "\n<b>"
          . Ts('Editing old revision %s.', $revision) . "  "
    . T('Saving this page will replace the latest revision with this text.')
          . '</b><br>'
  }
  if ($isConflict) {
    $editRows -= 10  if ($editRows > 19);
    print "\n<H1>" . T('Edit Conflict!') . "</H1>\n";
    if ($isConflict>1) {
      # The main purpose of a new warning is to display more text
      # and move the save button down from its old location.
      print "\n<H2>" . T('(This is a new conflict)') . "</H2>\n";
    }
    print "<p><strong>",
          T('Someone saved this page after you started editing.'), " ",
          T('The top textbox contains the saved text.'), " ",
          T('Only the text in the top textbox will be saved.'),
          "</strong><br>\n",
          T('Scroll down to see your edited text.'), "<br>\n";
    print T('Last save time:'), ' ', &TimeToText($oldTime),
          " (", T('Current time is:'), ' ', &TimeToText($Now), ")<br>\n";
  }
  print &GetFormStart();
  print &GetHiddenValue("title", $id), "\n",
        &GetHiddenValue("oldtime", $pageTime), "\n",
        &GetHiddenValue("oldconflict", $isConflict), "\n";
  if ($revision ne "") {
    print &GetHiddenValue("revision", $revision), "\n";
  }
  print &GetTextArea('text', $oldText, $editRows, $editCols);
  $summary = &GetParam("summary", "*");
  print "<p>", T('Summary:'),
        $q->textfield(-name=>'summary',
                      -default=>$summary, -override=>1,
                      -size=>60, -maxlength=>200);
  if (&GetParam("recent_edit") eq "on") {
    print "<br>", $q->checkbox(-name=>'recent_edit', -checked=>1,
                               -label=>T('This change is a minor edit.'));
  } else {
    print "<br>", $q->checkbox(-name=>'recent_edit',
                               -label=>T('This change is a minor edit.'));
  }
  if ($EmailNotify) {
    print "&nbsp;&nbsp;&nbsp;" .
           $q->checkbox(-name=> 'do_email_notify',
      -label=>Ts('Send email notification that %s has been changed.', $id));
  }
  print "<br>";
  if ($EditNote ne '') {
    print T($EditNote) . '<br>';  # Allow translation
  }
  print $q->submit(-name=>'Save', -value=>T('Save')), "\n";
  $userName = &GetParam("username", "");
  if ($userName ne "") {
    print ' (', T('Your user name is'), ' ',
          &GetPageLink($userName) . ') ';
  } else {
    print ' (', Ts('Visit %s to set your user name.', &GetPrefsLink(), 1), ') ';
  }
  print $q->submit(-name=>'Preview', -value=>T('Preview')), "\n";
  if ($isConflict) {
    print "\n<br><hr><p><strong>", T('This is the text you submitted:'),
          "</strong><p>",
          &GetTextArea('newtext', $newText, $editRows, $editCols),
          "<p>\n";
  }
  if ($preview) {
    print '<div class=wikipreview>';
    print "<hr class=wikilinepreview>\n";
    print "<h2>", T('Preview:'), "</h2>\n";
    if ($isConflict) {
      print "<b>",
            T('NOTE: This preview shows the revision of the other author.'),
            "</b><hr>\n";
    }
    $MainPage = $id;
    $MainPage =~ s|/.*||;  # Only the main page name (remove subpage)
    print &WikiToHTML($oldText) . "<hr class=wikilinepreview>\n";
    print "<h2>", T('Preview only, not yet saved'), "</h2>\n";
    print '</div>';
  }
  print $q->endform;
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetHistoryLink($id, T('View other revisions')) . "<br>\n";
    print &GetGotoBar($id);
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub GetTextArea {
  my ($name, $text, $rows, $cols) = @_;

  if (&GetParam("editwide", 1)) {
    return $q->textarea(-name=>$name, -default=>$text,
                        -rows=>$rows, -columns=>$cols, -override=>1,
                        -style=>'width:100%', -wrap=>'virtual');
  }
  return $q->textarea(-name=>$name, -default=>$text,
                      -rows=>$rows, -columns=>$cols, -override=>1,
                      -wrap=>'virtual');
}

sub DoEditPrefs {
  my ($check, $recentName, %labels);

  $recentName = $RCName;
  $recentName =~ s/_/ /g;
  &DoNewLogin()  if ($UserID < 400);
  print &GetHeader('', T('Editing Preferences'), '');
  print '<div class=wikipref>';
  print &GetFormStart();
  print GetHiddenValue("edit_prefs", 1), "\n";
  print '<b>' . T('User Information:') . "</b>\n";
  print '<br>' . Ts('Your User ID number: %s', $UserID) . "\n";
  print '<br>' . T('UserName:') . ' ', &GetFormText('username', "", 20, 50);
  print ' ' . T('(blank to remove, or valid page name)');
  print '<br>' . T('Set Password:') . ' ',
        $q->password_field(-name=>'p_password', -value=>'*', 
                           -size=>15, -maxlength=>50),
        ' ', T('(blank to remove password)'), '<br>(',
        T('Passwords allow sharing preferences between multiple systems.'),
        ' ', T('Passwords are completely optional.'), ')';
  if (($AdminPass ne '') || ($EditPass ne '')) {
    print '<br>', T('Administrator Password:'), ' ',
          $q->password_field(-name=>'p_adminpw', -value=>'*', 
                             -size=>15, -maxlength=>50),
          ' ', T('(blank to remove password)'), '<br>',
          T('(Administrator passwords are used for special maintenance.)');
  }
  if ($EmailNotify) {
    print "<br>";
    print &GetFormCheck('notify', 1,
          T('Include this address in the site email list.')), ' ',
          T('(Uncheck the box to remove the address.)');
    print '<br>', T('Email Address:'), ' ',
          &GetFormText('email', "", 30, 60);
  }
  print "<hr class=wikilinepref><b>$recentName:</b>\n";
  print '<br>', T('Default days to display:'), ' ',
        &GetFormText('rcdays', $RcDefault, 4, 9);
  print "<br>", &GetFormCheck('rcnewtop', $RecentTop,
                              T('Most recent changes on top'));
  print "<br>", &GetFormCheck('rcall', 0,
                              T('Show all changes (not just most recent)'));
  %labels = (0=>T('Hide minor edits'), 1=>T('Show minor edits'),
             2=>T('Show only minor edits'));
  print '<br>', T('Minor edit display:'), ' ';
  print $q->popup_menu(-name=>'p_rcshowedit',
                       -values=>[0,1,2], -labels=>\%labels,
                       -default=>&GetParam("rcshowedit", $ShowEdits));
  print "<br>", &GetFormCheck('rcchangehist', 1,
                              T('Use "changes" as link to history'));
  if ($UseDiff) {
    print '<hr class=wikilinepref><b>', T('Differences:'), "</b>\n";
    print "<br>", &GetFormCheck('diffrclink', 1,
                                Ts('Show (diff) links on %s', $recentName));
    print "<br>", &GetFormCheck('alldiff', 0,
                                T('Show differences on all pages'));
    print "  (",  &GetFormCheck('norcdiff', 1,
                                Ts('No differences on %s', $recentName)), ")";
    %labels = (1=>T('Major'), 2=>T('Minor'), 3=>T('Author'));
    print '<br>', T('Default difference type:'), ' ';
    print $q->popup_menu(-name=>'p_defaultdiff',
                         -values=>[1,2,3], -labels=>\%labels,
                         -default=>&GetParam("defaultdiff", 1));
  }
  print '<hr class=wikilinepref><b>', T('Misc:'), "</b>\n";
  # Note: TZ offset is added by TimeToText, so pre-subtract to cancel.
  print '<br>', T('Server time:'), ' ', &TimeToText($Now-$TimeZoneOffset);
  print '<br>', T('Time Zone offset (hours):'), ' ',
        &GetFormText('tzoffset', 0, 4, 9);
  print '<br>', &GetFormCheck('editwide', 1,
                              T('Use 100% wide edit area (if supported)'));
  print '<br>',
        T('Edit area rows:'), ' ', &GetFormText('editrows', 20, 4, 4),
        ' ', T('columns:'),   ' ', &GetFormText('editcols', 65, 4, 4);

  print '<br>', &GetFormCheck('toplinkbar', 1,
                              T('Show link bar on top'));
  print '<br>', &GetFormCheck('linkrandom', 0,
                              T('Add "Random Page" link to link bar'));
  print '<br>' . T('StyleSheet URL:') . ' ',
        &GetFormText('stylesheet', "", 30, 150);
  print '<br>', $q->submit(-name=>'Save', -value=>T('Save')), "\n";
  print $q->endform;
  print '</div>';
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetGotoBar('');
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub GetFormText {
  my ($name, $default, $size, $max) = @_;
  my $text = &GetParam($name, $default);

  return $q->textfield(-name=>"p_$name", -default=>$text,
                       -override=>1, -size=>$size, -maxlength=>$max);
}

sub GetFormCheck {
  my ($name, $default, $label) = @_;
  my $checked = (&GetParam($name, $default) > 0);

  return $q->checkbox(-name=>"p_$name", -override=>1, -checked=>$checked,
                      -label=>$label);
}

sub DoUpdatePrefs {
  my ($username, $password, $stylesheet);

  # All link bar settings should be updated before printing the header
  &UpdatePrefCheckbox("toplinkbar");
  &UpdatePrefCheckbox("linkrandom");
  print &GetHeader('', T('Saving Preferences'), '');
  print '<br>';
  if ($UserID < 1001) {
    print '<b>',
          Ts('Invalid UserID %s, preferences not saved.', $UserID), '</b>';
    if ($UserID == 111) {
      print '<br>',
            T('(Preferences require cookies, but no cookie was sent.)');
    }
    print &GetCommonFooter();
    return;
  }
  $username = &GetParam("p_username",  "");
  if ($FreeLinks) {
    $username =~ s/^\[\[(.+)\]\]/$1/;  # Remove [[ and ]] if added
    $username =  &FreeToNormal($username);
    $username =~ s/_/ /g;
  }
  if ($username eq "") {
    print T('UserName removed.'), '<br>';
    undef $UserData{'username'};
  } elsif ((!$FreeLinks) && (!($username =~ /^$LinkPattern$/))) {
    print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
  } elsif ($FreeLinks && (!($username =~ /^$FreeLinkPattern$/))) {
    print Ts('Invalid UserName %s: not saved.', $username), "<br>\n";
  } elsif (length($username) > 50) {  # Too long
    print T('UserName must be 50 characters or less. (not saved)'), "<br>\n";
  } else {
    print Ts('UserName %s saved.', $username), '<br>';
    $UserData{'username'} = $username;
  }
  $password = &GetParam("p_password",  "");
  if ($password eq "") {
    print T('Password removed.'), '<br>';
    undef $UserData{'password'};
  } elsif ($password ne "*") {
    print T('Password changed.'), '<br>';
    $UserData{'password'} = $password;
  }
  if (($AdminPass ne "") || ($EditPass ne "")) {
    $password = &GetParam("p_adminpw",  "");
    if ($password eq "") {
      print T('Administrator password removed.'), '<br>';
      undef $UserData{'adminpw'};
    } elsif ($password ne "*") {
      print T('Administrator password changed.'), '<br>';
      $UserData{'adminpw'} = $password;
      if (&UserIsAdmin()) {
        print T('User has administrative abilities.'), '<br>';
      } elsif (&UserIsEditor()) {
        print T('User has editor abilities.'), '<br>';
      } else {
        print T('User does not have administrative abilities.'), ' ',
              T('(Password does not match administrative password(s).)'),
              '<br>';
      }
    }
  }
  if ($EmailNotify) {
    &UpdatePrefCheckbox("notify");
    &UpdateEmailList();
  }
  &UpdatePrefNumber("rcdays", 0, 0, 999999);
  &UpdatePrefCheckbox("rcnewtop");
  &UpdatePrefCheckbox("rcall");
  &UpdatePrefCheckbox("rcchangehist");
  &UpdatePrefCheckbox("editwide");
  if ($UseDiff) {
    &UpdatePrefCheckbox("norcdiff");
    &UpdatePrefCheckbox("diffrclink");
    &UpdatePrefCheckbox("alldiff");
    &UpdatePrefNumber("defaultdiff", 1, 1, 3);
  }
  &UpdatePrefNumber("rcshowedit", 1, 0, 2);
  &UpdatePrefNumber("tzoffset", 0, -999, 999);
  &UpdatePrefNumber("editrows", 1, 1, 999);
  &UpdatePrefNumber("editcols", 1, 1, 999);
  print T('Server time:'), ' ', &TimeToText($Now-$TimeZoneOffset), '<br>';
  $TimeZoneOffset = &GetParam("tzoffset", 0) * (60 * 60);
  print T('Local time:'), ' ', &TimeToText($Now), '<br>';
  $stylesheet = &GetParam('p_stylesheet', '');
  if ($stylesheet eq '') {
    if (&GetParam('stylesheet', '') ne '') {
      print T('StyleSheet URL removed.'), '<br>';
    }
    undef $UserData{'stylesheet'};
  } else {
    $stylesheet =~ s/[">]//g;  # Remove characters that would cause problems
    $UserData{'stylesheet'} = $stylesheet;
    print T('StyleSheet setting saved.'), '<br>';
  }
  &SaveUserData();
  print '<b>', T('Preferences saved.'), '</b>';
  print &GetCommonFooter();
}

# add or remove email address from preferences to $EmailFile
sub UpdateEmailList {
  my (@old_emails);

  local $/ = "\n";  # don't slurp whole files in this sub.
  if (my $new_email = $UserData{'email'} = &GetParam("p_email", "")) {
    my $notify = $UserData{'notify'};
    if (-f $EmailFile) {
      open(NOTIFY, $EmailFile)
        or die(Ts('Could not read from %s:', $EmailFile) . " $!\n");
      @old_emails = <NOTIFY>;
      close(NOTIFY);
    } else {
      @old_emails = ();
    }
    my $already_in_list = grep /$new_email/, @old_emails;
    if ($notify and (not $already_in_list)) {
      &RequestLock() or die(T('Could not get mail lock'));
      if (!open(NOTIFY, ">>$EmailFile")) {
        &ReleaseLock();  # Don't leave hangling locks
        die(Ts('Could not append to %s:', $EmailFile) . " $!\n");
      }
      print NOTIFY $new_email, "\n";
      close(NOTIFY);
      &ReleaseLock();
    }
    elsif ((not $notify) and $already_in_list) {
      &RequestLock() or die(T('Could not get mail lock'));
      if (!open(NOTIFY, ">$EmailFile")) {
        &ReleaseLock();
        die(Ts('Could not overwrite %s:', "$EmailFile") . " $!\n");
      }
      foreach (@old_emails) {
        print NOTIFY "$_" unless /$new_email/;
      }
      close(NOTIFY);
      &ReleaseLock();
    }
  }
}

sub UpdatePrefCheckbox {
  my ($param) = @_;
  my $temp = &GetParam("p_$param", "*");

  $UserData{$param} = 1  if ($temp eq "on");
  $UserData{$param} = 0  if ($temp eq "*");
  # It is possible to skip updating by using another value, like "2"
}

sub UpdatePrefNumber {
  my ($param, $integer, $min, $max) = @_;
  my $temp = &GetParam("p_$param", "*");

  return  if ($temp eq "*");
  $temp =~ s/[^-\d\.]//g;
  $temp =~ s/\..*//  if ($integer);
  return  if ($temp eq "");
  return  if (($temp < $min) || ($temp > $max));
  $UserData{$param} = $temp;
}

sub DoIndex {
  print &GetHeader('', T('Index of all pages'), '');
  print '<br>';
  &PrintPageList(&AllPagesList());
  print &GetCommonFooter();
}

# Create a new user file/cookie pair
sub DoNewLogin {
  # Consider warning if cookie already exists
  # (maybe use "replace=1" parameter)
  &CreateUserDir();
  $SetCookie{'id'} = &GetNewUserId();
  $SetCookie{'randkey'} = int(rand(1000000000));
  $SetCookie{'rev'} = 1;
  %UserCookie = %SetCookie;
  $UserID = $SetCookie{'id'};
  # The cookie will be transmitted in the next header
  %UserData = %UserCookie;
  $UserData{'createtime'} = $Now;
  $UserData{'createip'} = $ENV{REMOTE_ADDR};
  &SaveUserData();
}

sub DoEnterLogin {
  print &GetHeader('', T('Login'), "");
  print &GetFormStart();
  print &GetHiddenValue('enter_login', 1), "\n";
  print '<br>', T('User ID number:'), ' ',
        $q->textfield(-name=>'p_userid', -value=>'',
                      -size=>15, -maxlength=>50);
  print '<br>', T('Password:'), ' ',
        $q->password_field(-name=>'p_password', -value=>'', 
                           -size=>15, -maxlength=>50);
  print '<br>', $q->submit(-name=>'Login', -value=>T('Login')), "\n";
  print $q->endform;
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetGotoBar('');
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub DoLogin {
  my ($uid, $password, $success);

  $success = 0;
  $uid = &GetParam("p_userid", "");
  $uid =~ s/\D//g;
  $password = &GetParam("p_password",  "");
  if (($uid > 199) && ($password ne "") && ($password ne "*")) {
    $UserID = $uid;
    &LoadUserData();
    if ($UserID > 199) {
      if (defined($UserData{'password'}) &&
          ($UserData{'password'} eq $password)) {
        $SetCookie{'id'} = $uid;
        $SetCookie{'randkey'} = $UserData{'randkey'};
        $SetCookie{'rev'} = 1;
        $success = 1;
      }
    }
  }
  print &GetHeader('', T('Login Results'), '');
  if ($success) {
    print Ts('Login for user ID %s complete.', $uid);
  } else {
    print Ts('Login for user ID %s failed.', $uid);
  }
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetGotoBar('');
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub GetNewUserId {
  my ($id);

  $id = $StartUID;
  while (-f &UserDataFilename($id+1000)) {
    $id += 1000;
  }
  while (-f &UserDataFilename($id+100)) {
    $id += 100;
  }
  while (-f &UserDataFilename($id+10)) {
    $id += 10;
  }
  &RequestLock() or die(T('Could not get user-ID lock'));
  while (-f &UserDataFilename($id)) {
    $id++;
  }
  &WriteStringToFile(&UserDataFilename($id), "lock");  # reserve the ID
  &ReleaseLock();
  return $id;
}

# Consider user-level lock?
sub SaveUserData {
  my ($userFile, $data);

  &CreateUserDir();
  $userFile = &UserDataFilename($UserID);
  $data = join($FS1, %UserData);
  &WriteStringToFile($userFile, $data);
}

sub CreateUserDir {
  my ($n, $subdir);

  if (!(-d "$UserDir/0")) {
    &CreateDir($UserDir);

    foreach $n (0..9) {
      $subdir = "$UserDir/$n";
      &CreateDir($subdir);
    }
  }
}

sub DoSearch {
  my ($string) = @_;

  if ($string eq '') {
    &DoIndex();
    return;
  }
  print &GetHeader('', &QuoteHtml(Ts('Search for: %s', $string)), '');
  print '<br>';
  &PrintPageList(&SearchTitleAndBody($string));
  print &GetCommonFooter();
}

sub DoBackLinks {
  my ($string) = @_;

  print &GetHeader('', &QuoteHtml(Ts('Backlinks for: %s', $string)), '');
  print '<br>';
  # At this time the backlinks are mostly a renamed search.
  # An initial attempt to match links only failed on subpages and free links.
  # Escape some possibly problematic characters:
  $string =~ s/([-'().,])/\\$1/g; 
  &PrintPageList(&SearchTitleAndBody($string));
  print &GetCommonFooter();
}

sub PrintPageList {
  my $pagename;

  print "<h2>", Ts('%s pages found:', ($#_ + 1)), "</h2>\n";
  foreach $pagename (@_) {
    print ".... "  if ($pagename =~ m|/|);
    print &GetPageLink($pagename), "<br>\n";
  }
}

sub DoLinks {
  print &GetHeader('', &QuoteHtml(T('Full Link List')), '');
  print "<hr><pre>\n\n\n\n\n";  # Extra lines to get below the logo
  &PrintLinkList(&GetFullLinkList());
  print "</pre>\n";
  print &GetCommonFooter();
}

sub PrintLinkList {
  my ($pagelines, $page, $names, $editlink);
  my ($link, $extra, @links, %pgExists);

  %pgExists = ();
  foreach $page (&AllPagesList()) {
    $pgExists{$page} = 1;
  }
  $names = &GetParam("names", 1);
  $editlink = &GetParam("editlink", 0);
  foreach $pagelines (@_) {
    @links = ();
    foreach $page (split(' ', $pagelines)) {
      if ($page =~ /\:/) {  # URL or InterWiki form
        if ($page =~ /$UrlPattern/) {
          ($link, $extra) = &UrlLink($page, 0);  # No images
        } else {
          ($link, $extra) = &InterPageLink($page, 0);  # No images
        }
      } else {
        if ($pgExists{$page}) {
          $link = &GetPageLink($page);
        } else {
          $link = $page;
          if ($editlink) {
            $link .= &GetEditLink($page, "?");
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
  my ($name, $unique, $sort, $exists, $empty, $link, $search);
  my ($pagelink, $interlink, $urllink);
  my (@found, @links, @newlinks, @pglist, %pgExists, %seen, $main);

  $unique = &GetParam("unique", 1);
  $sort = &GetParam("sort", 1);
  $pagelink = &GetParam("page", 1);
  $interlink = &GetParam("inter", 0);
  $urllink = &GetParam("url", 0);
  $exists = &GetParam("exists", 2);
  $empty = &GetParam("empty", 0);
  $search = &GetParam("search", "");
  if (($interlink == 2) || ($urllink == 2)) {
    $pagelink = 0;
  }
  %pgExists = ();
  @pglist = &AllPagesList();
  foreach $name (@pglist) {
    $pgExists{$name} = 1;
  }
  %seen = ();
  foreach $name (@pglist) {
    @newlinks = ();
    if ($unique != 2) {
      %seen = ();
    }
    @links = &GetPageLinks($name, $pagelink, $interlink, $urllink);
    if ($UseSubpage) {
      $main = $name;
      $main =~ s/\/.*//;
    }
    foreach $link (@links) {
      if ($UseSubpage && ($link =~ /^\//)) {
        $link = $main . $link;
      }
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
      if (($search ne "") && !($link =~ /$search/)) {
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
  &OpenPage($name);
  &OpenDefaultText();
  $text = $Text{'text'};
  $text =~ s/<html>((.|\n)*?)<\/html>/ /ig;
  $text =~ s/<nowiki>(.|\n)*?\<\/nowiki>/ /ig;
  $text =~ s/<pre>(.|\n)*?\<\/pre>/ /ig;
  $text =~ s/<code>(.|\n)*?\<\/code>/ /ig;
  if ($interlink) {
    $text =~ s/''+/ /g;  # Quotes can adjacent to inter-site links
    $text =~ s/$InterLinkPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
  } else {
    $text =~ s/$InterLinkPattern/ /g;
  }
  if ($urllink) {
    $text =~ s/''+/ /g;  # Quotes can adjacent to URLs
    $text =~ s/$UrlPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
  } else {
    $text =~ s/$UrlPattern/ /g;
  }
  if ($pagelink) {
    if ($FreeLinks) {
      my $fl = $FreeLinkPattern;
      $text =~ s/\[\[$fl\|[^\]]+\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
      $text =~ s/\[\[$fl\]\]/push(@links, &FreeToNormal($1)), ' '/ge;
    }
    if ($WikiLinks) {
      $text =~ s/$LinkPattern/push(@links, &StripUrlPunct($1)), ' '/ge;
    }
  }
  return @links;
}

sub DoPost {
  my ($editDiff, $old, $newAuthor, $pgtime, $oldrev, $preview, $user);
  my $string = &GetParam("text", undef);
  my $id = &GetParam("title", "");
  my $summary = &GetParam("summary", "");
  my $oldtime = &GetParam("oldtime", "");
  my $oldconflict = &GetParam("oldconflict", "");
  my $isEdit = 0;
  my $editTime = $Now;
  my $authorAddr = $ENV{REMOTE_ADDR};

  if ($FreeLinks) {
    $id = &FreeToNormal($id);
  }
  if (!&UserCanEdit($id, 1)) {
    # This is an internal interface--we don't need to explain
    &ReportError(Ts('Editing not allowed for %s.', $id));
    return;
  }
  if (($id eq   'SampleUndefinedPage')    ||
      ($id eq T('SampleUndefinedPage'))   ||
      ($id eq   'Sample_Undefined_Page')  ||
      ($id eq T('Sample_Undefined_Page'))) {
    &ReportError(Ts('%s cannot be defined.', $id));
    return;
  }
  $string  = &RemoveFS($string);
  $summary = &RemoveFS($summary);
  $summary =~ s/[\r\n]//g;
  if (length($summary) > 300) {  # Too long (longer than form allows)
    $summary = substr($summary, 0, 300);
  }
  # Add a newline to the end of the string (if it doesn't have one)
  $string .= "\n"  if (!($string =~ /\n$/));
  # Lock before getting old page to prevent races
  # Consider extracting lock section into sub, and eval-wrap it?
  # (A few called routines can die, leaving locks.)
  if ($LockCrash) {
    &RequestLock() or die(T('Could not get editing lock'));
  } else {
    if (!&RequestLock()) {
      &ForceReleaseLock('main');
    }
    # Clear all other locks.
    &ForceReleaseLock('cache');
    &ForceReleaseLock('diff');
    &ForceReleaseLock('index');
  }
  &OpenPage($id);
  &OpenDefaultText();
  $old = $Text{'text'};
  $oldrev = $Section{'revision'};
  $pgtime = $Section{'ts'};
  $preview = 0;
  $preview = 1  if (&GetParam("Preview", "") ne "");
  if (!$preview && ($old eq $string)) {  # No changes (ok for preview)
    &ReleaseLock();
    &ReBrowsePage($id, "", 1);
    return;
  }
  if (($UserID > 399) || ($Section{'id'} > 399))  {
    $newAuthor = ($UserID ne $Section{'id'});       # known user(s)
  } else {
    $newAuthor = ($Section{'ip'} ne $authorAddr);  # hostname fallback
  }
  $newAuthor = 1  if ($oldrev == 0);  # New page
  $newAuthor = 0  if (!$newAuthor);   # Standard flag form, not empty
  # Detect editing conflicts and resubmit edit
  if (($oldrev > 0) && ($newAuthor && ($oldtime != $pgtime))) {
    &ReleaseLock();
    if ($oldconflict > 0) {  # Conflict again...
      &DoEdit($id, 2, $pgtime, $string, $preview);
    } else {
      &DoEdit($id, 1, $pgtime, $string, $preview);
    }
    return;
  }
  if ($preview) {
    &ReleaseLock();
    &DoEdit($id, 0, $pgtime, $string, 1);
    return;
  }
  $user = &GetParam("username", "");
  # If the person doing editing chooses, send out email notification
  if ($EmailNotify) {
    &EmailNotify($id, $user) if &GetParam("do_email_notify", "") eq 'on';
  }
  if (&GetParam("recent_edit", "") eq 'on') {
    $isEdit = 1;
  }
  if (!$isEdit) {
    &SetPageCache('oldmajor', $Section{'revision'});
  }
  if ($newAuthor) {
    &SetPageCache('oldauthor', $Section{'revision'});
  }
  &SaveKeepSection();
  &ExpireKeepFile();
  if ($UseDiff) {
    &UpdateDiffs($id, $editTime, $old, $string, $isEdit, $newAuthor);
  }
  $Text{'text'} = $string;
  $Text{'minor'} = $isEdit;
  $Text{'newauthor'} = $newAuthor;
  $Text{'summary'} = $summary;
  $Section{'host'} = &GetRemoteHost(1);
  &SaveDefaultText(); 
  &SavePage();
  &WriteRcLog($id, $summary, $isEdit, $editTime, $Section{'revision'},
              $user, $Section{'host'});
  if ($UseCache) {
    &UnlinkHtmlCache($id);         # Old cached copy is invalid
    if ($Page{'revision'} < 2) {   # If this is a new page...
      &NewPageCacheClear($id);     # ...uncache pages linked to this one.
    }
  }
  if ($UseIndex && ($Page{'revision'} == 1)) {
    unlink($IndexFile);  # Regenerate index on next request
  }
  &ReleaseLock();
  &ReBrowsePage($id, "", 1);
}

sub UpdateDiffs {
  my ($id, $editTime, $old, $new, $isEdit, $newAuthor) = @_;
  my ($editDiff, $oldMajor, $oldAuthor);

  $editDiff  = &GetDiff($old, $new, 0);     # 0 = already in lock
  $oldMajor  = &GetPageCache('oldmajor');
  $oldAuthor = &GetPageCache('oldauthor');
  if ($UseDiffLog) {
    &WriteDiff($id, $editTime, $editDiff);
  }
  &SetPageCache('diff_default_minor', $editDiff);
  if ($isEdit || !$newAuthor) {
    &OpenKeptRevisions('text_default');
  }
  if (!$isEdit) {
    &SetPageCache('diff_default_major', "1");
  } else {
    &SetPageCache('diff_default_major', &GetKeptDiff($new, $oldMajor, 0));
  }
  if ($newAuthor) {
    &SetPageCache('diff_default_author', "1");
  } elsif ($oldMajor == $oldAuthor) {
    &SetPageCache('diff_default_author', "2");
  } else {
    &SetPageCache('diff_default_author', &GetKeptDiff($new, $oldAuthor, 0));
  }
}

# Translation note: the email messages are still sent in English
# Send an email message.
sub SendEmail {
  my ($to, $from, $reply, $subject, $message) = @_;

  # sendmail options:
  #    -odq : send mail to queue (i.e. later when convenient)
  #    -oi  : do not wait for "." line to exit
  #    -t   : headers determine recipient.
  open (SENDMAIL, "| $SendMail -oi -t ") or die "Can't send email: $!\n";
  print SENDMAIL <<"EOF";
From: $from
To: $to
Reply-to: $reply
Subject: $subject\n
$message
EOF
  close(SENDMAIL) or warn "sendmail didn't close nicely";
}

## Email folks who want to know a note that a page has been modified. - JimM.
sub EmailNotify {
  local $/ = "\n";   # don't slurp whole files in this sub.

  if ($EmailNotify) {
    my ($id, $user) = @_;
    if ($user) {
      $user = " by $user";
    }
    my $address;
    return  if (!-f $EmailFile);  # No notifications yet
    open(EMAIL, $EmailFile)
      or die "Can't open $EmailFile: $!\n";
    $address = join ",", <EMAIL>;
    $address =~ s/\n//g;
    close(EMAIL);
    my $home_url = $q->url();
    my $page_url = $home_url . &ScriptLinkChar() . &UriEscape($id);
    my $pref_url = $home_url . &ScriptLinkChar() . "action=editprefs";
    my $editors_summary = $q->param("summary");
    if (($editors_summary eq "*") or ($editors_summary eq "")){
      $editors_summary = "";
    }
    else {
      $editors_summary = "\n Summary: $editors_summary";
    }
    my $content = <<"END_MAIL_CONTENT";

 The $SiteName page $id at
   $page_url
 has been changed$user to revision $Page{revision}. $editors_summary

 (Replying to this notification will
  send email to the entire mailing list,
  so only do that if you mean to.

  To remove yourself from this list, visit
  $pref_url .)
END_MAIL_CONTENT
    my $subject = "The $id page at $SiteName has been changed.";
    # I'm setting the "reply-to" field to be the same as the "to:" field
    # which seems appropriate for a mailing list, especially since the
    # $EmailFrom string needn't be a real email address.
    &SendEmail($address, $EmailFrom, $address, $subject, $content);
  }
}

sub SearchTitleAndBody {
  my ($string) = @_;
  my ($name, $freeName, @found);

  foreach $name (&AllPagesList()) {
    &OpenPage($name);
    &OpenDefaultText();
    if (($Text{'text'} =~ /$string/i) || ($name =~ /$string/i)) {
      push(@found, $name);
    } elsif ($FreeLinks) {
      if ($name =~ m/_/) {
        $freeName = $name;
        $freeName =~ s/_/ /g;
        if ($freeName =~ /$string/i) {
          push(@found, $name);
        }
      } elsif ($string =~ m/ /) {
        $freeName = $string;
        $freeName =~ s/ /_/g;
        if ($Text{'text'} =~ /$freeName/i) {
          push(@found, $name);
        }
      }
    }
  }
  return @found;
}

sub SearchBody {
  my ($string) = @_;
  my ($name, @found);

  foreach $name (&AllPagesList()) {
    &OpenPage($name);
    &OpenDefaultText();
    if ($Text{'text'} =~ /$string/i){
      push(@found, $name);
    }
  }
  return @found;
}

sub UnlinkHtmlCache {
  my ($id) = @_;
  my $idFile;

  $idFile = &GetHtmlCacheFile($id);
  if (-f $idFile) {
    unlink($idFile);
  }
}

sub NewPageCacheClear {
  my ($id) = @_;
  my $name;

  return if (!$UseCache);
  $id =~ s|.+/|/|;  # If subpage, search for just the subpage
  # The following code used to search the body for the $id
  foreach $name (&AllPagesList()) {  # Remove all to be safe
    &UnlinkHtmlCache($name);
  }
}

# Note: all diff and recent-list operations should be done within locks.
sub DoUnlock {
  my $LockMessage = T('Normal Unlock.');

  print &GetHeader('', T('Removing edit lock'), '');
  print '<p>', T('This operation may take several seconds...'), "\n";
  if (&ForceReleaseLock('main')) {
    $LockMessage = T('Forced Unlock.');
  }
  &ForceReleaseLock('cache');
  &ForceReleaseLock('diff');
  &ForceReleaseLock('index');
  print "<br><h2>$LockMessage</h2>";
  print &GetCommonFooter();
}

# Note: all diff and recent-list operations should be done within locks.
sub WriteRcLog {
  my ($id, $summary, $isEdit, $editTime, $revision, $name, $rhost) = @_;
  my ($extraTemp, %extra);

  %extra = ();
  $extra{'id'} = $UserID          if ($UserID > 0);
  $extra{'name'} = $name          if ($name ne "");
  $extra{'revision'} = $revision  if ($revision ne "");
  $extraTemp = join($FS2, %extra);
  # The two fields at the end of a line are kind and extension-hash
  my $rc_line = join($FS3, $editTime, $id, $summary,
                     $isEdit, $rhost, "0", $extraTemp);
  if (!open(OUT, ">>$RcFile")) {
    die(Ts('%s log error:', $RCName) . " $!");
  }
  print OUT  $rc_line . "\n";
  close(OUT);
}

sub WriteDiff {
  my ($id, $editTime, $diffString) = @_;

  open (OUT, ">>$DataDir/diff_log") or die(T('can not write diff_log'));
  print OUT  "------\n" . $id . "|" . $editTime . "\n";
  print OUT  $diffString;
  close(OUT);
}

# Actions are vetoable if someone edits the page before
# the keep expiry time. For example, page deletion. If
# no one edits the page by the time the keep expiry time
# elapses, then no one has vetoed the last action, and the
# action is accepted.
# See http://www.usemod.com/cgi-bin/mb.pl?PageDeletion
sub ProcessVetos {
  my ($expirets);

  $expirets = $Now - ($KeepDays * 24 * 60 * 60);
  return (0, T('(done)'))  unless $Page{'ts'} < $expirets;
  if ($DeletedPage && $Text{'text'} =~ /^\s*$DeletedPage\W*?(\n|$)/o) {
    &DeletePage($OpenPageName, 1, 1);
    return (1, T('(deleted)'));
  }
  if ($ReplaceFile && $Text{'text'} =~ /^\s*$ReplaceFile\:\s*(\S+)/o) {
    my $fname = $1;
    # Only replace an allowed, existing file.
    if ((grep {$_ eq $fname} @ReplaceableFiles) && -e $fname) {
       if ($Text{'text'} =~ /.*<pre>.*?\n(.*?)\s*<\/pre>/ims)
       {
         my $string = $1;
         $string =~ s/\r\n/\n/gms;
         open (OUT, ">$fname") or return 0;
         print OUT $string;
         close OUT;
         return (0, T('(replaced)'));
      }
    }
  }
  return (0, T('(done)'));
}

sub DoMaintain {
  my ($name, $fname, $data, $message, $status);
  print &GetHeader('', T('Maintenance on all pages'), '');
  print "<br>";
  $fname = "$DataDir/maintain";
  if (!&UserIsAdmin()) {
    if ((-f $fname) && ((-M $fname) < 0.5)) {
      print T('Maintenance not done.'), ' ';
      print T('(Maintenance can only be done once every 12 hours.)');
      print ' ', T('Remove the "maintain" file or wait.');
      print &GetCommonFooter();
      return;
    }
  }
  &RequestLock() or die(T('Could not get maintain-lock'));
  foreach $name (&AllPagesList()) {
    &OpenPage($name);
    &OpenDefaultText();
    ($status, $message) = &ProcessVetos();
    &ExpireKeepFile() unless $status;
    print ".... "  if ($name =~ m|/|);
    print &GetPageLink($name);
    print " $message<br>\n";
  }
  &WriteStringToFile($fname, Ts('Maintenance done at %s', &TimeToText($Now)));
  &ReleaseLock();
  # Do any rename/deletion commands
  # (Must be outside lock because it will grab its own lock)
  $fname = "$DataDir/editlinks";
  if (-f $fname) {
    $data = &ReadFileOrDie($fname);
    print '<hr>', T('Processing rename/delete commands:'), "<br>\n";
    &UpdateLinksList($data, 1, 1);  # Always update RC and links
    unlink("$fname.old");
    rename($fname, "$fname.old");
  }
  if ($MaintTrimRc) {
    &RequestLock() or die(T('Could not get lock for RC maintenance'));
    $status = &TrimRc();  # Consider error messages?
    &ReleaseLock();
  }
  print &GetCommonFooter();
}

# Must be called within a lock.
# Thanks to Alex Schroeder for original code
sub TrimRc {
  my (@rc, @temp, $starttime, $days, $status, $data, $i, $ts);

  # Determine the number of days to go back
  $days = 0;
  foreach (@RcDays) {
    $days = $_  if $_ > $days;
  }
  $starttime = $Now - $days * 24 * 60 * 60;
  return 1  if (!-f $RcFile);  # No work if no file exists
  ($status, $data) = &ReadFile($RcFile);
  if (!$status) {
    print '<p><strong>' . Ts('Could not open %s log file', $RCName)
          . ":</strong> $RcFile<p>"
          . T('Error was') . ":\n<pre>$!</" . "pre>\n" . '<p>';
    return 0;
  }
  # Move the old stuff from rc to temp
  @rc = split(/\n/, $data);
  for ($i = 0; $i < @rc; $i++) {
    ($ts) = split(/$FS3/, $rc[$i]);
    last  if ($ts >= $starttime);
  }
  return 1  if ($i < 1);  # No lines to move from new to old
  @temp = splice(@rc, 0, $i);
  # Write new files and backups
  if (!open(OUT, ">>$RcOldFile")) {
    print '<p><strong>' . Ts('Could not open %s log file', $RCName)
          . ":</strong> $RcOldFile<p>"
          . T('Error was') . ":\n<pre>$!</" . "pre>\n" . '<p>';
    return 0;
  }
  print OUT  join("\n", @temp) . "\n";
  close(OUT);
  &WriteStringToFile($RcFile . '.old', $data);
  $data = join("\n", @rc);
  $data .= "\n"  if ($data ne '');  # If no entries, don't add blank line
  &WriteStringToFile($RcFile, $data);
  return 1;
}

sub DoMaintainRc {
  print &GetHeader('', T('Maintaining RC log'), '');
  return  if (!&UserIsAdminOrError());
  &RequestLock() or die(T('Could not get lock for RC maintenance'));
  if (&TrimRc()) {
    print '<br>' . T('RC maintenance done.') . '<br>';
  } else {
    print '<br>' . T('RC maintenance not done.') . '<br>';
  }
  &ReleaseLock();
  print &GetCommonFooter();
}

sub UserIsEditorOrError {
  if (!&UserIsEditor()) {
    print '<p>', T('This operation is restricted to site editors only...');
    print &GetCommonFooter();
    return 0;
  }
  return 1;
}

sub UserIsAdminOrError {
  if (!&UserIsAdmin()) {
    print '<p>', T('This operation is restricted to administrators only...');
    print &GetCommonFooter();
    return 0;
  }
  return 1;
}

sub DoEditLock {
  my ($fname);

  print &GetHeader('', T('Set or Remove global edit lock'), '');
  return  if (!&UserIsAdminOrError());
  $fname = "$DataDir/noedit";
  if (&GetParam("set", 1)) {
    &WriteStringToFile($fname, "editing locked.");
  } else {
    unlink($fname);
  }
  if (-f $fname) {
    print '<p>', T('Edit lock created.'), '<br>';
  } else {
    print '<p>', T('Edit lock removed.'), '<br>';
  }
  print &GetCommonFooter();
}

sub DoPageLock {
  my ($fname, $id);

  print &GetHeader('', T('Set or Remove page edit lock'), '');
  # Consider allowing page lock/unlock at editor level?
  return  if (!&UserIsAdminOrError());
  $id = &GetParam("id", "");
  if ($id eq "") {
    print '<p>', T('Missing page id to lock/unlock...');
    return;
  }
  return  if (!&ValidIdOrDie($id));       # Consider nicer error?
  $fname = &GetLockedPageFile($id);
  if (&GetParam("set", 1)) {
    &WriteStringToFile($fname, "editing locked.");
  } else {
    unlink($fname);
  }
  if (-f $fname) {
    print '<p>', Ts('Lock for %s created.', $id), '<br>';
  } else {
    print '<p>', Ts('Lock for %s removed.', $id), '<br>';
  }
  print &GetCommonFooter();
}

sub DoEditBanned {
  my ($banList, $status);

  print &GetHeader('', T('Editing Banned list'), '');
  return  if (!&UserIsAdminOrError());
  ($status, $banList) = &ReadFile("$DataDir/banlist");
  $banList = ""  if (!$status);
  print &GetFormStart();
  print GetHiddenValue("edit_ban", 1), "\n";
  print "<b>Banned IP/network/host list:</b><br>\n";
  print "<p>Each entry is either a commented line (starting with #), ",
        "or a Perl regular expression (matching either an IP address or ",
        "a hostname).  <b>Note:</b> To test the ban on yourself, you must ",
        "give up your admin access (remove password in Preferences).";
  print "<p>Example:<br>",
        "# blocks hosts ending with .foocorp.com<br>",
        "\\.foocorp\\.com\$<br>",
        "# blocks exact IP address<br>",
        "^123\\.21\\.3\\.9\$<br>",
        "# blocks whole 123.21.3.* IP network<br>",
        "^123\\.21\\.3\\.\\d+\$<p>";
  print &GetTextArea('banlist', $banList, 12, 50);
  print "<br>", $q->submit(-name=>'Save'), "\n";
  print $q->endform;
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetGotoBar('');
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub DoUpdateBanned {
  my ($newList, $fname);

  print &GetHeader('', T('Updating Banned list'), '');
  return  if (!&UserIsAdminOrError());
  $fname = "$DataDir/banlist";
  $newList = &GetParam("banlist", "#Empty file");
  if ($newList eq "") {
    print "<p>", T('Empty banned list or error.');
    print "<p>", T('Resubmit with at least one space character to remove.');
  } elsif ($newList =~ /^\s*$/s) {
    unlink($fname);
    print "<p>", T('Removed banned list');
  } else {
    &WriteStringToFile($fname, $newList);
    print "<p>", T('Updated banned list');
  }
  print &GetCommonFooter();
}

# ==== Editing/Deleting pages and links ====
sub DoEditLinks {
  print &GetHeader('', T('Editing Links'), '');
  if ($AdminDelete) {
    return  if (!&UserIsAdminOrError());
  } else {
    return  if (!&UserIsEditorOrError());
  }
  print &GetFormStart();
  print GetHiddenValue("edit_links", 1), "\n";
  print "<b>Editing/Deleting page titles:</b><br>\n";
  print "<p>Enter one command on each line.  Commands are:<br>",
        "<tt>!PageName</tt> -- deletes the page called PageName<br>\n",
        "<tt>=OldPageName=NewPageName</tt> -- Renames OldPageName ",
        "to NewPageName and updates links to OldPageName.<br>\n",
        "<tt>|OldPageName|NewPageName</tt> -- Changes links to OldPageName ",
        "to NewPageName.",
        " (Used to rename links to non-existing pages.)<br>\n",
        "<b>Note: page names are case-sensitive!</b>\n";
  print &GetTextArea('commandlist', "", 12, 50);
  print $q->checkbox(-name=>"p_changerc", -override=>1, -checked=>1,
                      -label=>"Edit $RCName");
  print "<br>\n";
  print $q->checkbox(-name=>"p_changetext", -override=>1, -checked=>1,
                      -label=>"Substitute text for rename");
  print "<br>", $q->submit(-name=>'Edit'), "\n";
  print $q->endform;
  if (!&GetParam('embed', $EmbedWiki)) {
    print '<div class=wikifooter>';
    print "<hr class=wikilinefooter>\n";
    print &GetGotoBar('');
    print '</div>';
  }
  print &GetMinimumFooter();
}

sub UpdateLinksList {
  my ($commandList, $doRC, $doText) = @_;

  if ($doText) {
    &BuildLinkIndex();
  }
  &RequestLock() or die T('UpdateLinksList could not get main lock');
  unlink($IndexFile)  if ($UseIndex);
  foreach (split(/\n/, $commandList)) {
    s/\s+$//g;
    next  if (!(/^[=!|]/));  # Only valid commands.
    print "Processing $_<br>\n";
    if (/^\!(.+)/) {
      &DeletePage($1, $doRC, $doText);
    } elsif (/^\=(?:\[\[)?([^]=]+)(?:\]\])?\=(?:\[\[)?([^]=]+)(?:\]\])?/) {
      &RenamePage($1, $2, $doRC, $doText);
    } elsif (/^\|(?:\[\[)?([^]|]+)(?:\]\])?\|(?:\[\[)?([^]|]+)(?:\]\])?/) {
      &RenameTextLinks($1, $2);
    }
  }
  &NewPageCacheClear(".");  # Clear cache (needs testing?)
  unlink($IndexFile)  if ($UseIndex);
  &ReleaseLock();
}

sub BuildLinkIndex {
  my (@pglist, $page, @links, $link, %seen);

  @pglist = &AllPagesList();
  %LinkIndex = ();
  foreach $page (@pglist) {
    &BuildLinkIndexPage($page);
  }
}

sub BuildLinkIndexPage {
  my ($page) = @_;
  my (@links, $link, %seen);

  @links = &GetPageLinks($page, 1, 0, 0);
  %seen = ();
  foreach $link (@links) {
    if (defined($LinkIndex{$link})) {
      if (!$seen{$link}) {
        $LinkIndex{$link} .= " " . $page;
      }
    } else {
      $LinkIndex{$link} .= " " . $page;
    }
    $seen{$link} = 1;
  }
}

sub DoUpdateLinks {
  my ($commandList, $doRC, $doText);

  print &GetHeader('', T('Updating Links'), '');
  if ($AdminDelete) {
    return  if (!&UserIsAdminOrError());
  } else {
    return  if (!&UserIsEditorOrError());
  }
  $commandList = &GetParam("commandlist", "");
  $doRC   = &GetParam("p_changerc", "0");
  $doRC   = 1  if ($doRC eq "on");
  $doText = &GetParam("p_changetext", "0");
  $doText = 1  if ($doText eq "on");
  if ($commandList eq "") {
    print "<p>", T('Empty command list or error.');
  } else {
    &UpdateLinksList($commandList, $doRC, $doText);
    print "<p>", T('Finished command list.');
  }
  print &GetCommonFooter();
}

sub EditRecentChanges {
  my ($action, $old, $new) = @_;

  &EditRecentChangesFile($RcFile,    $action, $old, $new, 1);
  &EditRecentChangesFile($RcOldFile, $action, $old, $new, 0);
}

sub EditRecentChangesFile {
  my ($fname, $action, $old, $new, $printError) = @_;
  my ($status, $fileData, $errorText, $rcline, @rclist);
  my ($outrc, $ts, $page, $junk);

  ($status, $fileData) = &ReadFile($fname);
  if (!$status) {
    # Save error text if needed.
    $errorText = "<p><strong>"
                 . Ts('Could not open %s log file:', $RCName)
                 . "</strong> $fname"
                 . "<p>" . T('Error was:') . "\n<pre>$!</pre>\n";
    print $errorText  if ($printError);
    return;
  }
  $outrc = "";
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
  &WriteStringToFile($fname . ".old", $fileData);  # Backup copy
  &WriteStringToFile($fname, $outrc);
}

# Delete and rename must be done inside locks.
sub DeletePage {
  my ($page, $doRC, $doText) = @_;
  my ($fname, $status);

  $page =~ s/ /_/g;
  $page =~ s/\[+//;
  $page =~ s/\]+//;
  $status = &ValidId($page);
  if ($status ne "") {
    print Tss('Delete-Page: page %1 is invalid, error is: %2', $page, $status)
          . "<br>\n";
    return;
  }
  $fname = &GetPageFile($page);
  unlink($fname)  if (-f $fname);
  $fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
  unlink($fname)  if (-f $fname);
  unlink($IndexFile)  if ($UseIndex);
  &EditRecentChanges(1, $page, "")  if ($doRC);  # Delete page
  # Currently don't do anything with page text
}

# Given text, returns substituted text
sub SubstituteTextLinks {
  my ($old, $new, $text) = @_;

  # Much of this is taken from the common markup
  %SaveUrl = ();
  $SaveUrlIndex = 0;
  $text =~ s/$FS(\d)/$1/g;              # Remove separators (paranoia)
  if ($RawHtml) {
    $text =~ s/(<html>((.|\n)*?)<\/html>)/&StoreRaw($1)/ige;
  }
  $text =~ s/(<pre>((.|\n)*?)<\/pre>)/&StoreRaw($1)/ige;
  $text =~ s/(<code>((.|\n)*?)<\/code>)/&StoreRaw($1)/ige;
  $text =~ s/(<nowiki>((.|\n)*?)<\/nowiki>)/&StoreRaw($1)/ige;
  if ($FreeLinks) {
    $text =~
     s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/&SubFreeLink($1,$2,$old,$new)/geo;
    $text =~ s/\[\[$FreeLinkPattern\]\]/&SubFreeLink($1,"",$old,$new)/geo;
  }
  if ($BracketText) {  # Links like [URL text of link]
    $text =~ s/(\[$UrlPattern\s+([^\]]+?)\])/&StoreRaw($1)/geo;
    $text =~ s/(\[$InterLinkPattern\s+([^\]]+?)\])/&StoreRaw($1)/geo;
  }
  $text =~ s/(\[?$UrlPattern\]?)/&StoreRaw($1)/geo;
  $text =~ s/(\[?$InterLinkPattern\]?)/&StoreRaw($1)/geo;
  if ($WikiLinks) {
    $text =~ s/$LinkPattern/&SubWikiLink($1, $old, $new)/geo;
  }
  # Thanks to David Claughton for the following fix
  1 while $text =~ s/$FS(\d+)$FS/$SaveUrl{$1}/ge;   # Restore saved text
  return $text;
}

sub SubFreeLink {
  my ($link, $name, $old, $new) = @_;
  my ($oldlink);

  $oldlink = $link;
  $link =~ s/^\s+//;
  $link =~ s/\s+$//;
  if (($link eq $old) || (&FreeToNormal($old) eq &FreeToNormal($link))) {
    $link = $new;
  } else {
    $link = $oldlink;  # Preserve spaces if no match
  }
  $link = "[[$link";
  if ($name ne "") {
    $link .= "|$name";
  }
  $link .= "]]";
  return &StoreRaw($link);
}

sub SubWikiLink {
  my ($link, $old, $new) = @_;
  my ($newBracket);

  $newBracket = 0;
  if ($link eq $old) {
    $link = $new;
    if (!($new =~ /^$LinkPattern$/)) {
      $link = "[[$link]]";
    }
  }
  return &StoreRaw($link);
}

# Rename is mostly copied from expire
sub RenameKeepText {
  my ($page, $old, $new) = @_;
  my ($fname, $status, $data, @kplist, %tempSection, $changed);
  my ($sectName, $newText);

  $fname = $KeepDir . "/" . &GetPageDirectory($page) .  "/$page.kp";
  return  if (!(-f $fname));
  ($status, $data) = &ReadFile($fname);
  return  if (!$status);
  @kplist = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  return  if (length(@kplist) < 1);  # Also empty
  shift(@kplist)  if ($kplist[0] eq "");  # First can be empty
  return  if (length(@kplist) < 1);  # Also empty
  %tempSection = split(/$FS2/, $kplist[0], -1);
  if (!defined($tempSection{'keepts'})) {
    return;
  }
  # First pass: optimize for nothing changed
  $changed = 0;
  foreach (@kplist) {
    %tempSection = split(/$FS2/, $_, -1);
    $sectName = $tempSection{'name'};
    if ($sectName =~ /^(text_)/) {
      %Text = split(/$FS3/, $tempSection{'data'}, -1);
      $newText = &SubstituteTextLinks($old, $new, $Text{'text'});
      $changed = 1  if ($Text{'text'} ne $newText);
    }
  }
  return  if (!$changed);  # No sections changed
  open (OUT, ">$fname") or return;
  foreach (@kplist) {
    %tempSection = split(/$FS2/, $_, -1);
    $sectName = $tempSection{'name'};
    if ($sectName =~ /^(text_)/) {
      %Text = split(/$FS3/, $tempSection{'data'}, -1);
      $newText = &SubstituteTextLinks($old, $new, $Text{'text'});
      $Text{'text'} = $newText;
      $tempSection{'data'} = join($FS3, %Text);
      print OUT $FS1, join($FS2, %tempSection);
    } else {
      print OUT $FS1, $_;
    }
  }
  close(OUT);
}

sub RenameTextLinks {
  my ($old, $new) = @_;
  my ($changed, $file, $page, $section, $oldText, $newText, $status);
  my ($oldCanonical, @pageList);

  $old =~ s/ /_/g;
  $oldCanonical = &FreeToNormal($old);
  $new =~ s/ /_/g;
  $status = &ValidId($old);
  if ($status ne "") {
    print Tss('Rename-Text: old page %1 is invalid, error is: %2', $old, $status)
          . "<br>\n";
    return;
  }
  $status = &ValidId($new);
  if ($status ne "") {
    print Tss('Rename-Text: new page %1 is invalid, error is: %2', $new, $status)
          . "<br>\n";
    return;
  }
  $old =~ s/_/ /g;
  $new =~ s/_/ /g;
  # Note: the LinkIndex must be built prior to this routine
  return  if (!defined($LinkIndex{$oldCanonical}));
  @pageList = split(' ', $LinkIndex{$oldCanonical});
  foreach $page (@pageList) {
    $changed = 0;
    &OpenPage($page);
    foreach $section (keys %Page) {
      if ($section =~ /^text_/) {
        &OpenSection($section);
        %Text = split(/$FS3/, $Section{'data'}, -1);
        $oldText = $Text{'text'};
        $newText = &SubstituteTextLinks($old, $new, $oldText);
        if ($oldText ne $newText) {
          $Text{'text'} = $newText;
          $Section{'data'} = join($FS3, %Text);
          $Page{$section} = join($FS2, %Section);
          $changed = 1;
        }
      } elsif ($section =~ /^cache_diff/) {
        $oldText = $Page{$section};
        $newText = &SubstituteTextLinks($old, $new, $oldText);
        if ($oldText ne $newText) {
          $Page{$section} = $newText;
          $changed = 1;
        }
      }
      # Add other text-sections (categories) here
    }
    if ($changed) {
      $file = &GetPageFile($page);
      &WriteStringToFile($file, join($FS1, %Page));
    }
    &RenameKeepText($page, $old, $new);
  }
}

sub RenamePage {
  my ($old, $new, $doRC, $doText) = @_;
  my ($oldfname, $newfname, $oldkeep, $newkeep, $status);

  $old =~ s/ /_/g;
  $new = &FreeToNormal($new);
  $status = &ValidId($old);
  if ($status ne "") {
    print Tss('Rename: old page %1 is invalid, error is: %2', $old, $status)
          . "<br>\n";
    return;
  }
  $status = &ValidId($new);
  if ($status ne "") {
    print Tss('Rename: new page %1 is invalid, error is: %2', $new, $status)
          . "<br>\n";
    return;
  }
  $newfname = &GetPageFile($new);
  if (-f $newfname) {
    print Ts('Rename: new page %s already exists--not renamed.', $new)
          . "<br>\n";
    return;
  }
  $oldfname = &GetPageFile($old);
  if (!(-f $oldfname)) {
    print Ts('Rename: old page %s does not exist--nothing done.', $old)
          . "<br>\n";
    return;
  }
  &CreatePageDir($PageDir, $new);  # It might not exist yet
  rename($oldfname, $newfname);
  &CreatePageDir($KeepDir, $new);
  $oldkeep = $KeepDir . "/" . &GetPageDirectory($old) .  "/$old.kp";
  $newkeep = $KeepDir . "/" . &GetPageDirectory($new) .  "/$new.kp";
  unlink($newkeep)  if (-f $newkeep);  # Clean up if needed.
  rename($oldkeep,  $newkeep);
  unlink($IndexFile)  if ($UseIndex);
  &EditRecentChanges(2, $old, $new)  if ($doRC);
  if ($doText) {
    &BuildLinkIndexPage($new);  # Keep index up-to-date
    &RenameTextLinks($old, $new);
  }
}

sub DoShowVersion {
  print &GetHeader('', T('Displaying Wiki Version'), '');
  print "<p>UseModWiki version 1.0.4</p>\n";
  print &GetCommonFooter();
}

# Thanks to Phillip Riley for original code
sub DoDeletePage {
  my ($id) = @_;

  return  if (!&ValidIdOrDie($id));
  print &GetHeader('', Ts('Delete %s', $id), '');
  return  if (!&UserIsAdminOrError());
  if ($ConfirmDel && !&GetParam('confirm', 0)) {
    print '<p>';
    print Ts('Confirm deletion of %s by following this link:', $id);
    print '<br>' . &GetDeleteLink($id, T('Confirm Delete'), 1);
    print '</p>';
    print &GetCommonFooter();
    return;
  }
  print '<p>';
  if ($id eq $HomePage)  {
    print Ts('%s can not be deleted.', $HomePage);
  } else {
    if (-f &GetLockedPageFile($id))   {
      print Ts('%s can not be deleted because it is locked.', $id);
    } else {
      # Must lock because of RC-editing
      &RequestLock() or die(T('Could not get editing lock'));
      DeletePage($id, 1, 1);
      &ReleaseLock();
      print Ts('%s has been deleted.', $id);
    }
  }
  print '</p>';
  print &GetCommonFooter();
}

# Thanks to Ross Kowalski and Iliyan Jeliazkov for original uploading code
sub DoUpload {
  print &GetHeader('', T('File Upload Page'), '');
  if (!$AllUpload) {
    return if (!&UserIsEditorOrError());
  }
  print '<p>' . Ts('The current upload size limit is %s.', $MaxPost) . ' '
        . Ts('Change the %s variable to increase this limit.', '$MaxPost');
  print '</p><br>';
  print '<FORM METHOD="post" ACTION="' . $ScriptName
        . '" ENCTYPE="multipart/form-data">';
  print '<input type="hidden" name="upload" value="1" />';
  print T('File to Upload:'), ' <INPUT TYPE="file" NAME="file"><br><BR>';
  print '<INPUT TYPE="submit" NAME="Submit" VALUE="', T('Upload'), '">';
  print '</FORM>';
  print &GetCommonFooter(); 
}

sub SaveUpload {
  my ($filename, $printFilename, $uploadFilehandle);
 
  print &GetHeader('', T('Upload Finished'), '');
  if (!$AllUpload) {
    return  if (!&UserIsEditorOrError());
  }
  $UploadDir .= '/'  if (substr($UploadDir, -1, 1) ne '/');  # End with /
  $UploadUrl .= '/'  if (substr($UploadUrl, -1, 1) ne '/');  # End with /
  $filename = $q->param('file');
  $filename =~ s/.*[\/\\](.*)/$1/;  # Only name after last \ or /
  $uploadFilehandle = $q->upload('file');
  open UPLOADFILE, ">$UploadDir$filename";
  binmode UPLOADFILE;
  while (<$uploadFilehandle>) { print UPLOADFILE; }
  close UPLOADFILE;
  print T('The wiki link to your file is:') . "\n<br><BR>";
  $printFilename = $filename;
  $printFilename =~ s/ /\%20/g;  # Replace spaces with escaped spaces
  print "upload:" . $printFilename . "<BR><BR>\n";
  if ($filename =~ /$ImageExtensions$/i) {
    print '<HR><img src="' . $UploadUrl . $filename . '">' . "\n";
  }
  print &GetCommonFooter();
}

sub ConvertFsFile {
  my ($oldFS, $newFS, $fname) = @_;
  my ($oldData, $newData, $status);

  return  if (!-f $fname);  # Convert only existing regular files
  ($status, $oldData) = &ReadFile($fname);
  if (!$status) {
    print '<br><strong>' . Ts('Could not open file %s', $fname)
          . ':</strong>' . T('Error was') . ":\n<pre>$!</pre>\n" . '<br>';
    return;
  }
  $newData = $oldData;
  $newData =~ s/$oldFS(\d)/$newFS . $1/ge;
  return  if ($oldData eq $newData);  # Do not write if the same
  &WriteStringToFile($fname, $newData);
# print $fname . '<br>';    # progress report
}

# Converts up to 3 dirs deep  (like page/A/Apple/subpage.db)
# Note that top level directory (page/keep/user) contains only dirs
sub ConvertFsDir {
  my ($oldFS, $newFS, $topDir) = @_;
  my (@dirs, @files, @subFiles, $dir, $file, $subFile, $fname, $subFname);

  opendir(DIRLIST, $topDir);
  @dirs = readdir(DIRLIST);
  closedir(DIRLIST);
  @dirs = sort(@dirs);
  foreach $dir (@dirs) {
    next  if (substr($dir, 0, 1) eq '.');   # No ., .., or .dirs
    next  if (!-d "$topDir/$dir");          # Top level directories only
    next  if (-f "$topDir/$dir.cvt");       # Skip if already converted
    opendir(DIRLIST, "$topDir/$dir");
    @files = readdir(DIRLIST);
    closedir(DIRLIST);
    foreach $file (@files) {
      next  if (($file eq '.') || ($file eq '..'));
      $fname = "$topDir/$dir/$file";
      if (-f $fname) {
#       print $fname . '<br>';   # progress
        &ConvertFsFile($oldFS, $newFS, $fname);
      } elsif (-d $fname) {
        opendir(DIRLIST, $fname);
        @subFiles = readdir(DIRLIST);
        closedir(DIRLIST);
        foreach $subFile (@subFiles) {
          next  if (($subFile eq '.') || ($subFile eq '..'));
          $subFname = "$fname/$subFile";
          if (-f $subFname) {
#           print $subFname . '<br>';   # progress
            &ConvertFsFile($oldFS, $newFS, $subFname);
          }
        }
      }
    }
  &WriteStringToFile("$topDir/$dir.cvt", 'converted');
  }
}

sub ConvertFsCleanup {
  my ($topDir) = @_;
  my (@dirs, $dir);

  opendir(DIRLIST, $topDir);
  @dirs = readdir(DIRLIST);
  closedir(DIRLIST);
  foreach $dir (@dirs) {
    next  if (substr($dir, 0, 1) eq '.');   # No ., .., or .dirs
    next  if (!-f "$topDir/$dir");          # Remove only files...
    next  unless ($dir =~ m/\.cvt$/);       # ...that end with .cvt
    unlink "$topDir/$dir";
  }
}

sub DoConvert {
  my $oldFS = "\xb3";
  my $newFS = "\x1e\xff\xfe\x1e";

  print &GetHeader('', T('Convert wiki DB'), '');
  return if (!&UserIsAdminOrError());
  if ($FS ne $newFS) {
    print Ts('You must change the %s option before converting the wiki DB.',
             '$NewFS') . '<br>';
    return;
  }
  &WriteStringToFile("$DataDir/noedit", 'editing locked.');
  print T('Wiki DB locked for conversion.') . '<br>';
  print T('Converting Wiki DB...') . '<br>';
  &ConvertFsFile($oldFS, $newFS, "$DataDir/rclog");
  &ConvertFsFile($oldFS, $newFS, "$DataDir/rclog.old");
  &ConvertFsFile($oldFS, $newFS, "$DataDir/oldrclog");
  &ConvertFsFile($oldFS, $newFS, "$DataDir/oldrclog.old");
  &ConvertFsDir($oldFS, $newFS, $PageDir);
  &ConvertFsDir($oldFS, $newFS, $KeepDir);
  &ConvertFsDir($oldFS, $newFS, $UserDir);
  &ConvertFsCleanup($PageDir);
  &ConvertFsCleanup($KeepDir);
  &ConvertFsCleanup($UserDir);
  print T('Finished converting wiki DB.') . '<br>';
  print Ts('Remove file %s to unlock wiki for editing.', "$DataDir/noedit")
        . '<br>';
  print &GetCommonFooter();
}

# Remove user-id files if no useful preferences set
sub DoTrimUsers {
  my (%Data, $status, $data, $maxID, $id, $removed, $keep);
  my (@dirs, @files, $dir, $file, $item);

  print &GetHeader('', T('Trim wiki users'), '');
  return if (!&UserIsAdminOrError());
  $removed = 0;
  $maxID = 1001;
  opendir(DIRLIST, $UserDir);
  @dirs = readdir(DIRLIST);
  closedir(DIRLIST);
  foreach $dir (@dirs) {
    next  if (substr($dir, 0, 1) eq '.');   # No ., .., or .dirs
    next  if (!-d "$UserDir/$dir");         # Top level directories only
    opendir(DIRLIST, "$UserDir/$dir");
    @files = readdir(DIRLIST);
    closedir(DIRLIST);
    foreach $file (@files) {
      if ($file =~ m/(\d+).db/) {  # Only numeric ID files
        $id = $1;
        $maxID = $id  if ($id > $maxID);
        %Data = ();
        ($status, $data) = &ReadFile("$UserDir/$dir/$file");
        if ($status) {
          %Data = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
          $keep = 0;
          foreach $item (qw(username password adminpw stylesheet)) {
            $keep = 1  if (defined($Data{$item}) && ($Data{$item} ne ''));
          }
          if (!$keep) {
            unlink "$UserDir/$dir/$file";
#           print "$UserDir/$dir/$file" . '<br>';  # progress
            $removed += 1;
          }
        }
      }
    }
  }
  print Ts('Removed %s files.', $removed) . '<br>';
  print Ts('Recommended $StartUID setting is %s.', $maxID + 100) . '<br>';
  print &GetCommonFooter();
}
#END_OF_OTHER_CODE

&DoWikiRequest()  if ($RunCGI && ($_ ne 'nocgi'));   # Do everything.
1; # In case we are loaded from elsewhere
# == End of UseModWiki script. ===========================================
