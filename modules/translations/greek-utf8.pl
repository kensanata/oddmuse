# UTF-8 encoded German translation file for use with Oddmuse
#
# Copyright (c) 2008 Giorgos Keramidas <keramida@freebsd.org>
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
use utf8;
use strict;

AddModuleDescription('greek-utf8.pl', 'Greek') if defined &AddModuleDescription;

our %Translate = split(/\n/,<<'END_OF_TRANSLATION');
This page is empty.

Add your comment here:

Reading not allowed: user, ip, or network is blocked.
Η ανάγνωση δεν επιτρέπεται: αυτός ο χρήστης, η διεύθυνση, ή το δίκτυο έχουν μπλοκαριστεί.
Login
Είσοδος
Error
Σφάλμα
%s calls
%s κλήσεις
Cannot create %s
Σφάλμα δημιουργίας του %s
Include normal pages
Με τις κανονικές σελίδες.
Invalid UserName %s: not saved.
Μη έγκυρο ΌνομαΧρήστη %s: δεν αποθηκεύθηκε.
UserName must be 50 characters or less: not saved
Το ΌνομαΧρήστη πρέπει να είναι το πολύ 50 χαρακτήρες: δεν αποθηκεύθηκε.
This page contains an uploaded file:
Αυτή η σελίδα περιέχει ένα μεταφορτωμένο αρχείο:
No summary was provided for this file.

Recursive include of %s!
Αναδρομική συμπερίληψη του %s
Clear Cache
Καθαρισμός Cache
Main lock obtained.
Το κεντρικό κλείδωμα έχει ενεργοποιηθεί.
Main lock released.
Το κεντρικό κλείδωμα έχει απενεργοποιηθεί.
Journal
Ημερολόγιο
More...
Περισσότερα...
Comments on this page
Σχόλια για αυτή τη σελίδα
XML::RSS is not available on this system.
Το άρθρωμα XML::RSS δεν είναι διαθέσιμο σε αυτό το σύστημα.
diff
διαφορές
history
ιστορικό
%s returned no data, or LWP::UserAgent is not available.
το %s δεν επέστρεψε καθόλου δεδομένα, ή το LWP::UserAgent δεν είναι διαθέσιμο.
RSS parsing failed for %s
Η ανάλυση RSS απέτυχε για το %s
No items found in %s.
Δε βρέθηκαν στοιχεία στο %s.
 . . . . 
 . . . . 
Click to edit this page
Πατήστε εδώ για να επεξεργαστείτε αυτή τη σελίδα
CGI Internal error: %s
Εσωτερικό Σφάλμα CGI: %s
Invalid action parameter %s
Μη έγκυρη παράμετρος action: %s
Page name is missing
Λείπει το όνομα της σελίδας
Page name is too long: %s
Πολύ μεγάλο όνομα σελίδας: %s
Invalid Page %s (must not end with .db)
Μη έγκυρο όνομα σελίδας %s (δεν επιτρέπεται να τελειώνει σε .db)
Invalid Page %s (must not end with .lck)
Μη έγκυρο όνομα σελίδας %s (δεν επιτρέπεται να τελειώνει σε .lck)
Invalid Page %s
Μη έγκυρη σελίδα %s
Too many redirections

No redirection for old revisions

Invalid link pattern for #REDIRECT

Please go on to %s.
Παρακαλώ δείτε το %s.
Updates since %s
Ενημερώσεις από %s
up to %s

Updates in the last %s days
Ενημερώσεις που έγιναν τις τελευταίες %s ημέρες
Updates in the last day
Ενημερώσεις την τελευταία ημέρα
for %s only
μόνο για %s
List latest change per page only
Αναφορά μόνο της τελευταίας αλλαγής για κάθε σελίδα
List all changes
Αναφορά όλων των αλλαγών
Skip rollbacks
Χωρίς τις επαναφορές σελίδας
Include rollbacks
Με τις επαναφορές σελίδας
List only major changes
Αναφορά μόνο των μεγάλων αλλαγών
Include minor changes
Αναφορά και των μικρών αλλαγών
%s days
%s ημέρες
%s day

