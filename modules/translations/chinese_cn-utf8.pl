# UTF-8 encoded Simplified Chinese language file for use with Oddmuse
#
# Copyright (c) 2006, Qianqian Fang <fangqq@gmail.com>
# Copyright (c) 2003, 2004  wctang <wctang@csie.nctu.edu.tw>.
# Copyright (c) 2005  xuzq <xuzq@chinalions.com>.
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
$ModulesDescription .= '<p>$Id: chinese_cn-utf8.pl,v 1.11 2009/06/07 19:30:37 as Exp $</p>';
##############################################################
#  for those who want to use Chinese even for special pages
#  please uncomment the corresponding lines to use translated 
#  page name
##############################################################
$SiteName    = '我的Wiki';                # Name of site (used for titles)
$HomePage    = '首页';      # Home page
$NewText     = "新页面内容\n";  # New page text
$NewComment  = "请添加评论\n";       # New comment text
$BannedContent = '禁用'; # Page for banned content (usually for link-ban)
$BannedHosts = '封禁地址';   # Page for banned hosts
$DeletedPage = '删除页面';   # Pages starting with this can be deleted
$RCName      = '最近更新'; # Name of changes page
$RssExclude       = 'RSS排除页面'; # name of the page that lists pages to be excluded from the feed
$CategoriesPage = '日志类别';
%Translate = split(/\n/,<<END_OF_TRANSLATION);
Include normal pages
包含普通页面
Reading not allowed: user, ip, or network is blocked.
禁止读取：使用者、ip 或是网路已被禁止连线。
Login
登录
Error

%s calls

Could not create %s
无法建立 %s
Invalid UserName %s: not saved.
无法储存。无效的使用者名称 %s
UserName must be 50 characters or less: not saved
无法储存。使用者名称不可超过 50 个字符。
This page contains an uploaded file:
本页包含一个已上传的文件：
Recursive include of %s!
递归包含 %s
Clear Cache
清除缓存
Main lock obtained.
取得主要锁定。
Main lock released.
释放主要锁定。
Journal

More...

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

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
请继续前住%s。
Updates since %s
自%s以来的修改
Updates in the last %s days
在%s天之内的更动
Updates in the last %s day
在%s天之内的更动
for %s only
只列出 %s
List latest change per page only
只列出每个页面最新的修改
List all changes
列出恢复的版本
Skip rollbacks
跳过恢复的版本
Include rollbacks
包含版本恢复
List only major changes
只列出主要的修改
Include minor changes
也显示次要的修改
%s days
%s天
List later changes
列出最新的修改
RSS

RSS with pages

RSS with pages and diff

Filters
过滤器
Title:
标题：
Title and Body:
标题和正文：
Username:
使用者名称：
Host:
来源主机：
Follow up to:

Language:
语言：
Go!
开始！
(minor)
(次要的)
rollback
恢复
new
新增
All changes for %s
%s页面的所有修订
from %s
自 %s
This page is too big to send over RSS.
页面太大，无法通过RSS发送。
History of %s
%s的历史记录
Compare
比较
Deleted
已删除的
Mark this page for deletion
标记为准备删除文档
No other revisions available
无其他版本
current
当前
Revision %s
第%s版本
Contributors to %s
参与编写%s的作者
Missing target for rollback.
找不到要恢复的目标
Target for rollback is too far back.
要恢复的目标过于久远。
A username is required for ordinary users.

Rolling back changes
恢复修改
The two revisions are the same.
两个版本相同
Editing not allowed for %s.
不允许编辑%s。
Rollback to %s
恢复至 %s
%s rolled back
%s已恢复
to %s
到 %s
Index of all pages
所有页面的索引
Wiki Version
显示 Wiki 的版本
Unlock Wiki
解锁
Password
密码
Run maintenance
执行维护动作
Unlock site
网站解锁
Lock site
网站锁定
Install CSS
安装CSS
Unlock %s
解锁 %s
Lock %s
锁定 %s
Administration
管理
Actions:
操作
Important pages:
重要页面
To mark a page for deletion, put <strong>%s</strong> on the first line.
在首行加入 <strong>%s</strong>以将页面标志为删除.
[Home]
[首页]
redirected from %s
自%s重定向 
%s: 

Click to search for references to this page
按下即可以搜索参考至本页的数据
Cookie: 
曲其：
Edit this page
编辑本页
Preview:
预览：
Preview only, not yet saved
现在是预览模式，尚未储存
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
Edit revision %s of this page
编辑本页的第%s版本
e

This page is read-only
本页是只读的
View other revisions
参阅其他版本
View current revision
参阅目前版本
View all changes
列出所有的修改
View contributors
查看作者
Homepage URL:
首页网址：
s

Save
储存
p

Preview
预览
Search:
搜索：
f

Replace:
取代：
Delete

