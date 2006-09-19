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

major:
print '[major]';

clear_pages();
# start with minor
update_page('bar', 'one', '', 1); # lastmajor is undef
test_page(get_page('action=browse id=bar diff=1'), 'No diff available', 'one', 'Last major edit',
	  'diff=1;id=bar;diffrevision=1');
test_page(get_page('action=browse id=bar diff=2'), 'No diff available', 'one', 'Last edit');
update_page('bar', 'two', '', 1); # lastmajor is undef
test_page(get_page('action=browse id=bar diff=1'), 'No diff available', 'two', 'Last major edit',
	  'diff=1;id=bar;diffrevision=1');
test_page(get_page('action=browse id=bar diff=2'), 'one', 'two', 'Last edit');
update_page('bar', 'three'); # lastmajor is 3
test_page(get_page('action=browse id=bar diff=1'), 'two', 'three', 'Last edit');
test_page(get_page('action=browse id=bar diff=2'), 'two', 'three', 'Last edit');
update_page('bar', 'four'); # lastmajor is 4
test_page(get_page('action=browse id=bar diff=1'), 'three', 'four', 'Last edit');
test_page(get_page('action=browse id=bar diff=2'), 'three', 'four', 'Last edit');
# start with major
major1:
clear_pages();
update_page('bla', 'one'); # lastmajor is 1
test_page(get_page('action=browse id=bla diff=1'), 'No diff available', 'one', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'No diff available', 'one', 'Last edit');
update_page('bla', 'two', '', 1); # lastmajor is 1
test_page(get_page('action=browse id=bla diff=1'), 'No diff available', 'two', 'Last major edit',
	  'diff=1;id=bla;diffrevision=1');
test_page(get_page('action=browse id=bla diff=2'), 'one', 'two', 'Last edit');
update_page('bla', 'three'); # lastmajor is 3
test_page(get_page('action=browse id=bla diff=1'), 'two', 'three', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'two', 'three', 'Last edit');
update_page('bla', 'four', '', 1); # lastmajor is 3
test_page(get_page('action=browse id=bla diff=1'), 'two', 'three', 'Last major edit',
	  'diff=1;id=bla;diffrevision=3');
test_page(get_page('action=browse id=bla diff=2'), 'three', 'four', 'Last edit');
update_page('bla', 'five'); # lastmajor is 5
test_page(get_page('action=browse id=bla diff=1'), 'four', 'five', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'four', 'five', 'Last edit');
update_page('bla', 'six'); # lastmajor is 6
test_page(get_page('action=browse id=bla diff=1'), 'five', 'six', 'Last edit');
test_page(get_page('action=browse id=bla diff=2'), 'five', 'six', 'Last edit');

# --------------------

revisions:
print '[revisions]';

clear_pages();

## Test revision and diff stuff

update_page('KeptRevisions', 'first');
update_page('KeptRevisions', 'second');
update_page('KeptRevisions', 'third');
update_page('KeptRevisions', 'fourth', '', 1);
update_page('KeptRevisions', 'fifth', '', 1);

# Show the current revision

test_page(get_page(KeptRevisions),
	  'KeptRevisions',
	  'fifth');

# Show the other revision

test_page(get_page('action=browse revision=2 id=KeptRevisions'),
	  'Showing revision 2',
	  'second');

test_page(get_page('action=browse revision=1 id=KeptRevisions'),
	 'Showing revision 1',
	  'first');

# Show the current revision if an inexisting revision is asked for

test_page(get_page('action=browse revision=9 id=KeptRevisions'),
	  'Revision 9 not available \(showing current revision instead\)',
	  'fifth');

# Disable cache and request the correct last major diff
test_page(get_page('action=browse diff=1 id=KeptRevisions cache=0'),
	  'Difference between revision 2 and revision 3',
	  'second',
	  'third');

