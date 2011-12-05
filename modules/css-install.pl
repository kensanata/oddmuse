=head1 NAME

css-install - an Oddmuse module that allows users to change the site CSS

=head1 SYNOPSIS

This module allows users to install their own CSS. This is useful for
new wikis, specially if using the I<Namespaces> extension.

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

$ModulesDescription .= '<p>$Id: css-install.pl,v 1.1 2011/12/05 23:59:30 as Exp $</p>';

=head1 CONFIGURATION

=head2 @CssList

C<@CssList> contains a list of all the recommended CSS URLs.

=cut

package OddMuse;

use vars qw(@CssList);

# List of Oddmuse CSS URLs

@CssList = qw(http://www.emacswiki.org/css/astrid.css
             http://www.emacswiki.org/css/beige-red.css
             http://www.emacswiki.org/css/blue.css
             http://www.emacswiki.org/css/cali.css
             http://www.emacswiki.org/css/green.css
             http://www.emacswiki.org/css/hug.css
             http://www.emacswiki.org/css/oddmuse.css
             http://www.emacswiki.org/css/wikio.css);

push(@MyAdminCode, \&CssInstallMenu);

sub CssInstallMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=css', T('Install CSS'), 'css'))
    unless $StyleSheet;
}

$Action{css} = \&DoCss;

sub DoCss {
  my $css = GetParam('install', '');
  if ($css) {
    my $data = GetRaw($css);
    ReportError(Ts('%s returned no data, or LWP::UserAgent is not available.', $css),
    '500 INTERNAL SERVER ERROR') unless $data;
    SetParam('text', $data);
    DoPost($StyleSheetPage);
  } else {
    print GetHeader('', T('Install CSS')), $q->start_div({-class=>'content css'}),
      $q->p(Ts('Copy one of the following stylesheets to %s:', GetPageLink($StyleSheetPage)));
    # undo preview
    print GetFormStart(undef, 'GET'), GetHiddenValue('action', 'css');
    print GetHiddenValue('css', '');
    print $q->submit(-name=>'Reset', -value=>T('Reset'));
    print $q->end_form;
    # save
    print GetFormStart(undef, 'GET'), GetHiddenValue('action', 'css');
    print GetHiddenValue('install', '');
    print $q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save'));
    print $q->end_form;
    print $q->end_div();
    foreach my $url (@CssList) {
      print $q->start_div({-class=>'sheet'}), $q->p(GetUrl($url));
      # preview
      print GetFormStart(undef, 'GET'), GetHiddenValue('action', 'css');
      print GetHiddenValue('css', $url);
      print $q->submit(-name=>'Preview', -accesskey=>T('p'), -value=>T('Preview'));
      print $q->end_form;
      # save
      print GetFormStart(undef, 'GET'), GetHiddenValue('action', 'css');
      print GetHiddenValue('css', '');
      print GetHiddenValue('install', $url);
      print $q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save'));
      print $q->end_form;
      print $q->end_div();
    }
    print $q->end_div();
    PrintFooter();
  }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

=cut
