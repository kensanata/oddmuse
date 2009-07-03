#!/usr/bin/env perl
# ====================[ usemod.pl                          ]====================
$ModulesDescription .= '<p>$Id: usemod.pl,v 1.37 2009/07/03 14:04:45 as Exp $</p>';

use vars qw($RFCPattern $ISBNPattern @HtmlTags $HtmlTags $HtmlLinks $RawHtml
      $UseModSpaceRequired $UseModMarkupInTitles);

push(@MyRules, \&UsemodRule);
# The ---- rule conflicts with the --- rule in markup.pl and portrait-support.pl
# The == heading rule conflicts with the same rule in portrait-support.pl
# The : indentation rule conflicts with a similar rule in portrait-support.pl
$RuleOrder{\&UsemodRule} = 100;

$RFCPattern  = 'RFC\\s?(\\d+)';
$ISBNPattern = 'ISBN:?([0-9- xX]{10,14})';
$HtmlLinks   = 0;   # 1 = <a href="foo">desc</a> is a link
$RawHtml     = 0;   # 1 = allow <HTML> environment for raw HTML inclusion
@HtmlTags    = ();  # List of HTML tags.  If not set, determined by $HtmlTags
$HtmlTags    = 0;   # 1 = allow some 'unsafe' HTML tags
$UseModSpaceRequired = 1;  # 1 = require space after * # : ; for lists.
$UseModMarkupInTitles = 0; # 1 = may use links and other markup in ==titles==

# do this later so that the user can customize some vars
push(@MyInitVariables, \&UsemodInit);

sub UsemodInit {
  if (not @HtmlTags) {   # do not override settings in the config file
    if ($HtmlTags) {    # allow many tags
      @HtmlTags = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
         em s strike strong tt var div center blockquote ol ul dl
         table caption br p hr li dt dd tr td th);
    } else {      # only allow a very small subset
      @HtmlTags = qw(b i u em strong tt);
    }
  }
}

my $UsemodHtmlRegExp;
my $rowcount;

sub UsemodRule {
  $UsemodHtmlRegExp = join('|',(@HtmlTags)) unless $UsemodHtmlRegExp;
  # <pre> for monospaced, preformatted and escaped
  if ($bol && m/\G&lt;pre&gt;\n?(.*?\n)&lt;\/pre&gt;[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1) . AddHtmlEnvironment('p');
  }
  # <code> for monospaced and escaped
  elsif (m/\G\&lt;code\&gt;(.*?)\&lt;\/code\&gt;/cgis) { return $q->code($1); }
  # <nowiki> for escaped
  elsif (m/\G\&lt;nowiki\&gt;(.*?)\&lt;\/nowiki\&gt;/cgis) { return $1; }
  # whitespace for monospaced, preformatted and escaped, all clean
  # note that ([ \t]+(.+\n)*.*) seems to crash very long blocks (2000 lines and more)
  elsif ($bol && m/\G(\s*\n)*([ \t]+.+)\n?/gc) {
    my $str = $2;
    while (m/\G([ \t]+.*)\n?/gc) {
      $str .= "\n" . $1;
    }
    return OpenHtmlEnvironment('pre',1) . $str; # always level 1
  }
  # unumbered lists using *
  elsif ($bol && m/\G(\s*\n)*(\*+)[ \t]{$UseModSpaceRequired,}/cog
	 or InElement('li') && m/\G(\s*\n)+(\*+)[ \t]{$UseModSpaceRequired,}/cog) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ul',length($2))
      . AddHtmlEnvironment('li');
  }
  # numbered lists using #
  elsif ($bol && m/\G(\s*\n)*(\#+)[ \t]{$UseModSpaceRequired,}/cog
	 or InElement('li') && m/\G(\s*\n)+(\#+)[ \t]{$UseModSpaceRequired,}/cog) {
    return CloseHtmlEnvironmentUntil('li') . OpenHtmlEnvironment('ol',length($2))
      . AddHtmlEnvironment('li');
  }
  # indented text using : (use blockquote instead?)
  elsif ($bol && m/\G(\s*\n)*(\:+)[ \t]{$UseModSpaceRequired,}/cog
	 or InElement('dd') && m/\G(\s*\n)+(\:+)[ \t]{$UseModSpaceRequired,}/cog) {
    return CloseHtmlEnvironmentUntil('dd') . OpenHtmlEnvironment('dl',length($2), 'quote')
      . $q->dt() . AddHtmlEnvironment('dd');
  }
  # definition lists using ;
  elsif (($bol and m/\G(\s*\n)*(\;+)[ \t]{$UseModSpaceRequired,}(?=.*\:)/cog) or
         (InElement('dd') and m/\G(\s*\n)+(\;+)[ \t]{$UseModSpaceRequired,}(?=.*\:)/cog)) {
    return CloseHtmlEnvironmentUntil('dd')
      .OpenHtmlEnvironment('dl', length($2))
      .AddHtmlEnvironment('dt');  # `:' needs special treatment, later
  }
  elsif (InElement('dt') and m/\G:[ \t]*/cg) {
    return CloseHtmlEnvironmentUntil('dt')
      .CloseHtmlEnvironment()
      .AddHtmlEnvironment('dd');
  }
  # headings using = (with lookahead)
  elsif ($bol && $UseModMarkupInTitles
	 && m/\G(\s*\n)*(\=+)[ \t]*(?=[^=\n]+=)/cg) {
    my $depth = length($2);
    $depth = 6 if $depth > 6;
    $depth = 2 if $depth < 2;
    my $html = CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '')
      . AddHtmlEnvironment('h' . $depth);
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  } elsif ($UseModMarkupInTitles
	   && (InElement('h1') || InElement('h2') || InElement('h3')
	       || InElement('h4') || InElement('h5') || InElement('h6'))
	   && m/\G[ \t]*=+\n?/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  } elsif ($bol && !$UseModMarkupInTitles
	   && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=+)[ \t]*\n?/cg) {
    my $html = CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '')
      . WikiHeading($2, $3) . AddHtmlEnvironment('p');
    $PortraitSupportColorDiv = 0; # after the HTML has been determined.
    $PortraitSupportColor = 0;
    return $html;
  }
  # horizontal lines using ----
  elsif ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg) {
    my $html = CloseHtmlEnvironments() . ($PortraitSupportColorDiv ? '</div>' : '')
      . $q->hr() . AddHtmlEnvironment('p');
    $PortraitSupportColorDiv = 0;
    $PortraitSupportColor = 0;
    return $html;
  }
  # tables using || -- the first row of a table
  elsif ($bol && m/\G(\s*\n)*((\|\|)+)([ \t])*(?=.*\|\|[ \t]*(\n|$))/cg) {
    $rowcount = 1;
    return OpenHtmlEnvironment('table',1,'user')
      . AddHtmlEnvironment('tr', 'class="odd first"')
      . AddHtmlEnvironment('td', UsemodTableAttributes(length($2)/2, $4));
  }
  # tables using || -- end of the row and beginning of the next row
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)([ \t]*)/cg) {
    my $attr = UsemodTableAttributes(length($3)/2, $5);
    my $type = ++$rowcount % 2 ? 'odd' : 'even';
    $attr = " " . $attr if $attr;
    return qq{</td></tr><tr class="$type"><td$attr>};
  }
  # tables using || -- an ordinary table cell
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)([ \t]*)(?!(\n|$))/cg) {
    my $attr = UsemodTableAttributes(length($1)/2, $3);
    $attr = " " . $attr if $attr;
    return "</td><td$attr>";
  }
  # tables using || -- since "next row" was taken care of above, this must be the last row
  elsif (InElement('td') && m/\G[ \t]*((\|\|)+)[ \t]*/cg) {
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  }
  # RFC
  elsif (m/\G$RFCPattern/cog) { return &RFC($1); }
  # ISBN -- dirty because the URL translations will change
  elsif (m/\G($ISBNPattern)/cog) { Dirty($1); print ISBN($2); return ''; }
  # traditional wiki syntax closure for bold italic'''''
  elsif (InElement('strong') and InElement('em') and m/\G'''''/cg) { # close both
    return CloseHtmlEnvironment('strong').CloseHtmlEnvironment('em');
  }
  # traditional wiki syntax for '''bold'''
  elsif (m/\G'''/cg) { return AddOrCloseHtmlEnvironment('strong'); }
  # traditional wiki syntax for ''italic''
  elsif (m/\G''/cg ) { return AddOrCloseHtmlEnvironment('em'); }
  # <html> for raw html
  elsif ($RawHtml && m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgis) {
    return UnquoteHtml($1);
  }
  # miscellaneous html tags
  elsif (m/\G\&lt;($UsemodHtmlRegExp)(\s+[^<>]*?)?\&gt;/cogi) { 
    return AddHtmlEnvironment($1, $2); }
  elsif (m/\G\&lt;\/($UsemodHtmlRegExp)\&gt;/cogi) {
    return CloseHtmlEnvironment($1); }
  elsif (m/\G\&lt;($UsemodHtmlRegExp) *\/\&gt;/cogi) {
    return "<$1 />"; }
  # <a ...>text</a> for html links
  elsif ($HtmlLinks && m/\G\&lt;a(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/cgi) {
    return "<a$1>$2</a>";
  }
  return undef;
}

