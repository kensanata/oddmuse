#!/usr/bin/perl -w

# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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
$RunCGI = 0;
do 'wiki.pl';

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
  open(F,"perl wiki.pl action=browse id=$id|");
  my $output = <F>;
  close F;
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
      print "\n\n---- input:\n", $input,
	    "\n---- output:\n", $output,
            "\n---- instead of:\n", $New{$input}, "\n----\n";
    }
  }
}

# Create temporary data directory as expected by the script

my $str;

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';

use Getopt::Std;
our($opt_m, $opt_x);
getopts('mx');

goto markup if $opt_m;
goto fixme if $opt_x;

$ENV{'REMOTE_ADDR'} = 'test-markup';

# --------------------

print '[pagenames]';

open(F,'>/tmp/oddmuse/config');
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

update_page('.dotfile', 'old content', 'older summary');
update_page('.dotfile', 'some content', 'some summary');
test_page(get_page('.dotfile'), 'some content');
test_page(get_page('action=browse id=.dotfile revision=1'), 'old content');
test_page(get_page('action=history id=.dotfile'), 'older summary', 'some summary');

# --------------------

print '[rollback]';

open(F,'>/tmp/oddmuse/config');
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

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
update_page('MinorPage', 'Ramtatam', 'tester', 1);

test_page(get_page('NicePage'), 'Bad content');
test_page(get_page('InnocentPage'), 'Lamb');
get_page('action=rc all=1 pwd=foo') =~ /.*action=rollback;to=([0-9]+).*?-- good guy two/;

test_page(get_page("action=rollback to=$1"), 'restricted to administrators');
test_page(get_page("action=rollback to=$1 pwd=foo"),
	  'Rolling back changes', 'NicePage rolled back', 'OtherPage rolled back');
test_page(get_page('NicePage'), 'Nice content');
test_page(get_page('OtherPage'), 'Other cute content 12');
test_page(get_page('EvilPage'), 'DeletedPage');
test_page(get_page('AnotherEvilPage'), 'DeletedPage');
test_page(get_page('InnocentPage'), 'Lamb');
test_page(get_page('action=rc showedit=1'),
	  'MinorPage</a>[ .]*test-markup *<strong>-- *Rollback to [^<>]*</strong> *<em>\(minor\)</em></li>',
	  'NicePage</a>[ .]*test-markup *<strong>-- *Rollback to [^<>]*</strong> *</li>');

# --------------------

print '[clusters]';

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$PageCluster = 'Cluster';\n";
close(F);

update_page('ClusterIdea', 'This is just a page.', 'one');
update_page('ClusterIdea', "This is just a page.\nBut somebody has to do it.", 'two');
update_page('ClusterIdea', "This is just a page.\nNobody wants it.", 'three', 1);
update_page('ClusterIdea', "MainPage\nThis is just a page.\nBut somebody has to do it.", 'four');

@Test = split('\n',<<'EOT');
Cluster.*MainPage
EOT

test_page(get_page('action=rc'), @Test);

@Test = split('\n',<<'EOT');
Cluster.*MainPage
ClusterIdea.*two
ClusterIdea.*one
EOT

test_page(get_page('action=rc all=1'), @Test);

@Test = split('\n',<<'EOT');
Cluster.*MainPage
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
action=browse;id=MainPage;rcclusteronly=MainPage;days=1;all=0;showedit=0
EOT

update_page('MainPage', 'Finally the main page.');
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

# --------------------

print '[rss]';

# create simple config file

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);

use Cwd;
$dir = cwd;
$uri = "file://$dir";

# RSS 2.0
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

@Test = split('\n',<<'EOT');
<div class="rss"><ul><li> <a title="999" href="http://www.heise.de/tp/deutsch/inhalt/te/15886/1.html">Berufsverbot für Mediendesigner\?</a></li>
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

update_page('RSS', "<rss $uri/heise.rdf>");
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

print '[redirection]';

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

# --------------------

print '[recent changes]';

$host1 = 'tisch';
$host2 = 'stuhl';
$ENV{'REMOTE_ADDR'} = $host1;
update_page('Mendacibombus', 'This is the place.', 'samba', 0, 0, ('username=berta'));
update_page('Bombia', 'This is the time.', 'tango', 0, 0, ('username=alex'));
$ENV{'REMOTE_ADDR'} = $host2;
update_page('Confusibombus', 'This is order.', 'ballet', 1, 0, ('username=berta'));
update_page('Mucidobombus', 'This is chaos.', 'tarantella', 0, 0, ('username=alex'));

@Positives = split('\n',<<'EOT');
for time or place only
Mendacibombus.*samba
Bombia.*tango
EOT

@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Mucidobombus
tarantella
EOT

$page = get_page('action=rc rcfilteronly=time%20or%20place');
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

$page = get_page('action=rc rcfilteronly=order%20or%20chaos');
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

$page = get_page('action=rc rcfilteronly=order%20and%20chaos');
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


system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);

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

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$ENV{'PATH'} = '';\n";
close(F);

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

test_page(get_page('CacheTest'), @Test);

# refresh the cache using the all action

@Test = split('\n',<<'EOT');
This is a WikiLink<a class="edit" title="Click to edit this page" href="http://localhost/wiki.pl\?action=edit;id=WikiLink">\?</a>.
EOT

get_page('action=all cache=0');
test_page(get_page('CacheTest'), @Test);

