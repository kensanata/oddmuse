# UTF-8 encoded Simplified Chinese language file for use with Oddmuse
#
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
$ModulesDescription .= '<p>$Id: chinese_cn-utf8.pl,v 1.2 2005/07/02 14:33:06 as Exp $</p>';
%Translate = split('\n',<<END_OF_TRANSLATION);
Reading not allowed: user, ip, or network is blocked.
禁止读取：使用者、ip 或是网路已被禁止连线。
Could not create %s
无法建立 %s
Invalid UserName %s: not saved.
无法储存。无效的使用者名称 %s
UserName must be 50 characters or less: not saved
无法储存。使用者名称不可超过 50 个字符。
This page contains an uploaded file:
本页包含一个已上传的文件：
XML::RSS is not available on this system.
本系统无法使用 XML::RSS 。
diff
差异
history
历史记录
%s returned no data, or LWP::UserAgent is not available.
%s 未返回数据，或是 LWP::UserAgent 无法使用。
RSS parsing failed for %s
%s 的 RSS 解析失败
No items found in %s.
在 %s 中未发现项目。
 . . . . 

Click to edit this page
按此即可编辑此页面
image
图像
download
下载
CGI Internal error: %s

Invalid action parameter %s
无效的动作参数 %s
Invalid URL.
无效的 URL 。
Page name is missing
页面不存在
Page name is too long: %s
页面名称太长了： %s
Invalid Page %s
无效的页面名称 %s
Invalid Page %s (must not end with .db)
无效的页面名称 %s (不可使用 .db 做为结尾)
Invalid Page %s (must not end with .lck)
无效的页面名称 %s (不可使用 .lck 做为结尾)
Page name may not contain space characters: %s
页面名称不可包含空白字符： %s
Preview:
预览：
Preview only, not yet saved
现在是预览模式，尚未储存
Please go on to %s.
请继续前住 %s 。
Could not open %s log file
无法打开日志文件 %s
Error was
错误是
Note: This error is normal if no changes have been made.
如果还没有做过任何修改的话，则不用理会这个错误讯息。
Could not open old %s log file
无法打开旧的 %s 日志文件
No updates since %s
自 %s 以来没有修改
Updates since %s
自 %s 以来的修改
Updates in the last %s days
在 %s 天之内的更动
Updates in the last %s day
在 %s 天之内的更动
for %s only
只列出 %s
List latest change per page only
只列出每个页面最新的修改
List all changes
列出所有的修改
List only major changes
只列出主要的修改
Include minor changes
也显示次要的修改
%s days
%s 天
List later changes
列出最新的修改
Filters
过滤器
Username:
使用者名称：
Host:
来源主机：
Language:
语文：
Go!
开始！
(minor)
(次要的)
rollback
恢复
new
新增
from %s
自 %s
History of %s
%s 的历史记录
Compare
比较
Revision %s
第 %s 版本
by
由
Rolling back changes
恢复修改
Missing target for rollback.
找不到要恢复的目标
Target for rollback is too far back.
要恢复的目标过于久远。
Rollback to %s
恢复至 %s
%s rolled back
%s 已恢复
Index of all pages
所有页面的索引
Wiki Version
显示 Wiki 的版本
Unlock Wiki
解锁
Recent Visitors
最近的访问者
Password
密码
Run maintenance
执行维护动作
Unlock site
网站解锁
Lock site
网站锁定
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
自 %s 重定向 
Click to search for references to this page
按下即可以搜索参考至本页的数据
Cookie: 

Warning
警告
Database is stored in temporary directory %s
数据库现在是存放于临时目录 %s
%s seconds
%s 秒
The same page on other sites:
其他网站的相同页面
EditNearLinks
编辑相邻链接
Last edited
最后编辑于
Edited
编辑
by %s
由 %s
(diff)
(比较差异)
Edit revision %s of this page
编辑本页的第 %s 版本
Edit this page
编辑本页
e

This page is read-only
本页是只读的
View other revisions
参阅其他版本
View current revision
参阅目前版本
View all changes
列出所有的修改
Homepage URL:
首页网址：
s

Save
储存
Preview
预览
Search:
搜索：
f

