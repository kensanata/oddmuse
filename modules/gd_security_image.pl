# GdSecurityImage - a CAPTCHA module for Oddmuse using GD::SecurityImage module
#
# Copyright (C) 2014 Aki Goto <tyatsumi@gmail.com>
#
# Codes reused from MwfCaptcha.pm in mwForum - Web-based discussion forum
# Copyright (c) 1999-2014 Markus Wichitill
#
# Codes reused from questionasker.pl for Oddmuse
# Copyright (C) 2004  Brock Wilcox <awwaiid@thelackthereof.org>
# Copyright (C) 2006, 2007  Alex Schroeder <alex@gnu.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AddModuleDescripton('gd_security_image.pl');

=head1 DESCRIPTION

This is a CAPTCHA module for Oddmuse using GD::SecurityImage module.

=head1 CONFIGURATION

$GdSecurityImageFont
Mandatory.
Set a TTF font file used for generating CAPTCHA images.
Example: '/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf'.

$GdSecurityImageRememberAnswer
If 1, once CAPTCHA is answered, the result is cached on cookies
and you need not to re-answer CAPTCHAs for some duration specified
by $GdSecurityImageDuration.
If 0, CAPTCHA is requested everytime you try to submit forms.
Default = 1.

$GdSecurityImageDuration
The duration a CAPTCHA ticket is valid in seconds.
Default = 60 * 10 (10 minutes).

$GdSecurityImageRequiredList
The page name for exceptions, if defined. Every page linked to via
WikiWord or [[free link]] is considered to be a page which needs
questions asked. All other pages do not require questions asked. If
not set, then all pages need questions asked.

%GdSecurityImageProtectedForms
Forms using one of the specified classes are protected.
Default:  ('comment' => 1, 'edit upload' => 1, 'edit text' => 1,).

$GdSecurityImageDataDir
When using with Namespaces Extension, specify original root data directory
to concentrate GdSecurityImage data files in it.
Default: $DataDir.

$GdSecurityImageWidth
Default: 250.

$GdSecurityImageHeight
Default: 60.

$GdSecurityImagePtsize
Default: 16.

$GdSecurityImageScramble
Default: 1.

$GdSecurityImageChars
Default: [qw(A B C D E F G H I J K L M O P R S T U V W X Y)].

=head1 API

You can use this module in other modules by using following APIs.

GdSecurityImageGetHtml
returns CAPTCHA HTML form element for embedding in HTML form clause.

GdSecurityImageCheck
returns whether CAPTCHA is answered correctly or not.

=head1 DATA STRUCTURE

Image data and ticket data are stored in $DataDir/gd_security_image directory.
Old data are deleted partially whenever CAPTCHA form is accessed.
You can delete this directory totally harmlessly, although it forces users to
re-answer CAPTCHA.

=cut

use vars qw($GdSecurityImageFont $GdSecurityImageRememberAnswer
  $GdSecurityImageDuration $GdSecurityImageRequiredList
  %GdSecurityImageProtectedForms $GdSecurityImageDataDir
  $GdSecurityImageWidth $GdSecurityImageHeight
  $GdSecurityImagePtsize $GdSecurityImageScramble $GdSecurityImageChars
  $GdSecurityImageAA);
use vars qw($GdSecurityImageDir $GdSecurityImageId $GdSecurityImagePngToAA);

use Digest::MD5;
use File::Glob ':glob';

$GdSecurityImageRequiredList = '';

$Action{gd_security_image} = \&GdSecurityImageDoImage;

push(@MyInitVariables, \&GdSecurityImageInitVariables);

sub GdSecurityImageGetImageFile {
  my ($id) = @_;
  return "$GdSecurityImageDir/$id.png";
}

sub GdSecurityImageGetTicketFile {
  my ($id) = @_;
  return "$GdSecurityImageDir/$id.ticket";
}