List later changes
Αναφορά πιο πρόσφατων αλλαγών
RSS
RSS
RSS with pages
RSS με σελίδες
RSS with pages and diff
RSS με σελίδες και διαφορές
Filters
Φίλτρα
Title:
Τίτλος:
Title and Body:
Τίτλος και Κείμενο:
Username:
Όνομα χρήστη:
Host:
Μηχάνημα:
Follow up to:
Απάντηση στο:
Language:
Γλώσσα:
Go!
Αναζήτηση!
(minor)
(μικροαλλαγή)
rollback
επαναφορά
new
νέα σελίδα
All changes for %s
Όλες οι αλλαγές για το %s
This page is too big to send over RSS.
Αυτή η σελίδα είναι πολύ μεγάλη για αποστολή μέσω RSS.
History of %s
Ιστορικό του %s
Compare
Σύγκριση
Deleted
Διαγράφηκε
Mark this page for deletion
Σημείωση αυτής της σελίδας για διαγραφή
No other revisions available
Δεν υπάρχουν άλλες εκδόσεις
current
τρέχουσα έκδοση
Revision %s
Έκδοση %s
Contributors to %s
Συνεισφέροντες για το %s
Missing target for rollback.
Χρειάζεται μια έκδοση προς επαναφορά.
Target for rollback is too far back.
Η έκδοση προς επαναφορά είναι πολύ παλιά.
A username is required for ordinary users.
Χρειάζεται όνομα χρήστη για τους απλούς χρήστες.
Rolling back changes
Επαναφορά παλιότερων εκδόσεων
Editing not allowed: %s is read-only.
Δεν επιτρέπεται η επεξεργασία: το %s είναι μόνο για ανάγνωση.
Rollback of %s would restore banned content.

Rollback to %s
Επαναφορά σε %s
%s rolled back
έγινε επαναφορά του %s
to %s
σε %s
Index of all pages
Κατάλογος όλων των σελίδων
Wiki Version
Έκδοση του Wiki
Password
Κωδικός
Run maintenance
Εκκίνηση συντήρησης
Unlock Wiki
Ξεκλείδωμα του Wiki
Unlock site
Ξεκλείδωμα ιστότοπου
Lock site
Κλείδωμα ιστότοπου
Unlock %s
Ξεκλείδωμα του %s
Lock %s
Κλείδωμα του %s
Administration
Διαχείριση
Actions:
Ενέργειες:
Important pages:
Σημαντικές σελίδες:
To mark a page for deletion, put <strong>%s</strong> on the first line.
Για να σημειωθεί μια σελίδα προς διαγραφή, εισάγετε το κείμενο <strong>%s</strong> στην πρώτη γραμμή της σελίδας.
from %s
από %s
redirected from %s
προώθηση από το %s
%s: 

[Home]
[Αρχική Σελίδα]
Click to search for references to this page
Πατήστε για αναζήτηση αναφορών σε αυτή τη σελίδα
Cookie: 
Cookie: 
Edit this page
Επεξεργασία αυτής της σελίδας
Preview:
Προεπισκόπηση:
Preview only, not yet saved
Προεπισκόπηση σελίδας, δεν έχει αποθηκευθεί ακόμη
Warning
Προειδοποίηση
Database is stored in temporary directory %s
Η βάση δεδομένων έχει αποθηκευθεί στον προσωρινό κατάλογο %s
%s seconds
%s δευτερόλεπτα
Last edited
Τελευταία ενημέρωση
Edited
Ενημέρωση
by %s
από %s
(diff)
(διαφορές)
a

c

Edit revision %s of this page
Επεξεργασία της έκδοσης %s αυτής της σελίδας
e
e
This page is read-only
Αυτή η σελίδα είναι μόνο για ανάγνωση
View other revisions
Προβολή άλλων εκδόσεων
View current revision
Προβολή τρέχουσας έκδοσης
View all changes
Προβολή όλων των αλλαγών
View contributors
Προβολή συνεισφερόντων
Homepage URL:
Διεύθυνση URL Αρχικής Σελίδας:
s
s
Save
Αποθήκευση
p
p
Preview
Προεπισκόπηση
Search:
Αναζήτηση:
f
f
Replace:
Αντικατάσταση με:
Delete
διαγραφή
Filter:
Filter:
Validate HTML
Έλεγχος Εγκυρότητας HTML
Validate CSS
Έλεγχος Εγκυρότητας CSS
Last edit
Τελευταία ενημέρωση
Summary:
Σύνοψη αλλαγών:
Difference between revision %1 and %2
Διαφορές μεταξύ των εκδόσεων %1 και %2
revision %s
Έκδοση %s
current revision
τρέχουσα έκδοση
Last major edit (%s)
Τελευταία μεγάλη αλλαγή (%s)
later minor edits
πιο πρόσφατες μικροαλλαγές
No diff available.
Δεν υπάρχουν διαφορές.
Old revision:
Παλιότερη έκδοση:
Changed:
Αλλαγή:
Deleted:
Διαγραφή:
Added:
Προσθήκη:
to
σε:
Revision %s not available
Η έκδοση %s δεν είναι διαθέσιμη
showing current revision instead
προβολή της τρέχουσας έκδοσης αντί γι αυτή
Showing revision %s
Προβάλλεται η έκδοση %s
Cannot save a nameless page.
Δε μπορεί να αποθηκευθεί μια σελίδα χωρίς όνομα.
Cannot save a page without revision.
Δε μπορεί να αποθηκευθεί μια σελίδα χωρίς έκδοση.
not deleted: 
δε διαγράφηκε: 
deleted
διαγράφηκε
Cannot open %s
Σφάλμα ανάγνωσης του %s
Cannot write %s
Σφάλμα αποθήκευσης του %s
unlock the wiki

