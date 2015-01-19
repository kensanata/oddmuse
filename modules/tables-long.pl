# Copyright (C) 2004–2015  Alex Schroeder <alex@gnu.org>
# Copyright (C)      2015  Matt Adams <opensource@radicaldynamic.com>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

AddModuleDescription('tables-long.pl', 'Long Table Markup Extension');

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
  if ($bol && m|\G\s*\n*\&lt;table(/[A-Za-z\x{0080}-\x{fffd}/]+)? +([A-Za-z\x{0080}-\x{fffd},;\/ ]+)\&gt; *\n|cg) {
    my $class = join(' ', split(m|/|, $1)); # leading / in $1 will make sure we have leading space
    Clean(CloseHtmlEnvironments() . "<table class=\"user long$class\">");
    # labels and their default class
    my %default_class = ();
    my @labels = map { my ($label, @classes) = split m|/|;
		       $default_class{$label} = join(' ', @classes);
		       $label;
		     } split(/ *[,;] */, $2);
    my $regexp = join('|', @labels);
    # read complete table
    my @lines = ();
    while (m/\G(.*)\n?/cg) { # last line may miss newline
      my $line = $1;
      last if substr($line,0,4) eq ('----'); # the rest of this line is ignored!
      push(@lines, $line);
    }
    # parse lines and print table rows
    my $lastpos = pos;
    my @rows = ();
    my %row = ();
    my %class = %default_class;
    my %rowspan = ();
    my $label = '';
    my $rowspan = '';
    my $rownum = 1;
    for my $line (@lines) {
      if ($line =~ m|^($regexp)/?([0-9]+)?/?([A-Za-z\x{0080}-\x{fffd}/]+)?[:=] *(.*)|) { # regexp changes for other tables
	$label = $1;
	$rowspan = $2;
	$class = join(' ', split(m|/|, $3)); # no leading / therefore no leading space
	$line = $4;
	if ($row{$label}) { # repetition of label, we must start a new row
	  TablesLongRow(\@labels, \%row, \%class, \%rowspan, $rownum++);
	  %row = ();
	  %class = %default_class;
	  foreach my $key (keys %rowspan) {
	    delete $rowspan{$key} if $rowspan{$key} == 1;
	    $rowspan{$key}--; # 0 will turn into negative numbers
	  }
	}
	$class{$label} = $class if $class;
	$rowspan{$label} = $rowspan if $rowspan;
      }
      $row{$label} .= $line . "\n";
    }
    TablesLongRow(\@labels, \%row, \%class, \%rowspan, $rownum); # don't forget the last row
    Clean('</table>' . AddHtmlEnvironment('p'));
    pos = $lastpos;
    return '';
  }
  return undef;
}

sub TablesLongRow {
  my @labels = @{$_[0]};
  my %row = %{$_[1]};
  my %class = %{$_[2]};
  my %rowspan = %{$_[3]};
  my $rownum = $_[4];
  if ($rownum == 1) {
    Clean('<tr class="first odd">');
  } elsif ($rownum %2 == 0) {
    Clean('<tr class="even">');
  } else {
    Clean('<tr class="odd">');
  }
  # first print the old row
  for my $i (0 .. $#labels) {
    next if not $row{$labels[$i]}; # should only happen after previous cellspans
    my $colspan = 1;
    while ($i + $colspan < $#labels + 1
	   and not $row{$labels[$i+$colspan]}
	   and not $rowspan{$labels[$i+$colspan]}) {
      $colspan++;
    }
    my $rowspan = $rowspan{$labels[$i]};
    my $class = $class{$labels[$i]};
    my $html = '<';
    $html .= $rownum == 1 ? 'th' : 'td';
    $html .= " colspan=\"$colspan\"" if $colspan != 1;
    $html .= " rowspan=\"$rowspan\"" if defined $rowspan and $rowspan >= 0; # ignore negatives
    $html .= " class=\"$class\"" if $class;
    $html .= '>';
    Clean($html);

    # WATCH OUT: here comes the evil magic messing with the internals!
    # first, clean everything up like at the end of ApplyRules

    if ($Fragment ne '') {
      $Fragment =~ s|<p></p>||g; # clean up extra paragraphs (see end Dirty())
      print $Fragment;
      push(@Blocks, $Fragment);
      push(@Flags, 0);
      $Fragment = '';
    }
    # call ApplyRules, and *inline* the results; ignoring $PortraitSupportColorDiv
    local $PortraitSupportColorDiv;
    my ($blocks, $flags) = ApplyRules($row{$labels[$i]}, 1, 1); # local links, anchors
    push(@Blocks, split(/$FS/, $blocks));
    push(@Flags, split(/$FS/, $flags));
    # end of evil magic

    # Alternatively, just use
    # Clean($row{$labels[$i]});
    # or mark this block as dirty.
    Clean(CloseHtmlEnvironments() . '</' . ($rownum == 1 ? 'th' : 'td') . '>');
  }
  Clean('</tr>');
}
