# UTF-8 encoded Serbian translation file for use with Oddmuse
#
# Copyright (c) 2003  Unknown
# Copyright (c) 2003  Chusslove Illich
#
# Permission is granted to copy, distribute and/or modify this document
# under the terms of the GNU Free Documentation License, Version 1.2
# or any later version published by the Free Software Foundation;
# with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
# A copy of the license could be found at: http://www.gnu.org/licenses/fdl.txt .
#
# Installation:
# =============
#
# Create a modules subdirectory in your data directory, and put the
# file in there. It will be loaded automatically.
#
# This translation was last checked for Oddmuse version 1.195.
#
use utf8;
use strict;

AddModuleDescription('serbian-utf8.pl', 'Serbian') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Читање није дозвољено: приступ за корисника, IP број или мрежу је блокиран.
Login

Error

%s calls

Cannot create %s
Не могу да направим %s
Include normal pages

Invalid UserName %s: not saved.
Неисправно корисничко име %s: није снимљено.
UserName must be 50 characters or less: not saved
Корисничко име мора имати 50 или мање знакова: није снимљено.
This page contains an uploaded file:

No summary was provided for this file.

Recursive include of %s!

Clear Cache

Main lock obtained.
Главна брава је добављена.
Main lock released.
Главна брава је отпуштена.
Journal

More...

Comments on this page
Коментари на овој страни
XML::RSS is not available on this system.

diff

history
историјат
%s returned no data, or LWP::UserAgent is not available.

RSS parsing failed for %s

No items found in %s.

 . . . .

Click to edit this page

CGI Internal error: %s

Invalid action parameter %s
Неисправан параметар акције %s
Page name is missing

Page name is too long: %s
Име странице је предугачко: %s
Invalid Page %s (must not end with .db)
Неисправна страница %s (не сме имати наставак .db)
Invalid Page %s (must not end with .lck)
Неисправна страница %s (не сме имати наставак .lck)
Invalid Page %s
Неисправна страница %s
There are no comments, yet. Be the first to leave a comment!

Welcome!

This page does not exist, but you can %s.

create it now

Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
Настави до %s.
Updates since %s
Измене од %s
up to %s

Updates in the last %s days
Измене у последњих %s дана
Updates in the last day
Измене у последњи дан
for %s only
само за %s
List latest change per page only

List all changes

Skip rollbacks

Include rollbacks

List only major changes

Include minor changes

days

List later changes

RSS

RSS with pages

RSS with pages and diff

Filters

Title:

Title and Body:

Username:
Корисничко име:
Host:

Follow up to:

Language:

Go!
Иди!
(minor)
(ситна)
rollback
повратак
new

All changes for %s

This page is too big to send over RSS.

History of %s
Историјат за %s
Compare
Упореди
Deleted

Mark this page for deletion

No other revisions available

current

Revision %s
Верзија %s
Contributors to %s

Missing target for rollback.
Недостаје циљ за повратак.
Target for rollback is too far back.
Циљ за повратак је предалеко уназад.
A username is required for ordinary users.

Rolling back changes
Враћам измене
Editing not allowed: %s is read-only.
Уређивање није дозвољено: %s је само за читање.
Rollback of %s would restore banned content.

Rollback to %s
Повратак на %s
%s rolled back
%s је враћен
to %s

Index of all pages
Списак свих страна:
Wiki Version
Приказујем верзију Викија
Password
Лозинка
Run maintenance

Unlock Wiki
Откључавам
Unlock site

Lock site

Unlock %s

Lock %s

Administration

Actions:

Important pages:

To mark a page for deletion, put <strong>%s</strong> on the first line.

from %s
од %s
redirected from %s
преусмерено са %s
%s:

[Home]
[Кућа]
Click to search for references to this page

