# UTF-8 encoded French language file for use with Oddmuse
#
# Copyright (c) 2003, 2005  Pierre Gaston
# Copyright (c) 2004, 2005  Christophe Ducamp
# Copyright (c) 2010  Alex Schroeder
# Copyright (c) 2012  Aurélien Desbrières
# Copyright (c) 2012  Hervé Robin
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
# This translation was last checked for Oddmuse 2.2.

use utf8;
use strict;

AddModuleDescription('french-utf8.pl', 'French') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Accès interdit : l’utilisateur, l’IP ou le réseau est bloqué.
Login
Se connecter
Error
Erreur
%s calls
%s appel
Cannot create %s
Impossible de créer %s
Include normal pages
Comprend les pages normales
Invalid UserName %s: not saved.
Nom d’utilisateur non valide %s : non sauvegardé.
UserName must be 50 characters or less: not saved
Le nom d’utilisateur ne doit pas dépasser 50 caractères : non sauvegardé
This page contains an uploaded file:
Cette page contient un fichier téléversé :
No summary was provided for this file.
Aucun résumé fourni pour ce fichier.
Recursive include of %s!
Inclusion par récursivité de %s !
Clear Cache
Effacer le cache
Main lock obtained.
Verrou principal obtenu.
Main lock released.
Verrou principal rendu.
Journal
Journal
More...
Suivant…
Comments on this page
Commentaires sur cette page
XML::RSS is not available on this system.
XML::RSS n’est pas disponible sur ce système.
diff
diff
history
historique
%s returned no data, or LWP::UserAgent is not available.
%s n’a pas retourné de données, ou LWP::UserAgent n’est pas disponible.
RSS parsing failed for %s
L’analyse du RSS de %s a échoué
No items found in %s.
Pas d’objets trouvés dans %s.
 . . . .
 . . . .
