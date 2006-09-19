#!/usr/bin/perl

# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

use XML::LibXML;
use Encode;

# Import the functions

package OddMuse;
$RunCGI = 0;    # don't print HTML on stdout
$UseConfig = 0; # don't read module files
do 'wiki.pl';
Init();

my ($passed, $failed) = (0, 0);
my $resultfile = "/tmp/test-markup-result-$$";
my $redirect;
undef $/;
$| = 1; # no output buffering

sub url_encode {
  my $str = shift;
  return '' unless $str;
  my @letters = split(//, $str);
  my @safe = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.'); # shell metachars are unsafe
  foreach my $letter (@letters) {
    my $pattern = quotemeta($letter);
    if (not grep(/$pattern/, @safe)) {
      $letter = sprintf("%%%02x", ord($letter));
    }
  }
  return join('', @letters);
}

print "* means that a page is being updated\n";
sub update_page {
  my ($id, $text, $summary, $minor, $admin, @rest) = @_;
  print '*';
  my $pwd = $admin ? 'foo' : 'wrong';
  $id = url_encode($id);
  $text = url_encode($text);
  $summary = url_encode($summary);
  $minor = $minor ? 'on' : 'off';
  my $rest = join(' ', @rest);
  $redirect = `perl wiki.pl Save=1 title=$id summary=$summary recent_edit=$minor text=$text pwd=$pwd $rest`;
  $output = `perl wiki.pl action=browse id=$id`;
  # just in case a new page got created or NearMap or InterMap
  $IndexInit = 0;
  $NearInit = 0;
  $InterInit = 0;
  $RssInterwikiTranslateInit = 0;
  InitVariables();
  return $output;
}

print "+ means that a page is being retrieved\n";
sub get_page {
  print '+';
  open(F,"perl wiki.pl @_ |");
  my $output = <F>;
  close F;
  return $output;
}

print ". means a test\n";
sub test_page {
  my $page = shift;
  my $printpage = 0;
  foreach my $str (@_) {
    print '.';
    if ($page =~ /$str/) {
      $passed++;
    } else {
      $failed++;
      $printpage = 1;
      print "\nSimple Test: Did not find \"", $str, '"';
    }
  }
  print "\n\nPage content:\n", $page, "\n" if $printpage;
}

sub test_page_negative {
  my $page = shift;
  my $printpage = 0;
  foreach my $str (@_) {
    print '.';
    if ($page =~ /$str/) {
      $failed++;
      $printpage = 1;
      print "\nSimple negative Test: Found \"", $str, '"';
    } else {
      $passed++;
    }
  }
  print "\n\nPage content:\n", $page, "\n" if $printpage;
}

sub get_text_via_xpath {
  my ($page, $test) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc;
  eval { $doc = $parser->parse_html_string($page) };
  if ($@) {
    print "Could not parse html: $@\n", $page, "\n\n";
    $failed += 1;
  } else {
    print '.';
    my $nodelist;
    eval { $nodelist = $doc->findnodes($test) };
    if ($@) {
      $failed++;
      print "\nXPATH Test: failed to run $test: $@\n";
    } elsif ($nodelist->size()) {
      $passed++;
      return $nodelist->string_value();
    } else {
      $failed++;
      print "\nXPATH Test: No matches for $test\n";
      $page =~ s/^.*?<body/<body/s;
      print substr($page,0,30000), "\n";
    }
  }
}


sub xpath_test {
  my ($page, @tests) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc;
  eval { $doc = $parser->parse_html_string($page) };
  if ($@) {
    print "Could not parse html: ", substr($page,0,100), "\n";
    $failed += @tests;
  } else {
    foreach my $test (@tests) {
      print '.';
      my $nodelist;
      eval { $nodelist = $doc->findnodes($test) };
      if ($@) {
	$failed++;
	print "\nXPATH Test: failed to run $test: $@\n";
      } elsif ($nodelist->size()) {
	$passed++;
      } else {
	$failed++;
	print "\nXPATH Test: No matches for $test\n";
	$page =~ s/^.*?<body/<body/s; # strip
	print substr($page,0,30000), "\n";
      }
    }
  }
}

sub negative_xpath_test {
  my ($page, @tests) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc = $parser->parse_html_string($page);
  foreach my $test (@tests) {
    print '.';
    my $nodelist = $doc->findnodes($test);
    if (not $nodelist->size()) {
      $passed++;
    } else {
      $failed++;
      $printpage = 1;
      print "\nXPATH Test: Unexpected matches for $test\n";
    }
  }
}

sub apply_rules {
  my $input = shift;
  local *STDOUT;
  $output = '';
  open(STDOUT, '>', \$output) or die "Can't open memory file: $!";
  $FootnoteNumber = 0;
  ApplyRules(QuoteHtml($input), 1);
  return $output;
}


sub xpath_run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my %New;
  foreach (keys %Test) {
    $Test{$_} =~ s/\\n/\n/g;
    my $new = $Test{$_};
    s/\\n/\n/g;
    $New{$_} = $new;
  }
  # Note that the order of tests is not specified!
  my $output;
  foreach my $input (keys %New) {
    my $output = apply_rules($input);
    xpath_test("<div>$output</div>", $New{$input});
  }
}

