# Copyright (C) 2015  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use Digest::SHA qw(sha256_hex);

package OddMuse;

AddModuleDescription('imagify.pl', 'Imagify Extension');

use vars qw(%ImagifyParams, $ImagifyDir, $ImagifyFormat);
$ImagifyFormat = 'png';
%ImagifyParams = qw{-background transparent -fill black -font Corsiva -pointsize 16 -size 600x};
$ImagifyDir = "$DataDir/imagify"; # For images with rendered text

push(@MyRules, \&DivFooRule);

sub DivFooRule {
  if (m/\Gimagify [ \t]* \{\{\{[ \t]*\n? (.*?)\n? \}\}\}[ \t]*(\n|$)?/cgsx) {
    my $str = $1;
    CreateDir($ImagifyDir);
    my $fileName = sha256_hex($str) . '.' . $ImagifyFormat;
    system('convert', %ImagifyParams, "caption:$str", "$ImagifyDir/$fileName") unless -e "$ImagifyDir/$fileName";
    my $src = $ScriptName . "/imagify/" . UrlEncode($fileName);
    return CloseHtmlEnvironments() . $q->img({-class => 'imagify', -src => $src, -alt => '(rendered text)'}) . AddHtmlEnvironment('p');
  }
  return;
}
