# Copyright (C) 2008  Weakish Jiang <weakish@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
#
# You can get a copy of GPL version 2 at
# http://www.gnu.org/licenses/gpl-2.0.html
#
# For user doc, see: 
# http://www.oddmuse.org/cgi-bin/oddmuse/Html_Comment_Extension

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/htmlcomment.pl">htmlcomment.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Html_Comment_Extension">Html Comment Extension</a></p>';

push(@MyRules, \&HtmlCommentRules);

sub HtmlCommentRules {
   # /* 
   # This is a comment.
   # */
   # This RegExp is borrowed from creole.pl shamelessly. 
   if ($bol && m/\G\/\*[ \t]*\n(.*?\n)\*\/[ \t]*(\n|\z)/cgs) {
       my $str = $1;
    $str =~ s/\n \*\//\n\*\//g;
    return CloseHtmlEnvironments() . '<!--' . $str . '-->' 
      . AddHtmlEnvironment('p');
    }
    return undef;
}	
   