sub test_match {
  my ($input, @tests) = @_;
  my $output = apply_rules($input);
  foreach my $str (@tests) {
    print '.';
    if ($output =~ /$str/) {
      $passed++;
    } else {
      $failed++;
      $printpage = 1;
      print "\n\n---- input:\n", $input,
	    "\n---- output:\n", $output,
            "\n---- instead of:\n", $str, "\n----\n";
    }
  }
}

sub run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my %New;
  foreach (keys %Test) {
    $Test{$_} =~ s/\\n/\n/g;
    my $new = $Test{$_};
    s/\\n/\n/g;
    $New{$_} = $new;
  }
  # Note that the order of tests is not specified!
  foreach my $input (keys %New) {
    print '.';
    my $output = apply_rules($input);
    if ($output eq $New{$input}) {
      $passed++;
    } else {
      $failed++;
      print "\n\n---- input:\n", $input,
	    "\n---- output:\n", $output,
            "\n---- instead of:\n", $New{$input}, "\n----\n";
    }
  }
}

sub run_macro_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my %New;
  foreach (keys %Test) {
    $Test{$_} =~ s/\\n/\n/g;
    my $new = $Test{$_};
    s/\\n/\n/g;
    $New{$_} = $new;
  }
  # Note that the order of tests is not specified!
  foreach my $input (keys %New) {
    print '.';
    $_ = $input;
    foreach my $macro (@MyMacros) { &$macro; }
    my $output = $_;
    if ($output eq $New{$input}) {
      $passed++;
    } else {
      $failed++;
      print "\n\n---- input:\n", $input,
	    "\n---- output:\n", $output,
            "\n---- instead of:\n", $New{$input}, "\n----\n";
    }
  }
}

sub remove_rule {
  my $rule = shift;
  my @list = ();
  my $found = 0;
  foreach my $item (@MyRules) {
    if ($item ne $rule) {
      push @list, $item;
    } else {
      $found = 1;
    }
  }
  die "Rule not found" unless $found;
  @MyRules = @list;
}

sub add_module {
  my $mod = shift;
  mkdir $ModuleDir unless -d $ModuleDir;
  my $dir = `/bin/pwd`;
  chop($dir);
  symlink("$dir/modules/$mod", "$ModuleDir/$mod") or die "Cannot symlink $mod: $!"
    unless -l "$ModuleDir/$mod";
  do "$ModuleDir/$mod";
  @MyRules = sort {$RuleOrder{$a} <=> $RuleOrder{$b}} @MyRules;
}

sub remove_module {
  my $mod = shift;
  mkdir $ModuleDir unless -d $ModuleDir;
  unlink("$ModuleDir/$mod") or die "Cannot unlink: $!";
}

sub clear_pages {
  system('/bin/rm -rf /tmp/oddmuse');
  die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
  mkdir '/tmp/oddmuse';
  open(F,'>/tmp/oddmuse/config');
  print F "\$AdminPass = 'foo';\n";
  # this used to be the default in earlier CGI.pm versions
  print F "\$ScriptName = 'http://localhost/wiki.pl';\n";
  print F "\$SurgeProtection = 0;\n";
  close(F);
  $ScriptName = 'http://localhost/test.pl'; # different!
  $IndexInit = 0;
  %IndexHash = ();
  $InterSiteInit = 0;
  %InterSite = ();
  $NearSiteInit = 0;
  %NearSite = ();
  %NearSearch = ();
}

