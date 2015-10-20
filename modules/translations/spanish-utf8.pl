# UTF-8 encoded Spanish language file for use with Oddmuse
#
# Copyright (c) 2003  Unknown
# Copyright (c) 2007  Juan Martínez Pineda
# Copyright (c) 2015  Matias A. Fonzo, <selk@dragora.org>
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

AddModuleDescription('spanish-utf8.pl', 'Spanish') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Lectura no permitida: el usuario, ip o sub-red está bloqueado.
Login
Iniciar Sesión
Error
Error
%s calls
%s llamadas
Cannot create %s
No se puede crear %s
Include normal pages
Incluir páginas normales
Invalid UserName %s: not saved.
Nombre de usuario %s no válido: no guardado.
UserName must be 50 characters or less: not saved
El nombre de usuario debe de contener 50 caracteres o menos: no guardado
This page contains an uploaded file:
Esta página contiene un archivo adjunto:
No summary was provided for this file.
No se proporcionó resumen para este archivo.
Recursive include of %s!
Inclusión recursiva de %s!
Clear Cache
Limpiar caché
Main lock obtained.
Bloqueo principal obtenido.
Main lock released.
Bloqueo principal liberado.
Journal
Diario
More...
Más...
Comments on this page
Comentarios sobre esta página
XML::RSS is not available on this system.
XML::RSS no disponible en este sistema.
diff
diff
history
historia
%s returned no data, or LWP::UserAgent is not available.
%s no ha devuelto datos, o LWP::UserAgent no está disponible.
RSS parsing failed for %s
Análisis RSS falló para %s
No items found in %s.
Ítems no encontrados en %s.
 . . . .
 . . . .
