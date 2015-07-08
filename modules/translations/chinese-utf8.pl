# UTF-8 encoded Traditional Chinese language file for use with Oddmuse
#
# Copyright (c) 2003, 2004  wctang <wctang@csie.nctu.edu.tw>
# Copyright (c) 2007  Wei Ren Wang <weithenn@gmail.com>
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
# This translation was last checked for Oddmuse version 1.504.
#
use utf8;
use strict;

AddModuleDescription('chinese-utf8.pl', 'Chinese') if defined &AddModuleDescription;

our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.

Add your comment here:

Reading not allowed: user, ip, or network is blocked.
禁止讀取：使用者、ip 或是網路已被禁止連線。
Login
登入
Error
錯誤
%s calls

Cannot create %s
無法建立 %s
Include normal pages
包含正常頁面
Invalid UserName %s: not saved.
無法儲存。無效的使用者名稱 %s
UserName must be 50 characters or less: not saved
無法儲存。使用者名稱不可超過 50 個字元。
This page contains an uploaded file:
本頁包含一個已上傳的檔案：
No summary was provided for this file.

Recursive include of %s!

Clear Cache
清除快取
Main lock obtained.
取得主要鎖定。
Main lock released.
釋放主要鎖定。
Journal

More...

Comments on this page
對本頁發表評論
XML::RSS is not available on this system.
本系統無法使用 XML::RSS 。
diff
差異
history
歷史記錄
%s returned no data, or LWP::UserAgent is not available.
%s 未回傳資料，或是 LWP::UserAgent 無法使用。
RSS parsing failed for %s
%s 的 RSS 解析失敗
No items found in %s.
在 %s 中未發現項目。
 . . . . 

Click to edit this page
按此即可編輯此頁面
CGI Internal error: %s
CGI 內部錯誤: %s
Invalid action parameter %s
無效的動作參數 %s
Page name is missing
頁面不存在
Page name is too long: %s
頁面名稱太長了： %s
Invalid Page %s (must not end with .db)
無效的頁面名稱 %s (不可使用 .db 做為結尾)
Invalid Page %s (must not end with .lck)
無效的頁面名稱 %s (不可使用 .lck 做為結尾)
Invalid Page %s
無效的頁面名稱 %s
Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
請繼續前住 %s 。
Updates since %s
自 %s 以來的修改
up to %s

Updates in the last %s days
在 %s 天之內的更動
Updates in the last day

for %s only
只列出 %s
List latest change per page only
只列出每個頁面最新的修改
List all changes
列出所有的修改
Skip rollbacks
跳過恢復的版本
Include rollbacks
包含恢復的版本
List only major changes
只列出主要的修改
Include minor changes
也顯示次要的修改
%s days
%s 天
%s day

List later changes
列出最新的修改
RSS

RSS with pages

RSS with pages and diff

Filters
過濾器
Title:
標題:
Title and Body:
標題和內文:
Username:
使用者名稱：
Host:
來源主機：
Follow up to:
後續行動:
Language:
語文：
Go!
開始！
(minor)
(次要的)
rollback
回滾
new
新增
All changes for %s
所有修改頁面 %s
This page is too big to send over RSS.
此頁面太大無法透過 RSS 傳送
History of %s
%s 的歷史記錄
Compare
比較
Deleted
已刪除
Mark this page for deletion
標記為準備刪除的頁面
No other revisions available
無其他版本
current
目前
Revision %s
第 %s 版本
Contributors to %s
編寫 %s 的作者
Missing target for rollback.
找不到要回滾的目標
Target for rollback is too far back.
要回滾的目標已太久以前了。
A username is required for ordinary users.
需使用普通用戶名稱
Rolling back changes
回滾修改
Editing not allowed: %s is read-only.
不允許編輯； %s 是唯讀的
Rollback of %s would restore banned content.

Rollback to %s
回滾至 %s
%s rolled back
%s 已回滾
to %s
到 %s
Index of all pages
所有頁面的索引
Wiki Version
顯示 Wiki 的版本
Password
密碼
Run maintenance
執行維護動作
Unlock Wiki
解鎖
Unlock site
網站解鎖
Lock site
網站鎖定
Unlock %s
解鎖 %s
Lock %s
鎖定 %s
Administration
管理 Oddmuse
Actions:
操作:
Important pages:
重要頁面:
To mark a page for deletion, put <strong>%s</strong> on the first line.
在該頁首行加入 <strong>%s</strong> 可將頁面標記為刪除
from %s
自 %s
redirected from %s
由 %s 轉址 
%s: 

