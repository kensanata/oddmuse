#!/usr/bin/perl

# This wrapper does nothing but tell Oddmuse to use the current
# directory as its data directory.
package OddMuse;
$DataDir = '.';

# You need to get the latest copy of this script from
# http://emacswiki.org/scripts/current.pl
do 'current.pl';