Click to edit this page
Clic para editar esta página
CGI Internal error: %s
Error interno de CGI: %s
Invalid action parameter %s
Parámetro de acción %s no válido
Page name is missing
Nombre de página perdido
Page name is too long: %s
El nombre de la página %s es demasiado largo
Invalid Page %s (must not end with .db)
Página %s no válida (no debe de terminar con la extensión .db)
Invalid Page %s (must not end with .lck)
Página %s no válida (no debe de terminar con la extensión .lck)
Invalid Page %s
Página %s no válida
There are no comments, yet. Be the first to leave a comment!
Todavía no hay comentarios. ¡Sé el primero en dejar un comentario!
Welcome!
¡Bienvenido!
This page does not exist, but you can %s.
Esta página no existe, pero se puede %s.
create it now
crearla ahora
Too many redirections
Demasiadas redirecciones
No redirection for old revisions
Ningún cambio de dirección para viejas revisiones
Invalid link pattern for #REDIRECT
Patrón de enlace no válido para #REDIRECT
Please go on to %s.
Por favor, vaya a %s.
Updates since %s
Actualizaciones desde %s
up to %s
hasta %s
Updates in the last %s days
Actualizaciones en los últimos %s días
Updates in the last day
Actualizaciones en el último día
for %s only
sólo para %s
List latest change per page only
Listar sólo últimos cambios por página
List all changes
Listar todos los cambios
Skip rollbacks
Omitir reversiones (rollbacks)
Include rollbacks
Incluir reversiones (rollbacks)
List only major changes
Listar sólo cambios mayores
Include minor changes
Incluir cambios menores
days
días
List later changes
Listar últimos cambios
RSS
RSS
RSS with pages
RSS con páginas
RSS with pages and diff
RSS con páginas y diff
Filters
Filtros
Title:
Título:
Title and Body:
Título y cuerpo:
Username:
Nombre de usuario:
Host:
Host:
Follow up to:
Vigilar:
Language:
Idioma:
Go!
Ir!
(minor)
(menor)
rollback
retrotraer
new
nuevo
All changes for %s
Todos los cambios para %s
This page is too big to send over RSS.
Esta página es demasiado grande para enviar a través de RSS
History of %s
Historia de %s
Compare
Comparar
Deleted
Borrado
Mark this page for deletion
Marcar esta página para borrar
No other revisions available
Otras revisiones no disponibles
current
actual
Revision %s
Revisión %s
Contributors to %s
Contribuidores de %s
Missing target for rollback.
Perdido destino para rollback
Target for rollback is too far back.
Destino para retrotraer está demasiado lejos.
A username is required for ordinary users.
Se requiere un nombre de usuario para usuarios normales.
Rolling back changes
Deshaciendo cambios
Editing not allowed: %s is read-only.
Edición no permitida: %s es de sólo-lectura.
Rollback of %s would restore banned content.
Retrotraer %s restauraría contenido prohibido.
Rollback to %s
Retrotraer (rollback) a %s
%s rolled back
%s ha sido revertido
to %s
a %s
Index of all pages
Índice de todas las páginas
Wiki Version
Versión de la wiki
Password
Contraseña
Run maintenance
Ejecutar mantenimiento
Unlock Wiki
Desbloquear wiki
Unlock site
Desbloquear sitio
Lock site
Bloquear sitio
Unlock %s
Desbloquear %s
Lock %s
Bloquear %s
Administration
Administración
Actions:
Acciones:
Important pages:
Páginas importantes:
To mark a page for deletion, put <strong>%s</strong> on the first line.
Para marcar una página para su eliminación, escribir <strong>%s</strong> en la primera línea.
from %s
desde %s
redirected from %s
redirigido desde %s
%s:
[Home]
[Casa]
Click to search for references to this page
Haga clic para buscar referencias a esta página
Edit this page
Editar esta página
Preview:
Previsualización:
Preview only, not yet saved
Sólo vista previa, aún no guardado
Warning
Advertencia
Database is stored in temporary directory %s
La base de datos se almacenó temporalmente en el directorio %s
%s seconds
%s segundos
Last edited
Última vez editado
Edited
Editado
by %s
por %s
(diff)
(diff)
a
c
Edit revision %s of this page
Editar revisión %s de esta página
e
This page is read-only
Esta página es de sólo-lectura
View other revisions
Ver otras revisiones
View current revision
Ver revisión actual
View all changes
Ver todos los cambios
View contributors
Ver contribuidores
Add your comment here:
Agregue su comentario aquí:
Homepage URL:
URL de Inicio:
s
Save
Guardar
p
Preview
Previsualizar
Search:
Buscar:
f
Replace:
Reemplazar:
Delete
Borrar
Filter:
Filtro:
Last edit
Última vez editado
revision %s
revisión %s
current revision
revisión actual
Difference between revision %1 and %2
Diferencia entre revisión %1 y %2
Last major edit (%s)
Última edición mayor (%s)
later minor edits
últimas ediciones menores
No diff available.
Diff no disponible.
Summary:
Sumario:
Old revision:
Revisión antigua:
Changed:
Modificado:
Deleted:
Borrado:
Added:
Añadido:
to
a
Revision %s not available
Revisión %s no disponible
showing current revision instead
mostrando revisión actual en su lugar
Showing revision %s
Mostrando revisión %s
Cannot save a nameless page.
No puede guardarse una página sin nombre.
Cannot save a page without revision.
No puede guardarse una página sin revisión.
not deleted:
no borrado:
deleted
borrado
Cannot open %s
No puede abrirse %s
Cannot write %s
No puede escribirse en %s
Could not get %s lock
No se pudo obtener el bloqueo de %s
The lock was created %s.
El bloqueo se ha creado para %s.
Maybe the user running this script is no longer allowed to remove the lock directory?
¿Tal vez, el usuario que ejecuta este script ya no es permitido para eliminar el directorio de bloqueo?
Sometimes locks are left behind if a job crashes.
A veces los bloqueos se quedan atrás si un trabajo se estrella.
After ten minutes, you could try to unlock the wiki.
Después de diez minutos, usted podría tratar de desbloquear el wiki.
This operation may take several seconds...
Esta operación puede tomar varios segundos...
Forced unlock of %s lock.
Forzado desbloqueo de %s.
No unlock required.
No se requiere desbloqueo.
%s hours ago
hace %s horas
1 hour ago
hace 1 hora
%s minutes ago
hace %s minutos
1 minute ago
hace 1 minuto
%s seconds ago
hace %s segundos
1 second ago
hace un segundo
just now
en este momento
Only administrators can upload files.
Sólo administradores pueden subir archivos.
Editing revision %s of
Editando revisión %s de
Editing %s
Editando %s
Editing old revision %s.
Editando revisión antigua %s.
Saving this page will replace the latest revision with this text.
Guardar esta página sustituirá a la última revisión con este texto.
This change is a minor edit.
Este cambio es una edición menor.
Cancel
Cancelar
Replace this file with text
Reemplazar este archivo con texto
Replace this text with a file
Reemplazar este texto con un archivo
File to upload:
Archivo a subir:
Files of type %s are not allowed.
No se permiten archivos de tipo %s.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Su contraseña se guardó en una cookie (si habilitó las cookies). Las cookies pueden perderse si se conecta desde otra máquina, desde otra cuenta, o con cualquier otro software.
This site does not use admin or editor passwords.
Este sitio no utiliza contraseñas de administrador o editor.
You are currently an administrator on this site.
Usted es actualmente un administrador de este sitio.
You are currently an editor on this site.
Usted es actualmente un editor de este sitio.
You are a normal user on this site.
Ustes es un usuario normal en este sitio.
You do not have a password set.
Eres un usuario normal en este sitio.
Usted no tiene una contraseña establecida.
Your password does not match any of the administrator or editor passwords.
Su contraseña no coincide con ninguna de las contraseñas de administrador o editor.
Password:
Contraseña:
Return to %s
This operation is restricted to site editors only...
Esta operación se restringe a sólo editores del sitio...
This operation is restricted to administrators only...
Esta operación se restringe a sólo administradores...
Edit Denied
Edición denegada
Editing not allowed: user, ip, or network is blocked.
Edición no permitida: usuario, ip, o subred ha sido bloqueada.
Contact the wiki administrator for more information.
Póngase en contacto con el administrador del wiki para más información.
The rule %s matched for you.
La regla %s concuerda para ti.
See %s for more information.
Ver %s para más información.
SampleUndefinedPage
PaginaEjemploSinDefinir
Sample_Undefined_Page
Pagina_Ejemplo_Sin_Definir
Rule "%1" matched "%2" on this page.
Regla "%1" concuerda con "%2" en esta página.
Reason: %s.
Motivo: %s.
Reason unknown.
Motivo desconocido.
(for %s)
(para %s)
%s pages found.
%s páginas encontradas.
Preview: %s
Vista previa: %s
Replaced: %s
Reemplazado: %s
Search for: %s
Buscar: %s
View changes for these pages
Ver cambios para estas páginas
last updated
última actualización
by
por
Transfer Error: %s
Error de transferencia: %s
Browser reports no file info.
Navegador reporta No hay información del archivo.
Browser reports no file type.
Navegador reporta No existe tipo de archivo.
The page contains banned text.
La página contiene texto baneado, prohibido.
No changes to be saved.
Sin cambios que guardar.
This page was changed by somebody else %s.
Esta página se cambió por alguien más %s.
The changes conflict.  Please check the page again.
Los cambios entran en conflicto.  Por favor, comprueba la página otra vez.
Please check whether you overwrote those changes.
Por favor, comprueba si sobreescribes esos cambios.
Anonymous
Anónimo
Cannot delete the index file %s.
No se puede borrar el archivo índice %s.
Please check the directory permissions.
Por favor, compruebe los permisos de directorio.
Your changes were not saved.
Tus cambios no se guardaron.
Could not get a lock to merge!
¡No pudo obtenerse un bloqueo para combinar!
you
tú
ancestor
ancestro
other
otro
Run Maintenance
Ejecutar Mantenimiento
Maintenance not done.
Mantenimiento no realizado.
(Maintenance can only be done once every 12 hours.)
(El mantenimiento sólo puede realizarse una vez cada 12 horas.)
Remove the "maintain" file or wait.
Remueva el archivo "maintain" o espere.
Expiring keep files and deleting pages marked for deletion
Expirando archivos "keep" y eliminando páginas marcadas para borrado
Moving part of the %s log file.
Moviendo parte del archivo de registro %s.
Could not open %s log file
No pudo abrirse el archivo de registro %s
Error was
El error fue
Note: This error is normal if no changes have been made.
Nota: Este error es normal si no se han hecho cambios.
Moving %s log entries.
Moviendo %s entradas del registro.
Set or Remove global edit lock
Establecer o quitar bloqueo global de edición
Edit lock created.
Bloqueo de edición creado.
Edit lock removed.
Bloqueo de edición removido.
Set or Remove page edit lock
Establecer o quitar página de edición de bloqueo
Lock for %s created.
Bloqueo para %s creado.
Lock for %s removed.
Bloqueo para %s removido.
Displaying Wiki Version
Mostrando versión de wiki
Debugging Information
Información de depuración
Too many connections by %s
Demasiadas conexiones por %s
Please do not fetch more than %1 pages in %2 seconds.
Por favor, no visites más de %1 páginas en %2 segundos.
Check whether the web server can create the directory %s and whether it can create files in it.
Compruebe si el servidor web puede crear el directorio %s y si puede crear archivos en él.
, see
, ver
The two revisions are the same.
Las dos revisiones son iguales.
################################################################################
# modules/admin.pl
################################################################################
Deleting %s
Borrando %s
Deleted %s
Borrado %s
Renaming %1 to %2.
Renombrando %1 a %2.
The page %s does not exist
La página %s no existe
The page %s already exists
La página %s ya existe
Cannot rename %1 to %2
No se puede renombrar %1 a %2
Renamed to %s
Renombrado a %s
Renamed from %s
Renombrado desde %s
Renamed %1 to %2.
Renombrado %1 a %2
Immediately delete %s
Inmediatamente eliminar %s
Rename %s to:
Renombrar %s a:
################################################################################
# modules/advanced-uploads.pl
################################################################################
Attach file:
Adjuntar archivo:
Upload
Subir
################################################################################
# modules/aggregate.pl
################################################################################
Learn more...
Para saber más ...
################################################################################
# modules/all.pl
################################################################################
Complete Content
Contenido Completo
The main page is %s.
La página principal es %s.
################################################################################
# modules/archive.pl
################################################################################
Archive:
Archivo:
################################################################################
# modules/backlinkage.pl
################################################################################
Rebuild BackLink database
Reconstruir base de datos de Retroenlaces
Internal Page: %s
Página interna: %s
Pages that link to this page
Páginas que enlazan a esta página
################################################################################
# modules/backlinks.pl
################################################################################
The search parameter is missing.
El parámetro de búsqueda está perdido.
Pages link to %s
Las páginas se vinculan a %s
################################################################################
# modules/ban-contributors.pl
################################################################################
Ban contributors
Prohibir contribuidores
Ban Contributors to %s
Prohibir contribuidores a %s
Ban!
¡Prohibir!
Regular expression:
Expresión regular:
%s is banned
%s está prohibido, baneado
These URLs were rolled back. Perhaps you want to add a regular expression to %s?
Estas direcciones URL se deshacen. ¿Quizás desee agregar una expresión regular para %s?
Consider banning the IP number as well:
Considere prohibir el número de IP también:
################################################################################
# modules/banned-regexps.pl
################################################################################
Regular expression "%1" matched "%2" on this page.
Expresión regular "%1" coincide con "%2" en esta página.
Regular expression "%s" matched on this page.
Expresión regular "%s" coincidente en esta página.
################################################################################
# modules/big-brother.pl
################################################################################
Recent Visitors
Visitantes Recientes
some action
alguna acción
was here
estuvo aquí
and read
y leyó
################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999
Valor prohibido de año, utilice: 0001-9999
The match parameter is missing.
El parámetro de coincidencias está perdido.
Page Collection for %s
Colección de páginas para %s
Previous
Anterior
Next
Siguiente
Calendar %s
Calendario
Su
Do
Mo
Lu
Tu
Ma
We
Mi
Th
Ju
Fr
Vi
Sa
Sá
January
Enero
February
Febrero
March
Marzo
April
Abril
May
Mayo
June
Junio
July
Julio
August
Agosto
September
Septiembre
October
Octubre
November
Noviembre
December
Diciembre
################################################################################
# modules/checkbox.pl
################################################################################
set %s
establecer %s
unset %s
remover %s
################################################################################
# modules/clustermap.pl
################################################################################
Clustermap
Clustermap
Pages without a Cluster
Páginas sin un cluster
################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:
Comentarios:
################################################################################
# modules/commentcount.pl
################################################################################
Comments on
Comentarios sobre
Comment on
Comentar
################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s
Compilación para %s
Compilation tag is missing a regular expression.
La etiqueta de compilación omite una expresión regular.
################################################################################
# modules/css-install.pl
################################################################################
Install CSS
Instalar CSS
Copy one of the following stylesheets to %s:
Copia uno de las siguientes hojas de estilo a %s:
Reset
Reiniciar
################################################################################
# modules/dates.pl
################################################################################
Extract all dates from the database
Extraer todas las fechas a partir de la base de datos
Dates
Fechas
No dates found.
No hay fechas encontradas.
################################################################################
# modules/despam.pl
################################################################################
List spammed pages
Lista de páginas con spam
Despamming pages
Deshaciendo spam
Spammed pages
Páginas con spam
Cannot find revision %s.
No se puede encontrar la revisión %s.
Revert to revision %1: %2
Revertir revisión %1: %2
Marked as %s.
Marcado como %s.
Cannot find unspammed revision.
No se puede encontrar revisión sin spam.
################################################################################
# modules/diff.pl
################################################################################
Page diff
Diferencia de página
Diff
Diferencia
################################################################################
# modules/drafts.pl
################################################################################
Recover Draft
Recuperar Borrador
No text to save
No hay texto que guardar
Draft saved
Borrador guardado
Draft recovered
Borrador recuperado
No draft available to recover
Borrador no disponible para recuperar
Save Draft
Guardar borrador
Draft Cleanup
Borrador limpiado
Unable to delete draft %s
Imposible de eliminar borrador %s
%1 was last modified %2 and was kept
%1 fue modificado por última vez %2 y fue mantenido
%1 was last modified %2 and was deleted
%1 fue modificado por última vez %2 y fue borrado
################################################################################
# modules/dynamic-comments.pl
################################################################################
Add Comment
Añadir Comentario
################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes
cambios normales
%s days
%s días
################################################################################
# modules/edit-paragraphs.pl
################################################################################
Could not identify the paragraph you were editing
No se pudo identificar el párrafo que estaba editando
This is the section you edited:
Esta es la sección que ha editado:
This is the current page:
Esta es la página actual:
################################################################################
# modules/find.pl
################################################################################
Matching page names:
Coincidencias con nombres de página:
################################################################################
# modules/fix-encoding.pl
################################################################################
Fix character encoding
Arreglar caracteres de codificación
Fix HTML escapes
Arreglar escapes HTML
################################################################################
# modules/form_timeout.pl
################################################################################
Set $FormTimeoutSalt.
Establecer $FormTimeoutSalt.
Form Timeout
Formulario de tiempo de espera
################################################################################
# modules/gd_security_image.pl
################################################################################
GD or Image::Magick modules not available.
Los módulos GD o Image::Magick no están disponibles.
GD::SecurityImage module not available.
El módulo GD::SecurityImage no está disponible.
Image storing failed. (%s)
Ha fallado el almacenamiento de la imagen. (%s)
Bad gd_security_image_id.
gd_security_image_id incorrecto.
Please type the six characters from the anti-spam image
Por favor escriba los seis caracteres de la imagen anti-spam
Submit
Enviar
CAPTCHA
You did not answer correctly.
No respondiste la respuesta correctamente.
$GdSecurityImageFont is not set.
$GdSecurityImageFont no está establecido.
################################################################################
# modules/git-another.pl
################################################################################
No summary provided
No hay un resumen proporcionado
################################################################################
# modules/git.pl
################################################################################
no summary available
No hay sumario disponible
page was marked for deletion
La página fue marcada para su eliminación
Oddmuse
Cleaning up git repository
Limpiando el repositorio git
################################################################################
# modules/google-plus-one.pl
################################################################################
Google +1 Buttons
Botones Google +1
All Pages +1
Todas las páginas +1
This page lists the twenty last diary entries and their +1 buttons.
Esta página muestra las últimas veinte entradas del diario y sus botones +1.
################################################################################
# modules/gravatar.pl
################################################################################
Email:
Correo electrónico:
################################################################################
# modules/header-and-footer-templates.pl
################################################################################
Could not find %1.html template in %2
No pudo encontrarse la plantilla %1.html en %2
################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.
Sólo se permiten Editores para ver esta página oculta.
Only Admins are allowed to see this hidden page.
Sólo se permiten Administradores para ver esta página oculta.
################################################################################
# modules/index.pl
################################################################################
Index
Índice
################################################################################
# modules/joiner.pl
################################################################################
The username %s already exists.
El nombre de usuario %s ya existe.
The email address %s has already been used.
La dirección de correo electrónico %s ya se ha utilizado.
Wait %s minutes before try again.
Espere %s minutos antes de intentarlo de nuevo.
Registration Confirmation
Confirmación del registro
Visit the link below to confirm registration.
Visite el siguiente enlace para confirmar la inscripción.
Recover Account
Recuperar cuenta
You can login by following the link below. Then set new password.
Puede iniciar sesión siguiendo el enlace a continuación. Entonces establezca una nueva contraseña.
Change Email Address
Cambiar dirección de correo electrónico
To confirm changing email address, follow the link below.
Para confirmar el cambio de dirección de correo electrónico, siga el siguiente enlace.
To submit this form you must answer this question:
Para enviar este formulario, usted debe responder a esta pregunta:
Question:
Pregunta:
CAPTCHA:
CAPTCHA:
Registration
Inscripción
The username must be valid page name.
El nombre de usuario debe de ser un nombre de página válido.
Confirmation email will be sent to the email address.
El E-mail de confirmación será enviado a la dirección de correo electrónico.
Repeat Password:
Repita la contraseña:
Bad email address format.
Formato de dirección de correo electrónico malo.
Password needs to have at least %s characters.
La contraseña debe de tener al menos %s caracteres.
Passwords differ.
Las contraseñas son diferentes.
Email Sent
Correo enviado
Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.
E-mail de confirmación ha sido enviado a %s. Visita el enlace en el correo para confirmar el registro.
Failed to Confirm Registration
No se ha podido confirmar la inscripción
Invalid key.
Llave no válida.
The key expired.
La llave expiró.
Registration Confirmed
Inscripción confirmada
Now, you can login by using username and password.
Ahora, usted puede iniciar sesión usando su nombre de usuario y contraseña.
Forgot your password?
¿Olvidaste tu contraseña?
Login failed.
Error de inicio de sesion.
You are banned.
Usted está prohibido (banned).
You must confirm email address.
Usted debe de confirmar la dirección de correo electrónico.
Logged in
Conectado
%s has logged in.
%s ha conectado.
You should set new password immediately.
Usted debe de establecer una nueva contraseña inmediatamente.
Change Password
Cambiar contraseña
Logged out
Desconectado
%s has logged out.
%s ha sido desconectado.
Account Settings
Configuraciones de la cuenta
Logout
Cerrar sesión
Current Password:
Contraseña actual:
New Password:
Nueva contraseña:
Repeat New Password:
Repita la nueva contraseña:
Password is wrong.
La contraseña es incorrecta.
Password Changed
Contraseña cambiada
Your password has been changed.
Su contraseña ha sido cambiada.
Forgot Password
Se te olvidó tu contraseña
Enter email address, and recovery login ticket will be sent.
Introduzca la dirección de correo electrónico, y el ticket de recuperación de inicio de sesión será enviado.
Not found.
No encontrado.
The mail address is not valid anymore.
La dirección de correo ya no es más válida.
An email has been sent to %s with further instructions.
Un correo ha sido enviado a %s con más instrucciones.
New Email Address:
Nueva dirección de correo:
Failed to load account.
No se pudo cargar la cuenta.
An email has been sent to %s with a login ticket.
Un correo ha sido enviado a %s con un ticket de inicio de sesión.
Confirmation Failed
La confirmación falló
Failed to confirm.
No se pudo confirmar.
Email Address Changed
La dirección de correo ha cambiado
Email address for %1 has been changed to %2.
La dirección de correo para %1 ha sido cambiada a %2.
Account Management
Administración de cuentas
Ban Account
Prohibir cuentas
Enter username of the account to ban:
Introduzca el nombre de usuario de la cuenta a prohibir:
Ban
Prohibir
Enter username of the account to unban:
Introduzca nombre de usuario de la cuenta para eliminar la prohibición:
Unban
Desprohibir
%s is already banned.
%s ya está prohibido.
%s has been banned.
%s ha sido prohibido.
%s is not banned.
%s no está prohibido.
%s has been unbanned.
%s ha sido desprohibido.
Register
Registrar
################################################################################
# modules/lang.pl
################################################################################
Languages:
Idiomas:
Show!
Mostrar!
################################################################################
# modules/like.pl
################################################################################
====(\d+) persons? liked this====
====a (\d+) ¿personas? les gusta esto====
====%d persons liked this====
====a %d personas les gusta esto====
====1 person liked this====
====a 1 persona le gusta esto====
I like this!
¡Esto me gusta!
################################################################################
# modules/link-all.pl
################################################################################
Define
Definir
################################################################################
# modules/links.pl
################################################################################
Full Link List
Lista Completa de Enlaces
################################################################################
# modules/list-banned-content.pl
################################################################################
Banned Content
Contenido prohibido
Rule "%1" matched on this page.
La regla "%1" coincide en esta página.
################################################################################
# modules/listlocked.pl
################################################################################
List of locked pages
Lista de páginas bloqueadas
################################################################################
# modules/listtags.pl
################################################################################
Pages tagged with %s
Páginas etiquetadas con %s
################################################################################
# modules/live-templates.pl
################################################################################
Template without parameters
Plantilla sin parámetros
The template %s is either empty or does not exist.
La plantilla %s está vacía o bien no existe.
################################################################################
# modules/localnames.pl
################################################################################
Name:
Nombre:
URL:
URL:
Define Local Names
Definir nombres locales
Define external redirect:
Definir redirección externa:
 -- defined on %s
 -- definido en %s
