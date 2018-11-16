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
use utf8;
use Test::More tests => 19;

add_module('markdown-converter.pl');

my $input = qq{
# mu
1 * 2 * 3
*foo*
**bar**
*foo bar*
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
unlike $output, qr'<p>#MARKDOWN</p>', 'No Markdown marker in the HTML';
like $output, qr'#MARKDOWN\n', 'Markdown marker';
like $output, qr'1\. mu', 'list item';
like $output, qr'1 \* 2 \* 3', 'lone asterisk';
like $output, qr'\*\*foo\*\*', 'short strong emphasis';
like $output, qr'\*\*bar\*\*', 'long strong emphasis';
like $output, qr'\*\*foo bar\*\*', 'spaces ok';
like $output, qr'\*baz\*', 'short emphasis';
like $output, qr'\*quux\*', 'long emphasis';
like $output, qr'`oort`', 'code';
like $output, qr'\[example\]\(http://example.com/\)', 'link';
like $output, qr'```\ncode\n```', 'fenced code';

# Errors found and fixed at a later date
$input = qq{
/Toe’s Reach/

{{{
one
}}}

and

{{{
two
}}}
};

update_page('test', $input);

my $output = get_page('action=convert id=test');

like $output, qr'\*Toe’s Reach\*', 'Toe’s Reach';
like $output, qr'^```\none\n```$'m, 'code block one';
like $output, qr'^```\none\n```$'m, 'code block two';

# check whether the candidates are listed correctly

test_page(get_page('action=conversion-candidates'), 'test');

# convert the file so it isn't listed anymore
update_page('test', "#MARKDOWN\nhello\n");

# add an image which cannot be converted
AppendStringToFile($ConfigFile, "\$UploadAllowed = 1;\n");
$page = update_page('pic', "#FILE image/png\niVBORw0KGgoAAAA");
test_page($page, 'This page contains an uploaded file:');

test_page_negative(get_page('action=conversion-candidates'), 'test', 'pic');