# Show a diff from the history page comparing two specific revisions
test_page(get_page('action=browse diff=1 revision=4 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and revision 4',
	  'second',
	  'fourth');

# Show no difference
update_page('KeptRevisions', 'second');
test_page(get_page('action=browse diff=1 revision=6 diffrevision=2 id=KeptRevisions'),
	  'Difference between revision 2 and revision 6',
	  'The two revisions are the same');

# --------------------

diff:
print '[diff]';

clear_pages();

# Highlighting differences
update_page('xah', "When we judge people in society, often, we can see people's true nature not by the official defenses and behaviors, but by looking at the statistics (past records) of their behavior and the circumstances it happens.\n"
	    . "For example, when we look at the leader in human history. Great many of them have caused thousands and millions of intentional deaths. Some of these leaders are hated by many, yet great many of them are adored and admired and respected... (ok, i'm digressing...)\n");
update_page('xah', "When we judge people in society, often, we can see people's true nature not by the official defenses and behaviors, but by looking at some subtleties, and also the statistics (past records) of their behavior and the circumstances they were in.\n"
	    . "For example, when we look at leaders in history. Great many of them have caused thousands and millions of intentional deaths. Some of these leaders are hated by many, yet great many of them are adored and admired and respected... (ok, i'm digressing...)\n");
test_page(get_page('action=browse diff=1 id=xah'),
	  '<strong class="changes">it happens</strong>',
	  '<strong class="changes">the leader</strong>',
	  '<strong class="changes">human</strong>',
	  '<strong class="changes">some subtleties, and also</strong>',
	  '<strong class="changes">they were in</strong>',
	  '<strong class="changes">leaders</strong>',
	 );

# --------------------

rollback:
print '[rollback]';

clear_pages();

# old revisions
update_page('InnocentPage', 'Innocent.', 'good guy zero');
update_page('NicePage', 'Friendly content.', 'good guy one');
update_page('OtherPage', 'Other cute content 1.', 'another good guy');
update_page('OtherPage', 'Other cute content 2.', 'another good guy');
update_page('OtherPage', 'Other cute content 3.', 'another good guy');
update_page('OtherPage', 'Other cute content 4.', 'another good guy');
update_page('OtherPage', 'Other cute content 5.', 'another good guy');
update_page('OtherPage', 'Other cute content 6.', 'another good guy');
update_page('OtherPage', 'Other cute content 7.', 'another good guy');
update_page('OtherPage', 'Other cute content 8.', 'another good guy');
update_page('OtherPage', 'Other cute content 9.', 'another good guy');
update_page('OtherPage', 'Other cute content 10.', 'another good guy');
update_page('OtherPage', 'Other cute content 11.', 'another good guy');
# good revisions -- need a different timestamp than the old revisions!
sleep(1);
update_page('InnocentPage', 'Lamb.', 'good guy zero');
update_page('OtherPage', 'Other cute content 12.', 'another good guy');
update_page('MinorPage', 'Dumdidu', 'tester');
# last good revision -- needs a different timestamp than the good revisions!
sleep(1);
update_page('NicePage', 'Nice content.', 'good guy two');
# bad revisions -- need a different timestamp than the last good revision!
sleep(1);
update_page('NicePage', 'Evil content.', 'vandal one');
update_page('OtherPage', 'Other evil content.', 'another vandal');
update_page('NicePage', 'Bad content.', 'vandal two');
update_page('EvilPage', 'Spam!', 'vandal three');
update_page('AnotherEvilPage', 'More Spam!', 'vandal four');
update_page('AnotherEvilPage', 'Still More Spam!', 'vandal five');
update_page('MinorPage', 'Ramtatam', 'testerror', 1);

test_page(get_page('NicePage'), 'Bad content');
test_page(get_page('InnocentPage'), 'Lamb');

$to = get_text_via_xpath(get_page('action=rc all=1 pwd=foo'),
			 '//strong[text()="good guy two"]/preceding-sibling::a[@class="rollback"]/attribute::href');
$to =~ /action=rollback;to=([0-9]+)/;
$to = $1;

test_page(get_page("action=rollback to=$to"), 'username is required');
test_page(get_page("action=rollback to=$to username=me"), 'restricted to administrators');
test_page(get_page("action=rollback to=$to pwd=foo"),
	  'Rolling back changes',
	  'EvilPage</a> rolled back',
	  'AnotherEvilPage</a> rolled back',
	  'MinorPage</a> rolled back',
	  'NicePage</a> rolled back',
	  'OtherPage</a> rolled back');

test_page(get_page('NicePage'), 'Nice content');
test_page(get_page('OtherPage'), 'Other cute content 12');
test_page(get_page('EvilPage'), 'DeletedPage');
test_page(get_page('AnotherEvilPage'), 'DeletedPage');
test_page(get_page('InnocentPage'), 'Lamb');

my $rc = get_page('action=rc all=1 showedit=1 pwd=foo'); # this includes rollback info and rollback links

# check all revisions of NicePage in recent changes
xpath_test($rc,
	'//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=1"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy one"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=2"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=2"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="good guy two"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=3"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=3"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal one"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage;diffrevision=4"][text()="diff"]/following-sibling::a[@class="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage;revision=4"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="vandal two"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=NicePage"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=NicePage"][text()="NicePage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]',
	# check that the minor spam is reverted with a minor rollback
	'//li/span[@class="time"]/following-sibling::span[@class="new"][text()="new"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=1"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="tester"]',
	'//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage;diffrevision=2"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage;revision=2"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[text()="testerror"]/following-sibling::em[text()="(minor)"]',
	   '//li/span[@class="time"]/following-sibling::a[@class="diff"][@href="http://localhost/wiki.pl?action=browse;diff=2;id=MinorPage"][text()="diff"]/following-sibling::a[@class="rollback"][text()="rollback"]/following-sibling::a[@class="revision"][@href="http://localhost/wiki.pl?action=browse;id=MinorPage"][text()="MinorPage"]/following-sibling::span[@class="dash"]/following-sibling::strong[contains(text(),"Rollback to")]/following-sibling::em[text()="(minor)"]',
	  );

# test that ordinary RC doesn't show the rollback stuff
update_page('Yoga', 'Ommmm', 'peace');

$page = get_page('action=rc raw=1');
test_page($page,
	  "title: NicePage\ndescription: good guy two\n",
	  "title: MinorPage\ndescription: tester\n",
	  "title: OtherPage\ndescription: another good guy\n",
	  "title: InnocentPage\ndescription: good guy zero\n",
	  "title: Yoga\ndescription: peace\n",
	  );
test_page_negative($page,
		   "rollback",
		   "Rollback",
		   "EvilPage",
		   "AnotherEvilPage",
		  );

# --------------------

history:
print '[history]';

clear_pages();

$page = get_page('action=history id=hist');
test_page($page,
	  'No other revisions available',
	  'View current revision',
	  'View all changes');
test_page_negative($page,
		   'View other revisions',
		   'Mark this page for deletion');

test_page(update_page('hist', 'testing', 'test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary'),
	  'testing',
	  'action=history',
	  'View other revisions');

test_page_negative(get_page('action=history id=hist'),
		   'Mark this page for deletion');
$page = get_page('action=history id=hist username=me');
test_page($page,
	  'test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary test summary',
	  'View current revision',
	  'View all changes',
	  'current',
	  'Mark this page for deletion');
test_page_negative($page,
		   'No other revisions available',
		   'View other revisions',
		   'rollback');

test_page(update_page('hist', 'Tesla', 'Power'),
	  'Tesla',
	  'action=history',
	  'View other revisions');
$page = get_page('action=history id=hist username=me');
test_page($page,
	  'test summary',
	  'Power',
	  'View current revision',
	  'View all changes',
	  'current',
	  'rollback',
	  'action=rollback;to=',
	  'Mark this page for deletion');
test_page_negative($page,
		   'Tesla',
		   'No other revisions available',
		   'View other revisions');

# --------------------

pagenames:
print '[pagenames]';

clear_pages();

update_page('.dotfile', 'old content', 'older summary');
update_page('.dotfile', 'some content', 'some summary');
test_page(get_page('.dotfile'), 'some content');
test_page(get_page('action=browse id=.dotfile revision=1'), 'old content');
test_page(get_page('action=history id=.dotfile'), 'older summary', 'some summary');

# --------------------

clusters:
print '[clusters]';

clear_pages();

AppendStringToFile($ConfigFile, "\$PageCluster = 'Cluster';\n");

update_page('ClusterIdea', 'This is just a page.', 'one');
update_page('ClusterIdea', "This is just a page.\nBut somebody has to do it.", 'two');
update_page('ClusterIdea', "This is just a page.\nNobody wants it.", 'three', 1);
update_page('ClusterIdea', "MainPage\nThis is just a page.\nBut somebody has to do it.", 'four');

test_page(get_page('action=rc'), 'Cluster.*MainPage');

test_page(get_page('action=rc all=1'), qw(Cluster.*MainPage ClusterIdea.*two ClusterIdea.*one));

test_page(get_page('action=rc all=1 showedit=1'), qw(Cluster.*MainPage ClusterIdea.*three
						     ClusterIdea.*two ClusterIdea.*one));

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*history.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=0
EOT

update_page('MainPage', 'Finally the main page.', 'main summary');
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage'), @Test);

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
EOT

test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage showedit=1'),
	  (@Test, 'action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=1'));
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1'),
	  (@Test, 'action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=1;showedit=0'));

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*five
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=1;showedit=1
EOT

