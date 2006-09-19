require 't/test.pl';
package OddMuse;
use Test::More tests => 5;
clear_pages();

add_module('irc.pl');

run_tests(split('\n',<<'EOT'));
<kensanata> foo
<dl class="irc"><dt><b>kensanata</b></dt><dd>foo</dd></dl>
16:45 <kensanata> foo
<dl class="irc"><dt><span class="time">16:45  </span><b>kensanata</b></dt><dd>foo</dd></dl>
[16:45] <kensanata> foo
<dl class="irc"><dt><span class="time">16:45  </span><b>kensanata</b></dt><dd>foo</dd></dl>
16:45am <kensanata> foo
<dl class="irc"><dt><span class="time">16:45am  </span><b>kensanata</b></dt><dd>foo</dd></dl>
[16:45am] <kensanata> foo
<dl class="irc"><dt><span class="time">16:45am  </span><b>kensanata</b></dt><dd>foo</dd></dl>
EOT