Local names defined on %1: %2
Nombres locales definidos en %1: %2
################################################################################
# modules/logbannedcontent.pl
################################################################################
IP number matched %s
El número de IP coincidió con %s
################################################################################
# modules/login.pl
################################################################################
Register for %s
Registro para %s
Please choose a username of the form "FirstLast" using your real name.
Por favor, elija un nombre de usuario de la forma "PrincipioFinal" utilizando su nombre real.
The passwords do not match.
Las contraseñas no coinciden.
The password must be at least %s characters.
La contraseña debe de contener al menos %s caracteres.
That email address is invalid.
Esa dirección de correo no es válida.
The username %s has already been registered.
El nombre de usuario %s ya ha sido registrado.
Your registration for %s has been submitted.
Su registro para %s ha sido enviado.
Please allow time for the webmaster to approve your request.
Por favor, dar tiempo a que el webmaster apruebe tu solicitud.
An email has been sent to "%s" with further instructions.
Se envió un correo a "%s" con instrucciones adicionales.
There was an error saving your registration.
Hubo un error guardando tu registro.
An account was created for %s.
Se creó una cuenta para %s.
Login to %s
Iniciar sesión a %s
Username and/or password are incorrect.
Nombre de usuario y/o contraseña incorrectas.
Logged in as %s.
Sesión iniciada como %s
Logout of %s
Fin de sesión de %s
Logout of %s?
Cerrar sesion de %s?
Logged out of %s
Sesion finalizada para %s
You are now logged out.
Ahora has finalizado la sesión.
Register a new account
Registrar una nueva cuenta
Who am I?
¿Quién soy yo?
Change your password
Cambiar tu contraseña
Approve pending registrations
Aprobar registros pendientes
Confirm Registration for %s
Confirmar registro para %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s, tu registro ha sido aprobado. Ahora puedes usar tu contraseña para iniciar sesión y editar este wiki.
Confirmation failed.  Please email %s for help.
Confirmación fallida. Por favor, envía un correo a %s por ayuda.
Who Am I?
¿Quién soy yo?
You are logged in as %s.
Has iniciado sesión como %s.
You are not logged in.
No has iniciado sesión.
Reset Password
Restablecer la contraseña
The password for %s was reset.  It has been emailed to the address on file.
La contraseña para %s fue restablecida. Se ha enviado un correo electrónico a la dirección registrada.
There was an error resetting the password for %s.
Hubo un error restableciendo la contraseña para %s.
The username "%s" does not exist.
El nombre de usuario "%s" no existe.
Reset Password for %s
Restablecer contraseña para %s
Reset Password?
¿Restablecer contraseña?
Change Password for %s
Cambiar contraseña para %s
Change Password?
¿Cambiar contraseña?
Your current password is incorrect.
Tu contraseña actual es incorrecta.
Approve Pending Registrations for %s
Aprobar registros pendientes para %s
%s has been approved.
%s ha sido aprobado.
There was an error approving %s.
Hubo un error aprobando %s.
There are no pending registrations.
No existen registros pendientes.
################################################################################
# modules/mail.pl
################################################################################
Invalid Mail %s: not saved.
Correo %s no válido: no se guarda.
unsubscribe
desuscribirse
subscribe
suscribirse
%s appears to be an invalid mail address
%s parece ser una dirección de correo no válida.
Your mail subscriptions
Sus suscripciones de correo
All mail subscriptions
Todas las suscripciones de correo
Subscriptions
Suscripciones
Email: 
Correo:
Show
Mostrar
Subscriptions for %s:
Suscripción para %s:
Unsubscribe
Darse de baja
There are no subscriptions for %s.
No hay suscripciones para %s.
Change email address
Cambiar dirección de correo electrónico
Mail addresses are linked to unsubscription links.
Las direcciones de correo son vinculadas a los enlaces de desuscripción.
Subscribe to %s.
Suscríbete a %s.
Subscribe
Suscribirse
Subscribed %s to the following pages:
Suscrito a las siguientes páginas: %s
The remaining pages do not exist.
Las páginas restantes no existen.
Unsubscribed %s from the following pages:
Desuscribirse de las siguientes páginas: %s
Migrating Subscriptions
Migrando suscripciones
No non-migrated email addresses found, migration not necessary.
No se encontraron direcciones de correo no migradas, la migración no es necesaria.
Migrated %s rows.
Migrado %s filas.
################################################################################
# modules/module-bisect.pl
################################################################################
Bisect modules
Biseccionar módulos
Module Bisect
Módulo Bisect
All modules enabled now!
¡Todos los módulos activados, ahora!
Go back
Volver
Test / Always enabled / Always disabled
Probar / Siempre habilitado / Siempre deshabilitado
Start
Empezar
Bisection process is already active.
El proceso de bisección ya está activo.
Stop
Parar
It seems like module %s is causing your problem.
Parece que el módulo %s está causando el problema.
Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).
Tenga en cuenta que este módulo no maneja situaciones en las que el problema es causado por una combinación de módulos específicos (lo cual es raro de todos modos).
Good luck fixing your problem! ;)
¡Buena suerte arreglando su problema! ;)
Module count (only testable modules):
Recuento de módulo (sólo módulos comprobables):
Current module statuses:
Estados del módulo actual:
Good
Bueno
Bad
Malo
Enabling %s
Habilitando %s
################################################################################
# modules/module-updater.pl
################################################################################
Update modules
Actualizar módulos
Module Updater
Actualizador de módulos
Looks good. Update modules now!
Luce bien. Actualización de módulos: ¡ahora!
################################################################################
# modules/multi-url-spam-block.pl
################################################################################
You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.
Vinculó más de %s veces para el mismo dominio. Parecería que sólo un spammer haría esto. Su edición es rechazada.
################################################################################
# modules/namespaces.pl
################################################################################
%s is not a legal name for a namespace
%s no es un nombre legal para un espacio de nombres
Namespaces
Espacio de nombres
################################################################################
# modules/near-links.pl
################################################################################
Getting page index file for %s.
Obteniendo archivo índice de página para %s.
Near links:
Enlaces cercanos:
Nearlinks:
EnlaceCercanos
Search sites on the %s as well
Buscar sitios en %s también
Fetching results from %s:
Recopilando resultados desde %s:
Near pages:
Páginas cercanas:
Nearpages:
PáginasCercanas:
Include near pages
Incluir Nearpages
EditNearLinks
EditarNearLinks
The same page on other sites:
La misma página en otros sitios:
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)
 (crear localmente)
