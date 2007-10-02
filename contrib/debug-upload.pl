#! /usr/bin/perl
use CGI;
use CGI::Carp;

my $q = new CGI;
print $q->header(),
  $q->start_html('File Upload'),
  $q->h1('File Upload');
print $q->start_form(-method=>'GET'),
  $q->p('File: ', $q->filefield(-name=>'file', -size=>50, -maxlength=>100)),
  $q->p($q->submit()),
  $q->end_form();
if ($q->param('file')) {
  my $file = $q->upload('file');
  if ($file) {
    print $q->p('Upload ok.');
    print $q->p('Name: ', $q->param('file'));
    print $q->p('Info: ', $q->uploadInfo($q->param('file')));
    print $q->p('Type: ', $q->uploadInfo($q->param('file'))->{'Content-Type'});
  } elsif (!$file && $q->cgi_error) {
    print $q->p('Error: ' . $q->cgi_error);
  } else {
    print $q->p('Weird.');
  }
}
print $q->end_html();
