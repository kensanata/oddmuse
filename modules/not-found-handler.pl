# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

$ModulesDescription .= '<p>$Id: not-found-handler.pl,v 1.5 2004/06/13 14:46:50 as Exp $</p>';

use vars qw($NotFoundHandlerDir, $LinkFile, %LinkDb, $LinkDbInit);

$NotFoundHandlerDir = '/tmp/oddmuse/cache';
$LinkFile = "$DataDir/linkdb";
$LinkDbInit = 0;

$Action{linkdb} = \&DoLinkDb;
$Action{clearcache} = \&DoClearCache;

sub DoClearCache {
  print GetHeader('', QuoteHtml(T('Clearing Cache')), '');
  unlink(glob("$NotFoundHandlerDir/*"));
  print $q->p(T('Done.'));
  PrintFooter();
}

# file handling

sub ReadLinkDb {
  return if $LinkDbInit;
  $LinkDbInit = 1;
  my $data = ReadFileOrDie($LinkFile);
  map { my ($id, @links) = split; $LinkDb{$id} = \@links } split(/\n/, $data);
}

sub WriteLinkDb {
  my $str = join("\n", map { join(' ', $_, @{$LinkDb{$_}}) } keys %LinkDb);
  RequestLockOrError(); # fatal
  WriteStringToFile($LinkFile, $str);
  ReleaseLock();
  return $str;
}

# create link database

sub DoLinkDb {
  print GetHeader('', QuoteHtml(T('Generating Link Database')), '');
  %LinkDb = %{GetFullLinkList(1, 0, 0, 1)};
  print $q->pre(WriteLinkDb());
  PrintFooter();
}

# refresh link database with data from the current open page

sub RefreshLinkDb {
  ReadLinkDb();
  my @links = GetLinkList(1, 0, 0, 1);
  $LinkDb{$OpenPageName} = \@links;
  WriteLinkDb();
}

# maintain link database

*OldNotFoundHandlerSave = *Save;
*Save = *NewNotFoundHandlerSave;

sub NewNotFoundHandlerSave {
  my @args = @_;
  my $id = $args[0];
  OldNotFoundHandlerSave(@args);
  RefreshLinkDb(); # for the open page
  mkdir($NotFoundHandlerDir) unless -d $NotFoundHandlerDir;
  if ($Page{revision} == 1) {
    NotFoundHandlerCacheUpdate($id);
  } else {
    # unlink PageName, PageName.en, PageName.de, etc.
    unlink("$NotFoundHandlerDir/$id", glob("$NotFoundHandlerDir/$id.[a-z][a-z]"));
  }
}

sub NotFoundHandlerCacheUpdate {
  my $id = shift;
  # new or deleted page: regenerate all pages that link to this page,
  # or to the permanent anchors defined on this page.
  ReadLinkDb();
  my @pages = @{$LinkDb{$id}};
  if ($PermanentAnchors) {
    foreach ($Page{text} =~ m/\[::$FreeLinkPattern\]/g) {
      push(@pages, @{$LinkDb{$1}}); # harmless: potentially adds duplicates
    }
  }
  foreach my $page (@pages) {
    unlink("$NotFoundHandlerDir/$page", glob("$NotFoundHandlerDir/$page.[a-z][a-z]"));
  }
}

*OldNotFoundHandlerDeletePage = *DeletePage;
*DeletePage = *NewNotFoundHandlerDeletePage;

sub NewNotFoundHandlerDeletePage {
  my $id = shift;
  OpenPage($id); # Page{text} is required to find permanent anchors defined on this page
  if (DeletePage($id) eq '') {
    NotFoundHandlerCacheUpdate($id);
  }
}