Click to edit this page
Cliquez pour éditer cette page
CGI Internal error: %s
Erreur Interne CGI : %s
Invalid action parameter %s
Parmètre d’action invalide %s
Page name is missing
Le nom de la page est manquant
Page name is too long: %s
Le nom de la page est trop long : %s
Invalid Page %s (must not end with .db)
Page non valide %s (ne doit pas se terminer par .db)
Invalid Page %s (must not end with .lck)
Page non valide %s (ne doit pas se terminer par .lck)
Invalid Page %s
Page non valide %s
There are no comments, yet. Be the first to leave a comment!
Pas encore de commentaires. Soyez le premier à laisser un commentaire !
Welcome!
Bienvenue !
This page does not exist, but you can %s.
Cette page n’existe pas, mais vous pouvez %s.
create it now
la créer maintenant
Too many redirections
Trop de redirections
No redirection for old revisions
Pas de redirection pour les versions anciennes
Invalid link pattern for #REDIRECT
Syntaxe invalide pour le lien de redirection (#REDIRECT)
Please go on to %s.
SVP allez à %s.
Updates since %s
Mises à jour depuis %s
up to %s
jusqu’à %s
Updates in the last %s days
Mises à jour durant les derniers %s jours
Updates in the last day
Mises à jour durant le dernier jour
for %s only
pour %s seulement
List latest change per page only
Lister seulement les dernières modifications par page
List all changes
Lister toutes les modifications
Skip rollbacks
Sans les retours en arrière
Include rollbacks
Inclure les retours en arrière
List only major changes
Lister seulement les modifications majeures
Include minor changes
Inclure les modifications mineures
days
jours
List later changes
Lister les modifications plus récentes
RSS
RSS
RSS with pages
RSS avec pages
RSS with pages and diff
RSS avec pages et différences
Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.

Filters
Filtres
Title:
Titre :
Title and Body:
Titre et Corps :
Username:
Nom d’utilisateur :
Host:
Hôte :
Follow up to:
Modifications suivant :
Language:
Langue :
Go!
Allez-y !
(minor)
(mineur)
rollback
retour en arrière
new
nouveau
All changes for %s
Tous les changements pour %s
This page is too big to send over RSS.
Cette page est trop grande pour être envoyée sur RSS
History of %s
Historique de %s
Using the ｢rollback｣ button on this page will reset the page to that particular point in time, undoing any later changes to this page.

Compare
Comparer
Deleted
Supprimé(e)
Mark this page for deletion
Marquer cette page comme étant à supprimer
No other revisions available
Il n’y a pas d’autre version
current
actuelle
Revision %s
Version %s
Contributors to %s
Contributeurs à %s
Missing target for rollback.
Cible manquante pour le retour en arrière.
Target for rollback is too far back.
La cible du retour en arrière est trop ancienne.
A username is required for ordinary users.
Un nom d’utilisateur est nécessaire pour les utilisateurs normaux
Rolling back changes
Réinitialisation en cours
Editing not allowed: %s is read-only.
Modification interdite : %s est en lecture seule.
Rollback of %s would restore banned content.
Un retour à %s restaurera du contenu interdit.
Rollback to %s
Retour à %s
%s rolled back
Retour en arrière pour %s
to %s
à %s
Index of all pages
Index de toutes les pages
Wiki Version
Affiche la version du wiki
Password
Mot de passe
Run maintenance
Lancer la maintenance
Unlock Wiki
Suppression du verrou
Unlock site
Déverrouiller le site
Lock site
Verouiller le site
Unlock %s
Déverrouiller %s
Lock %s
Verrouiller %s
Administration
Administration
Actions:
Actions :
Important pages:
Pages importantes :
To mark a page for deletion, put <strong>%s</strong> on the first line.
Pour marquer une page comme étant à supprimer, ajoutez <strong>%s</strong> à la première ligne
Anonymous
Anonyme
redirected from %s
redirigé(e) à partir de %s
%s:
%s :
[Home]
[Accueil]
Click to search for references to this page
Cliquer pour chercher des références vers cette page
Edit this page
Modifier cette page
Preview:
Prévisualisation :
Preview only, not yet saved
Prévisualisation seulement, pas encore sauvegardée
Warning
Attention
Database is stored in temporary directory %s
La base de données est stockée dans le répertoire temporaire %s
%s seconds
%s secondes
Last edited
Dernière modification
Edited
Modifié(e)
by %s
par %s
(diff)
(diff)
a
a
c
c
Edit revision %s of this page
Modifier la version %s de cette page
e
e
This page is read-only
Cette page est en lecture seule
View other revisions
Voir les autres versions
View current revision
Voir la version actuelle
View all changes
Voir toutes les modifications
View contributors
Voir les contributeurs
Add your comment here:
Ajoutez un commentaire :
Homepage URL:
Adresse(URL) du site personnel
s
s
Save
Sauvegarder
p
p
Preview
Prévisualisation
Search:
Rechercher :
f
f
Replace:
Remplacer :
Delete
Supprimer
Filter:
Filtre :
Last edit
Dernière modification
revision %s
version %s
current revision
version actuelle
Difference between revision %1 and %2
Différence entre les versions %1 et %2
Last major edit (%s)
Dernière modification majeure (%s)
later minor edits
modifications mineures suivantes
No diff available.
Pas de diff disponible.
Summary:
Résumé :
Old revision:
Ancienne révision :
Changed:
Modifié(e) :
Deleted:
Supprimé(e) :
Added:
Ajouté(e) :
to
à
Revision %s not available
La version %s n’est pas disponible
showing current revision instead
présentation à la place de la version en cours
Showing revision %s
Présentation de la version %s
Cannot save a nameless page.
Impossible de sauvegarder une page sans nom.
Cannot save a page without revision.
Impossible de sauvegarder une page sans version.
not deleted:
non supprimé(e) :
deleted
supprimé(e)
Cannot open %s
Ne peut pas ouvrir %s
Cannot write %s
Ne peut pas écrire %s
Could not get %s lock
Ne peut obtenir un verrouillage %s
The lock was created %s.
Le verrouillage a été créé %s.
Maybe the user running this script is no longer allowed to remove the lock directory?
Peut-être l’utilisateur exécutant le logiciel n’est-il plus autorisé à effacer le répertoire utilisé pour le verrouillage ?
Sometimes locks are left behind if a job crashes.

After ten minutes, you could try to unlock the wiki.

This operation may take several seconds...
Cette opération peut prendre quelques secondes...
Forced unlock of %s lock.
Suppression forcée du verrou %s.
No unlock required.
La suppression du verrou n’est pas nécessaire.
%s hours ago
il y a %s heures
1 hour ago
il y a une heure
%s minutes ago
il y a %s minutes
1 minute ago
il y a une minute
%s seconds ago
il y a %s secondes
1 second ago
il y a 1 seconde
just now
à l’instant
Only administrators can upload files.
Seuls les administrateurs peuvent téléverser des fichiers.
Editing revision %s of
Modification de la version %s de
Editing %s
Modification de %s
Editing old revision %s.
Modification de l’ancienne version %s.
Saving this page will replace the latest revision with this text.
Sauvegarder cette page remplacera la dernière version par ce texte.
This change is a minor edit.
Cette modification est une édition mineure.
Cancel
Annuler
Replace this file with text
Remplacer ce fichier par un texte
Replace this text with a file
Remplacer ce texte par un fichier
File to upload:
Fichier à téléverser :
Files of type %s are not allowed.
Les fichiers de type %s ne sont pas autorisés.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Votre mot de passe est conservé dans un cookie, si cette fonctionnalité est activée dans votre navigateur. Les cookies peuvent être perdus si vous vous reconnectez à partir d’une autre machine, d’un autre compte ou en utilisant un autre logiciel.
This site does not use admin or editor passwords.
Ce site n’utilise pas de mot de passe pour les administrateurs ou les éditeurs.
You are currently an administrator on this site.
Vous êtes actuellement administrateur de ce site.
You are currently an editor on this site.
Vous êtes actuellement éditeur de ce site.
You are a normal user on this site.
Vous êtes un utilisateur normal de ce site.
You do not have a password set.
Vous n’avez pas défini de mot de passe.
Your password does not match any of the administrator or editor passwords.
Vote mot de passe ne correspond ni au mot de passe administrateur ni au mot de passe éditeur.
Password:
Mot de passe :
Return to %s
Retour à %s
This operation is restricted to site editors only...
Cette opération est réservée aux éditeurs du site seulement...
This operation is restricted to administrators only...
Cette opération est réservée aux administrateurs seulement...
Edit Denied
Modification interdite
Editing not allowed: user, ip, or network is blocked.
Modification interdite : l’utilisateur, l’adresse ip, ou le réseau est bloqué.
Contact the wiki administrator for more information.
Contactez l’administrateur du wiki pour plus d’information.
The rule %s matched for you.
La règle %s a été appliquée pour vous.
See %s for more information.
Voir %s pour plus d’information.
SampleUndefinedPage
ExempleDePageNonDéfinie
Sample_Undefined_Page
Exemple_De_Page_NonDéfinie
Rule "%1" matched "%2" on this page.
La règle "%1" correspondait à "%2" sur cette page.
Reason: %s.
Raison : %s.
Reason unknown.
Raison inconnue.
(for %s)
(pour %s)
%s pages found.
%s pages trouvées.
Preview: %s
Prévisualiser: %s
Replaced: %s
Remplacé(e) : %s
Search for: %s
Rechercher : %s
View changes for these pages
Voir les modifications pour ces pages
last updated
dernière mise à jour
by
par
Transfer Error: %s
Erreur de Transfert : %s
Browser reports no file info.
Le navigateur ne signale pas d’information sur le fichier.
Browser reports no file type.
Le navigateur ne signale pas de type de fichier.
The page contains banned text.
Cette page contient un texte interdit.
No changes to be saved.
Aucun changement à sauvegarder.
This page was changed by somebody else %s.
Cette page a été modifiée par quelqu’un d’autre %s.
The changes conflict.  Please check the page again.
Conflit sur les modifications. SVP vérifiez la page à nouveau.
Please check whether you overwrote those changes.
SVP vérifiez si vous avez écrasé ces modifications.
Cannot delete the index file %s.
Impossible de supprimer le fichier index %s.
Please check the directory permissions.
Veuillez vérifier les permissions des répertoires.
Your changes were not saved.
Vos modifications n’ont pas été sauvegardées
Could not get a lock to merge!
Pas pu obtenir de verrouillage pour la fusion !
you
vous
ancestor
ancêtre
other
autre
Run Maintenance
Lancer la maintenance
Maintenance not done.
Maintenance non effectuée.
(Maintenance can only be done once every 12 hours.)
(La maintenance ne peut être effectuée qu’une fois toutes les 12 heures.)
Remove the "maintain" file or wait.
Enlevez le fichier "maintain" ou patientez.
Expiring keep files and deleting pages marked for deletion
Expiration des fichiers de cache et suppression des pages marquées pour la suppression
Moving part of the %s log file.
Déplace une partie du fichier de log %s.
Could not open %s log file
Impossible d’ouvrir le fichier de log %
Error was
L’erreur était
Note: This error is normal if no changes have been made.
Remarque : Cette erreur est normale si aucune modification n’a été effectuée.
Moving %s log entries.
Déplace %s entrées du log.
Removing IP numbers from %s log entries.

Set or Remove global edit lock
Positionne ou Retire le verrou global d’édition
Edit lock created.
Verrou d’édition créé.
Edit lock removed.
Verrou d’édition enlevé.
Set or Remove page edit lock
Positionne ou enlève le verrou d’édition de la page
Lock for %s created.
Verrou pour %s créé.
Lock for %s removed.
Verrou pour %s enlevé.
Displaying Wiki Version
Affichage de la version du Wiki
Debugging Information
Information pour le déboguage
Too many connections by %s
Trop de connexions par %s
Please do not fetch more than %1 pages in %2 seconds.
Veuillez ne pas télécharger plus de %1 pages toutes les %2 secondes
Check whether the web server can create the directory %s and whether it can create files in it.
Vérifiez si le serveur web peut créer le répertoire %s et s’il peut créer des fichiers dedans.
, see
, voir
The two revisions are the same.
Les deux versions sont identiques.
################################################################################
# modules/admin.pl
################################################################################
Deleting %s
Suppression de %s
Deleted %s
%s supprimé(e)
Renaming %1 to %2.
Renomme %1 en %2.
The page %s does not exist
La page %s n’existe pas
The page %s already exists
La page %s existe déjà
Cannot rename %1 to %2
Impossible de renommer %1 en %2
Renamed to %s
Renommé(e)  en %s
Renamed from %s
Renommé(e) à partir de %s
Renamed %1 to %2.
%1 a été renommé(e) en %2.
Immediately delete %s
Supprimer immédiatement %s
Rename %s to:
Renommer %s en :
################################################################################
# modules/advanced-uploads.pl
################################################################################
Attach file:
Joindre un fichier:
Upload
Uploader
################################################################################
# modules/aggregate.pl
################################################################################
Learn more...
En savoir plus...
################################################################################
# modules/all.pl
################################################################################
Complete Content
Contenu Complet
The main page is %s.
La page principale est %s.
################################################################################
# modules/archive.pl
################################################################################
Archive:
Archive :
################################################################################
# modules/backlinkage.pl
################################################################################
Rebuild BackLink database
Rebâtir les liens de la base de données
Internal Page: %s
Page Interne : %s
Pages that link to this page
Pages liées à cette page
################################################################################
# modules/backlinks.pl
################################################################################
The search parameter is missing.
Le paramètre de recherche est manquant
Pages link to %s
Pages liées à %s
################################################################################
# modules/ban-contributors.pl
################################################################################
Ban contributors

Ban Contributors to %s

Ban!

Regular expression:
Expression régulière :
%s is banned

These URLs were rolled back. Perhaps you want to add a regular expression to %s?

Consider banning the IP number as well:

################################################################################
# modules/banned-regexps.pl
################################################################################
Regular expression "%1" matched "%2" on this page.
Expression régulière "%1" correspond à "%2" sur cette page.
Regular expression "%s" matched on this page.
Expression régulière "%s" correspond à cette page.
################################################################################
# modules/big-brother.pl
################################################################################
Recent Visitors
Derniers Visiteurs
some action
quelque action
was here
était ici
and read
et a lu
################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999
Il faut que l’année soit un valeur entre 0001 et 9999
The match parameter is missing.
Le paramètre de correspondance est manquant.
Page Collection for %s
Liste des pages pour %s
Previous
Précédent
Next
Suivant
Calendar %s
Calendrier %s
Su
Di
Mo
Lu
Tu
Ma
We
Me
Th
Je
Fr
Ve
Sa
Sa
January
janvier
February
février
March
mars
April
avril
May
mai
June
juin
July
juillet
August
août
September
septembre
October
octobre
November
novembre
December
décembre
################################################################################
# modules/checkbox.pl
################################################################################
set %s
paramétrer %s
unset %s
dé-paramétrer %s
################################################################################
# modules/clustermap.pl
################################################################################
Clustermap
Carte du Faisceau
Pages without a Cluster
Pages sans Faisceau
################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:
Commentaires :
################################################################################
# modules/commentcount.pl
################################################################################
Comments on
Commentaires sur
Comment on
Commentaire sur
################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s
Compilation pour %s
Compilation tag is missing a regular expression.
Une expression régulière manque au tag de compilation.
################################################################################
# modules/creationdate.pl
################################################################################
Add creation date to page files
Ajouter une date de création aux fichiers des pages
################################################################################
# modules/css-install.pl
################################################################################
Install CSS
Installer CSS
Copy one of the following stylesheets to %s:
Copier une des feuilles de style suivantes sur %s.
Reset
Réinitialiser
################################################################################
# modules/dates.pl
################################################################################
Extract all dates from the database
Extraire toutes les dates depuis la base de données
Dates
Dates
No dates found.
Aucune date trouvée
################################################################################
# modules/despam.pl
################################################################################
List spammed pages
Lister les pages spammées
Despamming pages
Suppression des textes indésirables sur les pages.
Spammed pages
Pages spammées
Cannot find revision %s.
Impossible de trouver la version %s.
Revert to revision %1: %2
Retour à la version %1 : %2
Marked as %s.
Marqué(e) comme %s.
Cannot find unspammed revision.
Impossible de trouver une version sans texte indésirable.
################################################################################
# modules/diff.pl
################################################################################
Page diff
Page diff
Diff
Diff
################################################################################
# modules/drafts.pl
################################################################################
Recover Draft
Récupérer le brouillon
No text to save
Aucun texte à sauvegarder
Draft saved
Brouillon sauvegardé
Draft recovered
Brouillon récupéré
No draft available to recover
Aucun brouillon à récupérer
Save Draft
Sauvegarder le Brouillon
Draft Cleanup
Nettoyer le Brouillon
Unable to delete draft %s
Impossible d'effacer le brouillon %s
%1 was last modified %2 and was kept
%1 a été modifié(e) en dernier et %2 a été conservé(e)
%1 was last modified %2 and was deleted
%1 a été modifié(e) en dernier et %2 a été effacé(e)
################################################################################
# modules/dynamic-comments.pl
################################################################################
Add Comment
Ajouter un commentaire
################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes
modifications ordinaires
%s days
%s jours
################################################################################
# modules/edit-paragraphs.pl
################################################################################
Could not identify the paragraph you were editing
Impossible d'identifier le paragraphe que vous avez édité
This is the section you edited:
C’est la section que vous avez éditée :
This is the current page:
C’est la page actuelle
################################################################################
# modules/find.pl
################################################################################
Matching page names:
Pages correspondant aux noms :
################################################################################
# modules/fix-encoding.pl
################################################################################
Fix character encoding
Corriger l’encodage des caractères
Fix HTML escapes
Corriger les caractères d’échappement HTML
################################################################################
# modules/form_timeout.pl
################################################################################
Set $FormTimeoutSalt.
Définir $FormTimeoutSalt.
Form Timeout

################################################################################
# modules/gd_security_image.pl
################################################################################
GD or Image::Magick modules not available.
modules GD ou Image::Magick non disponibles.
GD::SecurityImage module not available.
module GD::SecurityImage non disponible.
Image storing failed. (%s)
Erreur d’enregistrement de l’image. (%s)
Bad gd_security_image_id.
Invalide gd_security_image_id.
Please type the six characters from the anti-spam image
Entrez les six caractères de l’image anti-spam
Submit
Soumettre
CAPTCHA
CAPTCHA
You did not answer correctly.
Vous n’avez pas répondu correctement.
$GdSecurityImageFont is not set.
$GdSecurityImageFont n’est pas défini.
################################################################################
# modules/git-another.pl
################################################################################
No summary provided
Aucun résumé fourni
################################################################################
# modules/git.pl
################################################################################
no summary available
aucun résumé disponible
page was marked for deletion
page marquée pour suppression
Oddmuse
Oddmuse
Cleaning up git repository
Nettoyage du dépôt git
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
Courriel :
################################################################################
# modules/header-and-footer-templates.pl
################################################################################
Could not find %1.html template in %2
Impossible de trouver le modèle %1.html dans %2
################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.
Seuls les Éditeurs ont l'autorisation de voir cette page cachée.
Only Admins are allowed to see this hidden page.
Seuls les Administrateurs ont l'autorisation de voir cette page cachée.
################################################################################
# modules/index.pl
################################################################################
Index
Index
################################################################################
# modules/joiner.pl
################################################################################
The username %s already exists.
Le nom d’utilisateur %s existe déjà.
The email address %s has already been used.
L’adresse courriel %s a déjà été utilisée.
Wait %s minutes before try again.
Attendez %s minutes avant de réessayer.
Registration Confirmation
Confirmation de l’enregistrement
Visit the link below to confirm registration.
Visitez le lien ci-dessous pour confirmer l’enregistrement.
Recover Account
Restaurer le compte
You can login by following the link below. Then set new password.

Change Email Address
Changer l’adresse courriel
To confirm changing email address, follow the link below.

To submit this form you must answer this question:

Question:
Question:
CAPTCHA:
CAPTCHA:
Registration
Enregistrement
The username must be valid page name.
Le nom d’utilisateur doit être un nom de page valide.
Confirmation email will be sent to the email address.
Un courriel de confirmation sera envoyé à l’adresse courriel.
Repeat Password:
Répétez le mot de passse :
Bad email address format.
Format d’adresse courriel invalide.
Password needs to have at least %s characters.
Le mot de passe doit avoir au moins %s caractères.
Passwords differ.
Mots de passe différents.
Email Sent
Courriel envoyé
Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.
Courriel de confirmation envoyé à %s. Visitez le lien du courriel de confirmation d'enregistrement.
Failed to Confirm Registration
Echec de confirmation d'enregistrement.
Invalid key.
Clé non valide.
The key expired.
Clé expirée.
Registration Confirmed

Now, you can login by using username and password.

Forgot your password?
Mot de passe oublié ?
Login failed.
Connexion échouée.
You are banned.

You must confirm email address.
Vous devez confirmer l'adresse courriel.
Logged in
Connecté
%s has logged in.
%s est connecté
You should set new password immediately.
Vous devriez définir un nouveau mot de passe immédiatement.
Change Password
Changer le mot de passe
Logged out
Déconnecté
%s has logged out.
%s s’est déconnecté
Account Settings
Paramètres de compte
Logout
Se déconnecter
Current Password:
Mot de passe actuel:
New Password:
Nouveau mot de passe:
Repeat New Password:
Répétez le mot de passe:
Password is wrong.
Mot de passe incorrect.
Password Changed
Mot de passe modifié
Your password has been changed.
Votre mot de passe a été modifié.
Forgot Password
Mot de passe oublié
Enter email address, and recovery login ticket will be sent.
Entrez une adresse courriel, un ticket de récupération de connexion sera envoyé.
Not found.
Non trouvé.
The mail address is not valid anymore.
L’adresse courriel n’est plus valide.
An email has been sent to %s with further instructions.
Un courriel a été envoyé à %s avec les instructions complémentaires.
New Email Address:
Nouvelle adresse courriel:
Failed to load account.
Echec du chargement du compte.
An email has been sent to %s with a login ticket.
Un courriel a été envoyé à %s avec un ticket de connexion.
Confirmation Failed
Echec de confirmation
Failed to confirm.
Echec de confirmation
Email Address Changed
Adresse courriel modifiée
Email address for %1 has been changed to %2.
Adresse courriel pour %1 modifiée en %2.
Account Management
Gestion des comptes
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
Enregistrement
################################################################################
# modules/lang.pl
################################################################################
Languages:
Langues :
Show!
Voir !
################################################################################
# modules/like.pl
################################################################################
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!
J’aime!
################################################################################
# modules/link-all.pl
################################################################################
Define
Définir
################################################################################
# modules/links.pl
################################################################################
Full Link List
Liste Complète des Liens
################################################################################
# modules/list-banned-content.pl
################################################################################
Banned Content

Rule "%1" matched on this page.

################################################################################
# modules/listlocked.pl
################################################################################
List of locked pages
Liste des pages verrouillées
################################################################################
# modules/listtags.pl
################################################################################
Pages tagged with %s
Pages taguées avec %s
################################################################################
# modules/live-templates.pl
################################################################################
Template without parameters
Modèle sans paramètres
The template %s is either empty or does not exist.
Le modèle %s est soit vide soit n'existe pas.
################################################################################
# modules/localnames.pl
################################################################################
Name:
Nom :
URL:
URL:
Define Local Names

Define external redirect:

 -- defined on %s
 -- défini(e) sur %s
Local names defined on %1: %2
Noms locaux définis sur %1 : %2
################################################################################
# modules/logbannedcontent.pl
################################################################################
IP number matched %s
Numéro IP correspond à %s
################################################################################
# modules/login.pl
################################################################################
Register for %s
Enregistrer pour %s
Please choose a username of the form "FirstLast" using your real name.
SVP choisissez un nom d'utilisateur sous la forme "PrénomNom" en utilisant votre vrai nom.
The passwords do not match.
Les mots de passe ne correspondent pas.
The password must be at least %s characters.
Le mot de passe doit être au moins de %s caractères.
That email address is invalid.
Cette adresse e-mail n'est pas valide.
The username %s has already been registered.
Le nom d'utilisateur %s a déjà été enregistré.
Your registration for %s has been submitted.
Votre enregistrement pour %s a été soumis.
Please allow time for the webmaster to approve your request.
SVP accordez un peu de temps au webmestre pour valider votre demande.
An email has been sent to "%s" with further instructions.
Un e-mail a été envoyé à "%s" pour de plus amples instructions.
There was an error saving your registration.
Il y a eu une erreur au moment de sauvegarder votre enregistrement.
An account was created for %s.
Un compte a été créé pour %s
Login to %s
Se connecter sur %s
Username and/or password are incorrect.
Le nom d'utilisateur et/ou le mot de passe sont incorrects.
Logged in as %s.
Connecté(e) sous %s.
Logout of %s
Déconnexion de %s
Logout of %s?
Déconnexion de %s ?
Logged out of %s
Déconnecté(e) de %s
You are now logged out.
Vous êtes maintenant déconnecté(e).
Register a new account
Enregistrer un nouveau compte.
Who am I?
Qui suis-je ?
Change your password
Changer votre mot de passe
Approve pending registrations
Accepter les enregistrements en attente
Confirm Registration for %s
Confirmation d'Enregistrement pour %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s, votre enregistrement a été accepté. Vous pouvez désormais utiliser votre mot de passe pour vous connecter et éditer ce wiki.
Confirmation failed.  Please email %s for help.
Échec sur la confirmation. SVP envoyez un e-mail à %s pour obtenir de l'aide.
Who Am I?
Qui suis-je ?
You are logged in as %s.
Vous êtes connecté(e) en tant que %s.
You are not logged in.
Vous n'êtes pas connecté(e).
Reset Password
Réinitialiser le mot de passe.
The password for %s was reset.  It has been emailed to the address on file.
Le mot de passe pour %s a été réinitialisé. Il a été envoyé à l'adresse spécifiée sur le fichier.
There was an error resetting the password for %s.
Il y a eu une erreur de réinitialisation du mot de passe pour %s.
The username "%s" does not exist.
Le nom d'utilisateur "%s" n'existe pas.
Reset Password for %s
Réinitialiser le mot de passe pour %s
Reset Password?
Réinitialisation du Mot de Passe ?
Change Password for %s
Modification du Mot de Passe pour %s
Change Password?
Modification du Mot de Passe ?
Your current password is incorrect.
Votre Mot de Passe est incorrect.
Approve Pending Registrations for %s
Accepter les Enregistrements en Attente pour %s
%s has been approved.
%s a été accepté(e).
There was an error approving %s.
Il y a eu une erreur en acceptant %s.
There are no pending registrations.
Il n'y a pas d'enregistrements en attente.
################################################################################
# modules/mail.pl
################################################################################
Invalid Mail %s: not saved.
L’adresse e-mail %s n’est pas valide
unsubscribe
se désabonner
subscribe
s'abonner
%s appears to be an invalid mail address
L’adresse e-mail %s n’est pas valide
Your mail subscriptions
Votre abonnements
All mail subscriptions
Tous les abonnements e-mail
Subscriptions
Abonnements
Email:
Courriel :
Show
Voir
Subscriptions for %s:
Abonnements pour %s :
Unsubscribe
Se désabonner
There are no subscriptions for %s.
Il n’y a pas d’abonnements pour %s.
Change email address
Changer l’adresse e-mail
Mail addresses are linked to unsubscription links.
Les adresses e-mail sont liées au désabonnement.
Subscribe to %s.
S'abonner %s.
Subscribe
S'abonner
Subscribed %s to the following pages:
%s est abonné aux pages suivantes :
The remaining pages do not exist.
Les pages restantes n’existent pas (ou plus).
Unsubscribed %s from the following pages:
%s est désabonné aux pages suivantes :
Migrating Subscriptions

No non-migrated email addresses found, migration not necessary.

Migrated %s rows.

################################################################################
# modules/markdown-converter.pl
################################################################################
Help convert %s to Markdown

List all non-Markdown pages

Converting %s
Conversion de %s
Candidates for Conversion to Markdown

################################################################################
# modules/module-bisect.pl
################################################################################
Bisect modules
Modules Bisect
Module Bisect
Module Bisect
All modules enabled now!
Tous les modules activés maintenant !
Go back
Retour
Test / Always enabled / Always disabled

Start
Démarrer
Bisecting proccess is already active.

Stop
Stop
It seems like module %s is causing your problem.
Le module %s sembler causer votre problème.
Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).