# --------------------

print '[search and replace]';

open(F,'>/tmp/oddmuse/config');
print F "\$NetworkFile = 1;\n";
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

# Test search

@Test = split('\n',<<'EOT');
<h1>Search for: fooz</h1>
<p>1 pages found.</p>
<span class="result"><a class="local" href="http://localhost/wiki.pl/SearchAndReplace">SearchAndReplace</a></span>
This is <strong>fooz</strong> and this is barz.
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
<p>1 pages found.</p>
This is <strong>fuuz</strong> and this is barz.
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
<h1><a title="Click to search for references to this page" href="http://localhost/wiki.pl\?search=Alexander\+Schr\%c3\%b6der">Alexander Schröder</a></h1>
Edit <a class="local" href="http://localhost/wiki.pl/Alexander_Schr\%c3\%b6der">Alexander Schröder</a>!
EOT

test_page(update_page("Alexander_Schröder", "Edit [[Alexander Schröder]]!"), @Test);

# --------------------

print '[banning]';

open(F,'>/tmp/oddmuse/config');
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

## Edit banned hosts as a normal user should fail

$localhost = 'confusibombus';
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

## Banning content

open(F,'>/tmp/oddmuse/config');
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
close(F);

@Test = split('\n',<<'EOT');
banned text
wiki administrator
matched
See .*BannedContent.* for more information
EOT

update_page('BannedContent', "cosa\n mafia\nnostra\n", 'one banned word', 0, 1);
test_page(update_page('CriminalPage', 'This is about the mafia'), 'Describe the new page here');
test_page($redirect, @Test);
test_page(update_page('CriminalPage', 'This is about the cosa nostra'), 'cosa nostra');

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

# Show a major diff

@Test = split('\n',<<'EOT');
Difference \(from prior major revision\)
third
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

# --------------------

print '[lock on creation]';

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$AdminPass = 'foo';\n";
close(F);

## Create a sample page, and test for regular expressions in the output

@Test = split('\n',<<'EOT');
SandBox
This is a test.
<h1><a title="Click to search for references to this page" href="http://localhost/wiki.pl\?search=SandBox">SandBox</a></h1>
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

print '[despam module]';

# create simple config file

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$AdminPass = 'foo';\n";
close(F);

mkdir '/tmp/oddmuse/modules';
symlink('/home/alex/src/oddmuse/modules/despam.pl',
	'/tmp/oddmuse/modules/despam.pl') or die "Cannot symlink: $!";

update_page('HilariousPage', "Ordinary text.");
update_page('HilariousPage', "Hilarious text.");
update_page('HilariousPage', "Spam from example.com.");

update_page('NoPage', "Spam from example.com.");

update_page('OrdinaryPage', "Spam from example.com.");
update_page('OrdinaryPage', "Ordinary text.");

update_page('ExpiredPage', "Spam from example.com.");
update_page('ExpiredPage', "More spam from example.com.");
update_page('ExpiredPage', "Still more spam from example.com.");

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

print '[near]';

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$AdminPass = 'foo';\n";
close(F);

mkdir '/tmp/oddmuse/near';
open(F,'>/tmp/oddmuse/near/EmacsWiki');
print F "AlexSchroeder\n";
print F "FooBar\n";
close(F);

update_page('InterMap', " EmacsWiki http://www.emacswiki.org/cgi-bin/wiki/%s\n",
	    'required', 0, 1);
update_page('NearMap', " EmacsWiki"
	    . " http://www.emacswiki.org/cgi-bin/emacs?action=index;raw=1"
	    . " http://www.emacswiki.org/cgi-bin/emacs?search=%s;raw=1;near=0\n",
	    'required', 0, 1);

test_page(update_page('FooBaz', "Try FooBar instead!\n"),
	  map { quotemeta } (
	  '<a class="near" title="EmacsWiki"'
	  . ' href="http://www.emacswiki.org/cgi-bin/wiki/FooBar">FooBar</a>',
	  '<div class="near"><p><a class="local"'
	  . ' href="http://localhost/wiki.pl/EditNearLinks">EditNearLinks</a>:'
	  . ' <a class="edit" title="Click to edit this page"'
	  . ' href="http://localhost/wiki.pl?action=edit;id=FooBar">FooBar</a></p></div>'));
test_page(update_page('FooBar', "Test by AlexSchroeder!\n"),
	  map { quotemeta } (
	  '<div class="sister"><p>The same page on other sites:<br />'
	  . '<a title="EmacsWiki:FooBar" href="http://www.emacswiki.org/cgi-bin/wiki/FooBar">'
	  . '<img src="file:///tmp/oddmuse/EmacsWiki.png" alt="EmacsWiki:FooBar" /></a>'));
test_page(get_page('search=alexschroeder'),
	  map { quotemeta } (
	  '<p>Near pages:</p>',
	  '<a class="near" title="EmacsWiki"'
	  . ' href="http://www.emacswiki.org/cgi-bin/wiki/AlexSchroeder">AlexSchroeder</a><br />'));

print '[links]';

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$AdminPass = 'foo';\n";
close(F);
mkdir '/tmp/oddmuse/modules';
symlink('/home/alex/src/oddmuse/modules/links.pl',
	'/tmp/oddmuse/modules/links.pl') or die "Cannot symlink: $!";

update_page('InterMap', " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n",
	    'required', 0, 1);

