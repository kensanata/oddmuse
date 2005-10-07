# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK);

package OddMuse;

$RunCGI = 0;
require 'wiki.pl';

sub handler {
  my $r = shift;
  for my $var (qw{DataDir UseConfig ConfigFile ModuleDir ConfigPage
		  AdminPass EditPass ScriptName FullUrl}) {
    no strict "refs";
    $$var = $ENV{"Wiki$var"} if exists $ENV{"Wiki$var"}; # symbolic references
  }
  DoWikiRequest();
  return Apache2::Const::OK;
}
