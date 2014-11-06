/* Copyright 2014  Alex Schroeder <alex@gnu.org>
   based on http://git.savannah.gnu.org/cgit/oddmuse.git/plain/plinks.js
   for more information see http://oddmuse.org/wiki/Purple_Numbers_Extension
   based on http://simon.incutio.com/archive/2004/05/30/plinks#p-13
   Copyright 2004  Simon Willison

   This program is free software: you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation, either version 3 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this program. If not, see <http://www.gnu.org/licenses/>.
*/

function add_edit_links() {
    /* Only show edit links on ordinary pages: They either use
     * path_info or keywords in the URL, not parameters. */
    if (/=/.test(document.location.href)) {
	return;
    }
    // find all the pencil links
    var links = new Array;
    var elem = document.getElementsByTagName('a');
    for (var i = 0; i < elem.length; i++) {
	var atr = elem[i].getAttribute('class');
	if (atr != null) {
	    var classes = atr.split(" ");
	    for (var j = 0; j < classes.length; j++) {
		if (classes[j] == 'pencil') {
		    links.push(elem[i]);
		}
	    }
	}
    }
    // make them invisible
    for (var i = 0; i < links.length; i++) {
	var link = links[i];
	var func = function(thislink) {
	    return function() {
		if (thislink.style.visibility == "visible") {
		    thislink.style.transition = "visibility 0s 1s, opacity 1s linear";
		    thislink.style.visibility = "hidden";
		    thislink.style.opacity = "0";
		} else {
		    thislink.style.transition = "opacity 1s linear";
		    thislink.style.visibility = "visible";
		    thislink.style.opacity = "1";
		};
	    }
	};
	link.style.transition = "visibility 0s 1s, opacity 1s linear";
	link.style.visibility = "hidden";
	link.style.opacity = "0";
	link.parentNode.onclick = func(link);
    }
}

function add_load_event(func) {
    var oldonload = window.onload;
    if (typeof window.onload != 'function') {
	window.onload = func;
    } else {
	window.onload = function() {
	    oldonload();
	    func();
	}
    }
}

add_load_event(add_edit_links);
