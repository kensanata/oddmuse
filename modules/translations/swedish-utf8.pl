# UTF-8 encoded Swedish language file for use with Oddmuse
#
# Copyright (c) 2003 Erik S-O Johansson and others
# Copyright (c) 2003 Björn Lindström <bkhl@elektrubadur.se> and
#                    Zrajm C Akfohg <zrajm@klingonska.org>
# Copyright (c) 2004-06 Johan Adler <alltid@nyfiken.org>
# Copyright (c) 2004 Zrajm C Akfohg <zrajm@klingonska.org>
#
# Permission is granted to copy, distribute and/or modify this
# document under the terms of the GNU Free Documentation License,
# Version 1.2 or any later version published by the Free Software
# Foundation; with no Invariant Sections, no Front-Cover Texts, and no
# Back-Cover Texts.  A copy of the license could be found at:
# http://www.gnu.org/licenses/fdl.txt.
#
# Installation:
# =============
#
# Create a modules subdirectory in your data directory, and put the
# file in there. It will be loaded automatically.
#
use utf8;
use strict;

AddModuleDescription('swedish-utf8.pl', 'Swedish') if defined &AddModuleDescription;

our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.

Add your comment here:

Reading not allowed: user, ip, or network is blocked.
Läsning inte tillåten: användare, ip eller nätverk är blockerat.
Login

Error

%s calls

Cannot create %s
Kan inte skapa %s
Include normal pages
Med vanliga sidor
Invalid UserName %s: not saved.
Ogiltigt användarnamn %s: Ej sparad.
UserName must be 50 characters or less: not saved
Användarnamn får bestå av högst 50 tecken: Ej sparad.
This page contains an uploaded file:
Denna sida innehåller en uppladdad fil:
No summary was provided for this file.

Recursive include of %s!

Clear Cache

Main lock obtained.
Huvudlås påslaget.
Main lock released.
Huvudlås avslaget.
Journal

More...

Comments on this page
Kommenterarer till denna sida
XML::RSS is not available on this system.
XML::RSS inte tillgängligt på det här systemet.
diff
ändringar
history
historik
%s returned no data, or LWP::UserAgent is not available.
Antingen returnerade %s inget data, eller så finns inte LWP::UserAgent tillgängligt.
RSS parsing failed for %s
Misslyckades med RSS-tolkningen av %s
No items found in %s.
Ingen information funnen i %s.
 . . . . 

Click to edit this page
Klicka för att redigera den här sidan
CGI Internal error: %s
Internt CGI-fel: %s
Invalid action parameter %s
Ogiltig parameter %s
Page name is missing
Sidnamn saknas
Page name is too long: %s
Sidnamn är för långt: %s
Invalid Page %s (must not end with .db)
Ogiltig sida %s (får inte sluta med .db)
Invalid Page %s (must not end with .lck)
Ogiltig sida %s (får inte sluta med .lck)
Invalid Page %s
Ogiltig sida %s
Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
Gå vidare till %s.
Updates since %s
Ändringar sedan %s
up to %s

Updates in the last %s days
Ändringar de %s senaste dagarna
Updates in the last day
Ändringar den senaste dagen
for %s only
för endast %s
List latest change per page only
Visa bara senaste ändring för varje sida
List all changes
Visa alla ändringar
Skip rollbacks

Include rollbacks

List only major changes
Visa bara stora ändringar
Include minor changes
Visa små ändringar också
%s days
%s dagar
%s day

List later changes
Visa senare ändringar
RSS

RSS with pages

RSS with pages and diff

Filters
Sålla
Title:
Titel:
Title and Body:
Titel och innehåll:
Username:
Användare:
Host:
Värddator:
Follow up to:

Language:
Språk
Go!
Utför
(minor)
(mindre)
rollback
återställning
new
ny
All changes for %s

This page is too big to send over RSS.
Denna sida är för stor för att sändas över RSS.
History of %s
Historik för %s
Compare
Jämför
Deleted

Mark this page for deletion

No other revisions available

current

Revision %s
Version %s
Contributors to %s

Missing target for rollback.
Mål för återställning saknas.
Target for rollback is too far back.
Mål för återställning för gammalt.
A username is required for ordinary users.

Rolling back changes
Återställer
Editing not allowed: %s is read-only.
Redigering är inte tillåten: %s är skrivskyddad.
Rollback of %s would restore banned content.

