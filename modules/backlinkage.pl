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

$ModulesDescription .= '<p>$Id: backlinkage.pl,v 1.2 2006/09/18 17:52:59 xterminus Exp $</p>';

push(@MyAdminCode, \&BacklinksMenu);

sub BacklinksMenu {
    my ($id, $menuref, $restref) = @_;
    push(@$menuref,
        ScriptLink('action=buildback', T('Rebuild BackLink database'))
    );
}

$Action{buildback} = \&BuildBacklinkDatabase;
sub BuildBacklinkDatabase {
    my %backhash;

    print GetHttpHeader('text/plain');
    my $backfile = $DataDir . '/backlinks.db';
    unlink $backfile; # Remove old database
    tie %backhash, 'MLDBM', $backfile or die "Cannot open file $backfile $!\n";

    foreach my $name (AllPagesList()) {
        OpenPage($name);
        my $page = $OpenPageName;
        $page =~ s/_/ /g;
        
        my $count = 1; 
        my @wikilinks = ($Page{text} =~ m/$LinkPattern/g);
        print "Searching $name ... \n";
        foreach my $links (@wikilinks) {
                my ($class, $resolved, $title, $exists) = ResolveId($links);
                if ($exists) {
                        my $linkage = "link" . $count++;
                        print "\tFound one, saving link to $resolved\n";
                        my $tmp = $backhash{$name};     # Retrieve value
                        $tmp->{$linkage} = $resolved;   # Now add hash to ref
                        $backhash{$name} = $tmp;        # Store Value
                }
        }
    }
    untie %backhash;
    print "Done. \n";
}

sub GetBackLink {
    my (%BackHash, @backlinks, @unpopped, @alldone);
    my $id = $_[0];
    if (!$BacklinkBanned) { $BacklinkBanned = "HomePage|ScratchPad"; }
    use vars qw($BacklinkBanned);
    my $backfile = $DataDir . '/backlinks.db';
    tie %BackHash, 'MLDBM', $backfile, O_CREAT|O_RDWR, 0644 or die "Cannot open file $backfile $!\n";

    # Search database for matches
    while ( ($source, $hashes) = each %BackHash ) {
        while ( ($key, $value) = each %$hashes ) {
            if ($id =~ /$value/) {
                push (@backlinks, $source);
            }
        }
    }
    untie %backhash;

    # Remove dupes
    my @uniqed = grep !$seen{$_}++, @backlinks;

    # Make backlinks back into links
    foreach my $backlink (@uniqed) {
            my ($class, $resolved, $title, $exists) = ResolveId($backlink);
            if (($resolved ne $id) && ($resolved !~ /^($BacklinkBanned)$/)) {
                push(@unpopped, ScriptLink(UrlEncode($resolved), $resolved, $class . ' backlink', undef, T('Internal Page: ' . $resolved)));
            }
    }
    
    my $arraycount = @unpopped;
    if ($arraycount eq 0) { return }
   
    # Pop and Push data to make it look good (no trailing commas) 
    my $temp = pop(@unpopped);
    foreach my $backlink (@unpopped) {
            push(@alldone, $backlink . ", ");
    }
    push(@alldone, $temp);  # And push last entry back in
    print $q->div({-class=>'docmeta'}, $q->h2(T('Pages that link to this page')), @alldone);
}
