# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA
#
# History / Notes
#   2004.03.19
#     - Created
#     - Works!
#     - Tried to get rid of LWP but failed :(
#     - We have to capture the script before CGI.pm starts to get STDIN

$ModulesDescription .= '<p>pingback-server.pl (v0.1) - PingbackServers get noted on the comment page.</p>';

use LWP::UserAgent; # This one will one day be eliminated! Hopefully!

# Need these to do pingback
use RPC::XML;
use RPC::XML::Parser;

use vars qw( $CommentsPrefix );

*OldPingbackServerGetHtmlHeader = *GetHtmlHeader;
*GetHtmlHeader = *NewPingbackServerGetHtmlHeader;

# Add the <link ...> to the header
sub NewPingbackServerGetHtmlHeader {
  my ($title, $id) = @_;
  my $header = OldPingbackServerGetHtmlHeader($title,$id);
  my $pingbackLink =
    '<link rel="pingback" '
    . 'href="http://thelackthereof.org/wiki.pl?action=pingback;id='
    . $id . '">';
  $header =~ s/<head>/<head>$pingbackLink/;
  return $header;
}

*OldPingbackServerInitRequest = *InitRequest;
*InitRequest = *NewPingbackServerInitRequest;

sub NewPingbackServerInitRequest {
  if($ENV{'QUERY_STRING'} =~ /action=pingback;id=(.*)/) {
    my $id = $1;
    DoPingbackServer($id);
    exit 0;
  } else {
    return OldPingbackServerInitRequest(@_);
  }
}

sub DoPingbackServer {
  my $id = FreeToNormal(shift);


  if ($ENV{'REQUEST_METHOD'} ne 'POST') {
      result('405 Method Not Allowed', -32300,
        'Only XML-RPC POST requests recognised.', 'Allow: POST');
  }

  if ($ENV{'CONTENT_TYPE'} ne 'text/xml') {
      result('415 Unsupported Media Type', -32300,
        'Only XML-RPC POST requests recognised.');
  }

  local $/ = undef;
  my $input = <STDIN>;

  # parse it
  my $parser = RPC::XML::Parser->new();
  my $request = $parser->parse($input);
  if (not ref($request)) {
      result('400 Bad Request', -32700, $request);
  }

  # handle it
  my $name = $request->name;
  my $arguments = $request->args;
  if ($name ne 'pingback.ping') {
      result('501 Not Implemented', -32601, "Method $name not supported");
  }
  if (@$arguments != 2) {
      result('400 Bad Request', -32602,
      "Wrong number of arguments (arguments must be in the form 'from', 'to')");
  }
  my $source = $arguments->[0]->value;
  my $target = $arguments->[1]->value;


  # TODO: Since we are _inside_ the wiki seems like we shouldn't have to use LWP
  # So comment out all the LWP stuff once the DoPost thingie works
  # DoPost($id);

  my $ua = LWP::UserAgent->new;
  $ua->agent("OddmusePingbackServer/0.1 ");

  # Create a request
  my $req = HTTP::Request->new(POST => 'http://thelackthereof.org/wiki.pl');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content("title=$CommentsPrefix$id"
    . "&summary=new%20comment"
    . "&aftertext=Pingback:%20$source"
    . "&save=save"
    . "&username=pingback");
  my $res = $ua->request($req);

  my $out = '';
  # Check the outcome of the response
  if ($res->is_success) {
    $out =  $res->content;
  } else {
    $out = $res->status_line, "\n";
  }

  result('200 OK', 0, "Oddmuse PingbackServer! $id OK");

  sub result {
      my($status, $error, $data, $extra) = @_;
      my $response;
      if ($error) {
          $response = RPC::XML::response->new(
            RPC::XML::fault->new($error, $data));
      } else {
          $response = RPC::XML::response->new(RPC::XML::string->new($data));
      }
      print "Status: $status\n";
      if (defined($extra)) {
          print "$extra\n";
      }
      print "Content-Type: text/xml\n\n";
      print $response->as_string;
      exit;
  }

=pod
  
  # This doesn't work... but might be a basis for an in-wiki update system

  sub DoPost {
    my $id = FreeToNormal(shift);
    my $source = shift;
    ValidIdOrDie($id);
    # Lock before getting old page to prevent races
    RequestLockOrError(); # fatal
    OpenPage($id);
    my $string = $Page{text};
    my $comment = "Pingback: $source";
    $comment =~ s/\r//g;	# Remove "\r"-s (0x0d) from the string
    $comment =~ s/\s+$//g;    # Remove whitespace at the end
    $string .= "----\n" if $string and $string ne "\n";
    $string .= $comment . "\n\n-- Pingback"
      . ' ' . TimeToText(time) . "\n\n";
    my $summary = "new pingback"
    $Page{summary} = $summary;
    $Page{username} = $user;
    $Page{text} = $string;
    SavePage();
    ReleaseLock();
  }

=cut

}

