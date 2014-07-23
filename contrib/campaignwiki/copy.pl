#! /usr/bin/perl

# Copyright (C) 2011–2014  Alex Schroeder <alex@gnu.org>

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
use utf8;

# load Oddmuse core
$RunCGI = 0;
do "wiki.pl";

$default_namespace = 'NameOfYourWiki';

main();

sub default {
  my ($url, $ns) = @_;
  print $q->start_multipart_form(-method=>'get', -class=>'copy');
  print $q->p("This script helps you copy of a blog post to your Campaign Wiki.");
  print $q->p($q->label({-for=>'url', -style=>'display: inline-block; width: 20ex'}, 'Blog post URL:'),
	      $q->textfield(-name=>'url', -id=>'url', -size=>50),
	      $q->br(),
	      $q->label({-for=>'ns', -style=>'display: inline-block; width: 20ex'}, 'Name of your wiki:'),
	      $q->textfield(-name=>'ns', -id=>'ns', -size=>50, -default=>$default_namespace));
  if ($url and not $ns) {
    print $q->p($q->em('Please provide the name of your wiki. It is mandatory. Use “NameOfYourWiki” if you just want to test something.'));
  }
  print $q->submit('go', 'Go!');
  print $q->end_form();
  print $q->p("Please make sure you’re only submitting your own articles",
	      "or articles with an appropriate license.");
  print $q->p("Drag this bookmarklet to your bookmarks bar for easy access:",
	      $q->a({-href=>q{javascript:location='http://campaignwiki.org/copy?url='+encodeURIComponent(window.location.href)}}, 'Copy Blog Post') . ".");
}

sub confirm_overwrite {
  my ($url, $ns, $name) = @_;
  print $q->p("We already have a page with that name: ", GetPageLink($name));
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p($q->label({-for=>'name'}, T('New name:')) . ' '
	      . $q->textfield(-name=>'name', -id=>'name', -size=>50, -default=>$name));
  print $q->hidden('url', $url);
  print $q->hidden('ns', $ns);
  print $q->hidden('confirm', 1);
  print $q->submit('go', 'Continue');
  print $q->end_form();
}

sub confirm_save {
  my ($url, $ns, $name) = @_;
  my $ns = GetParam('ns', $default_namespace);
  print $q->p("Please confirm that you want to copy",
	      $q->a({-href=>$url}, "this article"), "to", GetPageLink($HomePage, $ns) . ".");
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p($q->label({-for=>'name'}, T('Name:')) . ' '
	      . $q->textfield(-name=>'name', -id=>'name', -size=>50, -default=>$name));
  print $q->hidden('url', $url);
  print $q->hidden('ns', $ns);
  print $q->hidden('confirm', 1);
  print $q->submit('go', 'Continue');
  print $q->end_form();
}

sub get_data {
  my $url = shift;
  my $tree = HTML::TreeBuilder->new_from_content(GetRaw($url));
  my $h = $tree->look_down('_tag', 'h1');
  $h = $tree->look_down('_tag', 'title') unless $h;
  $h = $h->as_text if $h;
  my $b;
  if ($b = $tree->look_down('_tag', 'div', 'class', qr/post-body/)) {
    # Blogspot
    $b = html($b);
  } elsif ($b = $tree->look_down('_tag', 'div', 'class', qr/content/)) {
    # Oddmuse
    $b = html($b);
  } else {
    # default: get it all
    $b = html($tree->look_down('_tag', 'body'));
  }
  # common illegal character for page names
  $h =~ s/:/,/g;
  return ($h, $b);
}

sub html {
  my ($tree, $p) = @_;
  # $p indicates whether we need an empty line or not
  my $str;
  for my $element ($tree->content_list()) {
    if (not ref $element) {
      $str .= $element;
    } elsif ($element->tag() eq 'p') {
      $str .= ($p == 1 ? "\n\n" : "") . html($element);
      $p = 1;
    } elsif ($element->tag() eq 'br') {
      $str .= "\n\n";
    } elsif ($element->tag() eq 'span'
	     and $element->attr('style') =~ /font-weight: *bold/) {
      $str .= "[b]" . html($element) . "[/b]";
    } elsif ($element->tag() =~ m/^(b|i|h[1-6])$/) {
      $str .= "[$1]" . html($element) . "[/$1]";
    } elsif ($element->tag() eq 'a'
	     and $element->attr('href')) {
      $str .= "[url=" . $element->attr('href') . "]" . html($element) . "[/url]";
    } elsif ($element->tag() eq 'img'
	     and $element->attr('src')) {
      $str .= "[img]" . $element->attr('src') . "[/img]";
    } elsif ($element->tag() eq 'pre') {
      $str .= "\n\n[code]\n" . $element->as_text() . "\n[/code]";
      $p = 1;
    } elsif ($element->tag() eq 'div'
	     and ($element->attr('style') =~ /float: *(left|right)/
		  or $element->attr('style') =~ /text-align: *(center)/)) {
      $str .= "\n[$1]" . html($element) . "[/$1]";
      $p = 1;
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
  my ($url, $ns, $name, $data) = @_;
  my $id = FreeToNormal($name);
  print $q->p("Copying ", $q->a({-href=>$url}, "the blog post") . "…");
  my $text = "Based on [$url $name].\n----\n" . $data;
  my $ua = LWP::UserAgent->new;
  my %params = (text => $text,
		title => $id,
		summary => $name,
		username => GetParam('username'),
		ns => $ns,
		pwd => GetParam('pwd'));
  $params{$QuestionaskerSecretKey} = 1 if $QuestionaskerSecretKey;
  my $response = $ua->post($FullUrl, \%params);
  if ($response->is_error) {
    print $q->p("Copying failed!");
    print $q->p($q->strong($response->status_line));
    print $response->content;
  } else {
    print $q->p("Your copy: ", GetPageLink($name) . ".");
  }
}

sub main {
  Init();
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } else {
    $UserGotoBar .= $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Copy a blog article');
    print $q->start_div({-class=>'content index'});
    my $url = GetParam('url');
    my $ns = GetParam('ns');
    if (not $url or not $ns) {
      default($url, $ns);
    } else {
      my ($name, $data) = get_data($url);
      $name = GetParam('name', $name);
      if (name_exists($name) and not GetParam('confirm', 0)) {
	confirm_overwrite($url, $ns, $name);
      } elsif (not GetParam('confirm', 0)) {
	confirm_save($url, $ns, $name);
      } else {
	post_addition($url, $ns, $name, $data);
      }
    }
    print $q->p('Questions? Send mail to Alex Schröder <'
		. $q->a({-href=>'mailto:kensanata@gmail.com'},
			'kensanata@gmail.com') . '>');
    print $q->end_div();
    PrintFooter();
  }
}

__DATA__
