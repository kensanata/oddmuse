use Modern::Perl;
use RPC::XML;
use RPC::XML::Client;
use XML::LibXML;
use LWP::UserAgent;
use Data::Dumper;

if (@ARGV != 2) {
  die "Usage: pingback-client FROM TO\n";
}

my ($from, $to) = @ARGV;
my $ua = LWP::UserAgent->new;
$ua->agent("OddmusePingbackClient/0.1");

print "Getting $to\n";
my $response = $ua->get($to);

if (!$response->is_success) {
  die $response->status_line;
}

print "Parsing $to\n";
my $data = $response->decoded_content;

my $parser = XML::LibXML->new(recover => 2);
my $dom = $parser->load_html(string => $data);
my $pingback = $dom->findvalue('//link[@rel="pingback"]/@href');

if (!$pingback) {
  die "Pingback URL not found in $to\n";
}

print "Pingback URL is $pingback\n";

my $request = RPC::XML::request->new(
  'pingback.ping', $from, $to);
my $client = RPC::XML::Client->new($pingback);
$response = $client->send_request($request);

if (!ref($response)) {
  die $response;
}

print Dumper($response->value);
