#!/usr/bin/env perl
use Mojolicious::Lite;
use Archive::Tar;
use File::Basename;
my $dir = "/home/alex/oddmuse.org/releases";

get '/' => sub {
  my $c = shift;
  my @tarballs = sort map {
    my ($name, $path, $suffix) = fileparse($_, '.tar.gz');
    $name;
  } <$dir/*.tar.gz>;
  $c->render(template => 'index', tarballs => \@tarballs);
} => 'main';

get '/release/#tarball' => sub {
  my $c = shift;
  my $tar = Archive::Tar->new;
  my $tarball = $c->param('tarball');
  $tar->read("$dir/$tarball.tar.gz");
  my @files = sort grep /./, map { my @e = split('/', $_->name); $e[1] } $tar->get_files();
  $c->render(template => 'release', tarball=> $tarball, files => \@files);
} => 'release';

get '/release/#tarball/#file' => sub {
  my $c = shift;
  my $tar = Archive::Tar->new;
  my $tarball = $c->param('tarball');
  $tar->read("$dir/$tarball.tar.gz");
  my $file = $c->param('file');
  my $text = $tar->get_content("$tarball/$file");
  $c->render(template => 'file', format => 'txt', content => $text);
} => 'file';

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Releases';
<h1>Releases</h1>

<p>Welcome! This is where you get access to tarballs and files in released
versions of Oddmuse.</p>

<ul>
% for my $tarball (@$tarballs) {
<li>
%= link_to release => {tarball => $tarball} => begin
%= $tarball
% end
% }
</ul>


@@ release.html.ep
% layout 'default';
% title 'Release';
<h1><%= $tarball %></h1>
<p>
Back to the <%= link_to 'main page' => 'main' %>.

<ul>
% for my $file (@$files) {
<li>
%= link_to file => {file => $file} => begin
%= $file
% end
% }
</ul>

@@ file.txt.ep
%layout 'file';
<%= $content %>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
<head>
<title><%= title %></title>
%= stylesheet '/tarballs.css'
%= stylesheet begin
body {
  padding: 1em;
  font-family: "Palatino Linotype", "Book Antiqua", Palatino, serif;
}
% end
<meta name="viewport" content="width=device-width">
</head>
<body>
<%= content %>
<hr>
<p>
<%= link_to 'Releases' => 'main' %>&#x2003;<a href="https://alexschroeder.ch/wiki/Contact">Alex Schroeder</a>&#x2003;<a href="https://oddmuse.org/">Oddmuse</a>
</body>
</html>
