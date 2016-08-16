# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('templates.pl', 'Template Extension');

# Any page with a name ending in "Template" is a valid template.
# When creating a page, the $EditNote is prefixed with a list of
# available templates.  When the user clicks on one of the links,
# The text area is filled with the template.

our ($q, %IndexHash, %Action, $EditNote);
our ($TemplatePattern);

$Action{'edit'} = \&TemplateDoEdit;

$TemplatePattern = q{Template$}; # strange quoting because of cperl-mode ;)

sub TemplateDoEdit {
  my ($id, $newText, $preview) = @_;
  AllPagesList(); # prepare %IndexHash
  if (not $IndexHash{$id}) {
    local $EditNote = TemplateList($id) . $EditNote;
    if (GetParam('template', '') and $IndexHash{GetParam('template', '')}) {
      return DoEdit($id, GetPageContent(GetParam('template', '')), 1);
    } else {
      return DoEdit($id, $newText, $preview); # call with localized $EditNote
    }
  }
  DoEdit($id, $newText, $preview); # catch all
}

sub TemplateList {
  my $id = shift;
  my @list = map {
    my $page = $_;
    my $name = $_;
    $name =~ s/_/ /g;
    ScriptLink("action=edit;id=$id;template=$page", $name);
  } grep(/$TemplatePattern/, AllPagesList());
  return $q->div({-class=>'templates'},
		 $q->p(T('Alternatively, use one of the following templates:')),
		 $q->ul($q->li(\@list))) if @list;
}
