#!/usr/bin/perl
$dir = "/org/org.emacswiki/htdocs";
opendir(DIR, $dir) || die "can't opendir $dir: $!";
@names = grep { /^[a-z]+$/ && -d "$dir/$_" && -d "$dir/$_/keep" } readdir(DIR);
closedir DIR;

for $f (@names) {
  system('wget', '-O', "/org/org.emacswiki/htdocs/maintenance/$f.html",
         "http://www.emacswiki.org/cgi-bin/$f?action=maintain");
}
