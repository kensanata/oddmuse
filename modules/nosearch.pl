# This module is copied from http://sheep.art.pl/Oddmuse_modules

$ModulesDescription .= '<p>Id: nosearch.pl,v 0.1 2007/06/13 15:42:00 as Exp</p>';


*OldGetSearchLink = *GetSearchLink;
*GetSearchLink = *NewGetSearchLink;
sub NewGetSearchLink {
  my ($text, $class, $name, $title) = @_;
  $name = UrlEncode($name);
  $text =~ s/_/ /g;
  return $q->span({-class=>$class }, $text);
}

push(@MyAdminCode, \&BacklinksMenu);
sub BacklinksMenu {
  my ($id, $menuref, $restref) = @_;
  if ($id) {
      my $text = T('Backlinks');
      my $class = 'backlinks';
      my $name = "backlinks";
      my $title = T("Click to search for references to this page");
      my $link = ScriptLink('search=' . $id, $text, $class, $name, $title);
      push(@$menuref, $link);
  }
}


