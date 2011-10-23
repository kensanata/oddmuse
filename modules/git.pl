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

You should make sure that the script can execute git. Make sure to add
git's directory to C<$ENV{PATH}> in your B<config> file, if necessary
(the default value is pretty restricted):

    $ENV{PATH} .= ":/usr/local/bin"; # git

=cut

package OddMuse;

=head1 CONFIGURATION

Set these variables in the B<config> file within your data directory.

=head2 $GitDir

Default: C<$DataDir/git>

The directory in which the repository resides. If it doesn't exist,
Oddmuse will create it for you.

=head2 $GitMail

Default: C<unknown@oddmuse.org>

The email address used to identify users in git.

=cut

use vars qw($GitDir $GitMail);

$GitMail = 'unknown@oddmuse.org';

push(@MyInitVariables, \&GitInitVariables);

sub GitInitVariables {
  $GitDir = $DataDir . '/git';
}

sub GitInitRepository {
  if (not -d "$GitDir/.git") {
    CreateDir($GitDir);
    chdir($GitDir); # important for all the git commands that follow!
    system(qw(git init --quiet))  == 0
      or ReportError("git init failed: $!");
    foreach my $id (AllPagesList()) {
      OpenPage($id);
      WriteStringToFile("$GitDir/$id", $Page{text});
      system(qw(git add), $id)  == 0
	or ReportError("git add $id failed: $!");
    }
    system(qw(git commit -m), "initial import",
	   "--author=Oddmuse <$GitMail>") == 0
	     or ReportError("git initial commit failed: $!");
  } else {
    chdir($GitDir); # important for all the git commands that follow!
  }
}

*GitOldSave = *Save;
*Save = *GitNewSave;

sub GitNewSave {
  GitOldSave(@_);
  GitInitRepository();
  my ($id) = @_;
  WriteStringToFile("$GitDir/$id", $Page{text});
  if ($Page{revision} == 1) {
    system(qw(git add), $id) == 0
      or ReportError("git add $id failed: $!");
  }
  my $message = $Page{summary} || T('no summary available');
  my $author = $Page{username} || T('Anonymous');
  system(qw(git commit --quiet -m), $message,
	 "--author=$author <$GitMail>",
	 $id) == 0 or ReportError("git commit $id failed: $!");
}

*GitOldDeletePage = *DeletePage;
*DeletePage = *GitNewDeletePage;

sub GitNewDeletePage {
  my $error = GitOldDeletePage(@_);
  return $error if $error;
  GitInitRepository();
  my ($id) = @_;
  system(qw(git rm --quiet --ignore-unmatch), $id) == 0
    or ReportError("git rm $id failed: $!");
  my $message = T('page marked was for deletion');
  my $author = T('Oddmuse');
  system(qw(git commit --quiet -m), $message,
	 "--author=$author <$GitMail>",
	 $id) == 0 or ReportError("git commit $id failed: $!");
  return ''; # no error
}

push(@MyMaintenance, \&GitCleanup);

sub GitCleanup {
  if (-d $GitDir) {
    # delete all the files including all the files starting with a dot
    opendir(DIR, $GitDir) or ReportError("cannot open directory $GitDir: $!");
    foreach my $file (readdir(DIR)) {
      next if $file eq '.git' or $file eq '.' or $file eq '..';
      unlink "$GitDir/$file" or ReportError("cannot delete $GitDir/$file: $!");
    }
    closedir DIR;
    # write all the files again
    foreach my $id (AllPagesList()) {
      OpenPage($id);
      WriteStringToFile("$GitDir/$id", $Page{text});
    }
    # commit the new state
    chdir($GitDir); # important for all the git commands that follow!
    system(qw(git add --all)) == 0
      or ReportError("git add -A failed: $!");
    system(qw(git commit --quiet -m), 'maintenance job',
	   "--author=Oddmuse <$GitMail>",
	   $id) == 0 or ReportError("git maintenance commit failed: $!");
  }
}