update_page('ClusterIdea', "MainPage\nSomebody has to do it.", 'five', 1);
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1 showedit=1'), @Test);

test_page(get_page('action=rss'), 'action=browse;id=MainPage;rcclusteronly=MainPage');

update_page('OtherIdea', "MainPage\nThis is another page.\n", 'new page in cluster');
$page = get_page('action=rc raw=1');
test_page($page, 'title: MainPage', 'description: OtherIdea: new page in cluster',
	  'description: main summary');
test_page_negative($page, 'ClusterIdea');

# --------------------

rss:
print '[rss]';

# create simple config file

use Cwd;
$dir = cwd;
$uri = "file://$dir";

# some xpath tests
update_page('RSS', "<rss $uri/heise.rdf>");
$page = get_page('RSS');
xpath_test($page, Encode::encode_utf8('//a[@title="999"][@href="http://www.heise.de/tp/deutsch/inhalt/te/15886/1.html"][text()="Berufsverbot für Mediendesigner?"]'));

@Test = split('\n',<<'EOT');
<div class="rss"><ul><li>
Experimentell bestätigt:
http://www.heise.de/tp/deutsch/inhalt/lis/15882/1.html
Clash im Internet?
http://www.heise.de/tp/deutsch/special/med/15787/1.html
Die Einheit der Umma gegen die jüdische Weltmacht
http://www.heise.de/tp/deutsch/special/ost/15879/1.html
Im Krieg mit dem Satan
http://www.heise.de/tp/deutsch/inhalt/co/15880/1.html
Der dritte Mann
http://www.heise.de/tp/deutsch/inhalt/co/15876/1.html
Leicht neben dem Ziel
http://www.heise.de/tp/deutsch/inhalt/mein/15867/1.html
Wale sollten Nordkorea meiden
http://www.heise.de/tp/deutsch/inhalt/co/15878/1.html
Afghanistan-Krieg und Irak-Besatzung haben al-Qaida gestärkt
http://www.heise.de/tp/deutsch/inhalt/co/15874/1.html
Der mit dem Dinosaurier tanzt
http://www.heise.de/tp/deutsch/inhalt/lis/15863/1.html
Terroranschlag überschattet das Genfer Abkommen
http://www.heise.de/tp/deutsch/special/ost/15873/1.html
"Barwatch" in Kanada
http://www.heise.de/tp/deutsch/inhalt/te/15871/1.html
Die Türken kommen!
http://www.heise.de/tp/deutsch/special/irak/15870/1.html
Neue Regelungen zur Telekommunikationsüberwachung
http://www.heise.de/tp/deutsch/inhalt/te/15869/1.html
Ein Lied vom Tod
http://www.heise.de/tp/deutsch/inhalt/kino/15862/1.html
EOT

