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

$ModulesDescription .= '<p>$Id: namespaces.pl,v 1.11 2005/01/04 09:40:01 as Exp $</p>';

use vars qw($NamespacesMain $NamespacesSelf $NamespaceCurrent $NamespaceRoot);

$NamespacesMain = 'Main'; # to get back to the main namespace
$NamespacesSelf = 'Self'; # for your own namespace
$NamespaceCurrent = '';   # will be automatically set to the current namespace, if any
$NamespaceRoot = '';      # will be automatically set to the original $ScriptName

my $NamespacesInit = 0;

push(@MyInitVariables, \&NamespacesInitVariables);

sub NamespacesInitVariables {
  # Do this before changing the $DataDir and $ScriptName
  if (not $InterSiteInit and !$Monolithic and $UsePathInfo) {
    $InterSite{$NamespacesMain} = $ScriptName . '/';
    foreach my $name (glob("$DataDir/*")) {
      if (-d $name
	  and $name =~ m|/($InterSitePattern)$|
	  and $name ne $NamespacesMain
	  and $name ne $NamespacesSelf) {
	$InterSite{$1} = $ScriptName . '/' . $1 . '/';
      }
    }
  }
  $NamespaceCurrent = '';
  if (($UsePathInfo and not $NamespacesInit
       # make sure ordinary page names are not matched!
       and $q->path_info() =~ m|^/($InterSitePattern)(/.*)?|
       and ($2 or $q->param or $q->keywords)
       and ($1 ne $NamespacesMain)
       and ($1 ne $NamespacesSelf))
      or
      (GetParam('ns', '') =~ m/^($InterSitePattern)$/
       and ($1 ne $NamespacesMain)
       and ($1 ne $NamespacesSelf))) {
    $NamespaceCurrent = $1;
    $NamespacesInit = 1;
    # Change some stuff from the original InitVariables call:
    $SiteName   .= ' ' . $NamespaceCurrent;
    $DataDir    .= '/' . $NamespaceCurrent;
    $PageDir     = "$DataDir/page";
    $KeepDir     = "$DataDir/keep";
    $RefererDir  = "$DataDir/referer";
    $TempDir     = "$DataDir/temp";
    $LockDir     = "$TempDir/lock";
    $NoEditFile  = "$DataDir/noedit";
    $RcFile	 = "$DataDir/rc.log";
    $RcOldFile   = "$DataDir/oldrc.log";
    $IndexFile   = "$DataDir/pageidx";
    $VisitorFile = "$DataDir/visitors.log";
    $PermanentAnchorsFile = "$DataDir/permanentanchors";
    # $ConfigFile -- shared
    # $ModuleDir -- shared
    # $NearDir -- shared
    $NamespaceRoot = $ScriptName;
    $ScriptName .= '/' . $NamespaceCurrent;
    $FullUrl .= '/' . $NamespaceCurrent;
    $WikiDescription .= "<p>Current namespace: $NamespaceCurrent</p>";
    # override LastUpdate
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($IndexFile);
    $LastUpdate = $mtime;
    CreateDir($DataDir); # Create directory if it doesn't exist
    ReportError(Ts('Could not create %s', $DataDir) . ": $!", '500 INTERNAL SERVER ERROR')
      unless -d $DataDir;
  }
  $InterSite{$NamespacesSelf} = $ScriptName . '?';
}

*OldNamespaceDoRc = *DoRc;
*DoRc = *NewNamespaceDoRc;

sub NewNamespaceDoRc {
  if ($NamespaceCurrent) {
    return OldNamespaceDoRc(@_);
  } else {
    my $GetRC = shift;
    if ($GetRC eq \&GetRcHtml) {
      return NamespaceBrowseRc();
    } else {
      return OldNamespaceDoRc($GetRC, @_);
    }
  }
}

sub NamespaceBrowseRc {
  RcHeader();
  print NamespaceInternalRc(GetParam('limit',100));
  print GetFilterForm();
}