update_page('a', 'Oddmuse:foo(no) [Oddmuse:bar] [Oddmuse:baz text] '
	    . '[Oddmuse:bar(no)] [Oddmuse:baz(no) text] '
	    . '[[Oddmuse:foo_(bar)]] [[[Oddmuse:foo (baz)]]] [[Oddmuse:foo (quux)|text]]');

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

@Test = map { quotemeta } split('\n',<<'EOT');
<a class="local" href="http://localhost/wiki.pl/a">a</a>:
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo"><span class="site">Oddmuse</span>:<span class="page">foo</span></a>
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?bar"><span class="site">Oddmuse</span>:<span class="page">bar</span></a>
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?baz"><span class="site">Oddmuse</span>:<span class="page">baz</span></a>
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?foo_(bar)"><span class="site">Oddmuse</span>:<span class="page">foo_(bar)</span></a>
EOT

test_page_negative(get_page('action=links'), @Test);
test_page(get_page('action=links inter=1'), @Test);

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$BracketWiki = 0;\n";
close(F);

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

open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$BracketWiki = 1;\n";
print F "\$AdminPass = 'foo';\n";
close(F);

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

print '[link pattern]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
print F "\$AllNetworkFiles = 1;\n";
print F "\$SurgeProtection = 0;\n";
print F "\$AdminPass = 'foo';\n";
close(F);
update_page('HomePage', "This page exists.");
update_page('InterMap', " Oddmuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html", 'required', 0, 1);