test_page($page, @Test);

# RSS 2.0

update_page('RSS', "<rss $uri/flickr.xml>");
test_page(get_page('RSS'),
	  join('(.|\n)*', # verify the *order* of things.
	       'href="http://www.flickr.com/photos/broccoli/867118/"',
	       'href="http://www.flickr.com/photos/broccoli/867075/"',
	       'href="http://www.flickr.com/photos/seuss/864332/"',
	       'href="http://www.flickr.com/photos/redking/851171/"',
	       'href="http://www.flickr.com/photos/redking/851168/"',
	       'href="http://www.flickr.com/photos/redking/851167/"',
	       'href="http://www.flickr.com/photos/redking/851166/"',
	       'href="http://www.flickr.com/photos/redking/851165/"',
	       'href="http://www.flickr.com/photos/bibo/844085/"',
	       'href="http://www.flickr.com/photos/theunholytrinity/867312/"'),
	  join('(.|\n)*',
	       'title="2004-10-14 09:34:47 "',
	       'title="2004-10-14 09:28:11 "',
	       'title="2004-10-14 05:08:17 "',
	       'title="2004-10-13 10:00:34 "',
	       'title="2004-10-13 10:00:30 "',
	       'title="2004-10-13 10:00:27 "',
	       'title="2004-10-13 10:00:25 "',
	       'title="2004-10-13 10:00:22 "',
	       'title="2004-10-12 23:38:14 "',
	       'title="2004-10-10 10:09:06 "'),
	  join('(.|\n)*',
	       '>The Hydra<',
	       '>The War On Hydra<',
	       '>Nation Demolished<',
	       '>Drummers<',
	       '>Death<',
	       '>Audio Terrorists<',
	       '>Crowds<',
	       '>Assholes<',
	       '>iraq_saddam03<',
	       '>brudermann<'));

@Test = split('\n',<<'EOT');
Fania All Stars - Bamboleo
http://www.audioscrobbler.com/music/Fania\+All\+Stars/_/Bamboleo
EOT

update_page('RSS', "<rss $uri/kensanata.xml>");
test_page(get_page('RSS'), @Test);

