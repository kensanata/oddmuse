# UTF-8 encoded Simplified Chinese language file for use with Oddmuse
#
# Copyright (c) 2014, Andy Stewart <lazycat.manatee@gmail.com>
# Copyright (c) 2006, Qianqian Fang <fangqq@gmail.com>
# Copyright (c) 2003, 2004  wctang <wctang@csie.nctu.edu.tw>
# Copyright (c) 2005  xuzq <xuzq@chinalions.com>
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
#Thanks:
#=======
#This translation is based upon the traditional Chinese translation chinese-utf8.pl
#(http://www.oddmuse.org/cgi-bin/wiki/download/chinese-utf8.pl)
#by wctang <wctang@csie.nctu.edu.tw> and using the tool cnmap
#(http://search.cpan.org/~qjzhou/Encode-CNMap-0.32/bin/cnmap) by Qing-Jie Zhou <qjzhou@hotmail.com>.
#
use utf8;
use strict;

AddModuleDescription('chinese_cn-utf8.pl', 'Chinese') if defined &AddModuleDescription;
our $SiteName = '我的Wiki'; # Name of site (used for titles)
our $HomePage = '首页'; # Home page
our $NewText = "新页面内容\n"; # New page text
our $NewComment = "请添加评论\n"; # New comment text
our $BannedContent = '禁用'; # Page for banned content (usually for link-ban)
our $BannedHosts = '封禁地址'; # Page for banned hosts
our $DeletedPage = '删除页面'; # Pages starting with this can be deleted
our $RCName = '最近更新'; # Name of changes page
our $RssExclude = 'RSS排除页面'; # name of the page that lists pages to be excluded from the feed
our $CategoriesPage = '日志类别';
our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.

Add your comment here:

Reading not allowed: user, ip, or network is blocked.
禁止读取：用户、IP 或是网络已被禁止连接。
Login
登录
Error
错误
%s calls
%s 次调用
Cannot create %s
无法建立 %s
Include normal pages
包含普通页面
Invalid UserName %s: not saved.
无法保存, 无效的用户名 %s。
UserName must be 50 characters or less: not saved
无法保存, 使用者名称不可超过 50 个字符。
This page contains an uploaded file:
本页包含一个已上传的文件：
No summary was provided for this file.

Recursive include of %s!
递归包含 %s
Clear Cache
清除缓存
Main lock obtained.
获得主要锁定。
Main lock released.
释放主要锁定。
Journal
日志
More...
更多...
Comments on this page
对本页发表评论
XML::RSS is not available on this system.
本系统无法使用 XML::RSS 。
diff
差异
history
历史记录
%s returned no data, or LWP::UserAgent is not available.
%s未返回数据，或是 LWP::UserAgent 无法使用。
RSS parsing failed for %s
%s的 RSS 解析失败
No items found in %s.
在%s中未发现项目。
 . . . . 

Click to edit this page
按此即可编辑此页面
CGI Internal error: %s
CGI内部错误 %s
Invalid action parameter %s
无效的动作参数 %s
Page name is missing
页面不存在
Page name is too long: %s
页面名称太长了： %s
Invalid Page %s (must not end with .db)
无效的页面名称%s(不可使用 .db 做为结尾)
Invalid Page %s (must not end with .lck)
无效的页面名称%s(不可使用 .lck 做为结尾)
Invalid Page %s
无效的页面名称 %s
Too many redirections
太多的重定向
No redirection for old revisions
不能重定向到旧版本
Invalid link pattern for #REDIRECT
无效的 #REDIRECT 连接模式
Please go on to %s.
请继续前住%s。
Updates since %s
自%s以来的更改
up to %s

Updates in the last %s days
在%s天之内的更改
Updates in the last day
在天之内的更改
for %s only
只列出 %s
List latest change per page only
只列出每个页面最新的更改
List all changes
列出所有更改
Skip rollbacks
跳过回滚的版本
Include rollbacks
包含回滚的版本
List only major changes
只列出主要的更改
Include minor changes
显示次要的更改
%s days
%s天
%s day