%Test = split('\n',<<'EOT');
file://home/foo/tutorial.pdf
<a class="url" href="file://home/foo/tutorial.pdf">file://home/foo/tutorial.pdf</a>
file:///home/foo/tutorial.pdf
<a class="url" href="file:///home/foo/tutorial.pdf">file:///home/foo/tutorial.pdf</a>
image inline: [[image:HomePage]], [[image:OtherPage]]
image inline: <a class="image" href="http://localhost/test-wrapper.pl/HomePage"><img class="upload" src="http://localhost/test-wrapper.pl/download/HomePage" alt="HomePage" /></a>, [image:OtherPage]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage;upload=1">?</a>
traditional local link: HomePage, OtherPage
traditional local link: <a class="local" href="http://localhost/test-wrapper.pl/HomePage">HomePage</a>, OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a>
traditional local link with extra brackets: [HomePage], [OtherPage]
traditional local link with extra brackets: <a class="local number" title="HomePage" href="http://localhost/test-wrapper.pl/HomePage"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>, [OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a>]
traditional local link with other text: [HomePage homepage], [OtherPage other page]
traditional local link with other text: [<a class="local" href="http://localhost/test-wrapper.pl/HomePage">HomePage</a> homepage], [OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a> other page]
free link: [[home page]], [[other page]]
free link: [home page]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=home_page">?</a>, [other page]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=other_page">?</a>
free link with extra brackets: [[[home page]]], [[[other page]]]
free link with extra brackets: [home_page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=home_page">?</a>], [other_page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=other_page">?</a>]
free link with other text: [[home page|da homepage]], [[other page|da other homepage]]
free link with other text: [[home page|da homepage]], [[other page|da other homepage]]
URL: http://www.oddmuse.org/
URL: <a class="url" href="http://www.oddmuse.org/">http://www.oddmuse.org/</a>
URL in text http://www.oddmuse.org/ like this
URL in text <a class="url" href="http://www.oddmuse.org/">http://www.oddmuse.org/</a> like this
URL in brackets: [http://www.oddmuse.org/]
URL in brackets: <a class="url number" href="http://www.oddmuse.org/"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
URL in brackets with other text: [http://www.oddmuse.org/ oddmuse]
URL in brackets with other text: <a class="url outside" href="http://www.oddmuse.org/">oddmuse</a>
URL abbreviation: Oddmuse:Link_Pattern
URL abbreviation: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"><span class="site">Oddmuse</span>:<span class="page">Link_Pattern</span></a>
URL abbreviation with extra brackets: [Oddmuse:Link_Pattern]
URL abbreviation with extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
URL abbreviation with other text: [Oddmuse:Link_Pattern link patterns]
URL abbreviation with other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern">link patterns</a>
URL abbreviation with meta characters: Oddmuse:Link+Pattern
URL abbreviation with meta characters: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern"><span class="site">Oddmuse</span>:<span class="page">Link+Pattern</span></a>
URL abbreviation with meta characters and extra brackets: [Oddmuse:Link+Pattern]
URL abbreviation with meta characters and extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
URL abbreviation with meta characters and other text: [Oddmuse:Link+Pattern link patterns]
URL abbreviation with meta characters and other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link+Pattern">link patterns</a>
free URL abbreviation: [[Oddmuse:Link Pattern]]
free URL abbreviation: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"><span class="site">Oddmuse</span>:<span class="page">Link Pattern</span></a>
free URL abbreviation with extra brackets: [[[Oddmuse:Link Pattern]]]
free URL abbreviation with extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
free URL abbreviation with other text: [[Oddmuse:Link Pattern|link patterns]]
free URL abbreviation with other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern">link patterns</a>
free URL abbreviation with meta characters: [[Oddmuse:Link+Pattern]]
free URL abbreviation with meta characters: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern"><span class="site">Oddmuse</span>:<span class="page">Link+Pattern</span></a>
free URL abbreviation with meta characters and extra brackets: [[[Oddmuse:Link+Pattern]]]
free URL abbreviation with meta characters and extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
free URL abbreviation with meta characters and other text: [[Oddmuse:Link+Pattern|link patterns]]
free URL abbreviation with meta characters and other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%2bPattern">link patterns</a>
EOT

run_tests();

open(F,'>>/tmp/oddmuse/config');
print F "\$BracketWiki = 1;\n";
close(F);

%Test = split('\n',<<'EOT');
traditional local link: HomePage, OtherPage
traditional local link: <a class="local" href="http://localhost/test-wrapper.pl/HomePage">HomePage</a>, OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a>
traditional local link with extra brackets: [HomePage], [OtherPage]
traditional local link with extra brackets: <a class="local number" title="HomePage" href="http://localhost/test-wrapper.pl/HomePage"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>, [OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a>]
traditional local link with other text: [HomePage homepage], [OtherPage other page]
traditional local link with other text: <a class="local" href="http://localhost/test-wrapper.pl/HomePage">homepage</a>, [OtherPage<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OtherPage">?</a> other page]
free link: [[home page]], [[other page]]
free link: [home page]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=home_page">?</a>, [other page]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=other_page">?</a>
free link with extra brackets: [[[home page]]], [[[other page]]]
free link with extra brackets: [home_page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=home_page">?</a>], [other_page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=other_page">?</a>]
free link with other text: [[home page|da homepage]], [[other page|da other homepage]]
free link with other text: [home page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=home_page">?</a> da homepage], [other page<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=other_page">?</a> da other homepage]
URL: http://www.oddmuse.org/
URL: <a class="url" href="http://www.oddmuse.org/">http://www.oddmuse.org/</a>
URL in brackets: [http://www.oddmuse.org/]
URL in brackets: <a class="url number" href="http://www.oddmuse.org/"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
URL in brackets with other text: [http://www.oddmuse.org/ oddmuse]
URL in brackets with other text: <a class="url outside" href="http://www.oddmuse.org/">oddmuse</a>
URL abbreviation: Oddmuse:Link_Pattern
URL abbreviation: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"><span class="site">Oddmuse</span>:<span class="page">Link_Pattern</span></a>
URL abbreviation with extra brackets: [Oddmuse:Link_Pattern]
URL abbreviation with extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
URL abbreviation with other text: [Oddmuse:Link_Pattern link patterns]
URL abbreviation with other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link_Pattern">link patterns</a>
free URL abbreviation: [[Oddmuse:Link Pattern]]
free URL abbreviation: <a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"><span class="site">Oddmuse</span>:<span class="page">Link Pattern</span></a>
free URL abbreviation with extra brackets: [[[Oddmuse:Link Pattern]]]
free URL abbreviation with extra brackets: <a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
free URL abbreviation with other text: [[Oddmuse:Link Pattern|link pattern]]
free URL abbreviation with other text: <a class="inter outside" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?Link%20Pattern">link pattern</a>
EOT

run_tests();

# --------------------

markup:

print '[markup]';

open(F,'>/tmp/oddmuse/config');
print F "\$NetworkFile = 1;\n";
print F "\$AdminPass = 'foo';\n";
print F "\$SurgeProtection = 0;\n";
print F "\%Smilies = ('HAHA!' => '/pics/haha.png');\n";
close(F);

update_page('InterMap', " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html", 'required', 0, 1);

%Test = split('\n',<<'EOT');
HAHA!
<img class="smiley" src="/pics/haha.png" alt="HAHA!" />
do not eat 0 from text
do not eat 0 from text
ordinary text
ordinary text
paragraph\n\nparagraph
paragraph<p>paragraph</p>
* one\n*two
<ul><li>one *two</li></ul>
* one\n\n*two
<ul><li>one</li></ul><p>*two</p>
* one\n** two
<ul><li>one<ul><li>two</li></ul></li></ul>
* one\n** two\n*** three\n* four
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four</li></ul>
* one\n** two\n*** three\n* four\n** five\n* six
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four<ul><li>five</li></ul></li><li>six</li></ul>
* one\n* two\n** one and two\n** two and three\n* three
<ul><li>one</li><li>two<ul><li>one and two</li><li>two and three</li></ul></li><li>three</li></ul>
* one and *\n* two and * more
<ul><li>one and *</li><li>two and * more</li></ul>
WikiWord
WikiWord<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=WikiWord">?</a>
WikiWord:
WikiWord<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=WikiWord">?</a>:
OddMuse
OddMuse<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OddMuse">?</a>
OddMuse:
OddMuse<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=OddMuse">?</a>:
OddMuse:test
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"><span class="site">OddMuse</span>:<span class="page">test</span></a>
OddMuse:test: or not
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"><span class="site">OddMuse</span>:<span class="page">test</span></a>: or not
OddMuse:test, and foo
<a class="inter" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"><span class="site">OddMuse</span>:<span class="page">test</span></a>, and foo
PlanetMath:ZipfsLaw, and foo
<a class="inter" href="http://planetmath.org/encyclopedia/ZipfsLaw.html"><span class="site">PlanetMath</span>:<span class="page">ZipfsLaw</span></a>, and foo
[OddMuse:test]
<a class="inter number" href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
Foo::Bar
Foo::Bar
!WikiLink
WikiLink
!foo
!foo
![[Free Link]]
![Free Link]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=Free_Link">?</a>
http://www.emacswiki.org
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>
<http://www.emacswiki.org>
<<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>>
http://www.emacswiki.org/
<a class="url" href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>
http://www.emacswiki.org.
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>.
http://www.emacswiki.org,
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>,
http://www.emacswiki.org;
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>;
http://www.emacswiki.org:
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>:
http://www.emacswiki.org?
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>?
http://www.emacswiki.org/?
<a class="url" href="http://www.emacswiki.org/">http://www.emacswiki.org/</a>?
http://www.emacswiki.org!
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org'
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>'
http://www.emacswiki.org"
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>"
http://www.emacswiki.org!
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>!
http://www.emacswiki.org(
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>(
http://www.emacswiki.org)
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>)
http://www.emacswiki.org&
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>&
http://www.emacswiki.org#
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>#
http://www.emacswiki.org%
<a class="url" href="http://www.emacswiki.org">http://www.emacswiki.org</a>%
[http://www.emacswiki.org]
<a class="url number" href="http://www.emacswiki.org"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>
[http://www.emacswiki.org] and [http://www.emacswiki.org]
<a class="url number" href="http://www.emacswiki.org"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a> and <a class="url number" href="http://www.emacswiki.org"><span><span class="bracket">[</span>2<span class="bracket">]</span></span></a>
[http://www.emacswiki.org],
<a class="url number" href="http://www.emacswiki.org"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>,
[http://www.emacswiki.org and a label]
<a class="url outside" href="http://www.emacswiki.org">and a label</a>
[file://home/foo/tutorial.pdf local link]
<a class="url outside" href="file://home/foo/tutorial.pdf">local link</a>
file://home/foo/tutorial.pdf
<a class="url" href="file://home/foo/tutorial.pdf">file://home/foo/tutorial.pdf</a>
file:///home/foo/tutorial.pdf
file:///home/foo/tutorial.pdf
mailto:alex@emacswiki.org
<a class="url" href="mailto:alex@emacswiki.org">mailto:alex@emacswiki.org</a>
EOT

run_tests();

# --------------------

print '[usemod module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
* ''one\n** two
<ul><li><em>one</em><ul><li>two</li></ul></li></ul>
# one\n# two
<ol><li>one</li><li>two</li></ol>
* one\n# two
<ul><li>one</li></ul><ol><li>two</li></ol>
# one\n\n#two
<ol><li>one</li></ol><p>#two</p>
# one\n# two\n## one and two\n## two and three\n# three
<ol><li>one</li><li>two<ol><li>one and two</li><li>two and three</li></ol></li><li>three</li></ol>
# one and #\n# two and # more
<ol><li>one and #</li><li>two and # more</li></ol>
: one\n: two\n:: one and two\n:: two and three\n: three
<dl class="quote"><dt /><dd>one</dd><dt /><dd>two<dl class="quote"><dt /><dd>one and two</dd><dt /><dd>two and three</dd></dl></dd><dt /><dd>three</dd></dl>
: one and :)\n: two and :) more
<dl class="quote"><dt /><dd>one and :)</dd><dt /><dd>two and :) more</dd></dl>
: one\n\n:two
<dl class="quote"><dt /><dd>one</dd></dl><p>:two</p>
; one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins ;two:zwei</dd></dl>
; one:eins\n\n; two:zwei
<dl><dt>one</dt><dd>eins</dd><dt>two</dt><dd>zwei</dd></dl>
; a: b: c\n;; x: y: z
<dl><dt>a</dt><dd>b: c<dl><dt>x</dt><dd>y: z</dd></dl></dd></dl>
* foo &lt;b&gt;bold\n* bar &lt;/b&gt;
<ul><li>foo <b>bold</b></li><li>bar &lt;/b&gt;</li></ul>
This is ''emphasized''.
This is <em>emphasized</em>.
This is '''strong'''.
This is <strong>strong</strong>.
This is ''longer emphasized'' text.
This is <em>longer emphasized</em> text.
This is '''longer strong''' text.
This is <strong>longer strong</strong> text.
This is '''''emphasized and bold''''' text.
This is <strong><em>emphasized and bold</em></strong> text.
This is ''emphasized '''and bold''''' text.
This is <em>emphasized <strong>and bold</strong></em> text.
This is '''bold ''and emphasized''''' text.
This is <strong>bold <em>and emphasized</em></strong> text.
This is ''emphasized text containing '''longer strong''' text''.
This is <em>emphasized text containing <strong>longer strong</strong> text</em>.
This is '''strong text containing ''emph'' text'''.
This is <strong>strong text containing <em>emph</em> text</strong>.
||one||
<table class="user"><tr><td>one</td></tr></table>
|| one ''two'' ||
<table class="user"><tr><td align="center">one <em>two</em></td></tr></table>
|| one two ||
<table class="user"><tr><td align="center">one two </td></tr></table>
introduction\n\n||one||two||three||\n||||one two||three||
introduction<p></p><table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
||one||two||three||\n||||one two||three||\n\nfooter
<table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
|| one|| two|| three||\n|||| one two|| three||\n\nfooter
<table class="user"><tr><td align="right">one</td><td align="right">two</td><td align="right">three</td></tr><tr><td colspan="2" align="right">one two</td><td align="right">three</td></tr></table><p>footer</p>
||one ||two ||three ||\n||||one two ||three ||\n\nfooter
<table class="user"><tr><td align="left">one </td><td align="left">two </td><td align="left">three </td></tr><tr><td colspan="2" align="left">one two </td><td align="left">three </td></tr></table><p>footer</p>
|| one || two || three ||\n|||| one two || three ||\n\nfooter
<table class="user"><tr><td align="center">one </td><td align="center">two </td><td align="center">three </td></tr><tr><td colspan="2" align="center">one two </td><td align="center">three </td></tr></table><p>footer</p>
introduction\n\n||one||two||three||\n||||one two||three||\n\nfooter
introduction<p></p><table class="user"><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="2">one two</td><td>three</td></tr></table><p>footer</p>
 source
<pre> source</pre>
 source\n etc\n
<pre> source\n etc</pre>
 source\n \n etc\n
<pre> source\n \n etc</pre>
 source\n \n etc\n\nother
<pre> source\n \n etc</pre><p>other</p>
= title =
<h1>title</h1>
==title=
<h2>title</h2>
========fnord=
<h6>fnord</h6>
== nada\nnada ==
== nada nada ==
 == nada ==
<pre> == nada ==</pre>
==[[Free Link]]==
<h2>[[Free Link]]</h2>
EOT

run_tests();

open(F,'>>/tmp/oddmuse/config');
print F "\$UseModSpaceRequired = 0;\n";
print F "\$UseModMarkupInTitles = 1;\n";
close(F);

%Test = split('\n',<<'EOT');
*one\n**two
<ul><li>one<ul><li>two</li></ul></li></ul>
#one\n##two
<ol><li>one<ol><li>two</li></ol></li></ol>
:one\n:two\n::one and two\n::two and three\n:three
<dl class="quote"><dt /><dd>one</dd><dt /><dd>two<dl class="quote"><dt /><dd>one and two</dd><dt /><dd>two and three</dd></dl></dd><dt /><dd>three</dd></dl>
;one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins</dd><dt>two</dt><dd>zwei</dd></dl>
=='''title'''==
<h2><strong>title</strong></h2>
==[[Free Link]]==
<h2>[Free Link]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=Free_Link">?</a></h2>
EOT

run_tests();

# --------------------

print '[markup module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/markup.pl',
	'/tmp/oddmuse/modules/markup.pl') or die "Cannot symlink: $!";
symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
foo
foo
/foo/
<i>foo</i>
5km/h or 6km/h
5km/h or 6km/h
/foo/ bar
<i>foo</i> bar
/foo bar 5/
<i>foo bar 5</i>
6/22/2004
6/22/2004
#!/bin/sh
#!/bin/sh
put it in ~/elisp/
put it in ~/elisp/
see /usr/bin/
see /usr/bin/
to /usr/local/share/perl/!
to /usr/local/share/perl/!
we shall laugh/cry/run around naked
we shall laugh/cry/run around naked
da *foo*
da <b>foo</b>
da *foo bar 6*
da <b>foo bar 6</b>
_foo_
<em style="text-decoration: underline; font-style: normal;">foo</em>
foo_bar_baz
foo_bar_baz
_foo bar 4_
<em style="text-decoration: underline; font-style: normal;">foo bar 4</em>
this -&gt; that
this &#x2192; that
and this...
and this&#x2026;
foo---bar
foo&#x2014;bar
foo -- bar
foo &#x2013; bar
foo\n----\nbar
foo <hr />bar
EOT

run_tests();

# --------------------

print '[setext module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/setext.pl',
	'/tmp/oddmuse/modules/setext.pl') or die "Cannot symlink: $!";
symlink('/home/alex/src/oddmuse/modules/link-all.pl',
	'/tmp/oddmuse/modules/link-all.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
foo
foo
~foo~
<i>foo</i>
da *foo*
da *foo*
da **foo** bar
da <b>foo</b> bar
da `_**foo**_` bar
da **foo** bar
_foo_
<em style="text-decoration: underline; font-style: normal;">foo</em>
foo_bar_baz
foo_bar_baz
_foo_bar_ baz
<em style="text-decoration: underline; font-style: normal;">foo bar</em> baz
and\nfoo\n===\n\nmore\n
and <h2>foo</h2><p>more</p>
and\n\nfoo\n===\n\nmore\n
and<p></p><h2>foo</h2><p>more</p>
and\nfoo  \n--- \n\nmore\n
and <h3>foo</h3><p>more</p>
and\nfoo\n---\n\nmore\n
and <h3>foo</h3><p>more</p>
EOT

run_tests();

# --------------------

print '[anchors module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/anchors.pl',
	'/tmp/oddmuse/modules/anchors.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
This is a [:day for fun and laughter].
This is a <a class="anchor" name="day_for_fun_and_laughter" />.
[[#day for fun and laughter]].
<a class="local anchor" href="#day_for_fun_and_laughter">day for fun and laughter</a>.
[[2004-08-17#day for fun and laughter]].
<a class="local anchor" href="http://localhost/test-wrapper.pl/2004-08-17#day_for_fun_and_laughter">2004-08-17#day for fun and laughter</a>.
[[[#day for fun and laughter]]].
[<a class="local anchor" href="#day_for_fun_and_laughter">day for fun and laughter</a>].
[[[2004-08-17#day for fun and laughter]]].
<a class="local anchor number" title="2004-08-17#day_for_fun_and_laughter" href="http://localhost/test-wrapper.pl/2004-08-17#day_for_fun_and_laughter"><span><span class="bracket">[</span>1<span class="bracket">]</span></span></a>.
[[#day for fun and laughter|boo]].
[[#day for fun and laughter|boo]].
[[2004-08-17#day for fun and laughter|boo]].
[[2004-08-17#day for fun and laughter|boo]].
EOT

run_tests();

open(F,'>/tmp/oddmuse/config');
print F "\$BracketWiki = 1;\n";
close(F);

%Test = split('\n',<<'EOT');
[[2004-08-17#day for fun and laughter|boo]].
<a class="local anchor" href="http://localhost/test-wrapper.pl/2004-08-17#day_for_fun_and_laughter">boo</a>.
EOT

run_tests();

# --------------------

print '[link-all module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/link-all.pl',
	'/tmp/oddmuse/modules/link-all.pl') or die "Cannot symlink: $!";

update_page('foo', 'bar');

test_page(get_page('action=browse id=foo define=1'),
	  quotemeta('<a class="edit" title="Click to edit this page" href="http://localhost/wiki.pl?action=edit;id=bar">bar</a>'));

%Test = split('\n',<<'EOT');
testing foo.
testing <a class="local" href="http://localhost/test-wrapper.pl/foo">foo</a>.
EOT

run_tests();

# --------------------

print '[image module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/image.pl',
	'/tmp/oddmuse/modules/image.pl') or die "Cannot symlink: $!";

update_page('bar', 'foo');

%Test = split('\n',<<'EOT');
[[image:foo]]
[image:foo]<a class="edit" title="Click to edit this page" href="http://localhost/test-wrapper.pl?action=edit;id=foo;upload=1">?</a>
[[image:bar]]
<a class="image" href="http://localhost/test-wrapper.pl/bar"><img class="upload" src="http://localhost/test-wrapper.pl/download/bar" alt="bar" /></a>
[[image:bar|alternative text]]
<a class="image" href="http://localhost/test-wrapper.pl/bar"><img class="upload" src="http://localhost/test-wrapper.pl/download/bar" alt="alternative text" /></a>
[[image/left:bar|alternative text]]
<a class="image left" href="http://localhost/test-wrapper.pl/bar"><img class="upload" title="alternative text" src="http://localhost/test-wrapper.pl/download/bar" alt="alternative text" /></a>
[[image:bar|alternative text|foo]]
<a class="image" href="http://localhost/test-wrapper.pl/foo"><img class="upload" title="alternative text" src="http://localhost/test-wrapper.pl/download/bar" alt="alternative text" /></a>
[[image/left:bar|alternative text|foo]]
<a class="image left" href="http://localhost/test-wrapper.pl/foo"><img class="upload" title="alternative text" src="http://localhost/test-wrapper.pl/download/bar" alt="alternative text" /></a>
[[image/left:bar|alternative text|http://www.foo.com/]]
<a class="image left outside" href="http://www.foo.com/"><img class="upload" title="alternative text" src="http://localhost/test-wrapper.pl/download/bar" alt="alternative text" /></a>
EOT

run_tests();

# --------------------

print '[subscriberc module]'; # test together with link-all module

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/subscriberc.pl',
	'/tmp/oddmuse/modules/subscriberc.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
My subscribed pages: AlexSchroeder.
<a href="http://localhost/test-wrapper.pl?action=rc;rcfilteronly=^(AlexSchroeder)$">My subscribed pages: AlexSchroeder</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]].
<a href="http://localhost/test-wrapper.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar</a>.
My subscribed categories: CategoryDecisionMaking, CategoryBar.
<a href="http://localhost/test-wrapper.pl?action=rc;rcfilteronly=(CategoryDecisionMaking|CategoryBar)">My subscribed categories: CategoryDecisionMaking, CategoryBar</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]], categories: CategoryDecisionMaking.
<a href="http://localhost/test-wrapper.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$|(CategoryDecisionMaking)">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar, categories: CategoryDecisionMaking</a>.
EOT

run_tests();

# --------------------

print '[toc module]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);
symlink('/home/alex/src/oddmuse/modules/toc.pl',
	'/tmp/oddmuse/modules/toc.pl') or die "Cannot symlink: $!";
symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";

%Test = split('\n',<<'EOT');
== bees: honeymaking ==\n\nMoo.\n
<h2><a name="bees:_honeymaking">bees: honeymaking</a></h2><p>Moo.</p>
EOT

run_tests();

update_page('toc_test', "bla\n"
	    . "=one=\n"
	    . "bla\n"
	    . "==two==\n"
	    . "bla\n"
	    . "==two==\n");

test_page(get_page('toc_test'),
	  quotemeta('<ol><li><a href="#one">one</a><ol><li><a href="#two">two</a></li><li><a href="#two">two</a></li></ol></li></ol>'),
	  quotemeta('<h1><a name="one">one</a></h1>'),
	  quotemeta('<h2><a name="two">two</a></h2>'));

update_page('toc_test', "bla\n"
	    . "==two=\n"
	    . "bla\n"
	    . "===three==\n"
	    . "bla\n"
	    . "==two==\n");

test_page(get_page('toc_test'),
	  quotemeta('<ol><li><a href="#two">two</a><ol><li><a href="#three">three</a></li></ol></li><li><a href="#two">two</a></li></ol>'),
	  quotemeta('<h2><a name="two">two</a></h2>'),
	  quotemeta('<h3><a name="three">three</a></h3>'));

update_page('toc_test', "bla\n"
	    . "==two=\n"
	    . "bla\n"
	    . "===three==\n"
	    . "bla\n"
	    . "=one=\n");

test_page(get_page('toc_test'),
	  quotemeta('<ol><li><a href="#two">two</a><ol><li><a href="#three">three</a></li></ol></li><li><a href="#one">one</a></li></ol>'),
	  quotemeta('<h2><a name="two">two</a></h2>'),
	  quotemeta('<h1><a name="one">one</a></h1>'));

# --------------------

print '[comments]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
print F "\$CommentsPrefix = 'Comments on ';\n";
close(F);

get_page('title=Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Yadda'), 'Describe the new page');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20my%20comment.', 'username=Alex');
test_page(get_page('Comments_on_Yadda'), 'This is my comment\.', '-- Alex');

get_page('title=Comments_on_Yadda', 'aftertext=This%20is%20another%20comment.',
	 'username=Alex', 'homepage=http%3a%2f%2fwww%2eoddmuse%2eorg%2f');
test_page(get_page('Comments_on_Yadda'), 'This is my comment\.',
	  '-- <a class="url outside" href="http://www.oddmuse.org/">Alex</a>');


# --------------------

fixme:

print '[headers in various modules]';

system('/bin/rm -rf /tmp/oddmuse');
die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
mkdir '/tmp/oddmuse';
mkdir '/tmp/oddmuse/modules';
open(F,'>/tmp/oddmuse/config');
print F "\$SurgeProtection = 0;\n";
close(F);

# without portrait-support

# nothing
update_page('headers', "== no header ==\n\ntext\n");
test_page(get_page('headers'), '== no header ==');

# usemod only
symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";
update_page('headers', "== is header ==\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');
unlink('/tmp/oddmuse/modules/usemod.pl') or die "Cannot unlink: $!";

# toc only
symlink('/home/alex/src/oddmuse/modules/toc.pl',
	'/tmp/oddmuse/modules/toc.pl') or die "Cannot symlink: $!";
update_page('headers', "== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#toc0">one</a></li>',
	  '<li><a href="#toc1">two</a></li>',
	  '<h2><a id="toc0">one</a></h2>',
	  '<h2><a id="toc1">two</a></h2>', );
unlink('/tmp/oddmuse/modules/toc.pl') or die "Cannot unlink: $!";

# headers only
symlink('/home/alex/src/oddmuse/modules/headers.pl',
	'/tmp/oddmuse/modules/headers.pl') or die "Cannot symlink: $!";
update_page('headers', "is header\n=========\n\ntext\n");
test_page(get_page('headers'), '<h2>is header</h2>');
unlink('/tmp/oddmuse/modules/headers.pl') or die "Cannot unlink: $!";

# with portrait-support

symlink('/home/alex/src/oddmuse/modules/portrait-support.pl',
	'/tmp/oddmuse/modules/portrait-support.pl') or die "Cannot symlink: $!";

# nothing
update_page('headers', "[new]foo\n== no header ==\n\ntext\n");
test_page(get_page('headers'), '<div class="color one">foo == no header ==<p>text</p></div>');

# usemod only
symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";
update_page('headers', "[new]foo\n== is header ==\n\ntext\n");
test_page(get_page('headers'), '<div class="color one">foo </div><h2>is header</h2>');
unlink('/tmp/oddmuse/modules/usemod.pl') or die "Cannot unlink: $!";

# toc only
symlink('/home/alex/src/oddmuse/modules/toc.pl',
	'/tmp/oddmuse/modules/toc.pl') or die "Cannot symlink: $!";
update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#toc0">one</a></li>',
	  '<li><a href="#toc1">two</a></li>',
	  '<div class="color one">foo </div><h2><a id="toc0">one</a></h2>',
	  '<h2><a id="toc1">two</a></h2>', );
unlink('/tmp/oddmuse/modules/toc.pl') or die "Cannot unlink: $!";

# headers only
symlink('/home/alex/src/oddmuse/modules/headers.pl',
	'/tmp/oddmuse/modules/headers.pl') or die "Cannot symlink: $!";
update_page('headers', "[new]foo\nis header\n=========\n\ntext\n");
test_page(get_page('headers'), '<div class="color one">foo </div><h2>is header</h2>');
unlink('/tmp/oddmuse/modules/headers.pl') or die "Cannot unlink: $!";

# portrait-support, toc, and usemod

symlink('/home/alex/src/oddmuse/modules/usemod.pl',
	'/tmp/oddmuse/modules/usemod.pl') or die "Cannot symlink: $!";
symlink('/home/alex/src/oddmuse/modules/toc.pl',
	'/tmp/oddmuse/modules/toc.pl') or die "Cannot symlink: $!";
update_page('headers', "[new]foo\n== one ==\ntext\n== two ==\ntext\n== three ==\ntext\n");
test_page(get_page('headers'),
	  '<li><a href="#toc0">one</a></li>',
	  '<li><a href="#toc1">two</a></li>',
	  '<div class="color one">foo </div><h2><a id="toc0">one</a></h2>',
	  '<h2><a id="toc1">two</a></h2>', );

### END OF TESTS

print "\n";
print "$passed passed, $failed failed.\n";
