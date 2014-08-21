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

Default: C<git>

The fully qualified name for the binary to run. Your PATH will not be searched.

=head2 $GitRepo

Default: C<$DataDir/git>

The directory in which the repository resides. If it doesn't exist,
Oddmuse will create it for you.

=head2 $GitMail

Default: C<unknown@oddmuse.org>

The email address used to identify users in git.

=head2 $GitDebug

Default: 0

If set, we capture the output of the git command and store it in
$GitResult. This is useful when writing tests.

=head2 $GitResult

If $GitDebug is set, this variable holds STDOUT of the git command.

=cut

use Cwd;
use File::Temp ();
use vars qw($GitBinary $GitRepo $GitMail $GitPageFile $GitDebug $GitResult);

AddModuleDescripton('git.pl', 'Git Extension');

$GitBinary = 'git';
$GitMail = 'unknown@oddmuse.org';
$GitPageFile = 0;

push(@MyInitVariables, \&GitInitVariables);

sub GitRun {
  my $oldDir = cwd;
  my $exitStatus;
  # warn join(' ', $GitBinary, @_) . "\n";

  chdir($GitRepo);
  if ($GitDebug) {
    # capture the output of the git comand in a temporary file
    my $fh = File::Temp->new();
    open(my $oldout, ">&STDOUT") or die "Can't dup STDOUT: $!";
    open(STDOUT, '>', $fh) or die "Can't redirect STDOUT: $!";
    # run git in the work directory
    $exitStatus = system($GitBinary, @_);
    # read the temporary file with the output
    close($fh);
    open(STDOUT, ">&", $oldout) or die "Can't dup \$oldout: $!";
    open(F, '<', $fh) or die "Can't open temp file for reading: $!";
    local $/ = undef; # Read complete files
    $GitResult = <F>;
    close(F);
  } else {
    $exitStatus = system($GitBinary, @_);
  }
  chdir($oldDir);
  return $exitStatus;
}

sub GitInitVariables {
  $GitRepo = $DataDir . '/git';
}

sub GitInitRepository {
  return if -d "$GitRepo/.git";
  my $exception = shift;
  CreateDir($GitRepo);
  GitRun(qw(init --quiet));
  # Add legacy pages: If you installed this extension for an older
  # wiki, all the existing pages need to be added. We do this for all
  # the pages except for the one we just saved. That page will get a
  # better author and log message.
  foreach my $id (AllPagesList()) {
    next if $id eq $exception;
    OpenPage($id);
    WriteStringToFile("$GitRepo/$id", $GitPageFile ? EncodePage(%Page) : $Page{text});
    GitRun(qw(add --), $id);
  }
  GitRun(qw(commit --quiet -m), 'initial import', "--author=Oddmuse <$GitMail>");
}

*GitOldSave = *Save;
*Save = *GitNewSave;

sub GitNewSave {

  # Save is called within lock, with opened page. That's why we cannot
  # call GitInitRepository right away, because it opens all the legacy
  # pages to save them, too. We need to save first.
  GitOldSave(@_);

  # We also need to save all the data from the open page.
  my $message = $Page{summary};
  $message =~ s/^\s+$//;
  $message ||= T('no summary available');
  my $author = $Page{username} || T('Anonymous');
  my $data = $GitPageFile ? EncodePage(%Page) : $Page{text};
  my $id = shift;
  # GitInitRepository will try to add and commit all the pages already
  # in the wiki. These are assumed to be legacy pages. The page we
  # just saved, however, should not be committed as a legacy page
  # because legacy pages are committed with a default author and log
  # message!
  GitInitRepository($id);
  WriteStringToFile("$GitRepo/$id", $data);
  GitRun(qw(add --), $id);
  GitRun(qw(commit --quiet -m), $message,
	 "--author=$author <$GitMail>", '--', $id);
}

*GitOldDeletePage = *DeletePage;
*DeletePage = *GitNewDeletePage;

sub GitNewDeletePage {
  my $error = GitOldDeletePage(@_);
  return $error if $error;
  GitInitRepository();
  my ($id) = @_;
  GitRun(qw(rm --quiet --ignore-unmatch --), $id);
  my $message = T('page was marked for deletion');
  my $author = T('Oddmuse');
  GitRun(qw(commit --quiet -m), $message,
	 "--author=$author <$GitMail>", '--', $id);
  return ''; # no error
}

push(@MyMaintenance, \&GitCleanup);

$Action{git} = \&DoGitCleanup;

sub DoGitCleanup {
  UserIsAdminOrError();
  print GetHeader('', 'Git', '');
  print $q->start_div({-class=>'content git'});
  RequestLockOrError();
  print $q->p(T('Main lock obtained.')), '<p>', T('Cleaning up git repository');
  GitCleanup();
  ReleaseLock();
  print $q->p(T('Main lock released.')), $q->end_div();
  PrintFooter();
}

sub GitCleanup {
  if (-d $GitRepo) {
    print $q->p('Git cleanup starting');
    AllPagesList();
    # delete all the files including all the files starting with a dot
    opendir(DIR, $GitRepo) or ReportError("cannot open directory $GitRepo: $!");
    foreach my $file (readdir(DIR)) {
      my $name = $file;
      utf8::decode($name); # filenames are bytes
      next if $file eq '.git' or $file eq '.' or $file eq '..' or $IndexHash{$name};
      print $q->p("Deleting left over file $name");
      unlink "$GitRepo/$file" or ReportError("cannot delete $GitRepo/$name: $!");
    }
    closedir DIR;
    # write all the files again, just to be sure
    print $q->p('Rewriting all the files, just to be sure');
    foreach my $id (@IndexList) {
      OpenPage($id);
      WriteStringToFile("$GitRepo/$id", $GitPageFile ? EncodePage(%Page) : $Page{text});
    }
    # run git!
    # add any new files
    print $q->p('Adding new files, if any');
    GitRun(qw(add -A));
    # commit the new state
    print $q->p('Committing changes, if any');
    my $exitStatus = GitRun(qw(commit --quiet -m), 'maintenance job',
			    "--author=Oddmuse <$GitMail>");
    print $q->p('git commit finished with ' . $exitStatus . ' exit status.');
    print $q->p('Git done');
  }
}
