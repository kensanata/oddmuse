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

$ModulesDescription .= '<p>$Id: not-found-handler.pl,v 1.6 2004/06/26 00:00:31 as Exp $</p>';

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
  return if not -f $LinkFile;
  my $data = ReadFileOrDie($LinkFile);
  map { my ($id, @links) = split; $LinkDb{$id} = \@links } split(/\n/, $data);
}

sub WriteLinkDb { # call within the main lock!
  my $str = join("\n", map { join(' ', $_, @{$LinkDb{$_}}) } keys %LinkDb);
  WriteStringToFile($LinkFile, $str);
  return $str;
}

# create link database

sub DoLinkDb {
  print GetHeader('', QuoteHtml(T('Generating Link Database')), '');
  RequestLockOrError(); # fatal
  %LinkDb = %{GetFullLinkList(1, 0, 0, 1)};
  print $q->pre(WriteLinkDb());
  ReleaseLock();
  PrintFooter();
}

# refresh link database with data from the current open page

sub RefreshLinkDb {
  if (not defined(&GetLinkList)) {
    ReportError(T('The 404 handler extension requires the link data extension (links.pl).'));
    return;
  }
  if ($Page{revision} > 0 and not ($Page{blocks} && $Page{flags})) { #
    # make sure we have a cache!  We just discard this output, because
    # in a multilingual setting we would need to determine the correct
    # filename in which to store it in order to get headers
    # etc. right.
    *P = STDOUT;
    PrintWikiToHTML($Page{text}, 1, 0, 1); # revision 0, is already locked
    *STDOUT = *P;
  }
  my @links = GetLinkList(1, 0, 0, 1); # works on cached blocks...
  ReadLinkDb();
  if (@links) {
    $LinkDb{$OpenPageName} = \@links;
  } else {
    delete $LinkDb{$OpenPageName};
  }
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
  if (not -d $NotFoundHandlerDir) {
    mkdir($NotFoundHandlerDir);
  } elsif ($Page{revision} == 1) {
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
  # we will check for the current page, and for all the anchors defined on it.
  my @targets = ($id);
  if ($PermanentAnchors) {
    foreach ($Page{text} =~ m/\[::$FreeLinkPattern\]/g) {
      push(@targets, $1); # harmless: potentially adds duplicates
    }
  }
  # if any of the potential targets is the target of a link in the
  # link database, then the source page must be rendered anew.  in
  # other words, delete the cached version of the source page.
  my $target = '^(' . join('|', @targets) . ')$';
  warn "Unlinking pages pointing to $target\n";
  $target = qr($target);
  foreach my $source (keys %LinkDb) {
    warn "Examining $source\n";
    if (grep(/$target/, @{$LinkDb{$source}})) {
      unlink("$NotFoundHandlerDir/$source", glob("$NotFoundHandlerDir/$source.[a-z][a-z]"));
      warn "Unlinking $source\n";
    }
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