[Home]
[首頁]
Click to search for references to this page
按下即可以搜尋參考至本頁的資料
Cookie: 
Cookie:
Edit this page
編輯本頁
Preview:
預覽：
Preview only, not yet saved
現在是預覽模式，尚未儲存
Warning
警告
Database is stored in temporary directory %s
資料庫現在是存放於暫存目錄 %s
%s seconds
%s 秒
Last edited
最後編輯於
Edited
編輯
by %s
由 %s
(diff)
(比較差異)
a

c

Edit revision %s of this page
編輯本頁的第 %s 版本
e

This page is read-only
本頁是唯讀的
View other revisions
參閱其他版本
View current revision
參閱目前版本
View all changes
列出所有的修改
View contributors
查看編寫者
Homepage URL:
首頁網址：
s

Save
儲存
p

Preview
預覽
Search:
搜尋：
f

Replace:
取代：
Delete
刪除
Filter:
過濾規則:
Validate HTML
驗證 HTML
Validate CSS
驗證 CSS
Last edit
最後編輯
Summary:
摘要：
Difference between revision %1 and %2
差異（從第 %1 版到%2）
revision %s
第 %s 版
current revision
目前的版本
Last major edit (%s)
最後一個主要編輯 (%s)
later minor edits
後來小修改
No diff available.
沒有差異。
Old revision:
舊版本：
Changed:
修改：
Deleted:
已刪除:
Added:
增加：
to
至
Revision %s not available
不存在第 %s 版
showing current revision instead
顯示最新的版本
Showing revision %s
顯示第 %s 版
Cannot save a nameless page.
無法儲存沒有名稱的頁面。
Cannot save a page without revision.
無法儲存沒有版本資訊的頁面。
not deleted: 
未刪除：
deleted
已刪除
Cannot open %s
無法開啟 %s
Cannot write %s
無法寫入 %s
unlock the wiki

Could not get %s lock
無法取得 %s 鎖定
The lock was created %s.
建立鎖定 %s
Maybe the user running this script is no longer allowed to remove the lock directory?

This operation may take several seconds...
這個動作可能要花幾秒…
Forced unlock of %s lock.
強制解開 %s 鎖定。
No unlock required.
不需要解鎖。
%s hours ago
%s 小時前
1 hour ago
1 小時前
%s minutes ago
%s 分鐘前
1 minute ago
1 分鐘前
%s seconds ago
%s 秒前
1 second ago
1 秒前
just now
就是現在
Only administrators can upload files.
只有管理者可以上傳檔案。
Editing revision %s of
正在編輯第 %s 版的
Editing %s
正在編輯 %s
Editing old revision %s.
正在編輯舊的第 %s 版。
Saving this page will replace the latest revision with this text.
如果儲存的話，將會取代目前最新的版本。
This change is a minor edit.
這次的修改是次要的。
Cancel
取消
Replace this file with text
用文字來取代本檔
Replace this text with a file
用檔案來取代本文
File to upload: 
要上傳的檔案：
Files of type %s are not allowed.
不允許 %s 型態的檔案。
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
如果你的 cookie 功能開啟的話，則你的密碼會被儲放在 cookie 中。如果你由其他機器、用其他的帳號、或使用別的軟體來連線的話，則 cookie 可能會消失。
This site does not use admin or editor passwords.
本站並不使用管理者或編輯者密碼功能。
You are currently an administrator on this site.
你現在是本站的管理者。
You are currently an editor on this site.
你現在是本站的編輯者。
You are a normal user on this site.
你現在是本站的一般使用者。
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
你的密碼不符合任何管理者或編輯者的密碼。
Password:
密碼：
Return to 

This operation is restricted to site editors only...
這個動作限定只允許編輯者使用…
This operation is restricted to administrators only...
這個動作限定只允許管理者使用…
Edit Denied
禁止編輯
Editing not allowed: user, ip, or network is blocked.
禁止編輯；使用者、ip 或是網路已被禁止連線。
Contact the wiki administrator for more information.
請通知 wiki 管理者，以取得更多的資訊。
The rule %s matched for you.
你符合的規則： %s 。
See %s for more information.
請參閱 %s 以取得更多資訊。
SampleUndefinedPage
未定義頁面
Sample_Undefined_Page
未定義頁面
Rule "%1" matched "%2" on this page.
本頁的 "%2" 符合規則 "%1"。
Reason: %s.
原因: %s
Reason unknown.
未知原因
(for %s)
(列出 %s )
%s pages found.
找到 %s 個頁面。
Malformed regular expression in %s