List later changes
列出随后的更改
RSS
RSS
RSS with pages
RSS和页面
RSS with pages and diff
RSS和页面以及差异
Filters
过滤器
Title:
标题：
Title and Body:
标题和正文：
Username:
用户名：
Host:
主机：
Follow up to:
跟进：
Language:
语言：
Go!
开始！
(minor)
(次要的)
rollback
回滚
new
新增
All changes for %s
%s页面的所有更改
This page is too big to send over RSS.
页面太大，无法通过RSS发送。
History of %s
%s的历史记录
Compare
比较
Deleted
已删除的
Mark this page for deletion
标记为准备删除的文档
No other revisions available
没有其他版本可用
current
当前版本
Revision %s
第%s版本
Contributors to %s
参与编写%s的贡献者
Missing target for rollback.
找不到要回滚的目标。
Target for rollback is too far back.
要回滚的目标过于久远。
A username is required for ordinary users.
需要一个普通用户的用户名。
Rolling back changes
回滚更改
Editing not allowed: %s is read-only.
禁止编辑；%s为只读。
Rollback of %s would restore banned content.

Rollback to %s
回滚至 %s
%s rolled back
%s已回滚
to %s
到 %s
Index of all pages
所有页面的索引
Wiki Version
显示 Wiki 的版本
Password
密码
Run maintenance
执行维护动作
Unlock Wiki
解锁 Wiki
Unlock site
解锁网站
Lock site
锁定网站
Unlock %s
解锁 %s
Lock %s
锁定 %s
Administration
管理
Actions:
操作：
Important pages:
重要页面：
To mark a page for deletion, put <strong>%s</strong> on the first line.
在首行加入 <strong>%s</strong>以将页面标记为删除。
from %s
自 %s
redirected from %s
自%s重定向 
%s: 
%s：
[Home]
[首页]
Click to search for references to this page
按下即可以搜索参考至本页的数据
Cookie: 
Cookie：
Edit this page
编辑本页
Preview:
预览：
Preview only, not yet saved
现在是预览模式，尚未保存
Warning
警告
Database is stored in temporary directory %s
数据库现在是存放于临时目录 %s
%s seconds
%s秒
Last edited
最后编辑于
Edited
编辑
by %s
由 %s
(diff)
(比较差异)
a

c

Edit revision %s of this page
编辑本页的第%s版本
e

This page is read-only
本页是只读的
View other revisions
参阅其他版本
View current revision
参阅当前版本
View all changes
列出所有更改
View contributors
查看贡献者
Homepage URL:
首页网址：
s

Save
保存
p

Preview
预览
Search:
搜索：
f

Replace:
取代：
Delete
删除
Filter:
过滤规则：
Validate HTML
验证 HTML
Validate CSS
验证 CSS
Last edit
最后编辑
Summary:
摘要：
Difference between revision %1 and %2
比较第%1版和第%2版之间的差异
revision %s
第%s版
current revision
当前版本
Last major edit (%s)
最后主版本编辑 (%s)
later minor edits
随后的次要编辑
No diff available.
没有差异。
Old revision:
旧版本：
Changed:
修改：
Deleted:
已删除：
Added:
增加：
to
至
Revision %s not available
不存在第%s版
showing current revision instead
显示最新的版本
Showing revision %s
显示第%s版
Cannot save a nameless page.
无法保存没有名称的页面。
Cannot save a page without revision.
无法保存没有版本信息的页面。
not deleted: 
未删除：
deleted
已删除
Cannot open %s
无法打开 %s
Cannot write %s
无法写入 %s
unlock the wiki

Could not get %s lock
无法获得%s锁定
The lock was created %s.
为 %s 建立锁定 。	
Maybe the user running this script is no longer allowed to remove the lock directory?

