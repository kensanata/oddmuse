#! /usr/bin/perl

# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

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

package OddMuse;
# load Oddmuse core
$RunCGI = 0;
do "wiki.pl";

sub unique {
  my %h = map {$_ => 1} @_;
  return sort keys %h;
}

sub tag {
  print '<ul>';
  for my $id ($q->param) {
    if ($IndexHash{$id} and UserCanEdit($id, 1)) {
      my $tags = $q->param($id);
      $tags =~ s{"(.*?)"}{$_ = $1; s/ +/_/g; $_ }eg;
      my @tags = unique(map { s/_/ /g; $_ } split(' ', $tags));
      my $tagline = "Tags: " . join (' ', map { "[[tag:$_]]" } @tags);
      OpenPage($id);
      my $text = $Page{text};
      # delete existing taglines
      $text =~ s/\n+Tags: .*//g;
      if (@tags) {
	$text .= "\n\n$tagline\n";
      }
      if ($text ne $Page{text}) {
	RequestLockOrError(); # fatal
	print $q->li(GetPageLink($id) . " tagged " . join(', ', @tags));
	Save($id, $text, 'Tagged ' . join(', ', @tags), 1);
	ReleaseLock();
      }
    }
  }
  print '</ul>';
  print $q->p(ScriptLink('action=rc;showedit=1', $RCName));
}

sub tags {
  my $id = shift;
  OpenPage($id);
  my @tags = ();
  while ($Page{text} =~ m/\[\[tag:$FreeLinkPattern(?:\|([^]|]+))?\]\]/og) {
    my $tag = $1;
    $tag = qq{"$tag"} if $tag =~ / /;
    push(@tags, $tag);
  }
  return join(" ", @tags);
}

sub item {
  my $id = shift;
  print $q->Tr($q->td(GetPageLink($id)),
	       $q->td($q->textfield(-name=>$id, -default=>tags($id), -size=>80)));
}

sub search {
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p("Search term: "
	      . $q->strong($q->param('search')));
  print '<table>';
  SearchTitleAndBody($q->param('search'), \&item);
  print '</table>';
  print $q->hidden('tag', 'done');
  print $q->submit('go', 'Go!');
  print $q->end_form();
}

sub default {
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p("Search term: "
	      . $q->textfield(-name=>'search'));
  print $q->submit('go', 'Go!');
  print $q->end_form();
}

sub main {
  $ConfigFile = '/home/alex/campaignwiki/config';
  $ModuleDir = '/home/alex/campaignwiki/modules';
  $DataDir = '/home/alex/campaignwiki/Monsters';
  Init();
  $ScriptName = '/wiki/Monsters';
  DoSurgeProtection();
  if (not $BannedCanRead and UserIsBanned() and not UserIsEditor()) {
    ReportError(T('Reading not allowed: user, ip, or network is blocked.'), '403 FORBIDDEN',
    0, $q->p(ScriptLink('action=password', T('Login'), 'password')));
  }
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } else {
    $UserGotoBar .= $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Tag Monsters');
    print $q->start_div({-class=>'content'});
    if (GetParam('tag')) {
      tag();
    } elsif (GetParam('search')) {
      search();
    } else {
      default();
    }
    print $q->p('Questions? Send mail to Alex Schröder <'
		. $q->a({-href=>'mailto:kensanata@gmail.com'},
			'kensanata@gmail.com') . '>');
    print $q->end_div();
    PrintFooter();
  }
}

main();

__DATA__
