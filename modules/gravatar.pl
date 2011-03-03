# Copyright (C) 2010  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: gravatar.pl,v 1.8 2011/03/03 12:55:24 as Exp $</p>';

use Digest::MD5 qw(md5_hex);

# Same as in mail.pl
$CookieParameters{mail} = '';

my $gravatar_regexp = "\\[\\[gravatar:(?:$FullUrlPattern )?([^\n:]+):([0-9a-f]+)\\]\\]";

push(@MyRules, \&GravatarRule);

sub GravatarRule {
  if ($bol && m!\G$gravatar_regexp!cog) {
    my $url = $1;
    my $gravatar = "http://www.gravatar.com/avatar/$3";
    my $name = FreeToNormal($2);
    $url = ScriptUrl($name) unless $url;
    return $q->span({-class=>"portrait gravatar"},
		    $q->a({-href=>$url,
			   -class=>'newauthor'},
			  $q->img({-src=>$gravatar,
				   -class=>'portrait',
				   -alt=>''})),
		    $q->br(),
		    GetPageLink($name));
  }
  return undef;
}

*GravatarOldGetCommentForm = *GetCommentForm;
*GetCommentForm = *GravatarNewGetCommentForm;

sub GravatarNewGetCommentForm {
  my $html = GravatarOldGetCommentForm(@_);
  # the implementation in mail.pl takes precedence!
  return $html if defined &MailNewGetCommentForm;
  my $addition = $q->span({-class=>'mail'},
			  $q->label({-for=>'mail'}, T('Email: '))
			  . ' ' . $q->textfield(-name=>'mail', -id=>'mail',
						-default=>GetParam('mail', ''))
			  . $addition);
  $html =~ s!(name="homepage".*?)</p>!$1 $addition</p>!i;
  return $html;
}

push(@MyInitVariables, \&AddGravatar);

sub AddGravatar {
  my $aftertext = GetParam('aftertext');
  my $mail = GetParam('mail');
  $mail =~ s/^[ \t]+//;
  $mail =~ s/[ \t]+$//;
  my $gravatar = md5_hex(lc($mail));
  my $username = GetParam('username');
  my $homepage = GetParam('homepage');
  $homepage = 'http://' . $homepage
    if $homepage and $homepage !~ m!^https?://!i;
  $homepage .= ' ' if $homepage;
  if ($aftertext && $mail && $aftertext !~ /^\[\[gravatar:/) {
    SetParam('aftertext',
	     "[[gravatar:$homepage $username:$gravatar]]\n$aftertext");
  }
}

*GravatarOldGetSummary = *GetSummary;
*GetSummary = *GravatarNewGetSummary;

sub GravatarNewGetSummary {
  my $summary = GravatarOldGetSummary(@_);
  $summary =~ s/^$gravatar_regexp *//o;
  return $summary;
}
