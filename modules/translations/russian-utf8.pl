# UTF-8 encoded Russian language file for use with Oddmuse
#
# Copyright (c) 2003  Zajcev Evgeny
# Copyright (C) 2004  Andrei Bulava <abulava@users.sourceforge.net>
# Copyright (C) 2006  Igor Afanasyev <afan@mail.ru>
# Copyright (c) 2007  Alexander Uvizhev <uvizhe@yandex.ru>
# Copyright (C) 2015  Alex-Daniel Jakimenko <alex.jakimenko@gmail.com>
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
# This script was last checked for Oddmuse version 1.658.
#
use utf8;
use strict;

AddModuleDescription('russian-utf8.pl', 'Russian') if defined &AddModuleDescription;

our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.
Эта страница пуста.
Add your comment here:
Добавьте свой комментарий здесь:
Reading not allowed: user, ip, or network is blocked.
Просмотр недоступен: имя пользователя, IP-адрес или сеть заблокированы.
Login

Error
Ошибка
%s calls

Cannot create %s
Невозможно создать %s
Include normal pages

Invalid UserName %s: not saved.
Hекорректное имя пользователя %s: не сохранено.
UserName must be 50 characters or less: not saved
Имя пользователя не может содержать больше 50 символов: не сохранено
This page contains an uploaded file:
Эта страница содержит загруженный файл:
No summary was provided for this file.
Описание не было указано для этого файла.
Recursive include of %s!
Рекурсивное включение страницы %s!
Clear Cache
Очистить кэш
Main lock obtained.
Блокировка сайта установлена.
Main lock released.
Блокировка сайта снята.
Journal
Журнал
More...
Еще...
Comments on this page
Комментарии
XML::RSS is not available on this system.
XML::RSS не доступен на этом сервере.
diff
изменения
history
история
%s returned no data, or LWP::UserAgent is not available.

RSS parsing failed for %s

No items found in %s.

 . . . . 

Click to edit this page
Щелкните, чтобы править
CGI Internal error: %s
Внутренняя ошибка CGI: %s
Invalid action parameter %s
Некорректный параметр действия %s
Page name is missing
Отсутствует имя страницы
Page name is too long: %s
Слишком длинное имя страницы: %s
Invalid Page %s (must not end with .db)
Некорректная страница %s (не должна оканчиваться на .db)
Invalid Page %s (must not end with .lck)
Некорректная страница %s (не должна оканчиваться на .lck)
Invalid Page %s
Некорректная страница %s
Too many redirections
Слишком много перенаправлений
No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.

Updates since %s
Обновления с %s
up to %s

Updates in the last %s days
Обновления за последние %s дней
Updates in the last day
Обновления за последний день
for %s only
только для %s
List latest change per page only
Перечислить только последнее изменение на страницу
List all changes
Показать все изменения
Skip rollbacks
Не показывать откаты
Include rollbacks
Включая откаты
List only major changes
Показать только существенные изменения
Include minor changes
Включая несущественные изменения
%s days
%s дней
%s day
%s день
List later changes
Показать недавние изменения
RSS
RSS
RSS with pages
RSS со страницами
RSS with pages and diff
RSS со страницами изменениями
Filters
Фильтры
Title:
Заголовок:
Title and Body:
Заголовок и содержимое:
Username:
Имя пользователя:
Host:
Хост:
Follow up to:

Language:
Язык:
Go!
Вперед!
(minor)
(незначительные)
rollback
откат
new
новая
All changes for %s
Все изменения страницы %s
This page is too big to send over RSS.
Эта страница слишком велика для трансляции в RSS.
History of %s
История %s
Compare
Сравнить
Deleted
Удалено
Mark this page for deletion
Удалить эту страницу
No other revisions available
Нет других доступных версий
current
текущая
Revision %s
Версия %s
Contributors to %s
Редакторы страницы %s
Missing target for rollback.
Нет цели для отката.
Target for rollback is too far back.
Цель отката слишком далеко.
A username is required for ordinary users.

Rolling back changes
Откат изменений
Editing not allowed: %s is read-only.
Редактирование не допустимо: %s только для чтения.
Rollback of %s would restore banned content.
Откат страницы %s восстановит неразрешенный контент.
Rollback to %s
Откат до %s
%s rolled back
%s восстановлена
to %s
до %s
Index of all pages
Каталог страниц
Wiki Version
Версия Wiki
Password
Пароль
Run maintenance
Запустить процедуру техобслуживания
Unlock Wiki
Разблокировка Wiki
Unlock site
Разблокировать сайт для редактирования другими
Lock site
Блокировать сайт от редактирования другими
Unlock %s
Разблокировать %s
Lock %s
Блокировать %s
Administration
Администрирование
Actions:
Действия:
Important pages:
Служебные страницы:
To mark a page for deletion, put <strong>%s</strong> on the first line.
Чтобы пометить любую страницу к удалению, поместите <strong>%s</strong> первой строкой страницы.
from %s
с %s
redirected from %s
перенаправлено с %s
%s: 

