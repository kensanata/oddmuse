# Copyright (C) 2005  Robin V. Stacey (robin@greywulf.net)
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

# This module adds a wordcount to the bottom of edit boxes. The javascript code is munged from
# Richard Livsey's Textarea Tools page: http://livsey.org/experiments/textareatools/
# Though I've stripped it down to it's barest necessities

use strict;
use v5.10;

our (@MyInitVariables, $HtmlHeaders);

AddModuleDescription('wordcount.pl', 'Word Count Extension');

push(@MyInitVariables, \&WordcountAddScript);

sub WordcountAddScript {
	$HtmlHeaders .= "<script type='text/javascript'>
	function addEvent(obj, evType, fn) {
		if (obj.addEventListener) {
			obj.addEventListener(evType, fn, true);
			return true;
		} else if (obj.attachEvent) {
			var r = obj.attachEvent('on'+evType, fn);
			return r;
		} else { return false; }
	}

	addEvent(window, 'load', function() {
		document.getElementById('textWordCount').innerHTML = numWords(document.getElementById('text').value);
		document.getElementById('text').onkeyup = function() {
			document.getElementById('textWordCount').innerHTML = numWords(document.getElementById('text').value);
		}
	});

	function numWords(string) {
		string = string + ' ';
		string = string.replace(/^[^A-Za-z0-9]+/gi, '');
		string = string.replace(/[^A-Za-z0-9]+/gi, ' ');
		var items = string.split(' ');
		return items.length -1;
	}
	</script>";
}