Replace:
取代：
Validate HTML
验证 HTML
Validate CSS
验证 CSS
Difference (from revision %1 to %2)
差异（从第 %1 版到%2）
revision %s
第 %s 版
current revision
目前的版本
Difference (from prior %s revision)
差异（从先前的第 %s 版本）
major
主要
minor
次要
No diff available.
没有差异。
Old revision:
旧版本：
Changed:
修改：
Removed:
删除：
Added:
增加：
to
至
Revision %s not available
不存在第 %s 版
showing current revision instead
显示最新的版本
Showing revision %s
显示第 %s 版
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
无法取得 %s 锁定
This operation may take several seconds...
这个动作可能要花几秒…
Forced unlock of %s lock.
强制解开 %s 锁定。
No unlock required.
不需要解锁。
%s hours ago
%s 小时前
1 hour ago
1 小时前
%s minutes ago
%s 分钟前
1 minute ago
1 分钟前
%s seconds ago
%s 秒前
1 second ago
1 秒前
just now
就是现在
Editing Denied
禁止编辑
Editing not allowed: user, ip, or network is blocked.
禁止编辑；使用者、ip 或是网路已被禁止连线。
Contact the wiki administrator for more information.
请通知 wiki 管理者，以取得更多的信息。
The rule %s matched for you.
你符合的规则： %s 。
See %s for more information.
请参阅 %s 以取得更多信息。
Editing not allowed: %s is read-only.
不允许编辑； %s 是只读的
Only administrators can upload files.
只有管理者可以上传文件。
Editing revision %s of
正在编辑第 %s 版的
Editing %s
正在编辑 %s
Editing old revision %s.
正在编辑旧的第 %s 版。
Saving this page will replace the latest revision with this text.
如果储存的话，将会取代目前最新的版本。
Summary:
摘要：
This change is a minor edit.
这次的修改是次要的。
Replace this file with text.
用文字来取代本档。
Replace this text with a file.
用文件来取代本文。
File to upload: 
要上传的文件：
Files of type %s are not allowed.
不允许 %s 类型的文件。
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
Rule "%1" matched "%2" on this page.
本页的 "%2" 符合规则 "%1"。
Without normal pages
不包含普通页面
Include normal pages
包含普通页面
Without permanent anchors
不包含永久锚点
Include permanent anchors
包含永久锚点
Without near pages
不包含相邻页面
Include near pages
包含相邻页面
(for %s)
(列出 %s )
%s pages found.
找到 %s 个页面。
Replaced: %s
取代：%s
Search for: %s
搜索：%s
View changes for these pages
参阅这些页面的更动
Search sites on the %s as well
也搜索列在 %s 上的网站
and
和
or
或
Fetching results from %s:
由 %s 取回的结果：
Near pages:
相邻页面：
last updated
最后更新于
Complete Content
完整内容
The main page is %s.
首页是 %s 。
Comments on this page
对本页发表评论
Editing not allowed for %s.
不允许编辑 %s 。
SampleUndefinedPage

%s cannot be defined.
无法指定 %s 为页面名称。
Sample_Undefined_Page

