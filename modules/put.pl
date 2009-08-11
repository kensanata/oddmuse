# Copyright (C) 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 Put Extension

This module allows you to upload wiki pages using the PUT request
method. For example:

    echo test | curl -T - http://www.emacswiki.org/cgi-bin/test/Mu

This will replace the Mu page with "test".

Note that you cannot use an URL that will be rewritten by Apache
mod_rewrite as the target for your PUT request. Apparently mod_rewrite
only works reliably for GET requests.

=cut

push(@MyInitVariables, \&PutMethodHandler);

sub PutMethodHandler {
  if ($q->request_method() eq 'PUT') {
    my $data;
    while (<STDIN>) {
      $data .= $_;
      # protect against denial of service attacks?
      if (length($data) > $MaxPost) {
        ReportError(T('Upload is limited to %s bytes', $MaxPost),
                    '413 REQUEST ENTITY TOO LARGE');
      }
    }
    SetParam('title', GetId());
    SetParam('text', $data);
  }
}
