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

$ModulesDescription .= '<p>$Id: tables-long.pl,v 1.4 2005/01/01 13:48:21 as Exp $</p>';

# add the same CSS as in tables.pl
$DefaultStyleSheet .= q{
table.user { border-style:solid; border-width:thin; }
table.user tr td { border-style:solid; border-width:thin; padding:5px; }
table.user th { font-weight:bold; }
table.user td.r { text-align:right; }
table.user td.l { text-align:left; }
table.user td.c { text-align:center; }
table.user td.j { text-align:justify; }
table.user td.mark { background-color:yellow; }
} unless $DefaultStyleSheet =~ /table\.user/; # mod_perl?

push(@MyRules, \&TablesLongRule);

my $TablesLongLabels = '';

sub TablesLongRule {
  # start table by declaring the abbreviations used:
  # <table foo,bar,baz>
  # end with a horizontal line:
  # ----
  # use label: or label= to start a cell
  # label: bla
  #   bla bla bla
  # a new row is started when a cell is repeated
  # if cells are missing, column spans are created (the first row
  # could use row spans...)
  if ($bol && m/\G\s*\n*\&lt;table(?:\/([a-z]+))? +([A-Za-z\x80-\xff,;\/ ]+)\&gt; *\n/cgo) {
    my $class = ' ' . $1 if $1;
    Clean(CloseHtmlEnvironments() . "<table class=\"user long$class\">");
    # labels and their default class
    my %default_class = ();
    my @labels = map { my ($label, $class) = split /\//;
		       $default_class{$label} = $class;
		       $label;
		     } split(/ *[,;] */, $2);
    my $regexp = join('|', @labels);
    # read complete table
    my @lines = ();
    while (m/\G(.*\n)/cg) {
      my $line = $1;
      last if substr($line,0,4) eq ('----'); # the rest of this line is ignored!
      push(@lines, $line);
    }
    # parse lines and print table rows
    my $lastpos = pos;
    my @rows = ();
    my %row = ();
    my %class = %default_class;
    my $label = '';
    my $first = 1;
    for my $line (@lines) {
      if ($line =~ /^($regexp)(?:\/([a-z]+))?[:=] *(.*)/o) {
	$label = $1;
	$class = $2;
	$line = $3;
	if ($row{$label}) { # repetition of label, we must start a new row
	  TablesLongRow(\@labels, \%row, \%class, $first);
	  $first = 0;
	  %row = ();
	  %class = %default_class;
	}
	$class{$label} = $class if $class;
      }
      $row{$label} .= $line . "\n";
    }
    TablesLongRow(\@labels, \%row, \%class, $first); # don't forget the last row
    Clean('</table>');
    pos = $lastpos;
    return '';
  }
  return undef;
}

sub TablesLongRow {
  my @labels = @{$_[0]};
  my %row = %{$_[1]};
  my %class = %{$_[2]};
  my $first = $_[3];
  Clean('<tr>');
  # first print the old row
  for my $i (0 .. $#labels) {
    next if not $row{$labels[$i]}; # should only happen after previous cellspans
    my $span = 1;
    while ($span <= $#labels and not $row{$labels[$i+$span]}) {
      $span++;
    }
    my $class = $class{$labels[$i]};
    my $html = '<';
    $html .= $first ? 'th' : 'td';
    $html .= " colspan=\"$span\"" if $span > 1;
    $html .= " class=\"$class\"" if $class;
    $html .= '>';
    Clean($html);

    # WATCH OUT: here comes the evil magic messing with the internals!
    # first, clean everything up like at the end of ApplyRules
    print $Fragment;
    push(@Blocks, $Fragment);
    push(@Flags, 0);
    $Fragment = '';
    # call ApplyRules, and *inline* the results
    my ($blocks, $flags) = ApplyRules($row{$labels[$i]}, 1, 1); # local links, anchors
    push(@Blocks, split(/$FS/, $blocks));
    push(@Flags, split(/$FS/, $flags));
    # end of evil magic

    # Alternatively, just use
    # Clean($row{$labels[$i]});
    # or mark this block as dirty.

    Clean('</td>');
  }
  Clean('</tr>');
}
