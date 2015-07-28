# Copyright (C) 2015  Alex Jakimenko <alex.jakimenko@gmail.com>
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
use warnings;
use v5.10;
use utf8;

package OddMuse;
require 't/test.pl';
use Test::More tests => 10;

my @modules = <modules/*.pl>;
my @badModules;

@badModules = grep { (stat $_)[2] != oct '100644' } @modules;
unless (ok(@badModules == 0, 'Consistent file permissions of modules')) {
  diag(sprintf "$_ has %o but 100644 was expected", (stat $_)[2]) for @badModules;
  diag("▶▶▶ Use this command to fix it: chmod 644 @badModules");
}

@badModules = grep { ReadFile($_) !~ / ^ use \s+ strict; /xm } @modules;
unless (ok(@badModules == 0, '"use strict;" in modules')) {
  diag(qq{$_ has no "use strict;"}) for @badModules;
}

 SKIP: {
   skip '"use v5.10;" tests, we are not doing "use v5.10;" everywhere yet', 1;
   @badModules = grep { ReadFile($_) !~ / ^ use \s+ v5\.10; /xm } @modules;
   unless (ok(@badModules == 0, '"use v5.10;" in modules')) {
     diag(qq{$_ has no "use v5.10;"}) for @badModules;
     diag(q{Minimum perl version for the core is v5.10, it seems like there is no reason not to have "use v5.10;" everywhere else.});
   }
}

 SKIP: {
   skip '"use utf8;" tests, we are not doing "use utf8;" everywhere yet', 1;
   @badModules = grep { ReadFile($_) !~ / ^ use \s+ utf8; /xm } @modules;
   unless (ok(@badModules == 0, '"use utf8;" in modules')) {
     diag(qq{$_ has no "use utf8;"}) for @badModules;
   }
}

 SKIP: {
   skip 'documentation tests, we did not try to document every module yet', 1;
   @badModules = grep { ReadFile($_) !~ / ^ AddModuleDescription\(' [^\']+ ', /xm } @modules;
   unless (ok(@badModules == 0, 'link to the documentation in modules')) {
     diag(qq{$_ has no link to the documentation}) for @badModules;
   }
}

@badModules = grep { ReadFile($_) =~ / ^ package \s+ OddMuse; /xmi } @modules;
unless (ok(@badModules == 0, 'no "package OddMuse;" in modules')) {
  diag(qq{$_ has "package OddMuse;"}) for @badModules;
  diag(q{When we do "do 'somemodule.pl';" it ends up being in the same namespace of a caller, so there is no need to use "package OddMuse;"});
}

@badModules = grep { ReadFile($_) =~ / ^ use \s+ vars /xm } @modules;
unless (ok(@badModules == 0, 'no "use vars" in modules')) {
  diag(qq{$_ is using "use vars"}) for @badModules;
  diag('▶▶▶ Use "our ($var, ...)" instead of "use vars qw($var ...)"');
  diag(q{▶▶▶ Use this command to do automatic conversion: perl -0pi -e 's/^([\t ]*)use vars qw\s*\(\s*(.*?)\s*\);/$x = $2; $x =~ s{(?<=\w)\b(?!$)}{,}g;"$1our ($x);"/gems' } . "@badModules");
}

@badModules = grep { ReadFile($_) =~ / [ \t]+ $ /xm } @modules;
unless (ok(@badModules == 0, 'no trailing whitespace in modules')) {
  diag(qq{$_ has trailing whitespace}) for @badModules;
  diag(q{▶▶▶ Use this command to do automatic trailing whitespace removal: perl -pi -e 's/[ \t]+$//g' } . "@badModules");
}

@badModules = grep { ReadFile($_) =~ / This (program|file) is free software /x } @modules;
unless (ok(@badModules == 0, 'license is specified in every module')) {
  diag(qq{$_ has no license specified}) for @badModules;
}

# we have to use shell to redirect the output :(
@badModules = grep { system("perl -cT \Q$_\E > /dev/null 2>&1") != 0 } @modules;
unless (ok(@badModules == 0, 'modules are syntatically correct')) {
  diag(qq{$_ has syntax errors}) for @badModules;
}
