#!/usr/bin/env perl6
use Net::IRC::Bot;
use Net::IRC::Modules::Autoident;
use Net::IRC::Modules::Tell;
use Net::IRC::CommandHandler;

sub wikiLink($page is copy) {
  $page ~~ s:g/\s/_/; # quick and dirty
  return “https://oddmuse.org/wiki/$page”;
}

class Intermap {
  has $.intermapLink is rw = ‘https://oddmuse.org/wiki/Local_Intermap?raw=1’;
  has %!intermap;

  method update {
    # TODO https breaks HTTP::UserAgent, workaround with curl
    my $proc = run(‘curl’, $!intermapLink, :out);
    my $text = $proc.out.slurp-rest;
    $proc.out.close; # RT #126561
    return False unless $proc;
    for $text ~~ m:global〈 ^^ \h+ $<name>=\S+ \s+ $<value>=.+? $$ 〉 {
      %!intermap{~$_<name>} = ~$_<value>; # TODO map!
    }
    return True;
  }

  method said ($e) {
    self.update if not %!intermap or $e.what ~~ / ‘update intermap’ /; # lazy init
    for $e.what ~~ m:global〈 $<name>=<-[\s :]>+ ‘:’ $<value>=\S+ 〉 { # quick and dirty
      next unless %!intermap{.<name>}:exists;
      my $link = %!intermap{~.<name>};
      my $replacement = $_<value>;
      $link ~~ s{ \%s | $ } = $replacement;
      $e.msg: $link;
    }
  }
}

class Pages {
  method said ($e) {
    for $e.what ~~ m:global〈 ‘[[’ $<page>=<-[ \] ]>+ ‘]]’ 〉 { # quick and dirty
      $e.msg: wikiLink ~.<page>;
    }
  }
}


class Sorry {
  has $.answers  is rw = « ‘I'm so sorry!’    ‘Please forgive me!’
                           ‘I should have done better!’
                           ‘I promise that it won't happen again!’ »;

  method said ($e) {
    if $e.what ~~ / ^ "{ $e.bot.nick }" [‘:’|‘,’] / {
      $e.msg: $!answers.pick;
    }
  }
}

class RecentChanges {
  has $.delay is rw = 30;
  has $.url   is rw = ‘https://oddmuse.org/wiki?action=rss;all=0;showedit=0;rollback=1;from=’;
  has $!last = time;

  method joined ($e) {
    start loop {
      sleep $!delay;
      self.process: $e;
    }
  }

  method process ($e) {
    my $newLast = time;
    # TODO https breaks HTTP::UserAgent, workaround with curl
    my $proc = run(‘curl’, $!url ~ $!last, :out);
    my $xml = $proc.out.slurp-rest;
    $proc.out.close; # RT #126561
    return False unless $proc;
    $!last = $newLast;

    use XML;
    for from-xml($xml).elements(:TAG<item>, :RECURSE) {
      my $title  = ~.elements(:TAG<title>,          :SINGLE).contents;
      my $desc   = ~.elements(:TAG<description>,    :SINGLE).contents;
      my $author = ~.elements(:TAG<dc:contributor>, :SINGLE).contents;
      $e.msg: “Wiki: [$title] <$author> – $desc ({wikiLink $title})”;
    }
    return True;
  }
}


class RecentCommits {
  has $.delay is rw = 30;
  has $.url  = ‘https://github.com/kensanata/oddmuse.git’;
  has $.repo = ‘repo’;

  method joined ($e) {
    start {
      if $!repo.IO !~~ :e {
        fail unless run(‘git’, ‘clone’, $!url, $!repo);
      }
      loop {
        sleep $!delay;
        self.process: $e;
      }
    }
  }

  method process ($e) {
    my $proc1 = run(‘git’, ‘--git-dir’, $!repo ~ ‘/.git’, ‘fetch’) ;
    return False unless $proc1;
    my $proc2 = run(‘git’, ‘--git-dir’, $!repo ~ ‘/.git’, ‘log’,
                    ‘--pretty=format:Commit: %s (https://github.com/kensanata/oddmuse/commit/%h)’,
                    ‘...origin’, :out);
    $e.msg: $_ for $proc2.out;
    $proc2.out.close; # RT #126561
    return False unless $proc2;

    run(‘git’, ‘--git-dir’, $!repo ~ ‘/.git’, ‘merge’, ‘-q’);
    return True;
  }
}


class Backlog does Net::IRC::CommandHandler {
  has $.limit is rw = 60 * 60 * 48;
  has $.delay is rw = 30; # seconds before file deletion
  has $.path  is rw = ‘backlogs/’;
  has $.link  is rw = ‘http://alexine.oddmuse.org/backlogs/’; # TODO https
  has %.messages = ();

  multi method said ($e) {
    %!messages{$e.where} = [] unless %!messages{$e.where}:exists;
    %!messages{$e.where}.push: { ‘when’ => time, ‘who’ => $e.who<nick>, ‘what’ => $e.what };
    self.clean;
  }

  method clean {
    for %!messages.values -> $value { # each channel
      for $value.kv -> $index, $elem { # each message
        last if time - $elem<when> < $!limit;
        LAST { $value.splice(0, $index) } # at least one message will be kept
      }
    }
  }

  method backlog ($e, $match) is cmd {
    self.clean;
    mkdir $!path unless $!path.IO ~~ :d;
    my $name = ^2**128 .pick.base(36);
    my $fh = open “$!path/$name”, :w;
    $fh.say(“<{.<who>}> {.<what>}”) for @(%!messages{$e.where});
    $fh.close;
    $e.msg: “$!link$name”;
    Promise.in($!delay).then: { unlink “$!path/$name” };
  }

  method forget ($e, $match) is cmd {
    %!messages{$e.where} = [];
    $e.msg: ‘OK, we didn't have this conversation.’;
  }
}


sub MAIN(Str :$nick = ‘alexine’, Str :$password is copy = ‘’, Str :$channel = ‘#oddmuse’) {
  $password = prompt ‘Nickserv password: ’ unless $password;
  Net::IRC::Bot.new(
    nick     => $nick,
    username => $nick,
    realname => $nick,
    server   => ‘irc.freenode.org’,
    channels => [ $channel ],
    debug    => True,

    modules  => (
      Intermap.new(),
      Pages.new(),
      Sorry.new(),
      RecentChanges.new(),
      #RecentCommits.new(),
      Backlog.new(prefix => ‘.’),
      Net::IRC::Modules::Tell.new(prefix => ‘.’),
      Net::IRC::Modules::Autoident.new(password => $password),
    ),
  ).run;
}
