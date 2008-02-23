# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: fieldlist.t,v 1.1 2008/02/23 17:12:12 weakish Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 9;
clear_pages();

add_module('fieldlist.pl');

run_tests(split('\n',<<'EOT'));
:foo:bar
<dl class="fieldlist"><dt>foo</dt><dd>bar</dd></dl>
 :foo: bar
<dl class="fieldlist"><dt>foo</dt><dd>bar</dd></dl>
: foo : bar
: foo : bar
:author: weakish\n :sex:unknow
<dl class="fieldlist"><dt>author</dt><dd>weakish</dd><dt>sex</dt><dd>unknow</dd></dl>
:author:weakish\n:sex:unknow
<dl class="fieldlist"><dt>author</dt><dd>weakish</dd><dt>sex</dt><dd>unknow</dd></dl>
:main author: foo bar\n    :s:  Alex Joe
<dl class="fieldlist"><dt>main author</dt><dd>foo bar</dd><dt>s</dt><dd>Alex Joe</dd></dl>
:foo :bar
:foo :bar
:foo: bar:
<dl class="fieldlist"><dt>foo</dt><dd>bar:</dd></dl>
:foo:bar:
<dl class="fieldlist"><dt>foo</dt><dd>bar:</dd></dl>
EOT