Could not get %s lock
Σφάλμα κατά το κλείδωμα του %s
The lock was created %s.
Το %s έχει κλειδώσει.
Maybe the user running this script is no longer allowed to remove the lock directory?

This operation may take several seconds...
Αυτό το βήμα μπορεί να πάρει μερικά δευτερόλεπτα...
Forced unlock of %s lock.
Αναγκαστικό ξεκλείδωμα του %s.
No unlock required.
Δε χρειάζεται ξεκλείδωμα.
%s hours ago
πριν από %s ώρες
1 hour ago
πριν από 1 ώρα
%s minutes ago
πριν από %s λεπτά
1 minute ago
πριν από 1 λεπτό
%s seconds ago
πριν από %s δευτερόλεπτα
1 second ago
πριν 1 από 1 δευτερόλεπτο
just now
μόλις τώρα
Only administrators can upload files.
Μόνο οι διαχειριστές μπορούν να μεταφορτώσουν αρχεία.
Editing revision %s of
Επεξεργασίς της έκδοσης %s του
Editing %s
Επεξεργασία του %s
Editing old revision %s.
Επεξεργασία παλιότερης έκδοσης %s.
Saving this page will replace the latest revision with this text.
Αν αποθηκεύσετε αυτή τη σελίδα, θα αντικαταστήσει την τρέχουσα έκδοση με αυτό το κείμενο.
This change is a minor edit.
Αυτή η αλλαγή είναι μια μικρή αλλαγή.
Cancel
Ακύρωση
Replace this file with text
Αντικατάσταση αυτού του αρχείου με κείμενο.
Replace this text with a file
Αντικατάσταση αυτού του κειμένου από κάποιο αρχείο
File to upload: 
Αρχείο προς μεταφόρτωση: 
Files of type %s are not allowed.
Δεν επιτρέπονται αρχεία τύπου %s.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Ο κωδικός σας αποθηκεύεται σε ένα cookie, όταν έχετε ενεργοποιήσει τα cookies.  Τα cookies όμως μπορεί να μην ισχύουν πλέον ή να χαθούν αν συνδεθείτε από κάποιο άλλο μηχάνημα, από άλλο λογαριασμό, ή χρησιμοποιώντας κάποιο άλλο φυλλομετρητή.
This site does not use admin or editor passwords.
Αυτός ο ιστότοπος δε χρησιμοποιεί κωδικούς διαχειριστή ή κωδικούς εκδότη.
You are currently an administrator on this site.
Αυτή τη στιγμή είστε ένας διαχειριστής σε αυτό το δικτυακό τόπο.
You are currently an editor on this site.
Είστε ένας εκδότης σε αυτό το δικτυακό τόπο.
You are a normal user on this site.
Είστε ένας απλός χρήστης σε αυτό το δικτυακό τόπο.
You do not have a password set.

Your password does not match any of the administrator or editor passwords.
Ο κωδικός σας δεν ταιριάζει με κανένα κωδικό από τους διαχειριστές ή τους εκδότες.
Password:
Κωδικός:
Return to 

