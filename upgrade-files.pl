#! /usr/bin/perl -w

# This is what I used for testing:
# cd /tmp; rm -rf org.emacswiki oddmuse; tar xzf ~/Backups/community.tar.gz; ln -s /tmp/org.emacswiki/htdocs/community/ /tmp/oddmuse; perl ~/src/oddmuse/upgrade-files.pl dir=/tmp/oddmuse sure=yes; chgrp www-data -R /tmp/org.emacswiki/htdocs/community/; chmod g+w -R /tmp/org.emacswiki/htdocs/community/

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
print header() . start_html(), p;
print 'Upgrade version: $Id: upgrade-files.pl,v 1.7 2003/12/24 04:05:18 uid68242 Exp $', "\n";
if (not param('dir')) {
  print start_form, p,
    '$DataDir: ', textfield('dir', '/tmp/oddmuse'),
      p, submit('Ok'), "\n", end_form;
} elsif (param('dir') and not param('sure')) {
  print start_form, hidden('sure', 'yes'), hidden('dir', param('dir')),
    '$DataDir: ', param('dir'),
      p, submit('Confirm'), "\n", end_form;
} else {
  rewrite(param('dir'));
}
print end_html();

sub rewrite {
  my ($directory) = @_;
  # $FS  = "\xb3";  -- old separator
  $FS  = "\x1e"; #  -- new separator
  $FS1 = $FS . "1";
  $FS2 = $FS . "2";
  $FS3 = $FS . "3";
  my @files = glob("$directory/page/*/*.db");
  if (not @files) {
    print "$directory does not seem to be a data directory.\n";
    return;
  }
  print '<pre>';
  foreach my $file (@files) {
    print "Reading page $file...\n";
    %page = split(/$FS1/, read_file($file), -1);
    %section = split(/$FS2/, $page{text_default}, -1);
    %text = split(/$FS3/, $section{data}, -1);
    $file =~ s/\.db$/.pg/ or die "Invalid page name\n";
    print "Writing $file...\n";
    write_page_file($file);
  }
  print '</pre>';
  @files = glob("$directory/referer/*/*.rb");
  print '<pre>';
  foreach my $file (@files) {
    print "Reading refer $file...\n";
    my $data = read_file($file);
    $data =~ s/$FS1/$FS/g;
    $file =~ s/\.rb$/.rf/ or die "Invalid page name\n";
    print "Writing $file...\n";
    write_file($file, $data);
  }
  print '</pre>';
  @files = glob("$directory/keep/*/*.kp");
  foreach my $file (@files) {
    print '<pre>';
    print "Reading keep $file...\n";
    my $data = read_file($file);
    my @list = split(/$FS1/, $data);
    my $out = $file;
    $out =~ s/\.kp$// or die "Invalid keep name\n";
    print "Creating $out...\n";
    mkdir($out) or die "Cannot create directory $out\n" unless -d $out;
    foreach my $keep (@list) {
      next unless $keep;
      %section = split(/$FS2/, $keep, -1);
      %text = split(/$FS3/, $section{data}, -1);
      my $current = "$out/$section{'revision'}.kp";
      print "Writing $current...\n";
      write_keep_file($current);
    }
    print '</pre>';
  }
  @files = glob("$directory/*rclog");
  print '<pre>';
  foreach my $file (@files) {
    print "Reading $file...\n";
    my $data = read_file($file);
    @rc = split(/\n/, $data);
    foreach (@rc) {
      my ($ts, $pagename, $summary, $minor, $host, $kind, $extraTemp)
	= split(/$FS3/, $_);
      my %extra = split(/$FS2/, $extraTemp, -1);
      foreach ('name', 'revision', 'languages', 'cluster') {
	$extra{$_} = '' unless $extra{$_};
      }
      $extra{languages} =~ s/$FS1/,/g;
      $_ = join($FS, $ts, $pagename, $minor, $summary, $host,
		$extra{name}, $extra{revision}, $extra{languages}, $extra{cluster});
    }
    $data = join("\n", @rc) . "\n";
    $file =~ s/log$/.log/;
    print "Writing $file...\n";
    write_file($file, $data);
  }
  print '</pre>';
  print p, "Done.\n";
}

sub read_file {
  my ($filename) = @_;
  my ($data);
  my (%page);
  local $/ = undef;		# Read complete files
  open(F, "<$filename") or die "can't read $filename: $!";
  $data=<F>;
  close F;
  return $data;
}

sub write_file {
  my $filename = shift;
  open(F, ">$filename") or die "can't read $filename: $!";
  print F (shift);
  close F;
}

sub cache {
  $_ = shift;
  my ($block, $flag) = split(/$FS2/, $_);
  my @blocks = split(/$FS3/, $block);
  my @flags = split(/$FS3/, $flag);
  return 'blocks: ' . escape_newlines(join($FS, @blocks)) . "\n"
    . 'flags: ' . escape_newlines(join($FS, @flags)) . "\n";
}

sub escape_newlines {
  $_ = shift;
  $_ =~ s/\n/\n\t/g if $_;
  return $_;
}

# Skip the info encoded in the filename (page name).  We need the info
# stored in the rclog (summary, ip, host, username) for the history
# page.  Don't trust the modification dates of the files themselves,
# which is why we have the timestamp in the file, too.  We need the
# timestamp when expiring old keep files.  We need all the info in the
# page file that will eventually end up in the keep file.

sub basic_data {
  my $data = 'ts: ' . $section{ts} . "\n" if $section{ts};
  $data .= 'keep-ts: ' . $section{keepts} . "\n" if $section{keepts};
  $data .= 'revision: ' . $section{revision} . "\n" if $page{revision};
  $data .= 'summary: ' . $section{summary} . "\n" if $section{summary};
  $data .= 'username: ' . $section{username} . "\n" if $section{username};
  $data .= 'ip: ' . $section{ip} . "\n" if $section{ip};
  $data .= 'host: ' . $section{host} . "\n" if $section{host};
  $data .= 'minor: ' . $text{minor} . "\n" if $text{minor};
  $data .= 'oldmajor: ' . $page{cache_oldmajor} . "\n" if $page{cache_oldmajor};
  $data .= 'text: ' . escape_newlines($text{text}) . "\n";
  return $data;
}

sub write_page_file {
  my $file = shift;
  my $data = basic_data();
  $data .= cache($page{cache_blocks});
  $data .= 'diff-major: ' . escape_newlines($page{cache_diff_default_major}) . "\n"
    if $page{cache_diff_default_major};
  $data .= 'diff-minor: ' . escape_newlines($page{cache_diff_default_minor}) . "\n"
    if $page{cache_diff_default_minor};
  write_file($file, $data);
}

sub write_keep_file {
  my $file = shift;
  my $data = basic_data();
  write_file($file, $data);
}