sub GdSecurityImageGenerate {
  # Load modules
  my $gd = eval { require GD };
  eval { require Image::Magick }
    or ReportError(T('GD or Image::Magick modules not available.'), '500 INTERNAL SERVER ERROR') if !$gd;
  eval { require GD::SecurityImage }
    or ReportError(T('GD::SecurityImage module not available.'));

  # Generate captcha image
  GD::SecurityImage->import($gd ? () : (use_magick => 1));
  my $img = GD::SecurityImage->new(
          width => $GdSecurityImageWidth,
          height => $GdSecurityImageHeight,
          font => $GdSecurityImageFont,
          ptsize => $GdSecurityImagePtsize,
          scramble => $GdSecurityImageScramble,
          rnd_data => $GdSecurityImageChars,
          bgcolor => '#000000',
  );
  $img->random();
  my $newCaptchaStr = $img->random_str();
  $img->create('ttf', int(rand(2)) ? 'default' : 'ec', '#ffffff', '#ffffff');
  $img->particle(3000);

  ### experimental ###
  #my $raw = $img->raw;
  #my $w2 = $GdSecurityImageWidth * 2 / 3;
  #my $h2 = $GdSecurityImageHeight * 2 / 3;
  #my $raw2 = GD::Image->new($w2, $h2);
  #$raw2->copyResampled($raw, 0, 0, 0, 0, $w2, $h2, $raw->getBounds);
  #my $png = $raw2->png;

  # Store captcha image
  my ($imgData) = $img->out(force => 'png');
  my $ticketId = Digest::MD5::md5_hex(rand());
  CreateDir($GdSecurityImageDir);
  my $file = GdSecurityImageGetImageFile($ticketId);
  open my $fh, ">:raw", $file
    or ReportError(Ts('Image storing failed. (%s)', $!), '500 INTERNAL SERVER ERROR');
  print $fh $imgData;
  #print $fh $png; ### experimental ###
  close $fh;

  # Insert captcha ticket
  my %page = ();
  $page{id} = $ticketId;
  $page{generation_time} = $Now;
  $page{string} = $newCaptchaStr;
  CreateDir($GdSecurityImageDir);
  WriteStringToFile(GdSecurityImageGetTicketFile($ticketId), EncodePage(%page));

  return $ticketId;
}

sub GdSecurityImageIsValidId {
  my ($id) = @_;
  return $id =~ /^[0-9a-f]+$/;
}

sub GdSecurityImageReadImageFile {
  my $file = shift;
  utf8::encode($file); # filenames are bytes!
  if (open(IN, '<:raw', $file)) {
    local $/ = undef;   # Read complete files
    my $data=<IN>;
    close IN;
    return (1, $data);
  }
  return (0, '');
}

sub GdSecurityImageDoImage {
  my $id = GetParam('gd_security_image_id', '');

  if (!GdSecurityImageIsValidId($id)) {
    ReportError(T('Bad gd_security_image_id.'), '400 BAD REQUEST');
  }

  my ($status, $data) = GdSecurityImageReadImageFile(GdSecurityImageGetImageFile($id));

  binmode(STDOUT, ":raw");
  print $q->header(-type=>'image/png');
  print $data;

  unlink(GdSecurityImageGetImageFile($id));
}

sub GdSecurityImageCleanup {
  my ($id) = @_;
  if (!GdSecurityImageIsValidId($id)) {
    return;
  }
  my @files = (bsd_glob("$GdSecurityImageDir/*.png"), bsd_glob("$GdSecurityImageDir/*.ticket"));
  foreach my $file (@files) {
    if ($Now - (stat $file)[9] > $GdSecurityImageDuration) {
      unlink($file);
    }
  }
}

sub GdSecurityImageCheck {
  if (defined($GdSecurityImageId)) {
    return $GdSecurityImageId eq '';
  }

  my $id = GetParam('gd_security_image_id', '');
  my $answer = GetParam('gd_security_image_answer', '');

  GdSecurityImageCleanup($id);

  if ($answer ne '' && GdSecurityImageIsValidId($id)) {
    my ($status, $data) = ReadFile(GdSecurityImageGetTicketFile($id));
    if ($status) {
      my %page = ParseData($data);
      if ($page{generation_time} + $GdSecurityImageDuration > $Now) {
        if ($answer eq $page{string}) {
          $GdSecurityImageId = '';
          if (!$GdSecurityImageRememberAnswer) {
            SetParam('gd_security_image_id', '');
            SetParam('gd_security_image_answer', '');
          }
          return 1;
        }
      }
    }
  }

  if (GdSecurityImageIsValidId($id)) {
    unlink(GdSecurityImageGetTicketFile($id));
  }

  $GdSecurityImageId = GdSecurityImageGenerate();
  return 0;
}

sub GdSecurityImageGetHtml {
  if (GdSecurityImageCheck()) {
    return '';
  }

  my $form = '';

  SetParam('gd_security_image_answer', '');

  $form .= $q->start_div({-class=>'gd_security_image'});

  $form .= $q->start_div();
  $form .= T('Please type the six characters from the anti-spam image');
  $form .= $q->end_div();

  $form .= $q->start_div();
  $form .= $q->input({-type=>'hidden', -name=>'gd_security_image_id', -value=>$GdSecurityImageId});
  $form .= $q->textfield(-name=>'gd_security_image_answer', -id=>'gd_security_image_answer');
  $form .= $q->submit(-name=>'Submit', -value=>T('Submit'));
  $form .= $q->end_div();

  $form .= $q->start_div();
  $form .= $q->img({-src=>"$FullUrl?action=gd_security_image&gd_security_image_id=$GdSecurityImageId", -alt=>T('CAPTCHA'), -width=>$GdSecurityImageWidth, -height=>$GdSecurityImageHeight});
  $form .= $q->end_div();

  if ($GdSecurityImageAA) {
    $form .= $q->start_div({class=>'aa_captcha'});
    $form .= $q->start_pre();
    my $png_file = GdSecurityImageGetImageFile($GdSecurityImageId);
    $form .= `$GdSecurityImagePngToAA $png_file`;
    $form .= $q->end_pre();
    $form .= $q->end_div();
  }

  $form .= $q->end_div();

  return $form;
}

