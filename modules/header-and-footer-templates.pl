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

$ModulesDescription .= '<p>$Id: header-and-footer-templates.pl,v 1.3 2004/12/25 21:54:15 as Exp $</p>';

use vars qw($HtmlTemplateDir);
use HTML::Template;

$HtmlTemplateDir   = "$DataDir/templates";

sub HtmlTemplateLanguage {
  my $requested_language = $q->http('Accept-language');
  my @languages = split(/ *, */, $requested_language);
  my %Lang = ();
  foreach $_ (@languages) {
    my $qual = 1;
    $qual = $1 if (/q=([0-9.]+)/);
    $Lang{$qual} = $1 if (/^([-a-z]+)/);
  }
  return map { $Lang{$_} } sort { $b <=> $a } keys %Lang;
}

sub HtmlTemplate {
  my $type = shift;
  # return header.de.html, or header.html, or error.html, or report an error...
  foreach my $f ((map { "$type.$_" } HtmlTemplateLanguage()), $type, "error") {
    return "$HtmlTemplateDir/$f.html" if -r "$HtmlTemplateDir/$f.html";
  }
  ReportError(Tss('Could not find %1.html template in %2', $type, $HtmlTemplateDir),
	      '500 INTERNAL SERVER ERROR');
}

sub GetSpecialDays {
  if (%SpecialDays) {
    my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($Now);
    return $SpecialDays{($mon + 1) . '-' . $mday};
  }
}

*GetHeader = *HeaderTemplate;

sub HeaderTemplate {
  my ($id, $title, $oldId, $nocache, $status) = @_;
  if ($oldId ne '') {
    $Message .= $q->p('(' . Ts('redirected from %s', GetEditLink($oldId, $oldId)) . ')');
  }
  my $template = HTML::Template->new(filename => HtmlTemplate('header'),
				     die_on_bad_params => 0);
  $template->param(GOTO_BAR => GetGotoBar($id));
  $template->param(SPECIAL_DAYS => GetSpecialDays());
  $template->param(MESSAGE => $Message);
  $template->param(ID => $id);
  $template->param(TITLE => $title);
  $template->param(SEARCH => GetSearchForm());
  return GetHttpHeader('text/html', $nocache ? $Now : 0, $status)
    . $template->output;
}

*PrintFooter = *PrintFooterTemplate;

sub PrintFooterTemplate {
  my ($id, $rev, $comment) = @_;
  my $template = HTML::Template->new(filename => HtmlTemplate('footer'),
				     die_on_bad_params => 0);
  $template->param(GOTO_BAR => GetGotoBar($id));
  $template->param(SPECIAL_DAYS => GetSpecialDays());
  $template->param(ID => $id);
  $template->param(COMMENT_FORM => GetCommentForm($id, $rev, $comment));
  $template->param(FOOTER_LINKS => GetFooterLinks($id, $rev));
  $template->param(ADMIN_LINKS => GetAdminBar($id, $rev)) if UserIsAdmin();
  $template->param(TIMESTAMP => GetFooterTimestamp($id, $rev));
  $template->param(SEARCH => GetSearchForm());
  $template->param(SISTER_SITES => GetSisterSites($id));
  $template->param(NEAR_LINKS_USED => GetNearLinksUsed($id));
  print $template->output;
}
