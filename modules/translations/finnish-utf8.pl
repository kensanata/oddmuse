# UTF-8 encoded Finnish translation file for use with Oddmuse
#
# Copyright (c) 2004 mixu (Mikito Takada)
#
# Permission is granted to copy, distribute and/or modify this
# document under the terms of the GNU Free Documentation License,
# Version 1.2 or any later version published by the Free Software
# Foundation; with no Invariant Sections, no Front-Cover Texts, and no
# Back-Cover Texts.  A copy of the license could be found at:
# http://www.gnu.org/licenses/fdl.txt .
#
# Installation:
# =============
#
# Create a modules subdirectory in your data directory, and put the
# file in there. It will be loaded automatically.
#
use utf8;
use strict;

AddModuleDescription('finnish-utf8.pl', 'Finnish') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Lukeminen ei ole sallittua: käyttäjä, IP tai verkko on estetty.
Login

Error

%s calls

Cannot create %s
%s:ää ei voitu luoda
Include normal pages

Invalid UserName %s: not saved.
Epäkelpo käyttäjännimi %s: ei tallennettu.
UserName must be 50 characters or less: not saved
Käyttäjännimen on oltava alle 50 merkkiä pitkä: ei tallennettu
This page contains an uploaded file:

No summary was provided for this file.

Recursive include of %s!

Clear Cache

Main lock obtained.
Sivuston lukitus aloitettu.
Main lock released.
Sivuston lukitus avattu.
Journal

More...

Comments on this page
Komentteja tähän sivuun liittyen
XML::RSS is not available on this system.
XML::RSS ei ole asennettuna tälle palvelimelle.
diff
diff
history
historia
%s returned no data, or LWP::UserAgent is not available.
%s ei palauttanut dataa, tai LWP::UserAgent -moduuli ei ole saatavilla.
RSS parsing failed for %s
RSS-parseri epäonnistui: %s
No items found in %s.
No items found in %s.
 . . . .

Click to edit this page
Klikkaa muokataksesi tätä sivua
CGI Internal error: %s

Invalid action parameter %s
Virheellinen toiminto %s
Page name is missing
Sivun nimi puuttuu
Page name is too long: %s
Sivun nimi on liian pitkä: %s
Invalid Page %s (must not end with .db)
Virheellinen sivu %s (pääte ei voi olla .db)
Invalid Page %s (must not end with .lck)
Virheellinen sivu %s (pääte ei voi olla .lck)
Invalid Page %s
Virheellinen sivu %s
There are no comments, yet. Be the first to leave a comment!

Welcome!

This page does not exist, but you can %s.

create it now

Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
Siirtykää sivulle %s, kiitos.
Updates since %s
Päivitykset %s jälkeen
up to %s

Updates in the last %s days
Päivitykset viimeisten %s päivän aikana
Updates in the last day
Päivitykset viimeisen päivän aikana
for %s only
vain %s:lle
List latest change per page only
Luettele viimeisimmät muutokset kullekin sivulle
List all changes
Luettele kaikki muutokset
Skip rollbacks

Include rollbacks

List only major changes
Luettele vain tärkeimmät muutokset
Include minor changes
Näytä pienet korjaukset
days

List later changes
Luettele myöhemmät muutokset
RSS

RSS with pages

RSS with pages and diff

Filters
Suotimet
Title:

Title and Body:

Username:
Käyttäjännimi:
Host:
Host:
Follow up to:

Language:
Kieli:
Go!
Siirry!
(minor)
(pieni korjaus)
rollback
sivun palautus
new
uusi
All changes for %s

This page is too big to send over RSS.

History of %s
%s:n historia
Compare
Vertaa
Deleted

Mark this page for deletion

No other revisions available

current

Revision %s
Versio %s
Contributors to %s

Missing target for rollback.
Palautuksen kohde puuttuu.
Target for rollback is too far back.
Palautuksen kohde on liian kaukana.
A username is required for ordinary users.

Rolling back changes
Sivua palautetaan
Editing not allowed: %s is read-only.
Muokkaus estetty: %s on lukittu muutoksilta.
Rollback of %s would restore banned content.

