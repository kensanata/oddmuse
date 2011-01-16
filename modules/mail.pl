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

=head1 INSTALLATION

Installing a module is easy: Create a modules subdirectory in your
data directory, and put the Perl file in there. It will be loaded
automatically.

=cut

$ModulesDescription .= '<p>$Id: mail.pl,v 1.7 2011/01/16 03:39:50 as Exp $</p>';

use vars qw($MailFile $MailPattern);

push (@MyInitVariables, sub {
	$MailFile = "$DataDir/mail.db";
      });

# May contain neither space nor @; I'm too scared to put
# Mail::RFC822::Address here.
$MailPattern = '^[^ ]+@[^ ]+$';

=head1 Commenting

When commenting, users are presented with a form where they can
provide username and homepage. With this extension, users can also
provide their mail address and choose to subscribe to comment pages.

In order to get caching right, we also use an invisible cookie
parameter to make sure that visitors will get a new page when they
subscribe or unsubscribe. The alternative would have been to touch the
index file at the end of the subscribe and unsubscribe function.

=cut

*MailOldInitCookie = *InitCookie;
*InitCookie = *MailNewInitCookie;

$CookieParameters{mail} = '';
$CookieParameters{sub} = '';
$InvisibleCookieParameters{sub} = 1;

sub MailNewInitCookie {
  MailOldInitCookie(@_);
    my $mail = GetParam('mail', '');
  $q->delete('mail');
  if (!$mail) {
    # do nothing
  } elsif (!($mail =~ /$MailPattern/o)) {
    $Message .= $q->p(Ts('Invalid Mail %s: not saved.', $mail));
  } else {
    SetParam('mail', $mail);
  }
}

*MailOldGetCommentForm = *GetCommentForm;
*GetCommentForm = *MailNewGetCommentForm;

sub MailNewGetCommentForm {
  my $html = MailOldGetCommentForm(@_);
  my $id = shift;
  my $mail = GetParam('mail', '');
  my $addition;
  if (MailIsSubscribed($id, $mail)) {
    $addition = ' ' . ScriptLink("action=unsubscribe;pages=$id",
				 T('unsubscribe'), 'unsubscribe');
  } else {
    $addition = $q->input({-type=>checkbox, -name=>"notify", -value=>'1'})
      . ScriptLink("action=subscribe;pages=$id", T('subscribe'), 'subscribe');
  }
  $addition = $q->span({-class=>'mail'},
	       $q->label({-for=>'mail'}, T('Email: '))
	       . ' ' . $q->textfield(-name=>'mail', -id=>'mail',
				     -default=>GetParam('mail', ''))
		       . $addition);
  $html =~ s!(name="homepage".*?)</p>!$1 $addition</p>!i;
  return $html;
}

sub MailIsSubscribed {
  # is not called within a lock
  my ($id, $mail) = @_;
  return 0 unless $mail;
  # open the DB file
  require DB_File;
  tie %h, "DB_File", $MailFile;
  my %subscribers = map {$_=>1} split(/$FS/, $h{$id});
  untie %h;
  return $subscribers{$mail};
}

*MailOldGetFooterTimestamp = *GetFooterTimestamp;
*GetFooterTimestamp = *MailNewGetFooterTimestamp;

sub MailNewGetFooterTimestamp {
  my $html = MailOldGetFooterTimestamp(@_);
  my $id = shift;
  my $mail = GetParam('mail', '');
  my $addition;
  if (MailIsSubscribed($id, $mail)) {
    $addition = ScriptLink("action=unsubscribe;pages=$id",
			   T('unsubscribe'), 'unsubscribe');
  } else {
    $addition = ScriptLink("action=subscribe;pages=$id",
			   T('subscribe'), 'subscribe');
  }
  $html =~ s!(.*)(</span>)!$1 $addition$2!i;
  return $html;
}

=head1 Saving

When saving a comment page users can subscribe using a checkbox. To do
this via an URL you need to provide the parameters id, mail, aftertext
(a new comment), and notify (1).

=cut

*MailOldSave = *Save;
*Save = *MailNewSave;

sub MailNewSave {
  # is called within a lock! :)
  MailOldSave(@_);
  my $id = shift;
  my $mail = GetParam('mail', '');
  my $comment = GetParam('aftertext',  '');
  # Compare to GetId() in order to prevent subscription to LocalNames
  # page and other automatic saves.
  if ($id and $id eq GetId() and $comment and $mail
      and GetParam('notify', '')) {
    my $valid = 1;
    eval {
      local $SIG{__DIE__};
      require Mail::RFC822::Address;
      $valid = Mail::RFC822::Address::valid($mail);
      SetParam('msg', Ts('%s appears to be an invalid mail address', $mail))
	unless $valid;
    };
    MailSubscribe($mail, $id) if $valid;
  }
}

