# UTF-8 encoded Japanese translation file for use with Oddmuse
#
# Copyright (c) 2014  Aki Goto <tyatsumi@gmail.com>
# 
# Permission is granted to copy, distribute and/or modify this document
# under the terms of the GNU Free Documentation License, Version 1.3
# or any later version published by the Free Software Foundation;
# with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
# A copy of the license could be found at:
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

AddModuleDescription('japanese-utf8.pl', 'Japanese') if defined &AddModuleDescription;

our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.
このページは空です。
Add your comment here:
ここにコメントを追加してください。
Reading not allowed: user, ip, or network is blocked.
閲覧は許可されません: ユーザ、IP、またはネットワークがブロックされています。
Login
ログイン
Error
エラー
%s calls
%s回呼び出し
Cannot create %s
%s を作れません
Include normal pages
通常ページを含める
Invalid UserName %s: not saved.
不正なユーザ名 %s: 保存されませんでした。
UserName must be 50 characters or less: not saved
ユーザ名は50文字以下でなければなりません: 保存されませんでした
This page contains an uploaded file:
このページはアップロードされたファイルを含んでいます:
No summary was provided for this file.

Recursive include of %s!
%s の再帰的取り込み！
Clear Cache
キャッシュを消去
Main lock obtained.
メインロックを取得しました。
Main lock released.
メインロックを開放しました。
Journal
ジャーナル
More...
もっと...
Comments on this page
このページのコメント
XML::RSS is not available on this system.
このシステムではXML::RSSは利用できません。
diff
差分
history
履歴
%s returned no data, or LWP::UserAgent is not available.
%s がデータを返さなかったか、LWP::UserAgentが利用できません。
RSS parsing failed for %s
%s のRSS解析に失敗しました
No items found in %s.
%s に項目がありません。
 . . . . 
 . . . . 
Click to edit this page
このページを編集するにはクリックしてください
CGI Internal error: %s
CGI内部エラー: %s
Invalid action parameter %s
不正なアクションパラメタ %s
Page name is missing
ページ名がありません
Page name is too long: %s
ページ名が長すぎます: %s
Invalid Page %s (must not end with .db)
不正なページ %s (.db で終わってはいけない)
Invalid Page %s (must not end with .lck)
不正なページ %s (.lck で終わってはいけない)
Invalid Page %s
不正なページ %s
Too many redirections
リダイレクトが多すぎます
No redirection for old revisions
古いリビジョンはリダイレクトしません
Invalid link pattern for #REDIRECT
#REDIRECT への不正なリンク形式
Please go on to %s.

Updates since %s
%sからの更新
up to %s
%sまで
Updates in the last %s days
過去%s日間の更新
Updates in the last day
過去日間の更新
for %s only

List latest change per page only
ページあたりの最新の変更のみを一覧
List all changes
すべての変更を一覧
Skip rollbacks
ロールバックを飛ばす
Include rollbacks
ロールバックを含める
List only major changes
メジャーな変更のみ一覧
Include minor changes
マイナーな変更を含める
%s days
%s日間
%s day

List later changes
最近の変更を一覧
RSS
RSS
RSS with pages
ページ付きRSS
RSS with pages and diff
ページと差分付きRSS
Filters
フィルタ
Title:
タイトル:
Title and Body:
タイトルと本文:
Username:
ユーザ名:
Host:
ホスト:
Follow up to:

