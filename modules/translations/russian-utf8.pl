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

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Просмотр недоступен: имя пользователя, IP-адрес или сеть заблокированы.
Login
Войти в систему
Error
Ошибка
%s calls
%s вызовов
Cannot create %s
Невозможно создать %s
Include normal pages
Включая нормальные страницы
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
Либо %s не возвращает данные, либо не доступен LWP::UserAgent.
RSS parsing failed for %s
Не удалось распарсить RSS для %s
No items found in %s.
Нет записей в %s.
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
There are no comments, yet. Be the first to leave a comment!
Здесь пока нет комментариев. Не стесняйся быть первым!
Welcome!
Добро пожаловать!
This page does not exist, but you can %s.
Эта страница не существует, но вы можете %s.
create it now
создать её прямо сейчас
Too many redirections
Слишком много перенаправлений
No redirection for old revisions
Переадресация не разрешена для старых версий
Invalid link pattern for #REDIRECT
Неправильный формат ссылки для #REDIRECT
Please go on to %s.
Пожалуйста перейдите на %s.
Updates since %s
Обновления с %s
up to %s
до %s
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
days
дней
List later changes
Показать недавние изменения
RSS
RSS
RSS with pages
RSS со страницами
RSS with pages and diff
RSS со страницами изменениями
Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.

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
Ответы пользователю:
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
Using the ｢rollback｣ button on this page will reset the page to that particular point in time, undoing any later changes to this page.

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
Необходимо выставить имя пользователя.
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
Add your comment here:
Добавьте свой комментарий здесь:
Homepage URL:
Домашняя страница:
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
Last edit
Поледнее изменение
revision %s
версии %s
current revision
текущей версии
Difference between revision %1 and %2
Отличия (версии %1 от %2)
Last major edit (%s)
Последнее значительное изменение (%s)
later minor edits
более поздние незначительные изменения
No diff available.
Функция сравнения (diff) недоступна.
Summary:
Описание:
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
Could not get %s lock
Не могу получить блокировку %s
The lock was created %s.
Блокировка была создана %s.
Maybe the user running this script is no longer allowed to remove the lock directory?
Возможно пользователь, под которым запущен этот скрипт, более не может удалить lock-директорию?
Sometimes locks are left behind if a job crashes.
Иногда блокировка остается, если какое-то действие прерывается.
After ten minutes, you could try to unlock the wiki.
Через десять минут вы можете попытаться разблокировать вики.
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
У вас не выставлен пароль.
Your password does not match any of the administrator or editor passwords.
Ваш пароль не совпадает с паролями администратора или редактора.
Password:
Пароль:
Return to %s
Вернуться на %s
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
Смотрите %s чтобы узнать подробнее.
SampleUndefinedPage
ПримерПроизвольнойСтраницы
Sample_Undefined_Page
Пример_Произвольной_Страницы
Rule "%1" matched "%2" on this page.
Правило "%1" сработало на "%2" на этой странице.
Reason: %s.
Причина: %s.
Reason unknown.
Причина неизвестна.
(for %s)
(%s)
%s pages found.
Найдено %s страниц
Preview: %s
Предпросмотр: %s
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
Ошибка загрузки: %s
Browser reports no file info.
Браузер не предоставил информацию о файле.
Browser reports no file type.
Браузер не предоставил тип файла.
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
Проверье, что веб сервер может создать директорию %s, и что он может создавать в ней файлы.
, see
, смотрите
The two revisions are the same.
Заданы одинаковые версии страницы
################################################################################
# modules/admin.pl
################################################################################
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
################################################################################
# modules/advanced-uploads.pl
################################################################################
Attach file:
Прикрепить файл:
Upload
Загрузить
################################################################################
# modules/aggregate.pl
################################################################################
Learn more...
Читать далее...
################################################################################
# modules/all.pl
################################################################################
Complete Content
Полное содержаниe
The main page is %s.
Главная страница – %s.
################################################################################
# modules/archive.pl
################################################################################
Archive:
Архив:
################################################################################
# modules/backlinkage.pl
################################################################################
Rebuild BackLink database
Пересоздать базу данных обратных ссылок
Internal Page: %s
Внутренняя страница: %s
Pages that link to this page
Страницы ссылающиеся на эту страницу
################################################################################
# modules/backlinks.pl
################################################################################
The search parameter is missing.
Отсутствует параметр для поиска.
Pages link to %s
Страницы, ссылающиеся на %s
################################################################################
# modules/ban-contributors.pl
################################################################################
Ban contributors
Заблокировать пользователей
Ban Contributors to %s
Заблокировать пользователей, редактировавших %s
Ban!
Заблокировать!
Regular expression:
Регулярное выражение:
%s is banned
%s забанен
These URLs were rolled back. Perhaps you want to add a regular expression to %s?
Во время отката были убраны эти ссылки. Возможно вы хотите добавить регулярное выражения для %s?
Consider banning the IP number as well:
Также вы можете забанить IP адрес:
################################################################################
# modules/banned-regexps.pl
################################################################################
Regular expression "%1" matched "%2" on this page.
Регулярное выражение "%1" сработало на "%2" на этой странице.
Regular expression "%s" matched on this page.
Регулярное выражение "%s" сработало на этой странице.
################################################################################
# modules/big-brother.pl
################################################################################
Recent Visitors
Последние посетители
some action

