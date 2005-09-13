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

$ModulesDescription .= '<p>$Id: flickrgallery.pl,v 1.4 2005/09/13 05:46:37 fletcherpenney Exp $</p>';

# NOTE: This API key for Flickr is NOT to be used in any other products
# INCLUDING derivative works.  The rest of the code can be used as licensed
$FlickrAPIKey = "a8d5ba0d878e08847ccc8b150e52a859";

use vars qw($FlickrBaseUrl $FlickrHeaderTemplate $FlickrFooterTemplate $FlickrImageTemplate $FlickrExtension $FlickrLabel);


$FlickrBaseUrl = "http://www.flickr.com/services/rest/" unless defined $FlickrBaseUrl;

$FlickrHeaderTemplate = '<h3>$title</h3>
<p>$description</p>
<div class="gallery">' unless defined $FlickrHeaderTemplate;

$FlickrFooterTemplate = '<div class="gallery close"></div></div>' unless defined $FlickrFooterTemplate;

$FlickrImageTemplate = '<div class="image"><a href="$imageurl" title="$title"><img src="http://static.flickr.com/$server/$id_$secret$FlickrExtension.jpg" width="$width" height="$height" alt="$title"/></a><div class="text"><p>$cleanTitle<br/><br/>$description</p></div></div>' unless defined $FlickrImageTemplate;

$FlickrExtension = "_s" unless defined $FlickrExtension;
# s | t | m |  | o
$FlickrLabel = "Square" unless defined $FlickrLabel;
# Square|Thumbnail|Small|Medium|Original

push (@MyRules, \&FlickrGalleryRule);

# Allow compatibility with Markdown Module
push (@MyMarkdownRules, \&MarkdownFlickrGalleryRule);

$RuleOrder{\&FlickrGalleryRule} = -10;

sub FlickrGalleryRule {
	if (/\G^([\n\r]*\&lt;\s*FlickrSet:\s*(\d+)\s*\&gt;\s*)$/mgc) {
		return FlickrGallery($2);
	}
	
	return undef;
}

sub MarkdownFlickrGalleryRule {
	my $text = shift;
	
	$text =~ s{
		^&lt;FlickrSet:\s*(\d+)\s*\>
	}{
		FlickrGallery($1);
	}xmge;
	
	return $text
}

sub FlickrGallery {
	my $id = shift();
	return "&lt;FlickrSet:$id&gt; (error LWP::UserAgent not available)" unless eval {require LWP::UserAgent};
	my $ua = LWP::UserAgent->new;
	my $result = "";
	
	# Get Title and description
	my $url = $FlickrBaseUrl . "?method=flickr.photosets.getInfo&api_key=" . 
		$FlickrAPIKey . "&photoset_id=" . $id;
	my $response = $ua->get($url);

	$response->content =~ /\<title\>(.*?)\<\/title\>/;
	my $title = $1;

	$response->content =~ /\<description\>(.*?)\<\/description\>/;
	my $description = $1;
		
	$result = $FlickrHeaderTemplate;

	$result =~ s/(\$[a-zA-Z\d]+)/"defined $1 ? $1 : ''"/gee;
	
	# Get list of photos and process them
	$url = $FlickrBaseUrl . "?method=flickr.photosets.getPhotos&api_key=" . 
		$FlickrAPIKey . "&photoset_id=" . $id;
	$response = $ua->get($url);

	my $xml = $response->content;
	
	while (
		$xml =~ m/\<photo\s+id=\"(\d+)\"\s+secret=\"(.+?)\"\s+server=\"(\d+)\"/g
	) {
		$result .= FlickrPhoto($1,$2,$3);
	}

	my $footer = $FlickrFooterTemplate;
	
	$footer =~ s/(\$[a-zA-Z\d]+)/"defined $1 ? $1 : ''"/gee;
	$result .= $footer;
	
	return $result;
}

sub FlickrPhoto {
	my ($id, $secret, $server) = @_;
	
	my $ua = LWP::UserAgent->new;
	$url = $FlickrBaseUrl . "?method=flickr.photos.getInfo&api_key=" . 
		$FlickrAPIKey . "&photo_id=" . $id . "&secret=" . $secret;

	my $response = $ua->get($url);
	
	$response->content =~ /\<title\>(.*?)\<\/title\>/;
	my $title = $1;
	my $cleanTitle = $title;

	$response->content =~ /\<description\>(.*?)\<\/description\>/;
	my $description = $1;

	$response->content =~ /\<url type="photopage"\>(.*?)\<\/url\>/;
	my $imageurl = $1;

	$url = $FlickrBaseUrl . "?method=flickr.photos.getSizes&api_key=" . 
		$FlickrAPIKey . "&photo_id=" . $id;

	$response = $ua->get($url);

	$response->content =~ /\<size label=\"$FlickrLabel\" width=\"(\d+)\" height=\"(\d+)\"/;
	my $width = $1;
	my $height = $2;


	my $output = $FlickrImageTemplate;
	$output =~ s/(\$[a-zA-Z\d]+)/"defined $1 ? $1 : ''"/gee;

	return $output
}