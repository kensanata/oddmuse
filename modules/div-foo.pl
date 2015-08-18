# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
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
use v5.10;

AddModuleDescription('div-foo.pl', 'Div Foo Extension');

our (@MyRules);
our ($DivFooPrefix);
our (%RuleOrder);

$DivFooPrefix = 'foo_';

push(@MyRules, \&DivFooRule);

# conflicts with <nowiki> and other such rules by usemod.pl
$RuleOrder{\&DivFooRule} = 200;

sub DivFooRule {
  if (m/\G \&lt; ([a-z_-][a-z0-9 _-]+[a-z0-9_-]) \&gt; \s*\n /cgx) {
    return CloseHtmlEnvironment('p') . AddHtmlEnvironment('div', 'class="' . join(' ', map {"$DivFooPrefix$_"} split /\s+/, $1) . '"');
  }
  if (m/\G \&lt; ([a-z_-][a-z0-9 _-]+[a-z0-9_-]) (\?(.*?(?=\&gt;)))? \&gt; /cgx) {
    my $title = $3 ? ' title="' . QuoteHtml($3) . '"' : '';
    return AddHtmlEnvironment('span', 'class="' . join(' ', map {"$DivFooPrefix$_"} split /\s+/, $1) . '"' . $title);
  }
  if (m/\G \&lt; \/ \/ \&gt; /cgx) {
    return CloseHtmlEnvironment('div') . (InElement('div') ? '' : AddHtmlEnvironment('p'));
  }
  if (m/\G \&lt; \/ \&gt; /cgx) {
    return CloseHtmlEnvironment('span');
  }
  return;
}
