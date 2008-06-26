# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#	 Free Software Foundation, Inc.
#	 59 Temple Place, Suite 330
#	 Boston, MA 02111-1307 USA

$ModulesDescription .= '<p>$Id: static-hybrid.pl,v 1.14 2008/06/26 08:54:59 weakish Exp $</p>';

$Action{static} = \&DoStatic;

use vars qw($StaticDir $StaticAlways %StaticMimeTypes $StaticUrl
%StaticLinkedPages @StaticIgnoredPages);

$StaticDir = '' unless defined $StaticDir;
$StaticUrl = '' unless defined $StaticUrl;	  # change this!
$StaticAlways = 0 unless defined $StaticFilesAlways;
		# 1 = uploaded files only, 2 = all pages

my $StaticMimeTypes = '/etc/http/mime.types';
my %StaticFiles;

my $StaticAction = 0;	# Are we doing action or not?
my @StaticQueue = ();

my $ClusterHasChanged = 0;
my $PageBeingSaved = "";

sub DoStatic {
	$StaticAction = 1;
	return unless UserIsAdminOrError();
	my $raw = GetParam('raw', 0);
	if ($raw) {
		print GetHttpHeader('text/plain');
	} else {
		print GetHeader('', T('Static Copy'), '');
	}
	CreateDir($StaticDir);
	%StaticMimeTypes = StaticMimeTypes() unless %StaticMimeTypes;
	%StaticFiles = ();
	my $id = GetParam('id', '');
	if ($id) {
		local *GetDownloadLink = *StaticGetDownloadLink;
		StaticWriteFile($id);
	} else {
		StaticWriteFiles();
	}
	print '</p>' unless $raw;
	PrintFooter() unless $raw;
}

sub StaticMimeTypes {
	my %hash;
	# the default mapping matches the default @UploadTypes...
	open(F,$StaticMimeTypes)
		or return ('image/jpeg' => 'jpg', 'image/png' => 'png', 'image/gif' => 'gif');
	while (<F>) {
		s/\#.*//;					# remove comments
			my($type, $ext) = split;
		$hash{$type} = $ext if $ext;
	}
			close(F);
		return %hash;
}

sub StaticWriteFiles {
	my $raw = GetParam('raw', 0);
	local *GetDownloadLink = *StaticGetDownloadLink;
	foreach my $id (AllPagesList()) {
		SetParam('rcclusteronly',0);
		if (! grep(/^$id$/,@StaticIgnoredPages)) {
			StaticWriteFile($id);
		}
	}
}

sub StaticGetDownloadLink {
	my ($name, $image, $revision, $alt) = @_; # ignore $revision
	$alt = $name unless $alt;
	my $id = FreeToNormal($name);
	AllPagesList();
	# if the page does not exist
	return '[' . ($image ? 'image' : 'link') . ':' . $name . ']' unless $IndexHash{$id};
	if ($image) {
		my $result = $q->img({-src=>StaticFileName($id), -alt=>$alt, -class=>'upload'});
		$result = ScriptLink($id, $result, 'image');
		return $result;
	} else {
		return ScriptLink($id, $alt, 'upload');
	}
}

sub StaticFileName {
	my $id = shift;
	$id =~ s/ /_/g;
	$id =~ s/#.*//;		  # remove named anchors for the filename test
	return $StaticFiles{$id} if $StaticFiles{$id}; # cache filenames
	my ($status, $data) = ReadFile(GetPageFile(StaticUrlDecode($id)));
	print "cannot read " . GetPageFile(StaticUrlDecode($id)) . $q->br() unless $status;
	my %hash = ParseData($data);
	my $ext = '.html';
	if ($hash{text} =~ /^\#FILE ([^ \n]+)\n(.*)/s) {
		$ext = $StaticMimeTypes{$1};
		$ext = '.' . $ext if $ext;
	}
	$StaticFiles{$id} = $id . $ext;
	return $StaticFiles{$id};
}

sub StaticUrlDecode {
	my $str = shift;
	$str =~ s/%([0-9a-f][0-9a-f])/chr(hex($1))/ge;
	return $str;
}

