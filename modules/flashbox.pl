#!/usr/bin/env perl
# ====================[ flashbox.pl                        ]====================

=head1 NAME

flashbox - An Oddmuse module for embedding offsite-hosted Flash videos within
           an Oddmuse Wiki page - especially those hosted by Google Videos,
           YouTube, and SlideShare.

=head1 INSTALLATION

flashbox is easily installable: move this file into the B<wiki/modules/>
directory of your Oddmuse Wiki.

=cut
package OddMuse;

$ModulesDescription .= '<p>$Id: flashbox.pl,v 1.5 2009/07/29 13:00:33 as Exp $</p>';

# ....................{ CONFIGURATION                      }....................

=head1 CONFIGURATION

flashbox is easily configurable: set these variables in the B<wiki/config.pl>
file for your Oddmuse Wiki.

=cut
use vars qw($FlashboxWidth
            $FlashboxHeight);

=head2 $FlashboxWidth

The width of the HTML object "frame" for Flash videos, in pixels.

The default value for this variable is (usually) fine.

=cut
$FlashboxWidth = 420;

=head2 $FlashboxHeight

The height of the HTML object "frame" for Flash videos, in pixels. For any
specific width, a height roughly 83.33% of that width tends to provide a
respectable frame for viewing Flash videos.

The default value for this variable is (usually) fine.

=cut
$FlashboxHeight = 350;

# ....................{ MARKUP                             }....................

=head1 MARKUP

flashbox provides a few new markup rules. These are:

=over

=item [[GoogleVideo:${GoogleVideoID}]]

=over

=item Embeds the Google Video uniquely identified by ${GoogleVideoID} into the
      Oddmuse Wiki page, where ${GoogleVideoID} is the signed integer
      following the "docID" parameter in the Google Video URL for that video;
      for example, [[GoogleVideo:8649250863235826256]] embeds Derrick Jensen's
      "Endgame: Part I" Google Video into the Oddmuse Wiki page.

=back

=item [[YouTube:${YouTubeVideoID}]]

=over

=item Embeds the YouTube video uniquely identified by ${YouTubeVideoID} into the
      Oddmuse Wiki page, where ${YouTubeVideoID} is the string following the
      "watch?v" parameter in the YouTube URL for that video; for example,
      [[YouTube:Q1ZeXnmDZMQ]] embeds James Howard Kunstler's "The Tragedy of
      Suburbia TED Talk" YouTube video into the Oddmuse Wiki page.

=back

=item [[SlideShare:${SlideSharePresentationID}]]

=over

=item Embeds the SlideShare presentation uniquely identified by
      ${SlideSharePresentationID} into the Oddmuse Wiki page, where
      ${SlideSharePresentationID} is a string composed of the title for that
      presentation and an arbitrary signed integer. Unfortunately, this string
      is more difficult to obtain than for Google Video and YouTube; for any
      given presentation, see the small "Embed" box on that presentation's
      SlideShare page and the string following the "doc" parameter in that
      box. For example,
      [[SlideShare:the-tyranny-of-human-civilization-13479]] embeds
      huer1278ft's "The Tyranny of Human Civilization" SlideShare presentation
      into the Oddmuse Wiki page.

=back

=back

=cut
push(@MyRules, \&FlashboxRule);

# "FlashboxRule" conflicts with "CreoleRule"-style interpretation of "[[...]]"
# syntax; and must, thus, be applied before that rule.
$RuleOrder{\&FlashboxRule} = -11;

sub FlashboxRule {
  if    (/\G\[\[googlevideo:([0-9-]+)\]\]/cgi) {
    return FlashboxHtml('googlevideo',
                        "http://video.google.com/googleplayer.swf?docId=${1}&hl=en");
  }
  elsif (/\G\[\[slideshare:([a-z0-9-]+)\]\]/cgi) {
    return FlashboxHtml('slideshare',
                        "http://static.slideshare.net/swf/ssplayer2.swf?doc=${1}");
  }
  elsif (/\G\[\[youtube:([a-z0-9-_]{11})\]\]/cgi) {
    return FlashboxHtml('youtube',
                        "http://www.youtube.com/v/${1}");
  }
  return undef;
}