This operation may take several seconds...
这个动作可能要花几秒…
Forced unlock of %s lock.
强制解开%s锁定。
No unlock required.
不需要解锁。
%s hours ago
%s小时前
1 hour ago
1 小时前
%s minutes ago
%s分钟前
1 minute ago
1 分钟前
%s seconds ago
%s秒前
1 second ago
1 秒前
just now
刚才
Only administrators can upload files.
只有管理员可以上传文件。
Editing revision %s of
正在编辑第%s版的
Editing %s
正在编辑 %s
Editing old revision %s.
正在编辑旧的第%s版。
Saving this page will replace the latest revision with this text.
如果保存本页，将会替换目前最新的版本。
This change is a minor edit.
这次的更改是次要的。
Cancel
取消
Replace this file with text
用文字来取代本档
Replace this text with a file
用文件来取代本文
File to upload: 
要上传的文件：
Files of type %s are not allowed.
不允许%s类型的文件。
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
如果您已经开启了 cookie， 您的密码会被保存在 cookie 中。Cookie可能会因为您使用其他机器、帐号、或别的软件来连接而丢失。
This site does not use admin or editor passwords.
本站并不使用管理员或编辑者密码功能。
You are currently an administrator on this site.
您现在是本站的管理员。
You are currently an editor on this site.
您现在是本站的编辑者。
You are a normal user on this site.
您现在是本站的普通用户。
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
您的密码和任何管理员或编辑者的密码都不匹配。
Password:
密码：
Return to 

This operation is restricted to site editors only...
这个动作限定只允许编辑者使用…
This operation is restricted to administrators only...
这个动作限定只允许管理员使用…
Edit Denied
禁止编辑
Editing not allowed: user, ip, or network is blocked.
禁止编辑；用户、IP 或是网络已被禁止连接。
Contact the wiki administrator for more information.
请通知 wiki 管理员以获得更多的信息。
The rule %s matched for you.
符合您的规则：%s。
See %s for more information.
请参阅%s以获得更多信息。
SampleUndefinedPage
未定义页面
Sample_Undefined_Page
未定义_页面
Rule "%1" matched "%2" on this page.
本页的 "%2" 符合规则 "%1"。
Reason: %s.
原因：%s。
Reason unknown.
未知原因。
(for %s)
(列出%s)
%s pages found.
找到%s个页面。
Malformed regular expression in %s

Replaced: %s
取代：%s
Search for: %s
搜索：%s
View changes for these pages
参阅这些页面的更改
last updated
最后更新于
by
由
Transfer Error: %s
传输错误：%s
Browser reports no file info.
浏览器没有提供文件信息。
Browser reports no file type.
浏览器没有提供文件类型。
The page contains banned text.
本页含有一些禁止出现的文字。
No changes to be saved.
没有改动可以保存。
This page was changed by somebody else %s.
本页在%s已被人修改过。
The changes conflict.  Please check the page again.
您的修改和他人发生冲突。请再次确认。
Please check whether you overwrote those changes.
请您确认一下是否要覆盖这些修改。
Anonymous
匿名者
Cannot delete the index file %s.
无法删除索引档%s。
Please check the directory permissions.
请确认目录的权限。
Your changes were not saved.
您的变更尚未保存。
Could not get a lock to merge!
在合并时无法获得锁定！
you
您的
ancestor
之前的
other
别人的
Run Maintenance
运行管理
Maintenance not done.
无法进行管理。
(Maintenance can only be done once every 12 hours.)
(管理每 12 小时只能进行一次。)
Remove the "maintain" file or wait.
移除 "maintain" 档，或等时间到了再进行。
Expiring keep files and deleting pages marked for deletion
清除过期的库存档和删除已标记的文件
Moving part of the %s log file.
移除部分在%s日志文件中的数据。
Could not open %s log file
无法打开日志文件 %s
Error was
错误是
Note: This error is normal if no changes have been made.
如果还没有做过任何修改，请不用理会这个错误讯息。
Moving %s log entries.
移除了%s个日志项目。
Set or Remove global edit lock
设定或移除整个网站的编辑锁定
Edit lock created.
建立编辑锁定。
Edit lock removed.
移除编辑锁定。
Set or Remove page edit lock
设定或移除页面的编辑锁定
Lock for %s created.
已建立%s的锁定。
Lock for %s removed.
已移除%s的锁定。
Displaying Wiki Version
显示 Wiki 版本
Debugging Information
调试信息
Too many connections by %s
太多来自%s的连接
Please do not fetch more than %1 pages in %2 seconds.
请不要在 %2 秒内下载超过 %1 页的数据。
Check whether the web server can create the directory %s and whether it can create files in it.
请确认网站服务器是否可建立%s目录，并且在其中建立文件。
, see 

