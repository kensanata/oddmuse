# Copyright (C) 2004, 2005, 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

use strict;
use v5.10;

our ($q, $Now, %IndexHash, %Action, %Page, $OpenPageName, $FS, $BannedContent, $RcFile, $RcDefault, @MyAdminCode, $FullUrlPattern, $DeletedPage, $StrangeBannedContent);

AddModuleDescription('despam.pl', 'Despam Extension');

push(@MyAdminCode, \&DespamMenu);

sub DespamMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=spam', T('List spammed pages'), 'spam'));
  push(@$menuref, ScriptLink('action=despam', T('Despamming pages'), 'despam'));
}

my @DespamRules = ();
my @DespamStrangeRules = ();

sub DespamRule {
  $_ = shift;
  s/#.*//;  # trim comments
  s/^\s+//; # trim leading whitespace
  s/\s+$//; # trim trailing whitespace
  return $_;
}

sub InitDespamRules {
  # read them only once
  @DespamRules = grep /./, map { DespamRule($_) }
    split(/\n/, GetPageContent($BannedContent));
  @DespamStrangeRules = grep /./, map { DespamRule($_) }
    split(/\n/, GetPageContent($StrangeBannedContent))
      if $IndexHash{$StrangeBannedContent};
}

$Action{despam} = \&DoDespam;

sub DoDespam {
  RequestLockOrError();
  my $list = GetParam('list', 0);
  print GetHeader('', T('Despamming pages'), '') . '<div class="despam content"><p>';
  InitDespamRules();
  foreach my $id (DespamPages()) {
    next if $id eq $BannedContent or $id eq $StrangeBannedContent;
    OpenPage($id);
    my $rule = $list || DespamBannedContent($Page{text});
    print GetPageLink($id, NormalToFree($id));
    DespamPage($rule) if $rule and not $list;
    print $q->br();
  }
  print '</p></div>';
  PrintFooter();
  ReleaseLock();
}

$Action{spam} = \&DoSpam;

sub DoSpam {
  print GetHeader('', T('Spammed pages'), '') . '<div class="spam content"><p>';
  InitDespamRules();
  foreach my $id (AllPagesList()) {
    next if $id eq $BannedContent or $id eq $StrangeBannedContent;
    OpenPage($id);
    my $rule = DespamBannedContent($Page{text});
    next unless $rule;
    print GetPageLink($id, NormalToFree($id)), ' ', $rule, $q->br();
  }
  print '</p></div>';
  PrintFooter();
}

# Based on BannedContent(), but with caching
sub DespamBannedContent {
  my $str = shift;
  my @urls = $str =~ /$FullUrlPattern/g;
  foreach (@DespamRules) {
    my $regexp = $_;
    foreach my $url (@urls) {
      if ($url =~ /($regexp)/i) {
	return Tss('Rule "%1" matched "%2" on this page.',
		   QuoteHtml($regexp), QuoteHtml($url));
      }
    }
  }
  # depends on strange-spam.pl!
  foreach (@DespamStrangeRules) {
    my $regexp = $_;
    if ($str =~ /($regexp)/i) {
      my $match = $1;
      $match =~ s/\n/ /g;
      return Tss('Rule "%1" matched "%2" on this page.',
		 QuoteHtml($regexp), QuoteHtml($match));
    }
  }
  return 0;
}

sub DespamPages {
  # Assume that regular maintenance is happening and just read rc.log.
  # This is not optimized like DoRc().
  my $starttime = 0;
  $starttime = $Now - GetParam('days', $RcDefault) * 86400; # 24*60*60
  my $data = ReadFileOrDie($RcFile);
  my %files = (); # use a hash map to make it unique
  foreach my $line (split(/\n/, $data)) {
    my ($ts, $id) = split(/$FS/, $line);
    next if $ts < $starttime;
    $files{$id} = 1;
  }
  return keys %files;
}

sub DespamPage {
  my $rule = shift;
  # from DoHistory()
  my @revisions = sort {$b <=> $a} map { m|/([0-9]+).kp$|; $1; } GetKeepFiles($OpenPageName);
  foreach my $revision (@revisions) {
    my ($text, $rev) = GetTextRevision($revision, 1); # quiet
    if (not $rev) {
      print ': ' . Ts('Cannot find revision %s.', $revision);
      return;
    } elsif (not DespamBannedContent($text)) {
      my $summary = Tss('Revert to revision %1: %2', $revision, $rule);
      print ': ' . $summary;
      Save($OpenPageName, $text, $summary) unless GetParam('debug', 0);
      return;
    }
  }
  if (grep(/^1$/, @revisions) or not @revisions) { # if there is no kept revision, yet
    my $summary = Ts($rule). ' ' . Ts('Marked as %s.', $DeletedPage);
    print ': ' . $summary;
    Save($OpenPageName, $DeletedPage, $summary) unless GetParam('debug', 0);
  } else {
    print ': ' . T('Cannot find unspammed revision.');
  }
}