This operation is restricted to site editors only...
Αυτή η ενέργεια είναι διαθέσιμη μόνο στους εκδότες του ιστότοπου...
This operation is restricted to administrators only...
Αυτή η ενέργεια είναι διαθέσιμη μόνο στους διαχειριστές του ιστότοπου...
Edit Denied
Απαγορεύεται η Επεξεργασία
Editing not allowed: user, ip, or network is blocked.
Δεν επιτρέπεται η επεξεργασία: αυτός ο χρήστης, η διεύθυνση, ή το δίκτυο έχουν μπλοκαριστεί.
Contact the wiki administrator for more information.
Επικοινωνήστε με το διαχειριστή του wiki για περισσότερες πληροφορίες.
The rule %s matched for you.
Ο κανόνας %s ταίριαξε με εσάς.
See %s for more information.
Δείτε το %s για περισσότερες πληροφορίες.
SampleUndefinedPage
ΠαράδειγμαΑνύπαρκτηςΣελίδας
Sample_Undefined_Page
Παράδειγμα_Ανύπαρκτης_Σελίδας
Rule "%1" matched "%2" on this page.
Ο κανόνας "%1" ταίριαξε με το "%2" σε αυτή τη σελίδα.
Reason: %s.
Λόγος: %s.
Reason unknown.
Άγνωστος λόγος.
(for %s)
(για %s)
%s pages found.
Βρέθηκαν %s σελίδες.
Malformed regular expression in %s

Replaced: %s
Αντικαταστάθηκε: %s
Search for: %s
Αναζήτηση για: %s
View changes for these pages
Προβολή ιστορικού για αυτές τις σελίδες
last updated
τελευταία ενημέρωση
by
από
Transfer Error: %s
Σφάλμα Μεταφοράς: %s
Browser reports no file info.
Ο φυλλομετρητής δεν αναφέρει πληροφορίες για το αρχείο.
Browser reports no file type.
Ο φυλλομετρητής δεν αναφέρει τον τύπο του αρχείου.
The page contains banned text.
Αυτή η σελίδα περιέχει απαγορευμένο κείμενο.
No changes to be saved.
Δεν υπάρχουν αλλαγές για αποθήκευση.
This page was changed by somebody else %s.
Αυτή η σελίδα άλλαξε από κάποιον άλλο %s.
The changes conflict.  Please check the page again.
Οι αλλαγές έρχονται σε σύγκρουση.  Παρακαλώ δείτε τη σελίδα πάλι.
Please check whether you overwrote those changes.
Παρακαλώ ελέγξτε ότι δεν σβήσατε κάποιες από τις αλλαγές.
Anonymous
Ανώνυμος
Cannot delete the index file %s.
Σφάλμα διαγραφής του αρχείου %s.
Please check the directory permissions.
Παρακαλώ ελέγξτε τις άδειες χρήσης του καταλόγου.
Your changes were not saved.
Οι αλλαγές σας δεν αποθηκεύθηκαν.
Could not get a lock to merge!
Σφάλμα κλειδώματος για συγχώνευση των αλλαγών.
you
Εσείς
ancestor
Αρχική σελίδα
other
Άλλος
Run Maintenance
Εκκίνηση Εργασιών Συντήρησης
Maintenance not done.
Η Συντήρηση δεν έγινε.
(Maintenance can only be done once every 12 hours.)
(Η Συντήρηση μπορεί να γίνει μόνο μια φορά κάθε 12 ώρες.)
Remove the "maintain" file or wait.
Σβήστε το αρχείο "maintain" ή περιμένετε.
Expiring keep files and deleting pages marked for deletion
Εκκαθάριση αρχείων και διαγραφή σελίδων σημειωμένων για διαγραφή
Moving part of the %s log file.
Μετακίνηση τμήματος του αρχείου καταγραφής για το %s.
Could not open %s log file
Σφάλμα κατά το άνοιγμα του αρχείου καταγραφής %s
Error was
Το σφάλμα ήταν
Note: This error is normal if no changes have been made.
Σημείωση: Αυτό το σφάλμα δεν είναι σημαντικό αν δεν έχουν γίνει αλλαγές.
Moving %s log entries.
Μετακίνηση %s εγγραφών καταγραφής.
Set or Remove global edit lock
Κλείδωμα ή Ξεκλείδωμα του κεντρικού κλειδώματος εκδότη
Edit lock created.
Το κλείδωμα εκδότη δημιουργήθηκε με επιτυχία.
Edit lock removed.
Το κλείδωμα εκδότη αφαιρέθηκε.
Set or Remove page edit lock
Κλείδωμα ή Ξεκλείδωμα της σελίδας
Lock for %s created.
Το %s κλειδώθηκε.
Lock for %s removed.
Το %s έχει ξεκλειδώσει.
Displaying Wiki Version
Προβολή της Έκδοσης του Wiki
Debugging Information

