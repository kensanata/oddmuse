# Copyright (C) 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/toc-js.pl">toc-js.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Javascript_Table_of_Contents_Extension">Javascript Table of Contents Extension</a></p>';

use vars qw($TocOutlineLibrary);

$TocOutlineLibrary = 'http://h5o.googlecode.com/files/outliner.0.5.0.62.js';

# Add the dojo script to edit pages.
push (@MyInitVariables, \&TocScript);

sub TocScript {
  # cookie is not initialized yet so we cannot use GetParam
  # Cross browser compatibility: http://www.tek-tips.com/faqs.cfm?fid=4862
  # HTML5 Outlines: http://blog.tremily.us/posts/HTML5_outlines/
  # Required library: http://code.google.com/p/h5o/
  if (GetParam('action', 'browse') eq 'browse') {
    $HtmlHeaders .= qq{
<script type="text/javascript" src="$TocOutlineLibrary"></script>
<script type="text/javascript">

  function addOnloadEvent(fnc) {
    if ( typeof window.addEventListener != "undefined" )
      window.addEventListener( "load", fnc, false );
    else if ( typeof window.attachEvent != "undefined" ) {
      window.attachEvent( "onload", fnc );
    }
    else {
      if ( window.onload != null ) {
	var oldOnload = window.onload;
	window.onload = function ( e ) {
	  oldOnload( e );
	  window[fnc]();
	};
      }
      else
	window.onload = fnc;
    }
  }

  var initToc=function() {
    var toc = document.getElementById('toc');

    if (!toc) {
      var divs = document.getElementsByTagName('div');
      for (var i = 0; i < divs.length; i++) {
        if (divs[i].getAttribute('class') == 'toc') {
          toc = divs[i];
          break;
        }
      }
    }

    if (!toc) {
      var h2 = document.getElementsByTagName('h2')[0];
      if (h2) {
        toc = document.createElement('div');
        toc.setAttribute('class', 'toc');
        h2.parentNode.insertBefore(toc, h2);
      }
    }

    if (toc) {
      var outline = HTML5Outline(document.body);
      if (outline.sections.length == 1) {
        outline.sections = outline.sections[0].sections;
      }
      var html = outline.asHTML(true);

      toc.innerHTML = html;
    }
  }

  addOnloadEvent(initToc);
  </script>
};
  }
}
