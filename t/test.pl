# Copyright (C) 2004–2015  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2015       Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;
use lib '.';
use XML::LibXML;
use utf8;
use vars qw($raw);

# Test::More explains how to fix wide character in print issues
my $builder = Test::More->builder;
binmode $builder->output,         ":encoding(UTF-8)";
binmode $builder->failure_output, ":encoding(UTF-8)";
binmode $builder->todo_output,    ":encoding(UTF-8)";

# Import the functions

$raw = 0;       # capture utf8 is the default
$RunCGI = 0;    # don't print HTML on stdout
$UseConfig = 0; # don't read module files
$DataDir = 'test-data';
while (not mkdir($DataDir)) {
  $DataDir = sprintf("test-data-%03d", int(rand(1000)));
}
$ENV{WikiDataDir} = $DataDir;
require 'wiki.pl';

# Try to guess which Perl we should be using. Since we loaded wiki.pl,
# our $ENV{PATH} is set to /bin:/usr/bin in order to find diff and
# grep.
if ($ENV{PERLBREW_PATH}) {
  $ENV{PATH} = $ENV{PERLBREW_PATH} . ':' . $ENV{PATH};
} elsif (-f '/usr/local/bin/perl') {
  $ENV{PATH} = '/usr/local/bin:' . $ENV{PATH};
}

clear_pages();
Init();
use vars qw($redirect);

undef $/;
$| = 1; # no output buffering

sub url_encode {
  my $str = shift;
  return '' unless $str;
  utf8::encode($str); # turn to byte string
  my @letters = split(//, $str);
  my @safe = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.'); # shell metachars are unsafe
  foreach my $letter (@letters) {
    my $pattern = quotemeta($letter);
    if (not grep(/$pattern/, @safe)) {
      $letter = sprintf("%%%02x", ord($letter));
    }
  }
  return join('', @letters);
}

# Run perl in a subprocess and make sure it prints UTF-8 and not Latin-1
# If you use the download action, the output will be raw bytes. Use
# something like the following:
# {
#   local $raw = 1;
#   $page = get_page('action=download id=Trogs');
# }
sub capture {
  my $command = shift;
  if ($raw) {
    open (CL, '-|', $command) or die "Can't run $command: $!";
  } else {
    open (CL, '-|:encoding(utf-8)', $command) or die "Can't run $command: $!";
  }
  my $result = <CL>;
  close CL;
  return $result;
}

sub update_page {
  my ($id, $text, $summary, $minor, $admin, @rest) = @_;
  $id = FreeToNormal($id);
  my $pwd = $admin ? 'foo' : 'wrong';
  my $page = url_encode($id);
  $text = url_encode($text);
  $summary = url_encode($summary);
  $minor = $minor ? 'on' : 'off';
  my $rest = join(' ', @rest);
  $redirect = capture("perl wiki.pl 'Save=1' 'title=$page' 'summary=$summary' 'recent_edit=$minor' 'text=$text' 'pwd=$pwd' $rest");
  $output = capture("perl wiki.pl action=browse id=$page $rest");
  if ($redirect =~ /^Status: 302 /) {
    # just in case a new page got created or NearMap or InterMap
    $IndexHash{$id} = 1;
    @IndexList = sort(keys %IndexHash);
    ReInit($id); # if $id eq $InterMap, we need it to be in the $IndexHash before running ReInit()
  }
  return $output;
}

sub get_page {
  return capture("perl wiki.pl @_");
}

sub name {
  $_ = shift;
  s/\n/\\n/g;
  $_ = '...' . substr($_, -67) if length > 70;
  return $_;
}

sub newlines {
  my @strings = @_;
  return map { s/\\n/\n/g; $_; } @strings;
}

# alternating input and output strings for applying rules
sub run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = newlines(@_);
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    is($result, $output, name($input));
  }
}

# alternating input and output strings for applying rules
sub run_tests_negative {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = newlines(@_);
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    isnt($result, $output, name($input));
  }
}

sub apply_rules {
  my $input = shift;
  local *STDOUT;
  $output = '';
  open(STDOUT, '>', \$output) or die "Can't open memory file: $!";
  $FootnoteNumber = 0;
  ApplyRules(QuoteHtml($input), 1);
  return $output;
}

# alternating input and output strings for applying macros instead of rules
sub run_macro_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my %test = map { s/\\n/\n/g; $_; } @_;
  # Note that the order of tests is not specified!
  foreach my $input (keys %test) {
    $_ = $input;
    foreach my $macro (@MyMacros) { &$macro; }
    is($_, $test{$input}, $input);
  }
}

