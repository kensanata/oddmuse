# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>

# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

package OddMuse;

AddModuleDescription('edit-paragraph.pl', 'Edit Paragraphs Extension');

# Allow editing of substrings

$Action{'edit-paragraph'} = \&DoEditParagraph;

sub DoEditParagraph {
  my $id = GetParam('title', '');
  UserCanEditOrDie($id);
  my $old = GetParam('paragraph', '');
  $old =~ s/\r//g;
  return DoEdit($id) unless $old;

  # Find text to edit
  my $new = GetParam('text', '');
  OpenPage($id);
  if ($new) {
    my $myoldtime = GetParam('oldtime', ''); # maybe empty!
    my $text;
    if ($myoldtime and $myoldtime != $LastUpdate) {
      ($text) = GetTextAtTime($myoldtime);
    } else {
      $text = $Page{text};
    }
    
    my $search_term = quotemeta($old);
    my $around = GetParam('around', undef);
    my $done;
    if ($around) {
      # Fuzz Factor: Just search and replace foo around a certain
      # point in order to handle repeating paragraphs. Apply a fuzz
      # factor to handle edit conflicts.
      my $len = length($old);
      my ($from, $to) = ($around - 2 * $len + 1, $around + $len - 1);
      my ($before, $area, $after) =
	  (substr($text, 0, $from),
	   substr($text, $from, $to - $from),
	   substr($text, $to));
      $done = $area =~ s/$search_term/$new/;
      $text = $before . $area . $after if $done;
      if (!$done) {
	ReportError(T('Could not identify the paragraph you were editing'),
		    '500 INTERNAL SERVER ERROR',
		    undef,
		    $q->p(T('This is the section you edited:'))
		    . $q->pre($old)
		    . $q->p(Ts('This is the area around %s:', $around))
		    . $q->pre($area));
      }
    } else {
      # simple case, just do it
      $done = $text =~ s/$search_term/$new/;
    }

    if ($done) {
      SetParam('text', $text);
      return DoPost($id);
    } else {
      ReportError(T('Could not identify the paragraph you were editing'),
		  '500 INTERNAL SERVER ERROR',
		  undef,
		  $q->p(T('This is the section you edited:'))
		  . $q->pre($old)
		  . $q->p(T('This is the current page:'))
		  . $q->pre($text));
    }
  }
  print GetHeader('', Ts('Editing %s', NormalToFree($id)));
  print $q->start_div({-class=>'content edit paragraph'});
  my $form = GetEditForm($id, undef, $old);
  my $param = GetHiddenValue('paragraph', $old);
  $param .= GetHiddenValue('action', 'edit-paragraph'); # add action
  $form =~ s!</form>!$param</form>!;
  print $form;
  print $q->end_div();
  PrintFooter($id, 'edit');
}

# When PrintWikiToHTML is called for the current revision of a page we
# initialize our data structure. The data structure simply divides the
# page up into blocks based on what one would like to edit. By
# default, that's just paragraph breaks and list items. When using
# Creole, ordered list items and table rows are added.

my @EditParagraphs = ();

*EditParagraphOldPrintWikiToHTML = *PrintWikiToHTML;
*PrintWikiToHTML = *EditParagraphNewPrintWikiToHTML;

sub EditParagraphNewPrintWikiToHTML {
  my ($text, $is_saving_cache, $revision, $is_locked) = @_;
  if ($text and not $revision) {
    my ($start, $end) = (0, 0);
    # This grouping with zero-width positive look-ahead assertion
    # makes sure that this chunk of text does not include markup need
    # for the next chunk of text.
    if (grep { $_ eq \&CreoleRule } @MyRules) {
      $regexp = "\n+(\n|(?=[*#-=|]))";
    } else {
      $regexp = "\n+(\n|(?=[*]))";
    }
    while ($text =~ /$regexp/g) {
      $end = pos($text);
      push(@EditParagraphs,
	   [$start, $end, substr($text, $start, $end - $start)]);
      $start = $end;
    }
    # Only do this if we have at least two paragraphs.
    if (@EditParagraphs and $start) {
      push(@EditParagraphs, [$start, length($text), substr($text, $start)]);
    }
  }
  # warn join('', '', map { $_->[0] . "-" . $_->[1] .": " . $_->[2]; } @EditParagraphs);
  return EditParagraphOldPrintWikiToHTML(@_);
}

