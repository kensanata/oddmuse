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
undef $/;
$| = 1; # no output buffering

# Create temporary data directory as expected by the script
# and create a config file in this directory.

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
print F "\$NetworkFile = 1;\n";
print F "\$AdminPass = 'foo';\n";
close(F);

sub update_page {
  my ($id, $text, $summary, $minor, $admin) = @_;
  print '*';
  my $pwd = $admin ? 'foo' : 'wrong';
  $text = UrlEncode($text);
  $summary = UrlEncode($summary);
  $minor = 0 unless $minor;
  open(F,"perl wiki.pl action=edit id=$id pwd=$pwd |");
  my $output = <F>;
  close F;
  $output =~ /name="oldtime" value="([0-9]+)"/;
  my $oldtime = $1;
  system("perl wiki.pl oldtime=$oldtime title=$id summary=$summary text=$text pwd=$pwd > /dev/null");
  open(F,"perl wiki.pl action=browse id=$id|");
  my $output = <F>;
  close F;
  return $output;
}

sub get_page {
  my ($params) = @_;
  print '*';
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

### COMPLEX HTML OUTPUT TESTS

## Try to edit BanList

@Test = split('\n',<<'EOT');
Describe the new page here
EOT

test_page(update_page('BannedHosts', "Foo\nBar\n localhost\n", 'banning me'), @Test);

## Try to edit BanList

@Test = split('\n',<<'EOT');
Foo
 localhost
EOT

test_page(update_page('BannedHosts', "Foo\n localhost\n", 'banning me', 0, 1), @Test);

## Try to edit another page as a banned user

@Test = split('\n',<<'EOT');
Describe the new page here
EOT

test_page(update_page('BannedUser', 'This is a test.', 'banning test'), @Test);

## Try to edit the same page as a banned user with admin password

@Test = split('\n',<<'EOT');
This is a test
EOT

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1), @Test);

## Unbann myself again, testing the regexp

@Test = split('\n',<<'EOT');
Foo
localhost
EOT

test_page(update_page('BannedHosts', "Foo\nlocalhost\n", 'banning me', 0, 1), @Test);

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

### SIMPLE MARKUP TESTS

%Test = split('\n',<<'EOT');
ordinary text
ordinary text
\nparagraph
<p>paragraph
* one\n*two
<ul><li>one <li>two</ul>
# one\n# two
<ol><li>one <li>two</ol>
* one\n#two
<ul><li>one </ul><ol><li>two</ol>
* one\n**two
<ul><li>one <ul><li>two</ul></ul>
WikiWord
WikiWord<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>
WikiWord:
WikiWord<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=WikiWord">?</a>:
OddMuse
OddMuse<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>
OddMuse:
OddMuse<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=OddMuse">?</a>:
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
http://www.emacswiki.org/
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>
http://www.emacswiki.org.
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>.
http://www.emacswiki.org,
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
http://www.emacswiki.org;
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>;
http://www.emacswiki.org!
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org?
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>?
http://www.emacswiki.org/?
<a href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>?
"http://www.emacswiki.org".
"<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>".
http://www.emacswiki.org,
<a href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
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
close(F);
update_page('SandBox', "This page exists.");
update_page('Banana', "This page exists also.");

%Test = split('\n',<<'EOT');
[[SandBox|play here]]
<a href="http://localhost/test-wrapper.pl/SandBox">play here</a>
[[FooBar|do not play here]]
[FooBar<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=FooBar">?</a> do not play here]
[[Banana|Not a pear]]
<a href="http://localhost/test-wrapper.pl/Banana">Not a pear</a>
[[Appel|Not a pear]]
[Appel<a href="http://localhost/test-wrapper.pl?action=edit&amp;id=Appel">?</a> Not a pear]
EOT

run_tests();

### END OF TESTS

print "\n";
print "$passed passed, $failed failed.\n";