# one string, many tests
sub test_page {
  my ($page, @tests) = @_;
  foreach my $test (@tests) {
    like($page, qr($test), name($test));
  }
}

# one file, many tests
sub test_file {
  my ($file, @tests) = @_;
  if (open(F, '< :encoding(UTF-8)', $file)) {
    local $/ = undef;
    test_page(<F>, @tests);
    close(F);
  } else {
    warn "cannot open $file\n";
  }
}

# one string, many negative tests
sub test_page_negative {
  my $page = shift;
  foreach my $str (@_) {
    unlike($page, qr($str), name("not $str"));
  }
}

sub xpath_do {
  my ($check, $message, $page, @tests) = @_;
  $page =~ s/^.*?(<html)/$1/s; # strip headers
  $page =~ s/^.*?<\?xml.*?>\s*//s; # strip xml processing
  my $page_shown = 0;
  my $parser = XML::LibXML->new();
  my $doc;
  my @result;
 SKIP: {
    eval { $doc = $parser->parse_html_string($page) };
    eval { $doc = $parser->parse_string($page) } if $@;
    skip("Cannot parse ".name($page).": $@", $#tests + 1) if $@;
    foreach my $test (@tests) {
      my $nodelist;
      my $bytes = $test;
      # utf8::encode: Converts in-place the character sequence to the
      # corresponding octet sequence in *UTF-X*. The UTF8 flag is
      # turned off, so that after this operation, the string is a byte
      # string. (I have no idea why this is necessary, but there you
      # go. See encoding.t tests and make sure the page file is
      # encoded correctly.)
      utf8::encode($bytes);
      eval { $nodelist = $doc->findnodes($bytes) };
      if ($@) {
	fail(&$check(1) ? "$test: $@" : "not $test: $@");
      } elsif (ok(&$check($nodelist->size()),
		  name(&$check(1) ? $test : "not $test"))) {
	push(@result, $nodelist->string_value());
      } else {
	$page =~ s/^.*?<html/<html/s;
	diag($message, substr($page,0,30000)) unless $page_shown;
	$page_shown = 1;
      }
    }
  }
  return wantarray ? @result : $result[0]; # list or string of first result
}

sub xpath_test {
  xpath_do(sub { shift > 0; }, "No Matches\n", @_);
}

sub xpath_test_file {
  my ($file, @tests) = @_;
  if (open(F, '< :encoding(UTF-8)', $file)) {
    local $/ = undef;
    xpath_test(<F>, @tests);
    close(F);
  } else {
    warn "cannot open $file\n";
  }
}

sub negative_xpath_test {
  xpath_do(sub { shift == 0; }, "Unexpected Matches\n", @_);
}

# alias
sub xpath_test_negative {
  return negative_xpath_test(@_);
}

sub xpath_run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = newlines(@_);
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    xpath_test("<div>$result</div>", $output);
  }
}

sub xpath_run_tests_negative {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = newlines(@_);
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    xpath_test_negative("<div>$result</div>", $output);
  }
}

sub remove_rule {
  my $rule = shift;
  my @list = ();
  my $found = 0;
  foreach my $item (@MyRules) {
    if ($item ne $rule) {
      push @list, $item;
    } else {
      $found = 1;
    }
  }
  die "Rule not found" unless $found;
  @MyRules = @list;
}

sub add_module {
  my ($mod, $subdir) = @_;
  $subdir .= '/' if $subdir and substr($subdir, -1) ne '/';
  mkdir $ModuleDir unless -d $ModuleDir;
  my $dir = `/bin/pwd`;
  chop($dir);
  if (-l "$ModuleDir/$mod") {
    # do nothing
  } elsif (eval{ symlink("$dir/modules/$subdir$mod", "$ModuleDir/$mod"); 1; }) {
    # do nothing
  } else {
    system('copy', "$dir/modules/$subdir$mod", "$ModuleDir/$mod");
  }
  die "Cannot symlink $mod: $!" unless -e "$ModuleDir/$mod";
  do "$ModuleDir/$mod";
  @MyRules = sort {$RuleOrder{$a} <=> $RuleOrder{$b}} @MyRules;
}

sub remove_module {
  my $mod = shift;
  mkdir $ModuleDir unless -d $ModuleDir;
  unlink("$ModuleDir/$mod") or die "Cannot unlink: $!";
}

