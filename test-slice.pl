%h = ('a' => 'b', \['1', '2'] => 'c');
foreach (keys %h) {
  print "$_ -> $h{$_}\n";
  print "@{$_}\n";
}
