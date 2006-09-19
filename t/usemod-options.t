require 't/test.pl';
package OddMuse;
use Test::More tests => 7;

clear_pages();

add_module('usemod.pl');

InitVariables();

$UseModSpaceRequired = 0;
$UseModMarkupInTitles = 1;

run_tests(split('\n',<<'EOT'));
*one\n**two
<ul><li>one<ul><li>two</li></ul></li></ul>
#one\n##two
<ol><li>one<ol><li>two</li></ol></li></ol>
:one\n:two\n::one and two\n::two and three\n:three
<dl class="quote"><dt /><dd>one</dd><dt /><dd>two<dl class="quote"><dt /><dd>one and two</dd><dt /><dd>two and three</dd></dl></dd><dt /><dd>three</dd></dl>
;one:eins\n;two:zwei
<dl><dt>one</dt><dd>eins</dd><dt>two</dt><dd>zwei</dd></dl>
=='''title'''==
<h2><strong>title</strong></h2>
1 \+ 1 = 2
1 \+ 1 = 2
EOT

xpath_run_tests(split('\n',<<'EOT'));
==[[Free Link]]==
//h2/text()[string()="[Free Link]"]/following-sibling::a[@class="edit"][@title="Click to edit this page"][@href="http://localhost/test.pl?action=edit;id=Free_Link"][text()="?"]
EOT