# Create temporary data directory as expected by the script

my $str;

goto $ARGV[0] if $ARGV[0];

$ENV{'REMOTE_ADDR'} = 'test-markup';

# --------------------

recent_changes:
print '[recent changes]';
clear_pages();

$host1 = 'tisch';
$host2 = 'stuhl';
$ENV{'REMOTE_ADDR'} = $host1;
update_page('Mendacibombus', 'This is the place.', 'samba', 0, 0, ('username=berta'));
update_page('Bombia', 'This is the time.', 'tango', 0, 0, ('username=alex'));
$ENV{'REMOTE_ADDR'} = $host2;
update_page('Confusibombus', 'This is order.', 'ballet', 1, 0, ('username=berta'));
update_page('Mucidobombus', 'This is chaos.', 'tarantella', 0, 0, ('username=alex'));

@Positives = split('\n',<<'EOT');
for time\|place only
Mendacibombus.*samba
Bombia.*tango
EOT

@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Mucidobombus
tarantella
EOT

$page = get_page('action=rc rcfilteronly=time\|place');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
Mucidobombus.*tarantella
EOT

@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order\|chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
EOT

@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order%20chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
Mendacibombus.*samba
Bombia.*tango
EOT

@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Confusibombus
ballet
EOT

$page = get_page('action=rc rchostonly=tisch');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
Mucidobombus.*tarantella
EOT

@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Bombia
tango
Mendacibombus
samba
EOT

$page = get_page('action=rc rchostonly=stuhl'); # no minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
Mucidobombus.*tarantella
Confusibombus.*ballet
EOT

@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
EOT

$page = get_page('action=rc rchostonly=stuhl showedit=1'); # with minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = split('\n',<<'EOT');
Mendacibombus.*samba
EOT

@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcuseronly=berta');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella Bombia.*tango);

@Negatives = qw(Confusibombus ballet Mendacibombus samba);

$page = get_page('action=rc rcuseronly=alex');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Bombia.*tango);

@Negatives = qw(Mucidobombus tarantella Confusibombus ballet Mendacibombus samba);

$page = get_page('action=rc rcidonly=Bombia');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

edit_lock:
print '[edit lock]';

clear_pages();
test_page(get_page('action=editlock'), 'operation is restricted');
test_page(get_page('action=editlock pwd=foo'), 'Edit lock created');
xpath_test(update_page('TestLock', 'mu!'),
	   '//a[@href="http://localhost/wiki.pl?action=password"][@class="password"][text()="This page is read-only"]');
test_page($redirect, '403 FORBIDDEN', 'Editing not allowed for TestLock');
test_page(get_page('action=editlock set=0'), 'operation is restricted');
test_page(get_page('action=editlock set=0 pwd=foo'), 'Edit lock removed');
RequestLockDir('main');
test_page(update_page('TestLock', 'mu!'), 'Describe the new page here');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created (just now|1 second ago|2 seconds ago)');
test_page(update_page('TestLock', 'mu!'), 'Describe the new page here');
test_page($redirect, 'Status: 503 SERVICE UNAVAILABLE',
	  'Could not get main lock', 'File exists',
	  'The lock was created 3[0-5] seconds ago');

# --------------------

lock_on_creation:
print '[lock on creation]';

clear_pages();

## Create a sample page, and test for regular expressions in the output

$page = update_page('SandBox', 'This is a test.', 'first test');
test_page($page, 'SandBox', 'This is a test.');
xpath_test($page, '//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22SandBox%22"][text()="SandBox"]');

## Test RecentChanges

@Test = split('\n',<<'EOT');
RecentChanges
first test
EOT

test_page(get_page('action=rc'), @Test);

## Updated the page

@Test = split('\n',<<'EOT');
RecentChanges
This is another test.
EOT

test_page(update_page('SandBox', 'This is another test.', 'second test'), @Test);

## Test RecentChanges

@Test = split('\n',<<'EOT');
RecentChanges
second test
EOT

test_page(get_page('action=rc'), @Test);

## Attempt to create InterMap page as normal user