*OldMailDeletePage = *DeletePage;
*DeletePage = *NewMailDeletePage;

=head1 Deleting

When a page is deleted, the appropriate subscriptions have to be
deleted as well.

=cut

sub NewMailDeletePage {
  my $id = shift;
  MailDeletePage($id);
  return OldMailDeletePage($id, @_);
}

sub MailDeletePage {
  my $id = shift;
  require DB_File;
  tie %h, "DB_File", $MailFile;
  foreach my $mail (split(/$FS/, delete $h{$id})) {
    my %subscriptions = map {$_=>1} split(/$FS/, $h{$mail});
    delete $subscriptions{$id};
    if (%subscriptions) {
      $h{$mail} = join($FS, keys %subscriptions);
    } else {
      delete $h{$mail};
    }
  }
  untie %h;
}

=head1 Administration menu

The Administration page will have a list to your subscriptions, and if
you are an administrator, it will also have a link to all
subscriptions.

=cut

push(@MyAdminCode, \&MailMenu);

sub MailMenu {
  my ($id, $menuref, $restref) = @_;
  push(@$menuref,
       ScriptLink('action=subscriptions',
		  T('Your mail subscriptions'),
		  'subscriptions'));
  push(@$menuref,
       ScriptLink('action=subscriptionlist',
		  T('All mail subscriptions'),
		  'subscriptionlist')) if UserIsAdmin();
}

=head1 Your subscriptions

The subscriptions action will show you subscriptions and offer to
unsubscribe.

=cut

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
    my @subscriptions = MailSubscription($mail);
    if (@subscriptions) {
      print $q->p(Ts('Subscriptions for %s:', $mail),
		  $q->input({-type=>'hidden',-name=>'action',-value=>'unsubscribe'}));
      print $q->p(join($q->br(),
		       map { $q->input({-type=>checkbox, -name=>"pages", -value=>"$_"})
			       . GetPageLink($_) } @subscriptions));
      print $q->p($q->submit(-name=>'Unsubscribe', -value=>T('Unsubscribe')));
    } else {
      print $q->p(Ts('There are no subscriptions for %s.', $mail));
    }
    print $q->p(ScriptLink('action=subscriptions;mail=', T('Change email address'),
			   'change subscriptions'));
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
  return sort @result;
}

=head1 Administrator Access

The subscriptionlist action will show you the subscription database,
if you're an administrator. It's a plain text file of the data, which
you can use for debugging and scripting purposes.

=cut

$Action{subscriptionlist} = \&DoMailSubscriptionList;

sub DoMailSubscriptionList {
  UserIsAdminOrError();
  my $raw = GetParam('raw', 0);
  if ($raw) {
    print GetHttpHeader('text/plain');
  } else {
    print GetHeader('', T('Subscriptions')),
      $q->start_div({-class=>'content subscribtionlist'}),
      $q->p(T('Mail addresses are linked to unsubscription links.')),
      '<ul>';
  }
  require DB_File;
  tie %h, "DB_File", $MailFile;
  foreach my $key (sort keys %h) {
    my @values = sort split(/$FS/, $h{$key});
    if ($raw) {
      print join(' ', $key, @values) . "\n";
    } else {
        print $q->li(Ts('%s: ', MailLink($key, @values)),
		     join(' ', map { MailLink($_, $key) }
			  sort split(/$FS/, $h{$key})));
    }
  }
  print '</ul></div>' unless $raw;
  PrintFooter() unless $raw;
  untie %h;
}

sub MailLink {
  my ($str, @pages) = @_;
  # The @ is not a legal character for pagenames.
  return GetPageLink($str) if index($str, '@') == -1;
  return ScriptLink("action=unsubscribe;who=$str;"
		    . join(';', map { "pages=$_" } @pages), $str);
}

=head1 Subscription

The subscribe action will subscribe you to pages. The mail parameter
contains the mail address to use and defaults to the value store in
your cookie. Multiple pages parameters contain the pages to subscribe.

=cut

$Action{subscribe} = \&DoMailSubscribe;