Replaced: %s
取代：%s
Search for: %s
搜尋：%s
View changes for these pages
參閱這些頁面的更動
last updated
最後更新於
by
由
Transfer Error: %s
傳輸錯誤：%s
Browser reports no file info.
瀏覽器沒有提供檔案資料。
Browser reports no file type.
瀏覽器沒有提供檔案型態。
The page contains banned text.
本頁含有一些禁止出現的文字。
No changes to be saved.
沒有可以存取的變更。
This page was changed by somebody else %s.
本頁在 %s 已被人修改過。
The changes conflict.  Please check the page again.
你的修改和他人發生衝突。請再次確認。
Please check whether you overwrote those changes.
請確認一下是否你要覆蓋這些修改。
Anonymous
匿名者
Cannot delete the index file %s.
無法刪除索引檔 %s 。
Please check the directory permissions.
請確認目錄的權限。
Your changes were not saved.
你的變更尚未儲存。
Could not get a lock to merge!
在合併時無法取得鎖定！
you
你的
ancestor
之前的
other
別人的
Run Maintenance
執行維護 Oddmuse
Maintenance not done.
無法進行管理。
(Maintenance can only be done once every 12 hours.)
(管理每 12 小時只能進行一次。)
Remove the "maintain" file or wait.
移除 "maintain" 檔，或等時間到了再進行。
Expiring keep files and deleting pages marked for deletion
清除過期的庫存檔和刪除已標記的檔案
Moving part of the %s log file.
移除部分在 %s 記錄檔中的資料。
Could not open %s log file
無法開啟記錄檔 %s
Error was
錯誤是
Note: This error is normal if no changes have been made.
如果還沒有做過任何修改的話，則不用理會這個錯誤訊息。
Moving %s log entries.
移除了 %s 個記錄項目。
Set or Remove global edit lock
設定或移除整個網站的編輯鎖定
Edit lock created.
建立編輯鎖定。
Edit lock removed.
移除編輯鎖定。
Set or Remove page edit lock
設定或移除頁面的編輯鎖定
Lock for %s created.
已建立 %s 的鎖定。
Lock for %s removed.
已移除 %s 的鎖定。
Displaying Wiki Version
顯示 Wiki 主機相關套件版本
Debugging Information

Too many connections by %s
太多來自 %s 的連線
Please do not fetch more than %1 pages in %2 seconds.
請不要在 %2 秒內抓取超過 %1 頁的資料。
Check whether the web server can create the directory %s and whether it can create files in it.
請確認網站伺服器是否可建立 %s 目錄，並且在其中建立檔案。
, see 

The two revisions are the same.
二個版本相同
Deleting %s
正在刪除 %s
Deleted %s
已刪除 %s
Renaming %1 to %2.
正將 %1 更名為 %2 。
The page %s does not exist
頁面 %s 不存在
The page %s already exists
頁面 %s 已存在
Cannot rename %1 to %2
無法將 %1 重新命名為 %2
Renamed to %s
重新命名為 %s
Renamed from %s
來自 %s 的重新命名
Renamed %1 to %2.
已將 %1 更名為 %2 。
Immediately delete %s
立即刪除 %s
Rename %s to:
將 %s 重新命名為:
Attach file:

Upload

Learn more...
更多...
Complete Content
完整內容
The main page is %s.
首頁是 %s 。
Archive:
檔案:
Rebuild BackLink database
重建 BackLink 資料庫
Internal Page: 
內部頁面:
Pages that link to this page
連結此頁面
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
最近的參訪者
some action
部份行為
was here
在這裡
and read
閱讀
Illegal year value: Use 0001-9999
指定的年份無效:請使用 0001-9999 之間的數字
The match parameter is missing.
未指定 match 參數。
Page Collection for %s
%s 的頁面彙整
Previous
向前
Next
向後
Calendar %s
%s 年曆
Su
星期日
Mo
星期一
Tu
星期二
We
星期三
Th
星期四
Fr
星期五
Sa
星期六
January
一月
February
二月
March
三月
April
四月
May
五月
June
六月
July
七月
August
八月
September
九月
October
十月
November
十一月
December
十二月
set %s
設定 %s
unset %s
解除設定 %s
Clustermap
叢集頁面
Pages without a Cluster
不包含叢集頁面
Comments:

