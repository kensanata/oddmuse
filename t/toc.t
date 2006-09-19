require 't/test.pl';
package OddMuse;
use Test::More tests => 22;

clear_pages();

add_module('toc.pl');
add_module('usemod.pl');

InitVariables(); # do this after loading usemod.pl!

run_tests(split('\n',<<'EOT'));
== make honey ==\n\nMoo.\n
<h2 id="toc1">make honey</h2><p>Moo.</p>
EOT

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