@Test = split('\n',<<'EOT');
PRNewswire: Texas Software Startup, Serenity Systems, Advises Business Users to Get Off Windows
http://linuxtoday.com/story.php3\?sn=9443
LinuxPR: MyDesktop Launches Linux Software Section
http://linuxtoday.com/story.php3\?sn=9442
LinuxPR: Franklin Institute Science Museum Chooses Linux
http://linuxtoday.com/story.php3\?sn=9441
Yellow Dog Linux releases updated am-utils
http://linuxtoday.com/story.php3\?sn=9440
LinuxPR: LinuxCare Adds Laser5 Linux To Roster of Supported Linux Distributions
http://linuxtoday.com/story.php3\?sn=9439
EOT

update_page('RSS', "<rss $uri/linuxtoday.rdf>");
test_page(get_page('RSS'), @Test);

@Test = split('\n',<<'EOT');
Xskat 3.1
http://freshmeat.net/news/1999/09/01/936224942.html
Java Test Driver 1.1
http://freshmeat.net/news/1999/09/01/936224907.html
WaveLAN/IEEE driver 1.0.1
http://freshmeat.net/news/1999/09/01/936224545.html
macfork 1.0
http://freshmeat.net/news/1999/09/01/936224336.html
QScheme 0.2.2
http://freshmeat.net/news/1999/09/01/936223755.html
CompuPic 4.6 build 1018
http://freshmeat.net/news/1999/09/01/936223729.html
eXtace 1.1.16
http://freshmeat.net/news/1999/09/01/936223709.html
GTC 0.3
http://freshmeat.net/news/1999/09/01/936223686.html
RocketJSP 0.9c
http://freshmeat.net/news/1999/09/01/936223646.html
Majik 3D 0.0/M3
http://freshmeat.net/news/1999/09/01/936223622.html
EOT

update_page('RSS', "<rss $uri/fm.rdf>");
test_page(get_page('RSS'), @Test);

@Test = split('\n',<<'EOT');
GTKeyboard 0.85
http://freshmeat.net/news/1999/06/21/930003829.html
EOT

update_page('RSS', "<rss $uri/rss1.0.rdf>");
test_page(get_page('RSS'), @Test);

# Note, cannot identify BayleShanks as author in the mb.rdf
@Test = split('\n',<<'EOT');
MeatBall:LionKimbro
2003-10-24T22:49:33\+06:00
CommunityWiki:RecentNearChanges
http://www.usemod.com/cgi-bin/mb.pl\?LionKimbro
2003-10-24T21:02:53\+00:00
unified rc for here and meatball
<span class="contributor"><span> \. \. \. \. </span>AlexSchroeder</span>
http://www.emacswiki.org/cgi-bin/community\?action=browse;id=RecentNearChanges;revision=1
EOT

update_page('RSS', "<rss $uri/mb.rdf $uri/community.rdf>");
test_page(get_page('RSS'), @Test);

# --------------------

aggregation:
print '[aggregation]';

clear_pages();
add_module('aggregate.pl');

update_page('InnocentPage', 'We are innocent!');
update_page('NicePage', 'You are nice.');
update_page('OtherPage', 'This is off-topic.');
update_page('Front_Page', q{Hello!
<aggregate "NicePage" "OtherPage">
The End.});

$page = get_page('Front_Page');
xpath_test($page, '//div[@class="content browse"]/p[text()="Hello! "]',
	   '//div[@class="aggregate journal"]/div[@class="page"]/h2/a[@class="local"][text()="NicePage"]',
	   '//div[@class="aggregate journal"]/div[@class="page"]/h2/a[@class="local"][text()="OtherPage"]',
	   '//div[@class="page"]/p[text()="You are nice."]',
	   '//div[@class="page"]/p[text()="This is off-topic."]',
	   '//div[@class="content browse"]/p[text()=" The End."]');

$page = get_page('action=aggregate id=Front_Page');
test_page($page, '<title>NicePage</title>',
	  '<title>OtherPage</title>',
	  '<link>http://localhost/wiki.pl/NicePage</link>',
	  '<link>http://localhost/wiki.pl/OtherPage</link>',
	  '<description>&lt;p&gt;You are nice.&lt;/p&gt;</description>',
	  '<description>&lt;p&gt;This is off-topic.&lt;/p&gt;</description>',
	  '<wiki:status>new</wiki:status>',
	  '<wiki:importance>major</wiki:importance>',
	  quotemeta('<wiki:history>http://localhost/wiki.pl?action=history;id=NicePage</wiki:history>'),
	  quotemeta('<wiki:diff>http://localhost/wiki.pl?action=browse;diff=1;id=NicePage</wiki:diff>'),
	  quotemeta('<wiki:history>http://localhost/wiki.pl?action=history;id=OtherPage</wiki:history>'),
	  quotemeta('<wiki:diff>http://localhost/wiki.pl?action=browse;diff=1;id=OtherPage</wiki:diff>'),
	  '<title>Wiki: Front Page</title>',
	  '<link>http://localhost/wiki.pl/Front_Page</link>',
	 );

