#! /usr/bin/perl
package OddMuse;
my $dir = '/var/www/wiki';
my $script = '/usr/lib/cgi-bin/wiki.pl';
my $name = '/cgi-bin/wiki.pl';
my @path = split(/\//, $ENV{REDIRECT_URL});
my $file = $path[$#path];
# we only  care about the timestamp of the following two files.
# the timestamp of the first file is changed whenever a page is
# changed.
my $pageidx = '/tmp/oddmuse/pageidx';
my $cachepageidx = '/tmp/oddmuse/pageidx-cache';

# cache cleanup: if any page was changed, invalidate the cache
my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
  = stat($pageidx);
my $timestamp = $mtime;
if (not -f $cachepageidx) {
  open(F, "> $cachepageidx");
  close(F);
}
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
  = stat($cachepageidx);
if ($timestamp != $mtime) {
  unlink(glob("$dir/*"));
  utime $timestamp, $timestamp, $cachepageidx; # touch index file
}
print "<p><strong>$timestamp: ", join(", ", $atime,$mtime,$ctime), "</strong>";

# now call the wiki for the page missing in the cache.
# first set up CGI environment -- see http://localhost/cgi-bin/printenv.
# then call the script and read output from the pipe.

local $/;
local %ENV;
$ENV{REQUEST_METHOD}="GET";
$ENV{QUERY_STRING}=$file;
$ENV{SCRIPT_FILENAME}=$script;
$ENV{SCRIPT_NAME}=$name;
# print "Content-Type: text/plain\r\n\r\n";
# print "$script $file\n";
open(F, "$script |") || print STDERR "can't run $script: $!\n";
my $data = <F>;
close(F);

# print data to stdout and write a copy without headers into the cache
# if the script didn't print a Status (since the default is "200 Ok").

print $data;
$data =~ /^Status: ([1-9][0-9][0-9])/;
my $status = $1;
$data =~ /((.+:.*\n)*)/;
my $header = $1;
# print "<pre>$header</pre>";
if (not $status) { # ie. 200
  $data =~ s/^(.*\r\n)+//; # strip header
  open(G, "> $dir/$file") || print STDERR "can't write $dir/$file: $!\n";
  print G $data;
  close(G);
}