Validate HTML
验证 HTML
Validate CSS
验证 CSS
Last edit
最后编辑
Difference between revision %1 and %2
差异（从第 %1 版到%2）
revision %s
第%s版
current revision
目前的版本
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
无法储存没有名称的页面。
Cannot save a page without revision.
无法储存没有版本信息的页面。
Cannot open %s
无法打开 %s
Cannot write %s
无法写入 %s
Cannot create %s
无法创建
Could not get %s lock
无法取得%s锁定
The lock was created %s.
创建文件只读标记。
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
就是现在
Edit Denied
禁止编辑
Editing not allowed: user, ip, or network is blocked.
禁止编辑；使用者、ip 或是网路已被禁止连线。
Contact the wiki administrator for more information.
请通知 wiki 管理者，以取得更多的信息。
The rule %s matched for you.
你符合的规则：%s。
See %s for more information.
请参阅%s以取得更多信息。
Editing not allowed: %s is read-only.
禁止编辑；%s为只读。
Only administrators can upload files.
只有管理者可以上传文件。
Editing revision %s of
正在编辑第%s版的
Editing %s
正在编辑 %s
Editing old revision %s.
正在编辑旧的第%s版。
Saving this page will replace the latest revision with this text.
如果储存的话，将会取代目前最新的版本。
Summary:
摘要：
This change is a minor edit.
这次的修改是次要的。
Cancel

Replace this file with text
用文字来取代本档
Replace this text with a file
用文件来取代本文
File to upload: 
要上传的文件：
Files of type %s are not allowed.
不允许%s类型的文件。
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
如果你的 cookie 功能打开的话，则你的密码会被储放在 cookie 中。如果你由其他机器、用其他的帐号、或使用别的软件来连线的话，则 cookie 可能会消失。
You are currently an administrator on this site.
你现在是本站的管理者。
You are currently an editor on this site.
你现在是本站的编辑者。
You are a normal user on this site.
你现在是本站的一般使用者。
Your password does not match any of the  administrator or editor passwords.
你的密码不符合任何管理者或编辑者的密码。
Password:
密码：
This site does not use admin or editor passwords.
本站并不使用管理者或编辑者密码功能。
This operation is restricted to site editors only...
这个动作限定只允许编辑者使用…
This operation is restricted to administrators only...
这个动作限定只允许管理者使用…
SampleUndefinedPage
未定义页面
Sample_Undefined_Page
未定义_页面
Rule "%1" matched "%2" on this page.
本页的 "%2" 符合规则 "%1"。
Reason: %s.

Reason unknown.

Filter:
过滤规则：
(for %s)
(列出%s)
%s pages found.
找到%s个页面。
Replaced: %s
取代：%s
Search for: %s
搜索：%s
View changes for these pages
参阅这些页面的更动
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
你的修改和他人发生冲突。请再次确认。
Please check whether you overwrote those changes.
请确认一下是否你要覆盖这些修改。
Anonymous
匿名者
Cannot delete the index file %s.
无法删除索引档%s。
Please check the directory permissions.
请确认目录的权限。
Your changes were not saved.
你的变更尚未储存。
Could not get a lock to merge!
在合并时无法取得锁定！
you
你的
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
not deleted: 
未删除：
deleted
已删除
Moving part of the %s log file.
移除部分在%s日志文件中的数据。
Could not open %s log file
无法打开日志文件 %s
Error was
错误是
Note: This error is normal if no changes have been made.
如果还没有做过任何修改的话，则不用理会这个错误讯息。
Moving %s log entries.
移除了%s个记录项目。
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

Inter links:
内部连结：
Too many connections by %s
太多来自%s的连线
Please do not fetch more than %1 pages in %2 seconds.
请不要在 %2 秒内下载超过 %1 页的数据。
Check whether the web server can create the directory %s and whether it can create files in it.
请确认网站服务器是否可建立%s目录，并且在其中建立文件。
Copy one of the following stylesheets to %s:
复制以下样式模板至 %s。
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
Learn more...
更多...
Complete Content
完整内容
The main page is %s.
首页是%s。
Archive:

Rebuild BackLink database

Internal Page: 

Pages that link to this page

The search parameter is missing.

Pages link to %s

Cannot highlight the language %s.
无法高亮显示语言%s。
Recent Visitors
最近的访问者
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

unset %s

Clustermap
簇页面
Pages without a Cluster
不包含簇的页面
Comments on 
评论关于
Comment on 
评论关于
Compilation for %s
%s的汇编
Compilation tag is missing a regular expression.
汇编标志缺少一个正规表达式。
List spammed pages

Despamming pages
正在去除 spam 页面
Spammed pages

Cannot find revision %s.
无法取得版本%s。
Revert to revision %1: %2
恢复至版本 %1: %2 
Marked as %s.
标记为%s。
Cannot find unspammed revision.
找不到未被 spam 的版本。
Recover Draft

No text to save

Draft saved

Draft recovered

No draft available to recover

Save Draft

Draft Cleanup

%1 was last modified %2 and was kept

%1 was last modified %2 and was deleted

Unable to delete draft %s

