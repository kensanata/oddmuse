# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: htmlcomment.t,v 1.1 2008/02/22 09:24:27 weakish Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 6;
clear_pages();

add_module('htmlcomment.pl');

run_tests(split('\n',<<'EOT'));
/*\nThis is a comment\n*/
<!--This is a comment\n-->
/*\nA comment can have\nMulti-lines\n\nas this one\n*/
<!--A comment can have\nMulti-lines\n\nas this one\n-->
/*This is not a comment */
/*This is not a comment */
/*\nThis is not a comment either,\n*/ cause */ is not on a line by itself.
/* This is not a comment either, */ cause */ is not on a line by itself.
/*\nThis is a comment\n */ This is the second line\nComment ends here.\n*/
<!--This is a comment\n*/ This is the second line\nComment ends here.\n-->
/*\nSome special characters like < and > will be encoded.\n*/
<!--Some special characters like &lt; and &gt; will be encoded.\n-->
EOT

