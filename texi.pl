#!/usr/bin/perl
# Texi $Id: texi.pl,v 1.3 2003/04/24 21:52:03 as Exp $
# Copyright (C) 2002, 2003  Alex Schroeder <alex@gnu.org>
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

use CGI qw/:standard/;
use CGI::Carp 'fatalsToBrowser';

$DataDir = '/home/alex/WWW/emacswiki/test' unless $DataDir;
$PageDir     = "$DataDir/page";     # Stores page data
$InterFile   = "$DataDir/intermap"; # Interwiki site->url map
$ConfigFile  = "$DataDir/config" unless $ConfigFile; # Config file with Perl code to execute

# Basics
$HomePage    = 'HomePage'; # Home page (change space to _)
$HttpCharset = 'ISO-8859-1'; # Charset for pages, eg. 'UTF-8'

# LinkPattern
$WikiLinks   = 1;   # 1 = LinkPattern is a link
$FreeLinks   = 1;   # 1 = [[some text]] is a link
$FreeUpper   = 1;   # 1 = forces free links to start with upper case
$SimpleLinks = 0;   # 1 = only letters in links, 0 = allow _ and numbers
$NonEnglish  = 0;   # 1 = non-ASCII link characters allowed
$BracketText = 1;   # 1 = [URL desc] uses a description for the URL
$BracketWiki = 0;   # 1 = [WikiLink desc] uses a desc for the local link
$HtmlLinks   = 0;   # 1 = <a href="foo">desc</a> is a link
$UseSubpage  = 0;   # 1 = PageName/SubPage is a link
$NetworkFile = 1;   # 1 = file: is a valid protocol for URLs

# TextFormattingRules
$HtmlTags    = 0;   # 1 = allow some 'unsafe' HTML tags
$RawHtml     = 0;   # 1 = allow <HTML> environment for raw HTML inclusion

# RecentChanges and KeptPages
$DeletedPage = "DeletedPage";   # Pages starting with this can be deleted
$RCName      = 'RecentChanges'; # Name of changes page (change space to _)

if (not @HtmlTags) { # don't set if set in the config file
  if ($HtmlTags) {
    # HTML tag lists, enabled if $HtmlTags is set.
    # Scripting is currently possible with these tags,
    # so they are *not* particularly 'safe'.
    # Tags that must be in <tag> ... </tag> pairs:
    @HtmlTags = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
                   em s strike strong tt var div center blockquote ol ul dl
                   table caption br p hr li dt dd tr td th);
  } else {
    @HtmlTags = qw(b i u em strong tt);
  }
}

%HtmlTagEquivalent = ('b' => 'b',
		      'i' => 'i',
		      'u' => 'i',
		      'em' => 'emph',
		      'strong' => 'strong',
		      'tt' => 'code',
		     );

# == You should not have to change anything below this line. ==

$IndentLimit = 20;                  # Maximum depth of nested lists

# == Config file ==

if (-f $ConfigFile) {
  do $ConfigFile;
}

# == Code ==

die "No HomePage set.\n" unless $HomePage;

$outdir = $DataDir unless $outdir;
$outname = 'wiki' unless $outname;
$outfile = $outdir . '/' . $outname;
$licensefile = '' unless $licensefile;
$intro = qq{\\input texinfo \@c -*-texinfo-*-
\@c %**start of header
\@setfilename $outname.info
\@settitle $HomePage
\@ifnottex
\@node Top, $HomePage, , (dir)
\@top $HomePage
\@end ifnottex
};

$q = new CGI;
$q->charset($HttpCharset) if $HttpCharset;
@ScriptPath = split('/', $q->script_name());
$ScriptName = pop(@ScriptPath);
$IndexInit = 0;
$InterSiteInit = 0;
%InterSite = ();
$OpenPageName = '';
@HtmlStack = ();

# Internal Variables

my (@pages, @orphans, @control, $current);
my (%file, %up, %down, %next, %prev, %type, %text, %refs, %menu);

charset($HttpCharset);

print header;
print start_html('Texinfo Creation');
print h1("Texinfo Creation");
print "<p>";

print "Starting<br>\n";
&process;
print "Gzipping<br>\n";
system("/bin/rm", "$outfile.texi.gz");
system("/bin/gzip", "$outfile.texi");
print "Done<br>\n";
print p("Download ", a({-href=>"/$outname.texi.gz"}, "$outname.texi.gz"));
print end_html;