Too many connections by %s
Υπερβολικός αριθμός συνδέσεων από %s
Please do not fetch more than %1 pages in %2 seconds.
Παρακαλώ μη φορτώνετε πάνω από %s σελίδες σε λιγότερο από %2 δευτερόλεπτα.
Check whether the web server can create the directory %s and whether it can create files in it.
Επιβεβαιώστε ότι ο εξυπηρετητής web μπορεί να δημιουργήσει τον κατάλογο %s και να δημιουργήσει αρχεία σε αυτόν.
, see 

The two revisions are the same.
Οι δύο εκδόσεις είναι πανομοιότυπες.
Deleting %s
Διαγραφή του %s
Deleted %s
Διαγράφηκε το %s
Renaming %1 to %2.
Μετονομασία του %1 σε %2
The page %s does not exist
Η σελίδα %s δεν υπάρχει
The page %s already exists
Η σελίδα %s υπάρχει ήδη
Cannot rename %1 to %2
Η μετονομασία του %1 σε %2 απέτυχε
Renamed to %s
Μετονομάστηκε το %s
Renamed from %s
Μετονομάστηκε από το %s
Renamed %1 to %2.
Μετονομάστηκε το %1 σε %2
Immediately delete %s
Άμεση διαγραφή του %s
Rename %s to:
Μετονομασία του %s σε:
Attach file:

Upload

Learn more...
Περισσότερες πληροφορίες...
Complete Content
Πλήρες Περιεχόμενο
The main page is %s.
Η αρχική σελίδα είναι η %s.
Archive:
Αρχείο:
Rebuild BackLink database
Ανανέωση της βάσης των BackLink
Internal Page: 
Εσωτερική Σελίδα: 
Pages that link to this page
Σελίδες με συνδέσμους προς αυτή τη σελίδα
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
Πρόσφατοι Επισκέπτες
some action
κάποια ενέργεια
was here
ήταν εδώ
and read
και διάβασε το
Illegal year value: Use 0001-9999
Μη-έγκυρη τιμή έτους: Χρησιμοποιήστε μια τιμή μεταξύ 0001-9999
The match parameter is missing.
Λείπει η παράμετρος 'match'
Page Collection for %s
Συλλογή Σελίδων για το %s
Previous
Προηγούμενο
Next
Επόμενο
Calendar %s
Ημερολόγιο %s
Su
Κυ
Mo
Δε
Tu
Τρ
We
Τε
Th
Πε
Fr
Πα
Sa
Σα
January
Ιανουάριος
February
Φεβρουάριος
March
Μάρτιος
April
Απρίλιος
May
Μάιος
June
Ιούνιος
July
Ιούλιος
August
Αύγουστος
September
Σεπτέμβριος
October
Οκτώβριος
November
Νοέμβριος
December
Δεκέμβριος
set %s
ενεργοποίηση του %s
unset %s
απενεργοποίηση του %s
Clustermap
Clustermap
Pages without a Cluster
Σελίδες που δεν ανήκουν σε κάποιο Cluster
Comments:

Comments on 
Σχόλια για το 
Comment on 
Σχόλιο για το 
Compilation for %s
Συλλογή για το  %s
Compilation tag is missing a regular expression.
Λείπει η κανονική έκφραση (regular expression) από την ετικέτα της συλλογής.
Install CSS
Εγκατάσταση CSS
Copy one of the following stylesheets to %s:
Αντιγραφή ενός από τα παρακάτω stylesheets στο %s:
Reset

Extract all dates from the database

Dates

No dates found.

List spammed pages
Λίστα σελίδων με spam
Despamming pages
Αφαίρεση σελίδων από τη λίστα spam
Spammed pages
Σελίδες με spam
Cannot find revision %s.
Η έκδοση %s δεν υπάρχει.
Revert to revision %1: %2
Επαναφορά στην έκδοση %1: %2
Marked as %s.
Σημειώθηκε ως %s.
Cannot find unspammed revision.
Δεν υπάρχει έκδοση χωρίς spam.
Page diff

Diff

