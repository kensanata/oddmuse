var wiki = (function() {
    var pages;
    var log = function(msg) {
	$("#status").text(msg);
    }
    var log_html = function(msg) {
	$("#status").html(msg);
    }
    var log_node = function(msg) {
	$("#status").empty();
	$("#status").append(msg);
    }
    var get_pages = function(data) {
	pages = data.split("\n");
	var count = 1;
	pages.pop(); // after the last newline there is nothing
	$("#total").text(pages.length);
	var get_page = function(i, id) {
	    if (id != "") {
		var store_page = function(data) {
		    window.localStorage.setItem(id, data);
		    $("#page").text(count++);
		}
		$.get("cgi-bin/wiki.pl",
		      {action: "browse", id: id},
		      store_page);
	    }
	}
	$.each(pages, get_page);
	window.localStorage.setItem(" pages", pages.join(" "));
    }
    var download = function() {
	log("Getting list of pages...");
	$.get("cgi-bin/wiki.pl",
	      {action: "index", raw: "1"},
	      get_pages);
	log_html('<p><a href="javascript:wiki.list()">List</a> the pages in local storage.');
    }
    var initialize = function() {
	pages = window.localStorage.getItem(" pages").split(" ");
	if (pages) {
	    log_html('<p>Found pages in local storage. <a href="javascript:wiki.list()">List</a> the pages in local storage. <a href="javascript:wiki.download()">Download</a> a fresh copy.');
	} else {
	    download();
	}
    };
    var list = function() {
	var ul = document.createElement('ul');
	$.each(pages, function(i, id) {
	    var li = document.createElement('li');
	    var a = document.createElement('a');
	    $(a).attr({href: "javascript:wiki.browse('" + id + "')"});
	    $(a).text(id);
	    $(li).append(a);
	    $(ul).append(li);
	});
	log_node(ul);
    }
    var browse = function(id) {
	var re = /http:\/\/localhost\/cgi-bin\/wiki.pl\/([^\/?]+)/;
	$('*').html(window.localStorage.getItem(id));
	$('a[href^="http://localhost/cgi-bin/wiki.pl"]').each(function(i, a) {
	    var match = re.exec($(a).attr('href'));
	    if (match) {
		var id = unescape(match[1]);
		if (pages.indexOf(id) >= 0) {
		    $(a).attr('href', "javascript:wiki.browse('" + id + "')");
		}
	    }
	});
    }
    return {
	initialize: initialize,
	download: download,
	list: list,
	browse: browse,
    };
}());

$(document).ready(function(evt) {
    wiki.initialize();
});
