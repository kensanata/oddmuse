#!/usr/bin/perl
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use LWP::UserAgent;

if (not param('url')) {
  print header(),
    start_html('Wanted Pages'),
    h1('Wanted Pages'),
    p('$Id: wanted.pl,v 1.1 2004/01/03 14:55:27 as Exp $'),
    p('Returns a list of wanted pages based on a dot-file.'),
    start_form(-method=>'GET'),
    p('URL for dot-file: ', textfield('url'), br(),
      'Example: http://www.emacswiki.org/cgi-bin/alex?action=links;raw=1'),
    p('URL for list of nodes: ', textfield('nodes'), br(),
      'Example: http://www.emacswiki.org/cgi-bin/alex?action=index;raw=1'),
    p(submit()),
    end_form(),
    end_html();
  exit;
}

print header(-type=>'text/plain; charset=UTF-8');
$ua = LWP::UserAgent->new;
$request = HTTP::Request->new('GET', param('url'));
$response = $ua->request($request);
$data = $response->content;

while ($data =~ m/"(.*?)" -> "(.*?)"/g) {
  $page{$1} = 1;
  $link{$2} = 1;
}

$request = HTTP::Request->new('GET', param('nodes'));
$response = $ua->request($request);
$data = $response->content;

foreach $pg (split(/\n/, $data)) {
  $pg =~ s/_/ /g;
  $page{$pg} = 1 if $pg;
}

foreach $link (sort keys %link) {
  print $link, "\n" unless $page{$link};
}