################################################################################
# modules/no-question-mark.pl
################################################################################
image
imagen
download
descargar
################################################################################
# modules/nosearch.pl
################################################################################
Backlinks
Enlaces a esta página
################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache
Limpiando caché
Done.
Hecho.
Generating Link Database
Generando base de datos de enlaces
The 404 handler extension requires the link data extension (links.pl).
La extensión handler 404 requiere la extensión de datos de enlace (links.pl).
################################################################################
# modules/offline.pl
################################################################################
Make available offline
Descargar todas las páginas localmente y trabajar fuera de línea
Offline
Fuera de línea
You are currently offline and what you requested is not part of the offline application. You need to be online to do this.
Usted está actualmente fuera de línea (offline) y lo que ha solicitado no es parte de la solicitud en línea. Tienes que estar en línea (online) para hacer esto.
################################################################################
# modules/olocalmap.pl
################################################################################
LocalMap
Mapa local
No page id for action localmap
Sin id de página para la acción de mapa local (LocalMap)
Requested page %s does not exist
Página solicitada %s no existe
Local Map for %s
Mapa local para %s
view
ver
################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s
Auto prohibición por %s
You have banned your own IP.
Usted ha prohibido su propia IP.
################################################################################
# modules/orphans.pl
################################################################################
Orphan List
Lista huérfana
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
Rastro:
################################################################################
# modules/page-type.pl
################################################################################
None
Ninguno
Type
Tipo
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"
Enlace permanente a "%s"
anchor first defined here: %s
primera ancla definida aquí: %s
the page %s also exists
la página %s también existe
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Haga clic para buscar referencias a este anclaje permanente
Include permanent anchors
Incluir anclas permanentes
################################################################################
# modules/portrait-support.pl
################################################################################
Portrait
Retrato
################################################################################
# modules/preview.pl
################################################################################
Pages with changed HTML
Páginas con HTML cambiado
Preview changes in HTML output
Vista previa de la salida HTML
################################################################################
# modules/private-pages.pl
################################################################################
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.
Esta página está protegida por contraseña. Si conoce la contraseña, puede %s. Una vez que haya hecho eso, regrese y vuelva a cargar esta página.
supply the password now
proporcionar la contraseña ahora
################################################################################
# modules/private-wiki.pl
################################################################################
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.
Este error no debería de ocurrir. Si su contraseña está establecida correctamente y está viendo este mensaje, entonces es un error, por favor repórtelo. Si usted es sólo un extraño y está tratando de obtener acceso no solicitado, a continuación, tenga en cuenta que todos los datos se cifran con AES-256 y la llave no se almacena en el servidor, buena suerte.
Attempt to read encrypted data without a password.
Intento de leer los datos cifrados sin una contraseña.
Cannot refresh index.
No se puede refrescar el índice.
################################################################################
# modules/publish.pl
################################################################################
Publish %s
Publicar %s
No target wiki was specified in the config file.
Destino de wiki no se especificó en el archivo de configuración.
The target wiki was misconfigured.
El destino de wiki se desconfiguró.
################################################################################
# modules/put.pl
################################################################################
Upload is limited to %s bytes
La subida está limitada a %s bytes
################################################################################
# modules/questionasker.pl
################################################################################
To save this page you must answer this question:
Para guardar esta página debes de responder a esta pregunta:
################################################################################
# modules/recaptcha.pl
################################################################################
Please type the following two words:
Por favor, escriba las dos siguientes palabras:
Please answer this captcha:
Por favor, conteste este captcha:
################################################################################
# modules/referrer-rss.pl
################################################################################
Referrers
Referido
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Todos los referidos
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s
Lista de páginas para %s
################################################################################
# modules/small.pl
################################################################################
Index of all small pages
Índice de todas las páginas breves o pequeñas
################################################################################
# modules/static-copy.pl
################################################################################
Static Copy
Copia estática
Back to %s
Volver a %s
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
No se permite editar %s.
################################################################################
# modules/svg-edit.pl
################################################################################
Edit image in the browser
Editar imagen en el navegador
Summary of your changes:
Resumen de sus cambios:
################################################################################
# modules/sync.pl
################################################################################
Copy to %1 succeeded: %2.
Copiar a %1 logrado: %2.
Copy to %1 failed: %2.
Copiar a %1 fallido: %2.
################################################################################
# modules/tags.pl
################################################################################
Tag
Etiqueta
Feed for this tag
Feed (comida) para esta etiqueta
Tag Cloud
Nube de etiquetas
Rebuilding index not done.
Reconstrucción de índice: no hecho.
(Rebuilding the index can only be done once every 12 hours.)
(La reconstrucción del índice sólo puede ser hecho una vez cada 12 horas.)
Rebuild tag index
Reconstruir índice de etiqueta
list tags
Listar etiquetas
tag cloud
nube de etiquetas
################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Alternativamente, utilice una de las siguientes plantillas:
################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.
Demasiadas instancias. Sólo %s permitidas.
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Por favor, inténtalo de nuevo más tarde. Quizás alguien está ejecutando un mantenimiento o realizando una búsqueda extensa. Desafortunadamente, este sitio tiene recursos limitados, así que tendremos que pedirte un poco de paciencia.
################################################################################
# modules/thumbs.pl
################################################################################
thumb
Miniatura
Error creating thumbnail from nonexisting page %s.
Error al crear miniatura desde la página %s que no existe.
Can not create thumbnail for file type %s.
No se puede crear la miniatura por el tipo de archivo %s.
Can not create thumbnail for a text document
No se puede crear miniatura de un documento de texto
Can not create path for thumbnail - %s
No se puede crear ruta para miniatura - %s
Could not open %s for writing whilst trying to save image before creating thumbnail. Check write permissions.
No se pudo abrir %s para escribir al tratar de guardar la imagen antes de crear la miniatura. Compruebe los permisos de escritura.
Failed to run %1 to create thumbnail: %2
Error al ejecutar %1 al crear miniaturas: %2
%s ran into an error
%s se encontró con un error
%s produced no output
%s no ha producido salida
Failed to parse %s.
Fallo al analizar %s.
################################################################################
# modules/timezone.pl
################################################################################
Timezone
Zona horaria
Pick your timezone:
Elija su zona horaria:
Set
Establecer
################################################################################
# modules/toc-headers.pl
################################################################################
Contents
Contenidos
################################################################################
# modules/today.pl
################################################################################
Create a new page for today
Crear una página nueva para hoy
################################################################################
# modules/translation-links.pl
################################################################################
Add Translation
Añadir traducción
Added translation: %1 (%2)
Traducción agregada: %1 (%2)
Translate %s
Traducir %s
Thank you for writing a translation of %s.
GRacias por escribir una traducción para %s.
Please indicate what language you will be using.
Por favor, indique el idioma que va a utilizar.
Language is missing
Falta el idioma
Suggested languages:
Lenguajes sugeridos:
Please indicate a page name for the translation of %s.
Por favor, indique un nombre de página para la traducción de %s.
More help may be available here: %s.
Más ayuda puede estar disponible aquí: %s.
Translated page:
Página traducida:
Please provide a different page name for the translation.
Por favor, proporcione un nombre de página diferente para la traducción.
################################################################################
# modules/translations.pl
################################################################################
This page is a translation of %s.
Esta página es una translación de %s.
The translation is up to date.
La traducción está actualizada.
The translation is outdated.
Esta traducción es más vieja que la página original, y puede no estar mantenida.
The page does not exist.
La página no existe.
################################################################################
# modules/upgrade.pl
################################################################################
Upgrading Database
Actualizando base de datos
Did the previous upgrade end with an error? A lock was left behind.
¿Terminó la actualización anterior con un error? Un bloqueo se quedó atrás.
Unlock wiki
Desbloquear wiki
Upgrade complete.
Actualización completa.
Upgrade complete. Please remove $ModuleDir/upgade.pl, now.
Actualización completa. Por favor, remueva $ModuleDir/upgade.pl, ahora.
################################################################################
# modules/usemod.pl
################################################################################
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s
http://www.amazon.com/exec/obidos/ISBN=%s
alternate
alternativo
http://www.pricescan.com/books/BookDetail.asp?isbn=%s
search
buscar
################################################################################
# modules/wanted.pl
################################################################################
Wanted Pages
Páginas Wanted
%s pages
% páginas
%s, referenced from:
%s, referenciada desde:
################################################################################
# modules/webapp.pl
################################################################################
Web application for offline browsing
Aplicación web para navegación fuera de línea
################################################################################
# modules/webdav.pl
################################################################################
Upload of %s file
Subida del archivo %s
################################################################################
# modules/weblog-1.pl
################################################################################
Blog
Blog
################################################################################
# modules/weblog-3.pl
################################################################################
Matching pages:
Páginas encontradas:
New
Nuevo
Edit %s.
Editar %s.
################################################################################
# modules/weblog-4.pl
################################################################################
Tags:
Etiquetas:
END_OF_TRANSLATION
