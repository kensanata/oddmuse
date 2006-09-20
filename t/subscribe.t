# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 4;
clear_pages();

add_module('subscriberc.pl');

run_tests(split('\n',<<'EOT'));
My subscribed pages: AlexSchroeder.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder)$">My subscribed pages: AlexSchroeder</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]].
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar</a>.
My subscribed categories: CategoryDecisionMaking, CategoryBar.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=(CategoryDecisionMaking|CategoryBar)">My subscribed categories: CategoryDecisionMaking, CategoryBar</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]], categories: CategoryDecisionMaking.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$|(CategoryDecisionMaking)">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar, categories: CategoryDecisionMaking</a>.
EOT
