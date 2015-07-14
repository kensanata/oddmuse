# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

# Die Daten stammen von der deutschen Ausgabe des Monde Diplomatique.
# Falls der Wiki nur Deutsch ist, kann man diese Datei einfach als
# Modul installieren: Im Datenverzeichnis ein neues Unterverzeichnis
# namens 'modules' erstellen, und die Datei hineinkopieren.

# If you are running a multilingual site, then you should explicitly
# load this file from your language-specific config file.

use utf8;
use strict;

AddModuleDescription('national-days-de.pl', 'Special Days') if defined &AddModuleDescription;

our %SpecialDays = (
  '1-1' => 'Haiti: Erlangung der Unabhängigkeit 1804, Kuba: Jahrestag der Revolution 1959, Sudan: Erlangung der Unabhängigkeit 1956',
  '1-26' => 'Australien: Nationalfeiertag (Australia Day), Indien: Republic Day',
  '1-31' => 'Nauru: Erlangung der Unabhängigkeit 1968',
  '1-4' => 'Myanmar (Burma/Birma): Erlangung der Unabhängigkeit 1948',
  '2-4' => 'Sri Lanka: Erlangung der Unabhängigkeit 1948',
  '2-6' => 'Neuseeland: Waitangi Day (Unterzeichnung des Vertrages von Waitangi zwischen Maoris und britischer Regierung 1840)',
  '2-7' => 'Grenada: Erlangung der Unabhängigkeit 1974',
  '2-11' => 'Iran (Persien): Tag des Sieges der islamischen Revolution 1979',
  '2-16' => 'Litauen: Wiederherstellung der Souveränität 1918',
  '2-18' => 'Gambia: Erklärung der Unabhängigkeit 1965',
  '2-22' => 'Saint Lucia: Erlangung der Unabhängigkeit 1979',
  '2-23' => 'Brunei: Nationalfeiertag, Guyana: Gründung der Republik 1970',
  '2-24' => 'Estland: Erklärung der Unabhängigkeit 1918',
  '2-25' => 'Kuwait: Nationalfeiertag',
  '2-26' => 'Kuwait: Befreiungstag',
  '2-27' => 'Dominikanische Republik: Erklärung der Unabhängigkeit 1844',
  '3-1' => 'Bosnien und Herzegowina: Erlangung der Unabhängigkeit 1992',
  '3-3' => 'Bulgarien: Tag der Befreiung von der türkischen Herrschaft 1878',
  '3-6' => 'Ghana: Erklärung der Unabhängigkeit 1957',
  '3-11' => 'Litauen: Wiederherstellung der Souveränität 1990',
  '3-12' => 'Mauritius: Erlangung der Unabhängigkeit 1968',
  '3-14' => 'Andorra: Tag der Verfassung',
  '3-15' => 'Ungarn: Gedenktag an den Revolutions- und Freiheitskampf 1848/49',
  '3-17' => 'Irland: St. Patrick\'s Day',
  '3-20' => 'Tunesien: Erlangung der Unabhängigkeit 1956',
  '3-21' => 'Namibia: Erlangung der Unabhängigkeit 1990',
  '3-23' => 'Pakistan: Beschluss zur Staatsgründung 1940',
  '3-25' => 'Griechenland: Beginn des Freiheitskampfes gegen das Osmanische Reich 1821',
  '3-31' => 'Malta: National Day (Abzug der letzten britischen Truppen 1979)',
  '4-4' => 'Senegal: Erlangung der Unabhängigkeit 1960',
  '4-9' => 'Irak: vorläufig / Eroberung Bagdads durch Koalitionstruppen',
  '4-16' => 'Dänemark: im Ausland der Geburtstag der regierenden Königin Margrethe II. (1940)',
  '4-17' => 'Syrien: Abzug der letzten französischen Mandatstruppen 1946',
  '4-18' => 'Simbabwe: Erlangung der Unabhängigkeit',
  '4-19' => 'Jahrestag der Papstwahl (Benedikt XVI.)',
  '4-25' => 'Italien: Tag der Befreiung 1945',
  '4-26' => 'Tansania: Jahrestag der Vereinigung von Tanganjika und Sansibar 1964',
  '4-27' => 'Afghanistan: Tag der Revolution, Sierra Leone: Erlangung der Unabhängigkeit 1961, Südafrika: Tag der ersten freien Wahlen 1994, Togo: Erlangung der Unabhängigkeit 1960',
  '4-30' => 'Niederlande: Königinnentag',
  '5-1' => 'Marshallinseln: Erklärung der Unabhängigkeit 1979',
  '5-3' => 'Polen: erste polnische Verfassung 1791',
  '5-15' => 'Paraguay: Erklärung der Unabhängigkeit 1811',
  '5-17' => 'Norwegen: Jahrestag der Verfassung',
  '5-20' => 'Kamerun: Erlangung der Unabhängigkeit 1960',
  '5-22' => 'Jemen: Haupt-Nationalfeiertag - Wiedervereinigung von Nord- und Süd-Jemen 1990',
  '5-24' => 'Eritrea: Erklärung der Unabhängigkeit 1993',
  '5-25' => 'Argentinien: Tag des Vaterlandes (Sturz des spanischen Vizekönigs 1810), Jordanien: Erlangung der Unabhängigkeit 1946',
  '5-26' => 'Georgien: Erklärung der Unabhängigkeit 1918',
  '5-28' => 'Aserbaidschan: Erklärung der Unabhängigkeit 1918, Äthiopien: Tag der Niederlage des Derg-Regimes 1991',
  '6-1' => 'Samoa (West-): Beschluß zur Unabhängigkeit 1961',
  '6-2' => 'Italien: Gründung der Republik 1946',
  '6-5' => 'Dänemark: innerhalb Dänemarks wird der Verfassungstag gefeiert (1849), Seschellen: Liberation Day',
  '6-6' => 'Schweden: Flaggentag',
  '6-7' => 'Malta: Sette Giugno (Arbeiteraufstand 1919)',
  '6-10' => 'Portugal: Dia de Portugal (Todestag von Luis Vaz de Camoes 1580)',
  '6-12' => 'Philippinen: Erlangung der Unabhängigkeit, Russland: Tag der Unabhängigkeit - Souveränitätserklärung der RSFSR 1990',
  '6-17' => 'Island: Erklärung der Unabhängigkeit 1944',
  '6-23' => 'Luxemburg: offizieller Geburtstag des regierenden Großherzogs, Henri - der eigentlich am 16.4. Geburtstag hat)',
  '6-25' => 'Kroatien: Erklärung der Unabhängigkeit 1991, Mosambik: Erlangung der Unabhängigkeit 1975, Slowenien: Erklärung der Unabhängigkeit 1991',
  '6-26' => 'Madagaskar: Nationalfeiertag',
  '6-27' => 'Dschibuti: Erlangung der Unabhängigkeit',
  '6-30' => 'Kongo, Demokratische Republik (Zaire): Erlangung der Unabhängigkeit 1960',
  '7-1' => 'Burundi: Erlangung der Unabhängigkeit 1962, Kanada: Nationalfeiertag (Canada Day), Ruanda: Erlangung der Unabhängigkeit 1962',
  '7-3' => 'Belarus (Weißrussland): Nationalfeiertag',
  '7-4' => 'Tonga: Geburtstag des regierenden Königs, Vereinigte Staaten von Amerika: Erklärung der Unabhängigkeit 1776',
  '7-5' => 'Kap Verde: Erlangung der Unabhängigkeit 1975, Venezuela: Erklärung der Unabhängigkeit 1811',
  '7-6' => 'Komoren: Erlangung der Unabhängigkeit 1975, Litauen: Staatsgründung durch die Krönung von Fürst Mindaugas 1250, Malawi: Erlangung der Unabhängigkeit 1964',
  '7-7' => 'Nepal: Geburtstag des regierenden Königs, Salomonen: Erlangung der Unabhängigkeit 1978',
  '7-10' => 'Bahamas: Erklärung der Unabhängigkeit',
  '7-11' => 'Mongolei: Jahrestag des Sieges der Revolution (1921)',
  '7-12' => 'Kiribati: Erlangung der Unabhängigkeit 1979, Sao Tome und Principe: Erlangung der Unabhängigkeit 1975',
  '7-14' => 'Frankreich: Jahrestag des Sturms auf die Bastille 1789',
  '7-20' => 'Kolumbien: Erklärung der Unabhängigkeit 1810',
  '7-21' => 'Belgien: Tag der Vereidigung des ersten belgischen Königs, Leopold I.',
  '7-23' => 'Ägypten: Revolutionstag 1952',
  '7-26' => 'Liberia: Erklärung der Unabhängigkeit 1847, Malediven: Erlangung der Unabhängigkeit 1965',
  '7-28' => 'Peru: Erklärung der Unabhängigkeit 1821',
  '7-30' => 'Marokko: Thronbesteigung des regierenden Königs Mohammed VI. 1999, Vanuatu: Erlangung der Unabhängigkeit 1980',
  '8-1' => 'Benin: Erlangung der Unabhängigkeit, Schweiz: Jahrestag der Bundesfeier 1291',
  '8-2' => 'Mazedonien: Gedenktag anlässlich des Aufstandes gegen die Türken 1903',
  '8-6' => 'Bolivien: Erlangung der Unabhängigkeit, Jamaika: Erklärung der Unabhängigkeit 1962',
  '8-7' => 'Elfenbeinküste: Erlangung der Unabhängigkeit 1960',
  '8-9' => 'Singapur: Erlangung der Unabhängigkeit 1965 durch Ausscheiden aus der Malayischen Föderation',
  '8-10' => 'Ecuador: Erklärung der Unabhängigkeit 1809',
  '8-11' => 'Tschad: Erlangung der Unabhängigkeit 1960',
  '8-14' => 'Pakistan: Staatsgründung 1947',
  '8-15' => 'Indien: Erklärung der Unabhängigkeit (Independence Day), Kongo, Republik: Erlangung der Unabhängigkeit 1960, Korea, Süd: Erklärung der Unabhängigkeit 1948, Liechtenstein: Nationalfeiertag',
  '8-17' => 'Gabun: Erlangung der Unabhängigkeit 1960, Indonesien: Erklärung der Unabhängigkeit 1945',
  '8-19' => 'Afghanistan: Erlangung der Unabhängigkeit',
  '8-20' => 'Estland: Erklärung der Wiederherstellung der Unabhängigkeit 1991, Ungarn: offizieller Haupt-Nationalfeiertag (Fest des Staatsgründers und ersten ungarischen Königs Stephan des Heiligen)',
  '8-24' => 'Ukraine: Erklärung der Unabhängigkeit 1991',
  '8-25' => 'Uruguay: Erlangung der Unabhängigkeit 1825',
  '8-27' => 'Moldau: Erklärung der Unabhängigkeit 1991',
  '8-29' => 'Slowakei: Tag des slowakischen Nationalaufstandes',
  '8-31' => 'Kirgisistan: Erklärung der Unabhängigkeit 1991, Malaysia: Erlangung der Unabhängigkeit 1957, Trinidad und Tobago: Erlangung der Unabhängigkeit',
  '9-1' => 'Libyen: Jahrestag der Revolution 1969, Slowakei: Tag der Verfassung der Slowakischen Republik, Usbekistan: Erklärung der Unabhängigkeit 1991',
  '9-2' => 'Vietnam: Erklärung der Unabhängigkeit 1945',
  '9-3' => 'Katar: Erlangung der Unabhängigkeit 1971, San Marino: Tag der Staatsgründung',
  '9-6' => 'Swasiland: Erlangung der Unabhängigkeit 1968',
  '9-7' => 'Brasilien: Erklärung der Unabhängigkeit (1822)',
  '9-8' => 'Andorra: Tag der Schutzpatronin von Andorra, Malta: Our Lady of Victory (Ende der großen Türken-Belagerung 1565), Mazedonien: Erklärung der Unabhängigkeit 1991',
  '9-9' => 'Korea, Nord: Erklärung der Unabhängigkeit 1948, Tadschikistan: Erklärung der Unabhängigkeit 1991',
  '9-15' => 'Costa Rica: Erklärung der Unabhängigkeit 1821, El Salvador: Erklärung der Unabhängigkeit 1821, Guatemala: Erklärung der Unabhängigkeit 1821, Honduras: Erklärung der Unabhängigkeit 1821, Nicaragua: Erklärung der Unabhängigkeit 1821',
  '9-16' => 'Mexiko: Erklärung der Unabhängigkeit 1810, Papua-Neuguinea: Erklärung der Unabhängigkeit 1975',
  '9-18' => 'Chile: Erklärung der Unabhängigkeit 1810',
  '9-19' => 'Chile: Erklärung der Unabhängigkeit 1810, Saint Kitts und Nevis: Erlangung der Unabhängigkeit 1983',
  '9-21' => 'Armenien: Erklärung der Unabhängigkeit, Belize: Erklärung der Unabhängigkeit, Malta: Independence Day (Erlangung der Unabhängigkeit 1964)',
  '9-22' => 'Mali: Erlangung der Unabhängigkeit 1960',
  '9-23' => 'Saudi-Arabien: Proklamation des Königreichs 1932',
  '9-24' => 'Guinea-Bissau: Erklärung der Unabhängigkeit 1973',
  '9-26' => 'Jemen: Revolutionstag (Nord-Jemen) 1962',
  '9-30' => 'Botsuana (Botswana): Erlangung der Unabhängigkeit 1966',
  '10-1' => 'China: Gründung der Volksrepublik 1949, Nigeria: Erlangung der Unabhängigkeit, Palau: Erlangung der Unabhängigkeit 1994, Tuvalu: Erlangung der Unabhängigkeit 1978, Zypern: Erklärung der Unabhängigkeit 1960', 
  '10-2' => 'Guinea: Erklärung der Unabhängigkeit 1958',
  '10-3' => 'Deutschland: Jahrestag der Wiedervereinigung 1990',
  '10-4' => 'Lesotho: Erlangung der Unabhängigkeit',
  '10-9' => 'Uganda: Erlangung der Unabhängigkeit 1962',
  '10-10' => 'Fidschi: Erlangung der Unabhängigkeit 1970, Taiwan: Tag der republikanischen Revolte gegen die Mandschu-Dynastie 1911 bzw. Tag der Staatsgründung',
  '10-12' => 'Spanien: Gedenktag an die Entdeckung Amerikas 1492, Äquatorial Guinea: Erlangung der Unabhängigkeit 1968',
  '10-14' => 'Jemen: Revolutionstag (Süd-Jemen) 1963',
# '10-16' => 'Vatikanstaat: Jahrestag der Wahl des letzte nPapstes (Johannes Paul II.)',
  '10-21' => 'Somalia: Nationalfeiertag',
  '10-23' => 'Ungarn: Gedenktag für den Volksaufstand 1956 sowie Erklärung der Unabhängigkeit 1989',
  '10-24' => 'Sambia: Erlangung der Unabhängigkeit 1964',
  '10-26' => 'Österreich: Jahrestag der Verabschiedung des Neutralitätsgesetzes 1955',
  '10-27' => 'Saint Vincent und die Grenadinen: Erlangung der Unabhängigkeit 1979, Turkmenistan: Erklärung der Unabhängigkeit 1991',
  '10-28' => 'Tschechische Republik: Erlangung der Unabhängigkeit 1918',
  '10-29' => 'Türkei: Ausrufung der Republik durch Atatürk 1923',
  '11-1' => 'Algerien: Beginn der Revolution 1954, Antigua und Barbuda: Erlangung der Unabhängigkeit',
  '11-3' => 'Dominica: Erlangung der Unabhängigkeit, Mikronesien: Erlangung der Unabhängigkeit 1986, Panama: Erklärung der Unabhängigkeit 1903',
  '11-9' => 'Kambodscha: Tag der Entlassung aus dem französischen Protektorat 1953',
  '11-11' => 'Angola: Erlangung der Unabhängigkeit 1975, Polen: Erlangung der Unabhängigkeit 1918',
  '11-18' => 'Lettland: Erklärung der Unabhängigkeit 1918, Oman: Geburtstag des herrschenden Sultans',
  '11-19' => 'Monaco: Namenstag des regierenden Fürsten (Rainier III.)',
  '11-21' => 'Bosnien und Herzegowina: Friedenstag (Friedensabkommen von Dayton)',
  '11-22' => 'Libanon: Erlangung der Unabhängigkeit 1943',
  '11-25' => 'Bosnien und Herzegowina: Beitritt zum Staat Jugoslawien 1945, Surinam: Erlangung der Unabhängigkeit 1975',
  '11-28' => 'Albanien: Erklärung der Unabhängigkeit 1912, Mauretanien: Erlangung der Unabhängigkeit 1960, Timor-Leste (Ost-Timor): Nationalfeiertag',
  '11-29' => 'Albanien: Nationalfeiertag',
  '11-30' => 'Barbados: Erlangung der Unabhängigkeit 1966, Jemen: Ende der britischen Kolonialherrschaft im Süd-Jemen 1967',
  '12-1' => 'Rumänien: Nationalfeiertag, Zentralafrikanische Republik: Jahrestag der Staatsgründung 1958',
  '12-2' => 'Laos: Proklamation der Demokratischen Volksrepublik Laos 1975, Vereinigte Arabische Emirate: Jahrestag der Staatsgründung 1971',
  '12-5' => 'Thailand: Geburtstag des regierenden Königs',
  '12-6' => 'Finnland: Erklärung der Unabhängigkeit 1917',
  '12-11' => 'Burkina Faso: Erlangung der Unabhängigkeit',
  '12-12' => 'Kenia: Erlangung der Unabhängigkeit',
  '12-13' => 'Malta: Republic Day (Malteser wird Staatsoberhaupt 1974), Saint Lucia: St. Lucia Day (vermuteter Jahrestag der Entdeckung)',
  '12-16' => 'Bahrain: Nationalfeiertag, Kasachstan: Erklärung der Unabhängigkeit 1991',
  '12-17' => 'Bangladesch: Erlangung der Unabhängigkeit, Bhutan: Krönung des ersten Königs 1907',
  '12-18' => 'Niger: Ausrufung der Republik',
  '12-23' => 'Japan: Geburtstag des regierenden Kaisers Akihito',
               );
