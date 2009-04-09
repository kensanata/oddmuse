# Copyright (C) 2006, 2008, 2009  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

$ModulesDescription .= '<p>$Id: load-lang.pl,v 1.10 2009/04/09 17:02:17 as Exp $</p>';

$CookieParameters{interface} = '';

use vars qw($CurrentLanguage);

my %library= ('bg' => 'bulgarian-utf8.pl',
	      'de' => 'german-utf8.pl',
	      'es' => 'spanish-utf8.pl',
	      'fr' => 'french-utf8.pl',
	      'fi' => 'finnish-utf8.pl',
	      'gr' => 'greek-utf8.pl',
	      'he' => 'hebrew-utf8.pl',
	      'it' => 'italian-utf8.pl',
	      'ja' => 'japanese-utf8.pl',
	      'ko' => 'korean-utf8.pl',
	      'nl' => 'dutch-utf8.pl',
	      'pl' => 'polish-utf8.pl',
	      'pt' => 'portuguese-utf8.pl',
	      'ro' => 'romanian-utf8.pl',
	      'ru' => 'russian-utf8.pl',
	      'se' => 'swedish-utf8.pl',
	      'sr' => 'serbian-utf8.pl',
	      'zh' => 'chinese-utf8.pl',
	     );

sub LoadLanguage {
  # my $requested_language = "da, en-gb;q=0.8, en;q=0.7";
  my $requested_language = $q->http('Accept-language');
  my @languages = split(/ *, */, $requested_language);
  my %Lang = ();
  foreach $_ (@languages) {
    my $qual = 1;
    $qual = $1 if (/q=([0-9.]+)/);
    $Lang{$qual} = $1 if (/^([-a-z]+)/);
  }
  my $lang = GetParam('interface', '');
  $Lang{2} = $lang if $lang;
  my @prefs = sort { $b <=> $a } keys %Lang;
  # print ($q->header . $q->start_html
  #      . $q->pre("input: $requested_language\n"
  #                . "Result: "
  #                . join(', ', map { "$_ ($Lang{$_})" } @prefs))
  #      . $q->end_html) && exit if GetParam('debug', '');
  foreach $_ (@prefs) {
    last if $Lang{$_} eq 'en'; # the default
    my $file = $library{$Lang{$_}};
    if (-r $file) {
      do $file;
      do "$ConfigFile-$Lang{$_}" if -r "$ConfigFile-$Lang{$_}";
      $CurrentLanguage = $Lang{$_};
      my $f;
      if ($NamespaceCurrent) {
	$f = "$DataDir/../README.$Lang{$_}";
      } else {
	$f = "$DataDir/README.$Lang{$_}";
      }
      $ReadMe = $f if -r $f;
      last;
    }
  }
}

push(@MyInitVariables, \&LoadLanguage);
