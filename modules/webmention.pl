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
use Modern::Perl;
use XML::LibXML;

AddModuleDescription('webmention.pl', 'Webmention Server Extension');

# Specification:  https://www.w3.org/TR/webmention/

our ($CommentsPrefix, $q, $HtmlHeaders, %Action, $QuestionaskerSecretKey,
     @MyInitVariables, %IndexHash, $BannedContent, $UsePathInfo, $HomePage,
    $Message, @MyAdminCode, $FullUrlPattern);

push(@MyInitVariables, \&WebmentionServerAddLink, \&WebmentionAddAction);

# Add webmentions metadata to our pages

sub WebmentionServerAddLink {
  $Message .= T('Webmention module requires $CommentsPrefix to be set')  unless $CommentsPrefix;
  # only allow linking to reasonable pages: no URL parameters!
  my @params = $q->param;
  return if $UsePathInfo and @params > 0;
  return if not $UsePathInfo and (@params > 1 or @params == 1 and $params[0] ne 'id');
  return unless GetParam('action', 'browse') eq 'browse';
  my $id = GetId() || $HomePage;
  return if $id =~ /^$CommentsPrefix/;
  my $link = '<link rel="webmention" type="application/wiki" href="'
      . ScriptUrl('webmention/' . UrlEncode($id)) . '" />';
  $HtmlHeaders .= $link unless $HtmlHeaders =~ /rel="webmention"/;
}

sub WebmentionAddAction {
  SetParam('action', 'webmention') if $q->path_info =~ m|/webmention\b|;
}

# Process incoming webmentions

$Action{webmention} = \&DoWebmentionServer;

sub DoWebmentionServer {
  my $id = FreeToNormal(shift);

  # some sanity checks for the request
  if ($q->request_method() ne 'POST') {
    ReportError(T('Webmention requires a POST request'), '400 BAD REQUEST');
  }
  if ($q->content_type() ne 'application/x-www-form-urlencoded') {
    ReportError(T('Webmention requires x-www-form-urlencoded requests'), '400 BAD REQUEST');
  }

  # some sanity checks for the target page name
  if (not $id) {
    ReportError(T('Webmention must mention a specific page'), '400 BAD REQUEST');
  }
  my $error = ValidId($id);
  if ($error) {
    ReportError(T('Webmention must mention a valid page'), '400 BAD REQUEST');
  }

  # check the IP number for bans
  my $rule = UserIsBanned();
  if ($rule) {
    ReportError(Ts('Your IP number is blocked: %s', $rule), '403 FORBIDDEN');
  }

  # check that the target page exists
  AllPagesList();
  if (not $IndexHash{$id}) {
    ReportError(T('Webmention must mention an existing page'), '404 NOT FOUND');
  }

  # verify parameters
  my $source = GetParam('source', undef) or ReportError(T('Webmention must mention source'), '400 BAD REQUEST');
  my $target = GetParam('target', undef) or ReportError(T('Webmention must mention target'), '400 BAD REQUEST');

  # verify that the source isn't banned
  $rule = BannedContent($source);
  if ($rule) {
    ReportError(Ts('The URL is blocked: %s', $rule), '403 FORBIDDEN');
  }

  # verify that the webmention is legit
  my $ua = LWP::UserAgent->new(agent => 'Oddmuse Webmention Server/0.1');
  my $response = $ua->get($source);
  if (not $response->is_success) {
    ReportError(Tss('Webmention source cannot be verified: %1 returns %2 %3',
		    $source, $response->code, $response->message), '400 BAD REQUEST');
  }
  my $self = ScriptUrl(UrlEncode($id));
  if ($response->decoded_content !~ /$self/) {
    ReportError(Ts('Webmention source does not link to %s', $self), '400 BAD REQUEST');
  }
  $id = $CommentsPrefix . $id;
  if (GetPageContent($id) =~ /$source/) {
    ReportError(Ts('Webmention for %s already exists', $source), '400 BAD REQUEST');
  }

  # post a comment without redirect at the end
  SetParam('aftertext', 'Webmention: ' . $source);
  SetParam('summary', 'Webmention');
  SetParam('username', T('Anonymous'));
  SetParam($QuestionaskerSecretKey, 1) if $QuestionaskerSecretKey;
  local *ReBrowsePage = sub {};
  DoPost($id);

  # response
  print GetHeader('', T('Webmention OK!'));
  print $q->start_div({-class=>'content webmention'}),
      $q->p(GetPageLink($BannedContent)),
      $q->end_div;
  PrintFooter();
}

# Allow user to webmention other sites

push(@MyAdminCode, \&WebmentionMenu);

sub WebmentionMenu {
  my ($id, $menuref, $restref) = @_;
  if ($id) {
    push(@$menuref, ScriptLink('action=webmentions;id=' . $id, T('Add webmentions'), 'webmentions'));
  }
}

$Action{webmentions} = \&DoWebmentionMenu;

sub DoWebmentionMenu {
  my $id = GetId();
  ValidIdOrDie($id);
  print GetHeader('', Ts('Webmentioning others from %s', NormalToFree($id)), '');
  my $text = GetPageContent($id);
  my @urls = $text =~ /$FullUrlPattern/g;
  if (@urls) {
    print GetFormStart();
    print GetHiddenValue('action', 'webmentioning');
    print GetHiddenValue('from', UrlEncode($id));
    print '<p>';
    print $q->checkbox_group('to', \@urls, undef, 'true');
    print '</p>';
    print $q->submit('go', T('Webmention!'));
  } else {
    print $q->p(T('No links found.'));
  }
  PrintFooter();
}

$Action{webmentioning} = \&DoWebmention;

sub DoWebmention {
  my $id = GetParam('from');
  ValidIdOrDie($id);
  my $from = ScriptUrl($id);
  my @to = $q->param('to'); # multivalued!
  ReportError('Missing target') unless @to;
  print GetHeader('', Ts('Webmentioning somebody from %s', NormalToFree($id)), '');
  for my $to (@to) {
    Webmention($from, $to);
  }
  PrintFooter();
}

sub Webmention {
  my ($from, $to) = @_;
  ReportError('Target must be an URL', '400 BAD REQUEST', 0, $q->p($to)) unless $to =~ /$FullUrlPattern/;
  my $ua = LWP::UserAgent->new(agent => "Oddmuse Webmention Client/0.1");

  print $q->p(Ts('Contacting %s', $to));
  my $response = $ua->get($to);
  if (!$response->is_success) {
    print $q->p(Ts('Target reports an error: %s', $response->status_line));
    return;
  }

  print $q->p("Parsing response");
  my $data = $response->decoded_content;
  my $parser = XML::LibXML->new(recover => 2);
  my $dom = $parser->load_html(string => $data);
  my $webmention = $dom->findvalue('//link[@rel="webmention"]/@href');

  if (!$webmention) {
    print $q->p(T('No Webmention URL found'));
    return;
  }

  print $q->p("Webmention URL is $webmention");

  $response = $ua->post($webmention, { source => $from, target => $to });
  my $message = $response->code . " " . $response->message;
  if ($response->is_success) {
    print $q->p(Ts("Success: %s", $message));
  } else {
    print $q->p(Ts("Failure: %s", $message));
    $dom = $parser->load_html(string => $response->decoded_content());
    for my $node ($dom->getElementsByTagName('script')) { $node->parentNode->removeChild($node) };
    for my $node ($dom->getElementsByTagName('style')) { $node->parentNode->removeChild($node) };
    print $q->p($dom->textContent);
  }
}