[Home]
[Домой]
Click to search for references to this page
Щелкните для поиска ссылок на эту страницу
Cookie: 
Куки:
Edit this page
Редактировать
Preview:
Предварительный просмотр:
Preview only, not yet saved
Только предварительный просмотр - пока ничего не сохранено
Warning
Внимание
Database is stored in temporary directory %s
База данных сохранена во временной директории %s
%s seconds
%s секунд
Last edited
Редактировалось последний раз
Edited
Правленное
by %s
пользователем %s
(diff)
(изменения)
a

c

Edit revision %s of this page
Править версию %s этой страницы
e

This page is read-only
Страница только для чтения
View other revisions
История
View current revision
Смотреть текущую версию
View all changes
Смотреть все изменения
View contributors
Смотреть редакторов
Homepage URL:

s

Save
Сохранить
p

Preview
Предпросмотр
Search:
Поиск:
f

Replace:
Замена:
Delete
Удалить
Filter:
Фильтр:
Validate HTML
Провалидировать HTML
Validate CSS
Провалидировать CSS
Last edit
Поледнее изменение
Summary:
Описание:
Difference between revision %1 and %2
Отличия (версии %1 от %2)
revision %s
версии %s
current revision
текущей версии
Last major edit (%s)
Последнее значительное изменение (%s)
later minor edits
более поздние незначительные изменения
No diff available.
Функция сравнения (diff) недоступна.
Old revision:
Старая версия:
Changed:
Изменилось:
Deleted:
Удалено:
Added:
Добавлено:
to
на
Revision %s not available
Версия %s недоступна
showing current revision instead
отображение текущей версии вместо
Showing revision %s
Показ версии %s
Cannot save a nameless page.
Не могу сохранить страницу без названия.
Cannot save a page without revision.
Не могу сохранить страницу без версии.
not deleted: 
не удалена: 
deleted
удалена
Cannot open %s
Не могу открыть %s
Cannot write %s
Не могу записать %s
unlock the wiki
разблокировать вики
Could not get %s lock
Не могу получить блокировку %s
The lock was created %s.
Блокировка была создана %s.
Maybe the user running this script is no longer allowed to remove the lock directory?
Возможно пользователь, под которым запущен этот скрипт, более не может удалить lock-директорию?
This operation may take several seconds...
Эта операция может занять несколько секунд...
Forced unlock of %s lock.
Принудительный сброс блокировки %s.
No unlock required.
Разблокировка не требуется.
%s hours ago
%s часов назад
1 hour ago
1 час назад
%s minutes ago
%s минут назад
1 minute ago
1 минуту назад
%s seconds ago
%s секунд назад
1 second ago
1 секунду назад
just now
только что
Only administrators can upload files.
Только администраторы могут загружать файлы.
Editing revision %s of
Редактирование версии %s
Editing %s
Редактирование %s
Editing old revision %s.
Редактирование старой версии %s.
Saving this page will replace the latest revision with this text.
Сохранение этой страницы заменит последнюю версию на этот текст.
This change is a minor edit.
Это изменение является незначительной правкой.
Cancel
Отмена
Replace this file with text
Заменить этот файл текстом
Replace this text with a file
Заменить этот текст файлом
File to upload: 
Файл для загрузки: 
Files of type %s are not allowed.
Загрузка файлов типа "%s" не разрешена.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Ваш пароль сохраняется в куке (cookie), если поддержка кук в браузере включена. При подключении с другого компьютера, с другой учётной записи или из другого браузера вам придется вводить пароль заново.
This site does not use admin or editor passwords.
Этот сайт не использует пароли администратора или редактора.
You are currently an administrator on this site.
Сейчас вы имеете права администратора.
You are currently an editor on this site.
Сейчас вы имеете права редактора.
You are a normal user on this site.
Сейчас вы имеете права обычного пользователя.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
Ваш пароль не совпадает с паролями администратора или редактора.
Password:
Пароль:
Return to 
Вернуться на 
This operation is restricted to site editors only...
Эта операция доступна только для редакторов сайта...
This operation is restricted to administrators only...
Эта операция доступна только для администаторов сайта...
Edit Denied
Редактирование отклонено
Editing not allowed: user, ip, or network is blocked.
Редактирование не разрешено: пользователь, IP или сеть заблокированы.
Contact the wiki administrator for more information.
Свяжитесь с нашей администрацией чтоб узнать больше.
The rule %s matched for you.
Сработало правило %s.
See %s for more information.