Comments on 
評論關於
Comment on 
評論關於
Compilation for %s
%s 的彙整
Compilation tag is missing a regular expression.
匯編的標記缺少一個正規表示式
Install CSS
安裝 CSS
Copy one of the following stylesheets to %s:
複製以下 CSS 模版至 %s
Reset

Extract all dates from the database

Dates

No dates found.

List spammed pages
列出 SPAM 頁面
Despamming pages
正在去除 SPAM 頁面
Spammed pages
SPAM 廣告頁面
Cannot find revision %s.
無法取得版本 %s 。
Revert to revision %1: %2
回滾至版本 %1: %2 
Marked as %s.
標記為 %s 。
Cannot find unspammed revision.
找不到未被 spam 的版本。
Page diff

Diff

Recover Draft
還原草稿
No text to save
沒有儲存文字
Draft saved
草稿已儲存
Draft recovered
草稿已還原
No draft available to recover
沒有可還原的草稿
Save Draft
儲存草稿
Draft Cleanup
清除草稿
Unable to delete draft %s
無法刪除草稿 %s
%1 was last modified %2 and was kept
%1 最後修改 %2 及保存
%1 was last modified %2 and was deleted
%1 最後修改 %2 及刪除
Add Comment
新增評論
ordinary changes
普通變更
Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

Matching page names:
匹配頁面的名稱:
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
您沒有回答正確的答案
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
無法在 %2 找到 %1.html 的範本
Only Editors are allowed to see this hidden page.
只允許編輯者能看到此隱藏頁面
Only Admins are allowed to see this hidden page.
只允許管理者能看到此隱藏頁面
Index
索引
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
忘記您的密碼 ?
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
登出
Current Password:

New Password:

Repeat New Password:

Password is wrong.

Password Changed

Your password has been changed.
您的密碼已變更
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
語文：
Show!
顯示!
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define
定義
Full Link List
完整連結列表
Banned Content

Rule "%1" matched on this page.

List of locked pages

Pages tagged with %s

Template without parameters
未指定 template 參數
The template %s is either empty or does not exist.
範本 %s 可能為空或不存在。
Name: 

URL: 

Define Local Names

Define external redirect: 

 -- defined on %s
 -- 在 %s 中定義
Local names defined on %1: %2
定義本地名稱在 %1: %2
IP number matched %s

Register for %s
為 %s 註冊
Please choose a username of the form "FirstLast" using your real name.
請選擇符合您真實名字的 "FirstLast"
The passwords do not match.
密碼不正確
The password must be at least %s characters.
密碼必須有 %s 字
That email address is invalid.
無效的 E-Mail 地址
The username %s has already been registered.
使用者名稱 %s 已被註冊
Your registration for %s has been submitted.
您註冊的使用者名稱 %s 已提交
Please allow time for the webmaster to approve your request.
請等待一段時間網站管理者為盡快回應您的需求
An email has been sent to "%s" with further instructions.
E-Mail 已被送到 "%s" 等待進一步的指示
There was an error saving your registration.
存取的註冊資訊有一個錯誤
An account was created for %s.
使用者帳戶 %s 已建立
Login to %s
登入到 %s
Username and/or password are incorrect.
使用者名稱或密碼不正確
Logged in as %s.
登入為 %s
Logout of %s
登出 %s
Logout of %s?
登出 %s ?
Logged out of %s
已登出 %s
You are now logged out.
您已登出
Register a new account
註冊新使用者帳戶
Who am I?
我是誰 ?
Change your password
變更您的密碼
Approve pending registrations
等待核准註冊
Confirm Registration for %s
確認註冊為 %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s, 您的註冊已被核准，現在您可以用你的密碼登入和編輯頁面。
Confirmation failed.  Please email %s for help.
確認失敗!!請發 E-mail 至 %s 尋求幫助
Who Am I?
我是誰 ?
You are logged in as %s.
您是登入為 %s
You are not logged in.
您尚未登入
Reset Password
重設密碼
The password for %s was reset.  It has been emailed to the address on file.
%s 密碼已重設，已發送 E-mail 至該地址
There was an error resetting the password for %s.
重設密碼時發生錯誤 %s
The username "%s" does not exist.
使用者名稱 "%s" 不存在
Reset Password for %s
重設密碼 %s
Reset Password?
重設密碼 ?
Change Password for %s
變更密碼 %s
Change Password?
變更密碼 ?
Your current password is incorrect.
您目前的密碼不正確
Approve Pending Registrations for %s
等待註冊 %s
%s has been approved.
%s 已核准
There was an error approving %s.
核准有一處錯誤 %s
There are no pending registrations.
沒有等候的註冊
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
%s 不是一個正常的命名空間
Namespaces