sub StaticWriteFile {
	my $id = shift;
	my $raw = GetParam('raw', 0);
	my $html = GetParam('html', 1);
	my $filename = StaticFileName($id);

	OpenPage($id);
	my ($mimetype, $data) = $Page{text} =~ /^\#FILE ([^ \n]+)\n(.*)/s;
	return unless $html or $data;
	open(F,"> $StaticDir/$filename") or ReportError(Ts('Cannot write %s', $filename));
	if ($data) {
		StaticFile($id, $mimetype, $data);
	} elsif ($html) {
		StaticHtml($id);
	}
	close(F);
	chmod 0644,"$StaticDir/$filename";
	if (lc(GetParam('action','')) eq "static") {
		print $filename, $raw ? "\n" : $q->br();
	}
}

sub StaticFile {
	my ($id, $type, $data) = @_;
	require MIME::Base64;
	binmode(F);
	print F MIME::Base64::decode($data);
}

sub StaticHtml {
	my $id = FreeToNormal(shift);
	my $title = $id;
	$title =~ s/_/ /g;
	my $result = '';
	
	local *GetHttpHeader = *StaticGetHttpHeader;
	local *GetCommentForm = *StaticGetCommentForm;
	%NearLinksUsed = ();

	# Isolate our output
	local *STDOUT;
	open(STDOUT, '>', \$result);
	local *STDERR;
	open(STDERR, '>/dev/null');

	# Process the page
	local $Message = "";
	# encoding is left off, so fix it:
	print qq!<?xml version="1.0" encoding="$HttpCharset" ?>!;
	print GetHeader($id, QuoteHtml($id), undef, "");
	print $q->start_div({-class=> 'content browse'});
	print PageHtml($id);
	print $q->end_div();
	SetParam('rcclusteronly', $id) if (FreeToNormal(GetCluster($Page{text})) eq $id);
	if (($id eq $RCName) || (T($RCName) eq $id) || (T($id) eq $RCName)
		|| GetParam('rcclusteronly', '')) {
		print $q->start_div({-class=>'rc'});;
		print $q->hr()  if not GetParam('embed', $EmbedWiki);
		DoRc(\&GetRcHtml);
		print $q->end_div();
	}
	PrintFooter($id);
	print F $result;
	return;
}

*StaticFilesOldDoPost = *DoPost;
*DoPost = *StaticFilesNewDoPost;

sub StaticFilesNewDoPost {
	my $id = FreeToNormal(shift);
	OpenPage($id);
	my $old_cluster = FreeToNormal(GetCluster($Page{text}));
	StaticFilesOldDoPost($id);
	my $new_cluster = FreeToNormal(GetCluster($Page{text}));
	
	$ClusterHasChanged = 1 if ($old_cluster ne $new_cluster);
	
	if ($StaticAlways) {
		# always delete
		StaticDeleteFile($OpenPageName);
		if ($Page{text} =~ /^\#FILE / # if a file was uploaded
			or $StaticAlways > 1) {
			CreateDir($StaticDir);
			# If new Page added, update index
			if (! $IndexHash{$OpenPageName} ) {
				push(@IndexList, $OpenPageName);
				$IndexHash{$OpenPageName} = 1;
			}

			StaticWriteFile($OpenPageName);
			$PageBeingSaved = $OpenPageName;
			AddLinkedFilesToQueue($OpenPageName);
			StaticWriteLinkedFiles();
		}
	}
}

*StaticOldDeletePage = *DeletePage;
*DeletePage = *StaticNewDeletePage;

sub StaticNewDeletePage {
	my $id = shift;
	StaticDeleteFile($id) if ($StaticAlways);
	return StaticOldDeletePage($id);
}

sub StaticDeleteFile {
	my $id = shift;
	%StaticMimeTypes = StaticMimeTypes() unless %StaticMimeTypes;
	# we don't care if the files or $StaticDir don't exist -- just delete!
	for my $f (map { "$StaticDir/$id.$_" } (values %StaticMimeTypes, 'html')) {
		unlink $f;				 # delete copies with different extensions
	}
}

