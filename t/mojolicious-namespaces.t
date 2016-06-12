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

require 't/test.pl';

add_module('namespaces.pl');

start_mojolicious_server();
sleep(1);

my $t = Test::Mojo->new;

# Installation worked
$t->get_ok("$ScriptName?action=version")
  ->content_like(qr/namespaces\.pl/);

# Edit a page in the Main namespace
$t->post_ok("$ScriptName"
	    => form => {title => 'Some_Page',
			text => 'This is the Main namespace.'})
  ->status_is(302);
$t->get_ok("$ScriptName/Some_Page")
  ->status_is(200)
  ->content_like(qr/This is the Main namespace/);

# Edit a page in the Five Winds namespace
$t->post_ok("$ScriptName/FiveWinds"
	    => form => {title => 'Some_Page',
			text => 'This is the Five Winds namespace.'})
  ->status_is(302);
$t->get_ok("$ScriptName/FiveWinds/Some_Page")
  ->status_is(200)
  ->content_like(qr/This is the Five Winds namespace/);

# This didn't overwrite the Main namespace.
$t->get_ok("$ScriptName/Some_Page")
  ->content_like(qr/This is the Main namespace/);

TODO: {
  local $TODO = "Some bug in namespaces.pl remains";
  diag "Waiting for the lock dir in RefreshIndex...";
  
  # Umlauts
  $t->post_ok("$ScriptName/F%C3%BCnfWinde"
	      => form => {title => 'Some_Page',
			  text => 'Wir sind im Namensraum Fünf Winde.'})
      ->status_is(302);
  $t->get_ok("$ScriptName/F%C3%BCnfWinde/Some_Page")
      ->status_is(200)
      ->content_like(qr/Wir sind im Namensraum Fünf Winde/);
}

done_testing();
