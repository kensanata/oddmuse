# From the root directory, run one of the following:
# 1. stuff/mojolicious-app.pl daemon -l http://localhost:8080
# 2. stuff/hypnotoad.pl
# 3. stuff/toadfarm.pl start

use Mojolicious::Lite;

plugin CGI => {
  support_semicolon_in_query_string => 1,
};

plugin CGI => {
  route => '/',
  script => 'wiki.pl',
};

app->start;