# override the default!
sub GetDownloadLink {
	my ($name, $image, $revision, $alt) = @_;
	$alt = $name unless $alt;
	my $id = FreeToNormal($name);
	AllPagesList();
	# if the page does not exist
	return '[' . ($image ? T('image') : T('download')) . ':' . $name
		. ']' . GetEditLink($id, '?', 1) unless $IndexHash{$id};
	my $action;
	if ($revision) {
		$action = "action=download;id=" . UrlEncode($id) . ";revision=$revision";
	} elsif ($UsePathInfo) {
		$action = "download/" . UrlEncode($id);
	} else {
		$action = "action=download;id=" . UrlEncode($id);
	}
	if ($image) {
		if ($UsePathInfo and not $revision) {
			if ($StaticAlways and $StaticUrl) {
				my $url = $StaticUrl;
				my $img = UrlEncode(StaticFileName($id));
				$url =~ s/\%s/$img/g or $url .= $img;
				$action = $url;
			} else {
				$action = $ScriptName . '/' . $action;
			}
		} else {
			$action = $ScriptName . '?' . $action;
		}
		my $result = $q->img({-src=>$action, -alt=>$alt, -class=>'upload'});
		$result = ScriptLink(UrlEncode($id), $result, 'image') unless $id eq $OpenPageName;
		return $result;
	} else {
		return ScriptLink($action, $alt, 'upload');
	}
}

# override function from Image Extension to support advanced image tags
sub ImageGetInternalUrl{
	my $id = shift;
	if ($UsePathInfo) {
		if ($StaticAlways and $StaticUrl) {
			my $url = $StaticUrl;
			my $img = UrlEncode(StaticFileName($id));
			$url =~ s/\%s/$img/g or $url .= $img;
			return $url;
		} else {
			return $ScriptName . '/download/' . UrlEncode($id);
		}
	}
	return $ScriptName . '?action=download;id=' . UrlEncode($id);
}


sub AddLinkedFilesToQueue {
	my $id = shift;
		
	foreach my $pattern (keys %StaticLinkedPages) {
		if ($id =~ /$pattern/) {
			AddNewFilesToQueue(@{$StaticLinkedPages{$pattern}})
		}
	}
	
	# If you modify a comment page, then update the original
	# Don't check for recursive updates - the only thing that
	# changed was the CommentCount - no reason to waste time
	if ($id =~ /^$CommentsPrefix(.*)/) {
		my $match = $1;
		push(@StaticQueue,$match);
	}
	
	# If the page added belongs to a cluster, update the cluster's page
	# and the $ClusterMapPage
	# especially important with the clustermap module
	local %Page;
	local $OpenPageName = '';
	OpenPage($id);
	my $cluster = FreeToNormal(GetCluster($Page{text}));
	
	# Only move up the cluster hierarchy if the page we originally
	# edited has a cluster
	if ($PageBeingSaved = $id) {
		if ($cluster ne "" && $cluster ne $id) {
			AddNewFilesToQueue($cluster);
			
			# If we are using clustermaps then update
			# ClusterMapPage
			# But only if cluster has changed
			if ($ClusterHasChanged) {
				if ($ClusterMapPage ne "") {
					AddNewFilesToQueue($ClusterMapPage);
				}
			}
		}
	}
}


sub StaticWriteLinkedFiles {
	my $raw = GetParam('raw', 0);
	my $writeRC = 0;
	local *GetDownloadLink = *StaticGetDownloadLink;

	foreach my $id (@StaticQueue) {
		if (! grep(/^$id$/,@StaticIgnoredPages)) {
			StaticWriteFile($id);
			SetParam('rcclusteronly',0);
		}
	}
}

sub StaticGetCommentForm {
	my ($id, $rev, $comment) = @_;
	if ($CommentsPrefix ne '' and $id and $rev ne 'history' and $rev ne 'edit'
		and $OpenPageName =~ /^$CommentsPrefix/) {
		return $q->div({-class=>'comment'}, GetFormStart(undef, undef, 'comment'),
					   $q->p(GetHiddenValue('title', $OpenPageName),
							 GetTextArea('aftertext', $comment ? $comment : $NewComment)),
					   $q->p(T('Username:'), ' ',
							 $q->textfield(-name=>'username', -default=>'',
										   -override=>1, -size=>20, -maxlength=>50),
							 T('Homepage URL:'), ' ',
							 $q->textfield(-name=>'homepage', -default=>'',
										   -override=>1, -size=>40, -maxlength=>100)),
					   $q->p($q->submit(-name=>'Save', -accesskey=>T('s'), -value=>T('Save')), ' ',
							 $q->submit(-name=>'Preview', -value=>T('Preview'))),
					   $q->endform());
	}
	return '';
}