Language:
言語:
Go!
実行！
(minor)
(マイナー)
rollback
ロールバック
new
new
All changes for %s
%s へのすべての変更
This page is too big to send over RSS.
このページはRSSで送るには大きすぎます。
History of %s
%s の履歴
Compare
比較
Deleted
削除指定
Mark this page for deletion
このページを削除指定する
No other revisions available
他のリビジョンはありません
current
現在
Revision %s
リビジョン %s
Contributors to %s
%s への投稿者
Missing target for rollback.
ロールバックする対象がありません。
Target for rollback is too far back.
ロールバックする対象が古すぎます。
A username is required for ordinary users.
通常ユーザにはユーザ名が必要です。
Rolling back changes
変更をロールバック
Editing not allowed: %s is read-only.
編集は許可されません: %s は閲覧のみです。
Rollback of %s would restore banned content.
%s のロールバックは禁止された内容を復活させることになります。
Rollback to %s
%s にロールバックする
%s rolled back
%s はロールバックされました
to %s
%s に
Index of all pages
すべてのページの目録
Wiki Version
ウィキバージョン
Password
パスワード
Run maintenance
保守作業を実行
Unlock Wiki
ウィキのロックを解除
Unlock site
サイトのロックを解除
Lock site
サイトをロック
Unlock %s
%s のロックを解除
Lock %s
%s をロック
Administration
管理
Actions:
アクション:
Important pages:
重要なページ:
To mark a page for deletion, put <strong>%s</strong> on the first line.
ページを削除指定するには、最初の行に <strong>%s</strong> と記してください。
from %s
%s より
redirected from %s
%s からリダイレクト
%s: 
%s: 
[Home]
[ホーム]
Click to search for references to this page
クリックするとこのページへの参照を検索する
Cookie: 
クッキー: 
Edit this page
このページを編集
Preview:
プレビュー:
Preview only, not yet saved
プレビューにすぎません、まだ保存されていません
Warning
警告
Database is stored in temporary directory %s
データベースが一時ディレクトリ %s に保存されています
%s seconds
%s秒
Last edited
最終編集
Edited
編集
by %s
%s による
(diff)
(差分)
a
a
c
c
Edit revision %s of this page
このページのリビジョン %s を編集
e
e
This page is read-only
このページは閲覧のみ
View other revisions
他のリビジョンを見る
View current revision
現在のリビジョンを見る
View all changes
すべての変更を見る
View contributors
投稿者を見る
Homepage URL:
ホームページURL:
s
s
Save
保存
p
p
Preview
プレビュー
Search:
検索:
f
f
Replace:
置換:
Delete
削除
Filter:
フィルタ:
Validate HTML
HTMLを確認
Validate CSS
CSSを確認
Last edit
最終編集
Summary:
要約:
Difference between revision %1 and %2
リビジョン %1 と %2 の違い
revision %s
リビジョン %s
current revision
現在のリビジョン
Last major edit (%s)
最終のメジャーな編集 (%s)
later minor edits
その後のマイナーな編集
No diff available.
差分はありません。
Old revision:
古いリビジョン:
Changed:
変更:
Deleted:
削除:
Added:
追加:
to

Revision %s not available
リビジョン %s はありません
showing current revision instead
代わりに現在のリビジョンを表示しています
Showing revision %s
リビジョン %s を表示しています
Cannot save a nameless page.
名前のないページは保存できません。
Cannot save a page without revision.
リビジョンのないページは保存できません。
not deleted: 
削除されませんでした: 
deleted
削除されました
Cannot open %s
%s を開けません
Cannot write %s
%s を書き込めません
unlock the wiki

Could not get %s lock
%s ロックを取得できません
The lock was created %s.
ロックは %s に作られました。
Maybe the user running this script is no longer allowed to remove the lock directory?
このスクリプトを実行しているユーザはもはやロックディレクトリを除去することが許可されていないかもしれません？
This operation may take several seconds...
この処理は何秒かかかります...
Forced unlock of %s lock.
%s ロックを強制的に解除しました。
No unlock required.
ロック解除は必要ありません。
%s hours ago
%s 時間前
1 hour ago
1 時間前
%s minutes ago
%s 分前
1 minute ago
1 分前
%s seconds ago
%s 秒前
1 second ago
1 秒前
just now
たった今
Only administrators can upload files.
管理者だけがファイルをアップロードできます。
Editing revision %s of
編集中: リビジョン %s の
Editing %s
%s を編集中
Editing old revision %s.
古いリビジョン %s を編集中。
Saving this page will replace the latest revision with this text.
このページを保存すると最新のリビジョンをこのテキストに入れ替えます。
This change is a minor edit.
この変更はマイナーな編集です。
Cancel
中止
Replace this file with text
このファイルをテキストと入れ替える
Replace this text with a file
このテキストをファイルと入れ替える
File to upload: 
アップロードするファイル: 
Files of type %s are not allowed.
形式 %s のファイルは許可されません。
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
クッキーを有効にしていれば、パスワードはクッキーに保存されます。別のマシンから接続したり、別アカウントで接続したり、別のソフトウェアを使って接続すると、クッキーは失われることがあります。
This site does not use admin or editor passwords.
このサイトは管理者パスワードも編集者パスワードも使っていません。
You are currently an administrator on this site.
あなたは現在このサイトの管理者です。
You are currently an editor on this site.
あなたは現在このサイトの編集者です。
You are a normal user on this site.
あなたはこのサイトの通常ユーザです。
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
あなたのパスワードは管理者パスワードにも編集者パスワードにも一致しません。
Password:
パスワード:
Return to 

