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

$ModulesDescription .= '<p>$Id: simple-rules.pl,v 1.12 2004/04/11 11:18:04 as Exp $</p>';

*ApplyRules = *NewSimpleRulesApplyRules;

my $PROT = "\x1c";
my $DIRT = "\x1d";

sub NewSimpleRulesApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks, $withanchors, $revision) = @_;
  # shortcut for dirty blocks (if this is the content of a real page: no caching!)
  local $counter = 0;
  local %protected = ();
  local %dirty = ();
  my $result;
  $text = NewSimpleRulesApplyDirtyInlineRules($text, $locallinks);
  if ($text =~ /^${DIRT}[0-9]+${DIRT}$/) { # shortcut
    $result = $text;
  } else {
    $text =~ s/[ \t]+\n/\n/g;  # no trailing whitespace to worry about
    $text =~ s/\n$//g;
    $text =~ s/^\n//g;
    my @paragraphs = split(/\n\n+/, $text);
    foreach my $block (@paragraphs) {
      if ($block =~ /^(.+?)\n(--+)$/ and length($1) == length($2)) {
	$block = SimpleRulesProtect($q->h3($1));
      } elsif ($block =~ /^(.+?)\n(==+)$/ and length($1) == length($2)) {
	$block = SimpleRulesProtect($q->h2($1));
      } elsif ($block =~ /^\* (.*)/s) {
	$block = SimpleRulesProtect($q->ul(join('', # avoid extra space in CGI.pm code
						map{$q->li(NewSimpleRulesApplyInlineRules($_))}
						split(/\n\* +/, $1))));
      } elsif ($block =~ /^[0-9]\. (.*)/s) {
	$block = SimpleRulesProtect($q->ol(join('', # avoid extra space in CGI.pm code
						map{$q->li(NewSimpleRulesApplyInlineRules($_))}
						split(/\n[0-9]\. */, $1))));
      } elsif ($block =~ m/^#FILE ([^ \n]+)\n(.*)/s) {
	$block = SimpleRulesProtect(GetDownloadLink(
                   $OpenPageName, (substr($1, 0, 6) eq 'image/'), $revision));
      } else {
	$block = SimpleRulesProtect('<p>') . $block . SimpleRulesProtect('</p>');
      }
      ($block =~ s/(\&lt;journal(\s+(\d*))?(\s+"(.*)")?(\s+(reverse))?\&gt;)/
       my ($str, $num, $regexp, $reverse) = ($1, $3, $5, $7);
       SimpleRulesDirty($str, sub { PrintJournal($num, $regexp, $reverse)});/ego);
      $result .= NewSimpleRulesApplyInlineRules($block);
    }
  }
  return SimpleRulesMungeResult($result);
}

sub NewSimpleRulesApplyInlineRules {
  my ($block, $locallinks) = @_;
  $block = NewSimpleRulesApplyDirtyInlineRules($block, $locallinks);
  $block =~ s/$UrlPattern/SimpleRulesProtect($q->a({-href=>$1}, $1))/seg;
  $block =~ s/~(\S+)~/SimpleRulesProtect($q->em($1))/eg;
  $block =~ s/\*\*(.+?)\*\*/SimpleRulesProtect($q->strong($1))/seg;
  $block =~ s/\/\/(.+?)\/\//SimpleRulesProtect($q->em($1))/seg;
  $block =~ s/\_\_(.+?)\_\_/SimpleRulesProtect($q->u($1))/seg;
  $block =~ s/\*(.+?)\*/SimpleRulesProtect($q->b($1))/seg;
  $block =~ s/\/(.+?)\//SimpleRulesProtect($q->i($1))/seg;
  $block =~ s/\_(.+?)\_/SimpleRulesProtect($q->u($1))/seg;
  return $block;
}

sub NewSimpleRulesApplyDirtyInlineRules {
  my ($block, $locallinks) = @_;
  if ($locallinks) {
    ($block =~ s/(\[\[$FreeLinkPattern\]\])/
     my ($str, $link) = ($1, $2);
     SimpleRulesDirty($str, GetPageOrEditLink($link,0,0,1))/ego);
    ($block =~ s/(\[\[image:$FreeLinkPattern\]\])/
     my ($str, $link) = ($1, $2);
     SimpleRulesDirty($str, GetDownloadLink($link, 1))/ego);
  }
  return $block;
}

sub SimpleRulesProtect {
  my $html = shift;
  $counter++;
  $protected{$counter} = $html;
  return $PROT . $counter . $PROT;
}

sub SimpleRulesDirty {
  my ($str, $html) = @_;
  $counter++;
  $dirty{$counter} = $str;
  $protected{$counter} = $html;
  return $DIRT . $counter . $DIRT;
}

sub SimpleRulesMungeResult {
  my $raw = shift;
  $raw = SimpleRulesUnprotect($raw);
  # now do the dirty and clean block stuff
  my @blocks;
  my @flags;
  my $count = 0;
  my $html;
  foreach $item (split(/$DIRT([0-9]+)$DIRT/, $raw)) {
    if ($count % 2) { # deal with reference
      if ($dirty{$item}) { # dirty block
	if ($html) {
	  push (@blocks, $html); # store what we have as a clean block
	  push (@flags, 0);
	  print $html; # flush what we have
	  $html = '';
	}
	push (@blocks, $dirty{$item}); # store the raw fragment as dirty block
	push (@flags, 1);
	if (ref($protected{$item}) eq 'CODE') { # print stored html or execute code
	  &{$protected{$item}};
	} else {
	  print $protected{$item};
	}
      } else { # clean reference
	$html .= $protected{$item};
      }
    } else { # deal with normal text
      $html .= $item;
    }
    $count++;
  }
  if ($html) { # deal last bit of unprinted normal text
    print $html;
    push (@blocks, $html); # store what we have as a clean block
    push (@flags, 0);
  }
  return (join($FS, @blocks), join($FS, @flags));
}

sub SimpleRulesUnprotect {
  my $raw = shift;
  $raw =~ s/$PROT([0-9]+)$PROT/$protected{$1}/ge
    while $raw =~ /$PROT([0-9]+)$PROT/; # find recursive replacements!
  return $raw;
}

__DATA__

This is the text page for the rules.
This is a single paragraph.
With a link to [[other paragraphs]].

* This is a list
  with three items.
* Second item.
* Third item with a link: [[list items]].

We also have numbered lists:

1. We use something like setext...
2. But we ~extend~ it.
3. **Really we do!**

//multi-word emphasis// and
__multi-word underlining__, and we also
allow the similar /single/ _word_ *rules*.

I think that's all the rules we [[implemented]].