was here
был здесь
and read
и читал
################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999
Неправильное значение года, используйте 0001-9999
The match parameter is missing.
Отсутствует параметр match.
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
################################################################################
# modules/checkbox.pl
################################################################################
set %s
отметил %s
unset %s
убрал отметку %s
################################################################################
# modules/clustermap.pl
################################################################################
Clustermap
Кластеры
Pages without a Cluster
Некластеризованые страницы
################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:
Комментарии:
################################################################################
# modules/commentcount.pl
################################################################################
Comments on
Комментарии к
Comment on
Комментарий к
################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s

Compilation tag is missing a regular expression.

################################################################################
# modules/creationdate.pl
################################################################################
Add creation date to page files

################################################################################
# modules/css-install.pl
################################################################################
Install CSS
Загрузить CSS-стиль
Copy one of the following stylesheets to %s:
Выберите один из перечисленных стилей для копирования в %s
Reset
Сбросить
################################################################################
# modules/dates.pl
################################################################################
Extract all dates from the database
Обновить базу данных дат
Dates
Даты
No dates found.
Дат не найдено.
################################################################################
# modules/despam.pl
################################################################################
List spammed pages
Показать страницы со спамом
Despamming pages
Удаление спама
Spammed pages
Страницы со спамом
Cannot find revision %s.
Невозможно найти версию %s.
Revert to revision %1: %2
Откат до версии %1: %2
Marked as %s.
Помечено как %s.
Cannot find unspammed revision.
Не могу найти версию без спама.
################################################################################
# modules/diff.pl
################################################################################
Page diff
Сравнение страниц
Diff
Сравнить
################################################################################
# modules/drafts.pl
################################################################################
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
Очищение черновиков
Unable to delete draft %s
Не могу удалить черновик %s
%1 was last modified %2 and was kept
%1 был изменен %2 и был оставлен
%1 was last modified %2 and was deleted
%1 был изменен %2 и был удален
################################################################################
# modules/dynamic-comments.pl
################################################################################
Add Comment
Комментировать
################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes
обычные изменения
%s days
%s дней
################################################################################
# modules/edit-paragraphs.pl
################################################################################
Could not identify the paragraph you were editing
Не получилось определить параграф, который вы редактировали
This is the section you edited:
Это часть, которую вы отредактировали:
This is the current page:
Это текущая страница:
################################################################################
# modules/find.pl
################################################################################
Matching page names:
Подходящие названия страниц:
################################################################################
# modules/fix-encoding.pl
################################################################################
Fix character encoding
Исправить проблемы с кодировкой
Fix HTML escapes

