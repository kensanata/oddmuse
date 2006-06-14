package OddMuse;

use vars qw($WantedPageName $WantedPageNameFilter $WantedPageReferrerFilter);

$ModulesDescription .= '<p>$Id: wanted.pl,v 1.2 2006/06/14 18:25:04 skrap Exp $</p>';


push(@MyAdminCode, \&WantedAction);

sub WantedAction 
{
	my ($id, $menuref, $restref) = @_;
	push(@$menuref, ScriptLink('action=wanted', Ts('Wanted Pages')));
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
	print $q->p( sprintf( T('%d Pages'), scalar keys %wanted) );
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