our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.

Add your comment here:

Reading not allowed: user, ip, or network is blocked.

Login

Error

%s calls

Cannot create %s

Include normal pages

Invalid UserName %s: not saved.

UserName must be 50 characters or less: not saved

This page contains an uploaded file:

No summary was provided for this file.

Recursive include of %s!

Clear Cache

Main lock obtained.

Main lock released.

Journal

More...

Comments on this page

XML::RSS is not available on this system.

diff

history

%s returned no data, or LWP::UserAgent is not available.

RSS parsing failed for %s

No items found in %s.

 . . . . 

Click to edit this page

CGI Internal error: %s

Invalid action parameter %s

Page name is missing

Page name is too long: %s

Invalid Page %s (must not end with .db)

Invalid Page %s (must not end with .lck)

Invalid Page %s

Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.

Updates since %s

up to %s

Updates in the last %s days

Updates in the last day

for %s only

List latest change per page only

List all changes

Skip rollbacks

Include rollbacks

List only major changes

Include minor changes

%s days

%s day

List later changes

RSS

RSS with pages

RSS with pages and diff

Filters

Title:

Title and Body:

Username:

Host:

Follow up to:

Language:

Go!

(minor)

rollback

new

All changes for %s

This page is too big to send over RSS.

History of %s

Compare

