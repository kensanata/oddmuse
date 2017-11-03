# Copyright (C) 2016  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package OddMuse;
use Test::More;
use Test::Mojo;

require './t/test.pl';

start_mojolicious_server();
sleep(1);

my $t = Test::Mojo->new;

$t->get_ok("$ScriptName")->status_is(404)->content_like(qr/Welcome!/);
$t->get_ok("$ScriptName?action=admin")->status_is(200);

$t->post_ok("$ScriptName"
	    => form => {title => 'HomePage', text => 'This is a test.'})
  ->status_is(302);
$t->get_ok("$ScriptName")->status_is(200)->content_like(qr/This is a test/);

done_testing();
