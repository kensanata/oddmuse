# UTF-8 encoded Portuguese European language file for use with Oddmuse
#
# Portuguese European version by Guida Querido <guida@querido.net>
# and Paulo Querido <correio@pauloquerido.com> September 2005
# based on the Brazilian Portuguese version
# Copyright (c) 2003  Marcelo Toledo <rw@locked.org>.
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
# This translation was last checked for Oddmuse version 1.195.
#
use utf8;
use strict;

AddModuleDescription('portuguese-utf8.pl', 'Portuguese') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Leitura não permitida: utilizador, ip, ou rede está bloqueado(a).
Login
Entrar
Error

%s calls

Cannot create %s
Impossível criar %s
Include normal pages
Incluir páginas normais
Invalid UserName %s: not saved.
NomeUtilizador inválido %s: nada salvo.
UserName must be 50 characters or less: not saved
NomeUtilizador deve ter 50 caracteres ou menos: nada salvo
This page contains an uploaded file:
Esta página contém um ficheiro enviado:
No summary was provided for this file.

Recursive include of %s!

Clear Cache

Main lock obtained.
Bloqueio principal efectuado.
Main lock released.
Bloqueio principal libertado.
Journal

More...

Comments on this page
Comentários sobre esta página
XML::RSS is not available on this system.
XML::RSS não existe neste sistema
diff
diferenças
history
história
%s returned no data, or LWP::UserAgent is not available.
%não devolveu quaisquer dados, ou LWP::UserAgent não está disponível.
RSS parsing failed for %s
O parsing de RSS para %s falhou.
No items found in %s.
Não foram encontrados itens em %s.
 . . . .

Click to edit this page
Clique para editar esta página
CGI Internal error: %s
Erro interno CGI: %s
Invalid action parameter %s
Parametro %s de acção inválido
Page name is missing
Falta o nome da página
Page name is too long: %s
Nome de página é muito longo: %s
Invalid Page %s (must not end with .db)
Página %s inválida (não pode terminar com .db)
Invalid Page %s (must not end with .lck)
Página %s inválida (não pode terminar com .lck)
Invalid Page %s
Página %s inválida
There are no comments, yet. Be the first to leave a comment!

Welcome!

This page does not exist, but you can %s.

create it now

Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
Por favor vá para %s
Updates since %s
Actualizações desde %s
up to %s

Updates in the last %s days
Actualizações nos últimos %s dias
Updates in the last day
Actualizações no último dia
for %s only
para %s apenas
List latest change per page only
Mostrar só as últimas modificações por página
List all changes
Mostrar todas as modificações
Skip rollbacks

Include rollbacks

List only major changes
Mostrar só as modificações maiores
Include minor changes
Incluir também as modificações menores
days

List later changes
Mostrar modificações recentes
RSS

RSS with pages

RSS with pages and diff

Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.

Filters
Filtros
Title:

Title and Body:

Username:
Utilizador:
Host:

Follow up to:

Language:
Língua:
Go!
Ir!
(minor)
(mínima)
rollback

new
novo
All changes for %s

This page is too big to send over RSS.

History of %s
Histórico de %s
Using the ｢rollback｣ button on this page will reset the page to that particular point in time, undoing any later changes to this page.

Compare
Comparar
Deleted

Mark this page for deletion

No other revisions available

current

Revision %s
Revisão %s
Contributors to %s

Missing target for rollback.

Target for rollback is too far back.

A username is required for ordinary users.

Rolling back changes

Editing not allowed: %s is read-only.
Edição não permitida: %s é apenas para leitura.
Rollback of %s would restore banned content.

Rollback to %s

%s rolled back

to %s

Index of all pages
Índice de todas as páginas
Wiki Version
Versão do Wiki
Password
Senha
Run maintenance
Manutenção
Unlock Wiki
Desbloquear Wiki
Unlock site
Desbloquear sítio
Lock site
Bloquear sítio
Unlock %s
Desbloquear %s
Lock %s
Bloquear %s
Administration
Administração
Actions:
Acções:
Important pages:
Páginas importantes:
To mark a page for deletion, put <strong>%s</strong> on the first line.
Para marcar uma página a ser apagada, ponha <strong>%s</strong> na primeira linha.
from %s
de %s
redirected from %s
redireccionado de %s
%s:

