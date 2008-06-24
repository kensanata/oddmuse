# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: emailquote.t,v 1.1 2008/06/24 15:30:15 weakish Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 3;
clear_pages();

add_module('emailquote.pl');

run_tests(split('\n',<<'EOT'));
> This is a quote\n> \n> > Nesting is OK.\n> \n> Quote ends.
<dl class="quote"><dt></dt><dd>This is a quote</dd><dt></dt><dd><dl class="quote"><dt></dt><dd>Nesting is OK.</dd></dl></dd><dt></dt><dd></dd><dt></dt><dd>Quote ends.</dd></dl>
> This is a quote.
<dl class="quote"><dt></dt><dd>This is a quote.</dd></dl>
>This is not a quote.
&gt;This is not a quote.
EOT

