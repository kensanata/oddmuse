#! /usr/bin/perl
package OddMuse;
my $dir = '/var/www/wiki';
my $script = '/usr/lib/cgi-bin/wiki.pl';
my @path = split(/\//, $ENV{REDIRECT_URL});
my $file = $path[$#path];

# remember to compare modification dates on the pageidx file!
# remember to set $ScriptName in the config correctly.
# call $script as "true CGI" so that we can look at http status codes!

{
  local $/;
  open(F, "$script |") || print STDERR "can't run $script: $!\n";
  my $data = <F>;
  print $data;
  open(G, "> $dir/$file") || print STDERR "can't write $dir/$file: $!\n";
  print G $data;
}

