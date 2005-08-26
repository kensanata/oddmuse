# Copyright (C) 2005, Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2004, Leon Brocard

# This module is free software; you can redistribute it or modify it
# under the same terms as Perl itself.

use CGI;
# use Data::Dumper;

package OddMuse;

*DavOldDoBrowseRequest = *DoBrowseRequest;
*DoBrowseRequest = *DavNewDoBrowseRequest;

sub DavNewDoBrowseRequest {
  my $dav = new OddMuse::DAV;
  $dav->run($q)||DavOldDoBrowseRequest();
}

#   my $etag = PageEtag();
#   my $type = 'application/xml';
#   my %headers = (-cache_control=>($UseCache < 0 ? 'no-cache' : 'max-age=10'));
#   $headers{-etag} = $etag if GetParam('cache', $UseCache) >= 2;
#   if ($HttpCharset ne '') {
#     $headers{-type} = "$type; charset=$HttpCharset";
#   } else {
#     $headers{-type} = $type;
#   }

# sub Dav {
#   my ($tag, @content) = @_;
#   my $content = join("\n", @content);
#   my $nl = ($#content == 1 and length($content) > 40) ? "\n" : "";
#   return "<D:$tag>$nl$content$nl</D:$tag>\n";
# }

# sub Link {
#   return $ScriptName . ($UsePathInfo ? '/' : '?') . shift;
# }

package OddMuse::DAV;
use strict;
use warnings;
use Encode;
use HTTP::Date qw(time2str time2isoz);
use HTTP::Headers;
use HTTP::Response;
use HTTP::Request;
use File::Spec;
use URI;
use URI::Escape;
use XML::LibXML;

# These are the methods we understand -- but not all of them are truly
# implemented.
our %implemented = (
  options  => 1,
  put      => 1,
  get      => 1,
  head     => 1,
  post     => 1,
  delete   => 1,
  trace    => 1,
  mkcol    => 1,
  propfind => 1,
  copy     => 1,
  lock     => 1,
  unlock   => 1,
  move     => 1,
);

