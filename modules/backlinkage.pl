# Copyright (C) 2006 Charles Mauch <cmauch@gmail.com>
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

# Grab MLDBM at http://search.cpan.org/dist/MLDBM/lib/MLDBM.pm
# ie: http://search.cpan.org/CPAN/authors/id/C/CH/CHAMAS/MLDBM-2.01.tar.gz

use MLDBM qw( DB_File Storable );
$ModulesDescription .= '<p>$Id: backlinkage.pl,v 1.3 2006/10/01 04:26:11 xterminus Exp $</p>';

my $debug=1;             # Set Text Output Verbosity when compiling
my $backfile = $DataDir . '/backlinks.db';  # Where data lives

# Stuff buildback action into admin menu.
push(@MyAdminCode, \&BacklinksMenu);
sub BacklinksMenu {
    my ($id, $menuref, $restref) = @_;
    push(@$menuref,
        ScriptLink('action=buildback', T('Rebuild BackLink database'))
    );
}

# Build Database, called my oddmuse uri action
$Action{buildback} = \&BuildBacklinkDatabase;
sub BuildBacklinkDatabase {
    print GetHttpHeader('text/plain');
    unlink $backfile; # Remove old database
    tie my %backhash, 'MLDBM', $backfile or die "Cannot open file $backfile $!\n";
    log1("Starting Database Store Process ... please wait\n\n");

    foreach my $name (AllPagesList()) {
        log3("Opening $name ... \n");
        OpenPage($name);
        my @backlinks =  BacklinkProcess($name,$Page{text});

        my $hash = $backhash{$name};    # Declare Hash Ref
        my $backlinkcount = 0;          # Used to create link key
        foreach my $link (@backlinks) {
            $backlinkcount++;
            $hash->{'link' . $backlinkcount} = $link;
        }
        log2("$backlinkcount Links found in $name\n") if $backlinkcount;
        $backhash{$name} = $hash;       # Store Hash data in HoH    
    } 
  
    if ($debug >= 3) {
        log4("Printing dump of USABLE Data we stored, sorted and neat\n");
        for my $source (sort keys %backhash) {
            for my $role (sort keys %{ $backhash{$source} }) {
                log4("\n\$HoH\{\'$source\'\}\{\'$role\'\} = \"$backhash{$source}{$role}\"");
            }
        }
    }
    untie %backhash;
    log1("Done. \n");

}

# Used to filter though page text to find links, ensure there is only 1 link per destination
# per page, and then return an array of backlinks.
sub BacklinkProcess {
    my $name = $_[0];
    my $text = $_[1];
    my %seen = ();
    my @backlinks;
    my @wikilinks = ($text =~ m/$LinkPattern/g);

    foreach my $links (@wikilinks) {
        my ($class, $resolved, $title, $exists) = ResolveId($links);
        if ($exists) {
            push (@backlinks,$resolved) unless (($seen{$resolved}++) or ($resolved eq $name));
        }
    } 
    return @backlinks;
}

# Function used by user to display backlinks in proper html.
sub GetBackLink {
    my (@backlinks, @unpopped, @alldone);
    my $id = $_[0];
    
    use vars qw($BacklinkBanned);
    $BacklinkBanned = "HomePage|ScratchPad" if !$BacklinkBanned;
    tie my %backhash, 'MLDBM', $backfile, O_CREAT|O_RDWR, 0644 or die "Cannot open file $backfile $!\n";

    # Search database for matches
    while ( ($source, $hashes) = each %backhash ) {
        while ( ($key, $value) = each %$hashes ) {
            if ($id =~ /$value/) {
                push (@backlinks, $source);
            }
        }
    }
    untie %backhash;

    # Render backlinks into html links
    foreach my $backlink (@backlinks) {
            my ($class, $resolved, $title, $exists) = ResolveId($backlink);
            if (($resolved ne $id) && ($resolved !~ /^($BacklinkBanned)$/)) {
                push(@unpopped, ScriptLink(UrlEncode($resolved), $resolved, $class . ' backlink', undef, T('Internal Page: ' . $resolved)));
            }
    }
    
    my $arraycount = @unpopped;
    return if !$arraycount; # Dont bother with the rest if empty results
   
    # Pop and Push data to make it look good (no trailing commas) 
    my $temp = pop(@unpopped);
    foreach my $backlink (@unpopped) {
            push(@alldone, $backlink . ", ");
    }
    push(@alldone, $temp);  # And push last entry back in
    print $q->div({-class=>'docmeta'}, $q->h2(T('Pages that link to this page')), @alldone);
}

# Debug functions, all expect a string as input, and print it if the debug level is high enough.
# This allows for increasing levels of verbosity for runtime commenting.

sub log1 { # Very little info (only outputs if error - great for scripts)
    return if (($debug < 1) or ($debug == 4));
    my $msg = shift;
    print "$msg";
}

sub log2 { # Info Messages
    return if (($debug < 2) or ($debug == 4));
    my $msg = shift;
    print "$msg";
}

sub log3 { # More Info for the curious
    return if (($debug < 3) or ($debug == 4));
    my $msg = shift;
    print "$msg";
}

sub log4 {  # Dump all sorts of garbage (usally data structures)
    return if ($debug < 4);
    my $msg = shift;
    print "$msg";
}