Getting page index file for %s.
自 %s 取得頁面索引資料。
Near links:
近端連結：
Search sites on the %s as well
也搜尋列在 %s 上的網站
Fetching results from %s:
由 %s 取回的結果：
Near pages:
近端頁面：
Include near pages
包含相近的頁面
EditNearLinks
編輯接近連結
The same page on other sites:
其他網站的相同頁面
 (create locally)
 (本地建立)
image
圖像
download
下載
Backlinks

Clearing Cache
清除暫存
Done.
結束
Generating Link Database
產生連結資料庫
The 404 handler extension requires the link data extension (links.pl).
404 訊息，您需要安裝 (links.pl) 擴充模組
Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

LocalMap
本地地圖
No page id for action localmap
在本地地圖內查詢不到頁面名稱
Requested page %s does not exist
請求的頁面 %s 不存在
Local Map for %s
頁面 %s 的本地地圖
view
查看
Self-ban by %s
被 %s 禁止
You have banned your own IP.
您禁止了自已的 IP Address
Orphan List
孤立頁面列表
Trail: 
行經頁面:
None
不指定
Type
類別
Permalink to "%s"
永久連結至 "%s"
anchor first defined here: %s
錨點已被定義於 %s
the page %s also exists
也存在一個叫 %s 的頁面
There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.
建立 %s PDF 時發生錯誤，請停止下載動作並立即通知網站管理員。
Someone else is generating a pdf for %s.  Please wait a minute and then try again.
其它使用者正在建立 %s PDF，請過幾分鐘後在試試。
Download this page as PDF
下載本頁面 PDF
Click to search for references to this permanent anchor
按下即可搜尋此錨點的相關資料
Include permanent anchors
包含固定的錨點
Portrait
肖像
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now

This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.

Cannot refresh index.

Publish %s
發表 %s
No target wiki was specified in the config file.
設定檔案中沒有設定目標(Target) Wiki
The target wiki was misconfigured.
目標(Target) Wiki 設定錯誤
Upload is limited to %s bytes

To save this page you must answer this question:
為了保存此頁面，您必須回答這個問題:
Please type the following two words:

Please answer this captcha:

Referrers
引用者
All Referrers
所有的引用者
Page list for %s

Slideshow:%s
自動播放: %s
Index of all small pages
索引所有小頁面
Static Copy
靜態頁面備份
Back to %s
返回 %s
Editing not allowed for %s.
不允許編輯 %s 。
Edit image in the browser

Summary of your changes: 

Copy to %1 succeeded: %2.
從 %2 複製到 %1 成功
Copy to %1 failed: %2.
從 %2 複製到 %1 失敗
Tag
標籤
Feed for this tag

Tag Cloud
標籤雲
 ... 

Rebuilding index not done.
重建索引尚未完成
(Rebuilding the index can only be done once every 12 hours.)
(重建索引間隔為 12 小時)
Rebuild tag index

list tags

tag cloud

Alternatively, use one of the following templates:
或者，使用下列範本之一:
Too many instances.  Only %s allowed.
太多請求，只允許 %s
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
系統忙碌中請稍後在試一次，可能有人正在執行維護動作或長期搜尋
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
內容
Create a new page for today
建立今日頁面
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
本頁是頁面 %s 的翻譯。
The translation is up to date.
本頁翻譯符合最新的內容。
The translation is outdated.
本頁翻譯已過期。
The page does not exist.
頁面不存在。
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
另一個連結
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
搜尋
Wanted Pages
徵求頁面
%s pages
%s 頁面
%s, referenced from:
%s 引用自:
Web application for offline browsing

Upload of %s file
上傳 %s 檔案
Blog
日誌
Matching pages:
匹配頁面:
New
新增日誌
Edit %s.
編輯 %s
Title: 
標題:
Tags: 
標籤:
END_OF_TRANSLATION
