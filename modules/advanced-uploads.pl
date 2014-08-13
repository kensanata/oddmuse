# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>

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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/advanced-uploads.pl">advanced-uploads.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Advanced_File_Upload_Extension">Advanced File Upload Extension</a></p>';

$HtmlHeaders .= '<script type="text/javascript" src="/js/uploader.js"></script>';

*AdvancedUploadsOldGetTextArea = *GetTextArea;
*GetTextArea = *AdvancedUploadsNewGetTextArea;

sub AdvancedUploadsNewGetTextArea {
  my ($name, $text, $rows) = @_;
  return AdvancedUploadsOldGetTextArea(@_) . $q->br() . ($name =~ 'text|aftertext' ? GetUploadForm() : '');
}

sub GetUploadForm {
    return $q->span({-class=>'upload'}, $q->label({-for=>'fileToUpload'}, T('Attach file:')),
                    $q->filefield(-name=>'fileToUpload', -id=>'fileToUpload', -multiple=>'multiple', -onChange=>'fileSelected()', -size=>20),
                    $q->span({-id=>'fileSize'}, ''),
                    $q->button(-name=>'uploadButton', -value=>T('Upload'), -onClick=>'uploadFile()'),
                    $q->span({-id=>'progressNumber'}));
}
