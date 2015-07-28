# Copyright (C) 2011-2015  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2011  Ingo Belka <grimmen@mvnet.de>
# Copyright (C) 2011  Mark Zimmermann
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
# use warnings;
use v5.10;

AddModuleDescription('like.pl', 'Like Button');

our $LikeRegexp =      T('====(\d+) persons? liked this===='); # must match all translations
our $LikeReplacement = T('====%d persons liked this===='); # used for sprintf
our $LikeFirst =       T('====1 person liked this====');

our (%Action, %Page, $OpenPageName, @MyFooters);
$Action{like} = \&DoLike;
push(@MyFooters, \&LikeFooter);

sub DoLike {
  my $id = shift;
  OpenPage(FreeToNormal($id));
  return ReBrowsePage($id) unless $Page{text}; # skip empty pages
  my $data = $Page{text};
  if ($data =~ /$LikeRegexp/) {
    my $n = $1;
    $n++;
    my $to = sprintf($LikeReplacement, $n); # fresh copy
    $data =~ s/$LikeRegexp/$to/;
  } else {
    # data already ends in a newline
    $data .= "\n" . $LikeFirst;
  }
  SetParam('text', $data);
  SetParam('title', $OpenPageName);
  SetParam('oldtime', $Page{ts});
  SetParam('recent_edit', 'on');
  SetParam('summary', T('I like this!'));
  DoPost($id);
}

sub LikeFooter {
  my ($id) = @_;
  if ($id
      and $Page{revision} # don't like empty pages
      and GetParam('action', 'browse') eq 'browse') {
    return ScriptLink('action=like;id=' . UrlEncode($id), T('I like this!'), 'like');
  }
}
