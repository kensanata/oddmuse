#! /usr/bin/perl
my $usage = q{expire-pans.pl
Usage: this script expects to be run in a directory with a spammer.log file as
produced by the LogBannedContent module.
<https://oddmuse.org/wiki/LogBannedContent_Module>

In the same directory, it expects at least one of BannedContent, BannedHosts or
BannedRegexps. It will work on all three, though. These must be the raw text
files of the wiki.

Here's how you might get them from Emacs Wiki, for example.

wget https://www.emacswiki.org/spammer.log
wget https://www.emacswiki.org/emacs/raw/BannedContent
wget https://www.emacswiki.org/emacs/raw/BannedHosts
wget https://www.emacswiki.org/emacs/raw/BannedRegexps

};

die $usage if ! -f 'spammer.log'
    || !(-f 'BannedContent' || -f 'BannedHosts' || -f 'BannedRegexps');

my $fh;
my @bans;

warn "Reading spammer.log...\n";
open($fh, '<:utf8', 'spammer.log') or die "Cannot read spammer.log: $!";
for my $line (<$fh>) {
  push(@bans, $line);
}
close($fh);

for my $file (qw(BannedContent BannedHosts BannedRegexps)) {
  warn "Reading $file...\n";
  if (open($fh, '<:utf8', $file)) {
    my $count = 0;
    my $used = 0;
    my @out;
    for my $line (<$fh>) {
      if ($line =~ m/^\s*([^#]+?)\s*(#\s*(\d\d\d\d-\d\d-\d\d\s*)?(.*))?$/) {
	$count++;
	my ($regexp, $comment) = ($1, $4);
	foreach my $ban (@bans) {
	  if (index($ban, $regexp) > -1) {
	    $used++;
	    push(@out, $line);
	    last;
	  }
	}
      } else {
	push(@out, $line);
      }
    }
    close ($fh);
    warn "$count regular expressions checked\n";
    warn "$used regular expressions were used\n";
    warn "Writing $file-new...\n";
    open ($fh, '>:utf8', "$file-new")
	or die "Cannot write $file-new: $!";
    print $fh join("", @out);
    close $fh;
  }
}