@Test = split('\n',<<'EOT');
Describe the new page here
EOT

test_page(update_page('InterMap', " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n", 'required'), @Test);

## Create InterMap page as admin

@Test = split('\n',<<'EOT');
OddMuse
http://www\.emacswiki\.org/cgi-bin/oddmuse\.pl
PlanetMath
http://planetmath\.org/encyclopedia/\%s\.html
EOT

test_page(update_page('InterMap', " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html", 'required', 0, 1), @Test);

## Verify the InterMap stayed locked

@Test = split('\n',<<'EOT');
OddMuse
EOT

test_page(update_page('InterMap', "All your edits are blong to us!\n", 'required'), @Test);

# --------------------

despam_module:
print '[despam module]';

clear_pages();
add_module('despam.pl');

update_page('HilariousPage', "Ordinary text.");
update_page('HilariousPage', "Hilarious text.");
update_page('HilariousPage', "Spam from http://example.com.");

update_page('NoPage', "Spam from http://example.com.");

update_page('OrdinaryPage', "Spam from http://example.com.");
update_page('OrdinaryPage', "Ordinary text.");

update_page('ExpiredPage', "Spam from http://example.com.");
update_page('ExpiredPage', "More spam from http://example.com.");
update_page('ExpiredPage', "Still more spam from http://example.com.");

update_page('BannedContent', " example\\.com\n", 'required', 0, 1);

unlink('/tmp/oddmuse/keep/E/ExpiredPage/1.kp') or die "Cannot delete kept revision: $!";

@Test = split('\n',<<'EOT');
HilariousPage.*Revert to revision 2
NoPage.*Marked as DeletedPage
OrdinaryPage
ExpiredPage.*Cannot find unspammed revision
EOT

test_page(get_page('action=despam'), @Test);
test_page(get_page('ExpiredPage'), 'Still more spam');
test_page(get_page('OrdinaryPage'), 'Ordinary text');
test_page(get_page('NoPage'), 'DeletedPage');
test_page(get_page('HilariousPage'), 'Hilarious text');
test_page(get_page('BannedContent'), 'example\\\.com');

# --------------------

near:
print '[near]';

clear_pages();

CreateDir($NearDir);
WriteStringToFile("$NearDir/EmacsWiki", "AlexSchroeder\nFooBar\n");

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/cgi-bin/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/cgi-bin/emacs?action=index;raw=1"
	    . " http://www.emacswiki.org/cgi-bin/emacs?search=%s;raw=1;near=0\n",
	    'required', 0, 1);

xpath_test(update_page('FooBaz', "Try FooBar instead!\n"),
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"][text()="FooBar"]',
	   '//div[@class="near"]/p/a[@class="local"][@href="http://localhost/wiki.pl/EditNearLinks"][text()="EditNearLinks"]/following-sibling::text()[string()=": "]/following-sibling::a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=FooBar"][text()="FooBar"]');

xpath_test(update_page('FooBar', "Test by AlexSchroeder!\n"),
	  '//div[@class="sister"]/p/a[@title="EmacsWiki:FooBar"][@href="http://www.emacswiki.org/cgi-bin/wiki/FooBar"]/img[@src="file:///tmp/oddmuse/EmacsWiki.png"][@alt="EmacsWiki:FooBar"]');

xpath_test(get_page('search=alexschroeder'),
	   '//p[text()="Near pages:"]',
	   '//a[@class="near"][@title="EmacsWiki"][@href="http://www.emacswiki.org/cgi-bin/wiki/AlexSchroeder"][text()="AlexSchroeder"]');

# --------------------

links:
print '[links]';

clear_pages();
add_module('links.pl');

update_page('InterMap', " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
	    'required', 0, 1);

update_page('a', 'Oddmuse:foo(no) [Oddmuse:bar] [Oddmuse:baz text] '
	    . '[Oddmuse:bar(no)] [Oddmuse:baz(no) text] '
	    . '[[Oddmuse:foo_(bar)]] [[[Oddmuse:foo (baz)]]] [[Oddmuse:foo (quux)|text]]');
$InterInit = 0;
InitVariables();