Deleted

Mark this page for deletion

No other revisions available

current

Revision %s

Contributors to %s

Missing target for rollback.

Target for rollback is too far back.

A username is required for ordinary users.

Rolling back changes

Editing not allowed: %s is read-only.

Rollback of %s would restore banned content.

Rollback to %s

%s rolled back

to %s

Index of all pages

Wiki Version

Password

Run maintenance

Unlock Wiki

Unlock site

Lock site

Unlock %s

Lock %s

Administration

Actions:

Important pages:

To mark a page for deletion, put <strong>%s</strong> on the first line.

from %s

redirected from %s

%s: 

[Home]

Click to search for references to this page

Cookie: 

Edit this page

Preview:

Preview only, not yet saved

Warning

Database is stored in temporary directory %s

%s seconds

Last edited

Edited

by %s

(diff)

a

c

Edit revision %s of this page

e

This page is read-only

View other revisions

View current revision

View all changes

View contributors

Homepage URL:

s

Save

p

Preview

Search:

f

Replace:

Delete

Filter:

Validate HTML

Validate CSS

Last edit

Summary:

Difference between revision %1 and %2

revision %s

current revision

Last major edit (%s)

later minor edits

No diff available.

Old revision:

Changed:

Deleted:

Added:

to

Revision %s not available

