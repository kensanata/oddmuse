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
use LWP::UserAgent;
use HTML::TreeBuilder;

# load Oddmuse core
$RunCGI = 0;
do "wiki.pl";

# globals
my $wiki = 'BlogArchive';
my $site = "http://campaignwiki.org/wiki/$wiki";
# my $site = "http://localhost/wiki.pl";
my $home = "$site/HomePage";

main();

sub default {
  print $q->p("Copy a blog article to the "
	      . $q->a({-href=>$home}, $wiki) . ".");
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p($q->label({-for=>'url'}, T('URL:')) . ' '
	      . $q->textfield(-name=>'url', -id=>'url', -size=>50));
  print $q->submit('go', 'Go!');
  print $q->end_form();
  print $q->p("Please make sure you’re only submitting your own articles",
	      "or articles with an appropriate license.");

  print $q->p("Drag this bookmarklet to your bookmarks bar for easy access:",
	      $q->a({-href=>q{javascript:location='http://campaignwiki.org/copy?url='+encodeURIComponent(window.location.href)}}, $wiki) . ".");
}

sub check_url {
  my $url = shift;
  print $q->p("Looking at ", $q->a({-href=>$url}, $url));
  my ($name, $data) = get_data($url);
  $name = GetParam('name', $name);
  if (name_exists($name) and not GetParam('confirm', 0)) {
    print $q->p("We already have a page with that name: ",
		$q->a({-href=>$duplicate}, $duplicate));
    print $q->start_multipart_form(-method=>'get', -class=>'submit');
    print $q->p($q->label({-for=>'name'}, T('New name:')) . ' '
		. $q->textfield(-name=>'name', -id=>'name', -size=>50,
				-default=>$name));
    print $q->hidden('url', $url);
    print $q->hidden('confirm', 1);
    print $q->submit('go', 'Continue');
    print $q->end_form();
  } elsif (not GetParam('confirm', 0)) {
    print $q->p("Please confirm that you want to copy this article to the wiki.");
    print $q->start_multipart_form(-method=>'get', -class=>'submit');
    print $q->p($q->label({-for=>'name'}, T('Name:')) . ' '
		. $q->textfield(-name=>'name', -id=>'name', -size=>50,
				-default=>$name));
    print $q->hidden('url', $url);
    print $q->hidden('confirm', 1);
    print $q->submit('go', 'Continue');
    print $q->end_form();
  } else {
    post_addition($name, $data, $url);
  }
}

sub get_data {
  my $url = shift;
  my $tree = HTML::TreeBuilder->new_from_content(GetRaw($url));
  my $h = $tree->look_down('_tag', 'h1');
  $h = $tree->look_down('_tag', 'title') unless $h;
  $h = $h->as_text if $h;
  my $b = $tree->look_down('_tag', 'body');
  if ($b = $tree->look_down('_tag', 'div',
			    'class', qr/post-body/)) {
    # blogspot
    $b = html($b);
  } else {
    # no idea, just get the text
    $b = $b->as_text if $b;
  }
  return ($h, $b);
}

sub html {
  my $tree = shift;
  my $str;
  for my $element ($tree->content_list()) {
    if (not ref $element) {
      $str .= $element;
    } elsif ($element->tag() eq 'br') {
      $str .= "\n\n";
    } elsif ($element->tag() eq 'span'
	     and $element->attr('style') =~ /font-weight: *bold/) {
      $str .= "[b]" . html($element) . "[/b]";
    } elsif ($element->tag() =~ m/^(b|i|h[1-6])$/) {
      $str .= "[$1]" . html($element) . "[/$1]";
    } else {
      $str .= html($element);
    }
  }
  return $str;
}

sub name_exists {
  my $id = FreeToNormal(shift);
  AllPagesList();
  my $string = GetPageContent($id);
  return ($IndexHash{$id}
	  and substr($string, 0, length($DeletedPage)) ne $DeletedPage);
}

sub post_addition {
  my ($name, $data, $url) = @_;
  my $id = FreeToNormal($name);
  print $q->p("Adding ", $q->a({-href=>$url}, $name));
  my $text = "Based on [$url $name].\n----\n" . $data;
  my $ua = LWP::UserAgent->new;
  my %params = (text => $text,
		title => $id,
		summary => $name,
		username => GetParam('username'),
		pwd => GetParam('pwd'));
  $params{$QuestionaskerSecretKey} = 1 if $QuestionaskerSecretKey;
  my $response = $ua->post($site, \%params);
  if ($response->is_error) {
    print $q->p("The submission failed!");
    print $q->pre($response->status_line . "\n"
		  . $response->content);
  } else {
    print $q->p("See for yourself: ",
		$q->a({-href=>"$site/$id"}, $name));
  }
}

sub main {
  Init();
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } else {
    $UserGotoBar .= $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Submit a new blog article');
    print $q->start_div({-class=>'content index'});
    if (not GetParam('url')) {
      default();
    } else {
      check_url(GetParam('url'));
    }
    print $q->p('Questions? Send mail to Alex Schröder <'
		. $q->a({-href=>'mailto:kensanata@gmail.com'},
			'kensanata@gmail.com') . '>');
    print $q->end_div();
    PrintFooter();
  }
}

__DATA__
