# Copyright (C) 2005, Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2004, Leon Brocard

# This module is free software; you can redistribute it or modify it
# under the same terms as Perl itself.

$ModulesDescription .= '<p>$Id: webdav.pl,v 1.9 2005/08/29 20:58:17 as Exp $</p>';

use CGI;
# use Data::Dumper;
package OddMuse;

*DavOldDoBrowseRequest = *DoBrowseRequest;
*DoBrowseRequest = *DavNewDoBrowseRequest;

sub DavNewDoBrowseRequest {
  my $dav = new OddMuse::DAV;
  $dav->run($q)||DavOldDoBrowseRequest();
}

package OddMuse::DAV;

use strict;
use warnings;
use Encode;
use URI::Escape;
use HTTP::Date qw(time2str time2isoz);
use XML::LibXML;

# These are the methods we understand -- but not all of them are truly
# implemented.
our %implemented = (
  get      => 1,
  head     => 1,
  options  => 1,
  propfind => 1,
  put      => 1,
  trace    => 1,
  unlock   => 1,
);

sub new {
  my ($class) = @_;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub run {
  my ($self, $q) = @_;

  my $path   = decode_utf8 uri_unescape $q->path_info;
  return 0 if $path !~ m|/dav|;

  my $method = $q->request_method;
  $method = lc $method;
  # warn uc $method, " ", $path, "\n";
  if (not $implemented{$method}) {
    print $q->header( -status     => '501 Not Implemented', );
    return 1;
  }

  $self->$method($q);
  return 1;
}

sub options {
  my ($self, $q) = @_;
  print $q->header( -allow          => join(',', map { uc } keys %implemented),
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
			-status         => "200 OK",);
      print $OddMuse::Page{text} unless $head;
    }
  } else {
    print $q->header( -status         => "404 Not Found", );
    print $OddMuse::NewText unless $head;
  }
}

sub put {
  my ($self, $q) = @_;
  my $id = OddMuse::GetId();
  my $type = $ENV{'CONTENT_TYPE'};
  my $text = body();
  # hard coded magic based on the specs
  if (not $type) {
    if (substr($text,0,4) eq "\377\330\377\340"
	or substr($text,0,4) eq "\377\330\377\341") {
      # http://www.itworld.com/nl/unix_insider/07072005/
      $type = "image/jpeg";
    } elsif (substr($text,0,8) eq "\211\120\116\107\15\12\32\12") {
      # http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html
      $type = "image/png";
    }
  }
  # warn $type;
  if ($type and substr($type,0,5) ne 'text/') {
    require MIME::Base64;
    $text = '#FILE ' . $type .  "\n" . MIME::Base64::encode($text);
    OddMuse::SetParam('summary', OddMuse::Ts('Upload of %s file', $type));
  }
  OddMuse::SetParam('text', $text);
  local *OddMuse::ReBrowsePage;
  OddMuse::AllPagesList();
  if ($OddMuse::IndexHash{$id}) {
    *OddMuse::ReBrowsePage = *no_content; # modified existing page
  } else {
    *OddMuse::ReBrowsePage = *created; # created new page
  }
  OddMuse::DoPost($id); # do the real posting
}

sub no_content {
  print CGI::header( -status         => "204 No Content", );
}

sub created {
  print CGI::header( -status         => "201 Created", );
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
  # warn "reqprops: " . join(", ", map {join "", @$_} @reqprops) . "\n";

  # collection only, all pages, or single page?
  my @pages = OddMuse::AllPagesList();
  if ($q->path_info =~ '^/dav/?$') {
    # warn "collection!\n";
    if ($depth eq "0") {
      # warn "only the collection!\n";
      @pages = ('');
    } else {
      # warn "all pages!\n";
      unshift(@pages, '');
    }
  } else {
    my $id = OddMuse::GetId();
    # warn "single page, id: $id\n";
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
    my ($size, $mtime, $ctime) = ('', '', ''); # undefined for the wiki proper ($id eq '')
    if ($id) {			# ordinary page
      OddMuse::OpenPage($id);
      $size = length($OddMuse::Page{text});
      $mtime = $OddMuse::Page{ts};
      $ctime = 0;

      # modified time is stringified human readable HTTP::Date style
      $mtime = time2str($mtime);

      # created time is ISO format
      # tidy up date format - isoz isn't exactly what we want, but
      # it's easy to change.
      $ctime = time2isoz($ctime);
      $ctime =~ s/ /T/;
      $ctime =~ s/Z//;

      # force empty strings if undefined
      $size ||= '';
    }

    my $resp = $doc->createElement('D:response');
    $multistat->addChild($resp);
    my $href = $doc->createElement('D:href');
    $href->appendText($OddMuse::ScriptName . '/dav/' . uri_escape encode_utf8 $id);
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
	  $prop->appendText('text/plain');
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'getlastmodified') {
          $prop = $doc->createElement('D:getlastmodified');
          $prop->appendText($mtime);
          $okprops->addChild($prop);
        } elsif ($ns eq 'DAV:' && $name eq 'resourcetype') {
          $prop = $doc->createElement('D:resourcetype');
          if (not $id) { # change for namespaces later
            my $col = $doc->createElement('D:collection');
            $prop->addChild($col);
          }
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
      $prop->appendText('text/plain');
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:getlastmodified');
      $prop->appendText($mtime);
      $okprops->addChild($prop);
      $prop = $doc->createElement('D:resourcetype');
      if (not $id) { # change for namespaces later
	my $col = $doc->createElement('D:collection');
	$prop->addChild($col);
      }
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
  # warn $doc->toString(1);
  print $doc->toString(1);
}

sub body {
  local $/ = undef; # slurp
  return <STDIN>;   # can only be read once!
}

# my $dav = new OddMuse::DAV;
# my $q = new CGI;
# print $dav->run($q);