Rollback to %s
Palautus %s:ään
%s rolled back
%s palautettu
to %s

Index of all pages
Sivuston sisällysluettelo
Wiki Version
Wikin versio
Password
Salasana
Run maintenance
Ylläpitotoiminto
Unlock Wiki
Avataan lukitus
Unlock site
Avaa sivuston lukko
Lock site
Lukitse sivusto
Unlock %s

Lock %s

Administration

Actions:

Important pages:

To mark a page for deletion, put <strong>%s</strong> on the first line.

from %s
%s:stä
redirected from %s
uudelleenohjattu sivulta %s
%s:

[Home]
[Etusivu]
Click to search for references to this page
Klikkaa hakeaksesi viittauksia tälle sivulle
Edit this page
Muokkaa tätä sivua
Preview:
Esikatselu:
Preview only, not yet saved
Pelkkä esikatselu, sivua ei ole tallennettu vielä
Warning
Varoitus
Database is stored in temporary directory %s
Tietokanta on tallennettu väliaikaishakemistoon %s
%s seconds
%s sekuntia
Last edited
Viimeksi muokattu
Edited
Muokattu
by %s

(diff)
(diff)
a

c

Edit revision %s of this page
Muokkaa tämän sivun versiota %s
e
m
This page is read-only
Tämä sivu on lukittu muutoksilta
View other revisions
Näytä muut versiot
View current revision
Näytä nykyisin versio
View all changes
Näytä kaikki muutokset
View contributors

Add your comment here:

Homepage URL:
Kotisivun URL:
s
t
Save
Tallenna
p

Preview
Esikatselu
Search:
Haku:
f
h
Replace:
Korvaa:
Delete

Filter:

Last edit

revision %s
versio %s
current revision
nykyinen versio
Difference between revision %1 and %2
Muutokset (versioiden %1 ja %2 välillä)
Last major edit (%s)

later minor edits

No diff available.
Muutoksien vertailua ei saatavilla.
Summary:
Yhteenveto:
Old revision:
Vanha versio:
Changed:
Muokattu:
Deleted:

Added:
Lisätty:
to

Revision %s not available
Versiota %s ei ole saatavilla
showing current revision instead
näytetään nykyinen versio sen sijaan
Showing revision %s
Näytetään versio %s
Cannot save a nameless page.
Sivua ei voi tallentaa ilman nimeä.
Cannot save a page without revision.
Sivua ei voi tallentaa ilman versiota.
not deleted:
ei poistettu:
deleted
poistettu
Cannot open %s
Ei voitu avata: %s
Cannot write %s
Ei voitu kirjoittaa: %s
Could not get %s lock
Ei voitu lukita: %s
The lock was created %s.

Maybe the user running this script is no longer allowed to remove the lock directory?

Sometimes locks are left behind if a job crashes.

After ten minutes, you could try to unlock the wiki.

This operation may take several seconds...
Tämä operaatio voi kestää useita sekunteja...
Forced unlock of %s lock.
Pakotettu lukon avaus: %s.
No unlock required.
Lukon avausta ei tarvittu.
%s hours ago
%s tuntia aiemmin
1 hour ago
yhtä tuntia aiemmin
%s minutes ago
%s minuuttia aiemmin
1 minute ago
yhtä minuuttia aiemmin
%s seconds ago
%s sekuntia aiemmin
1 second ago
yhtä sekuntia aiemmin
just now
juuri nyt
Only administrators can upload files.
Vain ylläpito voi tallentaa tiedostoja.
Editing revision %s of
Muokataan versiota %s /
Editing %s
Muokataan %s:ää
Editing old revision %s.
Muokataan vanhaa versiota %s.
Saving this page will replace the latest revision with this text.
Tämän sivun tallentaminen korvaa viimeisimmän version tällä tekstillä.
This change is a minor edit.
Tämä on pieni korjaus.
Cancel

