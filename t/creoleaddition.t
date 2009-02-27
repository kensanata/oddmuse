#!/usr/bin/env perl
# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
# Copyright (C) 2009  Alex Schroeder <alex@gnu.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: creoleaddition.t,v 1.15 2009/02/27 09:56:05 as Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 29;
clear_pages();

add_module('creole.pl');
add_module('creoleaddition.pl');

run_tests(split('\n',<<'EOT'));
x^^2^^
x<sup>2</sup>
H,,2,,O
H<sub>2</sub>O
;dt1\n:dd1\n;dt2\n:dd2
<dl><dt>dt1</dt><dd>dd1</dd><dt>dt2</dt><dd>dd2</dd></dl>
;dt1\n:dd1
<dl><dt>dt1</dt><dd>dd1</dd></dl>
;dt1\n: dd1
<dl><dt>dt1</dt><dd>dd1</dd></dl>
; dt1\n: dd1
<dl><dt>dt1</dt><dd>dd1</dd></dl>
;;dt1\n:dd1
<dl><dt>;dt1</dt><dd>dd1</dd></dl>
;dt1\n:dd1\nmore dd1\n;dt2\n:dd2\n more dd2
<dl><dt>dt1</dt><dd>dd1 more dd1</dd><dt>dt2</dt><dd>dd2 more dd2</dd></dl>
; one:eins\n;two:zwei
; one:eins ;two:zwei
; one:eins
; one:eins
; one:eins\n\n; two:zwei
; one:eins<p>; two:zwei</p>
; dt1 :dd1
; dt1 :dd1
; dt1\n:dd1
<dl><dt>dt1</dt><dd>dd1</dd></dl>
  ;  dt1  \n  :  dd1  \n  ;  dt2 \n  :  dd2
<dl><dt>dt1</dt><dd>dd1</dd><dt>dt2</dt><dd>dd2</dd></dl>
;dt1\n:dd1\n:dd2
<dl><dt>dt1</dt><dd>dd1</dd><dd>dd2</dd></dl>
;dt1 \n :dd1\n:dd2\n : dd3
<dl><dt>dt1</dt><dd>dd1</dd><dd>dd2</dd><dd>dd3</dd></dl>
; **dt1**\n:dd1
<dl><dt><strong>dt1</strong></dt><dd>dd1</dd></dl>
; {{{dt1}}}\n:dd1
<dl><dt><code>dt1</code></dt><dd>dd1</dd></dl>
;[[http://www.toto.com|toto]] \n :Site of my friend Toto
<dl><dt><a class="url http outside" href="http://www.toto.com">toto</a></dt><dd>Site of my friend Toto</dd></dl>
; {{{[[http://www.toto.com|toto]]}}} \n : Site of my friend Toto
<dl><dt><code>[[http://www.toto.com|toto]]</code></dt><dd>Site of my friend Toto</dd></dl>
; what if we have {{{[[http://example.com]]}}} and {{{[[ftp://example.org]]}}}\n: And {{{[[http://example.net]]}}}
<dl><dt>what if we have <code>[[http://example.com]]</code> and <code>[[ftp://example.org]]</code></dt><dd>And <code>[[http://example.net]]</code></dd></dl>
;dt:notdd\n:dd
<dl><dt>dt:notdd</dt><dd>dd</dd></dl>
''my quote'' works ''what about x^^2^^''
<q>my quote</q> works <q>what about x<sup>2</sup></q>
""" not a block quote """
""" not a block quote """
"""\nmy block quote\n"""
<blockquote><p>my block quote </p></blockquote>
##monospace code##
<code>monospace code</code>
EOT

xpath_run_tests(split('\n',<<'EOT'));
##http://example.com##
//code/a[@class="url http"][@href="http://example.com"][text()="http://example.com"]
##[[wiki page]] will work##
//code/a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=wiki_page"][text()="?"][@rel="nofollow"]
EOT

# test for interaction with the usemod indented text rules

add_module('usemod.pl');
xpath_run_tests(split('\n',<<'EOT'));
: is working\n:: not working
//p[@class="indent level1"][@style="margin-left: 2em"][text()="is working "]/following-sibling::p[@class="indent level2"][@style="margin-left: 4em"][text()="not working"]
EOT
exit;