showing current revision instead

Showing revision %s

Cannot save a nameless page.

Cannot save a page without revision.

not deleted: 

deleted

Cannot open %s

Cannot write %s

unlock the wiki

Could not get %s lock

The lock was created %s.

Maybe the user running this script is no longer allowed to remove the lock directory?

This operation may take several seconds...

Forced unlock of %s lock.

No unlock required.

%s hours ago

1 hour ago

%s minutes ago

1 minute ago

%s seconds ago

1 second ago

just now

Only administrators can upload files.

Editing revision %s of

Editing %s

Editing old revision %s.

Saving this page will replace the latest revision with this text.

This change is a minor edit.

Cancel

Replace this file with text

Replace this text with a file

File to upload: 

Files of type %s are not allowed.

Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.

This site does not use admin or editor passwords.

You are currently an administrator on this site.

You are currently an editor on this site.

You are a normal user on this site.

You do not have a password set.

Your password does not match any of the administrator or editor passwords.

Password:

Return to 

This operation is restricted to site editors only...

This operation is restricted to administrators only...

Edit Denied

Editing not allowed: user, ip, or network is blocked.

Contact the wiki administrator for more information.

The rule %s matched for you.

See %s for more information.

SampleUndefinedPage

Sample_Undefined_Page

Rule "%1" matched "%2" on this page.