Edit this page
Уреди текст ове странице
Preview:
Преглед:
Preview only, not yet saved
Ово је само преглед, измена још увек није записана
Warning
Упозорење
Database is stored in temporary directory %s
База је снимљена у привремени директоријум %s
%s seconds
%s секунди
Last edited
Последње уређивање
Edited
Уређено
by %s
— %s
(diff)
(разлике)
a

c

Edit revision %s of this page
Уреди верзију %s ове странице
e

This page is read-only
Ова страница је само за читање
View other revisions
Прикажи остале верзије
View current revision
Прикажи тренутну верзију
View all changes
Прикажи све измене
View contributors

Add your comment here:

Homepage URL:

s

Save
Сачувај
p

Preview
Преглед
Search:
Пронађи:
f

Replace:
Замени:
Delete

Filter:

Last edit

revision %s
верзија %s
current revision
текућа верзија
Difference between revision %1 and %2

Last major edit (%s)

later minor edits

No diff available.
Разлика није доступна.
Summary:
Сажетак:
Old revision:

Changed:
Измењено:
Deleted:

Added:
Додато:
to
у
Revision %s not available
Верзија %s није доступна
showing current revision instead
уместо тога, користи се тренутна верзија
Showing revision %s
Приказана верзија %s
Cannot save a nameless page.
Не могу да снимим безимену страну.
Cannot save a page without revision.

not deleted:

deleted
обрисано
Cannot open %s

Cannot write %s

Could not get %s lock
Нисам могао да добавим браву %s
The lock was created %s.

Maybe the user running this script is no longer allowed to remove the lock directory?

Sometimes locks are left behind if a job crashes.

After ten minutes, you could try to unlock the wiki.

This operation may take several seconds...
Ова операција може потрајати неколико секунди...
Forced unlock of %s lock.
Форсирано откључавање браве %s.
No unlock required.
Откључавање није неопходно.
%s hours ago
пре %s часова
1 hour ago
пре 1 часа
%s minutes ago
пре %s минута
1 minute ago
пре 1 минута
%s seconds ago
пре %s секунди
1 second ago
пре 1 секунде
just now
управо сада
Only administrators can upload files.
Само администратори могу да каче датотеке.
Editing revision %s of
Уређује се верзија %s
Editing %s
Уређивање %s
Editing old revision %s.
Уређивање старе верзије %s.
Saving this page will replace the latest revision with this text.
Снимање ове странице ће преписати последњу верзију новим текстом.
This change is a minor edit.
Ово је ситна измена.
Cancel

Replace this file with text
Замени ову датотеку текстом
Replace this text with a file
Замени овај текст датотеком
File to upload:
Датотека коју треба окачити:
Files of type %s are not allowed.
Датотеке типа %s нису дозвољене.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Ваша лозинка је снимљена у колачићу, ако су укључени. Колачићи могу бити изгубљени ако се повежете са друге машине, са другог налога, или користећи други програм.
This site does not use admin or editor passwords.
Овај сајт не користи администраторске или уредничке лозинке.
You are currently an administrator on this site.
Тренутно сте администратор на овом сајту.
You are currently an editor on this site.
Тренутно сте уредник на овом сајту.
You are a normal user on this site.
Ви сте нормални корисник на овом сајту.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
Ваша лозинка се не поклапа ни са једном од аминистраторских или уредничких лозинки.
Password:
Лозинка:
Return to %s

This operation is restricted to site editors only...
Ово смеју да раде само уредници сајта...
This operation is restricted to administrators only...
Ово сме да ради само администратор...
Edit Denied

Editing not allowed: user, ip, or network is blocked.
Уређивање није дозвољено: приступ за корисника, IP број или мрежу је блокиран.
Contact the wiki administrator for more information.
Обратите се администратору за више информација.
The rule %s matched for you.

See %s for more information.
Погледајте %s за више информација.
SampleUndefinedPage
НенаписанаСтраницаЗаПример
Sample_Undefined_Page
Ненаписана_Страница_За_Пример
Rule "%1" matched "%2" on this page.

Reason: %s.

Reason unknown.

(for %s)

%s pages found.