Rollback to %s
Återställning till %s
%s rolled back
%s återställd
to %s

Index of all pages
Innehållsförteckning
Wiki Version
Wikiversion
Password
Lösenord
Run maintenance
Utför underhåll
Unlock Wiki
Lås upp wiki
Unlock site
Lås upp wikin
Lock site
Lås wikin
Unlock %s
Lås upp %s
Lock %s
Lås %s
Administration

Actions:
Verktyg:
Important pages:
Viktiga sidor:
To mark a page for deletion, put <strong>%s</strong> on the first line.
För att markera en sida för radering, skriv <strong>%s</strong> på första raden.
from %s
från %s
redirected from %s
omdirigerad från %s
%s: 

[Home]
[Startsida]
Click to search for references to this page
Klicka för att söka efter referenser till den här sidan
Cookie: 

Edit this page
Redigera sidan
Preview:
Förhandsgranskning:
Preview only, not yet saved
Endast förhandsgranskning, ännu inte sparad
Warning
Varning
Database is stored in temporary directory %s
Databas sparad i tillfällig katalog %s
%s seconds
%s sekunder
Last edited
Senast ändrad
Edited
Redigerad
by %s
av %s
(diff)
(ändringar)
a

c

Edit revision %s of this page
Redigera version %s av den här sidan
e
r
This page is read-only
Sidan är skrivskyddad
View other revisions
Visa andra versioner
View current revision
Visa rådande version
View all changes
Visa alla ändringar
View contributors

Homepage URL:
URL till hemsida:
s
s
Save
Spara
p
f
Preview
Förhandsgranska
Search:
Sök:
f
k
Replace:
Ersätt:
Delete

Filter:

Validate HTML
Validera HTML
Validate CSS
Validera CSS
Last edit

Summary:
Sammanfattning:
Difference between revision %1 and %2
Skillnad (från version %1 till %2)
revision %s
version %s
current revision
rådande version
Last major edit (%s)

later minor edits

No diff available.
Information om ändring är inte tillgänglig.
Old revision:
Gammal version:
Changed:
Ändrad:
Deleted:

Added:
Tillagd:
to
till
Revision %s not available
Version %s inte tillgänglig
showing current revision instead
visar rådande version istället
Showing revision %s
Det här är version %s
Cannot save a nameless page.
Kan inte spara en namnlös sida.
Cannot save a page without revision.
Kan inte spara en sida utan ändringar.
not deleted: 
ej borttagen:
deleted
borttagen
Cannot open %s
Kan inte öppna %s
Cannot write %s
Kan inte skriva %s
unlock the wiki

Could not get %s lock
Kunde inte låsa %s
The lock was created %s.
Låset skapades %s.
Maybe the user running this script is no longer allowed to remove the lock directory?

This operation may take several seconds...
Den här funktionen kan ta flera sekunder...
Forced unlock of %s lock.
Forcerad upplåsning av %s.
No unlock required.
Ingen upplåsning behövs.
%s hours ago
för %s timmar sedan
1 hour ago
för 1 timme sedan
%s minutes ago
för %s minuter sedan
1 minute ago
för 1 minut sedan
%s seconds ago
för %s sekunder sedan
1 second ago
för 1 sekund sedan
just now
just nu
Only administrators can upload files.
Endast administratörer kan ladda upp filer.
Editing revision %s of
Redigerar version %s av
Editing %s
Redigerar %s
Editing old revision %s.
Redigerar gammal version %s.
Saving this page will replace the latest revision with this text.
Att spara den här sidan kommer att ersätta den senaste versionen med den här texten.
This change is a minor edit.
Det här är en mindre ändring.
Cancel

Replace this file with text
Skriv text istället för den här filen
Replace this text with a file
Använd en fil i stället för den här texten
File to upload: 
Fil att ladda upp: 
Files of type %s are not allowed.
Filer av typen %s är inte tillåtna.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Ditt lösenord sparas i en cookie om du har cookies påslagna. Cookies kan försvinna om du ansluter från en annan dator, från ett annat konto eller med ett annat program.
This site does not use admin or editor passwords.
Den här webbplatsen använder inte administratörs- eller redaktörslösenord.
You are currently an administrator on this site.
Du är för närvarande administratör för den här webbplatsen.
You are currently an editor on this site.
Du är för närvarande redaktör för den här webbplatsen.
You are a normal user on this site.
Du är en normal användare på den här webbplatsen.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
Ditt lösenord motsvarar inget av admininistratörs- eller redaktörslösenorden.
Password:
Lösenord:
Return to 