Add Comment
添加评论
ordinary changes
普通改动
Matching page names:

Could not find %1.html template in %2
无法在 %2 找到 %1.html 的范本
Only Editors are allowed to see this hidden page.
只有编辑才允许查看该隐藏页面
Only Admins are allowed to see this hidden page.
只有管理员才允许查看该隐藏页面
Index
索引
Languages:
语言：
Show!
显示!
Define
定义
Full Link List
完整连结列表
List of locked pages

Pages tagged with %s

Template without parameters
未指定 template 参数
The template %s is either empty or does not exist.
范本%s可能为空或不存在。
 -- defined on %s
 -- 在%s中定义
Local names defined on %1: %2
定义在%s:%2的局部变量
Locked Pages

Register for %s
为%s注册
Please choose a username of the form "FirstLast" using your real name.
请使用你的名字注册。
The passwords do not match.
两次输入的口令不一致。
The password must be at least %s characters.
口令必须只要%s个西文字母。
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
Logout
注销
Who am I?
我是谁？
Forgot your password?
忘记了口令？
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
Your password has been changed.
您的口令已修改。
Approve Pending Registrations for %s
待候审批的用户“%s”的注册信息
%s has been approved.
用户“%s”已批准。
There was an error approving %s.
批准用户%s注册信息时出错。
<ul>

<li>%1 - %2</li>

</ul>

There are no pending registrations.
无待候审批用户
Invalid Mail %s: not saved.

unsubscribe

subscribe

Email: 

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

You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.

%s is not a legal name for a namespace
%s不是一个合法的用户名，请重新设置
Namespaces

Getting page index file for %s.
自%s取得页面索引数据。
Near links:
附近连结：
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

image
图像
download
下载
Backlinks

Clearing Cache
清除缓存
Done.
结束。
Generating Link Database
产生连结数据库
The 404 handler extension requires the link data extension (links.pl).
404信息处理扩展单元需要您安装links.pl
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
您把封禁了自己的IP地址。
OpenID Login

Your identity is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.

Your homepage is set to %s.

You have no homepage set.

Homepage:

Homepage is missing

OpenID error %s

Orphan List
孤立页面列表
Trail: 
行经页面:
None
不指定
Type
类别
Permalink to "%s"
永久连结至 "%s"
anchor first defined here: %s
锚点已被定义于 %s
the page %s also exists
也存在一个叫%s的页面
There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.
生成%s的pdf时出错。请停止下载并立即汇报管理员。
Someone else is generating a pdf for %s.  Please wait a minute and then try again.
其他用户正在生成%s的pdf。请稍候一分钟后再连接。
Download this page as PDF
下载该页面的PDF文档
Click to search for references to this permanent anchor
按下即可搜索此锚点的相关数据
Include permanent anchors
包含永久锚点
Portrait
肖像
Publish %s
发表%s
No target wiki was specified in the config file.
配置文件中没有设定目标wiki
The target wiki was misconfigured.
目标wiki设置有误
You did not answer correctly.
回答不正确。
To save this page you must answer this question:
保存该页面需要正确回答以下问题：
Please type the following two words:

Please answer this captcha:

Referrers
引用者
All Referrers
所有的引用者
Tag
标签
Rebuild index for searching
重建检索索引
Tag Cloud
标签云
Search::FreeText is not available on this system.
Search::FreeText不存在
Rebuilding index not done.
重建索引尚未完成
(Rebuilding the index can only be done once every 12 hours.)
（自动重建索引间隔为12个小时。）
New Pages for Indexed Search

List changes since %s

 ... 

Search term missing.
缺少搜索项。
Result pages: 
返回结果：
(%s results)
（%s个页面）
Tags:
标签：
Tags: %s.
标签：%s。
No tags
无标签
Page list for %s

Slideshow:%s
自动放映：%s
Index of all small pages

Static Copy
静态页面备份
Back to %s
返回 %s
Copy to %1 succeeded: %2.
成功复制为%1：%2
Copy to %1 failed: %2.
无法复制为%1：%2
Feed for this tag

Rebuild tag index

list tags

tag cloud

Alternatively, use one of the following templates:
或者，使用下列范本之一:
Thread: %s
讨论主题: %s
ID parameter is missing.
未指定 ID 参数。
Thread %s does not exist.
讨论主题%s不存在。
Page %s does not contain a thread.
页面%s不包含讨论主题.
Add
加入
URL parameter is missing.
未指定 URL 参数。
Add to %s thread
加入%s讨论主题
Below:
以下:
URL:
网址:
Name:
姓名:
Too many instances.  Only %s allowed.

Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.

Contents
内容
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

This page is a translation of %s. 
本页是页面%s的翻译。
The translation is up to date.
本页翻译符合最新的内容。
The translation is outdated.
本页翻译已过期。
The page does not exist.
页面不存在。
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
另一个连结
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
搜索
Wanted Pages
悬赏页面
%s pages
%s个页面
%s, referenced from:
%s，引用自：
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
