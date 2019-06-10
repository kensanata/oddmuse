use Toadfarm -init;

mount "stuff/mojolicious-app.pl" => {
  "Host" => qr{^localhost:8080$},
  mount_point => '/',
};

start;
