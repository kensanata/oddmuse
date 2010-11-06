#! /usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);

if (param('separator') eq 'UseMod 0.92' or param('separator') eq 'UseMod 1.00') {
  $FS = "\xb3";
} elsif (param('separator') eq 'UseMod 1.00 with $NewFS set') {
  $FS = "\x1e\xff\xfe\x1e";
} else {
  $FS = "\x1e";
}

$NewFS = "\x1e";

# override $FS if you want!

print header() . start_html('Upgrading Files'), p;
print q{Upgrade version: $Id: upgrade-files.pl,v 1.16 2010/11/06 11:51:18 as Exp $}, "\n";
if (not param('dir')) {
  print start_form, p, '$DataDir: ', textfield('dir', '/tmp/oddmuse'),
    p, radio_group('separator', ['Oddmuse', 'UseMod 0.92', 'UseMod 1.00',
				 'UseMod 1.00 with $NewFS set']),
    p, checkbox('convert', 'checked', 'on', 'Convert Latin-1 to UTF-8'),
    p, submit('Ok'), "\n", end_form;
} elsif (param('dir') and not param('sure')) {
  print start_form, hidden('sure', 'yes'), hidden('dir', param('dir')),
    hidden('separator', param('separator')), hidden('convert', param('convert')),
    p, '$DataDir: ', param('dir'),
    p, 'separator used when reading pages: ',
    join(', ', map { sprintf('0x%x', ord($_)) } split (//, $FS)),
    p, 'separator used when writing pages: ',
    join(', ', map { sprintf('0x%x', ord($_)) } split (//, $NewFS)),
    p, 'Convert Latin-1 to UTF-8: ', param('convert') ? 'Yes' : 'No',
    p, submit('Confirm'), "\n", end_form;
} else {
  rewrite(param('dir'));
}
print end_html();

sub rewrite {
  my ($directory) = @_;
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
    my %page = split(/$FS1/, read_file($file), -1);
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
    $data =~ s/$FS1/$NewFS/g;
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
    # We introduce a new variable $dir, here, instead of using $out,
    # because $out will be part of the filename later on, and the
    # filename will be converted in write_file.  To convert $out to
    # utf8 would double-encode the directory part of the filename.
    my $dir = param('convert') ? utf8($out) : $out;
    print "Creating $out...\n";
    mkdir($dir) or die "Cannot create directory $dir\n" unless -d $dir;
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
      $_ = join($NewFS, $ts, $pagename, $minor, $summary, $host,
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
  local $/ = undef;		# Read complete files
  open(F, "<$filename") or die "can't read $filename: $!";
  $data=<F>;
  close F;
  return $data;
}

sub write_file {
  my ($filename, $data) = @_;
  if (param('convert')) {
    $filename = utf8($filename);
    $data = utf8($data);
  }
  open(F, ">$filename") or die "can't write $filename: $!";
  print F $data;
  close F;
}

sub cache {
  $_ = shift;
  return "" unless $_;
  my ($block, $flag) = split(/$FS2/, $_);
  my @blocks = split(/$FS3/, $block);
  my @flags = split(/$FS3/, $flag);
  return 'blocks: ' . escape_newlines(join($NewFS, @blocks)) . "\n"
    . 'flags: ' . escape_newlines(join($NewFS, @flags)) . "\n";
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
  $data .= 'revision: ' . $section{revision} . "\n" if $section{revision};
  $data .= 'summary: ' . $section{summary} . "\n" if $section{summary};
  $data .= 'summary: ' . $text{summary} . "\n" if $text{summary} and not $section{summary};
  $data .= 'username: ' . $section{username} . "\n" if $section{username};
  $data .= 'ip: ' . $section{ip} . "\n" if $section{ip};
  $data .= 'host: ' . $section{host} . "\n" if $section{host};
  $data .= 'minor: ' . $text{minor} . "\n" if $text{minor};
  # $data .= 'oldmajor: ' . $page{cache_oldmajor} . "\n" if $page{cache_oldmajor};
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


# This Latin-1 to UTF-8 conversion was written by Skalman on the
# Oddmuse Wiki.  He says:  I added a quick, dirty and completely
# unreadable hack to convert all characters above 0x7F:

#  s/([\x80-\xff])/chr(0xc0+(ord($1)>>6)).chr(ord($1)&0b00111111|0b10000000)/ge;

# Reading the UTF-8 and Unicode FAQ, I convert every character to
# (binary) 110xxxxx 10xxxxxx where the 'x' marks the bits of the
# original ISO-8859-1 character. That is: take the two most
# significant bits of the caracter and add them to 0xC0 (first byte),
# then replace the first two bits with 10 (second byte).

sub utf8 {
  $_ = shift;
  s/([\x80-\xff])/chr(0xc0+(ord($1)>>6)).chr(ord($1)&0b00111111|0b10000000)/ge;
  return $_;
}
