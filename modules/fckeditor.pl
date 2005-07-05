# Copyright (C) 2005  Alex Schroeder <alex@emacswiki.org>
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
#    Boston, MA 02111-1307 USA,

$ModulesDescription .= '<p>$Id: fckeditor.pl,v 1.3 2005/07/05 23:48:15 as Exp $</p>';

use vars qw($FCKeditorRows);

$FCKeditorRows = 400; # Pixel

push (@MyRules, \&WysiwygRule);

sub WysiwygRule {
  if (m/\G(&lt;.*?&gt;)/gc) {
    return $1 if substr($1,5,6) eq 'script'
      or substr($1,4,6) eq 'script';
    return UnquoteHtml($1);
  }
  return undef;
}

push (@MyInitVariables, \&WysiwygScript);

sub WysiwygScript {
  # cookie is not initialized yet so we cannot use GetParam
  if ($q->param('action') eq 'edit') {
    $HtmlHeaders = qq{
<script type="text/javascript" src="/FCKeditor/fckeditor.js"></script>
<script type="text/javascript">
  window.onload = function()
  {
    var oFCKeditor = new FCKeditor( 'text' ) ;
    oFCKeditor.Height = "$FCKeditorRows" ;
    oFCKeditor.ReplaceTextarea() ;
  }
</script>
};
  }
}

# add id attribute to textarea
sub GetTextArea {
  my ($name, $text, $rows) = @_;
  return $q->textarea(-id=>$name, -name=>$name,
		      -default=>$text,
		      -rows=>$rows||55,
		      -columns=>78,
		      -override=>1);
}