Recover Draft
Επαναφορά Πρόχειρου
No text to save
Δεν υπάρχει κείμενο για αποθήκευση
Draft saved
Το Πρόχειρο αποθηκεύθηκε
Draft recovered
Έγινε επαναφορά του Πρόχειρου
No draft available to recover
Δεν υπάρχει πρόχειρο για επαναφορά
Save Draft
Αποθήκευση Πρόχειρου
Draft Cleanup
Εκκαθάριση Πρόχειρων Σελίδων
Unable to delete draft %s
Δε μπορεί να διαγραφεί το πρόχειρο %s
%1 was last modified %2 and was kept
το %1 ενημερώθηκε τελευταία φορά στις %2 και αποθηκεύθηκε
%1 was last modified %2 and was deleted
το %1 ενημερώθηκε τελευταία φορά στις %2 και διαγράφηκε
Add Comment
Προσθήκη Σχολίου
ordinary changes
απλές αλλαγές
Could not identify the paragraph you were editing

This is the section you edited:

This is the current page:

Matching page names:
Σελίδες με όνομα που ταιριάζει:
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
Δεν απαντήσατε σωστά.
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
Δε βρέθηκε το template %1.html sto %2
Only Editors are allowed to see this hidden page.
Αυτή την κρυφή σελίδα μπορούν να τη δουν μόνο οι Εκδότες.
Only Admins are allowed to see this hidden page.
Αυτή την κρυφή σελίδα μπορούν να τη δουν μόνο οι Διαχειριστές.
Index
Κατάλογος
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
Ξεχάσατε τον κωδικό σας;
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
Αποσύνδεση
Current Password:

New Password:

Repeat New Password:

Password is wrong.

Password Changed

Your password has been changed.
Ο κωδικός σας άλλαξε.
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
Γλώσσες:
Show!
Προβολή!
====(\d+) persons? liked this====

====%d persons liked this====

====1 person liked this====

I like this!

Define
Ορισμός
Full Link List
Λίστα Όλων των Συνδέσμων
Banned Content

Rule "%1" matched on this page.

List of locked pages

Pages tagged with %s

Template without parameters
Template χωρίς παραμέτρους
The template %s is either empty or does not exist.
Το template %s είναι άδειο ή δεν υπάρχει.
Name: 

URL: 

Define Local Names

Define external redirect: 

 -- defined on %s
 -- ορίζεται στο %s
Local names defined on %1: %2
Τοπικά ονόματα ορισμένα στο %1: %2
IP number matched %s

Register for %s
Εγγραφή στο %s
Please choose a username of the form "FirstLast" using your real name.
Παρακαλώ επιλέξτε ένα όνομα χρήστη της μορφής "ΜικρόΕπώνυμο" χρησιμοποιώντας το κανονικό σας όνομα.
The passwords do not match.
Οι κωδικοί δεν ταιριάζουν.
The password must be at least %s characters.
Ο κωδικός πρέπει να περιέχει τουλάχιστον %s χαρακτήρες.
That email address is invalid.
Αυτή η διεύθυνση ηλεκτρονικού ταχυδρομείου δεν είναι έγκυρη.
The username %s has already been registered.
Το όνομα χρήστη %s έχει κατοχυρωθεί ήδη.
Your registration for %s has been submitted.
Η εγγραφή σας για το %s έχει καταχωρηθεί.
Please allow time for the webmaster to approve your request.
Παρακαλώ δώστε λίγο χρόνο στο διαχειριστή του συστήματος να εγκρίνει την αίτησή σας.
An email has been sent to "%s" with further instructions.
Έχει αποσταλλεί ένα μήνυμα στη διεύθυνση "%s" με περισσότερες οδηγίες.
There was an error saving your registration.
Η αίτηση εγγραφής σας δε μπόρεσε να αποθηκευθεί.
An account was created for %s.
Δημιουργήθηκε ένας λογαριασμός για το %s.
Login to %s
Σύνδεση στο %s
Username and/or password are incorrect.
Το όνομα χρήστη ή ο κωδικός δεν είναι σωστό.
Logged in as %s.
Έχετε συνδεθεί ως %s.
Logout of %s
Αποσύνδεση από %s
Logout of %s?
Θέλετε να αποσυνδεθείτε από τo λογαριασμό %s;
Logged out of %s
Έχετε αποσυνδεθεί από το λογαριασμό %s
You are now logged out.
Έχετε αποσυνδεθεί.
Register a new account
Δημιουργία νέου λογαριασμού
Who am I?
Με τι όνομα έχω συνδεθεί;
Change your password
Αλλαγή κωδικού
Approve pending registrations
Διαχείριση αιτήσεων προς έγκριση
Confirm Registration for %s
Αποδοχή Εγγραφής για το %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s, η αίτησή σας έχει εγκριθεί.  Τώρα μπορείτε να χρησιμοποιήσετε τον κωδικό σας για να συνδεθείτε και να επεξεργαστείτε αυτό το wiki.
Confirmation failed.  Please email %s for help.
Απέτυχε η επιβεβαίωση.  Παρακαλώ επικοινωνήστε με το email %s για βοήθεια.
Who Am I?
Με τι όνομα έχω συνδεθεί;
You are logged in as %s.
Έχετε συνδεθεί ως %s.
You are not logged in.
Δεν έχετε συνδεθεί.
Reset Password
Επαναφορά Κωδικού
The password for %s was reset.  It has been emailed to the address on file.
Έγινε επαναφορά κωδικού για τον χρήστη %s.  Σας έχει αποσταλλεί στην ηλεκτρονική σας διεύθυνση μέσω email.
There was an error resetting the password for %s.
Η επαναφορά του κωδικού για τον χρήστη %s απέτυχε.
The username "%s" does not exist.
Δεν υπάρχει λογαριασμός χρήστη με το όνομα "%s".
Reset Password for %s
Επαναφορά Κωδικού για τον Χρήστη %s
Reset Password?
Θέλετε να Επαναφέρετε τον Κωδικό σας;
Change Password for %s
Αλλαγή Κωδικού για τον Χρήστη %s
Change Password?
Θέλετε να Αλλάξετε Κωδικό;
Your current password is incorrect.
Ο τρέχων κωδικός σας δεν είναι σωστός.
Approve Pending Registrations for %s
Offene Gesuche für %s bestätigen
%s has been approved.
το %s έχει διαγραφεί.
There was an error approving %s.
Παρουσιάστηκε κάποιο σφάλμα κατά την έγκριση του %s.
There are no pending registrations.
Δεν υπάρχουν εγγραφές προς επικύρωση.
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
το %s δεν είναι έγκυρο όνομα για ένα namespace.
Namespaces