sub UsemodTableAttributes {
  my ($span, $left, $right) = @_;
  my $attr = '';
  $attr = "colspan=\"$span\"" if ($span != 1);
  m/\G(?=.*?([ \t]*)\|\|)/;
  $right = $1;
  $attr .= ' ' if ($attr and ($left or $right));
  if ($left and $right) { $attr .= 'align="center"' }
  elsif ($left ) { $attr .= 'align="right"' }
  elsif ($right) { $attr .= 'align="left"' }
  return $attr;
}

sub WikiHeading {
  my ($depth, $text) = @_;
  $depth = length($depth);
  $depth = 6 if $depth > 6;
  $depth = 2 if $depth < 2;
  return "<h$depth>$text</h$depth>";
}

sub RFC {
  my $num = shift;
  return $q->a({-href=>"http://tools.ietf.org/html/rfc${num}"}, "RFC $num");
}

sub ISBN {
  my $rawnum = shift;
  my $num = $rawnum;
  my $rawprint = $rawnum;
  $rawprint =~ s/ +$//;
  $num =~ s/[- ]//g;
  my $len = length($num);
  return "ISBN $rawnum" unless $len == 10 or $len == 13 or $len = 14; # be prepared for 2007-01-01
  my $first  = $q->a({-href => Ts('http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s', $num)},
      "ISBN " . $rawprint);
  my $second = $q->a({-href => Ts('http://www.amazon.com/exec/obidos/ISBN=%s', $num)},
      T('alternate'));
  my $third  = $q->a({-href => Ts('http://www.pricescan.com/books/BookDetail.asp?isbn=%s', $num)},
      T('search'));
  my $html = "$first ($second, $third)";
  $html .= ' '  if ($rawnum =~ / $/);  # Add space if old ISBN had space.
  return $html;
}

=head1 COPYRIGHT AND LICENSE

The information below applies to everything in this distribution,
except where noted.

Copyleft  2008                         by Brian Curry <http://raiazome.com>.
Copyright 2008                         by Weakish Jiang <weakish@gmail.com>.
Copyright 2004, 2005, 2006, 2007, 2008 by Alex Schroeder <alex@gnu.org>.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut
