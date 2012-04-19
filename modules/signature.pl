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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/signature.pl">signature.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Signature_Extension">Signature Extension</a></p>';

push(@MyRules, \&SignatureExceptionRule);

push(@MyMacros, sub{ s/(?<![!+])\+\+\+\+/'-- ' . GetParam('username', T('Anonymous'))
                       . ' ' . TimeToText($Now) /ge });
push(@MyMacros, sub{ s/(?<![!+])\+\+\+/'-- ' . GetParam('username', T('Anonymous'))/ge });

push(@MyMacros, sub{ s/(?<![!+])\~\~\~\~/GetParam('username', T('Anonymous'))
                       . ' ' . TimeToText($Now) /ge });
push(@MyMacros, sub{ s/(?<![!~])\~\~\~/GetParam('username', T('Anonymous'))/ge });

sub SignatureExceptionRule {
  if (m/\G!\+\+\+/gc) {
    return '+++';
  } elsif (m/\G!\~\~\~/gc) {
    return '~~~';
  }
  return undef;
}
