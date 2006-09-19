require 't/test.pl';
package OddMuse;
use Test::More tests => 61;

clear_pages();

$host1 = 'tisch';
$host2 = 'stuhl';
$ENV{'REMOTE_ADDR'} = $host1;
update_page('Mendacibombus', 'This is the place.', 'samba', 0, 0,
	    ('username=berta'));
update_page('Bombia', 'This is the time.', 'tango', 0, 0,
	    ('username=alex'));
$ENV{'REMOTE_ADDR'} = $host2;
update_page('Confusibombus', 'This is order.', 'ballet', 1, 0,
	    ('username=berta'));
update_page('Mucidobombus', 'This is chaos.', 'tarantella', 0, 0,
	    ('username=alex'));

@Positives = split('\n',<<'EOT');
for time\|place only
Mendacibombus.*samba
Bombia.*tango
EOT

@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Mucidobombus
tarantella
EOT

$page = get_page('action=rc rcfilteronly=time\|place');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella);
@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order\|chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = ();
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Mendacibombus
samba
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcfilteronly=order%20chaos');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mendacibombus.*samba Bombia.*tango);
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Confusibombus
ballet
EOT

$page = get_page('action=rc rchostonly=tisch');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella);
@Negatives = split('\n',<<'EOT');
Confusibombus
ballet
Bombia
tango
Mendacibombus
samba
EOT

$page = get_page('action=rc rchostonly=stuhl'); # no minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella Confusibombus.*ballet);
@Negatives = split('\n',<<'EOT');
Mendacibombus
samba
Bombia
tango
EOT

$page = get_page('action=rc rchostonly=stuhl showedit=1'); # with minor edits!
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mendacibombus.*samba);
@Negatives = split('\n',<<'EOT');
Mucidobombus
tarantella
Bombia
tango
Confusibombus
ballet
EOT

$page = get_page('action=rc rcuseronly=berta');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Mucidobombus.*tarantella Bombia.*tango);
@Negatives = qw(Confusibombus ballet Mendacibombus samba);

$page = get_page('action=rc rcuseronly=alex');
test_page($page, @Positives);
test_page_negative($page, @Negatives);

@Positives = qw(Bombia.*tango);
@Negatives = qw(Mucidobombus tarantella Confusibombus ballet
		Mendacibombus samba);

$page = get_page('action=rc rcidonly=Bombia');
test_page($page, @Positives);
test_page_negative($page, @Negatives);