[[%s]] cannot be defined.
无法指定 [[%s]] 为页面名称。
Only an administrator can create %s.
只有管理者可以建立 %s 。
Transfer Error: %s
传输错误：%s
Browser reports no file info.
浏览器没有提供文件信息。
Browser reports no file type.
浏览器没有提供文件类型。
Edit Denied
禁止编辑
The page contains banned text.
本页含有一些禁止出现的文字。
This page was changed by somebody else %s.
本页在 %s 已被人修改过。
The changes conflict.  Please check the page again.
你的修改和他人发生冲突。请再次确认。
Please check whether you overwrote those changes.
请确认一下是否你要覆盖这些修改。
Anonymous
匿名者
Cannot delete the index file %s.
无法删除索引档 %s 。
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
Main lock obtained.
取得主要锁定。
Expiring keep files and deleting pages marked for deletion
清除过期的库存档和删除已标记的文件
not deleted: 
未删除：
deleted
已删除
Moving part of the %s log file.
移除部分在 %s 日志文件中的数据。
Moving %s log entries.
移除了 %s 个记录项目。
Getting page index file for %s.
自 %s 取得页面索引数据。
Main lock released.
释放主要锁定。
Set or Remove global edit lock
设定或移除整个网站的编辑锁定
Edit lock created.
建立编辑锁定。
Edit lock removed.
移除编辑锁定。
Set or Remove page edit lock
设定或移除页面的编辑锁定
Missing page id to lock/unlock...
没有指定要锁定/解锁的页面名称 (id)...
Lock for %s created.
已建立 %s 的锁定。
Lock for %s removed.
已移除 %s 的锁定。
Displaying Wiki Version
显示 Wiki 版本
Show dependencies
显示依赖关系
Inter links:
内部连结：
Near links:
附近连结：
Show parsed link data
显示特殊连结设定
Too many connections by %s
太多来自 %s 的连线
Please do not fetch more than %1 pages in %2 seconds.
请不要在 %2 秒内下载超过 %1 页的数据。
Check whether the web server can create the directory %s and whether it can create files in it.
请确认网站服务器是否可建立 %s 目录，并且在其中建立文件。
anchor first defined here: %s
锚点已被定义于 %s
Click to search for references to this permanent anchor
按下即可搜索此锚点的相关数据
the page %s also exists
也存在一个叫 %s 的页面
Deleting %s
正在删除 %s
Deleted %s
已删除 %s
Renaming %1 to %2.
正将 %1 更名为 %2 。
The page %s does not exist
页面 %s 不存在
The page %s already exists
页面 %s 已存在
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
将 %s 重命名为:
Cannot highlight the language %s.
无法高亮显示语言 %s 。
Missing one of cal(1), Date::Calc(3), or Date::Pcalc(3) to produce the calendar.
缺少下列之一的工具以致无法产生日历: cal(1), Date::Calc(3), 或 Date::Pcalc(3)
The match parameter is missing.
未指定 match 参数。
Page Collection for %s
%s 的页面集合
Previous
向前
Next
向后
Calendar %s
%s 年历
Clustermap

Pages without a Cluster

Comments on 
评论关于
Comment on 
评论关于
Compilation for %s
%s 的汇编
Compilation tag is missing a regular expression.
汇编标志缺少一个正规表达式。
Despamming pages
正在去除 spam 页面
Cannot find revision %s.
无法取得版本 %s 。
Revert to revision %1: %2
恢复至版本 %1: %2 
Marked as %s.
标记为 %s 。
Cannot find unspammed revision.
找不到未被 spam 的版本。
Footnotes:
注解：
Could not find %1.html template in %2
无法在 %2 找到 %1.html 的范本
image: %s
图像: %s
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
Template without parameters
未指定 template 参数
The template %s is either empty or does not exist.
范本 %s 可能为空或不存在。
Register for %s

Please choose a username of the form "FirstLast" using your real name.

The passwords do not match.

The password must be at least %s characters.

That email address is invalid.

The username %s has already been registered.

Your registration for %s has been submitted.

  Please allow time for the webmaster to approve your request.

An account was created for %s.

Login to %s

Username and/or password are incorrect.

Logged in as %s.

Logout of %s

Logout of %s?

Logged out of %s

You are now logged out.

Register a new account

Login

Logout

Clearing Cache
清除缓存
Done.
结束。
Generating Link Database
产生连结数据库
The 404 handler extension requires the link data extension (links.pl).

LocalMap

No page id for action localmap

Requested page %s does not exist

Local Map for %s

view

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
Portrait
肖像
You did not answer correctly.
回答不正确。
All Referrers
所有的引用者
Referrers
引用者
Rebuild index for searching

Rebuilding Index

Search::FreeText is not available on this system.

Rebuilding index not done.

(Rebuilding the index can only be done once every 12 hours.)

Search term missing.
缺少搜索项。
Result pages: 

(%s results)

Slideshow:%s

Static Copy
静态页面备份
Back to %s
返回 %s
Tag

Alternatively, use one of the following templates:
或者，使用下列范本之一:
Thread: %s
讨论主题: %s
ID parameter is missing.
未指定 ID 参数。
Thread %s does not exist.
讨论主题 %s 不存在。
Page %s does not contain a thread.
页面 %s 不包含讨论主题.
Add
加入
URL parameter is missing.
未指定 URL 参数。
Add to %s thread
加入 %s 讨论主题
Below:
以下:
URL:
网址:
Name:
姓名:
Failed to remove %s
无法移除 %s
Contents
内容
This page is a translation of %s. 
本页是页面 %s 的翻译。
The translation is up to date.
本页翻译符合最新的内容。
The translation is outdated.
本页翻译已过期。
The page does not exist.
页面不存在。
http://shop.barnesandnoble.com/bookSearch/isbnInquiry.asp?isbn=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
另一个连结
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
搜索
Blog

END_OF_TRANSLATION