sub DoMailSubscribe {
  my @pages = $q->param('pages');
  return DoMailSubscriptions(@_) unless @pages;
  my $mail = GetParam('mail', '');
  if (not $mail) {
    print GetHeader('', T('Subscriptions')),
      $q->start_div({-class=>'content subscribe'}),
      GetFormStart(undef, 'get', 'subscribe');
    print $q->p(Ts('Subscribe to %s.',
		   join(', ', map { GetPageLink($_) } @pages)));
    print $q->p($q->span($q->label({-for=>'mail'}, T('Email: '))
			 . ' ' . $q->textfield(-name=>'mail', -id=>'mail')));
    print $q->hidden('pages', @pages);
    print $q->input({-type=>'hidden',-name=>'action',-value=>'subscribe'}),
      ' ', $q->submit(-name=>'Subscribe', -value=>T('Subscribe'));
  } else {
    my @real = ();
    foreach my $id (@pages) {
      push @real, $id if $IndexHash{$id};
    }
    # subscriptions have to be added in a lock
    RequestLockOrError();
    MailSubscribe($mail, @real);
    ReleaseLock();
    # MailSubscribe will set a parameter and must run before printing
    # the header.
    print GetHeader('', T('Subscriptions')),
      $q->start_div({-class=>'content subscribe'});
    print $q->p(Ts('Subscribed %s to the following pages:', $mail));
    print $q->ul($q->li([map { GetPageLink($_) } @real]));
    print $q->p(T('The remaining pages do not exist.')) if $#real < $#pages;
    print $q->p(ScriptLink('action=subscriptions', T('Your mail subscriptions'),
			   'subscriptions') . '.');
  }
  print $q->end_div();
  PrintFooter();
}

sub MailSubscribe {
  # is called within a lock! :)
  my ($mail, @pages) = @_;
  return unless $mail and @pages;
  # open the DB file
  require DB_File;
  tie %h, "DB_File", $MailFile;
  # add to the mail entry
  my %subscriptions = map {$_=>1} split(/$FS/, $h{$mail});
  for my $id (@pages) {
    $subscriptions{$id} = 1;
  }
  $h{$mail} = join($FS, keys %subscriptions);
  # add to the page entries
  for my $id (@pages) {
    my %subscribers = map {$_=>1} split(/$FS/, $h{$id});
    $subscribers{$mail} = 1;
    $h{$id} = join($FS, keys %subscribers);
  }
  untie %h;
  # changes made will affect how pages look
  SetParam('sub', GetParam('sub', 0) + 1);
}

=head1 Unsubscription

The unsubscribe action will unsubscribe you from pages. The mail
parameter contains the mail address to use and defaults to the value
store in your cookie. Multiple pages parameters contain the pages to
unsubscribe.

The who parameter overrides the mail parameter and is used for
administrator unsubscription from the subscriptionlist action.

=cut

$Action{unsubscribe} = \&DoMailUnsubscribe;

sub DoMailUnsubscribe {
  my $mail = GetParam('who', GetParam('mail', ''));
  my @pages = $q->param('pages');
  return DoMailSubscriptions(@_) unless $mail;
  my @real = ();
  foreach my $id (@pages) {
    push @real, $id if $IndexHash{$id};
  }
  MailUnsubscribe($mail, @real);
  # MailUnsubscribe will set a parameter and must run before printing
  # the header.
  print GetHeader('', T('Subscriptions')),
    $q->start_div({-class=>'content unsubscribe'});
  print $q->p(Ts('Unsubscribed %s from the following pages:', $mail));
  print $q->ul($q->li([map { GetPageLink($_) } @real]));
  print $q->p(T('The remaining pages do not exist.')) if $#real < $#pages;
  print $q->p(ScriptLink('action=subscriptions', T('Your mail subscriptions'),
			 'subscriptions') . '.');
  print $q->end_div();
  PrintFooter();
}

sub MailUnsubscribe {
  my ($mail, @pages) = @_;
  return unless $mail and @pages;
  require DB_File;
  tie %h, "DB_File", $MailFile;
  my %subscriptions = map {$_=>1} split(/$FS/, $h{$mail});
  foreach my $id (@pages) {
    delete $subscriptions{$id};
    # take care of reverse lookup
    my %subscribers = map {$_=>1} split(/$FS/, $h{$id});
    delete $subscribers{$mail};
    if (%subscribers) {
      $h{$id} = join($FS, keys %subscribers);
    } else {
      delete $h{$id};
    }
  }
  if (%subscriptions) {
    $h{$mail} = join($FS, keys %subscriptions);
  } else {
    delete $h{$mail} unless %subscriptions;
  }
  untie %h;
  # changes made will affect how pages look
  SetParam('sub', GetParam('sub', 0) + 1);
}

=head1 Sending Mail

The actual sending of emails depends on setting the appropriate
options.

C<$MailServer>: This defaults to localhost. If you have Oddmuse
installed on a full server that includes an SMTP server such as
sendmail or postfix, you might get away with not setting any of the
variables.

C<$MailUser>: Chances are you will need to authenticate before you can
send an email via your mail server. Specify the name here.

C<$MailPassword>: Specify the password here.

C<$MailFrom>: Often mail servers know which email addresses they
serve. If somebody else tries to use them, they'll return an error
saying that "relaying is not allowed". If you are allowed to use the
mail server, use this option to set the appropriate sender address.

Example setup:

    $MailServer = 'smtp.google.com';
    $MailUser = 'kensanata';
    $MailPassword = '*secret*';
    $MailFrom = 'kensanata@gmail.com';

=cut
