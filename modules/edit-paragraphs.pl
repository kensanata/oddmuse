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
    if ($text =~ s/$search_term/$new/) {
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

# When PrintPageContent is called for the current revision of a page
# we initialize our data structure.

my @EditParagraphs = ();

*EditParagraphOldPrintPageContent = *PrintPageContent;
*PrintPageContent = *EditParagraphNewPrintPageContent;

sub EditParagraphNewPrintPageContent {
  my ($text, $revision) = @_;
  if ($text and not $revision) {
    my ($start, $end) = (0, 0);
    while ($text =~ /(\n\n+)/g) {
      $end = pos($text);
      push(@EditParagraphs, [$start, $end, substr($text, $start, $end - $start - length($1))]);
      $start = $end;
    }
    # Only do this if we have at least two paragraphs.
    if (@EditParagraphs and $start) {
      push(@EditParagraphs, [$start, length($text), substr($text, $start)]);
    }
  }
  for my $element (@EditParagraphs) {
    warn $element->[0] . "-" . $element->[1] .": " . $element->[2];
  }
  return EditParagraphOldPrintPageContent(@_);
}

# edit icon
# http://publicdomainvectors.org/en/free-clipart/Pencil-vector-icon/9221.html
# q{<img width="30" height="30" title="" alt="edit" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAE2UlEQVRIx53WW0sbaRwG8GcmSsxhdTKT5K60FFqa4CmKh96uq62gtR563butN1KNQSgESqFemBjr2mKjMRpBt1uln2FJe9ObHsyu3d2yyH6EFoTVhr7PXrQTJslMmuwLA0mYvL95/vOebPjSJJMLJZ+t7iu9pw9AHEAQwAGAE4v/Wnasf5dNHsQK/R7A37IsEwAB/ATAY9W/VUpjh9Wi7wHw5s2b4vz588KAKyb9fDMVqniwPgB/AWA0GhX5fF68fftWBAIBHV82wf83bET/AMDJyUnx4cMHwa/t1atXRry07AW0FlhvPwA4dDgclCRJtLe3ixcvXtDYXr9+bcRXjLhcQ+JS9LeGhgbeunVLXL58WQBgIBDg8+fPy/BgMKjjD3VcrrHUOppraGjg3NycWFpaEmfOnKGiKLTC37x5I1paWnT8US2w3voBHDgcDkYiEZFIJITP56PH42E0GmVLSwsB8NKlS8xms0V4JpMRdXV1+lSrWNbS3/sBHLhcLs7OzopEIiH8fj8VReHy8jIjkQhdLhfPnTtXhudyOdHV1UVJkgSAPVQxV4uSulwuhsNhsbi4KPx+P1VV5dLSEsPhMGVZZnNzMxcWFnj27FkCYDAY5P7+vmhra9OT/gLAWe0yOADgwO12c2ZmpoBqmsbFxUWGw2HabDY2Nzdza2uLN27coCzL7Ojo0BPq6C4Ad7Ur0gCAnNvtLkrq9XoZj8cLSVtbW7mxscHx8XEC4NDQEBcWFoSqqjq6DeC7ass7ACBXWl6v18tYLFZA29vbub6+zomJCQLg8PAwt7e3RW9vL7+u22kATWYrlxl6BcDvTqeTkUhExONx4fP5CklnZ2dps9kYCoWYTCYL6PXr15lOp0V3d7eeNGWxUVii7xwOB+fm5spQPWlHR0cROjY2xlQqJXp6enQ0CUD71u5kRP+02+28c+eOiMfj9Hq91DSNiUSCMzMzpuj4+DjX1tZEb2+vjq4C8FZ4pUXoVQDv6+vrGY1GRSwWE5qmUVVVPnjwoICGQiGura0VBtLExASTyaQRfQTAV+U4wlV9E797966IxWJUVZWKonBlZYXT09OUZZltbW1MpVKV0IeSJPnN3qkZPAjgCADv3bsnYrEYPR4PGxsbubq6ytu3b1OSJLa2tjKdTnNsbMyqvCsmqGWprwD4R9/E79+/z6amJrrdbq6vr3NqaqqwImUyGY6OjhIAR0dHSwfSyjeSlrV3dXV1nJ+fFx8/fuSTJ0/Y2NjIjY0NTk1NUZIkBgIB7uzscGRkhAA4MjLCzc1N45R5KEmSr8LZzbRRURTx6dMnkuTx8TGz2SwnJycJgBcvXuTTp0957dq1osWhq6vLOJAqjl6rB6CqqoIkhfhyasnn80yn07xw4QL39/c5PDxMABwcHOTu7q7o7Ow0Thmt2tFbBmuaRiMshODJyQlfvnzJoaEhAuDAwAD39vZEKBQyLg6eGk6h5XB9fT0zmUwRTpKnp6d8/Pgx+/v7+ezZM+PWlrI4sko1lfrre+bm5mYZ/vnzZ2azWREMBnU0XbLLSFVureawjm9tbRUdV3K5nAgEAgQgAGQAuGpALRNLBlgCAKfTib6+PtjtdpyenvLw8FA6OjoSAH4G8COAfyuVzyKYafvVmNrkygPYAWCvMWnFUv8Hwmcq2TCQ4MwAAAAASUVORK5CYII=" />};

my $EditParagraphPencil = '&#x270E;';

# Whenever CloseHtmlEnvironments is called, we add a link.

*EditParagraphOldCloseHtmlEnvironments = *CloseHtmlEnvironments;
*CloseHtmlEnvironments = *EditParagraphNewCloseHtmlEnvironments;

sub EditParagraphNewCloseHtmlEnvironments {
  my $text;
  my $pos = pos;
  if ($pos) {
    for my $element (@EditParagraphs) {
      if ($pos == $element->[1]) {
	$text = $element->[2];
	last;
      }
    }
  }
  if ($text) {
    # Huge Hack Alert: We are appending to $Fragment, which is what Clean appends to.
    # We do this so that we can handle headers. Without this fix we'd see something like this:
    # <h2>...</h2><p><a ...>&#x270E;</a></p>
    # Usually this would look as follows:
    # <h2>...</h2><p></p>
    # This is eliminated in Dirty. But it won't be eliminated if we leave the link in there.
    # What we want is this:
    # <h2>...<a ...>&#x270E;</a></h2><p></p>
    $Fragment =~ s/(<\/h[1-6]><p>)$//;
    my $html = $1;
    $html .= "<!-- here: $pos -->";
    $Fragment .= ScriptLink("action=edit-paragraph;title=$OpenPageName;paragraph="
			    . UrlEncode($text), $EditParagraphPencil, 'pencil');
    $Fragment .= $html;
  }
  return EditParagraphOldCloseHtmlEnvironments(@_);
}
