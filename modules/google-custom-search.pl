# Copyright (C) 2007  Alex Schroeder <alex@gnu.org>
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
# along with this program; if not, write to the
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: google-custom-search.pl,v 1.1 2007/12/26 08:59:11 as Exp $</p>';

# disable search form
sub GetSearchForm {}

# No more searching of titles
sub GetSearchLink {
  my $title = NormalToFree(shift);
  my $term = UrlEncode($title);
  return qq{<a href="http://www.google.com/cse?cx=004774160799092323420:6-ff2s0o6yi&q=$term">$title</a>};
}

*OldGoogleCustomGetHeader = *GetHeader;
*GetHeader = *NewGoogleCustomGetHeader;

sub NewGoogleCustomGetHeader {
  my $html = OldGoogleCustomGetHeader(@_);
  $form .= qq {
<!-- Google CSE Search Box Begins  -->
<form class="tiny" action="http://www.google.com/cse" id="searchbox_004774160799092323420:6-ff2s0o6yi"><p>
<input type="hidden" name="cx" value="004774160799092323420:6-ff2s0o6yi" />
<input type="text" name="q" size="25" />
<input type="submit" name="sa" value="Search" />
</p></form>
<script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=searchbox_004774160799092323420%3A6-ff2s0o6yi"></script>
<!-- Google CSE Search Box Ends -->
};
  $html =~ s{</span>}{</span>$form};
  return $html;
}


