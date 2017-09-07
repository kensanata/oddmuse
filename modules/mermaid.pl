#! /usr/bin/perl
# Copyright (C) 2017  Alex Schroeder <alex@gnu.org>

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

use strict;
use v5.10;

AddModuleDescription('mermaid.pl', 'Mermaid for Diagrams');

our ($bol, @MyRules, $MermaidCss, $MermaidJs, $HtmlHeaders, %Page);

$MermaidCss = '/mermaid/mermaid.css';
$MermaidJs = '/mermaid/mermaid.min.js';

# When browsing a page containing mermaid markup, load the mermaid Javascript and CSS

*MermaidOldBrowsePage = *BrowsePage;
*BrowsePage = *MermaidNewBrowsePage;

sub MermaidNewBrowsePage {
  my ($id) = @_;
  OpenPage($id);
  # Uses <mermaid> to render graphs
  if ($Page{text} =~ /<mermaid>/
      and $HtmlHeaders !~ /mermaid/) {
    $HtmlHeaders .= qq{
<link type="text/css" rel="stylesheet" href="$MermaidCss" />
<script type="text/javascript" src="$MermaidJs"></script>
};
  }
  return MermaidOldBrowsePage(@_);
}

# When previewing an edit containing mermaid markup, load the mermaid Javascript
# and CSS

*MermaidOldDoEdit = *DoEdit;
*DoEdit = *MermaidNewDoEdit;

sub MermaidNewDoEdit {
  # Uses <mermaid> to render graphs
  if (GetParam('text') =~ /&lt;mermaid&gt;/
      and $HtmlHeaders !~ /mermaid/) {
    $HtmlHeaders = q{
<link rel="stylesheet" href="/mermaid/mermaid.css" />
<script type="text/javascript" src="/mermaid/mermaid.min.js"></script>
};
  }
  return MermaidOldDoEdit(@_);
}

# And a formatting rule, of course.

push(@MyRules, \&MermaidRule);

sub MermaidRule {
  if ($bol && m/\G\&lt;mermaid\&gt;\n(.+?)\n\&lt;\/mermaid\&gt;/cgs) {
    return CloseHtmlEnvironments()
        . '<div class="mermaid">' . UrlDecode($1) . '</div>';
  }
  return undef;
}
