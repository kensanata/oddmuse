#!/usr/bin/perl -T
# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>

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
use v5.10;
use CGI;
#use CGI::Carp qw ( fatalsToBrowser );
use File::Basename;

AddModuleDescripton('upload.pl');

$CGI::POST_MAX = 1024 * 100000;
my $filenameWhitelist = 'a-zA-Z0-9_.-';
my @additionalChars = ('A'..'Z', 'a'..'z', '0'..'9');
my $urlStart = 'http://files.YOURDOMAIN.org/'; # CHANGE THIS
my $uploadDir = '../upload/';
my $logFile = '../upload.log';
my %keys = qw(justletmeupload you); # CHANGE THIS

sub squeak {
  say shift;
  die;
}

my $q = new CGI;
print $q->header();

if (not exists $keys{$q->param("key")}) {
  squeak 'Error: Not authorized to upload';
}

if (not $q->param("fileToUpload0")) {
  squeak 'Error: There was a problem uploading your file (try a smaller file)';
}

for (my $i=0; $q->param("fileToUpload$i"); $i++) {
  if ($i >= 100) { # Uploading more than 100 files? What?
    squeak 'Error: Cannot upload more than 100 files at once';
  }

  my $curFilename = substr $q->param("fileToUpload$i"), -100;

  my($name, $path, $extension) = fileparse($curFilename, '\..*');
  $name =~ tr/ /_/;
  $name =~ s/[^$filenameWhitelist]//g;
  $extension =~ tr/ /_/;
  $extension =~ s/[^$filenameWhitelist]//g;

  $curFilename = $name . $extension;

  while (-e "$uploadDir/$curFilename") { # keep adding random characters until we get unique filename
    squeak 'Error: Cannot save file with such filename' if length $curFilename >= 150; # cannot find available filename after so many attempts
    $name .= $additionalChars[rand @additionalChars];
    $curFilename = $name . $extension;
  }

  if ($curFilename =~ /^([$filenameWhitelist]+)$/) { # filename is already safe, but we have to untaint it
    $curFilename = $1;
  } else {
    squeak 'Error: Filename contains invalid characters'; # this should not happen
  }

  open(LOGFILE, '>>', $logFile) or squeak "$!";
  print LOGFILE $q->param("key") . ' ' . $ENV{REMOTE_ADDR} . ' ' . $curFilename . "\n";
  close LOGFILE;

  my $uploadFileHandle = $q->upload("fileToUpload$i");

  open(UPLOADFILE, '>', "$uploadDir/$curFilename") or squeak "$!";
  binmode UPLOADFILE;
  while (<$uploadFileHandle>) {
    print UPLOADFILE;
  }
  close UPLOADFILE;
  if ($q->param("nameOnly")) {
    print "$curFilename\n";
  } else {
    print "$urlStart$curFilename\n";
  }
}