The two revisions are the same.
两个版本相同
Deleting %s
正在删除 %s
Deleted %s
已删除 %s
Renaming %1 to %2.
正将 %1 更名为 %2 。
The page %s does not exist
页面%s不存在
The page %s already exists
页面%s已存在
Cannot rename %1 to %2
无法将 %1 重命名为 %2
Renamed to %s
更名为 %s
Renamed from %s
更名自 %s
Renamed %1 to %2.
已将 %1 更名为 %2 。
Immediately delete %s
立即删除 %s
Rename %s to:
将%s重命名为:
Attach file:

Upload

Learn more...
了解更多...
Complete Content
完整内容
The main page is %s.
主页是%s。
Archive:
存档：
Rebuild BackLink database
重建BackLink数据库
Internal Page: 
内部页面：
Pages that link to this page
本页的链接页面
The search parameter is missing.
未指定 search 参数。
Pages link to %s
页面链接至 %s
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
最近的游客
some action
部分行为
was here
在这里
and read
阅读
Illegal year value: Use 0001-9999
指定的年份无效：请使用0001-9999之间的数字
The match parameter is missing.
未指定 match 参数。
Page Collection for %s
%s的页面集合
Previous
向前
Next
向后
Calendar %s
%s年历
Su
周日
Mo
周一
Tu
周二
We
周三
Th
周四
Fr
周五
Sa
周六
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
设置 %s
unset %s
取消设置 %s
Clustermap
簇页面
Pages without a Cluster
不包含簇的页面
Comments:

Comments on 
评论关于
Comment on 
评论关于
Compilation for %s
%s的汇编
Compilation tag is missing a regular expression.
汇编标志缺少一个正规表达式。
Install CSS
安装CSS
Copy one of the following stylesheets to %s:
复制以下样式模板至 %s。
Reset

Extract all dates from the database

Dates

No dates found.

List spammed pages
列出垃圾页面
Despamming pages
正在去除垃圾页面
Spammed pages
垃圾页面
Cannot find revision %s.
无法获得版本%s。
Revert to revision %1: %2
恢复至版本 %1: %2 
Marked as %s.
标记为%s。
Cannot find unspammed revision.
找不到未被 spam 的版本。
Page diff

Diff

Recover Draft
恢复草稿
No text to save
没有文本需要保存
Draft saved
草稿已经保存
Draft recovered
草稿已恢复
No draft available to recover
没有需要恢复的草稿
Save Draft
保存草稿
Draft Cleanup
清除草稿
Unable to delete draft %s
不能删除草稿 %s
%1 was last modified %2 and was kept
%1 最后修改 %2 已被保持
%1 was last modified %2 and was deleted
%1 最后修改 %2 已被删除
Add Comment
添加评论
ordinary changes
普通改动
Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

Matching page names:
匹配页名称：
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
回答不正确。
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
邮件：
Could not find %1.html template in %2
无法在 %2 找到 %1.html 的模板
Only Editors are allowed to see this hidden page.
只有编辑才允许查看该隐藏页面
Only Admins are allowed to see this hidden page.
只有管理员才允许查看该隐藏页面
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
忘记了口令？
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
注销
Current Password:

New Password:

Repeat New Password:

Password is wrong.

Password Changed

Your password has been changed.
您的口令已修改。
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
语言：
Show!
显示!
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define
定义
Full Link List
完整链接列表
Banned Content

Rule "%1" matched on this page.

List of locked pages
列出被锁定的页面
Pages tagged with %s
页面标记为%s
Template without parameters
未指定 template 参数
The template %s is either empty or does not exist.
模板%s可能为空或不存在。
Name: 

