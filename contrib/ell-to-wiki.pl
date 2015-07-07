#!/usr/bin/perl
# -*- coding: utf-8 -*-

# Copyright (C) 2004  Alex Schroeder <alex@gnu.org>
# Copyright (C) 2007  Vinicius José Latorre <viniciusjl at ig.com.br>
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

use LWP::UserAgent;
use XML::Parser;

sub GetRaw {
    my $uri = shift;
    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new('GET', $uri);
    my $response = $ua->request($request);
    return $response->content;
}


{
    package MySubs;
    my %index = {};
    sub StartTag {
	my ($e, $name) = @_;
	if ($name eq 'entry') {
	    my $key = uc(substr($_{filename}, 0, 1));
	    unless (exists $index{$key}) {
		$index{$key} = 1;
		print "= $key =\n\n";
	    }
	    print "[$_{site} $_{filename}] --- $_{description} (by $_{contact})\n\n";
	} elsif ($name eq 'date') {
	    print "Timestamp: ";
	}
    }
    sub EndTag {
	my ($e, $name) = @_;
	if ($name eq 'date') {
	    print "\nThis page is based on the EmacsLispList by StephenEglen and updated automatically.\n\n*Do not edit.*\n\n<toc/dense>\n\n";
	}
    }
    sub Text {
	print $_ if $_;
    }
}

sub parse {
    my $data = GetRaw('http://anc.ed.ac.uk/~stephen/emacs/ell.xml');
    my $parser = new XML::Parser(Style => 'Stream', Pkg => 'MySubs');
    binmode(STDOUT, ':utf8');
    $parser->parse($data);
}

parse();