SampleUndefinedPage
ПримерПроизвольнойСтраницы
Sample_Undefined_Page
Пример_Произвольной_Страницы
Rule "%1" matched "%2" on this page.

Reason: %s.

Reason unknown.
Причина неизвестна.
(for %s)
(%s)
%s pages found.
Найдено %s страниц
Malformed regular expression in %s
Неправильно регулярное выражение %s
Replaced: %s
Заменено: %s
Search for: %s
Искать: %s
View changes for these pages
Посмотреть изменения для этих страниц
last updated
редактировалось последний раз
by
пользователем
Transfer Error: %s

Browser reports no file info.

Browser reports no file type.

The page contains banned text.
Страница содержит запрещенный текст.
No changes to be saved.
Нечего сохранить.
This page was changed by somebody else %s.
Страница была изменена кем-то %s.
The changes conflict.  Please check the page again.
Изменения конфликтуют. Проверьте страницу снова.
Please check whether you overwrote those changes.
Пожалуйста удостоверьтесь, что вы не перезаписали чужие изменения.
Anonymous
Аноним
Cannot delete the index file %s.
Не могу удалить индекс-файл %s.
Please check the directory permissions.
Проверьте разрешения этой директории.
Your changes were not saved.
Ваши изменения не были сохранены.
Could not get a lock to merge!
Не могу получить lock для слияния страниц!
you
ваша версия
ancestor
изначально
other
чужая версия
Run Maintenance
Процедура техобслуживания
Maintenance not done.
Техобслуживание не выполнено.
(Maintenance can only be done once every 12 hours.)
(Техобслуживание может выполняться раз в 12 часов, не чаще).
Remove the "maintain" file or wait.
Удалите файл "maintain" или подождите
Expiring keep files and deleting pages marked for deletion
Удаление устаревших версий страниц и страниц, явно помеченных к удалению
Moving part of the %s log file.
Перемещаю часть лог файла %s.
Could not open %s log file
Не возможно открыть файл протокола %s
Error was
Были ошибки
Note: This error is normal if no changes have been made.
Примечание: Эта ошибка - нормально, если не было сделано изменений.
Moving %s log entries.
Перемещаю %s лог записей.
Set or Remove global edit lock
Установка или снятие глобальной блокировки на редактирование
Edit lock created.
Блокировка на редактирование установлена.
Edit lock removed.
Блокировка на редактирование снята.
Set or Remove page edit lock
Установка или снятие блокировки на редактирование данной страницы
Lock for %s created.
Блокировка на %s установлена.
Lock for %s removed.
Блокировка на %s снята.
Displaying Wiki Version
Версия Wiki
Debugging Information
Отладочная информация
Too many connections by %s
Слишком много подключений от %s
Please do not fetch more than %1 pages in %2 seconds.
Пожалйуста, не запрашивайте более %1 страниц в течение %2 секунд.
Check whether the web server can create the directory %s and whether it can create files in it.

, see 
, смотрите 
The two revisions are the same.
Заданы одинаковые версии страницы
Deleting %s
Удаляю %s
Deleted %s
%s удалена
Renaming %1 to %2.
Переименовываю %1 в %2.
The page %s does not exist
Страница %s не существует
The page %s already exists
Страница %s уже существует
Cannot rename %1 to %2
Не могу переименовать %1 в %2
Renamed to %s
Переименовано в %s
Renamed from %s
Переименовано с %s
Renamed %1 to %2.
%1 Переименовано в %2
Immediately delete %s
Немедленно удалить %s
Rename %s to:
Переименовать %s в:
Attach file:
Прикрепить файл:
Upload

Learn more...

Complete Content

The main page is %s.

Archive:
Архив:
Rebuild BackLink database

Internal Page: 
Внутренняя страница:
Pages that link to this page
Страницы ссылающиеся на эту страницу
The search parameter is missing.

Pages link to %s

Ban contributors

Ban Contributors to %s

Ban!
Заблокировать!
Regular expression:
Регулярное выражение:
%s is banned
%s забанен
These URLs were rolled back. Perhaps you want to add a regular expression to %s?

Consider banning the IP number as well: 
Также вы можете забанить IP адрес: 
Regular expression "%1" matched "%2" on this page.

Regular expression "%s" matched on this page.

Recent Visitors

some action

was here

and read