[Home]
[Entrada]
Click to search for references to this page
Clique para procurar referências a esta página
Edit this page
Edite esta página
Preview:
Prever:
Preview only, not yet saved
Visualização apenas, nada foi gravado
Warning
Atenção
Database is stored in temporary directory %s
Base de dados é armazenada no directório temporário %s
%s seconds
%s segundos
Last edited
Última edição
Edited
Editado
by %s
de %s
(diff)
(diff)
a

c

Edit revision %s of this page
Edite a revisão %s desta página
e

This page is read-only
Esta página é apenas para leitura
View other revisions
Ver outras revisões
View current revision
Ver a versão actual
View all changes
Ver todas as alterações
View contributors

Add your comment here:

Homepage URL:
URL da página de entrada
s
s
Save
Gravar
p

Preview
Prever
Search:
Busca:
f

Replace:
Substituir:
Delete

Filter:

Last edit

revision %s
revisão %s
current revision
versão actual
Difference between revision %1 and %2
Diferença (entre a revisão %1 e %2)
Last major edit (%s)

later minor edits

No diff available.
Nenhuma dif. disponível.
Summary:
Sumário:
Old revision:
Revisão antiga:
Changed:
Alterado:
Deleted:

Added:
Adicionado:
to
para
Revision %s not available
Revisão %s não disponível
showing current revision instead
mostrando em vez dela a versão actual
Showing revision %s
Mostrando versão %s
Cannot save a nameless page.
Não se pode salvar uma página sem nome.
Cannot save a page without revision.
Não se pode salvar uma página sem revisão.
not deleted:
não apagado:
deleted
apagado
Cannot open %s
Não foi possível abrir %s
Cannot write %s
Não foi possível escrever %s
Could not get %s lock
Não foi possível bloquear %s
The lock was created %s.

Maybe the user running this script is no longer allowed to remove the lock directory?

Sometimes locks are left behind if a job crashes.

After ten minutes, you could try to unlock the wiki.

This operation may take several seconds...
Esta operação pode demorar alguns segundos...
Forced unlock of %s lock.
Bloqueio forçado de %s
No unlock required.
Não é necessário desbloquear.
%s hours ago
há %s horas
1 hour ago
há 1 hora
%s minutes ago
há %s minutos
1 minute ago
há 1 minuto
%s seconds ago
há %s segundos
1 second ago
há 1 segundo
just now
agora mesmo
Only administrators can upload files.
Só os administradores podem enviar ficheiros.
Editing revision %s of
Editando revisão %s de
Editing %s
Editando %s
Editing old revision %s.
Editando antiga revisão %s.
Saving this page will replace the latest revision with this text.
Gravar esta página irá substituir a última revisão com este texto.
This change is a minor edit.
Esta actualização é miníma.
Cancel

Replace this file with text
Substituir este ficheiro por texto
Replace this text with a file
Substituir este texto por um ficheiro
File to upload:
Arquivo a enviar:
Files of type %s are not allowed.
Não são permitidos ficheiros do tipo %s:
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
A sua senha foi guardada num cookie, se tem os cookies activados. Os cookies podem perder-se se você se ligar a partir de outra máquina, com outra conta, ou com outro software.
This site does not use admin or editor passwords.
Este sítio não usa senhas de administrador ou editor.
You are currently an administrator on this site.
Você é actualmente um administrador deste sítio.
You are currently an editor on this site.
Você é actualmente um editor deste sítio.
You are a normal user on this site.
Você é um utilizador normal deste sítio.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
A sua senha não coincide com nenhuma dos administradores ou editores.
Password:
Senha:
Return to %s

This operation is restricted to site editors only...
Esta operação é destinada apenas aos editores do sítio...
This operation is restricted to administrators only...
Esta operação é destinada apenas aos administradores...
Edit Denied
Edição Proibida
Editing not allowed: user, ip, or network is blocked.
Edição não permitida: utilizador, ip, ou rede está bloqueado(a).
Contact the wiki administrator for more information.
Contate o administrador do wiki para mais informações.
The rule %s matched for you.
A regra %s aplica-se a si.
See %s for more information.
Para mais informações, veja %s.
SampleUndefinedPage
ExemploPaginaNaoDefinida
Sample_Undefined_Page
Exemplo_Pagina_Nao_Definida
Rule "%1" matched "%2" on this page.
A regra "%1" coincide com a "%2" nesta página.
Reason: %s.

