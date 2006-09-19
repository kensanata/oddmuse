#!/usr/bin/perl

# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

package OddMuse;
use lib '.';
use XML::LibXML;
use Encode;

# Import the functions

$RunCGI = 0;    # don't print HTML on stdout
$UseConfig = 0; # don't read module files
require 'wiki.pl';
Init();

my $resultfile = "/tmp/test-markup-result-$$";
my $redirect;
undef $/;
$| = 1; # no output buffering

sub url_encode {
  my $str = shift;
  return '' unless $str;
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

sub update_page {
  my ($id, $text, $summary, $minor, $admin, @rest) = @_;
  my $pwd = $admin ? 'foo' : 'wrong';
  $id = url_encode($id);
  $text = url_encode($text);
  $summary = url_encode($summary);
  $minor = $minor ? 'on' : 'off';
  my $rest = join(' ', @rest);
  $redirect = `perl wiki.pl Save=1 title=$id summary=$summary recent_edit=$minor text=$text pwd=$pwd $rest`;
  $output = `perl wiki.pl action=browse id=$id`;
  # just in case a new page got created or NearMap or InterMap
  $IndexInit = 0;
  $NearInit = 0;
  $InterInit = 0;
  $RssInterwikiTranslateInit = 0;
  InitVariables();
  return $output;
}

sub get_page {
  open(F,"perl wiki.pl @_ |");
  my $output = <F>;
  close F;
  return $output;
}

sub test_page {
  my $page = shift;
  foreach my $str (@_) {
    like($page, qr($str), name($str));
  }
}

sub test_page_negative {
  my $page = shift;
  foreach my $str (@_) {
    unlike($page, qr($str), name($str));
  }
}

sub get_text_via_xpath {
  my ($page, $test) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc;
  eval { $doc = $parser->parse_html_string($page) };
  if ($@) {
    print "Could not parse html: $@\n", $page, "\n\n";
    $failed += 1;
  } else {
    print '.';
    my $nodelist;
    eval { $nodelist = $doc->findnodes($test) };
    if ($@) {
      $failed++;
      print "\nXPATH Test: failed to run $test: $@\n";
    } elsif ($nodelist->size()) {
      $passed++;
      return $nodelist->string_value();
    } else {
      $failed++;
      print "\nXPATH Test: No matches for $test\n";
      $page =~ s/^.*?<body/<body/s;
      print substr($page,0,30000), "\n";
    }
  }
}


sub xpath_test {
  my ($page, @tests) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc;
 SKIP: {
    eval { $doc = $parser->parse_html_string($page) };
    skip("Cannot parse ".name($page).": $@", $#tests + 1) if $@;
    foreach my $test (@tests) {
      my $nodelist;
      eval { $nodelist = $doc->findnodes($test) };
      if ($@) {
	fail("$test: $@");
      } else {
	if (not ok($nodelist->size(), name($test))) {
	  $page =~ s/^.*?<body/<body/s; # strip
	    diag("No Matches\n", substr($page,0,30000));
	}
      }
    }
  }
}

sub negative_xpath_test {
  my ($page, @tests) = @_;
  $page =~ s/^.*?<html>/<html>/s; # strip headers
  my $parser = XML::LibXML->new();
  my $doc = $parser->parse_html_string($page);
  foreach my $test (@tests) {
    print '.';
    my $nodelist = $doc->findnodes($test);
    if (not $nodelist->size()) {
      $passed++;
    } else {
      $failed++;
      $printpage = 1;
      print "\nXPATH Test: Unexpected matches for $test\n";
    }
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


sub xpath_run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = map { s/\\n/\n/g; $_; } @_;
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    xpath_test("<div>$result</div>", $output);
  }
}

sub test_match {
  my ($input, @tests) = @_;
  my $output = apply_rules($input);
  foreach my $str (@tests) {
    print '.';
    if ($output =~ /$str/) {
      $passed++;
    } else {
      $failed++;
      $printpage = 1;
      print "\n\n---- input:\n", $input,
	    "\n---- output:\n", $output,
            "\n---- instead of:\n", $str, "\n----\n";
    }
  }
}

sub name {
  $_ = shift;
  s/\n/\\n/g;
  $_ = substr($_, 0, 60) . '...' if length > 63;
  return $_;
}

sub run_tests {
  # translate embedded newlines (other backslashes remain untouched)
  my @tests = map { s/\\n/\n/g; $_; } @_;
  my ($input, $output);
  while (($input, $output, @tests) = @tests) {
    my $result = apply_rules($input);
    is($result, $output, name($input));
  }
}

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
  my $mod = shift;
  mkdir $ModuleDir unless -d $ModuleDir;
  my $dir = `/bin/pwd`;
  chop($dir);
  symlink("$dir/modules/$mod", "$ModuleDir/$mod") or die "Cannot symlink $mod: $!"
    unless -l "$ModuleDir/$mod";
  do "$ModuleDir/$mod";
  @MyRules = sort {$RuleOrder{$a} <=> $RuleOrder{$b}} @MyRules;
}

sub remove_module {
  my $mod = shift;
  mkdir $ModuleDir unless -d $ModuleDir;
  unlink("$ModuleDir/$mod") or die "Cannot unlink: $!";
}

sub clear_pages {
  system('/bin/rm -rf /tmp/oddmuse');
  die "Cannot remove /tmp/oddmuse!\n" if -e '/tmp/oddmuse';
  mkdir '/tmp/oddmuse';
  open(F,'>/tmp/oddmuse/config');
  print F "\$AdminPass = 'foo';\n";
  # this used to be the default in earlier CGI.pm versions
  print F "\$ScriptName = 'http://localhost/wiki.pl';\n";
  print F "\$SurgeProtection = 0;\n";
  close(F);
  $ScriptName = 'http://localhost/test.pl'; # different!
  $IndexInit = 0;
  %IndexHash = ();
  $InterSiteInit = 0;
  %InterSite = ();
  $NearSiteInit = 0;
  %NearSite = ();
  %NearSearch = ();
}

1;
