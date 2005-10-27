/* Copyright 2005  Alex Schroeder <alex@emacswiki.org>
   based on http://simon.incutio.com/archive/2004/05/30/plinks#p-13
   Copyright 2004  Simon Willison
*/

function plinkHighlight() {
    if (/#[0-9]+$/.test(document.location)) {
        // The user arrived via a plink
        var plink_id = document.location.href.split('#')[1];
        var para = document.getElementById("p" + plink_id);
        para.className = 'plink';
    }
}

function addpLinks() {
    /* Only show plinks on ordinary pages: They either use path_info
     * or keywords in the URL, not parameters. */
    if (/=/.test(document.location.href)) {
        return;
    }
    // find the content div: why is there no xpath?
    var elem = document.getElementsByTagName('div');
    var content;
    div:
    for (var i = 0; i < elem.length; i++) {
	var classes = elem[i].getAttribute('class').split(" ");
	for (var j = 0; j < classes.length; j++) {
	    if (classes[j] == 'content') {
		content = elem[i];
		break div;
	    }
	}
    }
    // identify all p and li items
    var items = new Array;
    elem = content.getElementsByTagName('p');
    for (var i = 0; i < elem.length; i++) {
	items.push(elem[i]);
    }
    elem = content.getElementsByTagName('li');
    for (var i = 0; i < elem.length; i++) {
	items.push(elem[i]);
    }
    // add named anchors at the beginning and a link to that anchor at
    // the end of all items
    for (var i = 0; i < items.length; i++) {
        var current = items[i];
	current.setAttribute("id", "p" + i);
	var anchor = document.createElement('a');
	anchor.name = i;
	current.insertBefore(anchor, current.firstChild);
	var plink = document.createElement('a');
	plink.href = document.location.href.split('#')[0] + '#' + i;
	plink.className = 'plink';
	plink.appendChild(document.createTextNode(' #'));
	current.appendChild(plink);
    }
}

function addLoadEvent(func) {
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

addLoadEvent(addpLinks);
addLoadEvent(plinkHighlight);
