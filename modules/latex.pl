# Copyright (C) 2003, 2004  Alex Schroeder <alex@emacswiki.org>
# Copyright (C) 2004  Haixing Hu <huhaixing@msn.com>
# Copyright (C) 2004, 2005 Todd Neal <tolchz@tolchz.net>
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
#
# External programs needed
# LaTeX   - http://www.latex-project.org
# TeX     - http://www.tug.org/teTeX/
#
# And one of : 
# dvipng  - http://sourceforge.net/projects/dvipng/
# convert - http://www.imagemagick.org/
#
# CSS Styles:
# span.eqCount 
# img.LaTeX
# img.InlineMath
# img.DisplayMath

use vars qw($LatexDir $LatexLinkDir $LatexExtendPath $LatexSingleDollars);

# One of the following options must be set correctly to the full path of
# either dvipng or convert.  If both paths are set correctly, dvipng is used
# instead of convert
my $dvipngPath = "/usr/bin/dvipng";
my $convertPath = "/usr/bin/convert";

# Set $dispErrors to display LaTeX errors inline on the page.
my $dispErrors = 1;

# Set $useMD5 to 1 if you want to use MD5 hashes for filenames, set it to 0 to use 
# a url-encoded hash. If $useMD5 is set and the Digest::MD5 module is not available, 
# latex.pl falls back to urlencode
my $useMD5 = 0;

# PATH must be extended in order to make latex available along with
# any binaries that it may need to work
$LatexExtendPath = ':/usr/share/texmf/bin:/usr/bin:/usr/local/bin';

# Allow single dollars signs to escape LaTeX math commands
$LatexSingleDollars = 0;

# Set $allowPlainTeX to 1 to allow normal LaTeX commands inside of $[ ]$
# to be executed outside of the math environment.  This should only be done
# if your wiki is not publically editable because of the possible security risk
$allowPlainLaTeX = 0;

# $LatexDir must be accessible from the outside as $LatexLinkDir.  The
# first directory is used to *save* the pictures, the second directory
# is used to produce the *link* to the pictures.
#
# Example: You store the images in /org/org.emacswiki/htdocs/test/latex.
# This directory is reachable from the outside as http://www.emacswiki.org/test/latex/.
# /org/org.emacswiki/htdocs/test is your $DataDir.
$LatexDir    = "$DataDir/latex";
$LatexLinkDir= "/wiki/latex";

# Text used when referencing equations with EQ(equationLabel)
my $eqAbbrev = "Eq. ";

# You also need a template stored as $DataDir/template.latex.  The
# template must contain the string <math> where the LaTeX code is
# supposed to go.  It will be created on the first run.
my $LatexDefaultTemplateName = "$LatexDir/template.latex";


$ModulesDescription .= '<p>$Id: latex.pl,v 1.14 2005/03/15 14:50:04 tolchz Exp $</p>';

# Internal Equation counting and referencing variables
my $eqCounter = 0;
my %eqHash;

my $LatexDefaultTemplate = << 'EOT';
\documentclass[12pt]{article}
\pagestyle{empty}
\begin{document}
<math>
\end{document}
EOT

push(@MyRules, \&LatexRule);

