# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: creoleadditon.t,v 1.1 2008/02/22 11:00:38 weakish Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 1;
clear_pages();

add_module('creoleaddition.pl');

run_tests(split('\n',<<'EOT'));
x^^2^^ and H,,2,,O
x<sup>2</sup> and H<sub>2</sub>O
EOT

