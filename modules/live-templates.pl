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

$ModulesDescription .= '<p>$Id: live-templates.pl,v 1.2 2004/12/05 03:53:42 as Exp $</p>';

push(@MyRules, \&LiveTemplateRule);

sub LiveTemplateRule {
  if ($bol and /\G(&lt;&lt;$FreeLinkPattern\n)/cog) {
    my $str = $1;
    my $template = FreeToNormal($2);
    print CloseHtmlEnvironments();
    /\G((.*?)\n$template(\n|\Z))/cgs or print $q->p($q->strong(T('Template without parameters')));
    my $oldpos = pos;
    $str .= $1;
    Dirty($str);
    my $data = $2;
    my %hash = ParseData($data);
    my $text = GetPageContent($template);
    return $q->p($q->strong(Ts('The template %s is either empty or does not exist.',
			       $template))) . AddHtmlEnvironment('p') unless $text;
    foreach my $key (keys %hash) {
      $text =~ s/\$$key\$/$hash{$key}/g;
    }
    print "<div class=\"template $template\">";
    ApplyRules($text, 1, 1, undef, 'p');
    pos = $oldpos;
    print '</div>';
    return AddHtmlEnvironment('p');
  }
  return undef;
}