sub new {
  my ($class) = @_;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub run {
  my ($self, $q) = @_;

  my $method = $q->request_method;
  $method = lc $method;
  return unless $implemented{$method};

  my $path   = decode_utf8 uri_unescape $q->path_info;
  return if $path !~ m|/dav|;

  $self->$method($q);
  return 1;
}

sub options {
  my ($self, $q) = @_;
  print $q->header( -DAV            => '1',
		    -allow          => join(',', map { uc } keys %implemented),
		    -status         => "200 OK", );
}

sub head {
  get(@_, 1);
}

sub get {
  my ($self, $q, $head) = @_;
  my $id = OddMuse::GetId();
  OddMuse::AllPagesList();
  if ($OddMuse::IndexHash{$id}) {
    OddMuse::OpenPage($id);
    if (OddMuse::FileFresh()) {
      print $q->header( -status         => '304 Not Modified', );
    } else {
      print $q->header( -cache_control  => 'max-age=10',
			-etag           => $OddMuse::Page{ts},
			-type           => "text/plain; charset=$OddMuse::HttpCharset",
			-status         => "200 OK", );
      print $OddMuse::Page{text} unless $head;
    }
  } else {
    print $q->header( -status         => "404 Not Found", );
    print $OddMuse::NewText unless $head;
  }
}

sub put {
  my ($self, $request, $response) = @_;
  my $path = decode_utf8 uri_unescape $request->uri->path;
  my $fs   = $self->filesys;

  $response = HTTP::Response->new(201, "CREATED", $response->headers);

  my $fh = $fs->open_write($path);
  print $fh $request->content;
  $fs->close_write($fh);

  return $response;
}

sub _delete_xml {
  my ($dom, $path) = @_;

  my $response = $dom->createElement("d:response");
  $response->appendTextChild("d:href"   => $path);
  $response->appendTextChild("d:status" => "HTTP/1.1 401 Permission Denied")
    ;    # *** FIXME ***
}

sub delete {
  my ($self, $request, $response) = @_;
  my $path = decode_utf8 uri_unescape $request->uri->path;
  my $fs   = $self->filesys;

  if ($request->uri->fragment) {
    return HTTP::Response->new(404, "NOT FOUND", $response->headers);
  }

  unless ($fs->test("e", $path)) {
    return HTTP::Response->new(404, "NOT FOUND", $response->headers);
  }

  my $dom = XML::LibXML::Document->new("1.0", "utf-8");
  my @error;
  foreach my $part (
    grep { $_ !~ m{/\.\.?$} }
    map { s{/+}{/}g; $_ }
    File::Find::Rule::Filesys::Virtual->virtual($fs)->in($path),
    $path
    )
  {

    next unless $fs->test("e", $part);

    if ($fs->test("f", $part)) {
      push @error, _delete_xml($dom, $part)
        unless $fs->delete($part);
    } elsif ($fs->test("d", $part)) {
      push @error, _delete_xml($dom, $part)
        unless $fs->rmdir($part);
    }
  }

  if (@error) {
    my $multistatus = $dom->createElement("D:multistatus");
    $multistatus->setAttribute("xmlns:D", "DAV:");

    $multistatus->addChild($_) foreach @error;

    $response = HTTP::Response->new(207 => "Multi-Status");
    $response->header("Content-Type" => 'text/xml; charset="utf-8"');
  } else {
    $response = HTTP::Response->new(204 => "No Content");
  }
  return $response;
}

sub copy {
  my ($self, $request, $response) = @_;
  my $path = decode_utf8 uri_unescape $request->uri->path;
  my $fs   = $self->filesys;

  my $destination = $request->header('Destination');
  $destination = URI->new($destination)->path;
  my $depth     = $request->header('Depth');
  my $overwrite = $request->header('Overwrite');

  if ($fs->test("f", $path)) {
    return $self->copy_file($request, $response);
  }

  # it's a good approximation
  $depth = 100 if defined $depth && $depth eq 'infinity';

  my @files =
    map { s{/+}{/}g; $_ }
    File::Find::Rule::Filesys::Virtual->virtual($fs)->file->maxdepth($depth)
    ->in($path);

  my @dirs = reverse sort
    grep { $_ !~ m{/\.\.?$} }
    map { s{/+}{/}g; $_ }
    File::Find::Rule::Filesys::Virtual->virtual($fs)
    ->directory->maxdepth($depth)->in($path);

  push @dirs, $path;
  foreach my $dir (sort @dirs) {
    my $destdir = $dir;
    $destdir =~ s/^$path/$destination/;
    if ($overwrite eq 'F' && $fs->test("e", $destdir)) {
      return HTTP::Response->new(401, "ERROR", $response->headers);
    }
    $fs->mkdir($destdir);
  }

  foreach my $file (reverse sort @files) {
    my $destfile = $file;
    $destfile =~ s/^$path/$destination/;
    my $fh = $fs->open_read($file);
    my $file = join '', <$fh>;
    $fs->close_read($fh);
    if ($fs->test("e", $destfile)) {
      if ($overwrite eq 'T') {
        $fh = $fs->open_write($destfile);
        print $fh $file;
        $fs->close_write($fh);
      } else {
      }
    } else {
      $fh = $fs->open_write($destfile);
      print $fh $file;
      $fs->close_write($fh);
    }
  }

  $response = HTTP::Response->new(200, "OK", $response->headers);
  return $response;
}

sub copy_file {
  my ($self, $request, $response) = @_;
  my $path = decode_utf8 uri_unescape $request->uri->path;
  my $fs   = $self->filesys;

  my $destination = $request->header('Destination');
  $destination = URI->new($destination)->path;
  my $depth     = $request->header('Depth');
  my $overwrite = $request->header('Overwrite');

  if ($fs->test("d", $destination)) {
    $response = HTTP::Response->new(204, "NO CONTENT", $response->headers);
  } elsif ($fs->test("f", $path) && $fs->test("r", $path)) {
    my $fh = $fs->open_read($path);
    my $file = join '', <$fh>;
    $fs->close_read($fh);
    if ($fs->test("f", $destination)) {
      if ($overwrite eq 'T') {
        $fh = $fs->open_write($destination);
        print $fh $file;
        $fs->close_write($fh);
      } else {
        $response->code(412);
        $response->message('Precondition Failed');
      }
    } else {
      unless ($fh = $fs->open_write($destination)) {
        $response->code(409);
        $response->message('Conflict');
        return $response;
      }
      print $fh $file;
      $fs->close_write($fh);
      $response->code(201);
      $response->message('Created');
    }
  } else {
    $response->code(404);
    $response->message('Not Found');
  }
  return $response;
}

sub move {
  my ($self, $request, $response) = @_;

  my $destination = $request->header('Destination');
  $destination = URI->new($destination)->path;
  my $destexists = $self->filesys->test("e", $destination);

  $response = $self->copy($request,   $response);
  $response = $self->delete($request, $response)
    if $response->is_success;

  $response->code(201) unless $destexists;

  return $response;
}

sub lock {
  my ($self, $q) = @_;
  print $q->header( -status         => "412 Precondition Failed", );
}

sub unlock {
  my ($self, $q) = @_;
  print $q->header( -status         => "204 No Content", );
}

sub mkcol {
  my ($self, $q) = @_;
  print $q->header( -status         => "403 Forbidden", );
}

sub propfind {
  my ($self, $q) = @_;
  my $depth = $q->http('depth') || "infinity";
  # warn "depth: $depth\n";

  my $content = body();
  # warn "content: $content\n";

  my $parser = XML::LibXML->new;
  my $req;
  eval { $req = $parser->parse_string($content); };
  if ($@) {
    print $q->header( -status       => "400 Bad Request", );
    print $@;
    return;
  }
  # warn "req: " . $req->toString;

  # what properties do we need?
  my $reqinfo;
  my @reqprops;
  $reqinfo = $req->find('/*/*')->shift->localname;
  if ($reqinfo eq 'prop') {
    for my $node ($req->find('/*/*/*')->get_nodelist) {
      push @reqprops, [ $node->namespaceURI, $node->localname ];
    }
  }
  warn "reqprops: " . join(", ", map {join "", @$_} @reqprops) . "\n";

  # collection only, all pages, or single page?
  my @pages = OddMuse::AllPagesList();
  if ($q->path_info =~ '^/dav/?$') {
    warn "collection!\n";
    if ($depth == 0) {
      warn "only the collection!\n";
      @pages = ();
    } else {
      warn "all pages!\n";
    }
  } else {
    my $id = OddMuse::GetId();
    warn "single page, id: $id\n";
    if (not $OddMuse::IndexHash{$id}) {
      print $q->header( -status       => "404 Not Found", );
      print $OddMuse::NewText;
      return;
    }
    @pages = ($id);
  }

  print $q->header( -status => "207 Multi-Status", );

  my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
  my $multistat = $doc->createElement('D:multistatus');
  $multistat->setAttribute('xmlns:D', 'DAV:');
  $doc->setDocumentElement($multistat);

  for my $id (@pages) {
    OddMuse::OpenPage($id);
    my $size = length($OddMuse::Page{text});
    my $mtime = $OddMuse::Page{ts};
    my $ctime = 0;

    # modified time is stringified human readable HTTP::Date style
    $mtime = time2str($mtime);

    # created time is ISO format
    # tidy up date format - isoz isn't exactly what we want, but
    # it's easy to change.
    $ctime = time2isoz($ctime);
    $ctime =~ s/ /T/;
    $ctime =~ s/Z//;

    $size ||= '';

    my $resp = $doc->createElement('D:response');
    $multistat->addChild($resp);
    my $href = $doc->createElement('D:href');
    $href->appendText($OddMuse::ScriptName . '/' . uri_escape encode_utf8 $id);
    $resp->addChild($href);
    my $okprops = $doc->createElement('D:prop');
    my $nfprops = $doc->createElement('D:prop');
    my $prop;

    if ($reqinfo eq 'prop') {
      my %prefixes = ('DAV:' => 'D');
      my $i        = 0;

      for my $reqprop (@reqprops) {
        my ($ns, $name) = @$reqprop;
        if ($ns eq 'DAV:' && $name eq 'creationdate') {
          $prop = $doc->createElement('D:creationdate');
          $prop->appendText($ctime);
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'getcontentlength') {
          $prop = $doc->createElement('D:getcontentlength');
          $prop->appendText($size);
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'getcontenttype') {
          $prop = $doc->createElement('D:getcontenttype');
	  $prop->appendText('httpd/unix-file');
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'getlastmodified') {
          $prop = $doc->createElement('D:getlastmodified');
          $prop->appendText($mtime);
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'resourcetype') {
          $prop = $doc->createElement('D:resourcetype');
          $okprops->addChild($prop);
        } else {
          my $prefix = $prefixes{$ns};
          if (!defined $prefix) {
            $prefix = 'i' . $i++;

            # mod_dav sets <response> 'xmlns' attribute - whatever
            #$nfprops->setAttribute("xmlns:$prefix", $ns);
            $resp->setAttribute("xmlns:$prefix", $ns);

            $prefixes{$ns} = $prefix;
          }

          $prop = $doc->createElement("$prefix:$name");
          $nfprops->addChild($prop);
        }
      }
    } elsif ($reqinfo eq 'propname') {
      $prop = $doc->createElement('D:creationdate');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getcontentlength');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getcontenttype');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getlastmodified');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:resourcetype');
      $okprops->addChild($prop);
    } else {
      $prop = $doc->createElement('D:creationdate');
      $prop->appendText($ctime);
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getcontentlength');
      $prop->appendText($size);
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getcontenttype');
      $prop->appendText('httpd/unix-file');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getlastmodified');
      $prop->appendText($mtime);
      $okprops->addChild($prop);
#       do {
#         $prop = $doc->createElement('D:supportedlock');
#         for my $n (qw(exclusive shared)) {
#           my $lock = $doc->createElement('D:lockentry');

#           my $scope = $doc->createElement('D:lockscope');
#           my $attr  = $doc->createElement('D:' . $n);
#           $scope->addChild($attr);
#           $lock->addChild($scope);

#           my $type = $doc->createElement('D:locktype');
#           $attr = $doc->createElement('D:write');
#           $type->addChild($attr);
#           $lock->addChild($type);

#           $prop->addChild($lock);
#         }
#         $okprops->addChild($prop);
#       };
      $prop = $doc->createElement('D:resourcetype');
      $okprops->addChild($prop);
    }

    if ($okprops->hasChildNodes) {
      my $propstat = $doc->createElement('D:propstat');
      $propstat->addChild($okprops);
      my $stat = $doc->createElement('D:status');
      $stat->appendText('HTTP/1.1 200 OK');
      $propstat->addChild($stat);
      $resp->addChild($propstat);
    }

    if ($nfprops->hasChildNodes) {
      my $propstat = $doc->createElement('D:propstat');
      $propstat->addChild($nfprops);
      my $stat = $doc->createElement('D:status');
      $stat->appendText('HTTP/1.1 404 Not Found');
      $propstat->addChild($stat);
      $resp->addChild($propstat);
    }
  }

  print $doc->toString(1);
}

sub body {
  local $/ = undef; # slurp
  return <STDIN>;   # can only be read once!
}

# my $dav = new OddMuse::DAV;
# my $q = new CGI;
# print $dav->run($q);