sub LatexRule {
  if (m/\G\\\[(\(.*?\))?((.*\n)*?.*?)\\\]/gc) {
    my $label = $1;
    my $latex = $2;
    $label =~ s#\(?\)?##g;# Remove the ()'s from the label and convert case
    $label =~ tr/A-Z/a-z/; 
    $eqCounter++;
    $eqHash{$label} = $eqCounter;
    return &MakeLaTeX("\\begin{displaymath} $latex \\end{displaymath}", "display math",$label);
  } elsif (m/\G\$\$((.*\n)*?.*?)\$\$/gc) {
    return &MakeLaTeX("\$\$ $1 \$\$", $LatexSingleDollars ? "display math" : "inline math");
  } elsif ($LatexSingleDollars and m/\G\$((.*\n)*?.*?)\$/gc) {
    return &MakeLaTeX("\$ $1 \$", "inline math");
  } elsif ($allowPlainLaTeX && m/\G\$\[((.*\n)*?.*?)\]\$/gc) { #Pick up plain LaTeX commands
    return &MakeLaTeX(" $1 ", "LaTeX");   
  } elsif (m/\GEQ\((.*?)\)/gc) { # Handle references to equations
    my $label = $1;
    $label =~ tr/A-Z/a-z/; 
    if ($eqHash{$label}) {
	return $eqAbbrev . "<a href=\"#$label\">". $eqHash{$label} . "</a>";
    }
    else {
	return "[ Equation $label not found ]";
    }
  }
  return undef;
}

sub MakeLaTeX {
  my ($latex, $type, $label) = @_;
  $ENV{PATH} .= $LatexExtendPath if $LatexExtendPath and $ENV{PATH} !~ /$LatexExtendPath/;

  # Select which binary to use for conversion of dvi to images
  my $useConvert = 0; 
  if (not -e $dvipngPath) { 
      if (not -e $convertPath) {
	  return "[Error: dvipng binary and convert binary not found at $dvipngPath or $converPath ]";
      }
      else {  
	  $useConvert = 1; # Fall back on convert if dvipng is missing and convert exists       
      }
  }


  $latex = UnquoteHtml($latex); # Change &lt; back to <, for example
  

  # User selects which hash to use
  my $hash;
  my $hasMD5;
  if ($useMD5)  { $hasMD5 = eval "require Digest::MD5;"; }
  if ($useMD5 && $hasMD5) {
      $hash = Digest::MD5::md5_base64($latex);
      $hash =~ s/\//a/g;
  }  else {
      $hash = UrlEncode($latex);
      $hash =~ s/%//g;
  }
  


  # check cache
  if (not -f "$LatexDir/$hash.png" or -z "$LatexDir/$hash.png") { #If file doesn't exist or is zero bytes
      # Then create the image

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
      my $errorText = qx(latex srender.tex);
      return "[Illegal LaTeX markup: <pre>$latex</pre>] <br/> Error: <pre>$errorText</pre>" if ($? && $dispErrors);
      return "[Illegal LaTeX markup: <pre>$latex</pre>] <br/>" if $?;
      
      my $output;
      
      # Use specified binary to convert dvi to png
      if ($useConvert) { 
	  $output = qx($convertPath -antialias -crop 0x0 -density 120x120 -transparent white srender.dvi srender1.png );
	  return "[convert error $? ($output)]" if $?;
      } else {
	  $output = qx($dvipngPath -T tight -bg Transparent srender.dvi);
	  return "[dvipng error $? ($output)]" if $?;
      }
      
      my $result;
      if (-f 'srender1.png' and not -z 'srender1.png') {
	  my $png = ReadFileOrDie("srender1.png");
	  WriteStringToFile ("$LatexDir/$hash.png", $png);
      } else {	  $result = "[Error retrieving image for $latex]"; }
      
								}
    # Finally print the html for the image
    if ($type eq "inline math") { # inline math
      return ("<img class='InlineMath' "
              ."src='$LatexLinkDir/$hash.png' alt='$latex'\/>");
    } elsif ($type eq "display math") { # display math
	my $ret;
	if ($label) { $ret = "<a name='$label'>"; }
	$ret .= "<center><img class='DisplayMath' "
             ."src='$LatexLinkDir/$hash.png' alt='$latex'> <span class=\'eqCount\'>($eqCounter)</span><\/center>";
	return($ret);
    } else {  # latex format
      return ("<img class='LaTeX' "
             ."src='$LatexLinkDir/$hash.png' alt='$latex' \/>");
	   }								

  unlink (glob('*'));
  chdir ($LatexDir);
  rmdir ($dir);
  return $result;
}


