#!/usr/bin/perl

# Copyright (C) 2003  Alex Schroeder <alex@emacswiki.org>
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

# This program uses test-wrapper.el to run ApplyRules,
# because ApplyRules prints the result to stdout.

# Import the functions

package OddMuse;
$_ = 'nocgi';
do 'wiki.pl';

my ($passed, $failed) = (0, 0);
my $resultfile = "/tmp/test-markup-result-$$";
my $redirect;
undef $/;
$| = 1; # no output buffering

sub update_page {
  my ($id, $text, $summary, $minor, $admin, @rest) = @_;
  print '*';
  my $pwd = $admin ? 'foo' : 'wrong';
  $text = UrlEncode($text);
  $summary = UrlEncode($summary);
  $minor = $minor ? 'on' : 'off';
  my $rest = join(' ', @rest);
  $redirect = `perl wiki.pl Save=1 title=$id summary=$summary recent_edit=$minor text=$text pwd=$pwd $rest`;
  open(F,"perl wiki.pl action=browse id=$id|");
  my $output = <F>;
  close F;
  return $output;
}

sub get_page {
  my ($params) = @_;
  print '+';
  open(F,"perl wiki.pl $params |");
  my $output = <F>;
  close F;
  return $output;
}

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
    open(F,"|perl test-wrapper.pl > $resultfile");
    print F $input;
    close F;
    open(F,$resultfile);
    my $output = <F>;
    close F;
    if ($output eq $New{$input}) {
      $passed++;
    } else {
      $failed++;
      print "\n\"", $input, '" -> "', $output, '" instead of "', $New{$input}, "\"\n";
    }
  }
}

# Create temporary data directory as expected by the script

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';

# create simple config file

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);

# --------------------

print '[clusters]';

update_page('ClusterIdea', 'This is just a page.', 'one');
update_page('ClusterIdea', 'This is just a page.\nBut somebody has to do it.', 'two');
update_page('ClusterIdea', 'This is just a page.\nNobody wants it.', 'three', 1);
update_page('ClusterIdea', 'MainPage: This is just a page.\nBut somebody has to do it.', 'four');

@Test = split('\n',<<'EOT');
Cluster:.*MainPage.*Related changes
EOT

test_page(get_page('action=rc'), @Test);

@Test = split('\n',<<'EOT');
Cluster:.*MainPage.*Related changes
ClusterIdea.*two
ClusterIdea.*one
EOT

test_page(get_page('action=rc all=1'), @Test);

@Test = split('\n',<<'EOT');
Cluster:.*MainPage.*Related changes
ClusterIdea.*three
ClusterIdea.*two
ClusterIdea.*one
EOT

test_page(get_page('action=rc all=1 showedit=1'), @Test);

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*history.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1
EOT

update_page('MainPage', 'Finally the main page.');
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage'), @Test);

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1
EOT

test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage showedit=1'), @Test);
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1'), @Test);

@Test = split('\n',<<'EOT');
Finally the main page
Updates in the last [0-9]+ days
diff.*ClusterIdea.*five
diff.*ClusterIdea.*four
for.*MainPage.*only
1 day
action=browse;id=MainPage;rcclusteronly=MainPage;days=1
EOT

update_page('ClusterIdea', 'MainPage: Somebody has to do it.', 'five', 1);
test_page(get_page('action=browse id=MainPage rcclusteronly=MainPage all=1 showedit=1'), @Test);

# --------------------

print '[conflicts]';

# simple edit

@Test = split('\n',<<'EOT');
test test test
EOT

$ENV{'REMOTE_ADDR'} = 'confusibombus';
test_page(update_page('ConflictTest', "test\ntest\ntest\n"), @Test);

# edit from another address should result in conflict warning

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', "test\ntest\ntest\nend\n"), @Test);

@Test = split('\n',<<'EOT');
This page was changed by somebody else
Please check whether you overwrote those changes
EOT

test_page($redirect, map { UrlEncode($_); } @Test); # test cookie!