# edit icon
# http://publicdomainvectors.org/en/free-clipart/Pencil-vector-icon/9221.html
# q{<img width="30" height="30" title="" alt="edit" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAE2UlEQVRIx53WW0sbaRwG8GcmSsxhdTKT5K60FFqa4CmKh96uq62gtR563butN1KNQSgESqFemBjr2mKjMRpBt1uln2FJe9ObHsyu3d2yyH6EFoTVhr7PXrQTJslMmuwLA0mYvL95/vOebPjSJJMLJZ+t7iu9pw9AHEAQwAGAE4v/Wnasf5dNHsQK/R7A37IsEwAB/ATAY9W/VUpjh9Wi7wHw5s2b4vz588KAKyb9fDMVqniwPgB/AWA0GhX5fF68fftWBAIBHV82wf83bET/AMDJyUnx4cMHwa/t1atXRry07AW0FlhvPwA4dDgclCRJtLe3ixcvXtDYXr9+bcRXjLhcQ+JS9LeGhgbeunVLXL58WQBgIBDg8+fPy/BgMKjjD3VcrrHUOppraGjg3NycWFpaEmfOnKGiKLTC37x5I1paWnT8US2w3voBHDgcDkYiEZFIJITP56PH42E0GmVLSwsB8NKlS8xms0V4JpMRdXV1+lSrWNbS3/sBHLhcLs7OzopEIiH8fj8VReHy8jIjkQhdLhfPnTtXhudyOdHV1UVJkgSAPVQxV4uSulwuhsNhsbi4KPx+P1VV5dLSEsPhMGVZZnNzMxcWFnj27FkCYDAY5P7+vmhra9OT/gLAWe0yOADgwO12c2ZmpoBqmsbFxUWGw2HabDY2Nzdza2uLN27coCzL7Ojo0BPq6C4Ad7Ur0gCAnNvtLkrq9XoZj8cLSVtbW7mxscHx8XEC4NDQEBcWFoSqqjq6DeC7ass7ACBXWl6v18tYLFZA29vbub6+zomJCQLg8PAwt7e3RW9vL7+u22kATWYrlxl6BcDvTqeTkUhExONx4fP5CklnZ2dps9kYCoWYTCYL6PXr15lOp0V3d7eeNGWxUVii7xwOB+fm5spQPWlHR0cROjY2xlQqJXp6enQ0CUD71u5kRP+02+28c+eOiMfj9Hq91DSNiUSCMzMzpuj4+DjX1tZEb2+vjq4C8FZ4pUXoVQDv6+vrGY1GRSwWE5qmUVVVPnjwoICGQiGura0VBtLExASTyaQRfQTAV+U4wlV9E797966IxWJUVZWKonBlZYXT09OUZZltbW1MpVKV0IeSJPnN3qkZPAjgCADv3bsnYrEYPR4PGxsbubq6ytu3b1OSJLa2tjKdTnNsbMyqvCsmqGWprwD4R9/E79+/z6amJrrdbq6vr3NqaqqwImUyGY6OjhIAR0dHSwfSyjeSlrV3dXV1nJ+fFx8/fuSTJ0/Y2NjIjY0NTk1NUZIkBgIB7uzscGRkhAA4MjLCzc1N45R5KEmSr8LZzbRRURTx6dMnkuTx8TGz2SwnJycJgBcvXuTTp0957dq1osWhq6vLOJAqjl6rB6CqqoIkhfhyasnn80yn07xw4QL39/c5PDxMABwcHOTu7q7o7Ow0Thmt2tFbBmuaRiMshODJyQlfvnzJoaEhAuDAwAD39vZEKBQyLg6eGk6h5XB9fT0zmUwRTpKnp6d8/Pgx+/v7+ezZM+PWlrI4sko1lfrre+bm5mYZ/vnzZ2azWREMBnU0XbLLSFVureawjm9tbRUdV3K5nAgEAgQgAGQAuGpALRNLBlgCAKfTib6+PtjtdpyenvLw8FA6OjoSAH4G8COAfyuVzyKYafvVmNrkygPYAWCvMWnFUv8Hwmcq2TCQ4MwAAAAASUVORK5CYII=" />};

my $EditParagraphPencil = '&#x270E;';

# Whenever an important element is closed, we try to add a link.

*EditParagraphOldCloseHtmlEnvironments = *CloseHtmlEnvironments;
*CloseHtmlEnvironments = *EditParagraphNewCloseHtmlEnvironments;

sub EditParagraphNewCloseHtmlEnvironments {
  EditParagraph();
  return EditParagraphOldCloseHtmlEnvironments(@_);
}

*EditParagraphOldCloseHtmlEnvironmentUntil = *CloseHtmlEnvironmentUntil;
*CloseHtmlEnvironmentUntil = *EditParagraphNewCloseHtmlEnvironmentUntil;

sub EditParagraphNewCloseHtmlEnvironmentUntil {
  my $tag = $_[0];
  if ($tag =~ /^(p|li|table|h[1-6])$/i) {
    EditParagraph();
  }
  return EditParagraphOldCloseHtmlEnvironmentUntil(@_);
}

sub EditParagraph {
  my $text;
  my $pos = pos;
  if (@EditParagraphs) {
    if ($pos) {
      while (@EditParagraphs and $EditParagraphs[0]->[1] <= $pos) {
	$text .= $EditParagraphs[0]->[2];
	shift(@EditParagraphs);
      }
    } else {
      # the last one
      $text = $EditParagraphs[-1]->[2];
    }
  }
  if ($text) {

    # Huge Hack Alert: We are appending to $Fragment, which is what
    # Clean appends to. We do this so that we can handle headers and
    # other block elements. Without this fix we'd see something like
    # this:
    # <h2>...</h2><p><a ...>&#x270E;</a></p>
    # Usually this would look as follows:
    # <h2>...</h2><p></p>
    # This is eliminated in Dirty. But it won't be eliminated if we leave the link in there.
    # What we want is this:
    # <h2>...<a ...>&#x270E;</a></h2><p></p>
    #
    # The same issue arises for other block level elements. What
    # happens at the end of a table? Without this fix we'd see
    # something like this:
    # <table><tr><td>...</td></tr></table><p><a ...>&#x270E;</a></p>
    # What we want, I guess, is this:
    # <table><tr><td>...<a ...>&#x270E;</a></td></tr></table></p>
    
    my $link = ScriptLink("action=edit-paragraph;title=$OpenPageName;around=$pos;paragraph="
			  . UrlEncode($text), $EditParagraphPencil, 'pencil');
    if ($Fragment =~ s!((:?</h[1-6]>|</t[dh]></tr></table>)<p>)$!!) {
      $Fragment .= $link . $1;
    } elsif ($Fragment eq '<p>') {
      # Do nothing: this will result in <p></p> and get eliminated.
    } else {
      # This is the default: add the link.
      $Fragment .= $link
    }
  }
}