URL: 

Define Local Names

Define external redirect: 

 -- defined on %s
 -- 在%s中定义
Local names defined on %1: %2
定义在%s:%2的局部变量
IP number matched %s

Register for %s
为%s注册
Please choose a username of the form "FirstLast" using your real name.
请使用您的名字注册。
The passwords do not match.
两次输入的口令不一致。
The password must be at least %s characters.
口令必须只要%s个英文字母。
That email address is invalid.
电子邮件地址非法。
The username %s has already been registered.
用户%s已经注册。
Your registration for %s has been submitted.
账号%s的注册信息已经发送。
Please allow time for the webmaster to approve your request.
请静候管理员的处理和回复。
An email has been sent to "%s" with further instructions.
请查看您的电子信箱"%s"获取详细说明。
There was an error saving your registration.
您的注册信息保存时出错。
An account was created for %s.
成功创建用户%s。
Login to %s
登录到%s
Username and/or password are incorrect.
用户名或口令不正确。
Logged in as %s.
以%s登录。
Logout of %s
%s退出登录
Logout of %s?
是否退出登录？
Logged out of %s
用户%s已退出登录
You are now logged out.
您现在已经退出登录。
Register a new account
注册一个新账号
Who am I?
我是谁？
Change your password
更改您的口令
Approve pending registrations
待候审批的用户注册
Confirm Registration for %s
确认%s的注册信息
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s，您的注册信息已批准。您可以使用注册的账号和口令登录Wiki进行编辑。
Confirmation failed.  Please email %s for help.
确认失败。请向%s发送电子邮件求助。
Who Am I?
我是谁？
You are logged in as %s.
您登录的账号为%s。
You are not logged in.
尚未登录
Reset Password
重置口令
The password for %s was reset.  It has been emailed to the address on file.
用户%s的口令已重置。请查看您的电子邮件。
There was an error resetting the password for %s.
重置%s口令时出错。
The username "%s" does not exist.
用户名“%s”不存在。
Reset Password for %s
重置“%s”的口令
Reset Password?
确认重置口令？
Change Password for %s
更改%s的口令
Change Password?
确认更改口令
Your current password is incorrect.
您现在的口令不正确。
Approve Pending Registrations for %s
待候审批的用户“%s”的注册信息
%s has been approved.
用户“%s”已批准。
There was an error approving %s.
批准用户%s注册信息时出错。
There are no pending registrations.
无待候审批用户
Invalid Mail %s: not saved.
无法保存, 无效的邮件 %s。
unsubscribe
退订
subscribe
订阅
%s appears to be an invalid mail address
%s 似乎是一个错误的邮件地址
Your mail subscriptions
您的邮件订阅
All mail subscriptions
所有邮件订阅
Subscriptions
订阅
Show
显示
Subscriptions for %s:
%s 的订阅
Unsubscribe
退订
There are no subscriptions for %s.
%s 没有订阅
Change email address
更改邮件地址
Mail addresses are linked to unsubscription links.
邮件地址链接到退订链接。
Subscribe to %s.
订阅 %s 。
Subscribe
订阅
Subscribed %s to the following pages:
订阅以下页面 %s ：
The remaining pages do not exist.
剩下的页面不存在。
Unsubscribed %s from the following pages:
从以下页面退订 %s
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
您已经对同一个域名的连接已经超过 %s 次。这似乎只有垃圾邮件发送者会这么做。您的编辑被拒绝。
%s is not a legal name for a namespace
%s不是一个合法的用户名，请重新设置
Namespaces
命名空间
Getting page index file for %s.
自%s获得页面索引数据。
Near links:
附近链接：
Search sites on the %s as well
也搜索列在%s上的网站
Fetching results from %s:
由%s取回的结果：
Near pages:
相邻页面：
Include near pages
包含相邻页面
EditNearLinks
编辑相邻链接
The same page on other sites:
其他网站的相同页面
 (create locally)
 (本地创建)
