# Copyright (C) 2003, 2004  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2004  Haixing Hu <huhaixing@msn.com>
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

# External programs needed
# dvipng  - http://sourceforge.net/projects/dvipng/
# LaTeX   - http://www.latex-project.org
# TeX     - http://www.tug.org/teTeX/

use vars qw($LatexDir $LatexLinkDir $LatexExtendPath $LatexSingleDollars);

my $dvipng = "/usr/bin/dvipng";

$ModulesDescription .= '<p>$Id: latex.pl,v 1.9 2004/10/04 02:58:29 tolchz Exp $</p>';

# PATH must be extended in order to make latex available along with
# any binaries that they may need to work

$LatexExtendPath = ':/usr/share/texmf/bin:/usr/bin:/usr/local/bin';


# $LatexDir must be accessible from the outside as $LatexLinkDir.  The
# first directory is used to *save* the pictures, the second directory
# is used to produce the *link* to the pictures.

# Example: You store the images in /org/org.emacswiki/htdocs/test/latex.
# This directory is reachable from the outside as http://www.emacswiki.org/test/latex/.
# /org/org.emacswiki/htdocs/test is your $DataDir.

$LatexDir    = "$DataDir/latex";
$LatexLinkDir= "/wiki/latex";

$LatexSingleDollars = 0;

# You also need a template stored as $DataDir/template.latex.  The
# template must contain the string <math> where the LaTeX code is
# supposed to go.  It will be created on the first run.

my $LatexDefaultTemplateName = "$LatexDir/template.latex";

my $LatexDefaultTemplate = << 'EOT';
\documentclass[12pt]{article}
\pagestyle{empty}
\begin{document}
<math>
\end{document}
EOT

push(@MyRules, \&LatexRule);

sub LatexRule {
  if (m/\G\\\[((.*\n)*?)\\\]/gc) {
    return &MakeLaTeX("\$\$ $1 \$\$", "display math");
  } elsif (m/\G\$\$((.*\n)*?.*?)\$\$/gc) {
    return &MakeLaTeX("\$\$ $1 \$\$", $LatexSingleDollars ? "display math" : "inline math");
  } elsif ($LatexSingleDollars and m/\G\$((.*\n)*?.*?)\$/gc) {
    return &MakeLaTeX("\$ $1 \$", "inline math");
  }
  return undef;
}

sub MakeLaTeX {
  my ($latex, $type) = @_;
  $ENV{PATH} .= $LatexExtendPath if $LatexExtendPath and $ENV{PATH} !~ /$LatexExtendPath/;

  if (not -e $dvipng) {
      return "[Error: dvipng binary not found at $dvipng]";
  }

  $latex = UnquoteHtml($latex); # Change &lt; back to <, for example
  my $hash = UrlEncode($latex);
  $hash =~ s/%//g;
  # check cache
  if (-f "$LatexDir/$hash.png"
      and not -z "$LatexDir/$hash.png") {
    if ($type eq "inline math") { # inline math
      return ("<img class='InlineMath' "
              ."src='$LatexLinkDir/$hash.png' alt='$latex'\/>");
    } elsif ($type eq "display math") { # display math
      return ("<center><img class='DisplayMath' "
             ."src='$LatexLinkDir/$hash.png' alt='$latex'><\/center>");
    } else {  # latex format
      return ("<img class='LaTeX' "
             ."src='$LatexLinkDir/$hash.png' alt='$latex' \/>");
    }
  }
  # read template and replace <math>
  mkdir($LatexDir) unless -d $LatexDir;
  if (not -f $LatexDefaultTemplateName) {
    open (F, "> $LatexDefaultTemplateName") or return '[Unable to write template]';
    print F $LatexDefaultTemplate;
    close (F);
  }
  my $template = ReadFileOrDie($LatexDefaultTemplateName);
  $template =~ s/<math>/$latex/ig;
  #setup rendering directory
  my $dir = "$LatexDir/$hash";
  if (-d $dir) {
    unlink (glob('$dir/*'));
  } else {
    mkdir($dir) or return "[Unable to create $dir]";
  }
  chdir ($dir) or return "[Unable to switch to $dir]";
  WriteStringToFile ("srender.tex", $template);
  qx(latex srender.tex);
  return "[Illegal LaTeX markup: <pre>$latex</pre>]" if $?;
  my $output = qx($dvipng -T tight -bg Transparent srender.dvi);
  return "[dvipng error $? ($output)]" if $?;
  my $result;
  if (-f 'srender1.png' and not -z 'srender1.png') {
    my $png = ReadFileOrDie("srender1.png");
    WriteStringToFile ("$LatexDir/$hash.png", $png);
    if ($type eq "inline math") {
      $result = "<img class='InlineMath' "
                ."src='$LatexLinkDir/$hash.png' alt='$latex'\/>";
    } elsif ($type eq "display math") {
      $result = "<center><img class='DisplayMath'"
               ."src='$LatexLinkDir/$hash.png' alt='$latex'><\/center>";    
    } else { # latex format
      return ("<img class='LaTeX' "
                   ."src='$LatexLinkDir/$hash.png' alt='$latex' \/>");	   
    }
  } else {
    $result = "[Error retrieving image for $latex]";
  }
  unlink (glob('*'));
  chdir ($LatexDir);
  rmdir ($dir);
  return $result;
}