Good luck fixing your problem! ;)

Module count (only testable modules):

Current module statuses:
Statuts du module courant :
Good
Bon
Bad
Mauvais
Enabling %s
Activer %s
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
Vous avez créé plus de %s liens vers le même domaine. Il semble que seuls les spammeurs font cela. Votre édition est donc refusée.
################################################################################
# modules/namespaces.pl
################################################################################
%s is not a legal name for a namespace
%s n’est pas un nom valide pour un espace de noms
Namespaces
Espaces de noms
################################################################################
# modules/near-links.pl
################################################################################
Getting page index file for %s.
Récupération du fichier d'index de %s.
Near links:
Liens de proximité :
Search sites on the %s as well
Rechercher aussi les sites présents sur %s
Fetching results from %s:
Récupération des résultats à partir de %s :
Near pages:
Pages à proximité :
Include near pages
Inclure les pages de proximité
EditNearLinks
ÉditerLiensDeProximité
The same page on other sites:
La même page sur d'autres sites :
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)
 (créer localement)
################################################################################
# modules/no-question-mark.pl
################################################################################
image
image
download
télécharger
################################################################################
# modules/nosearch.pl
################################################################################
Backlinks
Liens en retour
################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache
Nettoyage du cache.
Done.
Effectué.
Generating Link Database
Création de la base de données de liens
The 404 handler extension requires the link data extension (links.pl).
L'extension "404 handler" nécessite une base de données de liens (links.pl).
################################################################################
# modules/offline.pl
################################################################################
Make available offline
Rendre disponible hors ligne
Offline
Hors ligne
You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

