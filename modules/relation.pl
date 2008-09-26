# Copyright (C) 2008 Andreas Hofmann
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

$ModulesDescription .= '<p>$Id: relation.pl,v 1.3 2008/09/26 23:02:28 as Exp $</p>';

use vars qw(@RelationLinking $RelationPassedFlag);

push(@MyRules, \&RelationRule);

my $referencefile = "References.txt";
my $RelationPassedFlag = 0;
my $dummy = RelationRead();

sub RelationRead {
#   return scalar(@RelationLinking) if (scalar(@RelationLinking));
   open (RRR,"<$DataDir/$referencefile") || return(0);
   while (<RRR>) {
      chomp;
      my ($a,$b,$c) = split(';');
      # print "<!--- a,b,c=<$a,$b,$c> ---!>\n";
      push @RelationLinking, [$a, $b, $c];
   };
   close(RRR);
   return (scalar(@RelationLinking));
}

sub RelationRule {
  if (m/\G((forward@@|backward@@|forward@|backward@):([_A-Za-z0-9 ]+?);)/gc) {
    Dirty($1);
    my $rememberpos = pos;
    my $fwbw =$2;
    my $rel=$3;
    my $rtext = '';
    my $rhead;
    $RelationPassedFlag++;
    my @result;
    if ( substr($fwbw,0,7) eq 'forward' ) {
        @result = map { $_->[2] } grep { $_->[0] eq $OpenPageName and $_->[1] eq $rel } @RelationLinking;
        $rhead = "<h3>".NormalToFree($OpenPageName)." $rel:</h3>\n";
    }
    else{
        @result = map { $_->[0] } grep { $_->[2] eq $OpenPageName and $_->[1] eq $rel } @RelationLinking;
        $rhead = "<h3>$rel ".NormalToFree($OpenPageName).":</h3>\n";
    }
    if (scalar(@result) == 0 ) {
       if (substr($fwbw,-2) eq '@@') {
         $rtext = "<!--- RelationRule hits: <$fwbw> <$rel> hiding empty ---!>\n"
       }
       else {
         $rtext = "$rhead<ul><li>-no relation-</li></ul>\n";
       }
    }
    else {
       $rtext = $rhead."<ul>\n";
       foreach my $LLL (@result) {
          $rtext .=  "<li>" . GetPageOrEditLink($LLL,$LLL) . "</li>\n";
       };
       $rtext .= "</ul>\n";
    };
    pos = $rememberpos;
    return $rtext;
  }
  return undef;
}

*OldRelationPrintFooter = *PrintFooter;
*PrintFooter = *RelationPrintFooter;

sub RelationPrintFooter {
  my @params = @_;
  if ($RelationPassedFlag > 0) {
     print "<div class='footnotes'>\n";
#     print "<a href='$OpenPageName?action=checkrelates'>CheckRelations</a><br />\n";
     print ScriptLink('action=checkrelates;id='.$OpenPageName, CheckRelations, 'index');
     print "</div>\n";
  };
  OldRelationPrintFooter(@params);
};

$Action{'checkrelates'} = sub {
   my $id = shift;

   my @result = @RelationLinking;

   print $q->header;
   print "<html><head><title>Edit Relations</title></head><body>\n";

   print "<!--- 1 id=$id --->\n";

   print "<h3>Relations of $id (to be deleted)</h3>\n";
   print "<form action='".ScriptUrl("action=updaterelates")."' method='post'>\n";
   my $count = -1;
   foreach my $r (@result) {
      $count++;
      next if ($id ne $r->[0] and $id ne $r->[2]);
      print "<input type='checkbox' name='delete$count' value='$count' unchecked >$r->[0] -> $r->[1] -> $r->[2]<br />\n";
   };
   print "<h3>New Relation of $id (to be created)</h3>\n";
   print "$id -> <input name='newrelationto' type='text' size='30' maxlength='30'> -> <input name='newtargetto' type='text' size='30' maxlength='30'><br />\n";
   print "<h3>New Relation from $id (to be created)</h3>\n";
   print "<input name='newsourcefrom' type='text' size='30' maxlength='30'> -> <input name='newrelationfrom' type='text' size='30' maxlength='30'> -> $id<br />\n";
   print "<input type=\"hidden\" name=\"id\" value=\"$id\"  /><br />\n";
   print "<input type='submit' name='action' value='updaterelates' />&nbsp;\n";
   print "</form>\n";
   print "</body></html>\n";
};

$Action{'updaterelates'} = sub {
  my $id = shift;
  print $q->header;
  print "<html><head><title>Relations</title></head><body>\n";
  my %h = $q->Vars;
  print "<h3>Relations of $id</h3>";
  my $newrelationto = undef;
  my $newtargetto = undef;
  my $newrelationfrom = undef;
  my $newsourcefrom = undef;
  foreach my $r (keys %h) {
     if ( $r =~ m/^delete([0-9]+)/ ) {
        my $n = $1;
        my $s = $h{$r};
        print "delete: ". $RelationLinking[$n]->[0]." -> ". $RelationLinking[$n]->[1]." -> " . $RelationLinking[$n]->[2]."<br />\n";
        $RelationLinking[$n] = undef;
     }
     elsif ( $r eq 'newtargetto') {
        $newtargetto = $h{$r};
     }
     elsif ( $r eq 'newrelationto') {
        $newrelationto = $h{$r};
     }
     elsif ( $r eq 'newsourcefrom') {
        $newsourcefrom = $h{$r};
     }
     elsif ( $r eq 'newrelationfrom') {
        $newrelationfrom = $h{$r};
     }
     else {
        my $s = $h{$r};
        print "other: $r -> $s<br />\n" unless ($r eq 'action' or $r eq 'id');
     };
  };
  if (defined($newrelationto) and defined($newtargetto) and $newrelationto ne '' and $newtargetto  ne '') {
        print "new: $id -> $newrelationto  -> $newtargetto<br />\n";
        push @RelationLinking, [$id, $newrelationto, FreeToNormal($newtargetto)];
  }
  else {
        print "no new target<br />\n";
  }
  if (defined($newrelationfrom) and defined($newsourcefrom) and $newrelationfrom ne '' and $newsourcefrom  ne '') {
        print "new: $newsourcefrom -> $newrelationfrom  -> $id<br />\n";
        push @RelationLinking, [FreeToNormal($newsourcefrom), $newrelationfrom, $id];
  }
  else {
        print "no new source<br />\n";
  }
  open (RRR,">$DataDir/$referencefile");
  print "<br />\n";
  foreach my $t (@RelationLinking) {
      next unless (defined($t));
#      print "trace:". $t->[0] .";". $t->[1].";". $t->[2] ."<br />\n";
      print RRR $t->[0] .";". $t->[1].";". $t->[2] ."\n";
  };
  close(RRR);

  print ScriptLink('id='.$id, $id, 'index');
  print "</body></html>\n";
};

1;