@Test = map { quotemeta } split('\n',<<'EOT');
"a" -> "Oddmuse:foo"
"a" -> "Oddmuse:bar"
"a" -> "Oddmuse:baz"
"a" -> "Oddmuse:foo_(bar)"
"a" -> "Oddmuse:foo (baz)"
"a" -> "Oddmuse:foo (quux)"
EOT

test_page_negative(get_page('action=links raw=1'), @Test);
test_page(get_page('action=links raw=1 inter=1'), @Test);

@Test = split('\n',<<'EOT');
//a[@class="local"][@href="http://localhost/wiki.pl/a"][text()="a"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo"]/span[@class="site"][text()="Oddmuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="foo"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?bar"]/span[@class="site"][text()="Oddmuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="bar"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?baz"]/span[@class="site"][text()="Oddmuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="baz"]
//a[@class="inter Oddmuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo_(bar)"]/span[@class="site"][text()="Oddmuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="foo_(bar)"]
EOT

negative_xpath_test(get_page('action=links'), @Test);
xpath_test(get_page('action=links inter=1'), @Test);

AppendStringToFile($ConfigFile, "\$BracketWiki = 0;\n");

update_page('a', '[[b]] [[[c]]] [[d|e]] FooBar [FooBaz] [FooQuux fnord] ');

@Test1 = split('\n',<<'EOT');
"a" -> "b"
"a" -> "c"
"a" -> "FooBar"
"a" -> "FooBaz"
"a" -> "FooQuux"
EOT

@Test2 = split('\n',<<'EOT');
"a" -> "d"
EOT

$page = get_page('action=links raw=1');
test_page($page, @Test1);
test_page_negative($page, @Test2);

AppendStringToFile($ConfigFile, "\$BracketWiki = 1;\n");

update_page('a', '[[b]] [[[c]]] [[d|e]] FooBar [FooBaz] [FooQuux fnord] '
	    . 'http://www.oddmuse.org/ [http://www.emacswiki.org/] '
	    . '[http://www.communitywiki.org/ cw]');

@Test1 = split('\n',<<'EOT');
"a" -> "b"
"a" -> "c"
"a" -> "d"
"a" -> "FooBar"
"a" -> "FooBaz"
"a" -> "FooQuux"
EOT

@Test2 = split('\n',<<'EOT');
"a" -> "http://www.oddmuse.org/"
"a" -> "http://www.emacswiki.org/"
"a" -> "http://www.communitywiki.org/"
EOT

$page = get_page('action=links raw=1');
test_page($page, @Test1);
test_page_negative($page, @Test2);
$page = get_page('action=links raw=1 url=1');
test_page($page, @Test1, @Test2);
$page = get_page('action=links raw=1 links=0 url=1');
test_page_negative($page, @Test1);
test_page($page, @Test2);

# --------------------

toc_module:
print '[toc module]';

clear_pages();
add_module('toc.pl');
add_module('usemod.pl');
InitVariables();

%Test = split('\n',<<'EOT');
== make honey ==\n\nMoo.\n
<h2 id="toc1">make honey</h2><p>Moo.</p>
EOT

run_tests();

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "==two==\n"
		      . "bla\n"
		      . "==two==\n"
		      . "mu."),
	  quotemeta('<ol><li><a href="#toc1">one</a><ol><li><a href="#toc2">two</a></li><li><a href="#toc3">two</a></li></ol></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">two</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('two</a></li></ol></li></ol></div><h2 id="toc1">one</h2>'),);

test_page(update_page('toc', "bla\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "==two==\n"),
	  quotemeta('<ol><li><a href="#toc1">two</a><ol><li><a href="#toc2">three</a></li></ol></li><li><a href="#toc3">two</a></li></ol>'),
	  quotemeta('<h2 id="toc1">two</h2>'),
	  quotemeta('<h3 id="toc2">three</h3>'));

test_page(update_page('toc', "bla\n"
		      . "<toc>\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#toc1">two</a><ol><li><a href="#toc2">three</a></li></ol></li><li><a href="#toc3">one</a></li></ol>'),
	  quotemeta('<h2 id="toc1">two</h2>'),
	  quotemeta('<h2 id="toc3">one</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div><p> murks'),);

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "==two==\n"
		      . "<nowiki>bla\n"
		      . "==two==\n"
		      . "mu.</nowiki>\n"
		      . "<nowiki>bla\n"
		      . "==two==\n"
		      . "mu.</nowiki>\n"
		      . "yadda <code>bla\n"
		      . "==two==\n"
		      . "mu.</code>\n"
		      . "yadda <pre> has no effect! \n"
		      . "##bla\n"
		      . "==three==\n"
		      . "mu.##\n"
		      . "=one=\n"
		      . "blarg </pre>\n"),
	  quotemeta('<ol><li><a href="#toc1">one</a><ol><li><a href="#toc2">two</a></li><li><a href="#toc3">three</a></li></ol></li><li><a href="#toc4">one</a></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">two</h2>'),
	  quotemeta('<h2 id="toc3">three</h2>'),
	  quotemeta('<h2 id="toc4">one</h2>'),);

add_module('markup.pl');

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "<code>bla\n"
		      . "=two=\n"
		      . "mu.</code>\n"
		      . "##bla\n"
		      . "=three=\n"
		      . "mu.##\n"
		      . "=four=\n"
		      . "blarg\n"),
	  quotemeta('<ol><li><a href="#toc1">one</a></li><li><a href="#toc2">four</a></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">four</h2>'),);

