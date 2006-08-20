#
# A very simple module to support XHTML Friends Network (http://www.gmpg.org/xfn/)
# 
# Copyright (C) 2006 Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2006 Alexandre (adulau) Dulaunoy <adulauATATfoo.be>
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

$ModulesDescription .= '<p>$Id: xfn.pl,v 1.1 2006/08/20 15:34:35 adulau Exp $</p>';

push ( @MyRules, \&xfnRule );

my $PersonPattern = '\[\[person:(.*?)\]\]';

*MyOldGetHtmlHeader = *GetHtmlHeader;
*GetHtmlHeader      = *MyNewGetHtmlHeader;

sub MyNewGetHtmlHeader {
    my $result = MyOldGetHtmlHeader(@_);
    $result =~ s/\<head\>/\<head profile=\"http:\/\/gmpg.org\/xfn\/11\"\>/;
    return $result;
}

sub xfnRule {
    if (m/\G$PersonPattern/cog) { return &Person($1); }

    return undef;
}

sub Person {
    my $xfn = shift;
    my ( $url, $text, $rel ) = split ( /\|/, $xfn );
    return $q->a( { -href => "${url}", -rel => "${rel}" }, "$text" );
}

