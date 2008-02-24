# Copyright (C) 2004  Xavier Maillard
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

$ModulesDescription .= '<p>$Id: beautify.pl,v 1.4 2008/02/24 16:28:01 weakish Exp $</p>';

use Beautifier::Core;
use Output::HTML;

push(@MyRules, \&BeautificationRule);

sub BeautificationRule {
  if ($bol and m/\G&lt;source\s+([a-zA-Z0-9]+)\s*&gt;\n?(.*?\n)&lt;\/source&gt;[ \t]*\n?/cgs) {
    my $old_ = $_;
    my $oldpos = pos;
    my $lang = $1;
    my $source= $2;
    my $result = $source;
    eval { $result = Beautify($lang, $source); };
    $result = $@ if $@;
    $_ = $old_;
    pos = $oldpos;
    return CloseHtmlEnvironments() . $q->div({-class=>'beauty'}, $result) . AddHtmlEnvironment('p');
  }
  return undef;
}

sub Beautify {
  my ($lang, $source) = @_;
  eval "use HFile::HFile_$lang";
  my $Hfile = eval "new HFile::HFile_$lang";
  return $q->strong(Ts('Cannot highlight the language %s.', $lang)) . "\n\n" . $source if $@;
  my $highlighter = new Beautifier::Core($Hfile, new Output::HTML);
  return $highlighter->highlight_text(UnquoteHtml($source));
}