Replace this file with text
Korvaa tämä tiedosto tekstillä
Replace this text with a file
Korvaa tämä teksti tiedostolla
File to upload:
Tallennettava tiedosto:
Files of type %s are not allowed.
Tyyppiä %s olevat tiedostot eivät ole sallittuja.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Salasanasi tallennetaan keksiin (cookie), jos cookies-toiminto on päällä. Tallennettu cookie voi kadota, jos siirryt toiselle tietokoneelle, toiselle käyttäjäntunnukselle tai eri verkkoselaimelle.
This site does not use admin or editor passwords.
Tämä sivusto ei käytä ylläpidon tai toimittajien salasanoja.
You are currently an administrator on this site.
Olet tällä hetkellä kirjautunut sivuston ylläpitäjänä.
You are currently an editor on this site.
Olet tällä hetkellä sivuston toimittaja (editor).
You are a normal user on this site.
Olet tällä hetkellä tavallinen sivuston käyttäjä.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
Salasanasi ei ole yksikään ylläpidon tai toimittajien salasanoista.
Password:
Salasana:
Return to %s

This operation is restricted to site editors only...
Tämä toiminto on rajoitettu sivuston toimittajille...
This operation is restricted to administrators only...
Tämä toiminto on rajoitettu sivuston ylläpitäjille...
Edit Denied
Muokkaus estetty
Editing not allowed: user, ip, or network is blocked.
Muokkaus estetty: käyttäjä, IP tai verkko on estetty.
Contact the wiki administrator for more information.
Ota yhteyttä wikin ylläpitoon lisätiedon tarpeessa.
The rule %s matched for you.
Sääntö %s sopi sinuun.
See %s for more information.
Katso %s lisätiedon tarpeessa.
SampleUndefinedPage
EsimerkkiSivu
Sample_Undefined_Page
Esimerkki_Sivu
Rule "%1" matched "%2" on this page.
Sääntö "%1" sopi "%2":teen tällä sivulla.
Reason: %s.

Reason unknown.

(for %s)
(%s:lle)
%s pages found.
%s sivua löydetty.
Preview: %s

Replaced: %s
Korvattu: %s
Search for: %s
Etsi: %s
View changes for these pages
Näytä muutokset näille sivulle
last updated
viimeksi päivitetty
by

Transfer Error: %s
Virhe siirrossa: %s
Browser reports no file info.
Selain ei ilmoita tiedoston tietoja.
Browser reports no file type.
Selain ei ilmoita tiedoston tyyppiä.
The page contains banned text.
Tämä sivu sisältää kielettyä tekstiä.
No changes to be saved.

This page was changed by somebody else %s.
Joku muu muokkasi tätä sivua %s.
The changes conflict.  Please check the page again.
Muutokset ovat ristiriidassa. Tarkista sivu uudelleen.
Please check whether you overwrote those changes.
Tarkista, ylikirjoititko joitakin noista muutoksista.
Anonymous
Nimetön
Cannot delete the index file %s.

Please check the directory permissions.

Your changes were not saved.

Could not get a lock to merge!
Sivua ei voitu lukita sulautusta varten!
you
sinä
ancestor
edeltäjä
other
muu
Run Maintenance

Maintenance not done.
Ylläpitoa ei suoritettu.
(Maintenance can only be done once every 12 hours.)
Ylläpitotoiminto voidaan suorittaa vain kerran 12 tunnissa.)
Remove the "maintain" file or wait.
Poista "maintain" -tiedosto tai odota.
Expiring keep files and deleting pages marked for deletion
Eräännytetään keep-tiedostot ja poistetaan poistettaviksi merkityt sivut
Moving part of the %s log file.
Siirretään osa %s lokitiedostosta.
Could not open %s log file
Lokitiedostoa %s ei voitu avata
Error was
Virhe oli
Note: This error is normal if no changes have been made.
Huom: Tämä virhe on normaali, jos muutoksia ei ole tehty.
Moving %s log entries.
Siirretään %s kirjausta.
Set or Remove global edit lock
Aseta tai poista sivuston muokkauslukitus
Edit lock created.
Muokkauslukitus asetettu.
Edit lock removed.
Muokkauslukitus poistettu.
Set or Remove page edit lock
Aseta tai poista sivun muokkauslukitus
Lock for %s created.
Lukko %s:lle luotu.
Lock for %s removed.
Lukko %s:lle poistettu.
Displaying Wiki Version

