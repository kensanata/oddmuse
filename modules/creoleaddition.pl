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
# http://www.oddmuse.org/cgi-bin/oddmuse/CreoleAddition

$ModulesDescription .= '<p>$Id: creoleaddition.pl,v 1.11 2008/04/05 17:52:34 weakish Exp $</p>';

# Since these rules are not official now, users can turn off some of
# them.

use vars qw($CreoleAdditionSupSub);

$CreoleAdditionSupSub = 1; #  ^^supscript^^ and ,,subscript,,  
$CreoleAdditionDefList = 1; #  definition lists
$CreoleAdditionQuote =1; # 1= ""quote""

push(@MyRules, \&CreoleAdditionRules);

sub CreoleAdditionRules{
  # ^^sup^^
  if ($CreoleAdditionSupSub && m/\G\^\^/cg) {
     return (defined $HtmlStack[0] && $HtmlStack[0] eq 'sup')
       ? CloseHtmlEnvironment() : AddHtmlEnvironment('sup');
   # ,,sub,,
  } elsif ($CreoleAdditionSupSub && m/\G\,\,/cg) {
     return (defined $HtmlStack[0] && $HtmlStack[0] eq 'sub')
       ? CloseHtmlEnvironment() : AddHtmlEnvironment('sub');
  # definition lists 
  # ; term
  # : description
  } elsif ($CreoleAdditionDefList && $bol && m/\G\s*\;[ \t]*(?=(.+(\n)(\s)*\:))/cg
	 or InElement('dd') && m/\G\s*\n(\s)*\;[ \t]*(?=(.+\n(\s)*\:))/cg) {
    return CloseHtmlEnvironmentUntil('dd') . OpenHtmlEnvironment('dl', 1)
      . AddHtmlEnvironment('dt'); # `:' needs special treatment, later
  } elsif (InElement('dt') and m/\G\s*\n(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
    return CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  } elsif (InElement('dd') and m/\G\s*\n(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
	return 	CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  # """
  # blockquote
  # """
  } elsif ($CreoleAdditionQuote && $bol && m/\G\"\"\"[ \t]*\n(?=(.+\n\"\"\"[ \t]*(\n|\z)))/cg) {
	        return AddHtmlEnvironment('blockquote')
			    . AddHtmlEnvironment('p');
  } elsif (InElement('blockquote') && m/\G\n\"\"\"[ \t]*(\n|\z)/cgs) {
	  return  
	  CloseHtmlEnvironment(); 
  # ''quote''
  }	elsif ($CreoleAdditionQuote && m/\G\'\'/cgs) {
	  return (defined $HtmlStack[0] && $HtmlStack[0] eq 'q')
	   ? CloseHtmlEnvironment() : AddHtmlEnvironment('q');
  }	   
   return undef;
}
