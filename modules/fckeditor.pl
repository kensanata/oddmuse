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

$ModulesDescription .= '<p>$Id: fckeditor.pl,v 1.8 2006/09/05 14:12:22 as Exp $</p>';

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
<style type="text/css">
input[name="Preview"] { display: none; }
</style>
};
  }
}

*OldFckImproveDiff = *ImproveDiff;
*ImproveDiff = *NewFckImproveDiff;

sub NewFckImproveDiff {
  my $old = OldFckImproveDiff(@_);
  my $new = '';
  my $protected = 0;
  # fix diff inserting change boundaries inside tags
  $old =~ s!&<strong class="changes">([a-z]+);!</strong>&$1;!g;
  $old =~ s!&</strong>([a-z]+);!</strong>&$1;!g;
  # unquote named html entities
  $old =~ s/\&amp;([a-z]+);/&$1;/g;
  foreach my $str (split(/(<strong class="changes">|<\/strong>)/, $old)) {
    # Don't remove HTML tags affected by changes.
    $protected = 1 if $str eq '<strong class="changes">';
    # strip html tags and don't get confused with the < and > created
    # by diff!
    $str =~ s/\&lt;.*?\&gt;//g unless $protected;
    $protected = 0 if $str eq '</strong>';
    $new .= $str;
  }
  return $new;
}
