# Copyright (C) 2006, 2008  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 100;

clear_pages();
AppendStringToFile($ConfigFile, "\$CommentsPrefix = 'Comments on ';\n");

xpath_test(get_page('action=browse id=HomePage username=alex'),
	   '//link[@rel="alternate"][@type="application/rss+xml"]'
	   . '[@title="Follow-ups for alex"]'
	   . '[@href="http://localhost/wiki.pl?action=rss;followup=alex"]');

update_page('big', 'foofoo');
update_page('2008-08-07_New_Hope', 'testing');
update_page('2008-08-08', 'testing');
update_page('2008-08-07_12h50_Forget_It', 'testing');
update_page('Comments_on_2008-08-07_New_Hope', 'testing');
test_page(get_page('action=rss full=1'),
	  '<title>big</title>',
	  '<title>New Hope</title>',
	  '<title>12h50 Forget It</title>', # wrong
	  '<title>2008-08-08</title>',
	  '<title>Comments on New Hope</title>',
	  '<description>&lt;p&gt;foo foo&lt;/p&gt;</description>');
test_page(get_page('action=rss short=0'),
	  '<title>big</title>',
	  '<title>2008-08-07 New Hope</title>',
	  '<title>2008-08-07 12h50 Forget It</title>',
	  '<title>Comments on 2008-08-07 New Hope</title>');
AppendStringToFile($ConfigFile, "\$RssStrip = '^\\d\\d\\d\\d-\\d\\d-\\d\\d_(\\d\\d?h\\d\\d_)?';\n");
test_page(get_page('action=rss'),
	  '<title>New Hope</title>',
	  '<title>Forget It</title>');
AppendStringToFile($ConfigFile, "\$RssStrip = '';\n");
test_page(get_page('action=rss'),
	  '<title>2008-08-07 New Hope</title>',
	  '<title>2008-08-07 12h50 Forget It</title>');
update_page('big', 'foo foo foo', '<mu>');
test_page(get_page('action=rss'), '<description>&lt;mu&gt;</description>');
test_page(get_page('action=rss full=1'), 'foo foo foo');
test_page(get_page('action=rss full=1 diff=1'), '&lt;div class="diff"&gt;');
update_page('big', 'x' x 49000);
test_page(get_page('action=rss full=1'), 'xxxxxx');
test_page(get_page('action=rss full=1 diff=1'), 'too big to send over RSS');

update_page('big', 'x' x 55000, 'big edit');
test_page_negative(get_page('action=rss full=1'), 'xxxxxx');
test_page(get_page('action=rss full=1'), 'too big to send over RSS');
update_page('big', "mee too\n" x 2 . 'x' x 55000);
test_page(get_page('action=rss full=1'), 'too big to send over RSS');
test_page(get_page('action=rss full=1 diff=1'), 'mee too', 'too big to send over RSS');

SKIP: {

  eval {
    require XML::RSS;
  };

  skip "XML::RSS not installed", 75 if $@;

  use Cwd;
  $dir = cwd;
  $uri = "file://$dir";
  $uri =~ s/ /%20/g;		# for cygdrive stuff including spaces

  # some xpath tests
  update_page('RSS', "<rss $uri/heise.rdf>");
  $page = get_page('RSS');
  xpath_test($page, '//a[@title="999"][@href="http://www.heise.de/tp/deutsch/inhalt/te/15886/1.html"][text()="Berufsverbot für Mediendesigner?"]');

  test_page($page, split('\n',<<'EOT'));
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

  # RSS 2.0

  update_page('RSS', "<rss $uri/flickr.xml>");
  test_page(get_page('RSS'),
	    join('(.|\n)*',	# verify the *order* of things.
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

  update_page('RSS', "<rss $uri/kensanata.xml>");
  test_page(get_page('RSS'), split('\n',<<'EOT'));
Fania All Stars - Bamboleo
http://www.audioscrobbler.com/music/Fania\+All\+Stars/_/Bamboleo
EOT

  update_page('RSS', "<rss $uri/linuxtoday.rdf>");
  test_page(get_page('RSS'), split('\n',<<'EOT'));
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

  update_page('RSS', "<rss $uri/fm.rdf>");
  test_page(get_page('RSS'), split('\n',<<'EOT'));
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

  update_page('RSS', "<rss $uri/rss1.0.rdf>");
  test_page(get_page('RSS'), split('\n',<<'EOT'));
GTKeyboard 0.85
http://freshmeat.net/news/1999/06/21/930003829.html
EOT

  # Note, cannot identify BayleShanks as author in the mb.rdf
  update_page('RSS', "<rss $uri/mb.rdf $uri/community.rdf>");
  test_page(get_page('RSS'), split('\n',<<'EOT'));
MeatBall:LionKimbro
2003-10-24T22:49:33\+06:00
CommunityWiki:RecentNearChanges
http://www.usemod.com/cgi-bin/mb.pl\?LionKimbro
2003-10-24T21:02:53\+00:00
unified rc for here and meatball
<span class="contributor"><span> \. \. \. \. </span>AlexSchroeder</span>
http://www.emacswiki.org/cgi-bin/community\?action=browse;id=RecentNearChanges;revision=1
EOT
}
