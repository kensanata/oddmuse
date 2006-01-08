# Copyright (C) 2005  Fletcher T. Penney <fletcher@freeshell.org>
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
#

$ModulesDescription .= '<p>$Id: pdf.pl,v 1.5 2006/01/08 20:48:00 fletcherpenney Exp $</p>';

*PdfOldDoBrowseRequest = *DoBrowseRequest;
*DoBrowseRequest = *PdfDoBrowseRequest;

use vars qw($pdfDirectory $pdfProcessCommand $tempBaseDirectory);

# These variables must be configured properly!
$pdfProcessCommand 		= "/path/to/your/pdflatexscript"
						unless defined $pdfProcessCommand;
# Note - this script will vary from machine to machine
# The key is to set up pdflatex to use the appropriate texmf folder
# Also, I recommend running three times, if you use indexing, etc
# You can also try to get latexmk to work (I could not)

# My file:

# #!/bin/sh
#
# # Use MultiMarkdown to automagically convert a text file to html and pdf
#
# IFS=' '
# 
# export TEXINPUTS=/arpa/af/f/fletcher/texmf//:
# 
# for filename in "$@"
# do
#
# # Use XSLT to process XHTML to LaTeX
# /usr/pkg/bin/xsltproc /www/af/f/fletcher/wiki/wikidb/modules/Markdown/xhtml2article.xslt "$filename" > "${filename%.*}.tex"
# 
# /usr/pkg/bin/pdflatex "$filename"
# /usr/pkg/bin/pdflatex "$filename"
# /usr/pkg/bin/pdflatex "$filename"
#
# done

$tempBaseDirectory	= "$ModuleDir/Markdown/temp"
						unless defined $tempBaseDirectory;
$pdfDirectory		= "/path/to/your/pdf/directory"
						unless defined $pdfDirectory;


# Do not need to change these
$tempDirectory		= "";


sub PdfDoBrowseRequest{
	my $id = GetId();
	$id = FreeToNormal($id);
	
	if (GetParam('pdf','')) {

		# Strip `.pdf` if present
		# This does cause problems if you have a page name
		# that ends in `.pdf`...
                
		$id =~ s/\.pdf$//;


		# Isolate ourselves
		local %Page;
		local $OpenPageName = '';
				
		OpenPage($id);

		# Create a working directory				
		CreateTempDirectory($id);

		# Isolate our output
		outputHTML($id);

		createPDF();
		
		
		if (-f "$pdfDirectory/$id.pdf") {
			# Remove working directory/lockfile
			system ("/bin/rm -rf \"$tempDirectory\"");

			# pdf in place, redirect browser to download
			my %headers = (-uri=>"$ScriptName/pdf/$id.pdf");
			print $q->redirect(%headers);
		} else {
			# Something happened - pdf not in place
			# Leave lockfile to prevent the hard-headed from
			# killing your server, and for debugging
			
			ReportError(Ts('There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.', $id));
		}

	} else {
		&PdfOldDoBrowseRequest();
	}
}


# Create an HTML file with just the content of the page body
sub outputHTML {
	($id) = @_;
	my $result = '';
	
	local *STDOUT;
	open(STDOUT, '>', \$result);
	local *STDERR;
	open(STDERR, '>/dev/null');

	# Fix Markdown
	print PageHtml($id);

	open(FILE,"> $tempDirectory/temp.html") or ReportError(Ts('Cannot write %s', "temp.html"));
	
	print FILE qq{<?xml version="1.0" encoding="UTF-8" ?>
<html>
	<head>};
		
	# Create meta-data (you can customize this)
	print FILE qq{<title>$OpenPageName</title>};
	print FILE qq{<meta name="author" content="$SiteName"/>};
	print FILE qq{<meta name="copyright" content="2005. This work is licensed under a Creative Commons License:  http://creativecommons.org/licenses/by-sa/2.5/"/>};
	print FILE qq{<meta name="XMP" content="CCAttributionShareAlike"/>};
	print FILE "</head><body>";
	
	# Output the body and close the file
	print FILE $result;
	print FILE "\n</body>\n</html>\n";
	close FILE;
	
}


# Run a series of steps to convert XHTML to pdf
# You may have to change this based on your system
sub createPDF {
	local *STDOUT;
	open(STDOUT, '>/dev/null');
	local *STDERR;
	open(STDERR, '>/dev/null');
			
	# Run latex script and copy pdf to final location
	system("cd \"$tempDirectory\"; \"$pdfProcessCommand\" temp.html > /dev/null; /bin/cp temp.pdf \"$pdfDirectory/$id.pdf\" ");
}



# If we save a new version of a file, we want to delete the old pdf
# To save wasted time, don't recreate it until called for

*PdfOldDoPost = *DoPost;
*DoPost = *PdfNewDoPost;

sub PdfNewDoPost {
	my $id = FreeToNormal(shift);

	unlink("$pdfDirectory/$id.pdf");
	
	PdfOldDoPost($id);
}


sub CreateTempDirectory {
	my ($id) = @_;
	
	$tempDirectory = "$tempBaseDirectory/$id";
	
	# Create the general directory if it doesn't exist
	CreateDir($tempBaseDirectory);
	
	# Now, create a temp directory for this page
	# If it exists, then someone else is generating pdf - give error message
	
	if (-d $tempDirectory) {
		# Someone else is creating this pdf
		
		ReportError(Ts('Someone else is generating a pdf for %s.  Please wait a minute and then try again.', $id));
	
	}
	
	CreateDir($tempDirectory);
}



# Fix Wiki Links - they have to be fully qualified

*PdfOldCreateWikiLink = *CreateWikiLink;
*CreateWikiLink = PdfNewCreateWikiLink;

sub PdfNewCreateWikiLink {
	my $title = shift;
	
	my $rawlink = PdfOldCreateWikiLink($title);
	
	if ($rawlink =~ /http\:\/\//) {
		return $rawlink;
	} else {
		$rawlink =~ s/\((.*)\)/($ScriptName\/$1)/;
		
		return $rawlink;
	}
}

*PdfOldGetFooterLinks = *GetFooterLinks;
*GetFooterLinks = *PdfNewGetFooterLinks;

sub PdfNewGetFooterLinks {
	my ($id, $rev) = @_;
	my $result = PdfOldGetFooterLinks($id,$rev);	


	push(@NoLinkToPdf,"");	
	foreach my $page (@NoLinkToPdf) {
		if ($id =~ /^$page$/) {
			return $result;
		}
	}
	
	return $result . "<br/>" . ScriptLink("pdf/$id.pdf",T('Download this page as PDF'));
}