/* Copyright 2006  Alex Schroeder <alex@emacswiki.org> */

// not used at the moment
function insertForeigner (parent, foreigner, target) {
    if(!document.importNode) {
	var imported = foreigner.cloneNode(true);
	var dummy = new Element;
	dummy.innerHTML = imported.outerHTML;
	parent.insertBefore(dummy.firstChild, target);
    } else {
	var imported = document.importNode(foreigner, true);
	parent.insertBefore(imported, target);
    }
}

function doChanges (id, url, num, regexp, reverse, offset, xml) {
    var target = document.getElementById(id);
    var elem = getElementsByTagAndClass(xml, 'div', 'page');
    for (var i = 0; i < elem.length; i++) {
	var imported = document.importNode(elem[i], true);
	target.parentNode.insertBefore(imported, target);
	// insertForeigner(target.parentNode, elem[i], target);
    }
    addMoreLink(target.parentNode, num, regexp, reverse, offset+num);
    target.parentNode.removeChild(target);
}

function createXMLHttpRequest() {
   try { return new ActiveXObject("Msxml2.XMLHTTP"); } catch (e) {}
   try { return new ActiveXObject("Microsoft.XMLHTTP"); } catch (e) {}
   try { return new XMLHttpRequest(); } catch(e) {}
   alert("XMLHttpRequest not supported");
   return null;
 }

function journalQueue (id, url, num, regexp, reverse, offset) {
    var xmlHttp = createXMLHttpRequest();
    xmlHttp.open('GET', url+'?action=journal;num='+num
		 +';regexp='+escape(regexp)
		 +';reverse='+reverse
		 +';offset='+offset, true);
    var requestTimer = setTimeout(
        function() {
	    xmlHttp.abort();
	    alert('Timeout while getting more journal entries.');
	}, 30000);
    xmlHttp.onreadystatechange = function () {
	if (xmlHttp.readyState != 4) { return; }
	clearTimeout(requestTimer);
	if (xmlHttp.status != 200)  {
	    alert('Got '+xmlHttp.status+' from '+xmlHttp.url
		  +'response instead of more journal entries: '
		  +xmlHttp.responseText);
	    return;
	}
	doChanges(id, url, num, regexp, reverse, offset, xmlHttp.responseXML);
    };
    xmlHttp.send(null);
}

function addMore (id, url, num, regexp, reverse, offset) {
    var target = document.getElementById(id);
    var replacement = document.createElement('span');
    var text = document.createTextNode('Loading...');
    replacement.appendChild(text);
    target.parentNode.insertBefore(replacement, target);
    target.parentNode.removeChild(target);
    replacement.id = id;
    journalQueue(id, url, num, regexp, reverse, offset);
}

var linkCount = 1;

function addMoreLink (div, url, num, regexp, reverse, offset) {
    var more = document.createElement('span');
    more.id = 'journal' + linkCount++;
    more.setAttribute('onclick', 'javascript:addMore("'+more.id+'","'
		      +url+'",'+num+',"'
		      +regexp.replace(/\\/g, "\\\\")+'","'
		      +reverse+'",'+(offset+num)+')');
    more.className = 'more';
    more.appendChild(document.createTextNode('More...'));
    div.appendChild(more);
}

function getElementsByTagAndClass (node, tag, class) {
    // find the content div: why is there no xpath?
    var elem = node.getElementsByTagName(tag);
    var result = new Array;
    for (var i = 0; i < elem.length; i++) {
	var val = elem[i].getAttribute('class');
	if (val) {
	    var classes = val.split(" ");
	    for (var j = 0; j < classes.length; j++) {
		if (classes[j] == class) {
		    result.push(elem[i]);
		}
	    }
	}
    }
    return result;
}

function addMoreToJournal () {
    /* Only show the more link on ordinary pages: They either use
     * path_info or keywords in the URL, not parameters. */
    if (/=/.test(document.location.href)) {
        return;
    }
    // find the content div: why is there no xpath?
    var journals = getElementsByTagAndClass(document, 'div', 'journal');
    // find the comment inside the journal div and extract the
    // parameters
    for (var i = 0; i < journals.length; i++) {
        var current = journals[i];
	var str = current.firstChild;
	if (str.nodeType == 8) {
	    var match = str.nodeValue.match(/(\S*?) ([0-9]+) (.*?) (reverse)? ([0-9]+)/);
	    addMoreLink(current, match[1], parseInt(match[2]),
			match[3], match[4]||"", parseInt(match[5]));
	}
    }
}

function addLoadEvent (func) {
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

addLoadEvent(addMoreToJournal);