Reason: %s.

Reason unknown.

(for %s)

%s pages found.

Malformed regular expression in %s

Replaced: %s

Search for: %s

View changes for these pages

last updated

by

Transfer Error: %s

Browser reports no file info.

Browser reports no file type.

The page contains banned text.

No changes to be saved.

This page was changed by somebody else %s.

The changes conflict.  Please check the page again.

Please check whether you overwrote those changes.

Anonymous

Cannot delete the index file %s.

Please check the directory permissions.

Your changes were not saved.

Could not get a lock to merge!

you

ancestor

other

Run Maintenance

Maintenance not done.

(Maintenance can only be done once every 12 hours.)

Remove the "maintain" file or wait.

Expiring keep files and deleting pages marked for deletion

Moving part of the %s log file.

Could not open %s log file

Error was

Note: This error is normal if no changes have been made.

Moving %s log entries.

Set or Remove global edit lock

Edit lock created.

Edit lock removed.

Set or Remove page edit lock

Lock for %s created.

Lock for %s removed.

Displaying Wiki Version

Debugging Information

Too many connections by %s

Please do not fetch more than %1 pages in %2 seconds.

Check whether the web server can create the directory %s and whether it can create files in it.

, see 

The two revisions are the same.

Deleting %s

Deleted %s

Renaming %1 to %2.

