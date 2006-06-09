# Copyright (C) 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: sync.pl,v 1.3 2006/06/09 08:09:24 as Exp $</p>';

push(@MyRules, \&SyncRule);

sub SyncRule {
  # [[copy:http://example.com/wiki]]
  if (m/\G\[\[(copy:$FullUrlPattern)\]\]/cog) {
    my ($text, $url) = ($1, $2);
    return $q->a({-href=>$2, class=>'outside copy'}, $text);
  }
  return undef;
}

*SyncOldSave = *Save;
*Save = *SyncNewSave;

sub SyncNewSave {
  my ($id) = @_;
  SyncOldSave(@_);
  # %Page is now set, but the reply was not yet sent back to the
  # browser
  my $id = $OpenPageName;
  my $data = $Page{text};
  my $user = $Page{username};
  my $summary = $Page{summary};
  my $minor = $Page{minor};
  my @links = ();
  while ($data =~ m/\[\[copy:$FullUrlPattern\]\]/g) {
    push(@links, $1) unless $1 eq $ScriptName or $1 eq $FullUrl;
  }
  my $msg = GetParam('msg', '');
  foreach my $uri (@links) {
    next if $uri eq $ScriptName or $uri eq $FullUrl;
    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my %params = ( title=>$id,
		   text=>$data,
		   raw=>1,
		   username=>$user,
		   pwd=>GetParam('pwd',''),
		   summary=>$summary, );
    $params{recent_edit} = 'on' if $minor;
    my $response = $ua->post($uri, \%params);
    my $status = $response->code . ' ' . $response->message;
    warn "Result for $uri: $status";
    $msg .= ' ' if $msg;
    $msg .= $response->is_success
      ? Tss('Copy to %1 succeeded: %2.', $uri, $status)
      : Tss('Copy to %1 failed: %2.', $uri, $status);
  }
  SetParam('msg', $msg);
}
