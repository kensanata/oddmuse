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


$ModulesDescription .= '<p>$Id: edit-assist.pl,v 1.1 2007/02/06 01:12:59 as Exp $</p>';

push (@MyInitVariables,
      sub {

	if ($q->param('action') eq 'edit') {

	  $HtmlHeaders =  qq{

<script type="text/javascript">

function hookEvent(hookName, hookFunct) {
	if (window.addEventListener) {
		window.addEventListener(hookName, hookFunct, false);
	} else if (window.attachEvent) {
		window.attachEvent("on" + hookName, hookFunct);
	}
}

var mwEditButtons = [];
var mwCustomEditButtons = []; // eg to add in MediaWiki:Common.js

// this function generates the actual toolbar buttons with localized text
// we use it to avoid creating the toolbar where javascript is not enabled
function addButton(imageFile, speedTip, tagOpen, tagClose, sampleText) {
	// Don't generate buttons for browsers which don't fully
	// support it.
	mwEditButtons[mwEditButtons.length] =
		{"imageFile": imageFile,
		 "speedTip": speedTip,
		 "tagOpen": tagOpen,
		 "tagClose": tagClose,
		 "sampleText": sampleText};
}

// this function generates the actual toolbar buttons with localized text
// we use it to avoid creating the toolbar where javascript is not enabled
function mwInsertEditButton(parent, item) {
	var image = document.createElement("img");
	image.width = 23;
	image.height = 22;
	image.src = item.imageFile;
	image.border = 0;
	image.alt = item.speedTip;
	image.title = item.speedTip;
	image.style.cursor = "pointer";
	image.onclick = function() {
		insertTags(item.tagOpen, item.tagClose, item.sampleText);
		return false;
	};
	
	parent.appendChild(image);
	return true;
}

function mwSetupToolbar() {

       var toolbar;

       for (i=0;i<document.getElementsByTagName("div").length; i++) {
		if (document.getElementsByTagName("div").item(i).className == "header"){
			toolbar = document.getElementsByTagName("div").item(i);
		}
	}
	if (!toolbar) { return false; }

	var textbox = document.getElementById('text');
	if (!textbox) { return false; }
	
	// Don't generate buttons for browsers which don't fully
	// support it.
	if (!document.selection && textbox.selectionStart === null) {
		return false;
	}
	
	for (var i in mwEditButtons) {
		mwInsertEditButton(toolbar, mwEditButtons[i]);
	}
	for (i in mwCustomEditButtons) {
		mwInsertEditButton(toolbar, mwCustomEditButtons[i]);
	}
	return true;
}


// apply tagOpen/tagClose to selection in textarea,
// use sampleText instead of selection if there is none
// copied and adapted from phpBB
function insertTags(tagOpen, tagClose, sampleText) {
	var txtarea;
	if (document.editform) {
		txtarea = document.editform.wpTextbox1;
	} else {
		// some alternate form? take the first one we can find
		var areas = document.getElementsByTagName('textarea');
		txtarea = areas[0];
	}

	// IE
	if (document.selection  && !is_gecko) {
		var theSelection = document.selection.createRange().text;
		if (!theSelection) {
			theSelection=sampleText;
		}
		txtarea.focus();
		if (theSelection.charAt(theSelection.length - 1) == " ") { // exclude ending space char, if any
			theSelection = theSelection.substring(0, theSelection.length - 1);
			document.selection.createRange().text = tagOpen + theSelection + tagClose + " ";
		} else {
			document.selection.createRange().text = tagOpen + theSelection + tagClose;
		}

	// Mozilla
	} else if(txtarea.selectionStart || txtarea.selectionStart == '0') {
		var replaced = false;
		var startPos = txtarea.selectionStart;
		var endPos = txtarea.selectionEnd;
		if (endPos-startPos) {
			replaced = true;
		}
		var scrollTop = txtarea.scrollTop;
		var myText = (txtarea.value).substring(startPos, endPos);
		if (!myText) {
			myText=sampleText;
		}
		var subst;
		if (myText.charAt(myText.length - 1) == " ") { // exclude ending space char, if any
			subst = tagOpen + myText.substring(0, (myText.length - 1)) + tagClose + " ";
		} else {
			subst = tagOpen + myText + tagClose;
		}
		txtarea.value = txtarea.value.substring(0, startPos) + subst +
			txtarea.value.substring(endPos, txtarea.value.length);
		txtarea.focus();
		//set new selection
		if (replaced) {
			var cPos = startPos+(tagOpen.length+myText.length+tagClose.length);
			txtarea.selectionStart = cPos;
			txtarea.selectionEnd = cPos;
		} else {
			txtarea.selectionStart = startPos+tagOpen.length;
			txtarea.selectionEnd = startPos+tagOpen.length+myText.length;
		}
		txtarea.scrollTop = scrollTop;

	// All other browsers get no toolbar.
	// There was previously support for a crippled "help"
	// bar, but that caused more problems than it solved.
	}
	// reposition cursor if possible
	if (txtarea.createTextRange) {
		txtarea.caretPos = document.selection.createRange().duplicate();
	}
}

 
addButton('/images/button_bold.png','Bold text','**','**','Bold text');
addButton('/images/button_italic.png','Italic text','//','//','Italic text');

addButton('/images/button_link.png','Internal link','[[',']]','Link title');
addButton('/images/button_extlink.png','External link (remember http:// prefix)','[',']','http://www.example.com link title');

addButton('/images/button_headline.png','Level 2 headline','\\n== ',' ==\\n','Headline text');
 
addButton('/images/button_image.png','Embedded image','[[image:',']]','Example.jpg');

addButton('/images/button_nowiki.png','Ignore wiki formatting','{{{','}}}','Insert non-formatted text here');
addButton('/images/button_sig.png','Your signature with timestamp','--~~~~','','');

addButton('/images/button_hr.png','Horizontal line','\\n----\\n','','');


hookEvent("load", mwSetupToolbar);

</script>


};
	}
      });
