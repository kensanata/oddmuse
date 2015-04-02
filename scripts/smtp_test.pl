#! /usr/bin/perl
# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>

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

use strict;
use Getopt::Std;
use File::Temp;
use MIME::Entity;

# This script can be invoked as follows:
# perl smtp_test.pl -m "alex:*secret*@mail.epfarms.org" \
#                   -f "kensanata@gmail.com"

# -m user:password@mailhost for sending email using SMTP Auth. Without this
#    information, the script will send mail to localhost.
# -f email address to use as the sender and recipient.

my %opts;
getopt('mf', \%opts);
die "Must provide an SMTP host using -m\n" unless $opts{m};
$opts{m} =~ /(.*?):(.*)\@(.*)/;
my ($user, $password, $host) = ($1, $2, $3);
die "Cannot parse -m " . $opts{m} . "\n" unless $host;
my $from = $opts{f};
die "Must provide sender using -f\n" if $host && !$from;

my ($fh, $filename) = File::Temp->new(SUFFIX => '.html', UNLINK => 1);
print $fh qq(<body>This is a <b>test</b>!);
$fh->close;

eval {
  require Net::SMTP::TLS;
  my $mail = new MIME::Entity->build(To => $from, # test!
				     From => $from,
				     Subject => 'Test Net::SMTP::TLS',
				     Path => $fh,
				     Type => "text/html");
  my $smtp = Net::SMTP::TLS->new($host,
				 User => $user,
				 Password => $password,
				 Debug => 1);
  $smtp->mail($from);
  $smtp->to($from); # test!
  $smtp->data;
  $smtp->datasend($mail->stringify);
  $smtp->dataend;
  $smtp->quit;
};

warn "Net::SMTP::TLS problem: $@" if $@;

eval {
  require Net::SMTP::SSL;
  my $mail = new MIME::Entity->build(To => $from, # test!
				     From => $from,
				     Subject => 'Test Net::SMTP::SSL',
				     Path => $fh,
				     Type => "text/html");
  my $smtp = Net::SMTP::SSL->new($host, Port => 465,
				 Debug => 1);
  $smtp->auth($user, $password);
  $smtp->mail($from);
  $smtp->to($from); # test!
  $smtp->data;
  $smtp->datasend($mail->stringify);
  $smtp->dataend;
  $smtp->quit;
};

warn "Net::SMTP::SSL problem: $@" if $@;
