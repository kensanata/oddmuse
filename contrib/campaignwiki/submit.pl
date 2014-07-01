#!/usr/bin/perl

# Copyright (C) 2010, 2012  Alex Schroeder <alex@gnu.org>

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
use utf8;

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
  my $paramref;
  foreach $_ (@data) {
    if (/^\[(.+)\]/) {
      $url = $1;
      $paramref = {};
    } elsif (/^([a-z_]+) *= *(.+)/) {
      $paramref->{$1} = $2;
    }
    if ($url && $paramref->{name}) {
      $cached_blogs{$url} = $paramref;
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

sub debug_url {
  my $url = $q->url(-path_info=>1) . "?debug=1;";
  $url .= join(";", map { $_ . "=" . GetParam($_) }
	       qw(username confirmed candidate url));
  return $url;
}

sub check_url {
  my $url = shift;
  print $q->p("Debug: url=$url") if GetParam("debug");
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

  # - not an url
  # - it's campaign wiki site
  # - no username
  # or read Feeds page and
  #   - it's a duplicate
  #   - it's a partial match: continue with confirmed=1
  # or read the list of alternatives from the url
  #     - one of the feeds listed is known: continue with confirmed=2
  #     - no feeds were listed: url is a feed or report it
  #     - one feed was listed: try it
  #     - some feeds were listed: pick one

  if ($@) {
    # the prefixing of http:// above should make it really hard to reach this code
    print $q->p($q->a({-href=>$url}, $url) . qq{
seems to be <strong>invalid</strong>. $frown Make sure you use something
like the following: <tt>http://grognardia.blogspot.com/</tt>});
    } elsif ($url =~ /campaignwiki\.org/i) {
      print $q->p(qq{
This looks <strong>familiar</strong>!
I do not think that adding any of the wikis on this site is the right
thing to do, though.});
      print $q->p(qq{Thanks for testing it. }
		  . $q->img({-src=>"http://www.emacswiki.org/pics/grin.png"}));
  } elsif (not GetParam('username', '')) {
    print $q->p(qq{As an anti-spam measure I'd really like you to
<strong>provide a name</strong> for the log file. Sorry about that. $frown});
  } else {
    my %blogs = parse_blogs();
    my $duplicate = host_exists($u->host, %blogs);
    if ($blogs{$url}) {
      print $q->p("We already list ",
		  $q->a({-href=>$duplicate}, $duplicate));
    } elsif ($duplicate	&& !GetParam('confirmed')) {
      print $q->p("We have a partial match: ",
		  $q->a({-href=>$duplicate}, $duplicate));
      print GetFormStart();
      print $q->hidden('confirmed', 1);
      print $q->hidden('url', $url);
      print $q->submit('go', 'Proceed anyway!');
      print $q->end_form();
    } else {
      my ($status, @alternatives) = get_feeds($url, %blogs);
      if ($status eq 'known' && GetParam('confirmed') < 2) {
	print $q->p($q->a({-href=>$url},
			  "The page you submitted")
		    . " lists "
		    . $q->a({-href=>$alternatives[0]},
			    "a known feed") . ".");
	print GetFormStart();
	print $q->hidden('confirmed', 2);
	print $q->hidden('url', $url);
	print $q->submit('go', 'Proceed anyway!');
	print $q->end_form();
      } elsif ($#alternatives < 0) {
	if (is_feed($url)) {
	  post_addition($url);
	} else {
	  print $q->p("Apparently " . $q->a({-href=>$url}, QuoteHtml($url))
		      . " is not a feed and doesn't link to any feed. "
		      . "There is nothing for me to add. " . $frown);
	  print $q->p("If you feel like it, you could try to "
		      . $q->a({-href=>debug_url()}, "debug")
		      . " this.");
	}
      } elsif ($#alternatives == 0) {
	print $q->p($q->a({-href=>$url}, "The page you submitted")
		    . " lists "
		    . $q->a({-href=>$alternatives[0]},
			    "one new feed")
		    .  ".");
	print GetFormStart();
	print $q->hidden('url', $alternatives[0]);
	print $q->submit('go', 'Take it!');
	print $q->end_form();
	print $q->p("If you feel like it, you could try to "
		    . $q->a({-href=>debug_url()}, "debug")
		    . " this.");
      } else {
	print GetFormStart();
	print $q->p("You need to pick one of the candidates:");
	print $q->p(join($q->br(), map {
	  $q->input({-type=>"radio", -name=>"url", -value=>$_},
		    $q->a({-href=>$_}, QuoteHtml($_))) } @alternatives));
	print $q->submit('go', 'Submit');
	print $q->end_form();
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
  my %others = @_;
  my $html = GetRaw($url);
  my @links = $html =~ /<link\b *(.*?)>/g;
  print $q->p("Debug: " . scalar(@links) . " links found") if GetParam("debug");
  print $q->pre($html) unless scalar(@links);
  print $q->p("Debug: no content returned") if GetParam("debug") and not $html;
  my @feeds;
  foreach my $link (@links) {

    print $q->p("Debug: $link")
      if GetParam("debug");

    if ($link !~ /\brel=(['"])alternate\1/i) {
      print $q->p("Debug: missing rel='alternate'")
	if GetParam("debug");
      next;
    }

    $link =~ /\btype=(['"])(.*?)\1/i;
    my $type = $2;
    if (not $valid_content_type{$type}) {
      print $q->p("Debug: type parameter is invalid ($type)")
	if GetParam("debug");
      next;
    }

    $link =~ /\bhref=(['"])(.*?)\1/i;
    my $href = $2;
    # clean up blogspot urls and prefer atom format
    $href =~ s/\?alt=rss$//i if $href =~ /blogspot/i;
    if (not $href) {
      print $q->p("Debug: href missing")
	if GetParam("debug");
      next;
    }
    if ($others{$href}) {
      print $q->p("Debug: feed already known ($href)")
	if GetParam("debug");
      if ($q->param('confirmed') >= 2) {
	next;
      } else {
	# don't look for other alternatives!
	return 'known', $href;
      }
    }

    push(@feeds, $href);
  }
  print $q->p("Debug: returning " . scalar(@feeds) . " links found")
    if GetParam("debug");
  return 'ok', @feeds;
}

sub config {
  my %blogs = @_;
  my $result = qq{#! config file for the RPG Planet
# format:
# Feed URL in square brackets, followed by name = and the name of the feed
};
  foreach my $url (sort {lc($blogs{$a}->{name}) cmp lc($blogs{$b}->{name})} keys %blogs) {
    $result .= "[$url]\n";
    $paramref = $blogs{$url};
    foreach my $key (sort keys %{$paramref}) {
      $result .= $key . " = " . $paramref->{$key} . "\n";
    }
  }
  return $result;
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
    my %param = (name => $title);
    $blogs{$url} = \%param;
    my $result = config(%blogs);
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
  } elsif ($q->path_info eq '/test') {
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n";
    print config(parse_blogs());
  } else {
    $UserGotoBar .= $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Submit a new blog');
    print $q->start_div({-class=>'content index'});
    if (not GetParam('url')) {
      print $q->p("Debug: no url parameter provided.") if GetParam("debug");
      default();
    } else {
      SetParam('title', 'Feeds'); # required to trigger HoneyPotInspection()
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
