#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Cache;
use Archive::Tar;
use File::Basename;
use Sort::Versions;
use Encode qw(decode_utf8);
my $dir = "/home/alex/oddmuse.org/releases";
my $cache = Mojo::Cache->new(max_keys => 50);

get '/' => sub {
  my $c = shift;
  my @tarballs = sort versioncmp map {
    my ($name, $path, $suffix) = fileparse($_, '.tar.gz');
    $name;
  } <$dir/*.tar.gz>;
  $c->render(template => 'index', tarballs => \@tarballs);
} => 'main';

get '/#tarball' => sub {
  my $c = shift;
  my $tarball = $c->param('tarball');
  my $files = $cache->get($tarball);
  if (not $files) {
    $c->app->log->info("Reading $tarball.tar.gz");
    my $tar = Archive::Tar->new;
    $tar->read("$dir/$tarball.tar.gz");
    my @files = sort grep /./, map {
      my @e = split('/', $_->name);
      $e[1];
    } $tar->get_files();
    $files = \@files;
    $cache->set($tarball => $files);
  }
  $c->render(template => 'release', tarball=> $tarball, files => $files);
} => 'release';

get '/#tarball/#file' => sub {
  my $c = shift;
  my $tarball = $c->param('tarball');
  my $file = $c->param('file');
  my $text = $cache->get("$tarball/$file");
  if (not $text) {
    $c->app->log->info("Reading $tarball/$file");
    my $tar = Archive::Tar->new;
    $tar->read("$dir/$tarball.tar.gz");
    $text = decode_utf8($tar->get_content("$tarball/$file"));
    $cache->set("$tarball/$file" => $text);
  }
  if ($text) {
    $c->render(template => 'file', format => 'txt', content => $text);
  } else {
    $c->render(template => 'missing');
  }
} => 'file';

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'Oddmuse Releases';
<h1>Oddmuse Releases</h1>

<p>Welcome! This is where you get access to tarballs and files in released
versions of Oddmuse.</p>

<ul>
% for my $tarball (@$tarballs) {
<li>
<a href="https://oddmuse.org/releases/<%= $tarball %>.tar.gz"><%= $tarball %>.tar.gz</a>
(files for <%= link_to release => {tarball => $tarball} => begin %>\
<%= $tarball =%><%= end %>)
</li>
% }
</ul>


@@ release.html.ep
% layout 'default';
% title 'Release';
<h1>Files for <%= $tarball %></h1>
<p>
Back to the list of <%= link_to 'releases' => 'main' %>.
Remember,
%= link_to file => {file => 'wiki.pl'} => begin
wiki.pl
% end
is the main script.

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
<%== $content %>

@@ missing.html.ep
% layout 'default';
% title 'Missing File';
<h1><%= $tarball %> is missing <%= $file %></h1>
<p>
You can go back to the list of <%= link_to 'releases' => 'main' %>,
or you can try to find <%= $file %> in the
<a href="https://raw.githubusercontent.com/kensanata/oddmuse/master/modules/<%= $file %>">unstable modules</a> section on GitHub.

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
<a href="https://oddmuse.org/">Oddmuse</a>&#x2003;
<%= link_to 'Releases' => 'main' %>&#x2003;
<a href="https://alexschroeder.ch/wiki/Contact">Alex Schroeder</a>
</body>
</html>