remove_rule(\&UsemodRule);
remove_rule(\&MarkupRule);
remove_rule(\&TocRule);

# --------------------

headers:
print '[headers in various modules]';

clear_pages();

# without portrait-support

# nothing
update_page('headers', "== no header ==\n\ntext\n");
test_page(get_page('headers'), '== no header ==');

# usemod only
add_module('usemod.pl');
update_page('headers', "== is header ==\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');

# toc + usemod only
add_module('toc.pl');
update_page('headers', "== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<h2 id="headers1">one</h2>',
	  '<h2 id="headers2">two</h2>', );
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# toc + headers
add_module('headers.pl');
update_page('headers', "one\n===\ntext\ntwo\n---\ntext\nthree\n====\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a>',
	  '<ol><li><a href="#headers2">two</a></li></ol>',
	  '<li><a href="#headers3">three</a></li>',
	  '<h2 id="headers1">one</h2>',
	  '<h3 id="headers2">two</h3>',
	  '<h2 id="headers3">three</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);

# headers only
update_page('headers', "is header\n=========\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');
remove_module('headers.pl');
remove_rule(\&HeadersRule);

# --------------------

with_portrait_support:
print '[with portrait support]';

clear_pages();
add_module('portrait-support.pl');

# nothing
update_page('headers', "[new]foo\n== no header ==\n\ntext\n");
test_page(get_page('headers'), '<div class="color one level0"><p>foo == no header ==</p><p>text</p></div>');

# usemod only
add_module('usemod.pl');
update_page('headers', "[new]foo\n== is header ==\n\ntext\n");
test_page(get_page('headers'), '<div class="color one level0"><p>foo </p></div><h2>is header</h2>');

# usemod + toc only
add_module('toc.pl');
update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<div class="content browse"><div class="color one level0"><p>foo </p></div>', # default to before the header
	  '<div class="toc"><h2>Contents</h2><ol>',
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<li><a href="#headers3">three</a></li></ol></div>',
	  '<h2 id="headers1">one</h2><p>text </p>',
	  '<h2 id="headers2">two</h2>', );
remove_module('toc.pl');
remove_rule(\&TocRule);
remove_module('usemod.pl');
remove_rule(\&UsemodRule);

# headers only
add_module('headers.pl');
update_page('headers', "[new]foo\nis header\n=========\n\ntext\n");
test_page(get_page('headers'), '<div class="color one level0"><p>foo </p></div><h2>is header</h2>');
remove_module('headers.pl');
remove_rule(\&HeadersRule);

# portrait-support, toc, and usemod

add_module('usemod.pl');
add_module('toc.pl');
update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#headers1">one</a></li>',
	  '<li><a href="#headers2">two</a></li>',
	  '<div class="color one level0"><p>foo </p></div>',
	  '<h2 id="headers1">one</h2>',
	  '<h2 id="headers2">two</h2>', );

%Test = split('\n',<<'EOT');
[new]\nfoo
<div class="color one level0"><p> foo</p></div>
:[new]\nfoo
<div class="color two level1"><p> foo</p></div>
::[new]\nfoo
<div class="color one level2"><p> foo</p></div>
EOT

run_tests();

remove_rule(\&UsemodRule);
remove_rule(\&TocRule);
*GetHeader = *OldTocGetHeader;
remove_rule(\&PortraitSupportRule);
*ApplyRules = *OldPortraitSupportApplyRules;

# --------------------

hr:
print '[hr in various modules]';

clear_pages();

# without portrait-support

# nothing
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), 'one ---- two');