This operation is restricted to site editors only...
Den här funktionen kan bara utföras av redaktörer...
This operation is restricted to administrators only...
Den här funktionen kan bara utföras av adminstratörer...
Edit Denied
Redigering nekas
Editing not allowed: user, ip, or network is blocked.
Redigering inte tillåten: användare, ip-adress eller nätverk är blockerat.
Contact the wiki administrator for more information.
Kontakta wiki-administratören för mer information.
The rule %s matched for you.
Regeln %s passar in på dig.
See %s for more information.
Se %s för mer information.
SampleUndefinedPage
OdefinieradExempelsida
Sample_Undefined_Page
Odefinierad_exempelsida
Rule "%1" matched "%2" on this page.
Regel "%1"  matchade "%2" på denna sida.
Reason: %s.

Reason unknown.

(for %s)
(för: %s)
%s pages found.
%s sidor.
Malformed regular expression in %s

Replaced: %s
Ersatt: %s
Search for: %s
Sök efter: %s
View changes for these pages
Se ändringar för dessa sidor
last updated
senast reviderad
by
av
Transfer Error: %s
Överföringsfel: %s
Browser reports no file info.
Webbläsare rapporterar ingen filinformation.
Browser reports no file type.
Webbläsare rapporterar ingen filtyp.
The page contains banned text.
Sidan innehåller otillåten text.
No changes to be saved.
Inga ändringar att spara.
This page was changed by somebody else %s.
Den här sidan ändrades av någon annan %s.
The changes conflict.  Please check the page again.
Ändringarna står i konflikt. Kontrollera sidan igen.
Please check whether you overwrote those changes.
Kontrollera om du skrev över de ändringarna.
Anonymous
Anonym
Cannot delete the index file %s.
Kan inte radera index-filen %s.
Please check the directory permissions.
Vänligen kontrollera biblioteksrättigheter.
Your changes were not saved.
Dina ändringar har inte sparats.
Could not get a lock to merge!
Kunde inte låsa för att slå samman!
you
du
ancestor
förfader
other
annan
Run Maintenance
Utför underhåll
Maintenance not done.
Underhåll ej slutfört.
(Maintenance can only be done once every 12 hours.)
(Underhåll kan bara utföras en gång var 12:e timme.)
Remove the "maintain" file or wait.
Ta bort "maintain"-filen eller vänta.
Expiring keep files and deleting pages marked for deletion
Avlägsnar "keep"-filer och raderar sidor märkta för radering
Moving part of the %s log file.
Flyttar del av %s-loggen.
Could not open %s log file
Kunde inte öppna %s-loggen
Error was
Felet var
Note: This error is normal if no changes have been made.
Observera: Det här felet är normalt om inga ändringar gjorts.
Moving %s log entries.
Flyttar %s loggnotering.
Set or Remove global edit lock
Slå på eller av globalt redigeringslås
Edit lock created.
Redigeringslås påslaget.
Edit lock removed.
Redigeringslås avslaget.
Set or Remove page edit lock
Slå på eller av sidredigeringslås
Lock for %s created.
Slog på redigeringslås för %s.
Lock for %s removed.
Slog av redigeringslås för för %s.
Displaying Wiki Version
Visar Wikiversion
Debugging Information

Too many connections by %s
För många anslutningar ifrån %s
Please do not fetch more than %1 pages in %2 seconds.
Vänligen hämta inte mer än %1 sidor på %2 sekunder.
Check whether the web server can create the directory %s and whether it can create files in it.
Kontrollera att webservern kan skapa biblioteket %s och att den kan skapa filer i det.
, see 

The two revisions are the same.
De två versionerna är identiska.
Deleting %s
Tar bort %s
Deleted %s
Tog bort %s
Renaming %1 to %2.
Byter namn på %1 till %2.
The page %s does not exist
Sidan %s finnes inte
The page %s already exists
Sidan %s finns redan
Cannot rename %1 to %2
Kan inte byta namn på %1 till %2
Renamed to %s
Bytt namn till %s
Renamed from %s
Bytt namn från %s
Renamed %1 to %2.
Bytt namn på %1 till %2.
Immediately delete %s
Radera %s direkt
Rename %s to:
Byt namn på %s till:
Attach file:

Upload

