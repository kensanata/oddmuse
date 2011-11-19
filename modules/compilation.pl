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

$ModulesDescription .= '<p>$Id: compilation.pl,v 1.4 2011/11/19 15:27:00 as Exp $</p>';

$Action{compilation} = \&DoCompilation;

sub DoCompilation {
  my $match = GetParam('match', '') or ReportError(T('The match parameter is missing.'));
  print GetHeader('', Ts('Compilation for %s', $match), '');
  my @pages = PrintCompilation(undef, $match, GetParam('reverse', 0));
  print $q->p(Ts('%s pages found.', ($#pages + 1)));
  PrintFooter();
}

# like PrintJournal
sub PrintCompilation {
  return if $CollectingJournal; # avoid infinite loops
  local $CollectingJournal = 1;
  my ($num, $regexp, $mode) = @_;
  return $q->p($q->strong(T('Compilation tag is missing a regular expression.'))) unless $regexp;
  my @pages = SearchTitleAndBody($regexp);
  if (defined &CompilationSort) {
    @pages = sort CompilationSort @pages;
  } else {
    @pages = sort @pages;
  }
  if ($mode eq 'reverse') {
    @pages = reverse @pages;
  }
  @pages = @pages[0 .. $num - 1] if $num and $#pages >= $num;
  if (@pages) {
    # Now save information required for saving the cache of the current page.
    local %Page;
    local $OpenPageName='';
    print '<div class="compilation">';
    PrintAllPages(1, 1, undef, @pages);
    print '</div>';
  }
  return @pages;
}

push(@MyRules, \&CompilationRule);

sub CompilationRule {
  if ($bol && m/\G(\&lt;compilation(\s+(\d*))?(\s+"(.*)")(\s+(reverse))?\&gt;[ \t]*\n?)/cgi) {
    # <journal 10 "regexp"> includes 10 pages matching regexp
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    my $oldpos = pos;
    PrintCompilation($3, $5, $7);
    pos = $oldpos;		# restore \G after call to ApplyRules
    return AddHtmlEnvironment('p');
  }
  return undef;
}
