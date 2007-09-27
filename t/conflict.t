# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

require 't/test.pl';
package OddMuse;
use Test::More tests => 16;

clear_pages();

# Using the example files from the diff3 manual

my $lao_file = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
};

my $lao_file_1 = q{The Tao that can be told of is not the eternal Tao;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
};
my $lao_file_2 = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their simplicity,
And let there always be being,
  so we may see the result.
The two are the same,
But after they are produced,
  they have different names.
};

my $tzu_file = q{The Nameless is the origin of Heaven and Earth;
The named is the mother of all things.

Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
They both may be called deep and profound.
Deeper and more profound,
The door of all subtleties!
};

my $tao_file = q{The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The named is the mother of all things.

Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their result.
The two are the same,
But after they are produced,
  they have different names.

  -- The Way of Lao-Tzu, tr. Wing-tsit Chan
};

# simple edit

$ENV{'REMOTE_ADDR'} = 'confusibombus';
test_page(update_page('ConflictTest', $lao_file),
	  'The Way that can be told of is not the eternal Way');

# edit from another address should result in conflict warning

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $tzu_file),
	  'The Nameless is the origin of Heaven and Earth');

# test cookie!
test_page($redirect, map { UrlEncode($_); }
	  ('This page was changed by somebody else',
           'Please check whether you overwrote those changes'));

# test normal merging -- first get oldtime, then do two conflicting edits
# we need to wait at least a second after the last test in order to not
# confuse oddmuse.

sleep(2);

update_page('ConflictTest', $lao_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
my $oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $lao_file_1);

sleep(2);

# merge success has lines from both lao_file_1 and lao_file_2
$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $lao_file_2,
		      '', '', '', "oldtime=$oldtime"),
	  'The Tao that can be told of',     # file 1
	  'The name that can be named',      # both
	  'so we may see their simplicity'); # file 2

# test conflict during merging -- first get oldtime, then do two conflicting edits

sleep(2);

update_page('ConflictTest', $tzu_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
$oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $tao_file);

sleep(2);

$ENV{'REMOTE_ADDR'} = 'megabombus';
test_page(update_page('ConflictTest', $lao_file,
		      '', '', '', "oldtime=$oldtime"),
	  q{<pre class="conflict">&lt;&lt;&lt;&lt;&lt;&lt;&lt; ancestor
=======
The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
&gt;&gt;&gt;&gt;&gt;&gt;&gt; other
</pre>},
	  q{<pre class="conflict">&lt;&lt;&lt;&lt;&lt;&lt;&lt; you
||||||| ancestor
They both may be called deep and profound.
Deeper and more profound,
The door of all subtleties!
=======

  -- The Way of Lao-Tzu, tr. Wing-tsit Chan
&gt;&gt;&gt;&gt;&gt;&gt;&gt; other
</pre>});

@Test = split('\n',<<'EOT');
This page was changed by somebody else
The changes conflict
EOT

test_page($redirect, map { UrlEncode($_); } @Test); # test cookie!

# Test conflict during merging without diff3! -- First get oldtime,
# then do two conflicting edits, and notice how merging no longer
# works. We remove diff3 by setting the PATH environment variable to
# ''.

AppendStringToFile($ConfigFile, "\$ENV{'PATH'} = '';\n");

sleep(2);

update_page('ConflictTest', $lao_file);

$_ = `perl wiki.pl action=edit id=ConflictTest`;
/name="oldtime" value="([0-9]+)"/;
$oldtime = $1;

sleep(2);

$ENV{'REMOTE_ADDR'} = 'confusibombus';
update_page('ConflictTest', $lao_file_1);

sleep(2);
$ENV{'REMOTE_ADDR'} = 'megabombus';
diag('An error saying that diff3 was not found is expected because PATH has been unset.');
test_page(update_page('ConflictTest', $lao_file_2,
		      '', '', '', "oldtime=$oldtime"),
	  'The Way that can be told of is not the eternal Way',   # file 2 -- no merging!
	  'so we may see their simplicity',                       # file 2
	  'so we may see the result');                            # file 2

test_page($redirect, map { UrlEncode($_) }
	  ('This page was changed by somebody else',
           'Please check whether you overwrote those changes')); # test cookie!
