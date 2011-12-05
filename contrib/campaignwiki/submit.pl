#!/usr/bin/perl

# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>

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
use URI;
use LWP::UserAgent;

# load Oddmuse core
$RunCGI = 0;
do "wiki.pl";

# globals
my $page = "Feeds";
my $site = "http://campaignwiki.org/wiki/Planet";
my $src = "$site/raw/$page";
my $target = "$site/$page";
$FullUrl = "http://campaignwiki.org/submit";
my %valid_content_type = ('application/atom+xml' => 1,
			  'application/rss+xml' => 1,
			  'application/xml' => 1,
			  'text/xml' => 1);

main();

sub default {
  print $q->p("Submit a blog to the "
	      . $q->a({-href=>'http://campaignwiki.org/planet'},
			'Old School RPG Planet') . ".");
  print GetFormStart();
  print $q->p($q->label({-for=>'url', -style=>'display: inline-block; width:30ex'},
			T('URL:')) . ' '
	      . $q->textfield(-style=>'display: inline-block; width:60ex',
			      -name=>'url', -id=>'url', -size=>50)
	      . $q->br()
	      . $q->label({-for=>'username', -style=>'display: inline-block; width:30ex'},
			  T('Your name for the log file:')) . ' '
	      . $q->textfield(-style=>'display: inline-block; width:60ex',
			      -name=>'username', -id=>'username', -size=>50));
  print $q->submit('go', 'Go!');
  print $q->end_form();
  print $q->p("Drag this bookmarklet to your bookmarks bar for easy access:",
	      $q->a({-href=>q{javascript:location='http://campaignwiki.org/submit?url='+encodeURIComponent(window.location.href)}}, 'Submit OSR Blog') . ".");
}

my %cached_blogs;

sub parse_blogs {
  return %cached_blogs if %cached_blogs;
  my @data = split(/\n/, GetRaw($src));
  my $url;
  my $name;
  foreach $_ (@data) {
    if (/^\[(.+)\]/) {
      $url = $1;
      $name = undef;
    } elsif (/^name *= *(.+)/) {
      $name = $1;
    }
    if ($url && $name) {
      $cached_blogs{$url} = $name;
    }
  }
  return %cached_blogs;
}

sub host_exists {
  my ($host, %blogs) = @_;
  foreach my $candidate (keys %blogs) {
    my $u = URI->new($candidate);
    return $candidate if $host eq $u->host;
  }
}

