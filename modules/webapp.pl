=head1 NAME

webapp - an Oddmuse module that provides offline wiki browsing

=head1 SYNOPSIS

This module makes a number of files available. These files make up a
web application which will then download the rest of the wiki. The
B<Administration> menu will contain a link to the web application.

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

$ModulesDescription .= '<p>$Id: webapp.pl,v 1.1 2011/12/31 03:04:35 as Exp $</p>';

push(@MyAdminCode, \&WebAppMenu);

sub WebAppMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('webapp/index.html',
		  T('Web application for offline browsing'),
		  'webapp'));
}

push(@MyInitVariables, \&InitWebApp);

my $jquery = 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js';

sub InitWebApp {
  if ($q->path_info =~ /^\/webapp'/) {
    # HACK ALERT: In order to allow the app to cache all the pages, we
    # need to disable surge protection for the offline pages.
    $SurgeProtection = 0;
  }
  my $manifest = ScriptUrl('webapp/MANIFEST');
  my $oddmuse = ScriptUrl('webapp/oddmuse.js');
  if ($q->path_info eq '/webapp/index.html') {
    # Switch to HTML5 add link to the manifest listing all the pages
    print GetHttpHeader('text/html', $LastUpdate);
    print <<EOT;
<!doctype html>
<html lang="en" manifest="$manifest">
<head>
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black" />
  <meta charset="utf-8">
  <title>HomePage</title>
  <script type="text/javascript" charset="utf-8" src="$jquery" ></script>
  <script type="text/javascript" charset="utf-8" src="$oddmuse" ></script>
</head>
<body>
<h1>HomePage</h1>
<p>Caching the local wiki!</p>
<p id="cache">Caching <span id="page">0</span>/<span id="total">0</span>.</p>
<p id="status">Enable Javascript and reload this page in order to get started.</p>
</body>
</html>
EOT
    exit;
  } elsif ($q->path_info eq '/webapp/MANIFEST') {
    # List all the pages necessary for the offline application.
    print GetHttpHeader('text/cache-manifest');
    print "CACHE MANIFEST\n";
    # index.html
    print ScriptUrl('webapp/index.html') . "\n";
    # CSS file
    if ($StyleSheet) {
      print "$StyleSheet\n";
    } elsif ($IndexHash{$StyleSheetPage}) {
      print "$ScriptName?action=browse;id=" . UrlEncode($StyleSheetPage)
      . ";raw=1;mime-type=text/css\n";
    } else {
      print "http://www.oddmuse.org/oddmuse.css\n";
    }
    # javascript
    print "$jquery\n";
    print "$oddmuse\n";
    # default
    print "NETWORK:\n";
    print "*\n";
    exit;
  } elsif ($q->path_info eq '/webapp/oddmuse.js') {
    print GetHttpHeader('application/javascript', $LastUpdate);
    print <<EOT;
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
	var re = /$ScriptName\/([^\/?]+)/;
	$('*').html(window.localStorage.getItem(id));
	$('a[href^="$ScriptName"]').each(function(i, a) {
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
EOT
    exit;
  }
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

=cut
