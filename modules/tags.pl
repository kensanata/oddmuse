# Copyright (C) 2005, 2009  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: tags.pl,v 1.7 2009/03/20 10:06:28 as Exp $</p>';

=head1 NAME

tags - an Oddmuse module that implements tagging of pages and
       searching for tagged pages

=head1 SYNOPSIS

This module recognises the pattern C<[[tag:foo]]> on a page and will
render this as a link to all pages tagged foo, as well as a link to
the RSS feed for all pages tagged foo.

Alternatively, the pattern C<[[tag:foo|bar]]> is also recognized. The
only difference is that this will look like a link to bar instead of
foo.

When searching for a term of the form C<tag:foo> the term "foo" be
searched in a separate tag index, making it much faster.

You can also negate this particular form by using C<-tag:foo>.

These searches will also work for Journal Pages, Recent Changes, and
RSS feed.

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=head1 CONFIGURATION

=head2 $TagUrl and $TagFeed

These variable will be used to link the tags. By default, they will
point at the wiki itself, using C<$ScriptName>. They use C<%s> as a
placeholder for the URL encoded tag.

Example:

    $TagUrl = 'http://technorati.com/tag/%s';
    $TagFeed = 'http://feeds.technorati.com/tag/%s';

By default, these two will point to the list of recent changes,
filtered by the appropriate tag, formatted as HTML or RSS
respectively.

=head2 $TagRssIcon

This variable should point to an RSS icon. You can get one from
L<http://www.feedicons.com/>, for example.

Example:

    $TagRssIcon = 'http://www.example.org/pics/rss.png';

=cut

use vars qw($TagUrl $TagFeed $TagRssIcon);

push(@MyInitVariables, \&TagsInit);

sub TagsInit {
  $TagUrl = ScriptUrl('action=rc;rcfilteronly=tag:%s') unless $TagUrl;
  $TagFeed = ScriptUrl('action=rss;rcfilteronly=tag:%s') unless $TagFeed;
}

sub TagsGetLink {
  my ($url, $id) = @_;
  $id = UrlEncode($id);
  $url =~ s/\%s/$id/g or $url .= $id;
  return $url;
}

push(@MyRules, \&TagsRule);

sub TagsRule {
  if (m/\G(\[\[tag:$FreeLinkPattern\]\])/cog
      or m/\G(\[\[tag:$FreeLinkPattern\|([^]|]+)\]\])/cog) {
    # [[tag:Free Link]], [[tag:Free Link|alt text]]
    my ($tag, $text) = ($2, $3);
    my $html = $q->a({-href=>TagsGetLink($TagUrl, $tag),
		      -class=>'outside tag',
		      -title=>T('Tag'),
		      -rel=>'tag'
		     }, $text || $tag);
    if ($TagRssIcon) {
      $html .= ' ' . $q->a({-href=>TagsGetLink($TagFeed, $tag),
			    -class=>'feed tag',
			    -title=>T('Feed for this tag'),
			    -rel=>'feed'
			   }, $q->img({-src=>$TagRssIcon}));
    }
    return $html;
  }
  return undef;
}
