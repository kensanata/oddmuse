# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
# Copyright (C) 2011  Alex Schroeder <alex@gnu.org>

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

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/git-another.pl">git-another.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Another_Git_Extension">Another Git Extension</a></p>';

use Cwd;
use Capture::Tiny ':all';
use vars qw($GitBinary $GitMail);

$GitBinary = 'git';
$GitMail = 'unknown@oddmuse.org';

sub GitCommit {
  my ($message, $author) = @_;
  my $oldDir = cwd;
  chdir("$DataDir/page");
  capture {
    system($GitBinary, qw(add -A));
    system($GitBinary, qw(commit -q -m), $message, "--author=$author <$GitMail>");
  };
  chdir($oldDir);
}

sub GitInitRepository {
  return if -d "$DataDir/page/.git";
  capture {
    system($GitBinary, qw(init -q --), "$DataDir/page");
  };
  GitCommit('Initial import', 'Oddmuse');
}

sub RenderHtmlCacheWithoutPrinting { # requires an open page
  $FootnoteNumber = 0;
  my $blocks, $flags;
  capture {
    ($blocks, $flags) = ApplyRules(QuoteHtml($Page{text}), 1, 1, $Page{revision}, 'p');
  };
  if ($Page{blocks} ne $blocks and $Page{flags} ne $flags) {
    $Page{blocks} = $blocks;
    $Page{flags}  = $flags;
    SavePage();
  }
}

*GitOldSave = *Save;
*Save = *GitNewSave;

sub GitNewSave {
  GitInitRepository();
  GitCommit('No description available', 'Oddmuse'); # commit any changes before this edit
  GitOldSave(@_);
  RenderHtmlCacheWithoutPrinting();
  my $message = $Page{summary};
  $message =~ s/^\s+$//;
  $message ||= T('No summary provided');
  my $author = $Page{username} || T('Anonymous');
  GitCommit($message, $author); # commit this edit
}
