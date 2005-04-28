# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2005  Ingo Belka <grimmen@mvnet.de>
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

use vars qw($HeadlineNumber);

$ModulesDescription .= '<p>$Id: headlines.pl,v 1.8 2005/04/28 23:58:17 as Exp $</p>';

push(@MyRules, \&HeadlinesRule);

# Include this page on every page:

$HeadlineNumber = 20;

sub HeadlinesRule {
  if (m/\G(\&lt;headlines(:(\d+))?\&gt;)/gci) {
    if (($3) and ($3>0)) {$HeadlineNumber = $3;};
    Clean(CloseHtmlEnvironments());
    Dirty($1);
    HeadlinesPrint();
    return AddHtmlEnvironment('p');
  }
  return undef;
}

sub HeadlinesPrint {
  my @pages = (grep(/^\d\d\d\d-\d\d-\d\d_.+/, AllPagesList()));
  @pages = sort {$b cmp $a} @pages;
  @pages = @pages[0 .. $HeadlineNumber - 1] if $#pages >= $HeadlineNumber;
  my $current_date;
  if (@pages) {
    print '<dl class="headlines">';
    foreach my $page (@pages) {
      if ($page =~ /^(\d\d\d\d-\d\d-\d\d)_(.+)/) {
	my ($date, $title) = ($1, $2);
	$title =~ s/_/ /g;
	print '<dt class="headlinesdate">' . $date . '</dt>' unless $date eq $current_date;
	$current_date = $date;
	print '<dd>' . ScriptLink($page, $title, 'headlineslink') . '</dd>';
      }
    }
    print '</dl>';
  }
}