# MAIN CODE

sub process {
  open(F,">$outfile.texi") or die "Can't create output file: $!";
  &readpages($PageDir);
  &InitLinkPatterns;
  &readtexts;
  print scalar(@pages) . " pages read<br>\n";
  &removedeletedpages;
  &removeredirects;
  print scalar(@pages) . " pages undeleted and not redirected<br>\n";
  &makechapters;
  &countorphans;
  &findremainingchildren;
  &countorphans;
  &findparents(0);
  &countorphans;
  &findparents(1);
  &countorphans;
  &removeorphans();
  &countwalkthrough;
  # &fixmenus;
  print F $intro;
  &printmastermenu();
  &printorphans;
  &printpages;
  &printfooter;
  close(F);
}

# testing

sub testpages {
  foreach my $p (@pages) {
    $s = length($text{$p});
    print "$p has $s bytes<br>\n";
  }
}

sub countorphans {
  my $count = 0;
  foreach my $page (@pages) {
    next if $type{$page};
    $count += 1;
  }
  print "$count/" . scalar(@pages) . " orphaned<br>\n";
}

sub countwalkthrough {
  print scalar(@pages) . " remaining<br>\n";
  my $count = &countwalk($HomePage);
  print "$count pages on the walkthrough<br>\n";
  foreach my $page (@pages) {
    if (!grep(/^$page$/, @control)) {
      print "$page is not part of the walkthroguh<br>\n";
      &printnode($page);
      &printnode($up{$page});
    } elsif (!$type{$page}) {
      print "$page on the walk-through has no type<br>\n";
    }
  }
  foreach my $page (@control) {
    if (!grep(/^$page$/, @pages)) {
      print "$page has suddenly appeared in the page list<br>\n";
    }
  }
}

sub countwalk {
  my $count = 0;
  my ($page) = @_;
  while ($page) {
    push(@control, $page);
    $count += 1;
    if ($down{$page}) {
      $count += &countwalk($down{$page});
    }
    last if $down{$page} and $next{$page} and $down{$page} eq $next{$page};
    $page = $next{$page};
  }
  return $count;
}

# writing texinfo

sub removeorphans {
  my @result;
  foreach my $page (@pages) {
    if ($type{$page}) {
      push(@result, $page);
    } else {
      push(@orphans, $page);
    }
  }
  @pages = @result;
}

sub removedeletedpages {
  my @result;
  foreach my $page (@pages) {
    push(@result, $page) unless $text{$page} =~ /^DeletedPage/;
  }
  @pages = @result;
}

sub removeredirects {
  my @result;
  foreach my $page (@pages) {
    push(@result, $page) unless $text{$page} =~ /^#REDIRECT/;
  }
  @pages = @result;
}

sub printpages {
  &printwalk($HomePage);
}

sub printwalk {
  my ($page) = @_;
  while ($page) {
    &printtitle($page);
    print F $text{$page};
    &printmenu($page);
    &printwalk($down{$page}) if ($down{$page});
    last if $down{$page} and $next{$page} and $down{$page} eq $next{$page};
    $page = $next{$page};
  }
}

sub printmenu {
  my ($page) = @_;
  return unless $menu{$page};
  my @menu = @{$menu{$page}};
  return unless scalar(@menu) > 0;
  # print "Menu: " . join(" ",@{$menu{$page}}) . "<br>\n";
  print F "\n\n\@menu\n";
  print F "Related:\n";
  foreach my $entry (@menu) {
    print F "* " . $entry . "::\n";
  }
  print F "\@end menu\n";
}

