use CGI;
use Getopt::Std;

use vars qw($FS $FreeLinkPattern $UrlProtocols $UrlChars $EndChars
$UrlPattern $q);

$FS = "\x1e";
$FreeLinkPattern = "([-,.()' _0-9A-Za-z\x80-\xff]+)";
$UrlProtocols = 'http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|prospero|telnet|gopher|irc';
$UrlChars = '[-a-zA-Z0-9/@=+$_~*.,;:?!\'"()&#%]'; # see RFC 2396
$EndChars = '[-a-zA-Z0-9/@=+$_~*]'; # no punctuation at the end of the url.
$UrlPattern = "((?:$UrlProtocols):$UrlChars+$EndChars)";
$q = new CGI;

getopts('v');
do "simple-rules.pl";

open(STDOUT,'> /dev/null') unless $opt_v;

$| = 1;

my $count = 0;
my $total = 0;

sub test {
  my ($input, $output) = @_;
  my @result = NewSimpleRulesApplyRules($input, 1);
  my $result = shift(@result);
  print " - @result\n" if $opt_v;
  if ($output ne $result) {
    $input .= "\n" unless substr($input,-1,1) eq "\n";
    warn "$input -> $result\n != $output\n";
  } else {
    $count++;
  }
  $total++;
}

sub GetPageOrEditLink {
  return "link<" . shift() . ">";
}

test("test", "<p>test</p>");
test("foo\n\nbar", "<p>foo</p><p>bar</p>");
test("test\n====\n", "<h2>test</h2>");
test("test\n----\n", "<h3>test</h3>");
test("foo\nbar\n\ntest\n----\n\nfoo\nbar\n", "<p>foo\nbar</p><h3>test</h3><p>foo\nbar</p>");
test("* foo\n* bar\n* baz\n", "<ul><li>foo</li><li>bar</li><li>baz</li></ul>");
test("1. foo\n2. bar\n3. baz\n", "<ol><li>foo</li><li>bar</li><li>baz</li></ol>");
test("~test~ foo", "<p><em>test</em> foo</p>");
test("**test foo**", "<p><strong>test foo</strong></p>");
test("//test foo//", "<p><em>test foo</em></p>");
test("__test foo__", "<p><u>test foo</u></p>");
test("*test* foo", "<p><b>test</b> foo</p>");
test("/test/ foo", "<p><i>test</i> foo</p>");
test("_test_ foo", "<p><u>test</u> foo</p>");
test("http://www.oddmuse.org/",
     "<p><a href=\"http://www.oddmuse.org/\">http://www.oddmuse.org/</a></p>");
print "---> Expect link<foo> on next line:\n" if $opt_v;
test("[[foo]]", "[[foo]]"); # dirty block!
print "---> Expect <p>this is link<foo>.</p> on next line:\n" if $opt_v;
test("this is [[foo]].", "<p>this is ${FS}[[foo]]${FS}.</p>"); # dirty block!
print "---> Expect <p>link<foo> and link<bar></p> on next line:\n" if $opt_v;
test("[[foo]] and [[bar]]", "<p>${FS}[[foo]]${FS} and ${FS}[[bar]]${FS}</p>"); # dirty block!
test("/test/ _test_ *test*", "<p><i>test</i> <u>test</u> <b>test</b></p>");
test("[[foo]] /test/ _test_ *test*",
     "<p>${FS}[[foo]]${FS} <i>test</i> <u>test</u> <b>test</b></p>");
test("* some [[foo]]\n* [[bar]] and [[baz]]\n",
     "<ul><li>some ${FS}[[foo]]${FS}</li><li>${FS}[[bar]]${FS} and ${FS}[[baz]]${FS}</li></ul>");
warn "$count/$total passed.\n";
