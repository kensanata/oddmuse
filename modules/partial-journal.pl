# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
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

$ModulesDescription .= '<p>$Id: partial-journal.pl,v 1.4 2011/11/19 15:27:03 as Exp $</p>';

# Set up some rule so that we can mess with '-- cut --' (change to <hr>)
push(@MyRules, \&PartialCutRule);

sub PartialCutRule {
  if (m/\G(?<=\n)\s*--\s*cut\s*--\s*(?=\n)/gc) {
    return CloseHtmlEnvironments() . '<hr class="cut" />' . AddHtmlEnvironment('p');
  }
  return undef;
}

*OldPartialPrintJournal = *PrintJournal;
*PrintJournal = NewPartialPrintJournal;

sub NewPartialPrintAllPages {
  my $links = shift;
  my $comments = shift;
  my $num = shift;
  for my $id (@_) {
    OpenPage($id);
    print $q->hr . $q->h1($links ? GetPageLink($id) : $q->a({-name=>$id},$id));
    my $text = $Page{'text'};
    if ($text =~ /((.*\n)*.*)\n\s*--\s*cut\s*--\s*/) {
      $text = $1;
    }
    PrintWikiToHTML($text); # nocache, current, not locked
    if ($comments and UserCanEdit($CommentsPrefix . $id, 0) and $id !~ /^$CommentsPrefix/) {
      print $q->p({-class=>'comment'},
		  GetPageLink($CommentsPrefix . $id, T('Comments on this page')));
    }
  }
}

sub NewPartialPrintJournal {
  # We redefine PrintAllPages temporarily
  *OldPartialPrintAllPages = *PrintAllPages;
  *PrintAllPages = *NewPartialPrintAllPages;

  # Then we call the PrintJournal
  my $out = OldPartialPrintJournal(@_);

  # Then we put PrintAllPages back!
  *PrintAllPages = *OldPartialPrintAllPages;
  return $out;
}


