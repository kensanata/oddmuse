# Copyright (C) 2003, 2004  Alex Schroeder <alex@emacswiki.org>
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

use vars qw($LatexDir $LatexLinkDir $LatexExtendPath);

$ModulesDescription .= '<p>$Id: latex.pl,v 1.1 2004/02/13 18:34:18 as Exp $</p>';

# PATH must be extended in order to make dvi2bitmap available, and
# also all the programs that dvi2bitmap may call to do its work
# (namely mkdir, rm, kpathsea and mktexpk).

# You need /bin since dvi2bitmap uses mkdir and rm that are in /bin
# And you need /usr/share/texmf/bin to be able to use mktexpk.  And
# you need /usr/bin because that's where the latex executable is,
# probably.  This variable is appended to the PATH.

$LatexExtendPath = ':/bin:/usr/bin:/usr/share/texmf/bin';

# $LatexDir must be accessible from the outside as $LatexLinkDir.  The
# first directory is used to *save* the pictures, the second directory
# is used to produce the *link* to the pictures.

# Example: You store the images in /org/org.emacswiki/htdocs/test/latex.
# This directory is reachable from the outside as http://www.emacswiki.org/test/latex/.
# /org/org.emacswiki/htdocs/test is your $DataDir.

$LatexDir    = "$DataDir/latex";
$LatexLinkDir= "/test/latex";

# You also need a template stored as $DataDir/template.latex.  The
# template must contain the string <math> where the LaTeX code is
# supposed to go.

push(@MyRules, \&LatexRule);

sub LatexRule {
  if (m/\G\$\$(.*?)\$\$/gc) {
    return &MakeLaTeX($1);
  }
  return '';
}

sub MakeLaTeX {
  my ($latex) = @_;
  $ENV{PATH} .= $LatexExtendPath if $LatexExtendPath and $ENV{PATH} !~ /$LatexExtendPath/;
  $latex = UnquoteHtml($latex); # Change &lt; back to <, for example
  my $hash = UrlEncode($latex);
  $hash =~ s/%//g;
  # check cache
  if (-f "$LatexDir/$hash.png"
      and not -z "$LatexDir/$hash.png") {
    return ("<img border=0 src=\"$LatexLinkDir/$hash.png\" alt=\"$latex\">");
  }
  # read template and replace <math>
  mkdir($LatexDir) unless -d $LatexDir;
  local $/ = undef;   # Read complete files
  open (F,"$DataDir/template.latex") or return '[Unable to open template.latex]';
  my $template = <F>;
  close F;
  $template =~ s/<math>/$latex/ig;
  #setup rendering directory
  my $dir = "$LatexDir/$hash";
  if (-d $dir) {
    unlink (glob('$dir/*'));
  } else {
    mkdir($dir) or return "[Unable to create $dir]";
  }
  chdir ($dir) or return "[Unable to switch to $dir]";
  open (F, ">srender.tex") or return '[Unable to copy template.latex to working directory]';
  print F $template;
  close (F);
  qx(latex srender.tex);
  return "[Illegal LaTeX markup: $latex]" if $?;
  qx(dvi2bitmap -t png srender.dvi);
  return "[dvi2bitmap returned with status: $?]" if $?;
  my $result;
  if (-f 'srender-page1.png' and not -z 'srender-page1.png') {
    open (F, "srender-page1.png") or return '[Unable to read result image]';
    my $png = <F>;
    close (F);
    open (F, ">$LatexDir/$hash.png") or return '[Unable to copy result image back]';
    print F $png;
    close (F);
    $result = "<img border=0 src=\"$LatexLinkDir/$hash.png\" alt=\"$latex\">";
  } else {
    $result = "[Error retrieving image for $latex]";
  }
  unlink (glob('*'));
  chdir ($LatexDir);
  rmdir ($dir);
  return $result;
}