################################################################################
# modules/olocalmap.pl
################################################################################
LocalMap
CarteLocale
No page id for action localmap
Aucune page id pour actionner la carte locale
Requested page %s does not exist
La page demandée %s n'existe pas
Local Map for %s
Carte Locale pour %s
view
voir
################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s
Auto-bannissement par %s
You have banned your own IP.
Vous avez banni votre propre IP.
################################################################################
# modules/orphans.pl
################################################################################
Orphan List
Liste Orpheline
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
Trace :
################################################################################
# modules/page-type.pl
################################################################################
None
Aucune
Type
Type
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"
Lien permanent vers "%s"
anchor first defined here: %s
première ancre définie ici : %s
the page %s also exists
la page %s existe également
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Cliquer pour chercher des références vers cette ancre permanente
Include permanent anchors
Inclure les ancres permanentes
################################################################################
# modules/portrait-support.pl
################################################################################
Portrait
Portrait
################################################################################
# modules/preview.pl
################################################################################
Pages with changed HTML
Pages avec HTML modifié
Preview changes in HTML output
Visualiser les changenements de la sortie HTML
################################################################################
# modules/private-pages.pl
################################################################################
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now
donner le mot de passe maintenant
################################################################################
# modules/private-wiki.pl
################################################################################
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.
Tentative de lire des données cryptés sans mot de passe.
Cannot refresh index.
Impossible de mettre à jour l'index
################################################################################
# modules/publish.pl
################################################################################
Publish %s
Publier %s
No target wiki was specified in the config file.
La cible du wiki n'est pas spécifiée dans le fichier de configuration.
The target wiki was misconfigured.
La cible du wiki a été mal configurée.
################################################################################
# modules/put.pl
################################################################################
Upload is limited to %s bytes
Le téléversement est limité à %s bytes
################################################################################
# modules/questionasker.pl
################################################################################
To save this page you must answer this question:
Vous devez répondre à cette question pour sauvegarder la page :
################################################################################
# modules/recaptcha.pl
################################################################################
Please type the following two words:
Tapez s'il vous plaît les deux mots suivants :
Please answer this captcha:
Répondez à ce captcha s'il vous plaît :
################################################################################
# modules/referrer-rss.pl
################################################################################
Referrers
Référants
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Tous les Référants
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s
Liste des pages pour %s
################################################################################
# modules/small.pl
################################################################################
Index of all small pages
Index de toutes les pages de petite taille
################################################################################
# modules/sort.pl
################################################################################
Sort alphabetically
Trier alphabétiquement
Sorted alphabetically
Trié alphabétiquement
Sorted by last update first
Trié par dernière modification en premier
Sort by last update
Trier par dernière modification
Sorted by creation date
Trié par date de création
Sort by creation date
Trier par date de création
################################################################################
# modules/static-copy.pl
################################################################################
Static Copy
Copie Statique
Back to %s
Retour à %s
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Modification non autorisée pour %s.
################################################################################
# modules/svg-edit.pl
################################################################################
Edit image in the browser
Éditer l'image dans le navigateur
Summary of your changes:
Résumé de tous vos changements :
################################################################################
# modules/sync.pl
################################################################################
Copy to %1 succeeded: %2.
Copie vers %1 réussie : %2.
Copy to %1 failed: %2.
Copie vers %1 échouée : %2.
################################################################################
# modules/tags.pl
################################################################################
Tag
Tag
Feed for this tag
Flux pour ce tag
Tag Cloud
Nuage de Tags
Rebuilding index not done.
Reconstruction de l'index non effectuée.
(Rebuilding the index can only be done once every 12 hours.)
(La reconstruction de l'index ne peut être effectuée qu'une fois toutes les 12 heures.)
Rebuild tag index
Rebâtir votre index de tags
list tags
liste de tags
tag cloud
nuage de tags
################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Alternativement, utilisez un des modèles suivants :
################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.
Trop d'instances. %s seulement est autorisée
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Essayez plus tard s'il vous plaît. Peut-être que quelqu'un effectue une maintenance ou une recherche volumineuse. Malheureusement le site a des ressources limitées, nous vous demandons de faire preuve d'un peu de patience.
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
%s n’a produit aucun résultat
Failed to parse %s.