remove_rule(\&AggregateRule);
delete $Action{aggregate};

# --------------------

redirection:
print '[redirection]';
clear_pages();

update_page('Miles_Davis', 'Featuring [[John Coltrane]]'); # plain link
update_page('John_Coltrane', '#REDIRECT Coltrane'); # no redirect
update_page('Sonny_Stitt', '#REDIRECT [[Stitt]]'); # redirect
update_page('Keith_Jarret', 'Plays with [[Gary Peacock]]'); # link to perm. anchor
update_page('Jack_DeJohnette', 'A friend of [::Gary Peacock]'); # define perm. anchor

test_page(get_page('Miles_Davis'), ('Featuring', 'John Coltrane'));
test_page(get_page('John_Coltrane'), ('#REDIRECT Coltrane'));
test_page(get_page('Sonny_Stitt'),
	  ('Status: 302', 'Location: .*wiki.pl\?action=browse;oldid=Sonny_Stitt;id=Stitt'));
test_page(get_page('Keith_Jarret'),
	  ('Plays with', 'wiki.pl/Jack_DeJohnette#Gary_Peacock', 'Keith Jarret', 'Gary Peacock'));
test_page(get_page('Gary_Peacock'),
	  ('Status: 302', 'Location: .*wiki.pl/Jack_DeJohnette#Gary_Peacock'));
test_page(get_page('Jack_DeJohnette'),
	  ('A friend of', 'Gary Peacock', 'name="Gary_Peacock"', 'class="definition"',
	   'title="Click to search for references to this permanent anchor"'));
test_page(update_page('Jack_DeJohnette', 'A friend of Gary Peacock.'),
	  'A friend of Gary Peacock.');
test_page(get_page('Keith_Jarret'),
	  ('wiki.pl\?action=edit;id=Gary_Peacock'));

# --------------------

summary:
print '[summary]';
clear_pages();

update_page('sum', 'some [http://example.com content]');
test_page(get_page('action=rc raw=1'), 'description: some content');

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

# --------------------

conflicts:
print '[conflicts]';

# Using the example files from the diff3 manual

my $lao_file = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
};

my $lao_file_1 = q{The Tao that can be told of is not the eternal Tao;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
};
my $lao_file_2 = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their simplicity,
And let there always be being,
  so we may see the result.
The two are the same,
But after they are produced,
  they have different names.
};

my $tzu_file = q{The Nameless is the origin of Heaven and Earth;
The named is the mother of all things.

Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
They both may be called deep and profound.
Deeper and more profound,
The door of all subtleties!
};

my $tao_file = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The named is the mother of all things.

Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their result.
The two are the same,
But after they are produced,
  they have different names.

  -- The Way of Lao-Tzu, tr. Wing-tsit Chan
};

clear_pages();

# simple edit

$ENV{'REMOTE_ADDR'} = 'confusibombus';
test_page(update_page('ConflictTest', $lao_file),
	  'The Way that can be told of is not the eternal Way');

# edit from another address should result in conflict warning

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $tzu_file),
	  'The Nameless is the origin of Heaven and Earth');

# test cookie!
test_page($redirect, map { UrlEncode($_); }
	  ('This page was changed by somebody else',
           'Please check whether you overwrote those changes'));

# test normal merging -- first get oldtime, then do two conflicting edits
# we need to wait at least a second after the last test in order to not
# confuse oddmuse.

sleep(2);

update_page('ConflictTest', $lao_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
my $oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $lao_file_1);

sleep(2);

# merge success has lines from both lao_file_1 and lao_file_2
$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $lao_file_2,
		      '', '', '', "oldtime=$oldtime"),
	  'The Tao that can be told of',     # file 1
	  'The name that can be named',      # both
	  'so we may see their simplicity'); # file 2

# test conflict during merging -- first get oldtime, then do two conflicting edits

sleep(2);

update_page('ConflictTest', $tzu_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
$oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $tao_file);

sleep(2);

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $lao_file,
		      '', '', '', "oldtime=$oldtime"),
	  q{<pre class="conflict">&lt;&lt;&lt;&lt;&lt;&lt;&lt; ancestor
=======
The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
&gt;&gt;&gt;&gt;&gt;&gt;&gt; other
</pre>},
	  q{<pre class="conflict">&lt;&lt;&lt;&lt;&lt;&lt;&lt; you
||||||| ancestor
They both may be called deep and profound.
Deeper and more profound,
The door of all subtleties!
=======

  -- The Way of Lao-Tzu, tr. Wing-tsit Chan
&gt;&gt;&gt;&gt;&gt;&gt;&gt; other
</pre>});

