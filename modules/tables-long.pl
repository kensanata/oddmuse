# Copyright (C) 2004, 2005  Alex Schroeder <alex@emacswiki.org>
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

$ModulesDescription .= '<p>$Id: tables-long.pl,v 1.13 2005/10/09 11:58:34 as Exp $</p>';

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
  if ($bol && m|\G\s*\n*\&lt;table(/[A-Za-z\x80-\xff/]+)? +([A-Za-z\x80-\xff,;\/ ]+)\&gt; *\n|cg) {
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
    while (m/\G(.*)\n/cg) {
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
      if ($line =~ m|^($regexp)/?([A-Za-z\x80-\xff/]+)?[:=] *(.*)|) { # regexp changes for other tables
	$label = $1;
	$class = join(' ', split(m|/|, $2)); # no leading / therefore no leading space
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
  my $first = $_[3];
  Clean('<tr>');
  # first print the old row
  for my $i (0 .. $#labels) {
    next if not $row{$labels[$i]}; # should only happen after previous cellspans
    my $span = 1;
    while ($i + $span < $#labels + 1 and not $row{$labels[$i+$span]}) {
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

    if ($Fragment ne '') {
      $Fragment =~ s|<p></p>||g; # clean up extra paragraphs (see end Dirty())
      print $Fragment;
      push(@Blocks, $Fragment);
      push(@Flags, 0);
      $Fragment = '';
    }
    # call ApplyRules, and *inline* the results
    my ($blocks, $flags) = ApplyRules($row{$labels[$i]}, 1, 1); # local links, anchors
    push(@Blocks, split(/$FS/, $blocks));
    push(@Flags, split(/$FS/, $flags));
    # end of evil magic

    # Alternatively, just use
    # Clean($row{$labels[$i]});
    # or mark this block as dirty.
    Clean(CloseHtmlEnvironments() . '</' . ($first ? 'th' : 'td') . '>');
  }
  Clean('</tr>');
}
