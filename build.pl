# Copyright (C) 2015  Alex Schroeder <alex@gnu.org>
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

# This script processes wiki.pl, replacing the link to www.oddmuse.org with a
# link to the current version. It also changes the default of the random
# Challenge Token so that everybody gets a different one.

use Crypt::Random qw( makerandom );

my ($old_file, $new_file, $version) = @ARGV;

undef $/;
open(my $in, '<:utf8', $old_file) or die "Cannot read $old_file: $!";
$_ = <$in>;
close($in);

s!(\$q->a\({-href=>'http://www.oddmuse.org/'}, 'Oddmuse'\))!\$q->a\({-href=>'http://git.savannah.gnu.org/cgit/oddmuse.git/tag/?id=$version'}, 'wiki.pl'\) . ' ($version), see ' . $1!;

my $r = join('', map { sprintf('\x%x', makerandom( Size => 8, Uniform => 1, Strength => 1 )) } 1..16);

s!our \$TokenKey //= '(.*?)'!our \$TokenKey //= '$r'!;

open(my $out, '>:utf8', $new_file) or die "Cannot write $new_file: $!";
print $out $_;
close($out);
