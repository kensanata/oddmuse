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

$ModulesDescription .= '<p>$Id: nearlink-create.pl,v 1.1 2006/12/02 21:36:01 as Exp $</p>';

*OldNearCreateScriptLink = *ScriptLink;
*ScriptLink = *NewNearCreateScriptLink;

sub NewNearCreateScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey, $nofollow) = @_;
  my $html = OldNearCreateScriptLink(@_);
  if ($class eq 'near' and $text =~ /^$FreeLinkPattern$/) {
    # Hack alert: For near links, $action will contain an URL, not the
    # id. The NearSite is stored in $name.
    my $id = UrlDecode($action);
    if ($id =~ s/$InterSite{$title}// and $id =~ /^$FreeLinkPattern$/) {
      $action = 'action=edit;id=' . UrlEncode(FreeToNormal($id));
      $html .= ScriptLink($action, T(' (create locally)'), 'edit create', undef,
			  T('Click to edit this page'), $accesskey);
    }
  }
  return $html;
}