@Test = split('\n',<<'EOT');
This page was changed by somebody else
The changes conflict
EOT

test_page($redirect, map { UrlEncode($_); } @Test); # test cookie!

# test conflict during merging without merge! -- first get oldtime, then do two conflicting edits

AppendStringToFile($ConfigFile, "\$ENV{'PATH'} = '';\n");

sleep(2);

update_page('ConflictTest', $lao_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
$oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $lao_file_1);

sleep(2);

# merge not available -- must look for message
$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $lao_file_2,
		      '', '', '', "oldtime=$oldtime"),
	  'The Way that can be told of is not the eternal Way',   # file 2
	  'so we may see their simplicity',                       # file 2
	  'so we may see the result');                            # file 2

test_page($redirect, map { UrlEncode($_) }
	  ('This page was changed by somebody else',
           'Please check whether you overwrote those changes')); # test cookie!

# --------------------

html_cache:
print '[html cache]';

### Maintenance with cache resetting

clear_pages();
$str = 'This is a WikiLink.';

# this setting produces no link.
AppendStringToFile($ConfigFile, "\$WikiLinks = 0;\n");
test_page(update_page('CacheTest', $str, '', 1), $str);

# now change the setting, you still get no link because the cache has
# not been updated.
AppendStringToFile($ConfigFile, "\$WikiLinks = 1;\n");
test_page(get_page('CacheTest'), $str);

# refresh the cache
test_page(get_page('action=clear pwd=foo'), 'Clear Cache');

# now there is a link
# This is a WikiLink<a class="edit" title="Click to edit this page" href="http://localhost/wiki.pl\?action=edit;id=WikiLink">\?</a>.
xpath_test(get_page('CacheTest'), '//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/wiki.pl?action=edit;id=WikiLink"][text()="?"]');

# --------------------

search_and_replace:
print '[search and replace]';

clear_pages();
add_module('mac.pl');

# Test search

update_page('SearchAndReplace', 'This is fooz and this is barz.', '', 1);
$page = get_page('search=fooz');
test_page($page,
	  '<h1>Search for: fooz</h1>',
	  '<p class="result">1 pages found.</p>',
	  'This is <strong>fooz</strong> and this is barz.');
xpath_test($page, '//span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/SearchAndReplace"][text()="SearchAndReplace"]');

# Brackets in the page name

test_page(update_page('Search (and replace)', 'Muu'),
	  'search=%22Search\+%5c\(and\+replace%5c\)%22');

# Make sure only admins can replace

test_page(get_page('search=foo replace=bar'),
	  'This operation is restricted to administrators only...');

# Simple replace where the replacement pattern is found

@Test = split('\n',<<'EOT');
<h1>Replaced: fooz -&gt; fuuz</h1>
<p class="result">1 pages found.</p>
This is <strong>fuuz</strong> and this is barz.
EOT

test_page(get_page('search=fooz replace=fuuz pwd=foo'), @Test);

# Replace with backreferences, where the replacement pattern is no longer found

test_page(get_page('search=([a-z]%2b)z replace=x%241 pwd=foo'), '0 pages found');
test_page(get_page('SearchAndReplace'), 'This is xfuu and this is xbar.');

# Create an extra page that should not be found
update_page('NegativeSearchTest', 'this page contains an ab');
update_page('NegativeSearchTestTwo', 'this page contains another ab');
test_page(get_page('search=xb replace=[xa]b pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), 'This is xfuu and this is \[xa\]bar.');

# Handle quoting
test_page(get_page('search=xfuu replace=/fuu/ pwd=foo'), '1 pages found'); # not two ab!
test_page(get_page('SearchAndReplace'), 'This is /fuu/ and this is \[xa\]bar.');
test_page(get_page('search=/fuu/ replace={{fuu}} pwd=foo'), '1 pages found');
test_page(get_page('SearchAndReplace'), 'This is {{fuu}} and this is \[xa\]bar.');

## Check headers especially the quoting of non-ASCII characters.

$page = update_page("Alexander_Schröder", "Edit [[Alexander Schröder]]!");
xpath_test($page,
	   Encode::encode_utf8('//h1/a[@title="Click to search for references to this page"][@href="http://localhost/wiki.pl?search=%22Alexander+Schr%c3%b6der%22"][text()="Alexander Schröder"]'),
	   Encode::encode_utf8('//a[@class="local"][@href="http://localhost/wiki.pl/Alexander_Schr%c3%b6der"][text()="Alexander Schröder"]'));

xpath_test(update_page('IncludeSearch',
		       "first line\n<search \"ab\">\nlast line"),
	   '//p[text()="first line "]', # note the NL -> SPC
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTest"][text()="NegativeSearchTest"]',
	   '//div[@class="search"]/p/span[@class="result"]/a[@class="local"][@href="http://localhost/wiki.pl/NegativeSearchTestTwo"][text()="NegativeSearchTestTwo"]',
	  '//p[text()=" last line"]'); # note the NL -> SPC

# --------------------

banning:
print '[banning]';

clear_pages();
$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "# Foo\n#Bar\n$localhost\n", 'banning me'),
	  'Describe the new page here');