################################################################################
# modules/form_timeout.pl
################################################################################
Set $FormTimeoutSalt.
Установить $FormTimeoutSalt.
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
Вы неправильно ответили на вопрос.
$GdSecurityImageFont is not set.
Переменная $GdSecurityImageFont не установлена.
################################################################################
# modules/git-another.pl
################################################################################
No summary provided
Без описания
################################################################################
# modules/git.pl
################################################################################
no summary available
нет описания
page was marked for deletion
страница была помечена для удаления
Oddmuse
Oddmuse
Cleaning up git repository
Чищу git репозиторий
################################################################################
# modules/google-plus-one.pl
################################################################################
Google +1 Buttons
Кнопки Google +1
All Pages +1

This page lists the twenty last diary entries and their +1 buttons.
На этой странице виден список двадцати записей в дневнике и их +1 кнопки.
################################################################################
# modules/gravatar.pl
################################################################################
Email:
Email:
################################################################################
# modules/header-and-footer-templates.pl
################################################################################
Could not find %1.html template in %2
Не удалось найти шаблон %1.html в %2
################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.
Только редакторы могут видеть эту скрытую страницу.
Only Admins are allowed to see this hidden page.
Только администраторы могут видеть эту скрытую страницу.
################################################################################
# modules/index.pl
################################################################################
Index
Индекс
################################################################################
# modules/joiner.pl
################################################################################
The username %s already exists.
Пользователь %s уже существует.
The email address %s has already been used.
Email адрес %s уже существует.
Wait %s minutes before try again.
Подождите %s минут прежде чем попробовать еще раз.
Registration Confirmation
Подтверждение регистрации
Visit the link below to confirm registration.
Пройдите по этой ссылке чтобы подтвердить регистрацию.
Recover Account
Восстановить аккаунт
You can login by following the link below. Then set new password.
Вы можете войти пройдя по ссылке ниже. Там выставьте новый пароль.
Change Email Address
Поменять email адрес
To confirm changing email address, follow the link below.
Чтобы подтвердить изменение email адреса, пройдите по ссылке.
To submit this form you must answer this question:
Чтобы пройти эту форму вы должны ответить вопрос:
Question:
Вопрос:
CAPTCHA:

Registration
Регистрация
The username must be valid page name.
Имя пользователя должно быть валидным названием страницы.
Confirmation email will be sent to the email address.
Информация для подтверждения будет выслана на email.
Repeat Password:
Повторите пароль:
Bad email address format.
Плохой формат email адреса.
Password needs to have at least %s characters.
Пароль должен содержать как минимум %s символов.
Passwords differ.
Пароли не совпадают.
Email Sent
Сообщение отправлено
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
Теперь вы можете зайти используя логин и пароль.
Forgot your password?
Забыли пароль?
Login failed.
Вход не удался.
You are banned.
Вы забанены.
You must confirm email address.
Вы должны подтвердить email адрес.
Logged in

%s has logged in.

You should set new password immediately.
Вы должны установить новый пароль.
Change Password
Изменить пароль
Logged out

%s has logged out.

Account Settings
Настройки аккаунта
Logout
Выйти
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
Восстановление пароля
Enter email address, and recovery login ticket will be sent.
Впишите свой email и вам будет отправлено сообщение для восстановления.
Not found.

The mail address is not valid anymore.
Этот email адрес больше не является валидным.
An email has been sent to %s with further instructions.
Письмо с дальнейшими инструкциями было отправлено на %s.
New Email Address:
Новый Email адрес
Failed to load account.
Не удалось загрузить аккаунт.
An email has been sent to %s with a login ticket.

Confirmation Failed
Подтверждение не удалось.
Failed to confirm.
Не удалось подтвердить email адрес.
Email Address Changed
Email адрес изменен
Email address for %1 has been changed to %2.
Email адрес для %1 был изменен на %2.
Account Management

