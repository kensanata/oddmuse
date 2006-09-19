require 't/test.pl';
package OddMuse;
use Test::More tests => 18;

clear_pages();

$localhost = 'confusibombus';
$ENV{'REMOTE_ADDR'} = $localhost;

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "# Foo\n#Bar\n$localhost\n", 'banning me'),
	  'Describe the new page here');

## Edit banned hosts as admin should succeed

test_page(update_page('BannedHosts', "#Foo\n#Bar\n$localhost\n", 'banning me', 0, 1),
	  "Foo",
	  $localhost);

## Edit banned hosts as a normal user should fail

test_page(update_page('BannedHosts', "Something else.", 'banning me'),
	  "Foo",
	  $localhost);

## Try to edit another page as a banned user

test_page(update_page('BannedUser', 'This is a test which should fail.', 'banning test'),
	  'Describe the new page here');

## Try to edit the same page as a banned user with admin password

test_page(update_page('BannedUser', 'This is a test.', 'banning test', 0, 1),
	  "This is a test");

## Unbann myself again, testing the regexp

test_page(update_page('BannedHosts', "#Foo\n#Bar\n", 'banning me', 0, 1), "Foo", "Bar");

## Banning content

update_page('BannedContent', "# cosa\nmafia\n#nostra\n", 'one banned word', 0, 1);
test_page(update_page('CriminalPage', 'This is about http://mafia.example.com'),
	  'Describe the new page here');

test_page($redirect, split('\n',<<'EOT'));
banned text
wiki administrator
matched
See .*BannedContent.* for more information
EOT

test_page(update_page('CriminalPage', 'This is about http://nafia.example.com'),
	  "This is about", "http://nafia.example.com");
test_page(update_page('CriminalPage', 'This is about the cosa nostra'),
	  'cosa nostra');
test_page(update_page('CriminalPage', 'This is about the mafia'),
	  'This is about the mafia'); # not in an url
