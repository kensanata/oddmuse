# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: thread.pl,v 1.6 2004/06/28 21:39:05 as Exp $</p>';

$Action{getthread} = \&ThreadGet;
$Action{addthread} = \&ThreadAdd;

push(@MyRules, \&ThreadRule);

sub ThreadRule {
  if (m/\G(\[\[thread:$FreeLinkPattern\]\])/gcs) {
    Dirty($1);
    my $oldpos = pos;
    ThreadGet($2, 1, 1);
    pos = $oldpos;
    return '';
  }
  return undef;
}

sub ThreadGet {
  my ($id, $interactive, $inline) = @_;
  my ($page, $thread) = ThreadExtract($id);
  print GetHttpHeader('text/html') . GetHtmlHeader(Ts('Thread: %s', $id), '') unless $inline;
  if (GetParam('interactive', $interactive)) {
    $thread = ThreadInteractive($id, $thread);
  }
  ApplyRules($thread);
  print $q->end_html unless $inline;
}

sub ThreadExtract {
  my $id = shift;
  ReportError(T('ID parameter is missing.'), '400 BAD REQUEST') unless $id;
  $page = GetPageContent($id);
  ReportError(Ts('Thread %s does not exist.', $id), '404 NOT FOUND') unless $page;
  # ignore all the stuff that gets processed anyway
  foreach my $tag ('nowiki', 'pre', 'code') {
    $page =~ s|<$tag>(.*\n)*?</$tag>||gi;
  }
  if ($page =~ m/(^|\n)(\*(.+\n)+)/) {
    return ($page, $2);
  } else {
    ReportError(Ts('Page %s does not contain a thread.', $id), '404 NOT FOUND');
  }
}

sub ThreadInteractive {
  my ($id, $thread) = @_;
  my @items = split(/(^|\n)(\*+)/, $thread);
  my $result;
  while (@items) {
    my $level;
    while (@items and substr($level, 0, 1) ne '*') {
      $level = shift(@items);
    }
    my $rest = shift(@items);
    if ($rest =~ m/\[$UrlPattern\s+([^\]]+?)\]/) {
      my $url = UrlEncode($1);
      my $add = T('Add');
      my $link = "[$ScriptName?action=addthread;id=$id;url=$url $add]";
      $result .= $level . ' '. $link . ' ' . $rest . "\n";
    }
  }
  ReportError('Unable to parse thread', '500 INTERNAL SERVER ERROR') unless $result;
  return $result;
}

sub ThreadAdd {
  my $id = shift;
  ReportError(T('ID parameter is missing.'), '400 BAD REQUEST') unless $id;
  my $url = GetParam('url', '');
  ReportError(T('URL parameter is missing.'), '400 BAD REQUEST') unless $url;
  if (not (GetParam('new', '')) or not(GetParam('name', ''))) {
    print GetHeader('', Ts('Add to %s thread', $id), '');
    print $q->div({-class=>'thread'}, '<p>'
		  . GetFormStart(0, 1)
		  . GetHiddenValue('action', 'addthread')
		  . GetHiddenValue('id', $id)
		  . '<table><tr><td>'
		  . T('Below:')
		  . '</td><td>'
		  . $q->textfield(-name=>'url', -value=>$url,
				  -size=>100, -maxlength=>500)
		  . '</td></tr><tr><td>'
		  . T('URL:')
		  . '</td><td>'
		  . $q->textfield(-name=>'new',
				  -size=>100, -maxlength=>500)
		  . '</td></tr><tr><td>'
		  . T('Name:')
		  . '</td><td>'
		  . $q->textfield(-name=>'name',
				  -size=>50, -maxlength=>100)
		  . '</td></tr></table>'
		  . '<p>'
		  . $q->p($q->submit(-name=>'Save', -value=>T('Save')))
		  . $q->endform());
    print $q->end_html;
  } else {
    my ($page, $thread) = ThreadExtract($id);
    my $new = GetParam('new', '');
    my $name = GetParam('name', '');
    my @items = split(/(^|\n)(\*+)/, $thread);
    my $result;
    while (@items) {
      my $level;
      while (@items and substr($level, 0, 1) ne '*') {
	$level = shift(@items);
      }
      my $rest = shift(@items);
      $rest =~ s/\s+$//;
      if ($rest =~ m/\[$UrlPattern\s+([^\]]+?)\]/) {
	my $current = $1;
	$result .= $level . $rest . "\n";
	if ($current eq $url) {
	  $result .= $level . "* [$new $name]\n";
	}
      }
    }
    # print GetHttpHeader('text/html', $Now) . GetHtmlHeader(Ts('Thread: %s', $id), '');
    # ApplyRules($result);
    # print $q->pre($new . "\n" . $result);
    # print $q->end_html;
    $thread = quotemeta($thread);
    $page =~ s/$thread/$result/;
    SetParam('text', $page);
    DoPost($id);
  }
}