sub write_config_file {
  open(F, '>:encoding(utf-8)', "$DataDir/config");
  print F "\$AdminPass = 'foo';\n";
  # this used to be the default in earlier CGI.pm versions
  print F "\$ScriptName = 'http://localhost/wiki.pl';\n";
  print F "\$SurgeProtection = 0;\n";
  close(F);
  $ScriptName = 'http://localhost/test.pl'; # different!
  $IndexInit = 0;
  %IndexHash = ();
  @IndexList = ();
  $InterSiteInit = 0;
  %InterSite = ();
  $NearSiteInit = 0;
  %NearSite = ();
  %NearSearch = ();
}

sub clear_pages {
  if (-f "/bin/rm") {
    system('/bin/rm', '-rf', $DataDir);
  } else {
    system('c:/cygwin/bin/rm.exe', '-rf', $DataDir);
  }
  die "Cannot remove '$DataDir'!\n" if -e $DataDir;
  mkdir $DataDir;
  if ($^O eq 'darwin') {
    # On a Mac we are probably using the HFS filesystem which uses NFD instead
    # of NFC for filenames. Since clear_pages runs as the very first thing, the
    # modules directory doesn't exist, yet. And as Init() hasn't run, $ModuleDir
    # is not set either. All we have is $DataDir.
    $ModuleDir = "$DataDir/modules";
    add_module('mac.pl');
  }
  write_config_file();
}

# Find an unused port
sub random_port {
  use Errno  qw( EADDRINUSE );
  use Socket qw( PF_INET SOCK_STREAM INADDR_ANY sockaddr_in );
  
  my $family = PF_INET;
  my $type   = SOCK_STREAM;
  my $proto  = getprotobyname('tcp')  or die "getprotobyname: $!";
  my $host   = INADDR_ANY;  # Use inet_aton for a specific interface

  for my $i (1..3) {
    my $port   = 1024 + int(rand(65535 - 1024));
    socket(my $sock, $family, $type, $proto) or die "socket: $!";
    my $name = sockaddr_in($port, $host)     or die "sockaddr_in: $!";
    setsockopt($sock, SOL_SOCKET, SO_REUSEADDR, 1);
    bind($sock, $name)
	and close($sock)
	and return $port;
    die "bind: $!" if $! != EADDRINUSE;
    print "Port $port in use, retrying...\n";
  }
  die "Tried 3 random ports and failed.\n"
}

my $pid;

# Fork a simple test server
sub start_server {
  die "A server already exists: $pid\n" if $pid;
  my $port = random_port();
  $ScriptName = "http://localhost:$port";
  AppendStringToFile($ConfigFile, "\$ScriptName = '$ScriptName';\n");
  $pid = fork();
  if (!defined $pid) {
    die "Cannot fork: $!";
  } elsif ($pid == 0) {
    use Config;
    my $secure_perl_path = $Config{perlpath};
    exec($secure_perl_path, "stuff/server.pl", "wiki.pl", $port) or die "Cannot exec: $!";
  }
}

# Fork a Mojolicious server
sub start_mojolicious_server {
  die "A server already exists: $pid\n" if $pid;
  my $port = random_port();
  my $listen = "http://127.0.0.1:$port";
  $ScriptName = "http://127.0.0.1:$port/wiki";
  AppendStringToFile($ConfigFile, "\$ScriptName = '$ScriptName';\n");
  $pid = fork();
  if (!defined $pid) {
    die "Cannot fork: $!";
  } elsif ($pid == 0) {
    use Config;
    my $secure_perl_path = $Config{perlpath};
    exec($secure_perl_path, "server.pl", "daemon", "-l", $listen)
	or die "Cannot exec: $!";
  }
}

END {
  # kill server
  if ($pid) {
    kill 'KILL', $pid or warn "Could not kill server $pid";
  }  
}

sub RunAndTerminate { # runs a command for 1 second and then sends SIGTERM
  my $pid = fork();
  if (not $pid) { # child
    open(STDOUT, '>', '/dev/null'); # we don't want to see the output
    open(STDERR, '>', '/dev/null');
    exec(@_) or die "Cannot start a new process: $!";
  }
  # parent
  sleep 1;
  kill 'TERM', $pid;
  wait; # let it finish
}

sub AppendToConfig {
  my @data = @_; # one or more strings
  open(my $fh, '>>', "$DataDir/config") or die "Could not append to config file: $!";
  print $fh join("\n", @data);
  close $fh;
}

1;