The page %s does not exist

The page %s already exists

Cannot rename %1 to %2

Renamed to %s

Renamed from %s

Renamed %1 to %2.

Immediately delete %s

Rename %s to:

Attach file:

Upload

Learn more...

Complete Content

The main page is %s.

Archive:

Rebuild BackLink database

Internal Page: 

Pages that link to this page

The search parameter is missing.

Pages link to %s

Ban contributors

Ban Contributors to %s

Ban!

Regular expression:

%s is banned

These URLs were rolled back. Perhaps you want to add a regular expression to %s?

Consider banning the IP number as well: 

Regular expression "%1" matched "%2" on this page.

Regular expression "%s" matched on this page.

Recent Visitors

some action

was here

and read

Illegal year value: Use 0001-9999

The match parameter is missing.

Page Collection for %s

Previous

Next

Calendar %s

Su

Mo

Tu

We

Th

Fr

Sa

January

February

March

April

May

June

July

August

September

October

November

December

set %s

unset %s

Clustermap

Pages without a Cluster

Comments:

Comments on 

Comment on 

Compilation for %s

Compilation tag is missing a regular expression.

Install CSS

Copy one of the following stylesheets to %s:

Reset

Extract all dates from the database

Dates

No dates found.

List spammed pages

Despamming pages