sub fixmenus {
  foreach my $page (@pages) {
    # print "\n$page<br>\n";
    next unless $menu{$page};
    # entries are the pages that have an up pointer to this page
    my @entries = @{$menu{$page}};
    my @used = ();
    # print "Menu: " . join(" ",@entries) . "<br>\n";
    my @lines = split(/\n/, $text{$page});
     # Identify the menus
    my ($start, $ismenu, $idx) = (0, 0, 0);
    while ($idx <= $#lines) {
      my $line = $lines[$idx];
      # determine start of a menu, check wether any of the entries
      # could be part of a menu, and when the end of a menu is
      # reached, go back and change it to a menu if such an entry was
      # found.
      if ($line =~ /^\@itemize/) {
	$start = $idx;
	$ismenu = 0;
      } elsif ($start and not $ismenu) {
	if ($line =~ /^\@item *($LinkPattern)/
	    and grep(/^$1$/,@entries)) {
	  $ismenu = 1;
	}
      } elsif ($line =~ /^\@end itemize/) {
	if ($ismenu) {
	  $lines[$start] = '@menu';
	  $lines[$idx] = '@end menu';
	  # go through all entries between start and current position
	  my $i = $start;
	  while ($i < $idx) {
	    my $l = $lines[$i];
	    if ($l =~ /^\@item *($LinkPattern)/
		and grep(/^$1$/,@entries)) {
	      $l =~ s/^\@item *($LinkPattern) *-* */* $1:: /;
	      push(@used,$1);
	      $lines[$i] = $l;
	    } elsif ($l =~ s/^\@item *//) {
	      $lines[$i] = $l;
	    }
	    $i++;
	  }
	}
	$start = 0;
	$ismenu = 0;
      }
      $idx++;
    }
    # print "Used: " . join(" ",@used) . "<br>\n";
    my @newmenu = ();
    foreach my $entry (@entries) {
      unless (grep(/^$entry$/,@used)) {
	push(@newmenu, $entry);
      }
    }
    # print "New: " . join(" ",@newmenu) . "<br>\n";
    @{$menu{$page}} = @newmenu;
    $text{$page} = join("\n",@lines);
  }
}

sub printnode {
  my ($page) = @_;
  my $n = $next{$page} || "";
  my $p = $prev{$page} || "";
  my $u = $up{$page} || "";
  # my $d = $down{$page} || "";
  # print "$page, $n, $p, $u, $d<br>\n";
  print F "\n\n";
  print F "\@node $page, $n, $p, $u\n";
  print F "\@cindex $page\n";
}

sub printtitle {
  my ($page) = @_;
  print F "\n";
  &printnode($page);
  print F "\@comment node-name, next, previous, up\n";
  print F "\@$type{$page} $page\n";
  print F "\n";
}

sub makechapters {
  my $old = $HomePage;
  $type{$HomePage} = 'unnumbered';
  $up{$HomePage} = 'Top';
  $prev{$HomePage} = 'Top';
  print "$HomePage is the main page<br>\n";
  foreach my $page (@{$refs{$HomePage}}) {
    print "Examining $page...<br>\n";
    if ($page =~ /^Category/
       and grep(/^$page$/,@pages)) {
      print "$page is a chapter<br>\n";
      $type{$page} = 'unnumbered';
      $up{$page} = $HomePage;
      $down{$HomePage} = $page unless ($down{$HomePage}); # only once!
      push(@{$menu{$HomePage}}, $page);
      $next{$old} = $page;
      $prev{$page} = $old;
      $old = $page;
      # &makechildren($page);
    }
  }
}

sub makechildren {
  my ($parent) = @_;
  my $old = $parent;
  foreach my $page (@{$refs{$parent}}) {
    next if $type{$page} or not grep(/^$page$/,@pages);
    # make sure backref exists
    if (grep(/^$parent$/,@{$refs{$page}})) {
      print "$page added under $parent<br>\n";
      # print "  it links to: " . join(" ",@{$refs{$page}}) . "<br>\n";
      $type{$page} = 'unnumberedsec';
      $up{$page} = $parent;
      $down{$parent} = $page unless ($down{$parent}); # only once!
      push(@{$menu{$parent}}, $page);
      $next{$old} = $page unless ($parent eq $old);
      $prev{$page} = $old;
      $old = $page;
    }
  }
}

sub findremainingchildren {
  foreach my $page (@pages) {
    &makechildren($page) if $type{$page} and not $down{$page};
  }
}

sub findparents {
  my ($force) = @_;
  foreach my $page (@pages) {
    if (not $type{$page} and $refs{$page}) {
      my @parents = @{$refs{$page}}; # any page pointed to might be a parent
      if (not $force) {
	@parents = grep(/^Category/,@parents); # if possible, use a category as parent
      }
      @parents = grep(!/^$page$/,@parents); # exclude self
      @parents = grep($type{$_},@parents); # only accept non-orphaned parents
      if (@parents) {
	my $parent = $parents[0];
	my $old = $down{$parent}; # find last child
	if ($old) {
	  $old = $next{$old} while ($next{$old});
	} else {
	  $old = $parent;
	}
	print "$page adopted under $parent<br>\n";
	$type{$page} = 'unnumbered';
	$up{$page} = $parent;
	$down{$parent} = $page unless ($down{$parent}); # only once!
	push(@{$menu{$parent}}, $page);
	$prev{$page} = $old;
	$next{$old} = $page unless ($next{$old}); # only once!
	&makechildren($page);
      }
    }
  }
}

