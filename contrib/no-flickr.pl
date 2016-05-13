#! /usr/bin/perl -w

# Copyright (C) 2005-2016  Alex Schroeder <alex@gnu.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use Modern::Perl;
use LWP::UserAgent;
use utf8;
binmode(STDOUT, ":utf8");

my $ua = LWP::UserAgent->new;

sub url_encode {
  my $str = shift;
  return '' unless $str;
  utf8::encode($str); # turn to byte string
  my @letters = split(//, $str);
  my %safe = map {$_ => 1} ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')', '#');
  foreach my $letter (@letters) {
    $letter = sprintf("%%%02x", ord($letter)) unless $safe{$letter};
  }
  return join('', @letters);
}

sub get_raw {
  my $uri = shift;
  my $response = $ua->get($uri);
  return $response->content if $response->is_success;
}

sub get_wiki_page {
  my ($wiki, $id, $password) = @_;
  my $parameters = [
    pwd => $password,
    action => 'browse',
    id => $id,
    raw => 1,
      ];
  my $response = $ua->post($wiki, $parameters);
  return $response->decoded_content if $response->is_success;
  die "Getting $id returned " . $response->status_line;
}

sub get_wiki_index {
  my $wiki = shift;
  my $parameters = [
    search => "flickr.com",
    context => 0,
    raw => 1,
      ];
  my $response = $ua->post($wiki, $parameters);
  return $response->decoded_content if $response->is_success;
  die "Getting the index returned " . $response->status_line;
}

sub post_wiki_page {
  my ($wiki, $id, $username, $password, $text) = @_;
  my $parameters = [
    username => $username,
    pwd => $password,
    recent_edit => 'on',
    text => $text,
    title => $id,
      ];
  my $response = $ua->post($wiki, $parameters);
  die "Posting to $id returned " . $response->status_line unless $response->code == 302;
}

my %seen = ();

sub write_flickr {
  my ($id, $flickr, $dir, $file) = @_;
  say "Found $flickr";
  warn "$file was seen before: " . $seen{$file} if $seen{$file};
  die "$file contains unknown characters" if $file =~ /[^a-z0-9_.]/;
  $seen{$file} = "$id used $flickr";
  my $bytes = get_raw($flickr) or die("No data for $id");
  open(my $fh, '>', "$dir/$file") or die "Cannot write $dir/$file";
  binmode($fh);
  print $fh $bytes;
  close($fh);
}

sub convert_page {
  my ($wiki, $pics, $dir, $username, $password, $id) = @_;
  say $id;
  my $text = get_wiki_page($wiki, $id, $password);
  my $is_changed = 0;
  while ($text =~ m!(https://[a-z0-9.]+.flickr.com/(?:[a-z0-9.]+/)?([a-z0-9_]+\.(?:jpg|png)))!) {
    my $flickr = $1;
    my $file = $2;
    write_flickr($id, $flickr, $dir, $file);
    $is_changed = 1;
    my $re = quotemeta($flickr);
    $text =~ s!$flickr!$pics/$file!g;
  }
  if ($is_changed) {
    post_wiki_page($wiki, $id, $username, $password, $text);
  } else {
    # die "$id has no flickr matches?\n$text";
  }
  sleep(5);
}

sub convert_site {
  my ($wiki, $pics, $dir, $username, $password) = @_;
  my @ids = split(/\n/, get_wiki_index($wiki));
  for my $id (@ids) {
    convert_page($wiki, $pics, $dir, $username, $password, $id);
  }
}

our $AdminPass;
do "/home/alex/password.pl";
convert_site('https://alexschroeder.ch/wiki',
	     'https://alexschroeder.ch/pics',
	     '/home/alex/alexschroeder.ch/pics',
	     'Alex Schroeder',
	     $AdminPass);