Ban Account
Заблокировать аккуант
Enter username of the account to ban:
Введите имя пользователя, которого вы хотите забанить:
Ban
Забанить
Enter username of the account to unban:
Введите имя пользователя, которого вы хотите разбанить:
Unban
Разбанить
%s is already banned.
%s уже заблокирован.
%s has been banned.
%s заблокирован.
%s is not banned.
%s не заблокирован.
%s has been unbanned.
%s разблокирован.
Register
Зарегистрироваться
################################################################################
# modules/lang.pl
################################################################################
Languages:
Языки:
Show!

################################################################################
# modules/like.pl
################################################################################
====(\d+) persons? liked this====
====Понравилось (\d+) (?:человеку|людям)====
====%d persons liked this====
====Понравилось %d людям====
====1 person liked this====
====Понравилось 1 человеку====
I like this!
Мне нравится!
################################################################################
# modules/link-all.pl
################################################################################
Define

################################################################################
# modules/links.pl
################################################################################
Full Link List
Полный список ссылок
################################################################################
# modules/list-banned-content.pl
################################################################################
Banned Content
Заблокированный контент
Rule "%1" matched on this page.
Правило "%1" сработало на этой странице.
################################################################################
# modules/listlocked.pl
################################################################################
List of locked pages
Список заблокированных страних
################################################################################
# modules/listtags.pl
################################################################################
Pages tagged with %s
Страницы с тегом %s
################################################################################
# modules/live-templates.pl
################################################################################
Template without parameters
Шаблоны без параметров
The template %s is either empty or does not exist.
Шаблон %s пуст или не существует.
################################################################################
# modules/localnames.pl
################################################################################
Name:
Имя:
URL:
Ссылка:
Define Local Names

Define external redirect:

 -- defined on %s

Local names defined on %1: %2

################################################################################
# modules/logbannedcontent.pl
################################################################################
IP number matched %s
Правило %s сработало на IP адрес
################################################################################
# modules/login.pl
################################################################################
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
Пожалуйста подождите, пока вебмастер подтвердит вашу заявку.
An email has been sent to "%s" with further instructions.
Письмо с дальнейшими инструкциями было отправлено на "%s".
There was an error saving your registration.
Произошла ошибка при сохранении вашей регистрации.
An account was created for %s.
Аккаунт %s был создан.
Login to %s

Username and/or password are incorrect.
Имя пользователя или пароль не верны.
Logged in as %s.

Logout of %s

Logout of %s?

Logged out of %s

You are now logged out.

Register a new account
Создать новый аккаунт
Who am I?
Кто я?
Change your password
Изменить пароль
Approve pending registrations

Confirm Registration for %s
Подтверждение регистрации для %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.

Confirmation failed.  Please email %s for help.
Подтверждение не удалось.  Пожалуйста напишите письмо на адрес %s для получения помощи.
Who Am I?
Кто я?
You are logged in as %s.

You are not logged in.

Reset Password
Сбросить пароль
The password for %s was reset.  It has been emailed to the address on file.

There was an error resetting the password for %s.
Произошла ошибка при сбросе пароля для %s.
The username "%s" does not exist.
Пользователь "%s" не существует.
Reset Password for %s
Сбросить пароль для %s
Reset Password?
Сбросить пароль?
Change Password for %s

Change Password?
Изменить пароль?
Your current password is incorrect.

Approve Pending Registrations for %s

%s has been approved.

There was an error approving %s.
Произошла ошибка при подтверждении %s.
There are no pending registrations.

################################################################################
# modules/mail.pl
################################################################################
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
Email: 

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

################################################################################
# modules/module-bisect.pl
################################################################################
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
Bisecting proccess is already active.

Stop
Остановить
It seems like module %s is causing your problem.
Судя по всему, модуль %s вызывает вашу проблему.
Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).
Пожалуйста учитывайте, что этот модуль не может определить проблему, если она вызвана несколькими модулями одновременно (это довольно редкий случай).
Good luck fixing your problem! ;)
Удачи в решении вашей проблемы! ;)
Module count (only testable modules):
Количество модулей (только тестируемые модули):
Current module statuses:
Текущий статус модулей:
Good
Нет проблемы
Bad
Есть проблема
Enabling %s
Включаю %s
################################################################################
# modules/module-updater.pl
################################################################################
Update modules
Обновить модули
Module Updater
Обновление модулей
Looks good. Update modules now!
Всё в порядке. Обновить модули!
################################################################################
# modules/multi-url-spam-block.pl
################################################################################
You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.
Вы использовали больше чем %s ссылок на один и тот же домен. Обычно так делают только спаммеры. Ваше изменение отклонено.
################################################################################
# modules/namespaces.pl
################################################################################
%s is not a legal name for a namespace
%s не является разрешенным именем для пространства имен
Namespaces
Пространства имен
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
Та же страница на других сайтах:
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)

