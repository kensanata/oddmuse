# $Id: page-trail.pl,v 1.4 2004/01/25 21:04:44 as Exp $

my $PageTrailLength = 10;

$CookieParameters{trail} = '';
$InvisibleCookieParameters{trail} = 1;
my @PageTrail;

*OldBrowsePage = *BrowsePage;
*BrowsePage = *NewBrowsePage;

sub NewBrowsePage {
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

*OldGetGotoBar = *GetGotoBar;
*GetGotoBar = *NewGetGotoBar;

sub NewGetGotoBar {
  my $bar = OldGetGotoBar(@_);
  $bar .= $q->span({-class=>'trail'}, $q->br(), T('Trail: '),
		   map { GetPageLink($_) } reverse(@PageTrail))
    if @PageTrail;
  return $bar;
}