image
图像
download
下载
Backlinks
反向链接
Clearing Cache
清除缓存
Done.
结束。
Generating Link Database
产生链接数据库
The 404 handler extension requires the link data extension (links.pl).
404信息处理扩展单元需要您安装links.pl
Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

LocalMap
本地地图
No page id for action localmap
查询本地地图时无页面名称
Requested page %s does not exist
请求页面“%s”不存在
Local Map for %s
页面“%s”的本地地图
view
查看
Self-ban by %s
被%s自闭
You have banned your own IP.
您已经禁止了自己的IP地址。
Orphan List
孤立页面列表
Trail: 
行经页面:
None
不指定
Type
类别
Permalink to "%s"
永久链接至 "%s"
anchor first defined here: %s
锚点已被定义于 %s
the page %s also exists
也存在一个叫%s的页面
There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.
生成%s的pdf时出错。如果生成PDF不能工作请不要再尝试下载， 并报告给管理员。
Someone else is generating a pdf for %s.  Please wait a minute and then try again.
其他用户正在生成%s的pdf。请稍候一分钟后再连接。
Download this page as PDF
下载该页面为PDF文档
Click to search for references to this permanent anchor
按下即可搜索此锚点的相关数据
Include permanent anchors
包含永久锚点
Portrait
肖像
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now

This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.

Cannot refresh index.

Publish %s
发表%s
No target wiki was specified in the config file.
配置文件中没有设定目标wiki
The target wiki was misconfigured.
目标wiki设置有误
Upload is limited to %s bytes

To save this page you must answer this question:
保存该页面需要正确回答以下问题：
Please type the following two words:
请键入以下两句话：
Please answer this captcha:
请回答这个验证码：
Referrers
引用者
All Referrers
所有的引用者
Page list for %s
％s的页面列表
Slideshow:%s
自动放映：%s
Index of all small pages
索引所有小页面
Static Copy
静态页面备份
Back to %s
返回 %s
Editing not allowed for %s.
不允许编辑%s。
Edit image in the browser

Summary of your changes: 

Copy to %1 succeeded: %2.
成功复制为%1：%2
Copy to %1 failed: %2.
无法复制为%1：%2
Tag
标签
Feed for this tag
订阅这个标签
Tag Cloud
标签云
 ... 
 ... 
Rebuilding index not done.
重建索引尚未完成
(Rebuilding the index can only be done once every 12 hours.)
（自动重建索引间隔为12个小时。）
Rebuild tag index
重建标签索引
list tags
列出标签
tag cloud
标签云
Alternatively, use one of the following templates:
或者，使用下列模板之一:
Too many instances.  Only %s allowed.
太多的实例。只有%s被允许。
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
请稍后再试。也许有人正在运行维护或耗时搜索。不幸的是，站点的资源有限，还请您保持耐心。
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
内容
Create a new page for today
创建一个今天的新页面
Add Translation
添加翻译
Added translation: %1 (%2)
已添加翻译：%1 (%2)
Translate %s
翻译 %s
Thank you for writing a translation of %s.
感谢您编写 %s 的翻译
Please indicate what language you will be using.
请指定您要使用的语言
Language is missing
语言不存在
Suggested languages:
建议的语言：
Please indicate a page name for the translation of %s.
请指定 %s 的翻译页面名称
More help may be available here: %s.
在 %s 查找更多帮助
Translated page: 
已翻译页面：
Please provide a different page name for the translation.

This page is a translation of %s. 
本页是页面%s的翻译。
The translation is up to date.
本页翻译符合最新的内容。
The translation is outdated.
本页翻译已过期。
The page does not exist.
页面不存在。
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
另一个链接
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
搜索
Wanted Pages
悬赏页面
%s pages
%s个页面
%s, referenced from:
%s，引用自：
Web application for offline browsing

Upload of %s file
上传%s个文件
Blog
日志
Matching pages:
匹配页面：
New
新增日志
Edit %s.
编辑%s。
Title: 
标题：
Tags: 
标签：
END_OF_TRANSLATION