################################################################################
# modules/no-question-mark.pl
################################################################################
image
изображение
download
загрузить
################################################################################
# modules/nosearch.pl
################################################################################
Backlinks
Обратные ссылки
################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache
Очищаю кэш.
Done.
Готово.
Generating Link Database
Сгенерировать индекс ссылок
The 404 handler extension requires the link data extension (links.pl).

################################################################################
# modules/offline.pl
################################################################################
Make available offline
Сделать доступным офлайн
Offline
Офлайн
You are currently offline and what you requested is not part of the offline application. You need to be online to do this.
В данный момент вы просматриваете офлайновую версию и то, что вы запросили, не доступно. Вам нужно быть онлайн чтобы сделать это.
################################################################################
# modules/olocalmap.pl
################################################################################
LocalMap

No page id for action localmap

Requested page %s does not exist
Запрошенная страница %s не существует
Local Map for %s

view

################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s

You have banned your own IP.
Вы заблокировали свой собственный IP.
################################################################################
# modules/orphans.pl
################################################################################
Orphan List
Список страниц-сирот
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
След:
################################################################################
# modules/page-type.pl
################################################################################
None

Type
Тип
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"

anchor first defined here: %s
Якорь впервые объявлен здесь: %s
the page %s also exists
также существует страница %s
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Нажмите чтобы посмотреть все ссылки на этот якорь
Include permanent anchors
Включая якоря
################################################################################
# modules/portrait-support.pl
################################################################################
Portrait

################################################################################
# modules/preview.pl
################################################################################
Pages with changed HTML
Страницы с измененным HTML
Preview changes in HTML output
Посмотреть изменения в HTML
################################################################################
# modules/private-pages.pl
################################################################################
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.
Эта страница защищена паролем. Если вы знаете пароль, вы можете %s. Как только вы это сделали, просто перезагрузите эту страницу.
supply the password now
указать пароль прямо сейчас
################################################################################
# modules/private-wiki.pl
################################################################################
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.
Попытка прочитать зашифрованные данные без пароля.
Cannot refresh index.
Невозможно обновить индекс.
################################################################################
# modules/publish.pl
################################################################################
Publish %s
Опубликовать %s
No target wiki was specified in the config file.
Целевая вики не указана в файле конфигурации.
The target wiki was misconfigured.
Целевая вики настроена неправильно.
################################################################################
# modules/put.pl
################################################################################
Upload is limited to %s bytes
Закрузки ограничены до %s байт
################################################################################
# modules/questionasker.pl
################################################################################
To save this page you must answer this question:
Чтобы сохранить эту страницу вы должны ответить на вопрос:
################################################################################
# modules/recaptcha.pl
################################################################################
Please type the following two words:
Пожалуйства введите эти слова:
Please answer this captcha:
Пожалуйста введите капчу:
################################################################################
# modules/referrer-rss.pl
################################################################################
Referrers
Ссылающиеся
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Все ссылающиеся
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s
Список страниц для %s
################################################################################
# modules/small.pl
################################################################################
Index of all small pages
Индекс маленьких страниц
################################################################################
# modules/sort.pl
################################################################################
Sort alphabetically

Sorted alphabetically

Sorted by last update first

Sort by last update

Sorted by creation date

Sort by creation date

################################################################################
# modules/static-copy.pl
################################################################################
Static Copy

