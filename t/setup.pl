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

# This "test" does nothing but delete any extra test-data directories.

use Test::More;
use File::Path qw(remove_tree);

opendir(my $dh, '.') || die "can't opendir the working directory: $!";
@test_dirs = grep { /^test-data/ && -d $_ } readdir($dh);
closedir $dh;

remove_tree(@test_dirs, {error => \my $err});
ok(@$err == 0, "No errors deleting test-data directories");
done_testing();
