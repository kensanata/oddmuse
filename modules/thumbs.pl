# Copyright (C) 2004, 2012 Alex Schroeder <alex@gnu.org>
# Copyright (C) 2005 Rob Neild
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

# Thumbnail (and improved image handling) module for OddMuse wiki
# Conflicts with the "Image extension module"

require MIME::Base64;

use File::Path;

AddModuleDescripton('thumbs.pl', 'Image Thumbnails');

# Tempoary directory to create thumbnails in
$ThumbnailTempDir = '/tmp';

# Path and name of external program to use to create thumbnails. Only
# ImageMagick 'convert' can be used. You may have to set the MAGICK_HOME
# environment variable in your config file if you set it to
# /usr/local/bin/convert and get the following error:
#   convert: no decode delegate for this image format
# For your config file:
#   $ENV{MAGICK_HOME} = '/usr/local';
$ThumbnailConvert = '/usr/bin/convert';

# Max size for a thumbnail. If larger size is specified just shows
# regular image
$ThumbnailMaxSize  = 500;

# Default thumbnail size if non is specified
$ThumbnailDefaultSize = 100;

# MIME types to create thumbnail for, all allowed if empty list
@ThumbnailTypes =  @UploadTypes;

# As well as using ALT, use TITLE. This enables comments to popup when
# hovering mouse over thumbnail
$ThumbnailImageUseTitle = 0;

$ThumbnailCacheDir = "oddmuse_thumbnail_cache";
$ThumbnailCacheUrl = "/oddmuse_thumbnail_cache";

# Define new formatting rule "thumb" that inserts an auto generated thumbnail
# Syntax is [[thumb:page name | etc. ]]

push(@MyRules, \&ThumbNailSupportRule);

sub ThumbNailSupportRule {
   my $result;
   my $RawMatch;

  if (m!\G(\[\[thumb:$FreeLinkPattern(\|.*?)?\]\])!gc)
  {

       $RawMatch = $1;

       # Try and extract out all the options. They can be in any order, apart from comment at end

       my $name = $2;

       my $size="$ThumbnailDefaultSize";              # default size for thumbnail
       my $frame;
       my $comment;                                          # default alignment for a non framed picture
       my $alignment_framed = 'tright';              # default alignment for a framed picture
       my $alignment;

       my $params = $3 . '|';

       if($params =~ s/\|([0-9]+)px\|/\|/)  { $size = $1; }

       if($params =~ s/\|thumb\|/\|/) { $frame = 'yes' ;}
       if($params =~ s/\|frame\|/\|/) { $frame = 'yes'; }

       if ($params =~ s/\|none\|/\|/)  { $alignment_framed= 'tnone'; }
       if ($params =~ s/\|right\|/\|/)  { $alignment_framed= 'tright'; $alignment='floatright';}
       if ($params =~ s/\|left\|/\|/)  { $alignment_framed= 'tleft'; $alignment='floatleft'; }

       if ($params =~ m/\|(.+)\|$/) { $comment = $1; }

      my $id = FreeToNormal($name);
      AllPagesList();

      # if the page does exists
    
      if ($IndexHash{$id})
      {


            if (! -e "$ThumbnailCacheDir/$id/$size")
           { 
                   GenerateThumbNail ($id, $size); 
           }

    
         my %img_attribs;

          my $action = "$ThumbnailCacheUrl/" . UrlEncode($id) . "/$size"; 
          
         $img_attribs{'-src'} = $action;

         if (defined $comment)  { 
                     $img_attribs{'-alt'} ="$comment";
                     $img_attribs{'-title'} = "$comment" if $ThumbnailImageUseTitle==1;
        } 
           else { $img_attribs{'-alt'} = "$name"; }


        $img_attribs{'-class'} = 'upload';

         $result = $q->img(\%img_attribs);
         $result = ScriptLink(UrlEncode($id) , $result, 'image');

         if (defined $frame) {
              if (defined $comment)  { $result = $result . $q->div({-class=>'thumbcaption'}, "$comment"); }
              
              if ($size>0) {
                   $result = $q->div({-style=>"width:" .  ($size+2) . "px"}, $result); 
                   $result = $q->div({-class=>"thumb " .  $alignment_framed}, $result);
              }
         }
         else
         {
              if (defined $alignment) { $result = $q->div({-class=>"$alignment" }, $result); }
         }
     }
     else
     {
           # if the image does not exist
           $result = '[' . T('thumb') . ':' . $name . GetEditLink($id, '?', 1) . ']';
     }

   }

    if (defined $result) 
    { 
           Dirty($RawMatch); 
           print $result;
          
           $result = '';
     }

    return $result;
    
}




