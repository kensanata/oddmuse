# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: despam.pl,v 1.2 2004/10/28 01:31:05 as Exp $</p>';

$Action{despam} = \&DoDespam;

my @DespamRules = ();

sub DoDespam {
  RequestLockOrError();
  my @pages = DespamPages();
  print GetHeader('', T('Despamming pages'), '') . '<div class="content"><p>';
  foreach my $id (@pages) {
    next if $id eq $BannedContent;
    OpenPage($id);
    my $title = $id;
    $title =~ s/_/ /g;
    my $rule = DespamBannedContent($Page{text});
    print GetPageLink($id, $title);
    DespamPage($rule) if $rule;
    print $q->br();
  }
  print '</p></div>';
  PrintFooter();
  ReleaseLock();
}

# Based on BannedContent(), but with caching
sub DespamBannedContent {
  my $str = shift;
  @DespamRules = split(/\n/, GetPageContent($BannedContent));
  foreach (@DespamRules) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $rule = $1;
      if ($str =~ /($rule)/i) {
	my $match = $1;
	return Tss('Rule "%1" matched "%2" on this page.', $rule, $match);
      }
    }
  }
  return 0;
}

sub DespamPages {
  return AllPagesList(); # only check recently changed pages?
}

sub DespamPage {
  my $rule = shift;
  # from DoHistory()
  my @revisions = sort {$b <=> $a} map { m|/([0-9]+).kp$|; $1; } GetKeepFiles($OpenPageName);
  foreach my $revision (@revisions) { # remember the last revision checked
    my ($text, $rev) = GetTextRevision($revision, 1); # quiet
    if (not $rev) {
      print ': ' . Ts('Cannot find revision %s.', $revision);
      return;
    } elsif (not DespamBannedContent($text)) {
      my $summary = Tss('Revert to revision %1: %2', $revision, $rule);
      print ': ' . $summary;
      Save($OpenPageName, $text, $summary);
      return;
    }
  }
  if (grep(/^1$/, @revisions) or not @revisions) { # if there is no kept revision, yet
    my $summary = Ts($rule). ' ' . Ts('Marked as %s.', $DeletedPage);
    print ': ' . $summary;
    Save($OpenPageName, $DeletedPage, $summary);
  } else {
    print ': ' . T('Cannot find unspammed revision.'. $revision);
  }
}
