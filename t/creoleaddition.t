#!/usr/bin/env perl
# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html

# $Id: creoleaddition.t,v 1.11 2008/11/15 12:48:13 leycec Exp $

require 't/test.pl';
package OddMuse;
use Test::More tests => 22;
clear_pages();

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