Debugging Information

Too many connections by %s
Liian monta yhteydenottoa %s:stä
Please do not fetch more than %1 pages in %2 seconds.
älä avaa yli %1 sivua %2 sekunnin aikana.
Check whether the web server can create the directory %s and whether it can create files in it.
Tarkista voiko www-palvelin luoda hakemiston %s ja voiko se luoda sivuja tähän hakemistoon.
, see

The two revisions are the same.

################################################################################
# modules/admin.pl
################################################################################
Deleting %s
Poistetaan %s
Deleted %s
Poistettu %s
Renaming %1 to %2.
Uudelleennimetään %1:stä %2:ksi
The page %s does not exist
Sivu %s ei ole olemassa
The page %s already exists
Sivu %s on jo olemassa
Cannot rename %1 to %2

Renamed to %s
Nimi vaihdettu %:ksi
Renamed from %s
Nimi muutettu %s:stä
Renamed %1 to %2.
Nimi vaihdettu %1:stä %2:ksi
Immediately delete %s

Rename %s to:

################################################################################
# modules/advanced-uploads.pl
################################################################################
Attach file:

Upload

################################################################################
# modules/aggregate.pl
################################################################################
Learn more...

################################################################################
# modules/all.pl
################################################################################
Complete Content
Sisältö
The main page is %s.
Etusivu on %s.
################################################################################
# modules/archive.pl
################################################################################
Archive:

################################################################################
# modules/backlinkage.pl
################################################################################
Rebuild BackLink database

Internal Page: %s

Pages that link to this page

################################################################################
# modules/backlinks.pl
################################################################################
The search parameter is missing.

Pages link to %s

################################################################################
# modules/ban-contributors.pl
################################################################################
Ban contributors

Ban Contributors to %s

Ban!

Regular expression:

%s is banned

These URLs were rolled back. Perhaps you want to add a regular expression to %s?

Consider banning the IP number as well:

################################################################################
# modules/banned-regexps.pl
################################################################################
Regular expression "%1" matched "%2" on this page.

Regular expression "%s" matched on this page.

################################################################################
# modules/big-brother.pl
################################################################################
Recent Visitors
Viimeisimmät vierailijat
some action

was here

and read

################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999

The match parameter is missing.
Hakuparametri puuttuu.
Page Collection for %s
Sivukokoelma %s
Previous
Edellinen
Next
Seuraava
Calendar %s
Kalenteri %s
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

################################################################################
# modules/checkbox.pl
################################################################################
set %s

unset %s

################################################################################
# modules/clustermap.pl
################################################################################
Clustermap

Pages without a Cluster

################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:

################################################################################
# modules/commentcount.pl
################################################################################
Comments on

Comment on

################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s

Compilation tag is missing a regular expression.

################################################################################
# modules/css-install.pl
################################################################################
Install CSS

Copy one of the following stylesheets to %s:

Reset

################################################################################
# modules/dates.pl
################################################################################
Extract all dates from the database

Dates

No dates found.

################################################################################
# modules/despam.pl
################################################################################
List spammed pages

Despamming pages
Sivuja puhdistetaan spam:ista
Spammed pages

Cannot find revision %s.
Versiota ei löydy %s.
Revert to revision %1: %2
Palauta versioon %1: %2
Marked as %s.
Merkitty nimellä %s.
Cannot find unspammed revision.
Spam-vapaata versiota ei löydy.
################################################################################
# modules/diff.pl
################################################################################
Page diff

Diff

################################################################################
# modules/drafts.pl
################################################################################
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

################################################################################
# modules/dynamic-comments.pl
################################################################################
Add Comment

################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes

%s days
%s päivää
################################################################################
# modules/edit-paragraphs.pl
################################################################################
Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

################################################################################
# modules/find.pl
################################################################################
Matching page names:

################################################################################
# modules/fix-encoding.pl
################################################################################
Fix character encoding

Fix HTML escapes