Illegal year value: Use 0001-9999
Неправильное значение года, используйте 0001-9999
The match parameter is missing.

Page Collection for %s
Страницы (%s)
Previous
Назад
Next
Вперед
Calendar %s
Календарь за %s год
Su
Вс
Mo
Пн
Tu
Вт
We
Ср
Th
Чт
Fr
Пт
Sa
Сб
January
Январь
February
Февраль
March
Март
April
Апрель
May
Май
June
Июнь
July
Июль
August
Август
September
Сентябрь
October
Октябрь
November
Ноябрь
December
Декабрь
set %s

unset %s

Clustermap
Кластеры
Pages without a Cluster
Некластеризованые страницы
Comments:
Комментарии:
Comments on 
Комментарии к 
Comment on 
Комментарий к 
Compilation for %s

Compilation tag is missing a regular expression.

Install CSS
Загрузить CSS-стиль
Copy one of the following stylesheets to %s:
Выберите один из перечисленных стилей для копирования в %s
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
Сравнение страниц
Diff
Сравнить
Recover Draft
Восстановить черновик
No text to save
Отсутствует текст для сохранения
Draft saved
Черновик сохранен
Draft recovered
Черновик восстановлен
No draft available to recover
Нет черновика для восстановления
Save Draft
Сохранить черновик
Draft Cleanup

Unable to delete draft %s
Не могу удалить черновик %s
%1 was last modified %2 and was kept

%1 was last modified %2 and was deleted

Add Comment
Комментировать
ordinary changes

Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

Matching page names:
Подходящие названия страниц:
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
Без описания
no summary available
нет описания
page was marked for deletion
страница была помечена для удаления
Oddmuse

Cleaning up git repository
Чищу git репозиторий
Google +1 Buttons

All Pages +1

This page lists the twenty last diary entries and their +1 buttons.

Email: 

Could not find %1.html template in %2

Only Editors are allowed to see this hidden page.
Только редакторы могут видеть эту скрытую страницу.
Only Admins are allowed to see this hidden page.
Только администраторы могут видеть эту скрытую страницу.
Index
Индекс
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
Повторите пароль:
Email:

Bad email address format.

Password needs to have at least %s characters.
Пароль должен содержать как минимум %s символов.
Passwords differ.
Пароли не совпадают.
Email Sent

Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.
Письмо для подтверждения было отправлено на %s. Пройдите по ссылке в письме чтобы подтвердить регистрацию.
Failed to Confirm Registration
Не получилось подтвердить регистрацию
Invalid key.
Неправильный ключ.
The key expired.
Ключ устарел.
Registration Confirmed
Регистрация подтверждена
Now, you can login by using username and password.

Forgot your password?
Забыли пароль?
Login failed.

You are banned.
Вы забанены.
You must confirm email address.

Logged in

%s has logged in.

You should set new password immediately.

Change Password
Изменить пароль
Logged out

%s has logged out.

Account Settings

Logout

Current Password:
Текущий пароль:
New Password:
Новый пароль:
Repeat New Password:
Повторить новый пароль:
Password is wrong.
Пароль неправильный.
Password Changed
Пароль изменен
Your password has been changed.
Ваш пароль был изменен.
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
%s уже заблокирован.
%s has been banned.
%s заблокирован.
%s is not banned.
%s не заблокирован.
%s has been unbanned.
%s разблокирован.
Register

Languages:
Языки:
Show!

====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define

Full Link List
Полный список ссылок
Banned Content

Rule "%1" matched on this page.

List of locked pages
Список заблокированных страних
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
Пароли не сходятся.
The password must be at least %s characters.
Пароль должен быть как минимум %s символов.
That email address is invalid.

The username %s has already been registered.
Пользователь %s уже зарегистрирован.
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
Кто я?
Change your password
Изменить пароль
Approve pending registrations

Confirm Registration for %s

%s, your registration has been approved. You can now use your password to login and edit this wiki.

Confirmation failed.  Please email %s for help.

Who Am I?
Кто я?
You are logged in as %s.

You are not logged in.

Reset Password

The password for %s was reset.  It has been emailed to the address on file.

There was an error resetting the password for %s.

The username "%s" does not exist.
Пользователь "%s" не существует.
Reset Password for %s

Reset Password?
Сбросить пароль?
Change Password for %s

Change Password?
Изменить пароль?
Your current password is incorrect.

Approve Pending Registrations for %s

%s has been approved.

There was an error approving %s.

There are no pending registrations.

Invalid Mail %s: not saved.

unsubscribe
отписаться
subscribe
подписаться
%s appears to be an invalid mail address

Your mail subscriptions

All mail subscriptions

Subscriptions
Подписки
Show