# usemod only
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
remove_rule(\&UsemodRule);

# headers only
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
remove_rule(\&HeadersRule);

# --------------------

print '[with portrait support]';

clear_pages();
add_module('portrait-support.pl');


# just portrait-support
update_page('hr', "[new]one\n----\ntwo\n");
test_page(get_page('hr'), '<div class="content browse"><div class="color one level0"><p>one </p></div><hr /><p>two</p></div>');

# usemod and portrait-support
add_module('usemod.pl');
update_page('hr', "one\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one </p><hr /><p>three</p></div>');
unlink('/tmp/oddmuse/modules/usemod.pl') or die "Cannot unlink: $!";
remove_rule(\&UsemodRule);

# headers and portrait-support
add_module('headers.pl');
update_page('hr', "one\n----\ntwo\n");
test_page(get_page('hr'), '<div class="content browse"><h3>one</h3><p>two</p></div>');

update_page('hr', "one\n\n----\nthree\n");
test_page(get_page('hr'), '<div class="content browse"><p>one</p><hr /><p>three</p></div>');
unlink('/tmp/oddmuse/modules/headers.pl') or die "Cannot unlink: $!";
remove_rule(\&HeadersRule);

remove_rule(\&PortraitSupportRule);
*ApplyRules = *OldPortraitSupportApplyRules;

# --------------------

sidebar:
print '[sidebar]';

clear_pages();

add_module('sidebar.pl');

test_page(update_page('SideBar', 'mu'), '<div class="sidebar"><p>mu</p></div>');
test_page(get_page('HomePage'), '<div class="sidebar"><p>mu</p></div>');

print '[with toc]';

add_module('toc.pl');
add_module('usemod.pl');

AppendStringToFile($ConfigFile, "\$TocAutomatic = 0;\n");

update_page('SideBar', "bla\n\n"
	    . "== mu ==\n\n"
	    . "bla");

test_page(update_page('test', "bla\n"
		      . "<toc>\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#test1">two</a><ol><li><a href="#test2">three</a></li></ol></li><li><a href="#test3">one</a></li></ol>'),
	  quotemeta('<h2 id="SideBar1">mu</h2>'),
	  quotemeta('<h2 id="test1">two</h2>'),
	  quotemeta('<h2 id="test3">one</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div><p> murks'));

update_page('SideBar', "<toc>");
test_page(update_page('test', "bla\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#test1">two</a><ol><li><a href="#test2">three</a></li></ol></li><li><a href="#test3">one</a></li></ol>'),
	  quotemeta('<h2 id="test1">two</h2>'),
	  quotemeta('<h2 id="test3">one</h2>'),
	  quotemeta('<div class="sidebar"><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div></div><div class="content browse"><p>'));

remove_rule(\&TocRule);
remove_rule(\&UsemodRule);

print '[with forms]'; # + pagelock + forms

add_module('forms.pl');

test_page(update_page('SideBar', '<form><h1>mu</h1></form>'), '<div class="sidebar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');
xpath_test(get_page('action=pagelock id=SideBar set=1 pwd=foo'), '//p/text()[string()="Lock for "]/following-sibling::a[@href="http://localhost/wiki.pl/SideBar"][@class="local"][text()="SideBar"]/following-sibling::text()[string()=" created."]');
test_page(get_page('SideBar'), '<div class="sidebar"><form><h1>mu</h1></form></div>');
# While rendering the SideBar as part of the HomePage, it should still
# be considered "locked", and therefore the form should render
# correctly.
test_page(get_page('HomePage'), '<div class="sidebar"><form><h1>mu</h1></form></div>');
# test_page(get_page('HomePage'), '<div class="sidebar"><p>&lt;form&gt;&lt;h1&gt;mu&lt;/h1&gt;&lt;/form&gt;</p></div>');
get_page('action=pagelock id=SideBar set=0 pwd=foo');
