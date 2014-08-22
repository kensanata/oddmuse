# Copyright (C) 2014  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
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

AddModuleDescription('askpage.pl', 'Ask Page Extension');

use Fcntl qw(:DEFAULT :flock);

use vars qw($AskPage $QuestionPage $NewQuestion);
# Don't forget to set your $CommentsPattern to include both $AskPage and $QuestionPage
$AskPage = 'Ask';
$QuestionPage = 'Question_';
$NewQuestion = 'Write your question here:';

sub IncrementInFile {
  my $filename = shift;
  sysopen my $fh, $filename, O_RDWR|O_CREAT or die "can't open $filename: $!";
  flock $fh, LOCK_EX or die "can't flock $filename: $!";
  my $num = <$fh> || 1;
  seek $fh, 0, 0 or die "can't rewind $filename: $!";
  truncate $fh, 0 or die "can't truncate $filename: $!";
  (print $fh $num+1, "\n") or die "can't write $filename: $!";
  close $fh or die "can't close $filename: $!";
  return $num;
}

*OldAskPageDoPost=*DoPost;
*DoPost=*NewAskPageDoPost;
sub NewAskPageDoPost {
  my $id = FreeToNormal(shift);
  if ($id eq $AskPage and not GetParam('text', undef)) { # comment, not a regular edit
    my $currentQuestion = IncrementInFile("$DataDir/curquestion");
    $currentQuestion =~ s/[\s\n]//g;
    return OldAskPageDoPost($QuestionPage . $currentQuestion, @_); # hack page name
  }
  OldAskPageDoPost($id, @_); # keep original functionality for regular edits
}

*OldAskPageGetCommentForm=*GetCommentForm;
*GetCommentForm=*NewAskPageGetCommentForm;
sub NewAskPageGetCommentForm {
  my ($id, $rev, $comment) = @_;
  $NewComment = $NewQuestion if $id eq $AskPage;
  OldAskPageGetCommentForm(@_);
}

*OldAskPageJournalSort=*JournalSort;
*JournalSort=NewAskPageJournalSort;
sub NewAskPageJournalSort {
  return OldAskPageJournalSort() unless $a =~ m/^$QuestionPage\d+$/ and $b =~ m/^$QuestionPage\d+$/;
  ($b =~ m/$QuestionPage(\d+)/)[0] <=> ($a =~ m/$QuestionPage(\d+)/)[0];
}
