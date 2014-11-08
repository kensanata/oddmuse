# Copyright (C) 2014  Alex Schroeder <alex@gnu.org>
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

require 't/test.pl';
package OddMuse;
use Test::More tests => 25;
use utf8;

clear_pages();
add_module('edit-paragraphs.pl');

my $text = q{Give me a torch: I am not for this ambling;
Being but heavy, I will bear the light.

Nay, gentle Romeo, we must have you dance.


Not I, believe me: you have dancing shoes
With nimble soles: I have a soul of lead
So stakes me to the ground I cannot move.
};

my $page = update_page('Romeo_and_Mercutio', $text);
for my $paragraph (split(/\n\n+/, $text)) {
  test_page($page, 'action=edit-paragraph;title=Romeo_and_Mercutio;paragraph='
	    . UrlEncode($paragraph));
}	   

# Test for extra links in empty paragraphs before and after tables.

add_module('creole.pl');

my $text = q{|PARIS |JULIET |
|Come you to make confession to this father? |To answer that, I should confess to you. |
|Do not deny to him that you love me. |I will confess to you that I love him. |
|So will ye, I am sure, that you love me. | |

-- William Shakespeare, Romeo and Juliet, Act IV, Scene I
};

my $page = update_page('Paris_and_Juliet', $text);
test_page_negative($page, '\|', '</table><p><a ');

for my $row (split(/\n/, $text)) {
  test_page($page, 'action=edit-paragraph;title=Paris_and_Juliet;paragraph='
	    . UrlEncode($row));
}	   

my $text = q{== Romeo and Juliet, Act III, Scene II

* Tybalt is gone, and Romeo banished;
  Romeo that kill'd him, he is banished.
* O God! did Romeo's hand shed Tybalt's blood?
* It did, it did; alas the day, it did!
};

my $page = update_page('Nurse_and_Juliet', $text);

for my $item (split(/\n(?=[*])/, $text)) {
  my $str = UrlEncode($item);
  $str =~ s/\*/\\*/g;
  test_page($page, "action=edit-paragraph;title=Nurse_and_Juliet;paragraph=$str");
}

my $text = q{Benvolio: Tell me in sadness, who is that you love.

Romeo:  What, shall I groan and tell thee?

Benvolio: Groan! why, no. But sadly tell me who.

Romeo: Bid a sick man in sadness make his will: Ah, word ill urged to
one that is so ill! In sadness, cousin, I do love a woman.

Benvolio: I aim'd so near, when I supposed you loved.

Romeo: A right good mark-man! And she's fair I love.

Benvolio: A right fair mark, fair coz, is soonest hit.
};

# replace the first occurence
test_page(update_page('Benvolio_and_Romeo', $text),
	  'Benvolio: Tell me in sadness');
test_page(get_page('action=edit-paragraph title=Benvolio_and_Romeo '
		   . 'paragraph=Benvolio text=Ben'),
	  # not using update_page because of the parameters
	  'Status: 302');
test_page(get_page('Benvolio_and_Romeo'),
	  'Ben: Tell me in sadness',
	  'Benvolio: Groan!');

# reset and try again but replace the occurence around 105
update_page('Benvolio_and_Romeo', $text);
test_page(get_page('action=edit-paragraph title=Benvolio_and_Romeo '
		   . 'around=105 '
		   . 'paragraph=Benvolio text=Ben'),
	  # not using update_page because of the parameters
	  'Status: 302');
test_page(get_page('Benvolio_and_Romeo'),
	  'Benvolio: Tell me in sadness',
	  'Ben: Groan!');

# try again but now let's simulate a page changed in the background
# such that the text is now not exactly at the expected position, but
# close by.
$text =~ s/tell thee/tell you/;
update_page('Benvolio_and_Romeo', $text);
test_page(get_page('action=edit-paragraph title=Benvolio_and_Romeo '
		   . 'around=105 '
		   . 'paragraph=Benvolio text=Ben'),
	  # not using update_page because of the parameters
	  'Status: 302');
test_page(get_page('Benvolio_and_Romeo'),
	  'Benvolio: Tell me in sadness',
	  'Ben: Groan!');
