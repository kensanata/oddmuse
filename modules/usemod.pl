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

$ModulesDescription .= '<p>$Id: usemod.pl,v 1.5 2004/08/07 00:44:40 as Exp $</p>';

use vars qw($RFCPattern $ISBNPattern @HtmlTags $HtmlTags $HtmlLinks $RawHtml);

push(@MyRules, \&UsemodRule);
# The ---- rule conflicts with the --- rule in markup.pl and portrait-support.pl
# The == heading rule conflicts with the same rule in portrait-support.pl
$RuleOrder{\&UsemodRule} = 100;

$RFCPattern = "RFC\\s?(\\d+)";
$ISBNPattern = 'ISBN:?([0-9- xX]{10,})';
$HtmlLinks   = 0;   # 1 = <a href="foo">desc</a> is a link
$RawHtml     = 0;   # 1 = allow <HTML> environment for raw HTML inclusion
@HtmlTags    = ();  # List of HTML tags.  If not set, determined by $HtmlTags
$HtmlTags    = 0;   # 1 = allow some 'unsafe' HTML tags

*OldUsemodInitVariables = *InitVariables;
*InitVariables = *NewUsemodInitVariables;

sub NewUsemodInitVariables {
  OldUsemodInitVariables();
  if (not @HtmlTags) { # do not override settings in the config file
    if ($HtmlTags) {   # allow many tags
      @HtmlTags = qw(b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
		     em s strike strong tt var div center blockquote ol ul dl
		     table caption br p hr li dt dd tr td th);
    } else {	       # only allow a very small subset
      @HtmlTags = qw(b i u em strong tt);
    }
  }
}

my $htmlre;