sub printfooter {
  print F &readfile($licensefile);
  print F <<EOT;
\@node Index, , , Top
\@unnumbered Index
\@printindex cp
\@bye
EOT
}

sub printorphans {
  print F "\nThe following pages where not included:\n";
  foreach my $page (@orphans) {
    print F "$page\n";
  }
}

sub printmastermenu {
  print F '@menu' . "\n";
  print F "* " . $HomePage . "::\n";
  print F '@detailmenu' . "\n";
  foreach my $page (@pages) {
    next if ($page eq $HomePage);
    print F "* " . $page . "::\n";
  }
  print F "* GNU Free Documentation License::\n";
  print F "* Index::\n";
  print F '@end detailmenu' . "\n";
  print F '@end menu' . "\n";
}

# reading the page database

sub readpages {
  my ($parent) = @_;
  print "Starting with $parent...<br>\n";
  my @dirs = readdirectory($parent);
  foreach my $dir (@dirs) {
    next if $dir =~ /^\./ or ! -d "$parent/$dir";
    print "Reading $dir directory...<br>\n";
    my @files = readdirectory("$parent/$dir");
    foreach my $file (@files) {
      next if $dir =~ /^\./ or ! -f "$parent/$dir/$file";
      # print "Reading $file...<br>\n";
      $file =~ /(.*)\.db$/;
      my $page = $1;
      push @pages, $page;
      $file{$page} = "$parent/$dir/$file";
      # print "Page $page stored in $file{$page}<br>\n"
    }
  }
}

sub readtexts {
  local $| = 1;
  print "Reading pages";
  foreach $page (@pages) {
    $current = $page;
    my %p = &splitpage(&readfile($file{$page}));
    my %s = &splitsection(%p);
    my %t = &splittext(%s);
    my $o = $t{text};
    my $w = &wiki2texi($o);
    $text{$page} = $w;
    print ".";
  }
  print "done.<br>\n";
}

sub readdirectory {
  my ($dirname) = @_;
  opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
  @files = readdir(DIR);
  closedir DIR;
  return @files;
}

sub readfile {
  my ($filename) = @_;
  return '' unless $filename;
  my $data;
  local $/ = undef;   # Read complete files
  open(IN, "<$filename") or die "can't read $filename: $!";
  $data=<IN>;
  close IN;
  return $data;
}

sub splitpage {
  my ($data) = @_;
  my (%page);
  %page = split(/$FS1/, $data, -1);  # -1 keeps trailing null fields
  return %page;
}

sub splitsection {
  my (%page) = @_;
  my (%section);
  %section = split(/$FS2/, $page{text_default}, -1);
  return %section;
}

sub splittext {
  my (%section) = @_;
  my (%text);
  %text = split(/$FS3/, $section{data}, -1);
  return %text;
}

# Code moved over from wiki.pl

