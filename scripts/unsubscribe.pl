#! /usr/bin/perl
# Copyright (C) 2010–2021  Alex Schroeder <alex@gnu.org>

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

=head1 NAME

unsubscribe.pl - mass unsubscribe from Oddmuse

=head2 SYNOPSIS

B<perl unsubscribe.pl> F<MAILDB> [B<--regexp=>I<REGEXP>]

B<perl unsubscribe.pl> F<MAILDB> [B<--dump>]

=head2 DESCRIPTION

If you use the Mail Extension to Oddmuse, you end up with subscriptions to very
old pages. This script helps you unsubsribe people from old pages.

C<--regexp> indicates a regular expression matching pages names

The mandatory F<MAILDB> argument is the file containing all the mail
subscriptions.

=head2 EXAMPLES

Make a copy, unsubscribe people, check a dump of the remaining subscriptions,
and move the file back to the wiki data directory.

    cp ~/alexschroeder/mail.db copy.db
    perl ~/src/oddmuse/scripts/unsubscribe.pl copy.db --regexp='20[01][0-9]'
    perl ~/src/oddmuse/scripts/unsubscribe.pl copy.db --dump
    mv copy.db ~/alexschroeder/mail.db

=cut;

use Modern::Perl;
use Getopt::Long;
use Encode qw(encode_utf8 decode_utf8);
use DB_File;

binmode(STDOUT, ":utf8");

my $re = "";
my $confirm;
my $dump;

GetOptions ("regexp=s" => \$re,
	    "dump" => \$dump,
	    "confirm" => \$confirm, );

my $file = shift;

die "Not a file: $file" unless -f $file;
die "Unknown arguments: @ARGV" if @ARGV;

sub UrlEncode {
  my $str = shift;
  return '' unless $str;
  my @letters = split(//, encode_utf8($str));
  my %safe = map {$_ => 1} ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')', '#');
  foreach my $letter (@letters) {
    $letter = sprintf("%%%02x", ord($letter)) unless $safe{$letter};
  }
  return join('', @letters);
}

sub UrlDecode {
  my $str = shift;
  return '' unless $str;
  $str =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/eig;
  return decode_utf8($str);
}

tie my %h, "DB_File", $file;
my $FS = "\x1e";

if ($dump) {
  for my $key (keys %h) {
    my @value = split /$FS/, UrlDecode($h{$key});
    say UrlDecode($key), ": @value";
  }
  exit;
}

for my $raw (keys %h) {
  if ($raw =~ /@/) {
    # email address
    my $mail = UrlDecode($raw);
    my $value = $h{$raw};
    my @subscriptions = grep !/$re/, map { UrlDecode($_) } split /$FS/, $value;
    if (@subscriptions) {
      $h{$raw} = join $FS, map { UrlEncode($_) } @subscriptions if $confirm;
      say "> $mail: remains subscribed to @subscriptions";
    } else {
      delete $h{$raw} if $confirm;
      say "> $mail: unsubscribe from all pages";
    }
  } else {
    my $id = UrlDecode($raw);
    next unless $id =~ /$re/;
    delete $h{$raw} if $confirm;
    say "Delete $id";
  }
}

untie %h;

say "Use --confirm to actually do it" unless $confirm;
