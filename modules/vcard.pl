# Copyright (C) 2011–2015  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2014–2015  Aleks-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.
#
# We just try to autodetect everything.

use strict;

AddModuleDescription('vcard.pl');

our ($q, $bol, @MyRules);

push(@MyRules, \&hCardRule);

my $addr = qr(\G(\S+ \S+)
(.*)
((?:[A-Z][A-Z]?-)?\d+) (.*)(?:
(.*))?

);

my $email = qr(\G\s*(\S+@\S+)\n?);

my $tel = qr(\G\s*(\S+): (\+?[-0-9 ]+)\n?);

sub hCardRule {
  return unless $bol;
  my ($fn, $street, $zip, $city, $country) = /$addr/cg;
  if ($fn) {
    my ($mail) = /$email/cg;
    my ($phonetype, $phone) = /$tel/cg;
    my $html = $q->span({-class=>'fn'}, $fn) . $q->br();
    $html .= $q->span({-class=>'street-address'}, $street) . $q->br();
    $html .= $q->span({-class=>'postal-code'}, $zip)
      . ' ' . $q->span({-class=>'locality'}, $city);
    $html .= $q->br()
      . $q->span({-class=>'country-name'}, $country) if $country;
    my $hCard = $q->p($html);
    $html = '';
    $html .= $q->span({-class=>'email'},
		      $q->a({-href=>'mailto:' . $mail}, $mail)) if $mail;
    $html .= $q->br() if $mail and $phone;
    $html .= $q->span({-class=>'tel'},
		      $q->span({-class=>'type'}, $phonetype) . ': '
		      . $q->span({-class=>'value'}, $phone)) if $phone;
    $hCard .= $q->p($html) if $html;
    $hCard = $q->div({-class=>'vcard',
		      -style=>'color:red;'}, $hCard);
    return CloseHtmlEnvironments() . $hCard . AddHtmlEnvironment('p');
  }
  return;
}
