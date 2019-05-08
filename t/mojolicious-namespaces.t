# Copyright (C) 2016-2019  Alex Schroeder <alex@gnu.org>
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package OddMuse;
use Test::More;
use Test::Mojo;
use utf8; # tests contain UTF-8 characters and it matters

require './t/test.pl';

add_module('namespaces.pl');

# Before Perl 5.26, this appeared to be required because path_info is already
# decoded!
# AppendStringToFile($ConfigFile, <<'EOF');
# sub GetNamespace {
#   my $ns = GetParam('ns', '');
#   if (not $ns and $UsePathInfo) {
#     my $path_info = $q->path_info();
#     # make sure ordinary page names are not matched!
#     if ($path_info =~ m|^/($InterSitePattern)(/.*)?|
# 	and ($2 or $q->keywords or NamespaceRequiredByParameter())) {
#       $ns = $1;
#     }
#   }
#   ReportError(Ts('%s is not a legal name for a namespace', $ns))
#     if $ns and $ns !~ m/^($InterSitePattern)$/;
#   return $ns;
# }

# *GetId = \&NamespacesNewGetId;

# sub NamespacesNewGetId {
#   my $id = UnquoteHtml(GetParam('id', GetParam('title', ''))); # id=x or title=x -> x
#   if (not $id and $q->keywords) {
#     $id = decode_utf8(join('_', $q->keywords)); # script?p+q -> p_q
#   }
#   if ($UsePathInfo and $q->path_info) {
#     my @path = split(/\//, $q->path_info);
#     $id ||= pop(@path); # script/p/q -> q
#     foreach my $p (@path) {
#       # https://campaignwiki.org/wiki/F%c3%bcnfWinde/G%c3%b6tter means that
#       # FünfWinde and Götter are both treated correctly.
#       SetParam($p, 1);    # script/p/q -> p=1
#     }
#   }
#   # http://example.org/cgi-bin/wiki.pl?action=browse;ns=Test;id=Test means NamespaceCurrent=Test and id=Test
#   # http://example.org/cgi-bin/wiki.pl/Test/Test means NamespaceCurrent=Test and id=Test
#   # In this case GetId() will have set the parameter Test to 1.
#   # http://example.org/cgi-bin/wiki.pl/Test?rollback-1234=foo
#   # This doesn't set the Test parameter.
#   return if $id and $UsePathInfo and $id eq $NamespaceCurrent and not GetParam($id) and not GetParam('ns');
#   return $id;
# }
# EOF

start_mojolicious_server();

my $t = Test::Mojo->new;

# Installation worked
$t->get_ok("$ScriptName?action=version")
  ->content_like(qr/namespaces\.pl/);

# Edit a page in the Main namespace
$t->post_ok("$ScriptName"
	    => form => {title => 'Some_Page',
			text => 'This is the Main namespace.'})
  ->status_is(302);
$t->get_ok("$ScriptName/Some_Page")
  ->status_is(200)
  ->content_like(qr/This is the Main namespace/);

# Edit a page in the Five Winds namespace
$t->post_ok("$ScriptName/FiveWinds"
	    => form => {title => 'Some_Page',
			text => 'This is the Five Winds namespace.'})
  ->status_is(302);
$t->get_ok("$ScriptName/FiveWinds/Some_Page")
  ->status_is(200)
  ->content_like(qr/This is the Five Winds namespace/);

# This didn't overwrite the Main namespace.
$t->get_ok("$ScriptName/Some_Page")
  ->content_like(qr/This is the Main namespace/);

# Umlauts
$t->post_ok("$ScriptName/F%C3%BCnfWinde"
	    => form => {title => 'Some_Page',
			text => 'Wir sind im Namensraum Fünf Winde.'})
    ->status_is(302);
$t->get_ok("$ScriptName/F%C3%BCnfWinde/Some_Page")
    ->status_is(200)
    ->content_like(qr/Wir sind im Namensraum Fünf Winde/);
ok(IsDir("$DataDir/FünfWinde"), '$DataDir FünfWinde exists');

# Double trouble with Umlautes
$t->post_ok("$ScriptName/F%C3%BCnfWinde"
	    => form => {title => 'Zürich',
			text => 'Wir sind immer noch im Namensraum Fünf Winde.'})
    ->status_is(302);
$t->get_ok("$ScriptName/F%C3%BCnfWinde/Z%c3%bcrich")
    ->status_is(200)
    ->content_like(qr/Wir sind immer noch im Namensraum Fünf Winde/);

done_testing();