Preview: %s

Replaced: %s
Замењено: %s
Search for: %s
Тражи: %s
View changes for these pages

last updated
последњи пут ажурирана
by
—
Transfer Error: %s
Грешка у преносу: %s
Browser reports no file info.
Прегледач не пријављује информације о датотеци.
Browser reports no file type.
Прегледач не пријављује тип датотеке.
The page contains banned text.

No changes to be saved.

This page was changed by somebody else %s.
Ову страницу је изменио неко други %s.
The changes conflict.  Please check the page again.
Измене су у сукобу. Проверите страну поново.
Please check whether you overwrote those changes.
Проверите да нисте пребрисали ове те измене.
Anonymous
Анонимони
Cannot delete the index file %s.

Please check the directory permissions.

Your changes were not saved.

Could not get a lock to merge!
Нисам могао да добавим браву за стапање!
you
ви
ancestor
предак
other
други
Run Maintenance

Maintenance not done.
Одржавање није урађено.
(Maintenance can only be done once every 12 hours.)
(Одржавање може да се уради једном сваких 13 часова.)
Remove the "maintain" file or wait.
Уклони датотеку одржавања или чекај.
Expiring keep files and deleting pages marked for deletion
Истичем датотеке чувања и бришем странице означене за брисање
Moving part of the %s log file.
Премештам део дневничке датотеке %s.
Could not open %s log file
Нисам могао да отворим дневничку датотеку %s
Error was
Грешка
Note: This error is normal if no changes have been made.
Пажња: Ова грешка је уобичајена уколико ништа нисте изменили.
Moving %s log entries.
Премештам %s дневничких ставки.
Set or Remove global edit lock
Постави или уклони глобалну браву за уређивање
Edit lock created.
Брава за уређивање је направљена.
Edit lock removed.
Брава за уређивање је уклоњена.
Set or Remove page edit lock
Постави или уклони браву за уређивање стране
Lock for %s created.
Брава за %s је направљена.
Lock for %s removed.
Брава за %s је уклоњена.
Displaying Wiki Version

Debugging Information

Too many connections by %s
Превише веза од %s
Please do not fetch more than %1 pages in %2 seconds.

Check whether the web server can create the directory %s and whether it can create files in it.

, see

The two revisions are the same.

################################################################################
# modules/admin.pl
################################################################################
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
Потпуни садржај
The main page is %s.
Главна страна је %s.
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
Скори посетиоци
some action

was here

and read

################################################################################
# modules/calendar.pl
################################################################################
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

Spammed pages

Cannot find revision %s.

Revert to revision %1: %2

Marked as %s.

Cannot find unspammed revision.

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
%s дана
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

Show!

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

################################################################################
# modules/links.pl
################################################################################
Full Link List
Потпуни списак веза
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

The template %s is either empty or does not exist.

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

Bisection proccess is already active.

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

Near links:

Search sites on the %s as well

Fetching results from %s:

Near pages:

Include near pages

EditNearLinks

The same page on other sites:

################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)

################################################################################
# modules/no-question-mark.pl
################################################################################
image

download

################################################################################
# modules/nosearch.pl
################################################################################
Backlinks

################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache

Done.

Generating Link Database

The 404 handler extension requires the link data extension (links.pl).

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

################################################################################
# modules/page-trail.pl
################################################################################
Trail:

################################################################################
# modules/page-type.pl
################################################################################
None

Type

################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"

anchor first defined here: %s
сидро је прво дефинисано овде: %s
the page %s also exists

################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor

Include permanent anchors

################################################################################
# modules/portrait-support.pl
################################################################################
Portrait

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
Референце
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Све референце
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

Back to %s

################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Уређивање није дозвољено за %s.
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

################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.

Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.

################################################################################
# modules/thumbs.pl
################################################################################
thumb

Error creating thumbnail from nonexisting page %s.

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

The translation is outdated.

The page does not exist.

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

alternate
други
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
претрага
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
