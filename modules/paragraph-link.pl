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

$ModulesDescription .= '<p>$Id: paragraph-link.pl,v 1.3 2004/10/10 17:46:55 as Exp $</p>';

push(@MyRules, \&ParagraphLinkRule);
# The [...] rule conflicts with the [new] in portrait-support.pl
$RuleOrder{\&ParagraphLinkRule} = 100;

sub ParagraphLinkRule {
  if ($bol && m/\G(\[(-)?$FreeLinkPattern\])/cog) {
    Dirty($1);
    my $invisible = $2;
    my $orig = $3;
    my $id = FreeToNormal($orig);
    my $text = $id;
    $text =~ s/_/ /g;
    my $html = ScriptLink(UrlEncode($id), $invisible ? '' : $text, 'permalink', $id,
			  Ts('Permalink to "%s"', $orig));
    my ($class, $resolved, $title, $exists) = ResolveId($id);
    if ($class eq 'alias' and $title ne $OpenPageName) {
      $html .= ' [' . Ts('anchor first defined here: %s',
			 ScriptLink(UrlEncode($resolved), $text, 'alias')) . ']';
    } elsif ($PermanentAnchors{$id} ne $OpenPageName
	     and RequestLockDir('permanentanchors')) { # not fatal
      $PermanentAnchors{$id} = $OpenPageName;
      WritePermanentAnchors();
      ReleaseLockDir('permanentanchors');
    }
    $PagePermanentAnchors{$id} = 1; # add to the list of anchors in page
    $html .= ' [' . Ts('the page %s also exists',
		       ScriptLink("action=browse;anchor=0;id="
				  . UrlEncode($id), $id, 'local')) . ']'
				    if $exists;
    print $html;
    return '';
  }
  return undef;
}
