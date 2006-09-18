require 't/test.pl';
package OddMuse;

clear_pages();

update_page('InterMap', " OddMuse http://www.emacswiki.org/cgi-bin/oddmuse.pl?\n PlanetMath http://planetmath.org/encyclopedia/%s.html", 'required', 0, 1);
$InterInit = 0;
InitVariables();

# non links

$NetworkFile = 1;

run_tests(split('\n',<<'EOT'));
do not eat 0 from text
do not eat 0 from text
ordinary text
ordinary text
paragraph\n\nparagraph
paragraph<p>paragraph</p>
* one\n*two
<ul><li>one *two</li></ul>
* one\n\n*two
<ul><li>one</li></ul><p>*two</p>
* one\n** two
<ul><li>one<ul><li>two</li></ul></li></ul>
* one\n** two\n*** three\n* four
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four</li></ul>
* one\n** two\n*** three\n* four\n** five\n* six
<ul><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li><li>four<ul><li>five</li></ul></li><li>six</li></ul>
* one\n* two\n** one and two\n** two and three\n* three
<ul><li>one</li><li>two<ul><li>one and two</li><li>two and three</li></ul></li><li>three</li></ul>
* one and *\n* two and * more
<ul><li>one and *</li><li>two and * more</li></ul>
Foo::Bar
Foo::Bar
!WikiLink
WikiLink
!foo
!foo
file:///home/foo/tutorial.pdf
file:///home/foo/tutorial.pdf
named entities: &gt;
named entities: &gt;
garbage: &
garbage: &amp;
numbered entity: &#123;
numbered entity: &#123;
numbered hex entity: &#x123;
numbered hex entity: &#x123;
named entity: &copy;
named entity: &copy;
quoted named entity: &amp;copy;
quoted named entity: &amp;copy;
EOT

test_page(update_page('entity', 'quoted named entity: &amp;copy;'),
	  'quoted named entity: &amp;copy;');

# links and other attributes containing attributes

%Smilies = ('HAHA!' => '/pics/haha.png',
	    '&lt;3' => '/pics/heart.png',
	    ':"\(' => '/pics/cat.png');

%Test = split('\n',<<'EOT');
HAHA!
//img[@class="smiley"][@src="/pics/haha.png"][@alt="HAHA!"]
i <3 you
//img[@class="smiley"][@src="/pics/heart.png"][@alt="<3"]
:"(
//img[@class="smiley"][@src="/pics/cat.png"][@alt=':"(']
WikiWord
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=WikiWord"][text()="?"]
WikiWord:
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=WikiWord"][text()="?"]/following-sibling::text()[string()=":"]
OddMuse
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OddMuse"][text()="?"]
OddMuse:
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=OddMuse"][text()="?"]/following-sibling::text()[string()=":"]
OddMuse:test
//a[@class="inter OddMuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"]/span[@class="site"][text()="OddMuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="test"]
OddMuse:test: or not
//a[@class="inter OddMuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"]/span[@class="site"][text()="OddMuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="test"]
OddMuse:test, and foo
//a[@class="inter OddMuse"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"]/span[@class="site"][text()="OddMuse"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="test"]
PlanetMath:ZipfsLaw, and foo
//a[@class="inter PlanetMath"][@href="http://planetmath.org/encyclopedia/ZipfsLaw.html"]/span[@class="site"][text()="PlanetMath"]/following-sibling::text()[string()=":"]/following-sibling::span[@class="page"][text()="ZipfsLaw"]
[OddMuse:test]
//a[@class="inter OddMuse number"][@href="http://www.emacswiki.org/cgi-bin/oddmuse.pl?test"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
![[Free Link]]
//a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=Free_Link"][text()="?"]
http://www.emacswiki.org
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]
<http://www.emacswiki.org>
//text()[string()="<"]/following-sibling::a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()=">"]
http://www.emacswiki.org/
//a[@class="url http"][@href="http://www.emacswiki.org/"][text()="http://www.emacswiki.org/"]
http://www.emacswiki.org.
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="."]
http://www.emacswiki.org,
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()=","]
http://www.emacswiki.org;
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()=";"]
http://www.emacswiki.org:
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()=":"]
http://www.emacswiki.org?
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="?"]
http://www.emacswiki.org/?
//a[@class="url http"][@href="http://www.emacswiki.org/"][text()="http://www.emacswiki.org/"]/following-sibling::text()[string()="?"]
http://www.emacswiki.org!
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="!"]
http://www.emacswiki.org'
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="'"]
http://www.emacswiki.org"
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()='"']
http://www.emacswiki.org!
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="!"]
http://www.emacswiki.org(
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="("]
http://www.emacswiki.org)
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()=")"]
http://www.emacswiki.org&
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="&"]
http://www.emacswiki.org#
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="#"]
http://www.emacswiki.org%
//a[@class="url http"][@href="http://www.emacswiki.org"][text()="http://www.emacswiki.org"]/following-sibling::text()[string()="%"]
[http://www.emacswiki.org]
//a[@class="url http number"][@href="http://www.emacswiki.org"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
[http://www.emacswiki.org] and [http://www.emacswiki.org]
//a[@class="url http number"][@href="http://www.emacswiki.org"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]/../../following-sibling::text()[string()=" and "]/following-sibling::a[@class="url http number"][@href="http://www.emacswiki.org"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="2"]/following-sibling::span[@class="bracket"][text()="]"]
[http://www.emacswiki.org],
//a[@class="url http number"][@href="http://www.emacswiki.org"]/span/span[@class="bracket"][text()="["]/following-sibling::text()[string()="1"]/following-sibling::span[@class="bracket"][text()="]"]
[http://www.emacswiki.org and a label]
//a[@class="url http outside"][@href="http://www.emacswiki.org"][text()="and a label"]
[file://home/foo/tutorial.pdf local link]
//a[@class="url file outside"][@href="file://home/foo/tutorial.pdf"][text()="local link"]
file://home/foo/tutorial.pdf
//a[@class="url file"][@href="file://home/foo/tutorial.pdf"][text()="file://home/foo/tutorial.pdf"]
mailto:alex@emacswiki.org
//a[@class="url mailto"][@href="mailto:alex@emacswiki.org"][text()="mailto:alex@emacswiki.org"]
EOT

xpath_run_tests();

$NetworkFile = 0;
