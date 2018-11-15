#!/usr/bin/env perl
# Copyright (C) 2018  Alex Schroeder <alex@gnu.org>
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

require './t/test.pl';
package OddMuse;
use Test::More tests => 8;

add_module('markdown-converter.pl');

my $input = qq{
# mu
*foo*
**bar**
/baz/
//quux//
##oort##
[http://example.com/ example]
{{{
code
}}}
};

update_page('test', $input);

my $output = get_page('action=convert id=test');

like $output, qr'1\. mu', 'list item';
like $output, qr'\*\*foo\*\*', 'short strong emphasis';
like $output, qr'\*\*bar\*\*', 'long strong emphasis';
like $output, qr'\*baz\*', 'short emphasis';
like $output, qr'\*quux\*', 'long emphasis';
like $output, qr'`oort`', 'code';
like $output, qr'\[example\]\(http://example.com/\)', 'link';
like $output, qr'```\ncode\n```', 'fenced code';