Spammed pages

Cannot find revision %s.

Revert to revision %1: %2

Marked as %s.

Cannot find unspammed revision.

Page diff

Diff

Recover Draft

No text to save

Draft saved

Draft recovered

No draft available to recover

Save Draft

Draft Cleanup

Unable to delete draft %s

%1 was last modified %2 and was kept

%1 was last modified %2 and was deleted

Add Comment

ordinary changes

Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

Matching page names:

Fix character encoding

Fix HTML escapes

Set $FormTimeoutSalt.

Form Timeout

GD or Image::Magick modules not available.

GD::SecurityImage module not available.

Image storing failed. (%s)

Bad gd_security_image_id.

Please type the six characters from the anti-spam image

Submit

CAPTCHA

You did not answer correctly.

$GdSecurityImageFont is not set.

No summary provided

no summary available

page was marked for deletion

Oddmuse

Cleaning up git repository

Google +1 Buttons

All Pages +1

This page lists the twenty last diary entries and their +1 buttons.

Email: 

Could not find %1.html template in %2

Only Editors are allowed to see this hidden page.

Only Admins are allowed to see this hidden page.

Index

The username %s already exists.

The email address %s has already been used.

Wait %s minutes before try again.

Registration Confirmation

Visit the link blow to confirm registration.

Recover Account

You can login by following the link below. Then set new password.

Change Email Address

To confirm changing email address, follow the link below.

To submit this form you must answer this question:

Question:

CAPTCHA:

Registration

The username must be valid page name.

Confirmation email will be sent to the email address.

Repeat Password:

Email:

Bad email address format.

Password needs to have at least %s characters.

Passwords differ.

Email Sent

Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.

Failed to Confirm Registration

Invalid key.

The key expired.

Registration Confirmed

Now, you can login by using username and password.

Forgot your password?

Login failed.

You are banned.

You must confirm email address.

Logged in

%s has logged in.

You should set new password immediately.

Change Password

Logged out

%s has logged out.

Account Settings

Logout

Current Password:

New Password:

Repeat New Password:

Password is wrong.

Password Changed

Your password has been changed.

Forgot Password

Enter email address, and recovery login ticket will be sent.

Not found.

The mail address is not valid anymore.

An email has been sent to %s with further instructions.

New Email Address:

Failed to load account.

An email has been sent to %s with a login ticket.

Confirmation Failed

Failed to confirm.

Email Address Changed

Email address for %1 has been changed to %2.

Account Management

Ban Account

Enter username of the account to ban:

Ban

Enter username of the account to unban:

Unban

%s is already banned.

%s has been banned.

%s is not banned.

%s has been unbanned.

Register

Languages:

Show!

====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define

Full Link List

Banned Content

Rule "%1" matched on this page.

List of locked pages

Pages tagged with %s

Template without parameters

The template %s is either empty or does not exist.

Name: 

URL: 

Define Local Names

Define external redirect: 

 -- defined on %s

Local names defined on %1: %2

IP number matched %s

Register for %s

Please choose a username of the form "FirstLast" using your real name.

The passwords do not match.

The password must be at least %s characters.

That email address is invalid.

The username %s has already been registered.

Your registration for %s has been submitted.

Please allow time for the webmaster to approve your request.

An email has been sent to "%s" with further instructions.

There was an error saving your registration.

An account was created for %s.

Login to %s

Username and/or password are incorrect.

Logged in as %s.

Logout of %s

Logout of %s?

Logged out of %s

You are now logged out.

Register a new account

Who am I?

Change your password

Approve pending registrations

Confirm Registration for %s