sub NamespaceInternalRc { # code taken from RSS(), maybe refactoring would be possible, but tricky.
  my $maxitems = shift;
  my %lines;
  eval { require XML::RSS;  } or return $q->div({-class=>'rss'},
						$q->strong(T('XML::RSS is not available on this system.')));
  # All strings that are concatenated with strings returned by the RSS
  # feed must be decoded.  Without this decoding, 'diff' and 'history'
  # translations will be double encoded when printing the result.
  my $tDiff = T('diff');
  my $tHistory = T('history');
  if ($HttpCharset eq 'UTF-8' and ($tDiff ne 'diff' or $tHistory ne 'history')) {
    eval { local $SIG{__DIE__};
	   require Encode;
	   $tDiff = Encode::decode_utf8($tDiff);
	   $tHistory = Encode::decode_utf8($tHistory);
	 }
  }
  my $wikins = 'http://purl.org/rss/1.0/modules/wiki/';
  my $rdfns = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
  my $str;
  SetParam(GetParam('rsslimit', 'all'));
  foreach my $site (keys %InterSite) {
    if ($InterSite{$site} =~ m|^$ScriptName/([^/]*)|) {
      my $ns = $1;
      my $data = '';
      local $ScriptName = $ScriptName;
      local $RcFile = $RcFile;
      if ($ns) {
	my @dirs = split(/\//, $RcFile);
	my $file = pop @dirs;
	$RcFile = join('/', @dirs, $ns, $file);
	$ScriptName .= '/' . $ns;
      }
      local *STDOUT;
      open(STDOUT, '>', \$data) or die "Can't open memory file: $!";
      DoRc(\&GetRcRss);
      close(STDOUT);
      my $rss = new XML::RSS;
      $str .= $q->p($q->strong(Ts('%s returned no data.', $q->a({-href=>$ns}, $ns)))) unless $data;
      eval { local $SIG{__DIE__}; $rss->parse($data); };
      $str .= $q->p($q->strong(Ts('RSS parsing failed for %s',
				  $q->a({-href=>$ns}, $ns)) . ': ' . $@)) if $data and $@;
      # $str .= $q->p($q->strong(Ts('No items found in %s.', $q->a({-href=>$ns}, $ns or $NamespacesMain))))
      # unless @{$rss->{items}};
      foreach my $i (@{$rss->{items}}) {
	my $line;
	my $date = $i->{dc}->{date};
	my $title = $i->{title};
	my $description = $i->{description};
	$line .= ' (' . $q->a({-href=>$i->{$wikins}->{diff}}, $tDiff) . ')';
	$line .= ' (' . $q->a({-href=>$i->{$wikins}->{history}}, $tHistory) . ')';
	$line .= ' ' . $q->a({-href=>$i->{link}, -title=>$date}, ($ns ? $ns . ':' : '') . $title);
	my $contributor = $i->{dc}->{contributor};
	$contributor =~ s/^\s+//;
	$contributor =~ s/\s+$//;
	if (!$contributor) {
	  $contributor = $i->{$rdfns}->{value};
	}
	$line .= $q->span({-class=>'contributor'}, $q->span(T(' . . . . ')) . $contributor);
	$line .= ' ' . $q->strong({-class=>'description'}, '--', $description) if $description;
	while ($lines{$date}) {
	  $date .= ' ';
	}			# make sure this is unique
	$lines{$date} = $line;
      }
    }
  }
  my @lines = sort { $b cmp $a } keys %lines;
  @lines = @lines[0..$maxitems-1] if $maxitems and $#lines > $maxitems;
  my $date;
  foreach my $key (@lines) {
    my $line = $lines{$key};
    if ($key =~ /(\d\d\d\d(?:-\d?\d)?(?:-\d?\d)?)(?:[T ](\d?\d:\d\d))?/) {
      my ($day, $time) = ($1, $2);
      if ($day ne $date) {
	$str .= '</ul>' if $date; # close ul except for the first time where no open ul exists
	$date = $day;
	$str .= $q->p($q->strong($day)) . '<ul>';
      }
      $line = $time . ' UTC ' . $line if $time;
    } elsif (not $date) {
      $str .= '<ul>'; # if the feed doesn't have any dates we need to start the list anyhow
      $date = $Now;		# to ensure the list starts only once
    }
    $str .= $q->li($line);
  }
  $str .= '</ul>' if $date;
  return $q->div({-class=>'content rss'}, $str);
}
