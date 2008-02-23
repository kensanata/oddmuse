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
# http://www.oddmuse.org/cgi-bin/oddmuse/Field_List_Extension

$ModulesDescription .= '<p>$Id: fieldlist.pl,v 1.1 2008/02/23 17:11:27 weakish Exp $</p>';

push(@MyRules, \&FieldListRules);

sub FieldListRules {
   # :fieldname: fieldbody 
  if ($bol && m/\G\s*\:(?=(((\S.*\S)|\S)\:))/cg
	 or InElement('dd') && m/\G\s*\n(\s)*\:(?=(((\S.*\S)|\S)\:))/cg) {
    return CloseHtmlEnvironmentUntil('dd') . OpenHtmlEnvironment('dl', 1, 'fieldlist')
      . AddHtmlEnvironment('dt'); # `:' needs special treatment, later
  } elsif (InElement('dt') and m/\G\:[ \t]*(?=((\S)+))/cg) {
    return CloseHtmlEnvironment() . AddHtmlEnvironment('dd');
  }
    return undef;
}	
