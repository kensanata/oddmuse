# $Id: page-trail.pl,v 1.1 2004/01/25 20:27:58 as Exp $

my $PageTrailCookieName = $CookieName . "Trail";
my $PageTrailLength = 10;
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
  @PageTrail = split(/$FS/, $q->cookie($PageTrailCookieName));
  unshift(@PageTrail, $id);
  @PageTrail = @PageTrail[0..$PageTrailLength-1];
}

*OldGetGotoBar = *GetGotoBar;
*GetGotoBar = *NewGetGotoBar;

sub NewGetGotoBar {
  my $bar = OldGetGotoBar(@_);
  $bar .= $q->span({-class=>'trail'}, $q->br(),
		   map { GetPageLink($_) } reverse(@trail));
  return $bar;
}
