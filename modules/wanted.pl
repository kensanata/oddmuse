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

package OddMuse;

use vars qw($WantedPageName $WantedPageNameFilter $WantedPageReferrerFilter);

$ModulesDescription .= '<p>$Id: wanted.pl,v 1.5 2006/08/17 13:59:29 as Exp $</p>';


push(@MyAdminCode, \&WantedAction);

sub WantedAction 
{
	my ($id, $menuref, $restref) = @_;
	push(@$menuref, ScriptLink('action=wanted', Ts('Wanted Pages'), 'wanted'));
}

sub PrintWantedData
{
	my %links = %{(GetFullLinkList(1,0,0,1))};
	my %wanted;
	foreach my $page (sort keys %links) {
		next if defined $WantedPageReferrerFilter and ($page =~ m/$WantedPageReferrerFilter/);
		foreach my $link (@{$links{$page}}) {
			next if defined $WantedPageNameFilter and ($link =~ m/$WantedPageNameFilter/);
			push @{$wanted{$link}}, $page if not $IndexHash{$link};
		}
	}
	print $q->p(Ts('%s pages', scalar keys %wanted));
	foreach my $page (sort keys %wanted) {
		my @references = map {GetPageLink($_)} (sort @{$wanted{$page}});
		my $pageLink = sprintf( T('%s, referenced from:'), GetEditLink($page,$page) );
		print $q->ul( $q->li($pageLink, $q->ul($q->li(\@references))));
	}
}

$Action{'wanted'} = \&DoWantedPages;

sub DoWantedPages {
	my $title = defined $WantedPageName ? $WantedPageName : T('Wanted Pages');
	print GetHeader('', $title, '', 1), $q->start_div({-class=>'content wanted'});
	PrintWantedData();
	print $q->end_div();
	PrintFooter();
}
