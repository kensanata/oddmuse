# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2014  Aki Goto <tyatsumi@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

=head1 Balanced Page Directories

By default, Oddmuse disperses page data files into 27 directories
based on the first character of the page name. The directories are "A"
to "Z", and "other". If you use your wiki as a blog, all the pages
starting with a date end up in "other". If your page names start with
letters other than "A" to "Z", all the pages end up in "other". If you
are using comment pages, all your comment pages end in "C". This can
turn into a problem if you reach ten thousand pages and more in a
single directory.

=over

The ext2 inode specification allows for over 100 trillion files to
reside in a single directory, however because of the current
linked-list directory implementation, only about 10-15 thousand files
can realistically be stored in a single directory. – L<haversian-ga on
09 Dec 2002 22:56
PST|http://answers.google.com/answers/threadview?id=122241>

=back

CAUTION: When this extension is installed, your data structure I<must>
change. Make sure you have a backup of your data directory somewhere.

=head2 Finding the right directory

On the command line, finding the right subdirectory can be a problem.
Here's how to use md5sum. Note that the -n option to echo prevents the
trailing newline. Its inclusion would change the checksum.

    echo -n HomePage | md5sum | cut -c 1-2
    c1
    echo -n ホームページ | md5sum | cut -c 1-2
    10

=head2 $BalancedPageDirectoriesSize

If you have more than 2560000 pages (w00t!) you might want to set
$BalancedPageDirectoriesSize to 3. This will give you 16× more
directories, which should let you have 40960000 pages. Also, please
let us know about your wiki. :)

=head2 Migration

Once you install the code, reload any page. This should trigger
migration. No output is produced during migration. Migration is
triggered whenever a page file isn't found but a page is found at the
default old location. If, for example, $PageDir/c1/HomePage.pg doesn't
exist but $PageDir/h/HomePage.pg does, and the wiki can be locked, the
wiki is locked and migration is started.

=cut

$ModulesDescription .= '<p><a href="http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/balanced-page-directories.pl">balanced-page-directories.pl</a>, see <a href="http://www.oddmuse.org/cgi-bin/oddmuse/Balanced_Page_Directories_Extension">Balanced Page Directories Extension</a>';

use Digest::MD5 qw(md5_hex);
use File::Find qw(finddepth);
use vars qw($BalancedPageDirectoriesSize);

$BalancedPageDirectoriesSize = 2;

*OldBalancedPageDirectoriesGetPageDirectory = *GetPageDirectory;
*GetPageDirectory = *NewBalancedPageDirectoriesGetPageDirectory;

sub NewBalancedPageDirectoriesGetPageDirectory {
  my $id = shift;
  utf8::encode($id);
  return substr(md5_hex($id), 0, $BalancedPageDirectoriesSize);
}

*OldBalancedPageDirectoriesOpenPage = *OpenPage;
*OpenPage = *NewBalancedPageDirectoriesOpenPage;

sub NewBalancedPageDirectoriesOpenPage {
  my $id = shift;
  if (! -f GetPageFile($id)) {
    BalancedPageDirectoriesMigrate($id);
  }
  return OldBalancedPageDirectoriesOpenPage($id, @_);
}

sub BalancedPageDirectoriesMigrate {
  my $id = shift;

  # This code is called if the page file does not exist. Perhaps we
  # need to migrate? Check if the old page file exists. If it does
  # not, there is no point in migration.
  *GetPageDirectory = *OldBalancedPageDirectoriesGetPageDirectory;
  if (not -f GetPageFile($id)) {
    *GetPageDirectory = *NewBalancedPageDirectoriesGetPageDirectory;
    return;
  }

  # Make sure we can change the data structure now.
  RequestLockOrError();

  # Now we know that we need to migrate. The list of pages is scanned
  # using globbing.
  SetParam('refresh', 1);

  for $id (AllPagesList()) {

    *GetPageDirectory = *OldBalancedPageDirectoriesGetPageDirectory;
    my $page_from = GetPageFile($id);
    my $keep_from = GetKeepDir($id);
    my $lock_from = GetLockedPageFile($id);
    my $joiner_from = $JoinerDir . '/' . GetPageDirectory($username) if $JoinerDir;
    my $joiner_email_from = $JoinerEmailDir . '/' . GetPageDirectory($username) if $JoinerEmailDir;
    my $referrer_from = $RefererDir . '/' . GetPageDirectory($id) if $RefererDir;
    *GetPageDirectory = *NewBalancedPageDirectoriesGetPageDirectory;
    my $page_to = GetPageFile($id);
    my $keep_to = GetKeepDir($id);
    my $lock_to = GetLockedPageFile($id);
    my $joiner_to = $JoinerDir . '/' . GetPageDirectory($username) if $JoinerDir;
    my $joiner_email_to = $JoinerEmailDir . '/' . GetPageDirectory($username) if $JoinerEmailDir;
    my $referrer_to = $RefererDir . '/' . GetPageDirectory($id) if $RefererDir;

    # no clobbering
    if (! -f $page_to) {
      CreatePageDir($PageDir, $id);
      rename $page_from, $page_to || ReportError("Cannot rename $page_from");
    }
    if (-f $lock_from and ! -f $lock_to) {
      rename $lock_from, $lock_to || ReportError("Cannot rename $lock_from");
    }
    if (-d $keep_from and ! -d $keep_to) {
      CreateKeepDir($KeepDir, $id);
      rename $keep_from, $keep_to || ReportError("Cannot rename $keep_from");
    }
    if ($joiner_from and -d $joiner_from and ! -d $joiner_to) {
      CreatePageDir($JoinerDir, $id);
      rename $joiner_from, $joiner_to || ReportError("Cannot rename $joiner_from");
    }
    if ($joiner_email_from and -d $joiner_email_from and ! -d $joiner_email_to) {
      CreatePageDir($JoinerEmailDir, $id);
      rename $joiner_email_from, $joiner_email_to || ReportError("Cannot rename $joiner_email_from");
    }
    if ($referrer_from and -d $referrer_from and ! -d $referrer_to) {
      CreateRefererDir($RefererDir, $id);
      rename $referrer_from, $referrer_to || ReportError("Cannot rename $referrer_from");
    }
  }

  # Delete empty subdirectories. Actually, attempt to delete all the
  # directories, depth first. It will simply fail for the non-empty
  # directories. http://www.perlmonks.org/?node_id=520791
  for my $parent ($PageDir, $KeepDir, $JoinerDir, $JoinerEmailDir, $RefererDir) {
    next unless $parent;
    finddepth(sub { rmdir $_ if -d }, $parent);
  }

  ReleaseLock();
}