## Edit banned hosts as admin should succeed

test_page(update_page('BannedHosts', "#Foo\n#Bar\n$localhost\n", 'banning me', 0, 1),
	  "Foo",
	  $localhost);

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "Something else.", 'banning me'),
	  "Foo",
	  $localhost);

## Try to edit another page as a banned user

test_page(update_page('BannedUser', 'This is a test which should fail.', 'banning test'),
	  'Describe the new page here');

## Try to edit the same page as a banned user with admin password

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1),
	  "This is a test");

## Unbann myself again, testing the regexp

test_page(update_page('BannedHosts', "#Foo\n#Bar\n", 'banning me', 0, 1), "Foo", "Bar");

## Banning content

@Test = split('\n',<<'EOT');
banned text
wiki administrator
matched
See .*BannedContent.* for more information
EOT

update_page('BannedContent', "# cosa\nmafia\n#nostra\n", 'one banned word', 0, 1);
test_page(update_page('CriminalPage', 'This is about http://mafia.example.com'),
	  'Describe the new page here');
test_page($redirect, @Test);
test_page(update_page('CriminalPage', 'This is about http://nafia.example.com'),
	  "This is about", "http://nafia.example.com");
test_page(update_page('CriminalPage', 'This is about the cosa nostra'),
	  'cosa nostra');
test_page(update_page('CriminalPage', 'This is about the mafia'),
	  'This is about the mafia'); # not in an url

# --------------------

journal:
print '[journal]';

## Create diary pages

clear_pages();

update_page('2003-06-13', "Freitag");
update_page('2003-06-14', "Samstag");
update_page('2003-06-15', "Sonntag");

@Test = split('\n',<<'EOT');
This is my journal
2003-06-15
Sonntag
2003-06-14
Samstag
EOT

test_page(update_page('Summary', "This is my journal:\n\n<journal 2>"), @Test);
test_page(update_page('2003-01-01', "This is my journal -- recursive:\n\n<journal>"), @Test);
push @Test, 'journal';
test_page(update_page('2003-01-01', "This is my journal -- truly recursive:\n\n<journal>"), @Test);

test_page(update_page('Summary', "Counting down:\n\n<journal 2>"),
	  '2003-06-15(.|\n)*2003-06-14');

test_page(update_page('Summary', "Counting up:\n\n<journal 3 reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14');

$page = update_page('Summary', "Counting down:\n\n<journal>");
test_page($page, '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');
negative_xpath_test($page, '//h1/a[not(text())]');

test_page(update_page('Summary', "Counting up:\n\n<journal reverse>"),
	  '2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14(.|\n)*2003-06-15');

AppendStringToFile($ConfigFile, "\$JournalLimit = 2;\n\$ComentsPrefix = 'Talk about ';\n");

$page = update_page('Summary', "Testing the limit of two:\n\n<journal>");
test_page($page, '2003-06-15', '2003-06-14');
test_page_negative($page, '2003-06-13', '2003-01-01');

test_page(get_page('action=browse id=Summary pwd=foo'),
	  '2003-06-15(.|\n)*2003-06-14(.|\n)*2003-06-13(.|\n)*2003-01-01');

# --------------------

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

download:
print '[download]';

clear_pages();

test_page_negative(get_page('HomePage'), 'logo');
AppendStringToFile($ConfigFile, "\$LogoUrl = '/pic/logo.png';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="/pic/logo.png"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$LogoUrl = 'Logo';\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="Logo"][@alt="[Home]"]');
update_page('Logo', "#FILE image/png\niVBORw0KGgoAAAA");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl/download/Logo"][@alt="[Home]"]');
AppendStringToFile($ConfigFile, "\$UsePathInfo = 0;\n");
xpath_test(get_page('HomePage'), '//a[@class="logo"]/img[@class="logo"][@src="http://localhost/wiki.pl?action=download;id=Logo"][@alt="[Home]"]');

# --------------------

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