Back to %s
Назад к %s
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Редактирование не разрешено для %s.
################################################################################
# modules/svg-edit.pl
################################################################################
Edit image in the browser
Отредактировать изображение в браузере
Summary of your changes:
Описание изменений:
################################################################################
# modules/sync.pl
################################################################################
Copy to %1 succeeded: %2.
Копирование на %1 удалось: %2.
Copy to %1 failed: %2.
Копирование на %1 не удалось: %2.
################################################################################
# modules/tags.pl
################################################################################
Tag
Тег
Feed for this tag
Лента для этого тега
Tag Cloud
Облако тегов
Rebuilding index not done.
Индекс не был пересоздан.
(Rebuilding the index can only be done once every 12 hours.)
(Пересоздание индекса может быть сделано только каждые 12 часов)
Rebuild tag index
Пересоздать индекс тегов
list tags
список тегов
tag cloud
облако тегов
################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Вы также можете воспользоваться одним из этих шаблонов:
################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.
Слишком много одновременных запросов.  Разрешено только %s.
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Попробуйте еще раз попозже. Возможно, кто-то запустил процедуру техобслуживания, или в процессе находится долгий поиск. К сожалению, ресурсы этого сайта ограничены, мы вынуждены попросить Вас быть терпеливыми.
################################################################################
# modules/thumbs.pl
################################################################################
thumb
миниатюра
Error creating thumbnail from nonexisting page %s.
Ошибка создания миниатюры из несуществующей страницы %s.
Can not create thumbnail for file type %s.
Невозможно создать миниатюру для файла типа %s.
Can not create thumbnail for a text document
Невозможно создать миниатюру для текстового документа.
Can not create path for thumbnail - %s
Невозможно создать папку для миниатюры - %s
Could not open %s for writing whilst trying to save image before creating thumbnail. Check write permissions.
Во время записи изображения невозможно было открыть %s для записи. Проверьте права на запись.
Failed to run %1 to create thumbnail: %2
Невозможно запустить %1 для создания миниатюры: %2
%s ran into an error
Произошла ошибка во время запуска %s
%s produced no output
%s не вернул результата
Failed to parse %s.
Невозможно распарсить %s.
################################################################################
# modules/timezone.pl
################################################################################
Timezone
Часовой пояс
Pick your timezone:
Выберите ваш часовой пояс:
Set
Установить
################################################################################
# modules/toc-headers.pl
################################################################################
Contents
Содержашие
################################################################################
# modules/today.pl
################################################################################
Create a new page for today
Создать новую страницу для сегодняшнего дня
################################################################################
# modules/translation-links.pl
################################################################################
Add Translation
Добавить перевод
Added translation: %1 (%2)
Добавлен перевод: %1 (%2)
Translate %s
Перевести %s
Thank you for writing a translation of %s.
Спасибо за написание перевода для %s.
Please indicate what language you will be using.
Пожалуйста укажите язык перевода.
Language is missing
Такой язык отсутствует
Suggested languages:
Возможные языки:
Please indicate a page name for the translation of %s.
Пожалуйста укажите имя страницы для перевода %s.
More help may be available here: %s.
Помощь по переводам находится здесь: %s.
Translated page:
Переведенная страница:
Please provide a different page name for the translation.
Пожалуйста укажите другое имя страницы для перевода.
################################################################################
# modules/translations.pl
################################################################################
This page is a translation of %s.
Эта страница является переводом %s.
The translation is up to date.
Этот перевод актуален.
The translation is outdated.
Этот перевод устарел.
The page does not exist.
Эта страница не существует.
################################################################################
# modules/upgrade.pl
################################################################################
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
################################################################################
# modules/usemod.pl
################################################################################
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
альтернативный
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
поиск
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
Офлайн просмотр
################################################################################
# modules/webdav.pl
################################################################################
Upload of %s file

################################################################################
# modules/weblog-1.pl
################################################################################
Blog
Блог
################################################################################
# modules/weblog-3.pl
################################################################################
Matching pages:

New

Edit %s.
Редактировать %s.
################################################################################
# modules/weblog-4.pl
################################################################################
Tags:
Теги:
#
END_OF_TRANSLATION
