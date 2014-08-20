# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 't/test.pl';
package OddMuse;
use Test::More tests => 15;
use utf8; # test data is UTF-8 and it matters

SKIP: {

  clear_pages();

  test_page(update_page('Legacy', 'an old page'), 'an old page');

  add_module('git.pl');

  if (qx($GitBinary --version) !~ /git version/) {
    skip "$GitBinary not found", 15;
  }
  GitInitVariables();

  test_page(update_page('Test', 'Something'), # default summary = page text
	    'Something');

  test_page(update_page('Test', 'Some other thing', 'a summary is provided'),
	    'Some other thing');

  test_page(update_page('Test', 'No summary is provided'),
	    'No summary is provided');

  # Use GitRun so that git gets to run inside $GitRepo. Use $GitResult
  # to peek at the stdout of the git command. This is probably
  # clobbered in a mod_perl environment.

  $GitDebug = 1;
  $GitResult = '';

  GitRun(qw(status));
  test_page($GitResult,
	    'nothing to commit, working directory clean');
  
  GitRun(qw(log -- Test));
  test_page($GitResult,
	    'Author: Anonymous <unknown\@oddmuse.org>',
	    '    Something',
	    '    a summary is provided',
	    '    no summary available');
  test_page_negative($GitResult,
	    'initial import');
  
  GitRun(qw(log -- Legacy));
  test_page($GitResult,
	    'Author: Oddmuse <unknown\@oddmuse.org>',
	    'initial import');
  
  # use username Alex to save a new revision
  get_page("title=Test text=Otherness username=Alex");
  test_page(get_page('Test'), 'Otherness');
  GitRun(qw(log));
  test_page($GitResult, 'Author: Alex <unknown\@oddmuse.org>');

  # one for every update_page and one for the get_page with username
  my @matches = $GitResult =~ /commit/g;
  ok(scalar(@matches) == 5, "number of commits adds up");
}
