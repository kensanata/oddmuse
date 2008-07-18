# Copyright (C) 2006, 2008  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: dojo.pl,v 1.7 2008/07/18 13:28:54 as Exp $</p>';

use vars qw(@DojoPlugins $DojoTheme);

$DojoTheme = 'tundra';

# Configure toolbar example:
# @DojoPlugins = qw(copy cut paste | bold);

# Render all HTML tags except for <script>.
push (@MyRules, \&WysiwygRule);

sub WysiwygRule {
  if (m/\G(&lt;.*?&gt;)/gc) {
    return $1 if substr($1,5,6) eq 'script'
      or substr($1,4,6) eq 'script';
    return UnquoteHtml($1);
  }
  return undef;
}

# Add the dojo script to edit pages.
push (@MyInitVariables, \&WysiwygScript);

sub WysiwygScript {
  # cookie is not initialized yet so we cannot use GetParam
  if ($q->param('action') eq 'edit') {
    $HtmlHeaders .= qq{
<style type="text/css">
  \@import "/dojoroot/dijit/themes/$DojoTheme/$DojoTheme.css";
</style>
<script type="text/javascript" src="/dojoroot/dojo/dojo.js"
	djConfig="parseOnLoad: true"></script>
<script type="text/javascript">
	dojo.require("dijit.Editor");
	dojo.addOnLoad(function () {
	  dojo.connect(dojo.query("form.edit")[0], 'onsubmit', function () {
	   dojo.byId('dojotext').value = dijit.byId('dojoeditor').getValue(false);
	  });
	});
</script>
};
  }
  # theme has to match $DojoTheme (so that it gets used for the body tag)
  delete $CookieParameters{theme};
  SetParam('theme', $DojoTheme);
}

*OldWysiwygGetTextArea = *GetTextArea;
*GetTextArea = *NewWysiwygGetTextArea;

sub NewWysiwygGetTextArea {
  my ($name, $text, $rows) = @_;
  if ($name eq 'text') {
    # The dojoeditor is the visible thing that is not submitted; we
    # need some javascript that will copy the content of the
    # dojoeditor to the dojotext field which has the right name.
    my %params = (-id=>'dojoeditor', -default=>$text,
		  -rows=>$rows||25, -columns=>78, -override=>1,
		  -dojoType=>'dijit.Editor');
    $params{-plugins} = "[" . join(",", map{"'$_'"} @DojoPlugins) . "]"
      if @DojoPlugins;
    return $q->textarea(%params)
      . $q->hidden(-id=>'dojotext', name=>$name);
  } else {
    return OldWysiwygGetTextArea(@_);
  }
}

*OldWysiwygImproveDiff = *ImproveDiff;
*ImproveDiff = *NewWysiwygImproveDiff;

sub NewWysiwygImproveDiff {
  my $old = OldWysiwygImproveDiff(@_);
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
