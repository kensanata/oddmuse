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

$ModulesDescription .= '<p>$Id: html-template.pl,v 1.5 2004/11/23 23:26:30 as Exp $</p>';

# The entire mechanism of how pages are built is now upside down.
# Instead of writing code that assembles pages, we load templates,
# that refer to pieces of code.
#
# This is the beginning of PHP-in-Perl.  :(

use vars qw($HtmlTemplateDir);

$HtmlTemplateDir   = "$DataDir/templates";

*BrowsePage = *DoHtmlTemplate;

# replace all actions with DoHtmlTemplate!
foreach my $key (keys %Action) {
  $Action{$key} = \&DoHtmlTemplate;
}

sub DoHtmlTemplate {
  my ($id, $raw, $comment, $status) = @_;
  if ($q->http('HTTP_IF_MODIFIED_SINCE')
      and $q->http('HTTP_IF_MODIFIED_SINCE') eq gmtime($LastUpdate)
      and GetParam('cache', $UseCache) >= 2) {
    print $q->header(-status=>'304 NOT MODIFIED');
    return;
  }
  OpenPage($id) if $id;
  print GetHttpHeader('text/html');
  print GetHtmlTemplate();
}

# Some subroutines from the script need a wrapper in order to return a
# string instead of printing directly.

sub HtmlTemplateRc {
  my $result = '';
  local *STDOUT;
  open(STDOUT, '>', \$result) or die "Can't open memory file: $!";
  DoRc(\&GetRcHtml);
  return $result;
}

# Processing instructions are processed as Perl code, and its result
# is substituted.  Examples:
#
# <?&foo?> -- This will call the subroutine &foo.  It's return value
# will be substituted for the processing instruction.
#
# <?$foo?> -- This substitutes the value of variable $foo.
#
# Since the processing instruction is valid XHTML, the template should
# be valid XHTML as well.

sub GetHtmlTemplate {
  my $template = shift || GetActionHtmlTemplate();
  my $html = ReadFileOrDie($template);
  $html =~ s/<\?(.*?)\?>/HtmlTemplateEval($1)/egs;
  return $html;
}

sub HtmlTemplateEval {
  my $code = shift;
  my $result = eval($code) || $@;
}

sub GetActionHtmlTemplate {
  my $action = GetParam('action', 'browse');
  # return browse.de.html, or browse.html, or error.html, or report an error...
  foreach my $f ((map { "$action.$_" } HtmlTemplateLanguage()), $action, "error") {
    return "$HtmlTemplateDir/$f.html" if -r "$HtmlTemplateDir/$f.html";
  }
  ReportError(Tss('Could not find %1.html template in %2', $action, $HtmlTemplateDir),
	      '500 INTERNAL SERVER ERROR');
}

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
