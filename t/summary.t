# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 11;

update_page('link', 'some [http://example.com content]');
update_page('long', q{This program is >>free<< software;
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

# second edit doesn't automatically set a summary
update_page('link', 'fnord');
test_page_negative(get_page('action=rc raw=1'),
	  "description: some content",
	  "description: fnord");
# explicit setting of the summary works
update_page('link', 'bonk', 'bunk');
test_page(get_page('action=rc raw=1'),
	  "description: bunk");
# remove links from default summary when crossing $SummaryDefaultLength
update_page('size', 'lirum larum fiderallala lirum larum fiderallala lirum larum fiderallala lirum larum fiderallala lirum larum fiderallala lirum [http://example.com content]');
test_page_negative(get_page('action=rc raw=1'),
	  'content');
update_page('link', 'fnord', '[[bunk]]');
test_page(get_page('action=rc raw=1'),
	  "description: bunk");
