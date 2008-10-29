# Copyright (C) 2008  Alex Schroeder <alex@gnu.org>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

=head1 Translation Links

This package allows Oddmuse to support translation links.

The prerequisite is that you set the C<%Languages> option.

Example:

     %Languages = ('de' => '\b(der|die|das|und|oder)\b',
                   'en' => '\b(the|he|she|that|this)\b');

This defines the I<known languages>: de and en, in our example.

The known languages should not contain any characters with a special
meaning in a regular expresion, nor should it contain a space or an
underscore.

=head2 %TranslationLinkTarget

This option maps languages to URLs. If this option is not set, all
links will point to the default URL of the wiki, C<$ScriptName>.

You can use this together with the namespace extension. Here's an
example:

    $TranslationLinkTarget{en} = "$ScriptName/En";
    $TranslationLinkTarget{de} = "$ScriptName/De";

Or you can use a setup using a different wrapper script per language:

    $TranslationLinkTarget{en} = "$ScriptName-en";
    $TranslationLinkTarget{de} = "$ScriptName-de";

=head2 $TranslationLinkHelpPage

When translating a page, people will be offered a link to a help page.
The default page is called TranslationHelp.

=cut

use vars qw($TranslationLinkPattern %TranslationLinkTarget
	    $TranslationLinkHelpPage);

$TranslationLinkHelpPage = 'TranslationHelp';

=head2 $TranslationLinkPattern

This regular expression is formed via all the defined languages and
C<$FreeLinkPattern> if C<$FreeLinks> is set and/or C<$LinkPattern> if
C<$WikiLinks> is set. It matches things such as C<[[en:HomePage]]>.

=cut

push(@MyInitVariables, \&TranslationLinkInit);

my %TranslationLinkData;

sub TranslationLinkInit {
  $TranslationLinkPattern = '\[\[(' . join('|', keys %Languages) . '):(';
  $TranslationLinkPattern .= $FreeLinkPattern if $FreeLinks;
  $TranslationLinkPattern .= '|' if $FreeLinks or $WikiLinks;
  $TranslationLinkPattern .= $LinkPattern if $WikiLinks;
  $TranslationLinkPattern .= ')\]\]';
  my $text = GetPageContent(FreeToNormal(GetId()));
  %TranslationLinkData = ();
}

=head2 TranslationLinkRule

The translation links will not be rendered, that is text such as
C<[[en:HomePage]]> does not produce any HTML output directly. We will
collect the translation links as we go, however, and store them in our
C<%Page> which will be saved to disk if no HTML cache exists.

=cut

push(@MyRules, \&TranslationLinkRule);

sub TranslationLinkRule {
  if (m/\G$TranslationLinkPattern/cog) {
    $TranslationLinkData{$1} = $2;
    $Page{translations} = join($FS, %TranslationLinkData);
    return '';
  }
  return undef;
}

=head2 Footer Links

We hook into C<GetFooterLinks> and print a line of translations, as
well as a link to the translate action.

=cut

*TranslationLinkOldGetFooterLinks = *GetFooterLinks;
*GetFooterLinks = *TranslationLinkNewGetFooterLinks;

sub TranslationLinkNewGetFooterLinks {
  my $html = TranslationLinkOldGetFooterLinks(@_);
  my ($id, $rev) = @_;
  if ($id and not $rev) {
    OpenPage($id);
    my $bar;
    my %translations;
    if ($Page{translations}) {
      %translations = split(/$FS/, $Page{translations});
      $bar = join(' ', map {
	my $url;
	if ($TranslationLinkTarget{$_}) {
	  $url = $TranslationLinkTarget{$_};
	  $url =~ s/\%s/$translations{$_}/g or $url .= $translations{$_};
	} else {
	  $url = ScriptUrl($translations{$_});
	}
	$q->a({-href=>$url, -class=>"translation $_"}, T($_));
      } keys %translations);
    }
    my %missing;
    foreach (keys %Languages) {
      if (not $translations{$_}) {
	$missing{$_} = 1;
      }
    }
    # If the current page is autodetected to have exactly one
    # translation, then remove that language from the list of missing
    # languages.
    my @current = split(/,/, $Page{languages});
    if ($#current == 0) {
      delete $missing{$current[0]};
    }
    if (scalar keys %missing) {
      $bar .= ' ' . ScriptLink("action=translate;id=$id;missing="
			       . join('_', sort keys %missing),
			       T('Add Translation'), 'translation new');
    }
    $html = $q->span({-class=>'translation bar'}, $q->br(), $bar) . $html;
  }
  return $html;
}

=head2 Translate Action

The translate action knows what page the user is trying to translate,
and it knows what translations seem to be missing. By selecting the
appropriate checkbox, a translation link will be added to the source
page.

=cut

$Action{translate} = \&DoTranslationLink;

sub DoTranslationLink {
  my $source = shift;
  my $target = FreeToNormal(GetParam('target', ''));
  my $error = ValidId($target);
  my $lang = GetParam('translation', '');
  if (not $error and $lang) {
    OpenPage(FreeToNormal($source));
    Save($OpenPageName, "[[$lang:$target]]\n" . $Page{text},
	 Tss('Added translation: %1 (%2)',
	     NormalToFree($target), T($lang)), 1);
    DoEdit($target);
  } else {
    my @missing = split(/_/, GetParam('missing', ''));
    print GetHeader(undef, Ts('Translate %s', NormalToFree($source)));
    print $q->start_div({-class=>'content translate'}), GetFormStart();
    print $q->p(Ts('Thank you for writing a translation of %s.', $source),
	        T('Please indicate what language you will be using.'));
    if (defined $q->param('target') and not $lang) {
      print $q->div({-class=>'message'}, $q->p(T('Language is missing')));
    }
    print $q->p(T('Suggested languages:')),
      $q->p($q->radio_group(-name=>'translation',
			    -values=>\@missing,
			    -linebreak=>'true',
			    -labels=>\%Translate));
    print $q->p(Ts('Please indicate a page name for the translation of %s.',
		   $source),
	        Ts('More help may be available here: %s.',
		   GetPageLink($TranslationLinkHelpPage)));
    if (defined $q->param('target') and $error) {
      print $q->div({-class=>'message'}, $q->p($error));
    }
    print $q->p($q->label({-for=>'target'}, T('Translated page: ')),
		$q->textfield('target', '', 40),
		$q->hidden('action', 'translate'),
		$q->hidden('id', $source),
		$q->hidden('missing', GetParam('missing', '')),
		$q->submit('dotranslate', T('Go!')));
    print $q->endform, $q->end_div();
    PrintFooter();
  }
}