Reason unknown.

(for %s)
(para %s)
%s pages found.
Encontradas %s páginas.
Preview: %s

Replaced: %s
Substituído: %s
Search for: %s
Procurar: %s
View changes for these pages
Ver alterações para estas págians
last updated
última actualização
by
por
Transfer Error: %s
Erro de transferência: %s
Browser reports no file info.
Navegador não encontra informação sobre o ficheiro.
Browser reports no file type.
Browser não encontra o tipo do ficheiro.
The page contains banned text.
Esta página contém texto banido.
No changes to be saved.

This page was changed by somebody else %s.
Esta página foi editada por outra pessoa %s.
The changes conflict.  Please check the page again.
Conflito entre alterações. Por favor reverifique esta página.
Please check whether you overwrote those changes.
Por favor verifique se sobrescreveu essas alterações.
Anonymous
Anónimo
Cannot delete the index file %s.
Impossível apagar o ficheiro de índice %s.
Please check the directory permissions.
Por favor verifique as permissões do directório.
Your changes were not saved.
As suas alterações não foram gravadas.
Could not get a lock to merge!
Não foi possivel bloquear para juntar(merge)!
you
o que você escreveu
ancestor
o que já estava
other
o que a outra pessoa escreveu
Run Maintenance
Fazer a Manutenção
Maintenance not done.
Manutenção não concluída.
(Maintenance can only be done once every 12 hours.)
(Manutenção pode ser feita apenas de 12 em 12 horas.)
Remove the "maintain" file or wait.
Remover o arquivo "manter" ou esperar.
Expiring keep files and deleting pages marked for deletion
Expirando arquivos a manter e apagando páginas marcadas para apagar
Moving part of the %s log file.
Movendo parte do arquivo %s de log.
Could not open %s log file
Não foi possivel abrir o arquivo %s de log
Error was
Erro foi
Note: This error is normal if no changes have been made.
NOTA: Este erro é normal se nenhuma alteração foi feita.
Moving %s log entries.
Movendo entradas de log %s.
Set or Remove global edit lock
Marque ou Remova bloqueio global de edição
Edit lock created.
Bloqueio de edição criado.
Edit lock removed.
Bloqueio de edição removido.
Set or Remove page edit lock
Marque ou Remova bloqueio de edição de páginas
Lock for %s created.
Bloqueio para %s criado.
Lock for %s removed.
Bloqueio para %s removido.
Displaying Wiki Version
Mostrando Versão do Wiki
Debugging Information

Too many connections by %s
Demasiadas ligações de %s
Please do not fetch more than %1 pages in %2 seconds.
Por favor não busque mais do que %1 páginas em %2 segundos.
Check whether the web server can create the directory %s and whether it can create files in it.
Verificar se o servidor web pode criar ao directório %s e se pode criar ficheiros no directório.
, see

The two revisions are the same.

################################################################################
# modules/admin.pl
################################################################################
Deleting %s
Apagando %s
Deleted %s
%s apagado
Renaming %1 to %2.
Renomeando %1 para %2
The page %s does not exist
A página %s não existe
The page %s already exists
A página %s já existe
Cannot rename %1 to %2
Impossível renomear 1% para %2
Renamed to %s
Renomeado para %s
Renamed from %s
Renomeado de %s
Renamed %1 to %2.
%1 renomeado para %2
Immediately delete %s
Apagar %s imediatamente
Rename %s to:
Renomear %s para:
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
Conteúdo completo
The main page is %s.
A página principal é %s.
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
Visitantes recentes
some action
alguma acção
was here
foi aqui
and read
e ler
################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999

The match parameter is missing.
Falta o parâmentro de correspondência
Page Collection for %s

Previous
Anterior
Next
Próximo
Calendar %s
Calendário para %s
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
Páginas sem Cluster
################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:

################################################################################
# modules/commentcount.pl
################################################################################
Comments on
Comentários sobre
Comment on
Comentário sobre
################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s
Complilação para %s
Compilation tag is missing a regular expression.
Falta uma expressão regular na <i>tag</i> de compilação
################################################################################
# modules/creationdate.pl
################################################################################
Add creation date to page files

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
Limpando o <i>spam</i> das páginas
Spammed pages

