=head1 NAME

tags - an Oddmuse module that implements email subscription to pages

=head1 SYNOPSIS

Visitors can add their email address and click a checkbox to subscribe
to changes when they edit a page. The requirement to successfully edit
a page acts as a defense mechanism against spammers and vandals.

Email addresses are stored in a file. Each mail contains an
unsubscribe link, and from there users can see (and unsubscribe from)
all other pages they are subscribed to. The link contains a hash of
the email address which prevents others from guessing what email
addresses have subscriptions.

There is also an admin interface that shows which email addresses are
subscribed to which pages, allowing the easy removal of email
addresses from the database.

=head1 LIMITATION

The actual sending of emails is not done by this module. An external
process such as a cron job will have to do this. This complicates
installation, but it will also server as a security measure, since
wiki and mailer are separate processes.

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

$ModulesDescription .= '<p>$Id: mail.pl,v 1.1 2009/05/17 22:43:50 as Exp $</p>';

use vars qw($MailFile);

push (@MyInitVariables, sub {
	$MailFile = "$DataDir/mail.db";
      });

*MailOldGetCommentForm = *GetCommentForm;
*GetCommentForm = *MailNewGetCommentForm;

$CookieParameters{mail} = '';

sub MailNewGetCommentForm {
  my $html = MailOldGetCommentForm(@_);
  $html =~ s!(name="homepage".*?)</p>!$1 . ' '
    . $q->span($q->label({-for=>'mail'}, T('Email: '))
	       . ' ' . $q->textfield(-name=>'mail', -id=>'mail',
				     -default=>GetParam('mail', ''))
	       . $q->checkbox('notify', '', '1', 'send follow-up comments'))
    . '</p>'!ei;
  return $html;
}

*MailOldSave = *Save;
*Save = *MailNewSave;

sub MailNewSave {
  # is called within a lock! :)
  MailOldSave(@_);
  my $id = shift;
  my $mail = GetParam('mail', '');
  my $comment = GetParam('aftertext',  '');
  if ($id and $comment and $mail and GetParam('notify', '')) {
    my $valid = 1;
    eval {
      local $SIG{__DIE__};
      require Mail::RFC822::Address;
      $valid = Mail::RFC822::Address::valid($mail);
      SetParam('msg', Ts('%s appears to be an invalid mail address', $mail))
	unless $valid;
    };
    MailAddSubscription($id, $mail) if $valid;
  }
}

sub MailAddSubscription {
  # is called within a lock! :)
  my ($id, $mail) = @_;
  # open the DB file
  require DB_File;
  tie %h, "DB_File", $MailFile;
  # add both email and pagename references
  for my $i (0, 1) {
    my %collection = map {$_=>1} split(/$FS/, $h{$_[$i]});
    if (not $collection{$_[1-$i]}) {
      $collection{$_[1-$i]} = 1;
      $h{$_[$i]} = join($FS, keys %collection);
    }
  }
  untie %h;
}

push(@MyAdminCode, \&MailMenu);

sub MailMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=subscriptions',
		  T('Mail subscriptions'),
		  'subscriptions'));
}

$Action{subscriptions} = \&DoMailSubscriptions;

sub DoMailSubscriptions {
  my $mail = GetParam('mail', '');
  print GetHeader('', T('Subscriptions')),
    $q->start_div({-class=>'content subscriptions'}),
    GetFormStart(undef, 'get', 'mail');
  if (not $mail) {
    print $q->p($q->span($q->label({-for=>'mail'}, T('Email: '))
			 . ' ' . $q->textfield(-name=>'mail', -id=>'mail'))),
      $q->input({-type=>'hidden',-name=>'action',-value=>'subscriptions'}),
      ' ', $q->submit(-name=>'Show', -value=>T('Show'));
  } else {
    print $q->input({-type=>'hidden',-name=>'action',-value=>'unsubscribe'}),
      $q->p(join($q->br(),
		 map { $q->checkbox('id', '', '', NormalToFree($_)) }
		 MailSubscription($mail)));
  }
  print $q->endform(), $q->end_div();
  PrintFooter();
}

sub MailSubscription {
  my $mail = shift;
  return unless $mail;
  require DB_File;
  tie %h, "DB_File", $MailFile;
  my @result = split(/$FS/, $h{$mail});
  untie %h;
  return @result;
}

$Action{subscriptionlist} = \&DoMailSubscriptionList;

sub DoMailSubscriptionList {
  UserIsAdminOrError();
  print GetHttpHeader('text/plain');
  require DB_File;
  tie %h, "DB_File", $MailFile;
  foreach my $key (sort keys %h) {
    print "$key: " . join(', ', sort split(/$FS/, $h{$key})) . "\n";
  }
  untie %h;
}
