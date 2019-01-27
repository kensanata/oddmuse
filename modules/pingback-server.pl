# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2019  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

use LWP::UserAgent;
use RPC::XML::Parser;
use RPC::XML;

AddModuleDescription('pingback-server.pl', 'Pingback Server Extension');

# Specification:  http://www.hixie.ch/specs/pingback/pingback
# XML-RPC errors: http://xmlrpc-epi.sourceforge.net/specs/rfc.fault_codes.php

our ($CommentsPrefix, $q, $HtmlHeaders, %Action, $QuestionaskerSecretKey,
    @MyInitVariables, %IndexHash);

push(@MyInitVariables, \&PingbackServerAddLink);

sub PingbackServerAddLink {
  SetParam('action', 'pingback') if $q->path_info =~ m|/pingback\b|;
  my $id = GetId();
  return unless $id;
  return if $id =~ /^$CommentsPrefix/;
  my $link = '<link rel="alternate" type="application/wiki" href="'
      . ScriptUrl('pingback/' . UrlEncode($id)) . '" />';
  $HtmlHeaders .= $link unless index($HtmlHeaders, /$link/) != -1;
}

$Action{pingback} = \&DoPingbackServer;

sub DoPingbackServer {
  my $id = FreeToNormal(shift);

  # some sanity checks for the request
  if ($q->request_method() ne 'POST') {
    ReportError(T('Only XML-RPC POST requests recognised'), '405 METHOD NOT ALLOWED');
  }
  if ($q->content_type() ne 'text/xml') {
    ReportError(T('Only XML-RPC POST requests recognised'), '415 UNSUPPORTED MEDIA TYPE');
  }

  # some sanity checks for the target page name
  if (not $id) {
    PingbackServerFault('400 NO ID', 33, "No page specified");
  }
  my $error = ValidId($id);
  if ($error) {
    PingbackServerFault('400 INVALID ID', 33, "Invalid page name: $id");
  }

  # check the IP number for bans
  my $rule = UserIsBanned();
  if ($rule) {
   PingbackServerFault('403 FORBIDDEN', 49, "Your IP number is blocked");
  }

  # check that the target page exists
  AllPagesList();
  if (not $IndexHash{$id}) {
    PingbackServerFault('404 NOT FOUND', 32, "Page does not exist: $id");
  }

  # parse the remote procedure call
  my $data = $q->param('POSTDATA');
  my $parser = RPC::XML::Parser->new();
  my $request = $parser->parse($data);
  if (not ref($request)) {
    PingbackServerFault('400 NO DATA', -32700, "Could not parse XML-RPC");
  }

  # sanity check the function and argument number
  my $name = $request->name;
  my $arguments = $request->args;
  if ($name ne 'pingback.ping') {
    PingbackServerFault('501 NOT IMPLEMENTED', -32601, "Method $name not supported");
  }
  if (@$arguments != 2) {
    PingbackServerFault('400 WRONG NUMBER OF ARGS', -32602, "Wrong number of arguments");
  }

  # extract the two arguments
  my $source = $arguments->[0]->value;
  my $target = $arguments->[1]->value;

  # verify that the source isn't banned
  $rule = BannedContent($source);
  if ($rule) {
   PingbackServerFault('403 FORBIDDEN', 49, "The URL is blocked");
  }

  # verify that the pingback is legit
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($source);
  if (not $response->is_success) {
    PingbackServerFault('400 NO SOURCE', 16, "Cannot retrieve $source");
  }
  my $self = ScriptUrl(UrlEncode($id));
  if ($response->decoded_content !~ /$self/) {
    PingbackServerFault('403 FORBIDDEN', "$source does not link to $self");
  }
  $id = $CommentsPrefix . $id;
  if (GetPageContent($id) =~ /$source/) {
    PingbackServerFault('400 ALREADY REGISTERED', 48, "$source has already been registered");
  }

  # post a comment without redirect at the end
  SetParam('aftertext', 'Pingback: ' . $source);
  SetParam('summary', 'Pingback');
  SetParam('username', T('Anonymous'));
  SetParam($QuestionaskerSecretKey, 1) if $QuestionaskerSecretKey;
  local *ReBrowsePage = sub {};
  DoPost($id);

  # response
  my $message = "Oddmuse PingbackServer! $id OK";
  my $response = RPC::XML::response->new(RPC::XML::string->new($message));
  print GetHttpHeader('text/xml', 'nocache', '200 OK'), $response->as_string, "\n\n";
}

sub PingbackServerFault {
  my($status, $error, $data) = @_;
  my $fault = RPC::XML::response->new(RPC::XML::fault->new($error, $data));
  print GetHttpHeader('text/xml', 'nocache', $status), $fault->as_string, "\n\n";
  exit 2;
}
