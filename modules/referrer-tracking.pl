# Copyright (C) 2004, 2005, 2006  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: referrer-tracking.pl,v 1.12 2009/02/18 23:13:35 as Exp $</p>';

use LWP::UserAgent;

push(@KnownLocks, "refer_*");

$Action{refer} = \&DoPrintAllReferers;

use vars qw($RefererDir $RefererTimeLimit $RefererLimit $RefererFilter
%Referers);

$RefererTimeLimit = 86400; # How long referrals shall be remembered in seconds
$RefererLimit	  = 15;	   # How many different referer shall be remembered
$RefererFilter    = 'ReferrerFilter'; # Name of the filter page

push(@MyInitVariables, \&RefererInit);

sub RefererInit {
  $RefererFilter = FreeToNormal($RefererFilter); # spaces to underscores
  $AdminPages{$RefererFilter} = 1;
  $RefererDir  = "$DataDir/referer"; # Stores referer data
}

push(@MyAdminCode, \&RefererMenu);

sub RefererMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref, ScriptLink('action=refer', T('All Referrers'), 'refer'));
}

*RefererOldPrintFooter = *PrintFooter;
*PrintFooter = *RefererNewPrintFooter;

sub RefererNewPrintFooter {
  my ($id, $rev, $comment, @rest) = @_;
  if (not GetParam('embed', $EmbedWiki)) {
    my $referers = RefererTrack($id);
    print $referers if $referers;
  }
  RefererOldPrintFooter($id, $rev, $comment, @rest);
}

*RefererOldExpireKeepFiles = *ExpireKeepFiles;
*ExpireKeepFiles = *RefererNewExpireKeepFiles;

sub RefererNewExpireKeepFiles {
  RefererOldExpireKeepFiles(@_); # call with opened page
  ReadReferers($OpenPageName);   # clean up reading (expiring) and writing
  WriteReferers($OpenPageName);
}

*RefererOldDeletePage = *DeletePage;
*DeletePage = *RefererNewDeletePage;

sub RefererNewDeletePage {
  my $status = RefererOldDeletePage(@_);
  return $status if $status; # this would be the error message
  my $id = shift;
  my $fname = GetRefererFile($id);
  unlink($fname) if (-f $fname);
  return ''; # no error
}

## == Actual Code ==

sub GetRefererFile {
  my $id = shift;
  return $RefererDir . '/' . GetPageDirectory($id) . "/$id.rf";
}

sub ReadReferers {
  my $file = GetRefererFile(shift);
  %Referers = ();
  if (-f $file) {
    my ($status, $data) = ReadFile($file);
    %Referers = split(/$FS/, $data, -1) if $status;
  }
  ExpireReferers();
}

sub ExpireReferers { # no need to save the pruned list if nothing else changes
  if ($RefererTimeLimit) {
    foreach (keys %Referers) {
      if ($Now - $Referers{$_} > $RefererTimeLimit) {
	delete $Referers{$_};
      }
    }
  }
  if ($RefererLimit) {
    my @list = sort {$Referers{$a} cmp $Referers{$b}} keys %Referers;
    @list = @list[$RefererLimit .. @list-1];
    foreach (@list) {
      delete $Referers{$_};
    }
  }
}

# maybe test for valid utf-8 later?

# http://www.w3.org/International/questions/qa-forms-utf-8

# $field =~
#   m/^(
#      [\x09\x0A\x0D\x20-\x7E]            # ASCII
#    | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
#    |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
#    | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
#    |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
#    |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
#    | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
#    |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
#   )*$/x;

sub GetReferers {
  my $result = join(' ', map {
    my $title = QuoteHtml($_);
    $title = $1 if $title =~ /$FullUrlPattern/; # extract valid URL
    my ($ts, $charset) = split(/ /, $Referers{$_});
    $title =~ s/\%([0-9a-f][0-9a-f])/chr(hex($1))/egi
      if lc($charset) eq lc($HttpCharset); # decode if possible
    $q->a({-href=>$_}, $title);
  } keys %Referers);
  return $q->div({-class=>'refer'}, $q->p(T('Referrers') . ': ' . $result))
    if $result;
}

sub UpdateReferers {
  my $self = $ScriptName;
  my $referer = $q->referer();
  return  unless $referer and $referer !~ /$self/;
  foreach (split(/\n/,GetPageContent($RefererFilter))) {
    if (/^ ([^ ]+)[ \t]*$/) {  # only read lines with one word after one space
      my $regexp = $1;
      return  if $referer =~ /$regexp/i;
    }
  }
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($referer);
  return unless $response->is_success and $response->content =~ /$self/;
  my ($charset) = $response->header("Content-Type") =~ /charset=([^\s";]*)/;
  $Referers{$referer} = "$Now $charset"; # numerical comparisons still work!
  return 1;
}

sub WriteReferers {
  my $id = shift;
  return unless RequestLockDir('refer_' . $id); # not fatal
  my $data = join($FS, %Referers);
  my $file = GetRefererFile($id);
  if ($data) {
    CreatePageDir($RefererDir, $id);
    WriteStringToFile($file, $data);
  } else {
    unlink $file; # just try it, doesn't matter if it fails
  }
  ReleaseLockDir('refer_' . $id);
}

sub RefererTrack {
  my $id = shift;
  return unless $id;
  ReadReferers($id);
  WriteReferers($id) if UpdateReferers($id);
  return GetReferers();
}

sub DoPrintAllReferers {
  print GetHeader('', T('All Referrers'), ''), $q->start_div({-class=>'content refer'});
  PrintAllReferers(AllPagesList());
  print $q->end_div();
  PrintFooter();
}

sub PrintAllReferers {
  for my $id (@_) {
    ReadReferers($id);
    print $q->div({-class=>'page'},
		  $q->p(GetPageLink($id)),
		  GetReferers()) if %Referers;
  }
}