%s, your registration has been approved. You can now use your password to login and edit this wiki.

Confirmation failed.  Please email %s for help.

Who Am I?

You are logged in as %s.

You are not logged in.

Reset Password

The password for %s was reset.  It has been emailed to the address on file.

There was an error resetting the password for %s.

The username "%s" does not exist.

Reset Password for %s

Reset Password?

Change Password for %s

Change Password?

Your current password is incorrect.

Approve Pending Registrations for %s

%s has been approved.

There was an error approving %s.

There are no pending registrations.

Invalid Mail %s: not saved.

unsubscribe

subscribe

%s appears to be an invalid mail address

Your mail subscriptions

All mail subscriptions

Subscriptions

Show

Subscriptions for %s:

Unsubscribe

There are no subscriptions for %s.

Change email address

Mail addresses are linked to unsubscription links.

Subscribe to %s.

Subscribe

Subscribed %s to the following pages:

The remaining pages do not exist.

Unsubscribed %s from the following pages:

Migrating Subscriptions

No non-migrated email addresses found, migration not necessary.

Migrated %s rows.

Bisect modules

Module Bisect

All modules enabled now!

Go back

Test / Always enabled / Always disabled

Start

Biscecting proccess is already active.

Stop

It seems like module %s is causing your problem.

Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).

Good luck fixing your problem! ;)

Module count (only testable modules): 

Current module statuses:

Good

Bad

Enabling %s

Update modules

Module Updater

Looks good. Update modules now!

You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.

%s is not a legal name for a namespace

Namespaces

Getting page index file for %s.

Near links:

Search sites on the %s as well

Fetching results from %s:

Near pages:

Include near pages

EditNearLinks

The same page on other sites:

 (create locally)

image

download

Backlinks

Clearing Cache

Done.

Generating Link Database

The 404 handler extension requires the link data extension (links.pl).

Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

LocalMap

No page id for action localmap

Requested page %s does not exist

Local Map for %s

view

Self-ban by %s

You have banned your own IP.

Orphan List

Trail: 

None

Type

Permalink to "%s"

anchor first defined here: %s

the page %s also exists

There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.

Someone else is generating a pdf for %s.  Please wait a minute and then try again.

Download this page as PDF

Click to search for references to this permanent anchor

Include permanent anchors

Portrait

This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now

This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.

Cannot refresh index.

Publish %s

No target wiki was specified in the config file.

The target wiki was misconfigured.

Upload is limited to %s bytes

To save this page you must answer this question:

Please type the following two words:

Please answer this captcha:

Referrers

All Referrers

Page list for %s

Slideshow:%s

Index of all small pages

Static Copy

Back to %s

Editing not allowed for %s.

Edit image in the browser

Summary of your changes: 

Copy to %1 succeeded: %2.

Copy to %1 failed: %2.

Tag

Feed for this tag

Tag Cloud

 ... 

Rebuilding index not done.

(Rebuilding the index can only be done once every 12 hours.)

Rebuild tag index

list tags

tag cloud

Alternatively, use one of the following templates:

Too many instances.  Only %s allowed.

Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.

thumb

Error creating thumbnail from non existant page %s.

Can not create thumbnail for file type %s.

Can not create thumbnail for a text document

Can not create path for thumbnail - %s

Could not open %s for writing whilst trying to save image before creating thumbnail. Check write permissions.

Failed to run %1 to create thumbnail: %2

%s ran into an error

%s produced no output

Failed to parse %s.

Timezone

Pick your timezone:

Set

Contents

Create a new page for today

Add Translation

Added translation: %1 (%2)

Translate %s

Thank you for writing a translation of %s.

Please indicate what language you will be using.

Language is missing

Suggested languages:

Please indicate a page name for the translation of %s.

More help may be available here: %s.

Translated page: 

Please provide a different page name for the translation.

This page is a translation of %s. 

The translation is up to date.

The translation is outdated.

The page does not exist.

Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate

http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search

Wanted Pages

%s pages

%s, referenced from:

Web application for offline browsing

Upload of %s file

Blog

Matching pages:

New

Edit %s.

Title: 

Tags: 

END_OF_TRANSLATION