Getting page index file for %s.
Ανάκτηση καταλόγου σελίδας για το %s.
Near links:
Κοντινοί Σύνδεσμοι:
Search sites on the %s as well
Αναζήτηση ιστότοπων και στο %s
Fetching results from %s:
Ανάκτηση αποτελεσμάτων από %s:
Near pages:
Κοντινές σελίδες:
Include near pages
Με τις διπλανές σελίδες
EditNearLinks
ΕπεξεργασίαΚοντινώνΣελίδων
The same page on other sites:
Το ίδιο με άλλους ιστότοπους:
 (create locally)
 (δημιουργία τοπικά)
image
εικόνα
download
μεταφόρτωση
Backlinks

Clearing Cache
Καθαρισμός Cache
Done.
Τέλος.
Generating Link Database
Δημιουργία Βάσης Συνδέσμων
The 404 handler extension requires the link data extension (links.pl).
Η επέκταση χειρισμού σφαλμάτων 404 χρειάζεται την επέκταση link data (links.pl).
Make available offline

Offline

You are currently offline and what you requested is not part of the offline application. You need to be online to do this.

LocalMap
LocalMap
No page id for action localmap
Δεν υπάρχει ID σελίδας για το action localmap
Requested page %s does not exist
Η σελίδα %s που ζητήθηκε δεν υπάρχει
Local Map for %s
LocalMap για το %s
view
προβολή
Self-ban by %s
Αυτο-αποκλεισμός του %s
You have banned your own IP.
Έχετε αποκλείσει την ίδια σας τη διεύθυνση IP.
Orphan List
Λίστα Ορφανών Σελίδων
Trail: 
Μονοπάτι: 
None
Κανένα
Type
Τύπος
Permalink to "%s"
Μόνιμος Σύνδεσμος για το "%s"
anchor first defined here: %s
ο σύνδεσμος έχει οριστεί ήδη εδώ: %s
the page %s also exists
υπάρχει και η σελίδα %s
There was an error generating the pdf for %s.  Please report this to webmaster, but do not try to download again as it will not work.
Υπήρξε κάποιο πρόβλημα με τη δημιουργία pdf για το %s.  Παρακαλώ επικοινωνήστε με το διαχειριστή συστήματος, αλλά μη δοκιμάσετε να κατεβάσετε το pdf πάλι, γιατί δε θα δουλέψει.
Someone else is generating a pdf for %s.  Please wait a minute and then try again.
Κάποιος άλλος δημιουργεί ένα αρχείο pdf για το %s.  Παρακαλώ περιμένετε λίγο και δοκιμάστε πάλι.
Download this page as PDF
Μεταφόρτωση αυτής της σελίδας ως PDF
Click to search for references to this permanent anchor
Πατήστε εδώ για να ψάξετε για αναφορές σε αυτόν τον μόνιμο σύνδεσμο
Include permanent anchors
Με μόνιμες συνδέσεις
Portrait
Portrait
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.