*OldGdSecurityImageDoPost = *DoPost;
*DoPost = *NewGdSecurityImageDoPost;

sub NewGdSecurityImageDoPost {
  my(@params) = @_;
  my $id = FreeToNormal(GetParam('title', undef));
  my $preview = GetParam('Preview', undef); # case matters!
  unless (UserIsEditor()
          or $preview
          or GdSecurityImageCheck()
          or GdSecurityImageException($id)) {
    print GetHeader('', T('Edit Denied'), undef, undef, '403 FORBIDDEN');
    print $q->p(T('You did not answer correctly.'));
    print GetFormStart(), GdSecurityImageGetHtml(),
      (map { $q->input({-type=>'hidden', -name=>$_, -value=>UnquoteHtml(GetParam($_))}) }
       qw(title text oldtime summary recent_edit aftertext)), $q->end_form;
    PrintFooter();
    # logging to the error log file of the server
    # warn "Q: '$QuestionaskerQuestions[$question_num][0]', A: '$answer'\n";
    return;
  }
  return (OldGdSecurityImageDoPost(@params));
}

*OldGdSecurityImageGetEditForm = *GetEditForm;
*GetEditForm = *NewGdSecurityImageGetEditForm;

sub NewGdSecurityImageGetEditForm {
  return GdSecurityImageAddTo(OldGdSecurityImageGetEditForm(@_));
}

*OldGdSecurityImageGetCommentForm = *GetCommentForm;
*GetCommentForm = *NewGdSecurityImageGetCommentForm;

sub NewGdSecurityImageGetCommentForm {
  return GdSecurityImageAddTo(OldGdSecurityImageGetCommentForm(@_));
}

sub GdSecurityImageAddTo {
  my $form = shift;
  if (not $upload
      and not GdSecurityImageException(GetId())
      and not UserIsEditor()) {
    my $question = GdSecurityImageGetHtml();
    $form =~ s/(.*)<p>(.*?)<label for="username">/$1$question<p>$2<label for="username">/;
  }
  return $form;
}

sub GdSecurityImageException {
  my $id = shift;
  return 0 unless $GdSecurityImageRequiredList and $id;
  my $data = GetPageContent($GdSecurityImageRequiredList);
  if ($WikiLinks) {
    while ($data =~ /$LinkPattern/g) {
      return 0 if FreeToNormal($1) eq $id;
    }
  }
  if ($FreeLinks) {
    while ($data =~ /\[\[$FreeLinkPattern\]\]/g) {
      return 0 if FreeToNormal($1) eq $id;
    }
  }
  return 1;
}

sub GdSecurityImageInitVariables {
  ReportError(T('$GdSecurityImageFont is not set.'), '500 INTERNAL SERVER ERROR') unless defined $GdSecurityImageFont;
  $GdSecurityImageRememberAnswer = 1 unless defined $GdSecurityImageRememberAnswer;
  $GdSecurityImageDuration = 60 * 10 unless defined $GdSecurityImageDuration;

  $GdSecurityImageRequiredList = FreeToNormal($GdSecurityImageRequiredList);

  # Forms using one of the following classes are protected.
  %GdSecurityImageProtectedForms = ('comment' => 1,
                              'edit upload' => 1,
                              'edit text' => 1,)
    unless defined %GdSecurityImageProtectedForms;

  $GdSecurityImageDataDir = $DataDir unless defined $GdSecurityImageDataDir;

  $GdSecurityImageWidth = 240 unless defined $GdSecurityImageWidth;
  $GdSecurityImageHeight = 75 unless defined $GdSecurityImageHeight;
  $GdSecurityImagePtsize = 16.75 unless defined $GdSecurityImagePtsize;
  $GdSecurityImageScramble = 1 unless defined $GdSecurityImageScramble;
  $GdSecurityImageChars = [qw(A B C D E F G H I J K L M O P R S T U V W X Y)] unless defined $GdSecurityImageChars;

  $GdSecurityImageAA = 0 unless defined $GdSecurityImageAA;

  $GdSecurityImageDir = "$GdSecurityImageDataDir/gd_security_image";

  $GdSecurityImageId = undef;

  $GdSecurityImagePngToAA = "$ModuleDir/pngtoaa";

  $CookieParameters{'gd_security_image_id'} = '';
  $InvisibleCookieParameters{'gd_security_image_id'} = 1;
  $CookieParameters{'gd_security_image_answer'} = '';
  $InvisibleCookieParameters{'gd_security_image_answer'} = 1;
}
