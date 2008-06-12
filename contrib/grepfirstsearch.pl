# #!/bin/perl

# $t = AllPagesSearch("LocalEvents") ;

sub AllPagesSearch {
   my $string = shift ;
   my @out ;
   my %count ;
   # return a list of pages that have the raw string in them according to grep
   # to hand to SearchTitleAndBody
   my $dir = "data/page" ;

   # first search page names. Too lazy to write recursive code here - let 
   # ls -l do it instead of "opendir"

   open(IN,"/bin/ls $dir/*/*|")  ;
   while (<IN>) { if (m/^.*\/(.*$string.*).pg$/i) { 
      #print "'" . $1 . "'\n" ;
      $count{$1}++ 
      } } ;
   close(IN) ;

   # now search page content
   open(IN,"/opt/csw/bin/ggrep -l -i '" . $string . "' $dir/*/*|") ; 
   while (<IN>) {
      if (m/.*\/(.*).pg/) { $count{$1}++ } 
      } ;
   close(IN) ;

   foreach (sort(keys(%count))) { push (@out,$_) } ;
   return(@out) ;
   } ;