Subscriptions for %s:
Подписки на %s:
Unsubscribe
Отписаться
There are no subscriptions for %s.
Нет подписок на %s.
Change email address
Изменить email адрес
Mail addresses are linked to unsubscription links.

Subscribe to %s.
Подписаться на %s.
Subscribe
Подписаться
Subscribed %s to the following pages:
%s был подписан на следующие страницы:
The remaining pages do not exist.
Оставшиеся страницы не существуют.
Unsubscribed %s from the following pages:
%s был отписан от следующих страниц:
Migrating Subscriptions

No non-migrated email addresses found, migration not necessary.

Migrated %s rows.

Bisect modules

Module Bisect

All modules enabled now!
Все модули теперь включены!
Go back
Вернуться
Test / Always enabled / Always disabled
Проверить / Всегда включены / Всегда выключены
Start
Начать
Biscecting proccess is already active.

Stop
Остановить
It seems like module %s is causing your problem.
Судя по всему, модуль %s вызывает вашу проблему.
Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).

Good luck fixing your problem! ;)
Удачи в решении вашей проблемы! ;)
Module count (only testable modules): 
Количество модулей (только тестируемые модули):
Current module statuses:

Good
Нет проблемы
Bad
Есть проблема
Enabling %s
Включаю %s
Update modules
Обновить модули
Module Updater
Обновление модулей
Looks good. Update modules now!
Всё в порядке. Обновить модули!
You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.

%s is not a legal name for a namespace

Namespaces
Пространства имен
Getting page index file for %s.

Near links:

Search sites on the %s as well

Fetching results from %s:

Near pages:

Include near pages

EditNearLinks

The same page on other sites:
Та же страница на других сайтах:
 (create locally)

image
изображение
download
загрузить
Backlinks

Clearing Cache
Очищаю кэш.
Done.
Готово.
Generating Link Database

The 404 handler extension requires the link data extension (links.pl).

Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

LocalMap

No page id for action localmap

Requested page %s does not exist
Запрошенная страница %s не существует
Local Map for %s

view

Self-ban by %s

You have banned your own IP.
Вы заблокировали свой собственный IP.
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
Скачать эту страницу в PDF
Click to search for references to this permanent anchor

Include permanent anchors

Portrait

This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.
Эта страница защищена паролем. Если вы знаете пароль, вы можете %s. Как только вы это сделали, просто перезагрузите эту страницу.
supply the password now
указать пароль прямо сейчас
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.
Попытка прочитать зашифрованные данные без пароля.
Cannot refresh index.

Publish %s

No target wiki was specified in the config file.

The target wiki was misconfigured.

Upload is limited to %s bytes
Закрузки ограничены до %s байт
To save this page you must answer this question:
Чтобы сохранить эту страницу вы должны ответить на вопрос:
Please type the following two words:

Please answer this captcha:
Пожалуйста введите капчу:
Referrers

All Referrers

Page list for %s

Slideshow:%s

Index of all small pages

Static Copy

Back to %s
Назад к %s
Editing not allowed for %s.
Редактирование не разрешено для %s.
Edit image in the browser
Отредактировать изображение в браузере
Summary of your changes: 
Описание изменений:
Copy to %1 succeeded: %2.

Copy to %1 failed: %2.

Tag

Feed for this tag

Tag Cloud

 ... 

Rebuilding index not done.

(Rebuilding the index can only be done once every 12 hours.)

Rebuild tag index
Пересоздать индекс тегов
list tags
список тегов
tag cloud
облако тегов
Alternatively, use one of the following templates:

Too many instances.  Only %s allowed.

Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Попробуйте еще раз попозже. Возможно, кто-то запустил процедуру техобслуживания, или в процессе находится долгий поиск. К сожалению, ресурсы этого сайта ограничены, мы вынуждены попросить Вас быть терпеливыми.
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
Выберите ваш часовой пояс:
Set

Contents

Create a new page for today
Создать новую страницу для сегодняшнего дня
Add Translation
Добавить перевод
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
Эта страница является переводом %s. 
The translation is up to date.

The translation is outdated.
Это перевод устарел.
The page does not exist.
Эта страница не существует.
Upgrading Database
Обновление базы данных
Did the previous upgrade end with an error? A lock was left behind.
Lock не был удален, возможно предыдущее обновление закончилось с ошибкой?
Unlock wiki
Разблокировать вики
Upgrade complete.
Обновление заершено.
Upgrade complete. Please remove $ModuleDir/upgade.pl, now.
Обновление завершено. Пожалуйста удалите $ModuleDir/upgade.pl.
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
альтернативный
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
поиск
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