This operation is restricted to site editors only...
この操作はサイト編集者のみに制限されています...
This operation is restricted to administrators only...
この操作は管理者のみに制限されています...
Edit Denied
編集拒否
Editing not allowed: user, ip, or network is blocked.
編集は許可されません: ユーザ、IP、またはネットワークがブロックされています。
Contact the wiki administrator for more information.
詳しくはウィキ管理者に問い合わせてください。
The rule %s matched for you.
規則 %s があなたに当てはまりました。
See %s for more information.
詳しくは %s を見てください。
SampleUndefinedPage

Sample_Undefined_Page

Rule "%1" matched "%2" on this page.
規則 "%1" がこのページの "%2" に当てはまりました。
Reason: %s.
理由: %s。
Reason unknown.
理由は不明です。
(for %s)
(%s に対して)
%s pages found.
%s ページ見付かりました。
Malformed regular expression in %s
%s に不正な正規表現があります
Replaced: %s
%s に入れ替えられました
Search for: %s
%s についての検索
View changes for these pages
これらのページの変更を見る
last updated
最終更新
by
投稿者
Transfer Error: %s
転送エラー: %s
Browser reports no file info.
ブラウザがファイル情報を報告しません。
Browser reports no file type.
ブラウザがファイル形式を報告しません。
The page contains banned text.
ページが禁止されたテキストを含んでいます。
No changes to be saved.
保存すべき変更がありません。
This page was changed by somebody else %s.
このページは %s 別な誰かによって変更されました。
The changes conflict.  Please check the page again.
変更が衝突します。ページをもう一度確認してください。
Please check whether you overwrote those changes.
これらの変更を上書きするかどうか確認してください。
Anonymous
匿名
Cannot delete the index file %s.
目録ファイル %s を削除できません。
Please check the directory permissions.
ディレクトリ許可属性を確認してください。
Your changes were not saved.
変更は保存されませんでした。
Could not get a lock to merge!
統合のためのロックを取得できませんでした！
you
あなた
ancestor
先祖
other
他者
Run Maintenance
保守作業の実行
Maintenance not done.
保守作業は行なわれません。
(Maintenance can only be done once every 12 hours.)
(保守作業は12時間に一度だけ行なわれます。)
Remove the "maintain" file or wait.
"maintain" ファイルを削除するか、待ってください。
Expiring keep files and deleting pages marked for deletion
期限切れの保持ファイルを破棄し、削除指定されたファイルを削除しています
Moving part of the %s log file.
%s の一部をログファイルに移動しています。
Could not open %s log file
%s ログファイルが開けません
Error was
エラーは次のようでした
Note: This error is normal if no changes have been made.
注意: 何も変更されていなければ、このエラーは普通です。
Moving %s log entries.
%s 個のログ項目を移動しています。
Set or Remove global edit lock
全体の編集ロックを設定または除去
Edit lock created.
編集ロックが作られました。
Edit lock removed.
編集ロックが除去されました。
Set or Remove page edit lock
ページ編集ロックを設定または除去
Lock for %s created.
%s のロックが作られました。
Lock for %s removed.
%s のロックが除去されました。
Displaying Wiki Version
ウィキバージョンの表示
Debugging Information
デバッグ情報
Too many connections by %s
%s による多すぎる接続
Please do not fetch more than %1 pages in %2 seconds.
%2 秒間に %1 ページより多く取得しないでください。
Check whether the web server can create the directory %s and whether it can create files in it.
ウェブサーバが %s ディレクトリを作れるかどうかを、またウェブサーバがそのディレクトリの中にファイルを作れるかどうかを、確認してください。
, see 

The two revisions are the same.
2つのリビジョンは同じです。
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
%s の編集は許可されません。
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