Learn more...
Läs mer...
Complete Content
Fullständigt innehåll
The main page is %s.
Huvudsidan är %s.
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
Senaste besökare
some action
gjorde något
was here
var här
and read
och läste
Illegal year value: Use 0001-9999

The match parameter is missing.
Parametern "match" saknas.
Page Collection for %s
Sidsamling för %s
Previous
Föregående
Next
Nästa
Calendar %s
Kalender %s
Su
Sö
Mo
Må
Tu
Ti
We
On
Th
To
Fr

Sa
Lö
January
januari
February
februari
March
mars
April
april
May
maj
June
juni
July
juli
August
augusti
September
september
October
oktober
November
november
December
december
set %s

unset %s

Clustermap
Klusterkarta
Pages without a Cluster
Sidor utan kluster
Comments:

Comments on 
Kommentarer till 
Comment on 
Kommentar till 
Compilation for %s
Sammanställning för %s
Compilation tag is missing a regular expression.
Sammanställnings-taggen saknar en "regular expression".
Install CSS
Installera CSS
Copy one of the following stylesheets to %s:
Kopiera en av följande 'stylesheets' till %s:
Reset

Extract all dates from the database

Dates

No dates found.

List spammed pages

Despamming pages
Rensar sidor från skräptexter
Spammed pages

Cannot find revision %s.
Kan inte hitta version %s.
Revert to revision %1: %2
Återställer till version %1: %2
Marked as %s.
Markerad som %s.
Cannot find unspammed revision.
Kan inte finna version utan skräptexter
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
Lägg till kommentar
ordinary changes
vanliga ändringar
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
Du svarade inte korrekt.
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
Kunde inte finna %1.html-mallen i %2
Only Editors are allowed to see this hidden page.

Only Admins are allowed to see this hidden page.

Index
Innehållsförteckning
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
Språk:
Show!
Visa!
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define
Definiera
Full Link List
Fullständing länklista
Banned Content

Rule "%1" matched on this page.

List of locked pages

Pages tagged with %s

Template without parameters
Mall utan parametrar
The template %s is either empty or does not exist.
Mallen %s är antingen tom eller saknas.
Name: 

URL: 

Define Local Names

Define external redirect: 

 -- defined on %s
 -- definierad på %s
Local names defined on %1: %2
Lokala namn definierade på %1: %2
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
Hämtar sidindexfil för %s.
Near links:
Närlänkar:
Search sites on the %s as well
Sök siter på %s också
Fetching results from %s:
Hämtar resultat från %s:
Near pages:
Nära sidor:
Include near pages
Med nära sidor
EditNearLinks
Redigera närlänkar
The same page on other sites:
Samma sida på andra siter:
 (create locally)

image
bild
download
ladda ned
Backlinks

Clearing Cache
Rensar cachen
Done.
Färdig.
Generating Link Database
Skapar länkdatabas
The 404 handler extension requires the link data extension (links.pl).
404-hanterarmodulen kräver länkdatamodulen för att fungera (links.pl).
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
Lista över övergivna sidor
Trail: 
Senast: 
None
Inga
Type
Sort
Permalink to "%s"
Permanentlänk till "%s"
anchor first defined here: %s
ankare definierades först här: %s
the page %s also exists
sidan %s finns också
There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.

Someone else is generating a pdf for %s.  Please wait a minute and then try again.

Download this page as PDF

Click to search for references to this permanent anchor
Klicka för att söka efter referenser till det här permanenta ankaret
Include permanent anchors
Med permanenta ankare
Portrait
Porträtt
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
Sidor som länkat hit
All Referrers
Alla som länkat hit
Page list for %s

Slideshow:%s

Index of all small pages

Static Copy
Statisk kopia
Back to %s
Tillbaka till %s
Editing not allowed for %s.
%s kan inte redigeras.
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
Eller använd en av följande mallar:
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
Innehåll
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
Denna sida är en översättning av %s. 
The translation is up to date.
Denna översättning är aktuell.
The translation is outdated.
Denna översättning är föråldrad
The page does not exist.
Sidan finns inte.
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
alternativ
http://www.pricescan.com/books/BookDetail.asp?isbn=%s
http://www.bokpris.com/%s
search
sök
Wanted Pages

%s pages

%s, referenced from:

Web application for offline browsing

Upload of %s file

Blog
Blogg
Matching pages:

New

Edit %s.

Title: 

Tags: 

END_OF_TRANSLATION