Cannot find revision %s.
Imposível encontrar revisão %s.
Revert to revision %1: %2
Reverter para revisão %1: %2
Marked as %s.
Marcado como %s.
Cannot find unspammed revision.
Impossível encontrar revisão sem <i>spam</>.
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
Adicionar comentário
################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes

%s days
%s dias
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
Não respondeu correctamente.
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
Impossível encontrar <i>template</i> %1.html em %2
################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.

Only Admins are allowed to see this hidden page.

################################################################################
# modules/index.pl
################################################################################
Index
Índice
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
Sair
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
Línguas:
Show!
Mostrar!
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
Definir
################################################################################
# modules/links.pl
################################################################################
Full Link List
Lista completa de Ligações
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
<i>Template</i> sem parâmetros
The template %s is either empty or does not exist.
O <i>template</i> está em branco ou não existe.
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
Registar para %s
Please choose a username of the form "FirstLast" using your real name.
Por favor escolha um nome de utilizador no formulário "FirstLast" usando o seu nome verdadeiro.
The passwords do not match.
As senhas não coincidem.
The password must be at least %s characters.
A senha deve ter, no mínimo, %s carácteres.
That email address is invalid.
O endereço de e-mail é inválido
The username %s has already been registered.
O nome de utilizador %s já foi registado
Your registration for %s has been submitted.
O seu registo para % foi enviado
Please allow time for the webmaster to approve your request.

An email has been sent to "%s" with further instructions.

There was an error saving your registration.

An account was created for %s.
Foi criada uma conta para %s
Login to %s
Entrar para %s
Username and/or password are incorrect.
Nome de utilizador e/ou senha está incorrecto(a).
Logged in as %s.
Entrou como %s
Logout of %s
Sair de %s
Logout of %s?

Logged out of %s
Você saiu de %s
You are now logged out.
Você acaba de sair.
Register a new account
Registar uma nova conta
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

Bisecting proccess is already active.

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
Links próximos:
Search sites on the %s as well
Estender a busca aos sítios no %s
Fetching results from %s:
Recolhendo os resultados de %s:
Near pages:
Páginas próximas:
Include near pages
Incluir páginas próximas
EditNearLinks
EditarLinksPróximos
The same page on other sites:
A mesma página noutros sítios:
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)

################################################################################
# modules/no-question-mark.pl
################################################################################
image
imagem
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
Limpando a Cache
Done.
Concluído
Generating Link Database
Gerando base de dados de Links
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
MapaLocal
No page id for action localmap
Não há id de página para acção localmap
Requested page %s does not exist
A página %s pedida não existe
Local Map for %s
Mapa Local para %S
view
ver
################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s

You have banned your own IP.

################################################################################
# modules/orphans.pl
################################################################################
Orphan List
Lista de Órfãos
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
Rasto:
################################################################################
# modules/page-type.pl
################################################################################
None
Nenhum
Type
Tipo
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"
<i>Permalink</i> para "%s"
anchor first defined here: %s
âncora definida previamente aqui: %s
the page %s also exists
a página %s também existe
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Clicar para procurar referências a esta âncora permanente
Include permanent anchors
Incluir âncoras permanentes
################################################################################
# modules/portrait-support.pl
################################################################################
Portrait
Retrato
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
Referrers
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Todos os <i>Referrers</i>
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s

################################################################################
# modules/small.pl
################################################################################
Index of all small pages

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
Cópia Estática
Back to %s
Voltar para %s
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Edição não permitida para %s.
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
Tag
Feed for this tag

Tag Cloud

Rebuilding index not done.
Reconstrução do índice não realizada.
(Rebuilding the index can only be done once every 12 hours.)
(A reconstrução do índice só pode ser feita de 12 em 12 horas.)
Rebuild tag index

list tags

tag cloud

################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Como alternativa, use um dos modelos seguintes:
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
Conteúdo
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
Esta página é uma tradução de %s.
The translation is up to date.
A tradução está actualizada.
The translation is outdated.
A tradução está desactualizada.
The page does not exist.
Esta página não existe.
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
http://www.amazon.de/exec/obidos/ISBN=%s
alternate
alternativa
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
busca
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

#
END_OF_TRANSLATION
