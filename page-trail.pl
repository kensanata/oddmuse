use vars qw($PageTrailLength);

$PageTrailLength = 10;

$ModulesDescription .= '<p>$Id: page-trail.pl,v 1.7 2004/01/27 23:06:51 as Exp $</p>';

$CookieParameters{trail} = '';
$InvisibleCookieParameters{trail} = 1;
my @PageTrail;

*OldPageTrailBrowsePage = *BrowsePage;
*BrowsePage = *NewPageTrailBrowsePage;

sub NewPageTrailBrowsePage {
  my ($id, $raw, $comment) = @_;
  UpdatePageTrail($id);
  OldBrowsePage($id, $raw, $comment);
}

sub UpdatePageTrail {
  my $id = shift;
  my $US  = "\x1f";
  @PageTrail = split(/$US/, GetParam('trail', ''));
  unshift(@PageTrail, $id);
  @PageTrail = @PageTrail[0..$PageTrailLength-1] if $PageTrail[$PageTrailLength];
  SetParam('trail', join($US, @PageTrail));
}

*OldPageTrailGetGotoBar = *GetGotoBar;
*GetGotoBar = *NewPageTrailGetGotoBar;

sub NewPageTrailGetGotoBar {
  my $bar = OldGetGotoBar(@_);
  $bar .= $q->span({-class=>'trail'}, $q->br(), T('Trail: '),
		   map { GetPageLink($_) } reverse(@PageTrail))
    if @PageTrail;
  return $bar;
}
