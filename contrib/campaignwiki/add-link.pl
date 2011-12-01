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
use utf8;

# load Oddmuse core
$RunCGI = 0;
do "wiki.pl";

# globals
my $name = "OSR Links to Wisdom";
my $wiki = 'LinksToWisdom';
my $site = "http://campaignwiki.org/wiki/$wiki";
# my $site = "http://localhost/wiki.pl";
my $home = "$site/$HomePage";

main();

sub toc {
  # start with the homepage
  my @values;
  my %labels;
  for my $id (GetPageContent($HomePage) =~ /\* \[\[(.*?)\]\]/g) {
    push @values, $id;
    for my $item (GetPageContent(FreeToNormal($id)) =~ /(\*+ [^][\n]*)$/mg) {
      my $value = $item;
      my $label = $item;
      $value =~ s/\* *//g;
      push @values, $value;
      $label =~ s/\* */ /g; # EM SPACE
      $labels{$value} = $label;
    }
  }
  return $q->radio_group(-name =>'toc',
			 -values => \@values,
			 -labels => \%labels,
			 -linebreak=>'true');
}

sub default {
  print $q->p("Add a link to the " . $q->a({-href=>$home}, $name) . ".");
  print $q->start_multipart_form(-method=>'get', -class=>'submit');
  print $q->p($q->label({-for=>'url'}, T('URL:')) . ' '
	      . $q->textfield(-name=>'url', -id=>'url', -size=>50));
  print toc();
  print $q->submit('go', 'Add!');
  print $q->end_form();
  print $q->p("Drag this bookmarklet to your bookmarks bar for easy access:",
	      $q->a({-href=>q{javascript:location='}
		   . $q->url()
		   . qq{?url='+encodeURIComponent(window.location.href)}},
		    "Submit $name") . ".");
}

sub check_url {
  my $toc = GetParam('toc');
  return default() unless $toc;
  my $url = shift;
  if (not GetParam('confirm', 0)) {
    my $name = get_name($url);
    print $q->p("Please confirm that you want to add "
		. GetUrl($url, $name)
		. " to the section “$toc”.");
    print $q->start_form(-method=>'get');
    print $q->p($q->label({-for=>'name', -style=>'display: inline-block; width:30ex'},
			  T('Use a different link name:')) . ' '
		. $q->textfield(-style=>'display: inline-block; width:60ex',
				-name=>'name', -id=>'name', -size=>50, -default=>$name)
		. $q->br()
	        . $q->label({-for=>'username', -style=>'display: inline-block; width:30ex'},
			    T('Your name for the log file:')) . ' '
	        . $q->textfield(-style=>'display: inline-block; width:60ex',
				-name=>'username', -id=>'username', -size=>50));
    my $star = $q->img({-src=>'http://www.emacswiki.org/pics/star.png', -class=>'smiley',
			-alt=>'star'});
    print '<p>Optionally: Do you want to rate it?<br />';
    my $i = 0;
    foreach my $label ($q->span({-style=>'display: inline-block; width:15ex'}, $star)
		       . 'I might use this for my next campaign',
		       $q->span({-style=>'display: inline-block; width:15ex'}, $star x 2)
		       . 'I have used this in a campaign and it worked as intended',
		       $q->span({-style=>'display: inline-block; width:15ex'}, $star x 3)
		       . 'I have used it in many of my campaigns',
		       $q->span({-style=>'display: inline-block; width:15ex'}, $star x 4)
		       . 'Everybody should give it a try',
		       $q->span({-style=>'display: inline-block; width:15ex'}, $star x 5)
		       . 'Everybody should use it, that is how awesome it is!') {
      $i++;
      print qq{<label><input type="radio" name="stars" value="$i" $checked/>$label</label><br />};
    }
    print '</p>';
    print $q->hidden('url', $url);
    print $q->hidden('toc', $toc);
    print $q->hidden('confirm', 1);
    print $q->submit('go', 'Continue');
    print $q->end_form();
  } else {
    post_addition($q->param('name'), $url, $toc);
  }
}

sub get_name {
  my $url = shift;
  my $tree = HTML::TreeBuilder->new_from_content(GetRaw($url));
  my $h = $tree->look_down('_tag', 'h1');
  $h = $tree->look_down('_tag', 'title') unless $h;
  $h = $h->as_text if $h;
  return $h;
}

sub post_addition {
  my ($name, $url, $toc) = @_;
  my $id = FreeToNormal($name);
  my $display = $name;
  utf8::decode($display); # we're dealing with user input
  print $q->p("Adding ", GetUrl($url, $display), " to “$toc”.");
  # start with the homepage
  my @pages = GetPageContent($HomePage) =~ /\* \[\[(.*?)\]\]/g;
  for my $id (@pages) {
    return post($id, undef, $name, $url, GetParam('stars', '')) if $id eq $toc;
    my $data = GetPageContent(FreeToNormal($id));
    while ($data =~ /(\*+ ([^][\n]*))$/mg) {
      return post($id, $1, $name, $url, GetParam('stars', '')) if $2 eq $toc;
    }
  }
  print $q->p("Whoops. I was unable to find “$toc” in the wiki. Sorry!");
}

sub post {
  my ($id, $toc, $name, $url, $stars) = @_;
  my $data = GetPageContent(FreeToNormal($id));
  $stars = ' ' . (':star:' x $stars) if $stars;
  if ($toc) {
    $toc =~ /^(\*+)/;
    my $depth = "*$1"; # one more!
    my $regexp = quotemeta($toc);
    $data =~ s/$regexp/$toc\n$depth \[$url $name\]$stars/;
  } else {
    $data = "* [$url $name]$stars\n" . $data;
  }
  my $ua = LWP::UserAgent->new;
  my %params = (text => $data,
  		title => $id,
  		summary => $name,
  		username => GetParam('username'),
  		pwd => GetParam('pwd'));
  # spam fighting modules
  $params{$QuestionaskerSecretKey} = 1 if $QuestionaskerSecretKey;
  $params{$HoneyPotOk} = time if $HoneyPotOk;
  my $response = $ua->post($site, \%params);
  if ($response->is_error) {
    print $q->p("The submission failed!");
    print $q->pre($response->status_line . "\n"
  		  . $response->content);
  } else {
    print $q->p("See for yourself: ", GetPageLink($id));
  }
}

sub main {
  $ConfigFile = "$DataDir/config"; # read the global config file
  $DataDir = "$DataDir/$wiki";     # but link to the local pages
  Init();                          # read config file (no modules!)
  $ScriptName = $site;             # undo setting in the config file
  binmode(STDOUT,':utf8');
  $q->charset('utf8');
  if ($q->path_info eq '/source') {
    seek DATA, 0, 0;
    print "Content-type: text/plain; charset=UTF-8\r\n\r\n", <DATA>;
  } else {
    $UserGotoBar = $q->a({-href=>$q->url . '/source'}, 'Source');
    print GetHeader('', 'Submit a new link');
    print $q->start_div({-class=>'content index'});
    if (not GetParam('url')) {
      default();
    } else {
      check_url(GetParam('url'));
    }
    print $q->p('Questions? Send mail to Alex Schroeder <'
		. $q->a({-href=>'mailto:kensanata@gmail.com'},
			'kensanata@gmail.com') . '>');
    print $q->end_div();
    PrintFooter();
  }
}

__DATA__
