# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;

AddModuleDescription('diff.pl', 'Diff Action Extension');

our ($q, %Action, @IndexList, @MyRules, $TempDir);
push(@MyRules, \&DiffActionRule);
$Action{pagediff} = \&DoDiffAction;

sub DiffActionRule {
  return PrintDiffActionChooser($3) if (m/\G(&lt;diff( (.*))&gt;)/cgi);
  return; # the rule didn't match
}

sub DoDiffAction {
  print GetHeader('', T('Page diff'), '');
  my $page1 = GetParam('page1');
  my $page2 = GetParam('page2');
  my $pattern = GetParam('pattern');
  $pattern ||= '.*';
  print PrintDiffActionChooser($pattern);
  ValidIdOrDie($page1);
  ValidIdOrDie($page2);
  my $diff = DoUnifiedDiff("1\n \n" . GetPageContent($page1), "2\n \n" . GetPageContent($page2)); # add extra lines, otherwise diff between identical files will print nothing # TODO fix this, otherwise one day this will fail...
  $diff = QuoteHtml($diff);
  $diff =~ tr/\r//d; # TODO is this required? # probably not
  for (split /\n/, $diff) {
    s/(^.)//;
    my $type = $1;
    if ($type eq '+') {
      print '<span class="diffactionnew">' . $type;
    } elsif ($type eq '-') {
      print '<span class="diffactionold">' . $type;
    }
    ApplyRules($_);
    print '</span>' if $type =~ /[+-]/;
    print '<br/>';
  }
  PrintFooter();
}

sub PrintDiffActionChooser {
  my $pattern = shift;
  $pattern ||= '.*';
  my @chosenPages = ();
  for (@IndexList) {
    push @chosenPages, $_ if m/$pattern/;
  }
  return  GetFormStart(undef, 'get', 'pagediff')
      . GetHiddenValue('action', 'pagediff')
      . GetHiddenValue('pattern', $pattern)
      . $q->popup_menu(-name=>'page1', -values=>\@chosenPages) . ' '
      . $q->popup_menu(-name=>'page2', -values=>\@chosenPages) . ' '
      . $q->submit(-name=>'', -value=>T('Diff'))
      . $q->end_form();
}

sub DoUnifiedDiff { # copied from DoDiff
  CreateDir($TempDir);
  my $oldName = "$TempDir/old";
  my $newName = "$TempDir/new";
  RequestLockDir('diff') or return '';
  WriteStringToFile($oldName, $_[0]);
  WriteStringToFile($newName, $_[1]);
  my $diff_out = `diff -U 99999 -- \Q$oldName\E \Q$newName\E | tail -n +7`; # should be +4, but we always add extra line # TODO that workaround is ugly, fix it!
  utf8::decode($diff_out); # needs decoding
  $diff_out =~ s/\n\K\\ No newline.*\n//g; # Get rid of common complaint.
  ReleaseLockDir('diff');
  # No need to unlink temp files--next diff will just overwrite.
  return $diff_out;
}