################################################################################
# modules/timezone.pl
################################################################################
Timezone
Fuseau horaire
Pick your timezone:
Sélectionnez votre fuseau horaire
Set
Ajusté
################################################################################
# modules/toc-headers.pl
################################################################################
Contents
Contenus
################################################################################
# modules/today.pl
################################################################################
Create a new page for today
Ajouter une page nouvelle pour aujourd’hui
################################################################################
# modules/translation-links.pl
################################################################################
Add Translation
Ajouter une traduction
Added translation: %1 (%2)
Traduction ajoutée : %1 (%2)
Translate %s
Traduire %s
Thank you for writing a translation of %s.
Merci pour la traduction de %s.
Please indicate what language you will be using.
Merci d’indiquer quelle langue vous allez utiliser.
Language is missing
La langue est manquante
Suggested languages:
Langues suggérées
Please indicate a page name for the translation of %s.
Indiquez s’il vous plaît un nom de page pour la traduction de %s.
More help may be available here: %s.
Plus d'aide disponible ici : %s.
Translated page:
Page traduite :
Please provide a different page name for the translation.
Donnez s'il vous plait un nom différent à votre traduction
################################################################################
# modules/translations.pl
################################################################################
This page is a translation of %s.
Cette page est une traduction de %s.
The translation is up to date.
La traduction est à jour.
The translation is outdated.
La traduction n'est plus à jour.
The page does not exist.
La page n'existe pas.
################################################################################
# modules/upgrade.pl
################################################################################
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki
Déverrouiller le wiki
Upgrade complete.
Mise à jour terminée
Upgrade complete. Please remove $ModuleDir/upgade.pl, now.
Mise à jour terminée. SVP, supprimez $ModuleDir/upgade.pl maintenant.
################################################################################
# modules/usemod.pl
################################################################################
http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s
http://www.amazon.fr/exec/obidos/ISBN=%s
alternate
Alternative
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
chercher
################################################################################
# modules/wanted.pl
################################################################################
Wanted Pages
Pages recherchées
%s pages
%s pages
%s, referenced from:
%s, référencé(e) depuis :
################################################################################
# modules/webapp.pl
################################################################################
Web application for offline browsing

################################################################################
# modules/webdav.pl
################################################################################
Upload of %s file
Téléversement du fichier %s
################################################################################
# modules/weblog-1.pl
################################################################################
Blog
Blog
################################################################################
# modules/weblog-3.pl
################################################################################
Matching pages:
Pages correspondantes :
New
Nouveau
Edit %s.
Éditer %s.
################################################################################
# modules/weblog-4.pl
################################################################################
Tags:
Tags :
#
END_OF_TRANSLATION
