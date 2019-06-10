use Mojo::Server::Hypnotoad;
warn "Use hypnotoad -s stuff/hypnotoad.pl to stop the server\n";
my $hypnotoad = Mojo::Server::Hypnotoad->new;
$hypnotoad->run('stuff/mojolicious-app.pl');
