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

$ModulesDescription .= '<p>$Id: fckeditor.pl,v 1.4 2005/07/07 11:28:56 as Exp $</p>';

use vars qw($FCKeditorHeight);

$FCKeditorHeight = 400; # Pixel

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
    oFCKeditor.Height = "$FCKeditorHeight" ;
    oFCKeditor.ReplaceTextarea() ;
  }
</script>
};
  }
}
