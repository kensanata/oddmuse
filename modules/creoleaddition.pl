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

$ModulesDescription .= '<p>$Id: creoleaddition.pl,v 1.3 2008/02/22 19:38:36 weakish Exp $</p>';

# Since these rules are not official now, users can turn off some of
# them. Currently, It's no use, since there is only one rule. But
# maybe we'll have more addition rules in the furture.

use vars qw($CreoleAdditionSupSub);

$CreoleAdditionSupSub = 1; # 1= ^^supscript^^ and ,,subscript,,  
$CreoleAdditionDefList = 1; # 1= allow definition lists

push(@MyRules, \&CreoleAdditionRule);

sub CreoleAdditionRule{
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
	 or InElement('dd') && m/\G\s*(\n)+(\s)*\;[ \t]*(?=(.+\n(\s)*\:))/cg) {
    return CloseHtmlEnvironmentUntil('dd') . OpenHtmlEnvironment('dl', 1)
      . AddHtmlEnvironment('dt'); # `:' needs special treatment, later
  } elsif (InElement('dt') and m/\G\s*(\n)+(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
    return CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  } elsif (InElement('dd') and m/\G\s*(\n)+(\s)*\:[ \t]*(?=(.+(\n)(\s)*\:)*)/cg) {
	return 	CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  }	
   return undef;
}