sub InitLinkPatterns {
  my ($UpperLetter, $LowerLetter, $AnyLetter, $LpA, $LpB, $QDelim);
  # Allow uses to call this from their config file, so do not run twice.
  return if $FS;
  # Field separators are used in the URL-style patterns below.
  if (!$FS) {
    $FS  = "\x1e";    # The FS character is the RECORD SEPARATOR control char in ASCII
    $FS0 = "\xb3";    # The old FS character is a superscript "3" in Latin-1
  }
  $FS1 = $FS . '1';   # The FS values are used to separate fields
  $FS2 = $FS . '2';   # in stored hashtables and other data structures.
  $FS3 = $FS . '3';   # The FS character is not allowed in user data.
  $UpperLetter = '[A-Z';
  $LowerLetter = '[a-z';
  $AnyLetter   = '[A-Za-z';
  if ($NonEnglish) {
    $UpperLetter .= "\xc0-\xde";
    $LowerLetter .= "\xdf-\xff";
    $AnyLetter   .= "\x80-\xff";
  }
  if (!$SimpleLinks) {
    $AnyLetter .= '_0-9';
  }
  $UpperLetter .= ']'; $LowerLetter .= ']'; $AnyLetter .= ']';
  # Main link pattern: lowercase between uppercase, then anything
  $LpA = $UpperLetter . '+' . $LowerLetter . '+' . $UpperLetter
         . $AnyLetter . '*';
  # Optional subpage link pattern: uppercase, lowercase, then anything
  $LpB = $UpperLetter . '+' . $LowerLetter . '+' . $AnyLetter . '*';
  if ($UseSubpage) {
    # Loose pattern: If subpage is used, subpage may be simple name
    $LinkPattern = "((?:(?:$LpA)?\\/$LpB)|$LpA)";
    # Strict pattern: both sides must be the main LinkPattern
    # $LinkPattern = "((?:(?:$LpA)?\\/)?$LpA)";
  } else {
    $LinkPattern = "($LpA)";
  }
  $QDelim = '(?:"")?';     # Optional quote delimiter (not in output)
  $LinkPattern .= $QDelim;
  # Inter-site convention: sites must start with uppercase letter
  # (Uppercase letter avoids confusion with URLs)
  $InterSitePattern = $UpperLetter . $AnyLetter . '+';
  $InterLinkPattern = "($InterSitePattern:[-a-zA-Z0-9\x80-\xff_=!?#$@~`%&*+\\/:;.,]+[-a-zA-Z0-9\x80-\xff_=#$@~`%&*+\\/])$QDelim";
  if ($FreeLinks) {
    # Note: the - character must be first in $AnyLetter definition
    if ($NonEnglish) {
      $AnyLetter = "[-,.()' _0-9A-Za-z\x80-\xff]";
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
  $UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|'
                  . 'prospero|telnet|gopher';
  $UrlProtocols .= '|file'  if $NetworkFile;
  $UrlPattern = "((?:$UrlProtocols):(?://[-a-zA-Z0-9_.]+:[0-9]*)?[-a-zA-Z0-9_=!?#$\@~`%&*+\\/:;.,]+[-a-zA-Z0-9_=#$\@~`%&*+\\/])$QDelim";
  $ImageExtensions = '(gif|jpg|png|bmp|jpeg)';
}

# ==== Common wiki markup ====
sub wiki2texi {
  my ($pageText) = @_;
  %SaveUrl = ();
  %SaveNumUrl = ();
  $SaveUrlIndex = 0;
  $SaveNumUrlIndex = 0;
  return '#REDIRECT' if $pageText =~ /^#REDIRECT/;
  return 'DeletedPage' if $pageText =~ /^DeletedPage/;
  $pageText =~ s/$FS//g;              # Remove separators (paranoia)
  $pageText = &QuoteTexi($pageText);
  $pageText = &ApplyTexiRules($pageText, 1);
  return $pageText;
}

sub QuoteTexi {
  my ($text) = @_;
  $text =~ s/\r//g;     # remove ^M
  $text =~ s/\@/\@\@/g; # quote @
  $text =~ s/\{/\@\{/g; # quote {
  $text =~ s/\}/\@\}/g; # quote }
  $text =~ s/\\input/\@\}/g; # quote }
  return $text;
}

sub ApplyTexiRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks) = @_;
  $text =~ s/\r\n/\n/g; # DOS to Unix
  my $state = ''; # quote, list, or normal ('')
  my $fragment;   # the current HTML fragment to be printed
  my $result;
  my $htmlre = join('|',(@HtmlTags));
  my ($oldmatch, $rest);
  local $_ = $text;
  while(1) {
    # first block -- at the beginning of a line.  Note that block level elements eat empty lines to prevent empty p elements.
    undef($fragment);
    if (m/\G(?<=\n)/cg or m/\G^/cg) { # at the beginning of a line
      if (m/\G&lt;pre&gt;\n?(.*?\n)&lt;\/pre&gt;[ \t]*\n?/cgs) { # pre must be on column 1
	$fragment = &CloseHtmlEnvironments() . "\@example\n" . $1 . "\@end example\n";
      } elsif (m/\G(\s*\n)*(\*+)[ \t]*/cg) {
	$fragment = &OpenHtmlEnvironment('itemize',length($2)) . "\n\@item ";
      } elsif (m/\G(\s*\n)*(\#+)[ \t]*/cg) {
	$fragment = &OpenHtmlEnvironment('enumerate',length($2)) . "\n\@item ";
      } elsif (m/\G(\s*\n)*(\:+)[ \t]*/cg) {
	$fragment = &OpenHtmlEnvironment('quotation',length($2));
      } elsif (m/\G(\s*\n)*(\=+)[ \t]*(.*?)[ \t]*(=+)[ \t]*\n?/cg) {
	$fragment = &CloseHtmlEnvironments() . &WikiHeading($2, $3);
      } elsif (m/\G(\s*\n)*----+[ \t]*\n?/cg) {
	$fragment = &CloseHtmlEnvironments() . $q->hr();
      } elsif (m/\G(\s*\n)*(([ \t]+.*\n?)+)/cg) {
	$fragment = &OpenHtmlEnvironment('example',1) . $2; # always level 1
      } elsif (m/\G(\s*\n)*(\;+)[ \t]*(?=.*\:)/cg) {
	$fragment = &OpenHtmlEnvironment('table',length($2), '@asis')
	  . "\@item "; # the `:' needs special treatment, later
      } elsif (m/\G(\s*\n)+/cg) {
	$fragment = &CloseHtmlEnvironments() . "\n\n"; # there is another one like this further down
      } elsif (m/\G(\&lt;include +"(.*)"\&gt;[ \t]*\n?)/cgi) { # <include "uri..."> includes the text of the given URI verbatim
	$oldmatch = $1;
	my $oldpos = pos;
	&ApplyTexiRules(&QuoteHtml(&GetRaw($2)),0);
	pos = $oldpos;
      } elsif (m/\G(\&lt;rss +"(.*)"\&gt;[ \t]*\n?)/cgi) { # <rss "uri..."> stores the parsed RSS of the given URI
	$result .= "[RSS feed from \@url{$2}]";
      }
      if (defined $fragment) {
	$result .= $fragment;
	next; # skipt the remaining tests
      }
    }
    # second block -- remaining hilighting
    if ($HtmlStack[0] eq 'table' && m/\G:/cg) {
      $fragment = "\n";
    } elsif (m/\G\&lt;nowiki\&gt;(.*?)\&lt;\/nowiki\&gt;/cgis) {
      $fragment = $1;
    } elsif (m/\G\&lt;code\&gt;(.*?)\&lt;\/code\&gt;/cgis) {
      $fragment = $q->code($1);
    } elsif ($RawHtml && m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgis) {
      $fragment = &UnquoteHtml($1);
    } elsif (m/\G'''/cg) { # traditional wiki syntax with '''strong'''
      if ($HtmlStack[0] eq 'strong') {
	$fragment = &CloseHtmlEnvironment();
      } else {
	$fragment = &AddHtmlEnvironment('strong');
      }
    } elsif (m/\G''/cg) {     #  traditional wiki syntax with ''emph''
      if ($HtmlStack[0] eq 'em') {
	$fragment = &CloseHtmlEnvironment();
      } else {
	$fragment = &AddHtmlEnvironment('em');
      }
    } elsif (m/\G\&lt;($htmlre)\&gt;/cgi) { # opening
      $fragment = &AddHtmlEnvironment($1);
    } elsif (m/\G\&lt;\/($htmlre)\&gt;/cgi) { # closing tags
      $fragment = &CloseHtmlEnvironment($1);
    } elsif ($HtmlLinks && m/\G\&lt;a(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/cgi) { # <a ...>text</a>
      $fragment = "<a$1>$2</a>";
    } elsif ($BracketText && $locallinks && m/\G(\[$InterLinkPattern\s+([^\]]+?)\])/cg) { # [InterLink text]
      # Interlinks can change when the intermap file changes (local config, therefore depend on $locallinks).
      # The intermap file is only read if necessary, so if this not an interlink after all,
      # we have to backtrack a bit.
      $oldmatch = $1;
      $fragment = &GetInterLink($2, $3, 1);
      # we may have to backtrack a bit.
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	$result .= $fragment;
      }
    } elsif ($locallinks && m/\G(\[$InterLinkPattern\])/cog) { # [InterWiki:FooBar] makes footnotes [1]
      $oldmatch = $1;
      $fragment = &GetInterLink($2, '', 1);
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	$result .= $fragment;
      }
    } elsif ($locallinks && m/\G$InterLinkPattern/cog) { # InterWiki:FooBar
      $oldmatch = $1;
      $fragment = &GetInterLink($oldmatch, '', 0);
      # we have to backtrack a bit.
      if ($oldmatch eq $fragment) {
	($fragment, $rest) = split(/:/, $oldmatch, 2);
	pos = (pos) - length($rest) - 1;
      } else {
	$result .= $fragment;
      }
    } elsif ($BracketText && m/\G\[$UrlPattern\s+([^\]]+?)\]/cg) { # [URL text] makes [text] link to URL
      $fragment = &GetUrl($1, $2, 1, 0);
    } elsif (m/\G\[$UrlPattern\]/cog) { # [URL] makes footnotes [1]
      $fragment = &GetUrl($1, '', 1, 0);
    } elsif (m/\G$UrlPattern/cg) { # plain URLs after all $UrlPattern, such that [$UrlPattern text] has priority
      $fragment = &GetUrl($1, '', 0, 1);
    } elsif ($WikiLinks && $BracketWiki && $locallinks && m/\G(\[$LinkPattern\s+([^\]]+?)\])/cg) { # [LocalPage text]
      $result .= &GetPageOrEditLink($2, $3, 1);
    } elsif ($WikiLinks && $locallinks && m/\G(\[$LinkPattern\])/cg) { # [LocalPage]
      $result .= &GetPageOrEditLink($2, '', 1);
    } elsif ($WikiLinks && $locallinks && m/\G$LinkPattern/cg) { # LocalPage
      # LinkPattern after all $UrlPattern, such that http//:...?FooBar
      # will not get an additional ? if FooBar is undefined.
      $result .= &GetPageOrEditLink($1, '');
    } elsif ($FreeLinks && $BracketWiki && $locallinks && m/\G(\[\[$FreeLinkPattern\|([^\]]+)\]\])/cg) { # [[Free Link|text]]
      $result .= &GetPageOrEditLink($2, $3, 0 , 1);
    } elsif ($FreeLinks && $locallinks && m/\G(\[\[$FreeLinkPattern\]\])/cg) { # [[Free Link]]
      $result .= &GetPageOrEditLink($2, '', 0, 1);
    } elsif (m/\G\s*\n(s*\n)+/cg) { # paragraphs -- whitespace including at least two newlines
      $fragment = &CloseHtmlEnvironments() . "\n\n"; # there is another one like this further up
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
      $result .= $fragment;
    }
  }
  # last block -- close it, cache it
  $fragment = &CloseHtmlEnvironments();
  if (defined $fragment) {
    $result .= $fragment;
  }
  return $result;
}

sub UnquoteHtml {
  my ($html) = @_;
  $html =~ s/&lt;/</g;
  $html =~ s/&gt;/>/g;
  $html =~ s/&amp;/&/g;
  return $html;
}

sub CloseEnv {
  my $tag = shift;
  if (exists $HtmlTagEquivalent{$tag}) {
    return "}";
  } else {
    return "\n\@end " . $tag . "\n";
  }
}

sub OpenEnv {
  my ($tag, $attr) = @_;
  if ($attr) {
    return "\n\@$tag $attr\n";
  } elsif (exists $HtmlTagEquivalent{$tag}) {
    return '@' . $HtmlTagEquivalent{$tag} . '{';
  } else {
    return "\n\@$tag\n";
  }
}

sub CloseHtmlEnvironment { # just close the current one
  my $code = shift;
  my $result = shift(@HtmlStack)  if not defined($code) or $HtmlStack[0] eq $code;
  return &CloseEnv($result) if $result;
  return "</$code>"; # to recognize the bug
}

sub AddHtmlEnvironment { # add a new one so that it will be closed!
  my ($code) = @_;
  if ($HtmlStack[0] ne $code) {
    unshift(@HtmlStack, $code);
    return &OpenEnv($code);
  }
  return '';
}

sub CloseHtmlEnvironments { # close all
  my $text = ''; # always return something
  my $tag;
  while (@HtmlStack > 0) {
    $text .= &CloseEnv(shift(@HtmlStack));
  }
  return $text;
}

sub OpenHtmlEnvironment { # close the previous one and open a new one instead
  my ($code, $depth, $class) = @_;
  my ($oldCode, $tag);
  my $text = ''; # always return something
  $depth = @HtmlStack unless defined($depth);
  while (@HtmlStack > $depth) { # Close tags as needed
    $text .= &CloseEnv(shift(@HtmlStack));
  }
  if ($depth > 0) {
    $depth = $IndentLimit  if ($depth > $IndentLimit);
    if (@HtmlStack) {  # Non-empty stack
      $oldCode = shift(@HtmlStack);
      if ($oldCode ne $code) {
	$text .= &CloseEnv($oldCode);
	$text .= &OpenEnv($code, $class);
      }
      unshift(@HtmlStack, $code);
    }
    while (@HtmlStack < $depth) {
      unshift(@HtmlStack, $code);
      $text .= &OpenEnv($code, $class);
    }
  }
  return $text;
}

sub GetInterLink {
  my ($id, $text, $bracket) = @_;
  my ($site, $page) = split(/:/, $id, 2);
  $page =~ s/&amp;/&/g;  # Unquote common URL HTML
  my $url;
  $url = &GetSiteUrl($site) if $page;
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
  $url .= $page;
  return "\@uref{$url,$text}";
}

sub GetSiteUrl {
  my ($site) = @_;
  my ($data, $url, $status);
  if (!$InterSiteInit) {
    $InterSiteInit = 1;
    ($status, $data) = &ReadFile($InterFile);
    return ''  if (!$status);
    %InterSite = split(/\s+/, $data);  # Later consider defensive code
  }
  $url = $InterSite{$site}  if (defined($InterSite{$site}));
  return $url;
}

sub GetUrl {
  my ($url, $text, $bracket, $images) = @_;
  if ($NetworkFile && $url =~ m|^file:///|
      or !$NetworkFile && $url =~ m|^file:|) {
    # Only do remote file:// links. No file:///c|/windows.
    return $url;
  } elsif ($bracket && !$text) {
    return "\@footnote{$url}";
  }
  $url = &UnquoteHtml($url); # links should be unquoted again
  if ($text) {
    return "\@uref{$url, $text}";
  } else {
    return "\@uref{$url}";
  }
}

sub GetPageOrEditLink { # use GetPageLink and GetEditLink if you know the result!
  my ($id, $text, $bracket, $free) = @_;
  local $| = 1;
  $id =~ s/^\s+//;      # Trim extra spaces
  $id =~ s/\s+$//;
  $id =~ s|\s*/\s*|/|;  # ...also before/after subpages
  $id =~ s|^/|$MainPage/|;
  $id = &FreeToNormal($id) if $free;
  my $exists = grep(/^$id$/, @pages);
  if (!$text && $exists && $bracket) {
    $text = ++$FootnoteNumber;
  }
  if ($exists) {
    $text = $id unless $text;
    $text =~ s/_/ /g if $free;
    $text = "[$text]" if $bracket;
    return &ScriptLink($id, $text);
  } else {
    # $free and $bracket usually exclude each other
    # $text and not $bracket exclude each other
    if ($bracket && $text) {
      return "[$id $text]";
    } elsif ($bracket) {
      return "[$id]";
    } elsif ($free && $text) {
      $id =~ s/_/ /g;
      $text =~ s/_/ /g;
      return "[$id $text]";
    } elsif ($free) {
      $text = $id;
      $text = "[$text]" if $text =~ /_/;
      $text =~ s/_/ /g;
      return $text;
    } else { # plain, no text
      return $id;
    }
  }
}

sub GetPageLink { # shortcut
  my ($id, $name) = @_;
  $name = $id unless $name;
  $id =~ s|^/|$MainPage/|;
  if ($FreeLinks) {
    $id = &FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return &ScriptLink($id, $name);
}

sub GetEditLink { # shortcut
  my ($id, $name) = @_;
  $id =~ s|^/|$MainPage/|;
  if ($FreeLinks) {
    $id = &FreeToNormal($id);
    $name =~ s/_/ /g;
  }
  return &ScriptLink("action=edit&id=$id", $name);
}

sub ScriptLink {
  my ($action, $text) = @_;
  push @{$refs{$current}}, $text; # remember all forward links
  return $text;
}

sub WikiHeading {
  my ($pre, $depth, $text) = @_;
  return $pre . "\@heading $text\n";
}

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

sub ReadFile {
  my ($fileName) = @_;
  my ($data);
  local $/ = undef;   # Read complete files
  if (open(IN, "<$fileName")) {
    $data=<IN>;
    close IN;
    if ($FS0 and $data =~ /$FS0/ and $data !~ /$FS/) {
      $data =~ s/$FS0/$FS/go;
      $FS0used = 1;
    }
    return (1, $data);
  }
  return (0, '');
}

sub FreeToNormal {
  my ($id) = @_;
  $id =~ s/ /_/g;
  $id = ucfirst($id);
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