sub StaticGetHttpHeader {
	return;
}

sub AddNewFilesToQueue {
	# Add a file to queue, but only if not already there
	my @ids = @_;

	foreach my $id (@ids) {
		if (! grep(/^$id$/,@StaticQueue)) {
			push(@StaticQueue,$id);
			AddLinkedFilesToQueue($id);
		}
	}
}

# Make rollback compatible

*StaticOldDoRollback = *DoRollback;
*DoRollback = *StaticNewDoRollback;
$Action{rollback} = \&StaticNewDoRollback;

# Delete the static file so that changes made during a rollback are propogated

sub StaticNewDoRollback {
  my $page = shift;
  my $to = GetParam('to', 0);
  ReportError(T('Missing target for rollback.'), '400 BAD REQUEST') unless $to;
  ReportError(T('Target for rollback is too far back.'), '400 BAD REQUEST') unless $page or RollbackPossible($to);
  ReportError(T('A username is required for ordinary users.'), '403 FORBIDDEN') unless GetParam('username', '') or UserIsEditor();
  my @ids = ();
  if (not $page) { # cannot just use list length because of ('')
    return unless UserIsAdminOrError(); # only admins can do mass changes
    my %ids = map { my ($ts, $id) = split(/$FS/o); $id => 1; } # make unique via hash
      GetRcLines($Now - $KeepDays * 86400, 1); # 24*60*60
    @ids = keys %ids;
  } else {
    @ids = ($page);
  }
  RequestLockOrError();
  print GetHeader('', T('Rolling back changes')), $q->start_div({-class=>'content rollback'}), $q->start_p();
  foreach my $id (@ids) {
    OpenPage($id);
    my ($text, $minor, $ts) = GetTextAtTime($to);
    if ($Page{text} eq $text) {
      print T("The two revisions are the same."), $q->br() if $page; # no message when doing mass revert
    } elsif (!UserCanEdit($id, 1)) {
      print Ts('Editing not allowed for %s.', $id), $q->br();
    } else {
      Save($id, $text, Ts('Rollback to %s', TimeToText($to)), $minor, ($Page{ip} ne $ENV{REMOTE_ADDR}));
     	StaticDeleteFile($id);
		print Ts('%s rolled back', GetPageLink($id)), ($ts ? ' ' . Ts('to %s', TimeToText($to)) : ''), $q->br();
    }
  }
  WriteRcLog('[[rollback]]', '', $to) unless $page; # leave marker for DoRc() if mass rollback
  print $q->end_p() . $q->end_div();
  ReleaseLock();
  PrintFooter();
}

*StaticOldDespamPage = *DespamPage;
*DespamPage = *StaticNewDespamPage;

sub StaticNewDespamPage {
  my $rule = shift;
  # from DoHistory()
  my @revisions = sort {$b <=> $a} map { m|/([0-9]+).kp$|; $1; } GetKeepFiles($OpenPageName);
  foreach my $revision (@revisions) { # remember the last revision checked
    my ($text, $rev) = GetTextRevision($revision, 1); # quiet
    if (not $rev) {
      print ': ' . Ts('Cannot find revision %s.', $revision);
      return;
    } elsif (not DespamBannedContent($text)) {
      my $summary = Tss('Revert to revision %1: %2', $revision, $rule);
      print ': ' . $summary;
      Save($OpenPageName, $text, $summary) unless GetParam('debug', 0);
		StaticDeleteFile($OpenPageName);
      return;
    }
  }
  if (grep(/^1$/, @revisions) or not @revisions) { # if there is no kept revision, yet
    my $summary = Ts($rule). ' ' . Ts('Marked as %s.', $DeletedPage);
    print ': ' . $summary;
    Save($OpenPageName, $DeletedPage, $summary) unless GetParam('debug', 0);
	StaticDeleteFile($OpenPageName);
  } else {
    print ': ' . T('Cannot find unspammed revision.'. $revision);
  }
}