supply the password now

This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.

Attempt to read encrypted data without a password.

Cannot refresh index.

Publish %s
Έκδοση του %s
No target wiki was specified in the config file.
Δεν έχει οριστεί wiki προορισμού στο αρχείο ρυθμίσεων.
The target wiki was misconfigured.
Το wiki προορισμού δεν έχει ρυθμιστεί σωστά.
Upload is limited to %s bytes

To save this page you must answer this question:

Please type the following two words:

Please answer this captcha:

Referrers
Σύνδεσμοι προς Αυτόν τον Ιστότοπο
All Referrers
Όλοι οι Σύνδεσμοι προς Αυτόν τον Ιστότοπο
Page list for %s

Slideshow:%s
Διαφάνειες:%s
Index of all small pages
Κατάλογος όλων των μικρών σελίδων
Static Copy
Στατικό Αντίγραφο
Back to %s
Επιστροφή στο %s
Editing not allowed for %s.
Δεν επιτρέπεται η επεξεργασία του %s.
Edit image in the browser

Summary of your changes: 

Copy to %1 succeeded: %2.
Η αντιγραφή στο %1 ολοκληρώθηκε με επιτυχία: %2.
Copy to %1 failed: %2.
Η αντιγραφή στο %1 απέτυχε: %2.
Tag
Ετικέτα
Feed for this tag

Tag Cloud
Σύννεφο Ετικετών
 ... 
 ... 
Rebuilding index not done.
Η ενημέρωση του καταλόγου δεν έχει ολοκληρωθεί ακόμη.
(Rebuilding the index can only be done once every 12 hours.)
(Η ενημέρωση του καταλόγου μπορεί να γίνει μόνο μία φορά κάθε 12 ώρες.)
Rebuild tag index

list tags

tag cloud

Alternatively, use one of the following templates:
Εναλλακτικά, χρησιμοποιήστε ένα από τα παρακάτω templates:
Too many instances.  Only %s allowed.
Πάρα πολλές ταυτόχρονες αιτήσεις στον εξυπηρετητή αυτής της σελίδας.  Επιτρέπονται μόνο %s ταυτόχρονες συνδέσεις.
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Παρακαλώ δοκιμάστε αργότερα.  Μπορεί κάποιος να τρέχει αυτή τη στιγμή μια εργασία διαχείρισης ή μια μεγάλη αίτηση αναζήτησης.  Δυστυχώς ο ιστότοπος έχει περιορισμένες πηγές, οπότε επαφιόμαστε προς το παρόν στην υπομονή σας.
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
Περιεχόμενα
Create a new page for today
Δημιουργία μιας νέας σελίδας για τη σημερινή ημερομηνία
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
Αυτή η σελίδα είναι μετάφραση της %s. 
The translation is up to date.
Αυτή η μετάφραση είναι ενημερωμένη με τις τελευταίες αλλαγές.
The translation is outdated.
Αυτή η μετάφραση χρειάζεται ενημέρωση.
The page does not exist.
Αυτή η σελίδα δεν υπάρχει.
Upgrading Database

Did the previous upgrade end with an error? A lock was left behind.

Unlock wiki

Upgrade complete.

Upgrade complete. Please remove $ModuleDir/upgade.pl, now.

http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=%s

http://www.amazon.com/exec/obidos/ISBN=%s

alternate
εναλλακτική
http://www.pricescan.com/books/BookDetail.asp?isbn=%s

search
αναζήτηση
Wanted Pages
Επιθυμητές Σελίδες
%s pages
%s σελίδες
%s, referenced from:
%s, αναφέρονται από:
Web application for offline browsing

Upload of %s file
Μεταφόρτωση του αρχείου %s
Blog
Ιστολόγιο
Matching pages:
Σελίδες που ταιριάζουν:
New
Νέο
Edit %s.
Επεξεργασία του %s.
Title: 
Τίτλος: 
Tags: 
Ετικέτες: 
END_OF_TRANSLATION
