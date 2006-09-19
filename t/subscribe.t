require 't/test.pl';
package OddMuse;
use Test::More tests => 4;
clear_pages();

add_module('subscriberc.pl');

run_tests(split('\n',<<'EOT'));
My subscribed pages: AlexSchroeder.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder)$">My subscribed pages: AlexSchroeder</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]].
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar</a>.
My subscribed categories: CategoryDecisionMaking, CategoryBar.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=(CategoryDecisionMaking|CategoryBar)">My subscribed categories: CategoryDecisionMaking, CategoryBar</a>.
My subscribed pages: AlexSchroeder, [[LionKimbro]], [[Foo bar]], categories: CategoryDecisionMaking.
<a href="http://localhost/test.pl?action=rc;rcfilteronly=^(AlexSchroeder|LionKimbro|Foo_bar)$|(CategoryDecisionMaking)">My subscribed pages: AlexSchroeder, LionKimbro, Foo bar, categories: CategoryDecisionMaking</a>.
EOT