sub UsemodRule {
  my $htmlre = join('|',(@HtmlTags)) unless $htmlre;
  # <pre> for monospaced, preformatted and escaped
  if ($bol && m/\G&lt;pre&gt;\n?(.*?\n)&lt;\/pre&gt;[ \t]*\n?/cgs) {
    return CloseHtmlEnvironments() . $q->pre({-class=>'real'}, $1);
  }
  # <code> for monospaced and escaped
  elsif (m/\G\&lt;code\&gt;(.*?)\&lt;\/code\&gt;/cgis) { return $q->code($1); }
  # <nowiki> for escaped
  elsif (m/\G\&lt;nowiki\&gt;(.*?)\&lt;\/nowiki\&gt;/cgis) { return $1; }
  # whitespace for monospaced, preformatted and escaped
  elsif ($bol && m/\G(\s*\n)*([ \t]+(.+\n)*.*)/cg) {
    return OpenHtmlEnvironment('pre',1) . $2; # always level 1
  }
  # numbered lists using #
  elsif ($bol && m/\G(\s*\n)*(\#+)[ \t]+/cg
	 or $HtmlStack[0] eq 'li' && m/\G(\s*\n)+(\#+)[ \t]*/cg) {
    return OpenHtmlEnvironment('ol',length($2)) . AddHtmlEnvironment('li');
  }
  # indented text using :
  elsif ($bol && m/\G(\s*\n)*(\:+)[ \t]+/cg
	 or $HtmlStack[0] eq 'dd' && m/\G(\s*\n)+(\:+)[ \t]*/cg) { # blockquote instead?
    return OpenHtmlEnvironment('dl',length($2), 'quote')
      . $q->dt() . AddHtmlEnvironment('dd');
  }
  # definition lists using ;
  elsif ($bol && m/\G(\s*\n)*(\;+)[ \t]+(?=.*\:)/cg
	 or $HtmlStack[0] eq 'dd' && m/\G(\s*\n)+(\;+)[ \t]*(?=.*\:)/cg) {
    return OpenHtmlEnvironment('dl',length($2))
      . AddHtmlEnvironment('dt'); # `:' needs special treatment, later
  } elsif (defined $HtmlStack[0] && $HtmlStack[0] eq 'dt'
	   && m/\G:/cg) {
    return CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  }
  # headings using =
  elsif ($bol && m/\G(\s*\n)*(\=+)[ \t]*(.+?)[ \t]*(=+)[ \t]*\n?/cg) {
    return CloseHtmlEnvironments() . WikiHeading($2, $3);
  }
  # horizontal lines using ----
  elsif ($bol && m/\G(\s*\n)*----+[ \t]*\n?/cg) {
    return CloseHtmlEnvironments() . $q->hr();
  }
  # tables using ||
  elsif ($bol && m/\G(\s*\n)*((\|\|)+)[ \t]*(?=.*\|\|[ \t]*(\n|$))/cg) {
    return OpenHtmlEnvironment('table',1,'user')	# `||' needs special treatment, later
      . AddHtmlEnvironment('tr')
      . ((length($2) == 2)
	 ? AddHtmlEnvironment('td')
	 : AddHtmlEnvironment('td', 'colspan="' . length($2)/2 . '"'));
  } elsif (defined $HtmlStack[0] && $HtmlStack[0] eq 'td'
	   && m/\G[ \t]*((\|\|)+)[ \t]*\n((\|\|)+)[ \t]*/cg) {
    return '</td></tr><tr>' . ((length($3) == 2)
			       ? '<td>' : ('<td colspan="' . length($3)/2 . '">'));
  } elsif (defined $HtmlStack[0] && $HtmlStack[0] eq 'td'
	   && m/\G[ \t]*((\|\|)+)[ \t]*(?!(\n|$))/cg) { # continued
    return '</td>' . ((length($1) == 2) ?
		      '<td>' : ('<td colspan="' . length($1)/2 . '">'));
  } elsif (defined $HtmlStack[0] && $HtmlStack[0] eq 'td'
	   && m/\G[ \t]*((\|\|)+)[ \t]*/cg) { # at the end of the table
    return CloseHtmlEnvironments();
  }
  # RFC
  elsif (m/\G$RFCPattern/cog) { return &RFC($1); }
  # ISBN -- dirty because the URL translations will change
  elsif (m/\G($ISBNPattern)/cog) { Dirty($1); print ISBN($2); return ''; }
  # emphasis and strong emphasis using '' and '''
  elsif (defined $HtmlStack[0] && $HtmlStack[1] && $HtmlStack[0] eq 'em'
	 && $HtmlStack[1] eq 'strong' and m/\G'''''/cg) { # close either of the two
    return CloseHtmlEnvironment() . CloseHtmlEnvironment();
  } elsif (m/\G'''/cg) { # traditional wiki syntax for '''strong'''
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'strong')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('strong');
  } elsif (m/\G''/cg) { # traditional wiki syntax for ''emph''
    return (defined $HtmlStack[0] && $HtmlStack[0] eq 'em')
      ? CloseHtmlEnvironment() : AddHtmlEnvironment('em');
  }
  # <html> for raw html
  elsif ($RawHtml && m/\G\&lt;html\&gt;(.*?)\&lt;\/html\&gt;/cgis) { 
    return UnquoteHtml($1);
  }
  # miscellaneous html tags
  elsif (m/\G\&lt;($htmlre)\&gt;/cogi) { return AddHtmlEnvironment($1); }
  elsif (m/\G\&lt;\/($htmlre)\&gt;/cogi) { return CloseHtmlEnvironment($1); }
  elsif (m/\G\&lt;($htmlre) *\/\&gt;/cogi) { return "<$1 />"; }
  # <a href="...">...</a> for html links
  elsif ($HtmlLinks && m/\G\&lt;a(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/cgi) { # <a ...>text</a>
    return "<a$1>$2</a>";
  }
  return undef;
}

sub WikiHeading {
  my ($depth, $text) = @_;
  $depth = length($depth);
  $depth = 6  if ($depth > 6);
  return "<h$depth>$text</h$depth>";
}

sub RFC {
  my $num = shift;
  return $q->a({-href=>"http://www.faqs.org/rfcs/rfc${num}.html"}, "RFC $num");
}

sub ISBN {
  my $rawnum = shift;
  my ($rawprint, $html, $num, $first, $second, $third);
  $num = $rawnum;
  $rawprint = $rawnum;
  $rawprint =~ s/ +$//;
  $num =~ s/[- ]//g;
  if (length($num) != 10) {
    return "ISBN $rawnum";
  }
  $first  = $q->a({-href => Ts('http://shop.barnesandnoble.com/bookSearch/isbnInquiry.asp?isbn=%s', $num)},
		  "ISBN " . $rawprint);
  $second = $q->a({-href => Ts('http://www.amazon.com/exec/obidos/ISBN=%s', $num)},
		  T('alternate'));
  $third  = $q->a({-href => Ts('http://www.pricescan.com/books/BookDetail.asp?isbn=%s', $num)},
		  T('search'));
  $html	 = "$first ($second, $third)";
  $html .= ' '	if ($rawnum =~ / $/);  # Add space if old ISBN had space.
  return $html;
}