# test normal merging -- first get oldtime, then do two conflicting edits

@Test = split('\n',<<'EOT');
foo test bar end
EOT

update_page('ConflictTest', "test\ntest\ntest\nend\n");

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
my $oldtime = $1;

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', "foo\ntest\ntest\nend\n");

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', "test\ntest\nbar\nend\n", '', '', '', "oldtime=$oldtime"), @Test);

# test conflict during merging -- first get oldtime, then do two conflicting edits

my $str = QuoteHtml(<<'EOT');
test
<<<<<<< you
bar
||||||| ancestor
test
=======
foo
>>>>>>> other
test
EOT
$str = "\n<pre>\n$str</pre>\n\n";
@Test = ($str);

update_page('ConflictTest', "test\ntest\ntest\nend\n");

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
my $oldtime = $1;

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', "test\nfoo\ntest\nend\n");

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', "test\nbar\ntest\nend\n", '', '', '', "oldtime=$oldtime"), @Test);

@Test = split('\n',<<'EOT');
This page was changed by somebody else
The changes conflict
EOT

test_page($redirect, map { UrlEncode($_); } @Test); # test cookie!

# test conflict during merging without merge! -- first get oldtime, then do two conflicting edits

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$ENV{'PATH'} = '';\n";
close(F);

@Test = split('\n',<<'EOT');
test bar test end
EOT

update_page('ConflictTest', "test\ntest\ntest\nend\n");

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
my $oldtime = $1;

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', "test\nfoo\ntest\nend\n");

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', "test\nbar\ntest\nend\n", '', '', '', "oldtime=$oldtime"), @Test);

@Test = split('\n',<<'EOT');
This page was changed by somebody else
Please check whether you overwrote those changes
EOT

test_page($redirect, map { UrlEncode($_); } @Test); # test cookie!

# --------------------

print '[html cache]';

# create config file with WikiLinks=0

open(F,'>/tmp/oddmuse/config');
print F "\$WikiLinks = 0;\n";
print F "\$SurgeProtection = 0;\n";
close(F);

### Maintenance with cache resetting

@Test = split('\n',<<'EOT');
This is a WikiLink.
EOT

test_page(update_page('CacheTest', 'This is a WikiLink.', '', 1), @Test);

# create new config file with WikiLinks=1

open(F,'>/tmp/oddmuse/config');
print F "\$WikiLinks = 1;\n";
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

# without new edit, the cached version persists

@Test = split('\n',<<'EOT');
This is a WikiLink.
EOT

test_page(get_page('CacheTest'), @Test);

# now run maintenance without refreshing the cache

get_page('action=maintain');
test_page(get_page('CacheTest'), @Test);

# a second maintenance run without admin password has no effect, either

get_page('action=maintain cache=1');
test_page(get_page('CacheTest'), @Test);

# new refresh the cache

@Test = split('\n',<<'EOT');
This is a WikiLink<a href="http://localhost/wiki.pl\?action=edit;id=WikiLink">\?</a>.
EOT

get_page('action=maintain cache=1 pwd=foo');
test_page(get_page('CacheTest'), @Test);

# --------------------

print '[search and replace]';

# create config file

open(F,'>/tmp/oddmuse/config');
print F "\$NetworkFile = 1;\n";
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

# Test search

@Test = split('\n',<<'EOT');
<h1>Search for: fooz</h1>
<h2>1 pages found:</h2>
<span class="result"><a href="http://localhost/wiki.pl/SearchAndReplace">SearchAndReplace</a></span>
This is fooz and this is barz.
EOT

update_page('SearchAndReplace', 'This is fooz and this is barz.', '', 1);
test_page(get_page('search=fooz'), @Test);

# Make sure only admins can replace

@Test = split('\n',<<'EOT');
This operation is restricted to administrators only...
EOT

test_page(get_page('search=foo replace=bar'), @Test);

# Simple replace

@Test = split('\n',<<'EOT');
<h1>Replaced: fooz -&gt; fuuz</h1>
<h2>1 pages found:</h2>
This is fuuz and this is barz.
EOT

test_page(get_page('search=fooz replace=fuuz pwd=foo'), @Test);

# Replace with backreferences

@Test = split('\n',<<'EOT');
This is xfuu and this is xbar.
EOT

get_page('search=([a-z]%2b)z replace=x%241 pwd=foo');
test_page(get_page('SearchAndReplace'), @Test);

## Check headers especially the quoting of non-ASCII characters.

@Test = split('\n',<<'EOT');
<h1><a href="http://localhost/wiki.pl\?search=Alexander\+Schr\%f6der">Alexander Schröder</a></h1>
Edit <a href="http://localhost/wiki.pl/Alexander_Schr\%f6der">Alexander Schröder</a>!
EOT

test_page(update_page('Alexander_Schr\%f6der', "Edit [[Alexander Schröder]]!"), @Test);

# --------------------

print '[banning]';

## Edit banned hosts as a normal user should fail

my $localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;

@Test = split('\n',<<'EOT');
Describe the new page here
EOT

test_page(update_page('BannedHosts', "Foo\nBar\n $localhost\n", 'banning me'), @Test);

## Edit banned hosts as admin should succeed

@Test = split('\n',<<"EOT");
Foo
 $localhost
EOT

test_page(update_page('BannedHosts', "Foo\nBar\n $localhost\n", 'banning me', 0, 1), @Test);

## Edit banned hosts as a normal user should fail

@Test = split('\n',<<"EOT");
Foo
 $localhost
EOT

test_page(update_page('BannedHosts', "Something else.", 'banning me'), @Test);

## Try to edit another page as a banned user

@Test = split('\n',<<'EOT');
Describe the new page here
EOT

test_page(update_page('BannedUser', 'This is a test which should fail.', 'banning test'), @Test);

## Try to edit the same page as a banned user with admin password

@Test = split('\n',<<'EOT');
This is a test
EOT

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1), @Test);

## Unbann myself again, testing the regexp

@Test = split('\n',<<'EOT');
Foo
Bar
EOT

test_page(update_page('BannedHosts', "Foo\nBar\n", 'banning me', 0, 1), @Test);

# --------------------

print '[lock on creation]';

## Create a sample page, and test for regular expressions in the output

@Test = split('\n',<<'EOT');
SandBox
This is a test.
<h1><a href="http://localhost/wiki.pl\?search=SandBox">SandBox</a></h1>
EOT

test_page(update_page('SandBox', 'This is a test.', 'first test'), @Test);

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
## The OddMuse intermap entry is required for later tests.

@Test = split('\n',<<'EOT');
OddMuse
EOT

test_page(update_page('InterMap', " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n", 'required', 0, 1), @Test);

## Verify the InterMap stayed locked

@Test = split('\n',<<'EOT');
OddMuse
EOT

test_page(update_page('InterMap', "All your edits are blong to us!\n", 'required'), @Test);

# --------------------

print '[journal]';

## Create diary pages

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

@Test = split('\n',<<'EOT');
2003-06-15(.|\n)*2003-06-14
EOT

test_page(update_page('Summary', "Counting down:\n\n<journal 2>"), @Test);

@Test = split('\n',<<'EOT');
2003-01-01(.|\n)*2003-06-13(.|\n)*2003-06-14
EOT

test_page(update_page('Summary', "Counting up:\n\n<journal 3 reverse>"), @Test);

# --------------------

print '[markup]';

%Test = split('\n',<<'EOT');
ordinary text
ordinary text
\nparagraph
<p>paragraph
* one\n*two
<ul><li>one </li><li>two</li></ul>
# one\n# two
<ol><li>one </li><li>two</li></ol>
* one\n#two
<ul><li>one </li></ul><ol><li>two</li></ol>
* one\n**two
<ul><li>one <ul><li>two</li></ul></li></ul>
* one\n**two\n***three\n*four
<ul><li>one <ul><li>two <ul><li>three </li></ul></li></ul></li><li>four</li></ul>
* one\n**two\n***three\n*four\n**five\n*six
<ul><li>one <ul><li>two <ul><li>three </li></ul></li></ul></li><li>four <ul><li>five </li></ul></li><li>six</li></ul>
* one\n* two\n** one and two\n** two and three\n* three
<ul><li>one </li><li>two <ul><li>one and two </li><li>two and three </li></ul></li><li>three</li></ul>
# one\n# two\n## one and two\n## two and three\n# three
<ol><li>one </li><li>two <ol><li>one and two </li><li>two and three </li></ol></li><li>three</li></ol>
: one\n: two\n:: one and two\n:: two and three\n: three
<dl class="quote"><dt /><dd>one </dd><dt /><dd>two <dl class="quote"><dt /><dd>one and two </dd><dt /><dd>two and three </dd></dl></dd><dt /><dd>three</dd></dl>
;one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins </dd><dt>two</dt><dd>zwei</dd></dl>
This is ''emphasized''.
This is <em>emphasized</em>.
This is '''strong'''.
This is <strong>strong</strong>.
This is ''longer emphasized'' text.
This is <em>longer emphasized</em> text.
This is '''longer strong''' text.
This is <strong>longer strong</strong> text.
This is ''emphasized text containing '''longer strong''' text''.
This is <em>emphasized text containing <strong>longer strong</strong> text</em>.
WikiWord
WikiWord<a href="http://localhost/test-wrapper.pl?action=edit;id=WikiWord">?</a>
WikiWord:
WikiWord<a href="http://localhost/test-wrapper.pl?action=edit;id=WikiWord">?</a>:
OddMuse
OddMuse<a href="http://localhost/test-wrapper.pl?action=edit;id=OddMuse">?</a>
OddMuse:
OddMuse<a href="http://localhost/test-wrapper.pl?action=edit;id=OddMuse">?</a>:
OddMuse:test
<a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test">OddMuse:test</a>
OddMuse:test: or not
<a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test">OddMuse:test</a>: or not
OddMuse:test, and foo
<a href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test">OddMuse:test</a>, and foo
Foo::Bar
Foo::Bar
||one||
<table class="user"><tr><td>one</td></tr></table>
introduction\n\n||one||two||three||\n||||one two||three||
introduction<p><table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table><p>footer
introduction\n\n||one||two||three||\n||||one two||three||\n\nfooter
introduction<p><table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table><p>footer
http://www.emacswiki.org
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>
<http://www.emacswiki.org>
<<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>>
http://www.emacswiki.org/
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>
http://www.emacswiki.org.
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>.
http://www.emacswiki.org,
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
http://www.emacswiki.org;
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>;
http://www.emacswiki.org:
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>:
http://www.emacswiki.org?
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>?
http://www.emacswiki.org/?
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>?
http://www.emacswiki.org!
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org'
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>'
http://www.emacswiki.org"
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>"
http://www.emacswiki.org!
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org(
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>(
http://www.emacswiki.org)
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>)
http://www.emacswiki.org&
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>&
http://www.emacswiki.org#
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>#
http://www.emacswiki.org%
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>%
[http://www.emacswiki.org]
<a href="http://www.emacswiki.org">[1]</a>
[http://www.emacswiki.org] and [http://www.emacswiki.org]
<a href="http://www.emacswiki.org">[1]</a> and <a href="http://www.emacswiki.org">[2]</a>
[http://www.emacswiki.org],
<a href="http://www.emacswiki.org">[1]</a>,
[http://www.emacswiki.org and a label]
<a href="http://www.emacswiki.org">[and a label]</a>
[file://home/foo/tutorial.pdf local link]
<a href="file://home/foo/tutorial.pdf">[local link]</a>
file://home/foo/tutorial.pdf
<a href="file://home/foo/tutorial.pdf">file://home/foo/tutorial.pdf</a>
file:///home/foo/tutorial.pdf
file:///home/foo/tutorial.pdf
mailto:alex@emacswiki.org
<a href="mailto:alex@emacswiki.org">mailto:alex@emacswiki.org</a>
 source
<pre> source</pre>
 source\n etc\n
<pre> source\n etc\n</pre>
 source\n \n etc\n
<pre> source\n \n etc\n</pre>
 source\n \n etc\n\nother
<pre> source\n \n etc\n</pre><p>other
[[SandBox|play here]]
[[<a href="http://localhost/test-wrapper.pl/SandBox">SandBox</a>|play here]]
[[Appel|Not a pear]]
[[Appel|Not a pear]]
EOT

run_tests();

# Create temporary data directory as expected by the script
# and create a config file in this directory.

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
print F "\$BracketWiki = 1;\n";
print F "\$AllNetworkFiles = 1;\n";
print F "\$SurgeProtection = 0;\n";
close(F);
update_page('SandBox', "This page exists.");
update_page('Banana', "This page exists also.");

%Test = split('\n',<<'EOT');
[[SandBox|play here]]
<a href="http://localhost/test-wrapper.pl/SandBox">play here</a>
[[FooBar|do not play here]]
[FooBar<a href="http://localhost/test-wrapper.pl?action=edit;id=FooBar">?</a> do not play here]
[[Banana|Not a pear]]
<a href="http://localhost/test-wrapper.pl/Banana">Not a pear</a>
[[Appel|Not a pear]]
[Appel<a href="http://localhost/test-wrapper.pl?action=edit;id=Appel">?</a> Not a pear]
file://home/foo/tutorial.pdf
<a href="file://home/foo/tutorial.pdf">file://home/foo/tutorial.pdf</a>
file:///home/foo/tutorial.pdf
<a href="file:///home/foo/tutorial.pdf">file:///home/foo/tutorial.pdf</a>
EOT

run_tests();

# --------------------

print '[revisions]';

## Test revision and diff stuff

update_page('KeptRevisions', 'first');
update_page('KeptRevisions', 'second');
update_page('KeptRevisions', 'third');
update_page('KeptRevisions', 'fourth', '', 1);
update_page('KeptRevisions', 'fifth', '', 1);

# Show the current revision

@Test = split('\n',<<'EOT');
KeptRevisions
fifth
EOT

test_page(get_page(KeptRevisions), @Test);

# Show the other revision

@Test = split('\n',<<'EOT');
Showing revision 2
second
EOT

test_page(get_page('action=browse revision=2 id=KeptRevisions'), @Test);

@Test = split('\n',<<'EOT');
Showing revision 1
first
EOT

test_page(get_page('action=browse revision=1 id=KeptRevisions'), @Test);

# Show the current revision if an inexisting revision is asked for

@Test = split('\n',<<'EOT');
Revision 9 not available \(showing current revision instead\)
fifth
EOT

test_page(get_page('action=browse revision=9 id=KeptRevisions'), @Test);

@Test = split('\n',<<'EOT');
Revision 0 not available \(showing current revision instead\)
fifth
EOT

test_page(get_page('action=browse revision=0 id=KeptRevisions'), @Test);

# Show a major diff

@Test = split('\n',<<'EOT');
Difference \(from prior major revision\)
second
fifth
EOT

test_page(get_page('action=browse diff=1 id=KeptRevisions'), @Test);

# Show a minor diff

@Test = split('\n',<<'EOT');
Difference \(from prior minor revision\)
fourth
fifth
EOT

test_page(get_page('action=browse diff=2 id=KeptRevisions'), @Test);

# Show a diff from the history page comparing two specific revisions

@Test = split('\n',<<'EOT');
Difference \(from revision 2 to revision 4\)
second
fourth
EOT

test_page(get_page('action=browse diff=1 revision=4 diffrevision=2 id=KeptRevisions'), @Test);

### END OF TESTS

print "\n";
print "$passed passed, $failed failed.\n";