################################################################################
# modules/form_timeout.pl
################################################################################
Set $FormTimeoutSalt.

Form Timeout

################################################################################
# modules/gd_security_image.pl
################################################################################
GD or Image::Magick modules not available.

GD::SecurityImage module not available.

Image storing failed. (%s)

Bad gd_security_image_id.

Please type the six characters from the anti-spam image

Submit

CAPTCHA

You did not answer correctly.

$GdSecurityImageFont is not set.

################################################################################
# modules/git-another.pl
################################################################################
No summary provided

################################################################################
# modules/git.pl
################################################################################
no summary available

page was marked for deletion

Oddmuse

Cleaning up git repository

################################################################################
# modules/google-plus-one.pl
################################################################################
Google +1 Buttons

All Pages +1

This page lists the twenty last diary entries and their +1 buttons.

################################################################################
# modules/gravatar.pl
################################################################################
Email:

################################################################################
# modules/header-and-footer-templates.pl
################################################################################
Could not find %1.html template in %2

################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.

Only Admins are allowed to see this hidden page.

################################################################################
# modules/index.pl
################################################################################
Index
Sisällysluettelo
################################################################################
# modules/joiner.pl
################################################################################
The username %s already exists.

The email address %s has already been used.

Wait %s minutes before try again.

Registration Confirmation

Visit the link below to confirm registration.

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

################################################################################
# modules/lang.pl
################################################################################
Languages:
Kielet:
Show!
Näytä
################################################################################
# modules/like.pl
################################################################################
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

################################################################################
# modules/link-all.pl
################################################################################
Define
Määritä
################################################################################
# modules/links.pl
################################################################################
Full Link List
Täysi linkkilista
################################################################################
# modules/list-banned-content.pl
################################################################################
Banned Content

Rule "%1" matched on this page.

################################################################################
# modules/listlocked.pl
################################################################################
List of locked pages

################################################################################
# modules/listtags.pl
################################################################################
Pages tagged with %s

################################################################################
# modules/live-templates.pl
################################################################################
Template without parameters
Pohja ilman parametrejä
The template %s is either empty or does not exist.
Pohja %s on joko tyhjä tai ei ole olemassa.
################################################################################
# modules/localnames.pl
################################################################################
Name:

URL:

Define Local Names

Define external redirect:

 -- defined on %s

Local names defined on %1: %2

################################################################################
# modules/logbannedcontent.pl
################################################################################
IP number matched %s

################################################################################
# modules/login.pl
################################################################################
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

################################################################################
# modules/mail.pl
################################################################################
Invalid Mail %s: not saved.

unsubscribe

subscribe

%s appears to be an invalid mail address

Your mail subscriptions

All mail subscriptions

Subscriptions

Email: 

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

################################################################################
# modules/module-bisect.pl
################################################################################
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

################################################################################
# modules/module-updater.pl
################################################################################
Update modules

Module Updater

Looks good. Update modules now!

################################################################################
# modules/multi-url-spam-block.pl
################################################################################
You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.

################################################################################
# modules/namespaces.pl
################################################################################
%s is not a legal name for a namespace

Namespaces

################################################################################
# modules/near-links.pl
################################################################################
Getting page index file for %s.
Haetaan sivun indeksitiedosto %s.
Near links:
Lähilinkit:
Search sites on the %s as well
Etsi myös sivustoilla %s
Fetching results from %s:
Haetaan tulokset %s:stä :
Near pages:
Lähisivut:
Include near pages

EditNearLinks
MuokkaaLähiLinkkejä
The same page on other sites:
Sama sivu muilla sivustoilla:
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)

################################################################################
# modules/no-question-mark.pl
################################################################################
image
kuva
download
download
################################################################################
# modules/nosearch.pl
################################################################################
Backlinks

################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache
Välimuistia tyhjennetään
Done.

Generating Link Database
Linkkitietokantaa luodaan
The 404 handler extension requires the link data extension (links.pl).
404-käsittelijä-laajennus vaatii "link data" -laajennuksen (links.pl).
################################################################################
# modules/offline.pl
################################################################################
Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

