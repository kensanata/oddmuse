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

$ModulesDescription .= '<p>$Id: creoleaddition.pl,v 1.1 2008/02/22 10:59:07 weakish Exp $</p>';

# Since these rules are not official now, users can turn off some of
# them. Currently, It's no use, since there is only one rule. But
# maybe we'll have more addition rules in the furture.

use vars qw($CreoleAdditionSupSub);

$CreoleAdditionSupSub = 1; # 1= ^^supscript^^ and ,,subscript,,  

push(@MyRules, \&CreoleAdditionRule);

sub CreoleAdditionRule{


   # ^^sup^^
   if ($CreoleAdditionSupSub && m/\G\^\^/cg) {
     return (defined $HtmlStack[0] && $HtmlStack[0] eq 'sup')
       ? CloseHtmlEnvironment() : AddHtmlEnvironment('sup');
   }
   # ,,sub,,
   elsif ($CreoleAdditionSupSub && m/\G\,\,/cg) {
     return (defined $HtmlStack[0] && $HtmlStack[0] eq 'sub')
       ? CloseHtmlEnvironment() : AddHtmlEnvironment('sub');
   }
   return undef;
}
