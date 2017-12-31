#!/usr/bin/env perl
use strict;
use 5.10.0;
use Socket;

my ($host, $port, $selector) = @ARGV;

sub query_gopher {
  my $query = shift;
  my $text = shift;

  # create client
  socket(my $socket,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2]);
  connect($socket, pack_sockaddr_in($port, inet_aton($host)))
      or die "Can't connect to gopher-server on $host:$port\n";
  $socket->autoflush(1);

  print $socket "$query\r\n";
  binmode($socket, ':pop:raw');
  print $socket $text;
  shutdown($socket,SHUT_WR);
  
  undef $/; # slurp
  return <$socket>;
}

print "gopher://$host:$port/$selector\n";
my $text = undef;
if ($selector =~ m!/write/text$!) {
  print "Type text, end with Ctrl-D:\n";
  local undef $/;
  $text = <STDIN>;
}
print query_gopher($selector, $text);
