# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#               2004  Tilmann Holst <spam@tholst.de>
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

$ModulesDescription .= '<p>$Id: translations.pl,v 1.2 2004/12/22 02:35:32 as Exp $</p>';

push(@MyRules, \&TranslationRule);

sub TranslationRule {
  if (m/\G(\&lt;translation +\[\[$FreeLinkPattern\]\] +(\d+)\&gt;[ \t]*)/gc) {
    Dirty($1);
    print GetTranslationLink($2, $3);
    return '';
  }
  return undef;
}

sub GetCurrentPageRevision {
  my $id   = shift;
  my %page = ParseData(ReadFileOrDie(GetPageFile($id)));
  return $page{revision};
}

sub GetTranslationLink {
  my ($id, $revision) = @_;
  my $result = "";
  my $currentRevision;
  $id =~ s/^\s+//;		# Trim extra spaces
  $id =~ s/\s+$//;
  $id     = FreeToNormal($id);
  $result = Ts('This page is a translation of %s. ', GetPageOrEditLink( $id, '', 0, 1));
  $currentRevision = GetCurrentPageRevision($id);

  if ($currentRevision == $revision) {
    $result .= T("The translation is up to date.");
  } elsif ( $currentRevision > $revision ) {
    $result .= T("The translation is outdated.") . ' '
      . ScriptLink("action=browse&diff=1&id=$id&revision=$currentRevision&diffrevision=$revision",
		   T("(diff)"));
  } else {
    $result .= T("The page does not exist.");
  }
  return $result;
}
