# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

# In your CSS file, use something like this, for example:

# span[lang=en] { background-color:#ddf; }
# span[lang=fr] { background-color:#fdd; }
# span[lang=de] { background-color:#ffd; }
# span[lang=it] { background-color:#dfd; }

$ModulesDescription .= '<p>$Id: lang.pl,v 1.4 2004/03/21 01:57:57 as Exp $</p>';

push(@MyRules, \&LangRule);

sub LangRule {
  if  (m/\G\[([a-z][a-z])\]/gc) {
    my $html;
    $html .= "</" . shift(@HtmlStack) . ">"  if $HtmlStack[0] eq 'span';
    return $html . AddHtmlEnvironment('span', "lang=\"$1\"") . "[$1]";
  }
  return '';
}

*OldLangInitCookie = *InitCookie;
*InitCookie = *NewLangInitCookie;

sub NewLangInitCookie {
  OldLangInitCookie(@_);
  my @langs = $q->param('languages');
  SetParam('theme', join(' ', @langs));
}

*OldLangGetNearLinksUsed = *GetNearLinksUsed;
*GetNearLinksUsed = *NewLangGetNearLinksUsed;

sub NewLangGetNearLinksUsed {
  my $id = shift;
  my $html = OldLangGetNearLinksUsed($id);
  my @langs = qw(en de fr it pt);
  my @selected = split(/ /, GetParam('theme', ''));
  $html .= $q->div({-class=>'languages'},
		   GetFormStart(),
		   GetHiddenValue('action', 'browse'),
		   GetHiddenValue('id', $id),
		   T('Languages:'), ' ',
		   $q->checkbox_group('languages', \@langs, \@selected),
		   $q->submit('dolang', T('Show!')) . $q->endform);
  return $html;
}
