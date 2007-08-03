# Copyright (C) 2006, 2007  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;
use Test::More tests => 27;

clear_pages();

add_module('toc.pl');
add_module('usemod.pl');

InitVariables(); # do this after loading usemod.pl!

# Note that we're not calling TocInit between tests, so we rely on
# them being run in order.
run_tests(split('\n',<<'EOT'));
== make honey ==\n\nMoo.\n
<h2 id="toc1">make honey</h2><p>Moo.</p>
== make honey ==\nMoo.\n== make honey ==\nMoo.\n
<h2 id="toc2">make honey</h2><p>Moo. </p><h2 id="toc3">make honey</h2><p>Moo.</p>
EOT

test_page(update_page('toc', "bla\n"
		      . "<toc/fnord/mu>\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<div class="toc fnord mu">'));

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "==two==\n"
		      . "bla\n"
		      . "==two==\n"
		      . "mu."),
	  quotemeta('<ol><li><a href="#toc1">one</a><ol><li><a href="#toc2">two</a></li><li><a href="#toc3">two</a></li></ol></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">two</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('two</a></li></ol></li></ol></div><h2 id="toc1">one</h2>'),);

test_page(update_page('toc', "bla\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "==two==\n"),
	  quotemeta('<ol><li><a href="#toc1">two</a><ol><li><a href="#toc2">three</a></li></ol></li><li><a href="#toc3">two</a></li></ol>'),
	  quotemeta('<h2 id="toc1">two</h2>'),
	  quotemeta('<h3 id="toc2">three</h3>'));

test_page(update_page('toc', "bla\n"
		      . "<toc>\n"
		      . "murks\n"
		      . "==two=\n"
		      . "bla\n"
		      . "===three==\n"
		      . "bla\n"
		      . "=one=\n"),
	  quotemeta('<ol><li><a href="#toc1">two</a><ol><li><a href="#toc2">three</a></li></ol></li><li><a href="#toc3">one</a></li></ol>'),
	  quotemeta('<h2 id="toc1">two</h2>'),
	  quotemeta('<h2 id="toc3">one</h2>'),
	  quotemeta('bla </p><div class="toc"><h2>Contents</h2><ol><li><a '),
	  quotemeta('one</a></li></ol></div><p> murks'),);

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "==two==\n"
		      . "<nowiki>bla\n"
		      . "==two==\n"
		      . "mu.</nowiki>\n"
		      . "<nowiki>bla\n"
		      . "==two==\n"
		      . "mu.</nowiki>\n"
		      . "yadda <code>bla\n"
		      . "==two==\n"
		      . "mu.</code>\n"
		      . "yadda <pre> has no effect! \n"
		      . "##bla\n"
		      . "==three==\n"
		      . "mu.##\n"
		      . "=one=\n"
		      . "blarg </pre>\n"),
	  quotemeta('<ol><li><a href="#toc1">one</a><ol><li><a href="#toc2">two</a></li><li><a href="#toc3">three</a></li></ol></li><li><a href="#toc4">one</a></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">two</h2>'),
	  quotemeta('<h2 id="toc3">three</h2>'),
	  quotemeta('<h2 id="toc4">one</h2>'),);

add_module('markup.pl');

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg\n"
		      . "<code>bla\n"
		      . "=two=\n"
		      . "mu.</code>\n"
		      . "##bla\n"
		      . "=three=\n"
		      . "mu.##\n"
		      . "=four=\n"
		      . "blarg\n"),
	  quotemeta('<ol><li><a href="#toc1">one</a></li><li><a href="#toc2">four</a></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">four</h2>'),);

test_page(update_page('toc', "bla\n"
		      . "=one=\n"
		      . "blarg ##<code>## and <code>##</code>\n"
		      . "=two=\n"
		      . "blarg ##</code>##\n"),
	  quotemeta('<ol><li><a href="#toc1">one</a></li><li><a href="#toc2">two</a></li></ol>'),
	  quotemeta('<h2 id="toc1">one</h2>'),
	  quotemeta('<h2 id="toc2">two</h2>'),);
