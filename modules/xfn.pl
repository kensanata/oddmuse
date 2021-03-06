#
# A very simple module to support XHTML Friends Network (http://www.gmpg.org/xfn/)
#
# Copyright (C) 2006 Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2006 Alexandre (adulau) Dulaunoy <adulauATATfoo.be>
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

AddModuleDescription('xfn.pl', 'xfn Module');

our ($q, @MyRules);

push ( @MyRules, \&xfnRule );

my $PersonPattern = '\[\[person:(.*?)\]\]';

*MyOldGetHtmlHeader = \&GetHtmlHeader;
*GetHtmlHeader      = \&MyNewGetHtmlHeader;

sub MyNewGetHtmlHeader {
    my $result = MyOldGetHtmlHeader(@_);
    $result =~ s/\<head\>/\<head profile=\"http:\/\/gmpg.org\/xfn\/11\"\>/;
    return $result;
}

sub xfnRule {
    if (m/\G$PersonPattern/cg) { return &Person($1); }

    return;
}

sub Person {
    my $xfn = shift;
    my ( $url, $text, $rel ) = split ( /\|/, $xfn );
    return $q->a( { -href => "${url}", -rel => "${rel}" }, "$text" );
}
