$Action{static} = \&DoStatic;

use vars qw($StaticDir);

$StaticDir = '/tmp/static';

sub DoStatic {
  return unless UserIsAdminOrError();
  local *ScriptLink = *StaticScriptLink;
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain');
  } else {
    print GetHeader('', T('Static Copy'), '');
  }
  CreateDir($StaticDir);
  foreach my $id (AllPagesList()) {
    print $id, ($raw ? "\n" : $q->br());
    open(F,"> $StaticDir/$id.html") or ReportError(Ts('Cannot write %s', "$StaticDir/$id"));
    print F PageHtml($id);
    close(F);
  }
  print '</p>' unless $raw;
  PrintFooter() unless $raw;
}

sub StaticScriptLink {
  my ($action, $text, $class, $name, $title, $accesskey) = @_;
  my %params;
  if ($action !~ /=/) {
    $params{-href} = $action . ".html";
  }
  $params{'-class'} = $class  if $class;
  $params{'-name'} = UrlEncode($name)  if $name;
  $params{'-title'} = $title  if $title;
  $params{'-accesskey'} = $accesskey  if $accesskey;
  return $q->a(\%params, $text);
}