sub FlashboxHtml {
  my ($paragraph_class, $flashbox_url) = @_;
  return
    ($bol
     ? CloseHtmlEnvironments().AddHtmlEnvironment('p', qq~class="flashbox ${paragraph_class}"~)
     : '').qq~
<object width="${FlashboxWidth}" height="${FlashboxHeight}">
  <param name="movie"     value="${flashbox_url}"/>
  <param name="pluginurl" value="http://www.macromedia.com/go/getflashplayer"/>
  <param name="quality"   value="high"/>
  <param name="wmode"     value="transparent"/>
  <param name="allowFullScreen"   value="true"/>
  <param name="allowScriptAccess" value="always"/>
  <embed type="application/x-shockwave-flash"
         width="${FlashboxWidth}" height="${FlashboxHeight}"
         src="${flashbox_url}"
         wmode="transparent"
         allowscriptaccess="always" allowfullscreen="true"/>
</object>~;
}

=head1 CSS

flashbox also provides a few new HTML classes for CSS-stylizing the HTML emitted
by these markup rules. Of necessity, flashbox embeds Flash videos in an
"<object>...</object>" HTML tag-set; technically, therefore, you can stylize
such videos with a CSS selector resembling:

  # This CSS selector selects all HTML-embedded objects (e.g., Flash videos).
  object {
    # These CSS properties are supposed to horizontally center such objects;
    # however, they do not.
    margin:  1.500em auto;
    padding: 1.500em 0.000em 0.500em 0.000em;
    text-align:  center;
    text-indent: 0.000em;
  }

Unfortunately, most browsers ignore most CSS properties on the CSS "object"
selector (including those in the example, above).

To circumvent this, flashbox enwraps all block-level, flashbox-specific markup
(i.e., flashbox-specific markup preceded by at least two newlines) within an
HTML paragraph having two unique classes. This HTML paragraph, unlike the
"<object>...</object>" HTML tag-set, is styleable by all browsers via CSS
selection of these classes:

=over

=item "flashbox"; and

=item "googlevideo", "youtube", or "slideshare" - according to which offsite host
      a Flash video is embedded from.

=back

Let's illustrate with a crude example. Suppose some Oddmuse Wiki page contains
this text markup:

  In this compelling reading of his, perhaps, most well-read poetry, Carl Sagan
  thunders the truth, Vangelis supplies the angel’s harp and music, and YouTube
  plies the photo-montage seas of "this pale, blue dot": our Earth, from afar.

  [[YouTube:p86BPM1GV8M]]

Then, flashbox transmutes that text markup into HTML markup resembling:

  <p>
  In this compelling reading of his, perhaps, most well-read poetry, Carl Sagan
  thunders the truth, Vangelis supplies the angel’s harp and music, and YouTube
  plies the photo-montage seas of "this pale, blue dot": our Earth, from afar.
  </p>
  <p class="flashbox youtube">
    <object width="420" height="350">
      <param name="movie"     value="http://www.youtube.com/v/p86BPM1GV8M"/>
      <param name="pluginurl" value="http://www.macromedia.com/go/getflashplayer"/>
      <embed type="application/x-shockwave-flash"
             width="420" height="350"
             src="http://www.youtube.com/v/p86BPM1GV8M"/>
    </object>
  </p>

Then, your CSS stylesheet can style this HTML markup with CSS resembling:

  # This CSS selector selects flashbox-embedded Flash videos.
  p.flashbox {
    # These CSS properties horizontally center such videos.
    margin:  1.500em auto;
    padding: 1.500em 0.000em 0.500em 0.000em;
    text-align:  center;
    text-indent: 0.000em;
  }

  # This CSS selector selects flashbox-embedded, YouTube-specific Flash videos.
  p.youtube {
    # These CSS properties background and border such videos.
    background: #334466;
    border:     #112255 0.125em solid;
  }

Wew! There; that wasn't so gruesomely detailed, was it?

=head1 SEE ALSO

The oddmuse.org "YouTube" page off which this Oddmuse extension was founded, at:

L<http://www.oddmuse.org/cgi-bin/oddmuse/YouTube>

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft 2008 by B.w.Curry <http://www.raiazome.com>.

This file is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

=cut
