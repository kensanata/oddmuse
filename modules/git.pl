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

=head1 NAME

git - An Oddmuse module to save all changes made into a git repository.

=head1 INSTALLATION

This module is easily installable; move this file into the B<modules>
subdirectory for your data directory (C<$DataDir>).

=cut

package OddMuse;

=head1 CONFIGURATION

Set these variables in the B<config> file within your data directory.

=head2 $GitBinary

Default: C</usr/bin/git>

The fully qualified name for the binary to run. Your PATH will not be searched.

=head2 $GitRepo

Default: C<$DataDir/git>

The directory in which the repository resides. If it doesn't exist,
Oddmuse will create it for you.

=head2 $GitMail

Default: C<unknown@oddmuse.org>

The email address used to identify users in git.

=cut

use vars qw($GitBinary $GitRepo $GitMail);

$GitBinary = '/usr/bin/git';
$GitMail = 'unknown@oddmuse.org';

push(@MyInitVariables, \&GitInitVariables);

sub GitRun {
  my $result = '';
  local *STDOUT;
  open(STDOUT, '>', \$result) or die "Can't open memory file: $!";
  system($GitBinary, @_) == 0
    or ReportError("git failed: $!",
		   "500 INTERNAL SERVER ERROR",
		   undef,
		   $q->p($q->tt(join(' ', $GitBinary, map {
		     if (index($_, ' ') == -1) {
		      $_;
		     } else {
		       "'$_'";
		     }
		   } @_))),
		   $q->pre($result));
}

sub GitInitVariables {
  $GitRepo = $DataDir . '/git';
}

sub GitInitRepository {
  if (not -d "$GitRepo/.git") {
    CreateDir($GitRepo);
    chdir($GitRepo); # important for all the git commands that follow!
    GitRun('init', '--quiet');
    foreach my $id (AllPagesList()) {
      OpenPage($id);
      WriteStringToFile("$GitRepo/$id", $Page{text});
      GitRun('add', $id);
    }
    GitRun('commit', '--quiet', '-m', 'initial import',
	   "--author=Oddmuse <$GitMail>");
  } else {
    chdir($GitRepo); # important for all the git commands that follow!
  }
}

*GitOldSave = *Save;
*Save = *GitNewSave;

sub GitNewSave {
  GitOldSave(@_);
  GitInitRepository();
  my ($id) = @_;
  WriteStringToFile("$GitRepo/$id", $Page{text});
  if ($Page{revision} == 1) {
    GitRun('add', $id);
  }
  my $message = $Page{summary};
  $message =~ s/^\s+$//;
  $message ||= T('no summary available');
  my $author = $Page{username} || T('Anonymous');
  GitRun('commit', '--quiet', '-m', $message,
	 "--author=$author <$GitMail>", $id);
}

*GitOldDeletePage = *DeletePage;
*DeletePage = *GitNewDeletePage;

sub GitNewDeletePage {
  my $error = GitOldDeletePage(@_);
  return $error if $error;
  GitInitRepository();
  my ($id) = @_;
  GitRun('rm', '--quiet', '--ignore-unmatch', $id);
  my $message = T('page was marked for deletion');
  my $author = T('Oddmuse');
  GitRun('commit', '--quiet', '-m', $message,
	 "--author=$author <$GitMail>", $id);
  return ''; # no error
}

push(@MyMaintenance, \&GitCleanup);

sub GitCleanup {
  if (-d $GitRepo) {
    # delete all the files including all the files starting with a dot
    opendir(DIR, $GitRepo) or ReportError("cannot open directory $GitRepo: $!");
    foreach my $file (readdir(DIR)) {
      next if $file eq '.git' or $file eq '.' or $file eq '..';
      unlink "$GitRepo/$file" or ReportError("cannot delete $GitRepo/$file: $!");
    }
    closedir DIR;
    # write all the files again
    foreach my $id (AllPagesList()) {
      OpenPage($id);
      WriteStringToFile("$GitRepo/$id", $Page{text});
    }
    # commit the new state
    chdir($GitRepo); # important for all the git commands that follow!
    GitRun('commit', '--quiet', '-a', '-m', 'maintenance job',
	   "--author=Oddmuse <$GitMail>");
  }
}