################################################################################
# modules/olocalmap.pl
################################################################################
LocalMap

No page id for action localmap

Requested page %s does not exist

Local Map for %s

view

################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s

You have banned your own IP.

################################################################################
# modules/orphans.pl
################################################################################
Orphan List
Orpojen sivujen lista
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
Historia:
################################################################################
# modules/page-type.pl
################################################################################
None
Ei yhtään
Type
Tyyppi
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"
Pysyvä linkki "%s":ään
anchor first defined here: %s
ankkuri nimetty ensimmäisen kerran täällä: %s
the page %s also exists
tämä sivu %s on myös olemassa
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Klikkaa etsiäksesi viittauksia tähän pysyvään ankkuriin
Include permanent anchors

################################################################################
# modules/portrait-support.pl
################################################################################
Portrait
Avatar
################################################################################
# modules/preview.pl
################################################################################
Pages with changed HTML

Preview changes in HTML output

################################################################################
# modules/private-pages.pl
################################################################################
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now

################################################################################
# modules/private-wiki.pl
################################################################################
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.

Cannot refresh index.

################################################################################
# modules/publish.pl
################################################################################
Publish %s

No target wiki was specified in the config file.

The target wiki was misconfigured.

################################################################################
# modules/put.pl
################################################################################
Upload is limited to %s bytes

################################################################################
# modules/questionasker.pl
################################################################################
To save this page you must answer this question:

################################################################################
# modules/recaptcha.pl
################################################################################
Please type the following two words:

Please answer this captcha:

################################################################################
# modules/referrer-rss.pl
################################################################################
Referrers
Viittaukset
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Kaikki viittaukset
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s

################################################################################
# modules/small.pl
################################################################################
Index of all small pages

################################################################################
# modules/static-copy.pl
################################################################################
Static Copy
Staattinen kopio
Back to %s
Takaisin %s:ään
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Muokkaus ei ole sallittu: %s.
################################################################################
# modules/svg-edit.pl
################################################################################
Edit image in the browser

Summary of your changes:

################################################################################
# modules/sync.pl
################################################################################
Copy to %1 succeeded: %2.

Copy to %1 failed: %2.

################################################################################
# modules/tags.pl
################################################################################
Tag

Feed for this tag

Tag Cloud

Rebuilding index not done.

(Rebuilding the index can only be done once every 12 hours.)

Rebuild tag index

list tags

tag cloud

################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Vaihtoehtoisesti, käytä yhtä seuraavista pohjista:
################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.

Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.

################################################################################
# modules/thumbs.pl
################################################################################
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

################################################################################
# modules/timezone.pl
################################################################################
Timezone

Pick your timezone:

Set

################################################################################
# modules/toc-headers.pl
################################################################################
Contents
Sisältö
################################################################################
# modules/today.pl
################################################################################
Create a new page for today

################################################################################
# modules/translation-links.pl
################################################################################
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

################################################################################
# modules/translations.pl
################################################################################
This page is a translation of %s.

The translation is up to date.
Käännös on ajantasainen.
The translation is outdated.
Käännös on vanhentunut.
The page does not exist.
Sivu ei ole olemassa.
################################################################################
# modules/upgrade.pl
################################################################################
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

################################################################################
# modules/usemod.pl
################################################################################
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s
http://www.amazon.com/exec/obidos/ISBN=%s
alternate
vaihtoehto
http://www.pricescan.com/books/BookDetail.asp?isbn=%s
http://www.pricescan.com/books/BookDetail.asp?isbn=%s
search
haku
################################################################################
# modules/wanted.pl
################################################################################
Wanted Pages

%s pages

%s, referenced from:

################################################################################
# modules/webapp.pl
################################################################################
Web application for offline browsing

################################################################################
# modules/webdav.pl
################################################################################
Upload of %s file

################################################################################
# modules/weblog-1.pl
################################################################################
Blog
Blog
################################################################################
# modules/weblog-3.pl
################################################################################
Matching pages:

New

Edit %s.

################################################################################
# modules/weblog-4.pl
################################################################################
Tags:

END_OF_TRANSLATION