sub check_url {
  my $url = shift;
  my $frown = $q->img({-src=>"http://emacswiki.org/pics/smiles/sad.png",
		       -alt=>":("});
  my $smile = $q->img({-src=>"http://emacswiki.org/pics/smiles/smile.png",
		       -alt=>":)"});
  my $u = URI->new($url);
  eval {$u->host };
  if ($@) {
    $url = 'http://' . $url;
    $u = URI->new($url);
    eval {$u->host };
  }
  if ($@) {
    # the prefixing of http:// above should make it really hard to reach this code
    print $q->p($q->a({-href=>$url}, $url) . qq{
seems to be <strong>invalid</strong>. $frown Make sure you use something
like the following: <tt>http://grognardia.blogspot.com/</tt>});
  } elsif (not GetParam('username', '')) {
    print $q->p(qq{As an anti-spam measure I'd really like you to <strong>provide a name</strong> for the log file. Sorry about that. $frown});
  } else {
    my %blogs = parse_blogs();
    my $duplicate = host_exists($u->host, %blogs);
    if ($duplicate
	&& !$blogs{$url}
	&& !GetParam('confirmed')) {
      print $q->p("We have a partial match: ",
		  $q->a({-href=>$duplicate}, $duplicate));
      print GetFormStart();
      print $q->hidden('confirmed', 1);
      print $q->hidden('url', $url);
      print $q->submit('go', 'Proceed anyway!');
      print $q->end_form();
    } elsif ($url =~ /campaignwiki\.org/i) {
      print $q->p(qq{
This looks <strong>familiar</strong>!
I do not think that adding any of the wikis on this site is the right
thing to do, though.});
      print $q->p(qq{Thanks for testing it. }
		  . $q->img({-src=>"http://www.emacswiki.org/pics/grin.png"}));
    } else {
      my @alternatives = get_feeds($url, keys %blogs);
      if ($#alternatives > 0 && !GetParam('candidate')) {
	print GetFormStart();
	print $q->hidden('confirmed', 1);
	print $q->hidden('url', $url);
	print $q->p("You need to pick one of the candidates:");
	print $q->p(join($q->br(), map {
	  $q->input({-type=>"radio", -name=>"candidate", -value=>$_},
		    $q->a({-href=>$_}, QuoteHtml($_))) } @alternatives));
	print $q->submit('go', 'Submit');
	print $q->end_form();
      } elsif ($#alternatives < 0) {
	if (is_feed($url)) {
	  post_addition($url);
	} else {
	  print $q->p("Apparently " . $q->a({-href=>$url}, QuoteHtml($url))
		      . " is not a feed and doesn't link to any feed. "
		      . "There is nothing for me to add. " . $frown);
	}
      } else {
	my $candidate = GetParam('candidate');
	$candidate = $alternatives[0] unless $candidate;
	if (is_feed($candidate)) {
	  post_addition($candidate);
	} else {
	  print $q->p($q->a({-href=>$candidate}, "The page you submitted")
		      . " listed "
		      . $q->a({-href=>$candidate}, QuoteHtml($candidate))
		      . " as one of its feeds. "
		      . "But it turns out that this is not a valid feed! "
		      . "I can't add an invalid feed. " . $frown);
	}
      }
    }
  }
}

sub is_feed {
  my $url = shift;
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($url);
  return unless $response->is_success;
  return $valid_content_type{$response->content_type};
}

sub get_feeds {
  my $url = shift;
  my %others = map { $_ => 1 } @_;
  my @links = GetRaw($url) =~ /<link\b *(.*?)>/g;
  my @feeds;
  foreach my $link (@links) {
    my %link;
    foreach (split(/ /, lc($link))) {
      my ($attr, $val) = split(/=/, $_, 2);
      # strip quotes and garbage: "foo"/ -> foo
      my $to = index($val, substr($val, 0, 1), 1);
      $val = substr($val, 1, $to -1) if $to >= 0;
      $link{$attr} = $val;
    }
    next unless $link{rel} eq 'alternate';
    next unless $valid_content_type{$link{type}};
    push(@feeds, $link{href}) unless $others{$link{href}};
  }
  return @feeds;
}

sub post_addition {
  my $url = shift;
  print $q->p("Missing URL?") unless $url;
  my ($title, $final_url) = get_title($url);
  my %blogs = parse_blogs();
  if ($blogs{$final_url}) {
    print $q->p("The URL you ",
		$q->a({-href=>$url}, 'picked'),
		" is redirected to an URL we already list: ",
		$q->a({-href=>$final_url}, $blogs{$final_url}),
		".");
  } else {
    $title = $final_url unless $title;
    print $q->p("Adding ",
		$q->a({-href=>$final_url}, $title));
    $blogs{$url} = $title;
    my $result = qq{#! config file for the RPG Planet
# format:
# Feed URL in square brackets, followed by name = and the name of the feed
};
    foreach $url (sort {lc($blogs{$a}) cmp lc($blogs{$b})} keys %blogs) {
      $result .= "[$url]\nname = " . $blogs{$url} . "\n";
    }
    my $ua = LWP::UserAgent->new;
    my %params = (text => $result,
		  title => $page,
		  summary => $title,
		  username => GetParam('username'),
		  pwd => GetParam('pwd'));
    # spam fighting modules
    $params{$QuestionaskerSecretKey} = 1 if $QuestionaskerSecretKey;
    $params{$HoneyPotOk} = GetParam($HoneyPotOk, time) if $HoneyPotOk;
    my $response = $ua->post($site, \%params);
    if ($response->is_error) {
      print $q->p("The submission failed!");
      print $q->pre($response->status_line . "\n"
		    . $response->content);
    } else {
      print $q->p("See for yourself: ",
		  $q->a({-href=>$target}, $page));
    }
  }
}

sub get_title {
  my $uri = shift;
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($uri);
  return unless $response->is_success;
  my $title;
  $title = $1 if $response->content =~ m!<title.*?>(.*?)</title>!;
  return $title, $response->request->uri;
}

sub main {
  Init();
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } else {
    $UserGotoBar .= $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Submit a new blog');
    print $q->start_div({-class=>'content index'});
    if (not GetParam('url')
	or not GetParam($HoneyPotOk)) {
      default();
    } else {
      SetParam('title', 'Feeds'); # required to trigger HoneyPotInspection()
      HoneyPotInspection();
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
