# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: publish.pl,v 1.3 2006/08/06 11:47:40 as Exp $</p>';

use vars qw($PublishTargetUrl);

$PublishTargetUrl = '';

$Action{publish} = \&DoPublish;

push(@MyAdminCode, \&PublishMenu);

sub PublishMenu {
  my ($id, $menuref, $restref) = @_;
  my $name = $id;
  $name =~ s/_/ /g;
  if ($id and $PublishTargetUrl) {
    push(@$menuref, ScriptLink('action=publish;id=' . $id,
			       Ts('Publish %s', $name), 'publish'));
  }
}

sub DoPublish {
  my ($id) = @_;
  ReportError(T('No target wiki was specified in the config file.'),
	      '500 INTERNAL SERVER ERROR')
    unless $PublishTargetUrl;
  ReportError(T('The target wiki was misconfigured.',
	      '500 INTERNAL SERVER ERROR'))
    if $PublishTargetUrl eq $ScriptName or $PublishTargetUrl eq $FullUrl;
  ReportError('LWP::UserAgent is not available',
	      '500 INTERNAL SERVER ERROR')
    unless eval {require LWP::UserAgent};
  my $ua = LWP::UserAgent->new;
  OpenPage($id);
  my %params = ( title=>$OpenPageName,
		 text=>$Page{text},
		 raw=>1,
		 username=>$Page{username},
		 summary=>$Page{summary},
		 pwd=>GetParam('pwd',''),
	       );
  $params{recent_edit} = 'on' if $Page{minor};
  my $response = $ua->post($PublishTargetUrl, \%params);
  if ($response->code == 302 and $response->header('Location')) {
    print $q->redirect($response->header('Location'));
  } elsif ($response->code == 200) {
    print $q->redirect($PublishTargetUrl . '?' . $id);
  } else {
    ReportError($response->content,
		$response->code . ' ' . $response->message);
  }
}
