# -*- mode:cperl -*-

sub ApplyRules {
  # locallinks: apply rules that create links depending on local config (incl. interlink!)
  my ($text, $locallinks) = @_;
  # shortcut for dirty blocks (if this is the content of a real page: no caching!)
  if ($locallinks and $text =~ m/^\[\[$FreeLinkPattern\]\]$/) {
    print GetPageOrEditLink($1,0,0,1);
    return;
  }
  $text =~ s/[ \t]+\n/\n/g; # no trailing whitespace to worry about
  my @paragraphs = split(/\n\n+/, $text);
  my $html;
  my @escapes;
  my @dirty;
  foreach my $block (@paragraphs) {
    if ($block =~ /^(.+?)\n(--+)$/ and length($1) == length($2)) {
      $block = $q->h3($1);
    } elsif ($block =~ /^(.+?)\n(==+)$/ and length($1) == length($2)) {
      $block = $q->h2($1);
    } elsif ($block =~ /^\* (.*)/s) {
      $block = $q->ul( map{$q->li($_)} split(/\n\* */, $1));
    } elsif ($block =~ /^[0-9]\. (.*)/s) {
      $block = $q->ol( map{$q->li($_)} split(/\n[0-9]\. */, $1));
    } else {
      $block = $q->p($block);
    }
    $block =~ s/\*\*(.+?)\*\*/$q->strong($1)/seg;
    $block =~ s/~(\S+)~/$q->em($1)/eg;
    if ($locallinks) {
      ($block =~ s/(\[\[$FreeLinkPattern\]\])/
       push (@dirty, $1);
       push (@escapes, GetPageOrEditLink($2,0,0,1));
       $FS;/ego);
    }
    # add more rules here
    $html .= $block;
  }
  # now do the dirty and clean block stuff
  my @blocks;
  my @flags;
  foreach $_ (split(/$FS/, $html)) {
    print $_;
    push (@blocks, $_);
    push (@flags, 0);
    if (@dirty) {
      push (@blocks, shift(@dirty));
      push (@flags, 1);
      print shift(@escapes);
    }
  }
  return (join($FS, @blocks), join($FS, @flags));
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

I think that's all the rules we [[implemented]].