# define new action "thumbnail" that actually does the on fly generation of the image
# thumbnails are put into the file so they only need be generated once
# we also store the size of thumbnail so that can be used in the markup

# if we get passed a size of zero then all we need to do is check whether we have the image size stored in thumbnail_0
# this enbles markup for non-thumbnail images better


sub GenerateThumbNail {
   my ($id, $size) = (@_); 

   ValidIdOrDie($id);

    AllPagesList();
    
     if (not $IndexHash{$id}) { ReportError(Ts('Error creating thumbnail from non existant page %s.' , $id), '500 INTERNAL SERVER ERROR'); }   # Page Doesn't exist,


     my $openpage = $OpenPageName;       # remember  the current page we are on


    RequestLockOrError();  
    OpenPage($id);

     # Parse out some data
     #   Check MIME type supported
     #   Check is a file

     my ($text, $revision) = GetTextRevision(GetParam('revision', '')); # maybe revision reset!
     my ($type) = TextIsFile($text); # MIME type if an uploaded file
     my $data = substr($text, index($text, "\n") + 1);

     if ($type)
     {
           my $regexp = quotemeta($type);

            if (@ThumbnailTypes and not grep(/^$regexp$/, @ThumbnailTypes)) {
                ReportError(Ts('Can not create thumbnail for file type %s.' , $type), '415 UNSUPPORTED MEDIA TYPE');
           }
      }
      else
      {
             ReportError(T('Can not create thumbnail for a text document'), '500 INTERNAL SERVER ERROR');
      }


     my $filename = $ThumbnailTempDir . "/odd" . $id . "_" . $size;

     # Decode the original image to a temp file

     open(FD, "> $filename") or ReportError(Ts("Could not open %s for writing whilst trying to save image before creating thumbnail. Check write permissions.",$filename), '500 INTERNAL SERVER ERROR');  
     binmode(FD);
     print FD MIME::Base64::decode($data);
     close(FD);

     eval { mkpath("$ThumbnailCacheDir/$id") };
     if ($@) {
         ReportError(Ts('Can not create path for thumbnail - %s', $@), '500 INTERNAL SERVER ERROR');
     }

    # create the thumbnail

     my $command = "$ThumbnailConvert '$filename' -verbose -resize ${size}x '$ThumbnailCacheDir/$id/$size' 2>&1";
     open (MESSAGE, '-|', $command)
       or ReportError(Tss("Failed to run %1 to create thumbnail: %2", $ThumbnailConvert, $!),
		      '500 INTERNAL SERVER ERROR');

      my $convert = <MESSAGE>;
      close(MESSAGE);

      my $scaled_size_x;
      my $scaled_size_y;

	my $thumbnail_data= '';

        if($?) {
                 ReportError(Ts("%s ran into an error", $ThumbnailConvert), '500 INTERNAL SERVER ERROR', undef,
			     $q->pre($command . "\n" . $convert));
	} elsif($convert =~ m/=>(\d+)x(\d+)/) {
                 $scaled_size_x = $1;
                 $scaled_size_y = $2;
	} elsif (!$convert) {
                 ReportError(Ts("%s produced no output", $ThumbnailConvert), '500 INTERNAL SERVER ERROR');
        } else {
                 ReportError(Ts("Failed to parse %s.", $convert), '500 INTERNAL SERVER ERROR');
        }

        unlink($filename);

        # save tag to page
        #$Page{'thumbnail_' . $size} = '#FILE ' . $type . ' created=' . $Now . ' revision=' . $Page{'revision'} . ' size=' . $scaled_size_x . 'x' . $scaled_size_y . "\n" . $thumbnail_data;
        #SavePage();
        
        ReleaseLock();

        OpenPage($openpage);      # restore original open page
}
