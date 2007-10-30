# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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

$ModulesDescription .= '<p>$Id: multi-url-spam-block.pl,v 1.3 2007/10/30 08:47:59 as Exp $</p>';

*OldMultiUrlBannedContent = *BannedContent;
*BannedContent = *NewMultiUrlBannedContent;

$BannedContent = $OldMultiUrlBannedContent; # copy scalar

$MultiUrlLimit = 30;

sub NewMultiUrlBannedContent {
  my $str = shift;
  my @urls = $str =~ /$FullUrlPattern/go;
  my %domains;
  my $max = 0;
  foreach my $url (@urls) {
    my @urlparts = split('/', $url, 4);
    my $domain = $urlparts[2];
    my @domainparts = split('\.', $domain);
    splice(@domainparts, 0, -2); # no subdomains
    $domain = join('.', @domainparts);
    $domains{$domain}++;
    $max = $domains{$domain} if $domains{$domain} > $max;
  }
  return Ts('You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.', $MultiUrlLimit)
    if $max > $MultiUrlLimit;
  return OldMultiUrlBannedContent($str);
}
