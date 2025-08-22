# UTF-8 encoded Indonesian translation file for use with Oddmuse
#
# Copyright (c) 2025  NawanP <saya@nawan.my.id>
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

AddModuleDescription('indonesian-utf8.pl', 'Indonesian') if defined &AddModuleDescription;

our %Translate = grep(!/^#/, split(/\n/,<<'END_OF_TRANSLATION'));
################################################################################
# wiki.pl
################################################################################
Reading not allowed: user, ip, or network is blocked.
Akses tidak diizinkan: pengguna, IP, atau jaringan diblokir.
Login
Masuk log
Error
Galat
%s calls
%s panggilan
Cannot create %s
Gagal membuat %s
Include normal pages
Sertakan laman normal
Invalid UserName %s: not saved.
Nama pengguna %s tidak valid: tidak disimpan.
UserName must be 50 characters or less: not saved
Nama pengguna tidak boleh lebih dari 50 karakter: tidak disimpan
This page contains an uploaded file:
laman ini memiliki berkas lampiran:
No summary was provided for this file.
Ringkasan tidak tersedia untuk berkas ini.
Recursive include of %s!
Transklusi rekursif ke %s!
Clear Cache
Bersihkan Tembolok
Main lock obtained.
Kunci utama didapat.
Main lock released.
Kunci utama dilepas.
Journal
Jurnal
More...
Selengkapnya...
Comments on this page
Komentar di laman ini
XML::RSS is not available on this system.
XML::RSS tidak tersedia di sistem ini.
diff
beda
history
riwayat
%s returned no data, or LWP::UserAgent is not available.
%s tidak menghasilkan apa-apa atau LWP::UserAgent tidak tersedia.
RSS parsing failed for %s
Penguraian RSS gagal untuk %s
No items found in %s.
Tidak ada item ditemukan di %s.
 . . . .

Click to edit this page
Klik untuk menyunting laman ini
CGI Internal error: %s
Galat Internal CGI: %s
Invalid action parameter %s
Parameter %s tidak valid
Page name is missing
Nama laman tidak ditemukan
Page name is too long: %s
Nama laman terlalu panjang: %s
Invalid Page %s (must not end with .db)
laman %s tidak valid (harus berakhiran dengan .db)
Invalid Page %s (must not end with .lck)
laman %s tidak valid (harus berakhiran dengan .lck)
Invalid Page %s
laman %s tidak valid
There are no comments, yet. Be the first to leave a comment!
Masih belum ada komentar. Jadilah yang pertama meninggalkan komentar!
Welcome!
Selamat Datang!
This page does not exist, but you can %s.
Laman ini belum tersedia, tapi kamu dapat %s
create it now
membuatnya sekarang
Too many redirections
Terlalu banyak pengalihan
No redirection for old revisions
Tidak ada pengalihan untuk revisi lama
Invalid link pattern for #REDIRECT
Pranala untuk #REDIRECT tidak valid
Please go on to %s.
Silakan pergi ke %s.
Updates since %s
Pembaharuan sejak %s
up to %s
hingga %s
Updates in the last %s days
Pembaharuan terakhir %s hari lalu
Updates in the last day
Pembaharuan terakhir hari
for %s only
untuk %s saja
List latest change per page only
Daftar perubahan terbaru per laman saja
List all changes
Daftar semua perubahan terbaru
Skip rollbacks
Lewati pengembalian
Include rollbacks
Sertakan pengembalian
List only major changes
Tampilkan perubahan besar saja
Include minor changes
Sertakan perubahan remeh-temeh
days
hari
List later changes
Buat daftar perubahan nanti
RSS
RSS
RSS with pages
RSS dengan laman
RSS with pages and diff
RSS dengan laman dan perbedaan
Using the ｢rollback｣ button on this page will reset the wiki to that particular point in time, undoing any later changes to all of the pages.
Menggunakan tombol ｢kembalikan｣ pada laman ini akan mengembalikan wiki ke revisi tertentu dan membatalkan semua perubahan yang akan datang di semua laman.
Filters
Saring
Title:
Judul:
Title and Body:
Judul dan Badan:
Username:
Nama pengguna:
Host:
Hos:
Follow up to:
Setelah:
Language:
Bahasa:
Go!
Cari!
(minor)
(suntingan remeh-temeh)
rollback
kembalikan
new
baru
All changes for %s
Semua perubahan untuk %s
This page is too big to send over RSS.
laman ini terlalu besar untuk dikirim lewat RSS.
History of %s
Riwayat %s
Using the ｢rollback｣ button on this page will reset the page to that particular point in time, undoing any later changes to this page.
Menggunakan tombol ｢kembalikan｣ pada laman ini akan mengembalikan laman ke titik waktu tertentu dan membatalkan perubahan apa pun yang terjadi setelahnya.
Compare
Bandingkan
Deleted
Dihapus
Mark this page for deletion
Tandai laman ini untuk penghapusan
No other revisions available
Tidak ada revisi lain
current
terbaru
Revision %s
Revisi %s
Contributors to %s
Kontributor untuk %s
Missing target for rollback.
Target pengembalian tidak ditemukan.
Target for rollback is too far back
Target pengembalian terlalu lama.
A username is required for ordinary users.
Nama pengguna diwajibkan untuk pengguna biasa.
Rolling back changes
Mengembalikan perubahan
Editing not allowed: %s is read-only.
Penyuntingan tidak diizinkan: %s hanya-baca.
Rollback of %s would restore banned content.
Aksi pengembalian %s akan memulihkan konten yang diblokir.
Rollback to %s
Kembalikan ke %s
%s rolled back
%s telah dikembalikan
to %s
ke %s
Index of all pages
Indeks semua laman
Wiki Version
Versi Wiki
Password
Kata sandi
Run maintenance
Jalankan pemeliharaan
Unlock Wiki
Buka kunci Wiki
Unlock site
Buka kunci situs
Lock site
Kunci situs
Unlock %s
Buka kunci %s
Lock %s
Kunci %s
Administration
Administrasi
Actions:
Aksi:
Important pages:
laman penting:
To mark a page for deletion, put <strong>%s</strong> on the first line.
Untuk menandai laman untuk dihapus, tambahkan <strong>%s</strong> di baris pertama.
Anonymous
Pengguna anonim
redirected from %s
dialihkan dari %s
%s:
%s:
[Home]
[Beranda]
Click to search for references to this page
Klik untuk mencari referensi ke laman ini
Edit this page
Sunting laman ini
Preview:
Pratinjau:
Preview only, not yet saved
Suntingan belum disimpan, ini hanya pratinjau
Warning
Peringatan
Database is stored in temporary directory %s
Basis data disimpan di direktori sementara %s
%s seconds
%s detik
Last edited
Terakhir disunting
Edited
Telah disunting
by %s
oleh %s
(diff)
(beda)
a
a
c
c
Edit revision %s of this page
Sunting revisi %s laman ini
e
e
This page is read-only
laman ini hanya-baca
View other revisions
Lihat riwayat
View current revision
Lihat revisi terbaru
View all changes
Lihat semua perubahan
View contributors
Kontributor laman
Add your comment here:
Tambahkan komentar di sini:
Homepage URL:
URL laman utama:
s
s
Save
Terbitkan
p
p
Preview
Pratinjau
Search:
Pencarian:
f
f
Replace:
Ganti:
Delete
Hapus
Filter:
Saring:
Summary:
Ringkasan:
Last edit
Suntingan Terakhir
revision %s
Revisi %s
current revision
revisi terbaru
Difference between revision %1 and %2
Perbedaan antara revisi %1 dan %2
Last major edit (%s)
Suntingan terahir (%s)
later minor edits
suntingan remeh-temeh berikutnya
No diff available.
Tidak ada perbedaan.
Old revision:
Revisi lama:
Changed:
Diubah:
Deleted:
Dihapus:
Added:
Ditambahkan:
to
menjadi
Revision %s not available
Revisi %s tidak tersedia
showing current revision instead
menampilkan revisi terbaru sebagai ganti
Showing revision %s
Menampilkan revisi %s
Cannot save a nameless page.
Tidak dapat menyimpan laman tak bernama.
Cannot save a page without revision.
Tidak dapat menyimpan laman tanpa perbedaan.
not deleted:
tidak dihapus:
deleted
dihapus
Cannot open %s
Gagal membuka %s
Cannot write %s
Gagal menulis %s
Could not get %s lock
Tidak dapat mengunci %s
The lock was created %s.
Berhasil mengunci %s.
Maybe the user running this script is no longer allowed to remove the lock directory?
Mungkin pengguna yang menjalankan skrip ini tidak diizinkan menghapus direktori kunci?
Sometimes locks are left behind if a job crashes.
Terkadang penguncian tertinggal saat proses mogok.
After ten minutes, you could try to unlock the wiki.
Setelah sepuluh menit, Anda bisa mencoba membuka kunci wiki.
This operation may take several seconds...
Tindakan ini mungkin membutuhkan beberapa detik...
Forced unlock of %s lock.
Membuka paksa kunci %s.
No unlock required.
Buka kunci tidak diperlukan.
%s hours ago
%s jam lalu
1 hour ago
1 jam lalu
%s minutes ago
%s menit lalu
1 minute ago
1 menit lalu
%s seconds ago
%s detik lalu
1 second ago
1 detik lalu
just now
baru saja
Only administrators can upload files.
Hanya admin yang dapat mengunggah file.
Editing revision %s of
Menyunting revisi %s dari
Editing %s
Menyunting %s
Editing old revision %s.
Menyunting revisi lama %s.
Saving this page will replace the latest revision with this text.
Menyimpan laman ini akan mengganti revisi terbaru dengan ini.
This change is a minor edit.
Ini adalah suntingan remeh-temeh.
Cancel
Batal
Replace this file with text
Ganti file ini dengan teks
Replace this text with a file
Ganti teks ini dengan file
File to upload:
Unggah berkas:
Files of type %s are not allowed.
Tiper berkas %s tidak diizinkan.
Your password is saved in a cookie, if you have cookies enabled. Cookies may get lost if you connect from another machine, from another account, or using another software.
Kata sandi akan disimpan di kuki jika kuki diaktifkan. Kuki dapat hilang jika Anda menggunakan perangkat lain, dari akun lain, atau menggunakan perangkat lunak lain.
This site does not use admin or editor passwords.
Situs ini tidak menggunakan kata sandi admin atau editor.
You are currently an administrator on this site.
Saat ini Anda adalah administrator.
You are currently an editor on this site.
Saat ini Anda adalah editor.
You are a normal user on this site.
Anda adalah pengguna reguler.
You do not have a password set.
Tidak ada kata sandi yang diatur.
Your password does not match any of the administrator or editor passwords.
Kata sandi tidak cocok.
Password:
Kata sandi:
Return to %s
Kembali ke %s
This operation is restricted to site editors only...
Hanya editor yang bisa melakukan tindakan ini...
This operation is restricted to administrators only...
Hanya admin yang bisa melakukan tindakan ini...
Edit Denied
Suntingan Ditolak
Editing not allowed: user, ip, or network is blocked.
Penyuntingan dilarang: pengguna, IP, atau jaringan diblokir.
Contact the wiki administrator for more information.
Hubungi administrator wiki untuk informasi lebih lanjut.
The rule %s matched for you.
Aturan %s cocok dengan Anda.
See %s for more information.
Lihat %s untuk informasi lebih lanjut.
SampleUndefinedPage
ContohlamanTakTerdefinisi
Sample_Undefined_Page
Contoh_laman_Tak_Terdefinisi
Rule "%1" matched "%2" on this page.
Aturan "%1" cocok dengan "%2" di laman ini.
Reason: %s.
Alasan: %s.
Reason unknown.
Alasan tidak diketahui.
(for %s)
(untuk %s)
%s pages found.
%s laman ditemukan.
Preview: %s
Pratinjau: %s
Replaced: %s
Diganti: %s
Search for: %s
Pencarian untuk: %s
View changes for these pages
Riwayat laman ini
last updated
terakhir diperbaharui
by
oleh
Transfer Error: %s
Galat Transfer: %s
Browser reports no file info.
Peramban melaporkan tidak ada info berkas.
Browser reports no file type.
Peramban melaporkan tidak ada tipe berkas.
The page contains banned text.
laman ini mengandung kata terlarang.
No changes to be saved.
Tidak ada perubahan untuk disimpan.
This page was changed by somebody else %s.
laman ini telah diubah oleh seseorang %s
The changes conflict.  Please check the page again.
Terjadi konflik suntingan. Mohon cek laman ini lagi.
Please check whether you overwrote those changes.
Mohon cek apakah Anda menimpa suntingan itu.
Cannot delete the index file %s.
Tak dapat menghapus berkas indeks %s.
Please check the directory permissions.
Mohon cek izin direktori.
Your changes were not saved.
Suntingan Anda tidak disimpan.
Could not get a lock to merge!
Tidak dapat mengunci untuk penggabungan!
you
Anda
ancestor
terdahulu
other
lainnya
Run Maintenance
Jalankan Pemeliharaan
Maintenance not done.
Pemeliharaan belum dilakukan.
(Maintenance can only be done once every 12 hours.)
(Pemeliharaan hanya dapat dilakukan setiap 12 jam.)
Remove the "maintain" file or wait.
Hapus berkas "maintain" atau tunggu.
Expiring keep files and deleting pages marked for deletion
Berkas riwayat kedaluwarsa dan menghapus file yang ditandai
Moving part of the %s log file.
Memindahkan bagian dari berkas log %s.
Could not open %s log file
Tidak dapat menyimpan berkas log %s
Error was
Galat
Note: This error is normal if no changes have been made.
Catatan: Kesalahan ini normal jika tidak ada perubahan yang dilakukan.
Moving %s log entries.
Memindahkan entri log %s.
Removing IP numbers from %s log entries.
Menghapus alamat IP dari entri log %s.
Set or Remove global edit lock
Mengatur atau Menghapus penguncian suntingan global
Edit lock created.
Penguncian suntingan dibuat.
Edit lock removed.
Penguncian suntingan dihapus.
Set or Remove page edit lock
Atur atau Hapus penguncian sunting laman
Lock for %s created.
Penguncian %s dibuat.
Lock for %s removed.
Penguncian %s dihapus.
Displaying Wiki Version
Menampilkan Versi Wiki
Debugging Information
Informasi Awakutu
Too many connections by %s
Terlalu banyak koneksi oleh %s
Please do not fetch more than %1 pages in %2 seconds.
Mohon tidak mengambil lebih dari %s laman dalam %2 detik.
Check whether the web server can create the directory %s and whether it can create files in it.
Cek apakah peladen web dapat membuat direktori %s dan berkas di dalamnya.
, see
, lihat
The two revisions are the same.
Kedua revisi sama persis.
################################################################################
# modules/admin.pl
################################################################################
Deleting %s
Menghapus %s
Deleted %s
%s dihapus
Renaming %1 to %2.
Memindahkan %1 ke %2.
The page %s does not exist
laman %s tidak ada
The page %s already exists
laman %s telah ada
Cannot rename %1 to %2
Tidak dapat memindahkan %1 ke %2
Renamed to %s
Dipindahkan ke %s
Renamed from %s
Dipindahkan dari %s
Renamed %1 to %2.
%1 dipindahkan ke %2.
Immediately delete %s
Menghapus %s seketika
Rename %s to:
Memindahkan %s ke:
################################################################################
# modules/advanced-uploads.pl
################################################################################
Attach file:
Lampirkan:
Upload
Unggah
################################################################################
# modules/aggregate.pl
################################################################################
Learn more...
Lebih lanjut...
################################################################################
# modules/all.pl
################################################################################
Complete Content
Konten Penuh
The main page is %s.
laman utama adalah %s.
################################################################################
# modules/archive.pl
################################################################################
Archive:
Arsip:
################################################################################
# modules/backlinkage.pl
################################################################################
Rebuild BackLink database
Merekontruksi basis data pranala balik
Internal Page: %s
Laman Internal: %s
Pages that link to this page
laman yang tertaut ke laman ini
################################################################################
# modules/backlinks.pl
################################################################################
The search parameter is missing.
Parameter pencarian tidak ada.
Pages link to %s
Laman tertaut ke %s
################################################################################
# modules/ban-contributors.pl
################################################################################
Ban contributors
Blokir pengguna
Ban Contributors to %s
Blokir pengguna ke %s
Ban!
Blokir!
Regular expression:
Ekspresi reguler:
%s is banned
%s telah diblokir
These URLs were rolled back. Perhaps you want to add a regular expression to %s?
Pranala ini telah dibalikkan. Mungkin Anda ingin menambahkannya ke %s?
Consider banning the IP number as well:
Pertimbangkan untuk memblokir alamat IP berikut:
################################################################################
# modules/banned-regexps.pl
################################################################################
Regular expression "%1" matched "%2" on this page.
Ekspresi reguler "%1" cocok dengan "%2" di laman ini.
Regular expression "%s" matched on this page.
Ekspresi reguler "%s" cocok di laman ini.
################################################################################
# modules/big-brother.pl
################################################################################
Recent Visitors
Pengunjung Terakhir
some action
beberapa aksi
was here
di sini
and read
dan dibaca
################################################################################
# modules/calendar.pl
################################################################################
Illegal year value: Use 0001-9999
Tahun tidak diperbolehkan: Gunakan 0001-9999
The match parameter is missing.
Parameter kecocokan hilang.
Page Collection for %s
Koleksi Laman untuk %s
Previous
Sebelumnya
Next
Selanjutnya
Calendar %s
Kalender %s
Su
Mi
Mo
Sen
Tu
Sel
We
Rab
Th
Kam
Fr
Jum
Sa
Sab
January
Januari
February
Februari
March
Maret
April
April
May
Mei
June
Juni
July
Juli
August
Agustus
September
September
October
Oktober
November
November
December
Desember
################################################################################
# modules/checkbox.pl
################################################################################
set %s
atur %s
unset %s
batal atur %s
################################################################################
# modules/clustermap.pl
################################################################################
Clustermap
Peta klaster
Pages without a Cluster
laman tanpa Klaster
################################################################################
# modules/comment-div-wrapper.pl
################################################################################
Comments:
Komentar:
################################################################################
# modules/commentcount.pl
################################################################################
Comments on
Komentar di
Comment on
Komentar di
################################################################################
# modules/compilation.pl
################################################################################
Compilation for %s
Kompilasi untuk %s
Compilation tag is missing a regular expression.
Tag kompilasi tak memiliki ekspresi reguler.
################################################################################
# modules/creationdate.pl
################################################################################
Add creation date to page files
Tambahkan tanggal pembuatan pada laman
################################################################################
# modules/css-install.pl
################################################################################
Install CSS
Pasang CSS
Copy one of the following stylesheets to %s:
Salin salah satu dari lembar gaya ke %s:
Reset
Reset
################################################################################
# modules/dates.pl
################################################################################
Extract all dates from the database
Ekstrak semua tanggal dari basis data
Dates
Tanggal
No dates found.
Tanggal tak ditemukan.
################################################################################
# modules/despam.pl
################################################################################
List spammed pages
Daftar laman dispam
Despamming pages
Membersihan laman dispam
Spammed pages
laman dispam
Cannot find revision %s.
Tidak dapat menemukan revisi %s.
Revert to revision %1: %2
Membalikkan ke revisi %s: %2
Marked as %s.
Ditandai sebagai %s.
Cannot find unspammed revision.
Tak dapat menemukan revisi bersih.
################################################################################
# modules/diff.pl
################################################################################
Page diff
Perbedaan laman
Diff
Beda
################################################################################
# modules/drafts.pl
################################################################################
Recover Draft
Pulihkan Konsep
No text to save
Tidak ada teks untuk disimpan
Draft saved
Konsep disimpan
Draft recovered
Konsep dipulihkan
No draft available to recover
Tidak ada konsep untuk dipulihkan
Save Draft
Simpan Konsep
Draft Cleanup
Bersihkan Konsep
Unable to delete draft %s
Gagal menghapus konsep %s
%1 was last modified %2 and was kept
%1 terakhir dimodifikasi %2 dan telah disimpan
%1 was last modified %2 and was deleted
%1 terakhir dimodifikasi %2 dan telah dihapus
################################################################################
# modules/dynamic-comments.pl
################################################################################
Add Comment
Tambah Komentar
################################################################################
# modules/edit-cluster.pl
################################################################################
ordinary changes
perubahan biasa
%s days
%s hari
################################################################################
# modules/edit-paragraphs.pl
################################################################################
Could not identify the paragraph you were editing
Tidak dapat mengidentifikasi paragraf
This is the section you edited:
Ini adalah seksi yang Anda sunting:
This is the current page:
Ini adalah laman saat ini:
################################################################################
# modules/find.pl
################################################################################
Matching page names:
Nama laman yang cocok:
################################################################################
# modules/fix-encoding.pl
################################################################################
Fix character encoding
Perbaiki pengodean karakter
Fix HTML escapes
Perbaiki pengodean HTML
################################################################################
# modules/form_timeout.pl
################################################################################
Set $FormTimeoutSalt.
Atur $FormTimeoutSalt.
Form Timeout
Batas waktu Formulir
################################################################################
# modules/gd_security_image.pl
################################################################################
GD or Image::Magick modules not available.
Modul GD atau Image::Magick tidak ada.
GD::SecurityImage module not available.
Modul GD::SecurityImage tidak ada.
Image storing failed. (%s)
Gagal menyimpan gambar. (%s)
Bad gd_security_image_id.
Kesalahan gd_security_image_id.
Please type the six characters from the anti-spam image
Mohon ketikkan enam karakter dari gambar CAPTCHA
Submit
Simpan
CAPTCHA
CAPTCHA
You did not answer correctly.
Jawaban Anda salah.
$GdSecurityImageFont is not set.
$GdSecurityImageFont tidak diatur.
################################################################################
# modules/git-another.pl
################################################################################
No summary provided
Tidak ada ringkasan yang diberikan
################################################################################
# modules/git.pl
################################################################################
no summary available
Tidak ada ringkasan
page was marked for deletion
laman telah ditandai untuk dihapus
Oddmuse
Oddmuse
Cleaning up git repository
Membersihkan repositori git
################################################################################
# modules/google-plus-one.pl
################################################################################
Google +1 Buttons
Tombol +1 Google
All Pages +1
Semua laman +1
This page lists the twenty last diary entries and their +1 buttons.
laman ini menampilkan dua puluh entri diary terakhir beserta tombol +1-nya.
################################################################################
# modules/gravatar.pl
################################################################################
Email:
Surel:
################################################################################
# modules/header-and-footer-templates.pl
################################################################################
Could not find %1.html template in %2
Tidak dapat menemukan templat %1.html di %2
################################################################################
# modules/hiddenpages.pl
################################################################################
Only Editors are allowed to see this hidden page.
Hanya pengguna dengan kata sandi Editor yang dapat melihat laman ini.
Only Admins are allowed to see this hidden page.
Hanya pengguna dengan kata sandi Admin yang dapat melihat laman ini.
################################################################################
# modules/index.pl
################################################################################
Index
Indeks
################################################################################
# modules/joiner.pl
################################################################################
The username %s already exists.
Nama pengguna %s telah digunakan.
The email address %s has already been used.
Alamat surel %s telah digunakan.
Wait %s minutes before try again.
Tunggu %s menit sebelum mencoba lagi.
Registration Confirmation
Konfirmasi Pendaftaran
Visit the link below to confirm registration.
Kunjungi pranala di bawah untuk mengonfirmasi pendaftaran.
Recover Account
Pulihkan Akun
You can login by following the link below. Then set new password.
Anda dapat login dengan mengunjungi pranala berikut. Kemudian mengatur kata sandi baru.
Change Email Address
Ubah Alamat Surel
To confirm changing email address, follow the link below.
Konfirmasi perubahan alamat surel dengan mengunjungi pranala di bawah ini.
To submit this form you must answer this question:
Untuk mengirimkan formulir, jawab pertanyaan ini:
Question:
Pertanyaan:
CAPTCHA:
CAPTCHA:
Registration
Registrasi
The username must be valid page name.
Nama pengguna harus berupa nama laman yang valid.
Confirmation email will be sent to the email address.
Surel konfirmasi telah dikirim ke alamat surel.
Repeat Password:
Ulangi Kata sandi:
Bad email address format.
Format alamat surel tidak valid.
Password needs to have at least %s characters.
Kata sandi harus terdiri dari %s karakter atau lebih.
Passwords differ.
Kata sandi berbeda.
Email Sent
Surel Terkirim
Confirmation email has been sent to %s. Visit the link on the mail to confirm registration.
Surel konfirmasi telah dikirim ke %s. Kunjungi pranala pada surel untuk mengonfirmasi pendaftaran.
Failed to Confirm Registration
Gagal mengonfirmasi pandaftaran
Invalid key.
Kunci tidak valid.
The key expired.
Kunci kedaluwarsa.
Registration Confirmed
Registrasi Berhasil Dikonfirmasi
Now, you can login by using username and password.
Sekarang, Anda dapat masuk log dengan nama pengguna dan kata sandi.
Forgot your password?
Lupa kata sandi?
Login failed.
Gagal masuk log.
You are banned.
Anda telah diblokir.
You must confirm email address.
Anda harus mengonfirmasi alamat surel.
Logged in
Masuk log akun
%s has logged in.
%s telah masuk log.
You should set new password immediately.
Anda harus mengubah kata sandi segera.
Change Password
Ubah Kata sandi
Logged out
Keluar log
%s has logged out.
%s telah keluar log.
Account Settings
Preferensi Akun
Logout
Keluar log
Current Password:
Kata sandi Saat Ini:
New Password:
Kata sandi Baru:
Repeat New Password:
Ulangi Kata sandi Baru:
Password is wrong.
Kata sandi salah.
Password Changed
Kata sandi Diubah
Your password has been changed.
Kata sandi Anda telah diubah.
Forgot Password
Lupa Kata sandi
Enter email address, and recovery login ticket will be sent.
Masukkan alamat surel, informasi pemulihan akun akan dikirimkan.
Not found.
Tidak ditemukan.
The mail address is not valid anymore.
Alamat surel tidak lagi valid.
An email has been sent to %s with further instructions.
Alamat surel telah dikirimkan ke %s dengan petunjuk lebih lanjut.
New Email Address:
Alamat Surel Baru:
Failed to load account.
Gagal untuk memuat akun.
An email has been sent to %s with a login ticket.
Alamat surel telah dikirimkan ke %s dengan tiket masuk log.
Confirmation Failed
Konfimasi Gagal
Failed to confirm.
Gagal untuk mengonfirmasi.
Email Address Changed
Alamat Surel Berubah
Email address for %1 has been changed to %2.
Alamat surel untuk %1 telah diubah menjadi %2.
Account Management
Manajemen Akun
Ban Account
Blokir Akun
Enter username of the account to ban:
Masukkan nama pengguna untuk diblokir:
Ban
Blokir
Enter username of the account to unban:
Masukkan nama pengguna untuk dibuka blokirnya:
Unban
Buka blokir
%s is already banned.
%s telah diblokir.
%s has been banned.
%s telah diblokir.
%s is not banned.
%s tidak diblokir.
%s has been unbanned.
%s telah dibuka blokirnya.
Register
Daftar
################################################################################
# modules/lang.pl
################################################################################
Languages:
Bahasa:
Show!
Tampilkan!
################################################################################
# modules/like.pl
################################################################################
====(\d+) persons? liked this====
====(\d+) orang? menyukai ini====
====%d persons liked this====
====%d orang telah menyukai ini====
====1 person liked this====
====1 orang menyukai ini====
I like this!
Saya menyukai ini!
################################################################################
# modules/link-all.pl
################################################################################
Define
Tentukan
################################################################################
# modules/links.pl
################################################################################
Full Link List
Daftar Pranala Penuh
################################################################################
# modules/list-banned-content.pl
################################################################################
Banned Content
Konten Diblokir
Rule "%1" matched on this page.
Aturan "%1" cocok dengan laman ini.
################################################################################
# modules/listlocked.pl
################################################################################
List of locked pages
Daftar laman yang dikunci
################################################################################
# modules/listtags.pl
################################################################################
Pages tagged with %s
laman dengan label %s
################################################################################
# modules/live-templates.pl
################################################################################
Template without parameters
Templat tanpa parameter
The template %s is either empty or does not exist.
Templat %s tidak ada atau kosong.
################################################################################
# modules/localnames.pl
################################################################################
Name:
Nama:
URL:
URL:
Define Local Names
Tentukan Nama Lokal
Define external redirect:
Tentukan pengalihan eksternal:
 -- defined on %s
 -- ditentukan di %s
Local names defined on %1: %2
Nama lokal ditentukan di %1: %2
################################################################################
# modules/logbannedcontent.pl
################################################################################
IP number matched %s
Nomor IP cocok dengan %s
################################################################################
# modules/login.pl
################################################################################
Register for %s
Daftar untuk %s
Please choose a username of the form "FirstLast" using your real name.
Silakan pilih nama pengguna dalam format "DepanBelakang" menggunakan nama asli.
The passwords do not match.
Kata sandi tidak cocok.
The password must be at least %s characters.
Kata sandi harus terdiri dari setidaknya %s karakter.
That email address is invalid.
Alamat surel tidak valid
The username %s has already been registered.
Nama pengguna %s telah terdaftar.
Your registration for %s has been submitted.
Registrasi untuk %s telah berhasil dikirim.
Please allow time for the webmaster to approve your request.
Mohon tunggu beberapa saat untuk admin menyetujui permintaan Anda.
An email has been sent to "%s" with further instructions.
Surel telah dikirim ke "%s" dengan instruksi lebih lanjut.
There was an error saving your registration.
Terjadi galat saat menyimpan registrasi Anda.
An account was created for %s.
Akun telah dibuat untuk %s.
Login to %s
Masuk log ke %s
Username and/or password are incorrect.
Nama pengguna dan/atau kata sandi salah.
Logged in as %s.
Masuk log sebagai %s.
Logout of %s
Keluar log dari %s
Logout of %s?
Keluar log?
Logged out of %s
Mengeluarkan dari akun %s
You are now logged out.
Anda telah berhasil keluar log.
Register a new account
Daftarkan akun baru
Who am I?
Siapa saya?
Change your password
Ubah kata sandi Anda
Approve pending registrations
Setujui registrasi tertunda
Confirm Registration for %s
Konfirmasi Registrasi untuk %s
%s, your registration has been approved. You can now use your password to login and edit this wiki.
%s, registrasi Anda telah disetujui. Anda sekarang dapat menggunakan kata sandi untuk masuk ke akun dan menyunting wiki ini.
Confirmation failed.  Please email %s for help.
Konfirmasi gagal. Mohon hubungi %s untuk bantuan.
Who Am I?
Siapa saya?
You are logged in as %s.
Anda masuk log sebagai %s.
You are not logged in.
Anda tidak masuk log.
Reset Password
Atur Ulang Kata sandi
The password for %s was reset.  It has been emailed to the address on file.
Kata sandi untuk %s berhasil diatur ulang. Kata sandi telah dikirimkan ke alamat surel.
There was an error resetting the password for %s.
Terjadi galat saat mengatur ulang kata sandi untuk %s.
The username "%s" does not exist.
Nama pengguna “%s” tidak ada.
Reset Password for %s
Atur ulang Kata sandi untuk %s
Reset Password?
Atur ulang Kata sandi?
Change Password for %s
Ubah Kata Sandi untuk %s
Change Password?
Ubah Kata Sandi?
Your current password is incorrect.
Kata sandi Anda saat ini salah.
Approve Pending Registrations for %s
Setujui Pendaftaran yang Tertunda untuk %s
%s has been approved.
%s telah disetujui.
There was an error approving %s.
Terjadi kesalahan saat menyetujui %s.
There are no pending registrations.
Tidak ada pendaftaran yang tertunda.
################################################################################
# modules/mail.pl
################################################################################
Invalid Mail %s: not saved.
Alamat email tidak valid %s: tidak disimpan.
unsubscribe
Berhenti berlangganan
subscribe
Berlangganan
%s appears to be an invalid mail address
%s tampaknya merupakan alamat email yang tidak valid
Your mail subscriptions
Langganan surel Anda
All mail subscriptions
Semua langganan surel
All mail subscribers
Semua langganan surel
Subscriptions
Langganan
Email:
Surel:
Show
Tampilkan
Subscriptions for %s:
Langganan untuk %s:
Unsubscribe
Berhenti berlangganan
There are no subscriptions for %s.
Tidak ada langganan untuk %s.
Change email address
Ubah alamat surel
Mail addresses are linked to unsubscription links.
Alamat surel terhubung dengan tautan berhenti berlangganan.
Subscribe to %s.
Berlangganan ke %s.
Subscribe
Berlangganan
Subscribed %s to the following pages:
%s telah berlangganan ke laman-laman berikut:
The remaining pages do not exist.
laman-laman yang tersisa tidak ada.
Unsubscribed %s from the following pages:
%s telah berhenti berlangganan dari laman-laman berikut:
Unsubscribed %s from all pages.
%s telah berhenti berlangganan dari semua laman.
Migrating Subscriptions
Migrasi Langganan
No non-migrated email addresses found, migration not necessary.
Tidak ditemukan alamat email yang belum dimigrasi, migrasi tidak diperlukan.
Migrated %s rows.
%s baris telah dimigrasi.
################################################################################
# modules/markdown-converter.pl
################################################################################
Help convert %s to Markdown
Bantu konversi %s ke Markdown
List all non-Markdown pages
Daftar laman-laman non-Markdown
Converting %s
Mengubah %s
Candidates for Conversion to Markdown
Kandidat untuk mengubah ke Markdown
################################################################################
# modules/module-bisect.pl
################################################################################
Bisect modules
Modul Bisect
Module Bisect
Modul Bisect
All modules enabled now!
Semua modul sekarang diaktifkan!
Go back
Kembali
Test / Always enabled / Always disabled
Uji / Selalu diaktifkan / Selalu dinonaktifkan
Start
Mulai
Bisecting proccess is already active.
Proses pembagian sudah aktif.
Stop
Hentikan
It seems like module %s is causing your problem.
Sepertinya modul %s menyebabkan masalah Anda.
Please note that this module does not handle situations when your problem is caused by a combination of specific modules (which is rare anyway).
Harap diperhatikan bahwa modul ini tidak menangani situasi di mana masalah Anda disebabkan oleh kombinasi modul tertentu (yang jarang terjadi).
Good luck fixing your problem! ;)
Semoga berhasil memperbaiki masalah Anda! ;)
Module count (only testable modules):
Jumlah modul (hanya modul yang dapat diuji):
Current module statuses:
Status modul saat ini:
Good
Baik
Bad
Buruk
Enabling %s
Mengaktifkan %s
################################################################################
# modules/module-updater.pl
################################################################################
Update modules
Perbarui modul
Module Updater
Penerima Pembaruan Modul
Looks good. Update modules now!
Terlihat bagus. Perbarui modul sekarang!
################################################################################
# modules/multi-url-spam-block.pl
################################################################################
You linked more than %s times to the same domain. It would seem that only a spammer would do this. Your edit is refused.
Anda telah menghubungkan lebih dari %s kali ke domain yang sama. Sepertinya hanya spammer yang akan melakukan hal ini. Perubahan Anda ditolak.
################################################################################
# modules/namespaces.pl
################################################################################
%s is not a legal name for a namespace
%s bukanlah nama yang sah untuk ruang nama
Namespaces
Ruang nama
################################################################################
# modules/near-links.pl
################################################################################
Getting page index file for %s.
Mendapatkan berkas indeks laman untuk %s.
Near links:
Tautan terdekat:
Search sites on the %s as well
Cari situs di %s juga
Fetching results from %s:
Mendapatkan hasil dari %s:
Near pages:
laman terdekat:
Include near pages
Sertakan laman terdekat
EditNearLinks
EditNearLinks
The same page on other sites:
laman yang sama di situs lain:
################################################################################
# modules/nearlink-create.pl
################################################################################
 (create locally)
 (dibuat secara lokal)
################################################################################
# modules/no-question-mark.pl
################################################################################
image
gambar
download
unduh
################################################################################
# modules/nosearch.pl
################################################################################
Backlinks
Pranala balik
################################################################################
# modules/not-found-handler.pl
################################################################################
Clearing Cache
Membersihkan Tembolok
Done.
Selesai.
Generating Link Database
Menghasilkan Basis Data Tautan
The 404 handler extension requires the link data extension (links.pl).
Ekstensi penangan 404 memerlukan link data extension (links.pl).
################################################################################
# modules/offline.pl
################################################################################
Make available offline
Buah tersedia secara luring
Offline
Luring
You are currently offline and what you requested is not part of the offline application. You need to be online to do this.
Anda saat ini sedang luring dan apa yang Anda lakukan tidak tersedia secara luring. Anda perlu terhubung ke internet untuk melakukan ini.
################################################################################
# modules/olocalmap.pl
################################################################################
LocalMap
LocalMap
No page id for action localmap
Tidak ada id laman untuk tindakan localmap
Requested page %s does not exist
laman yang diminta %s tidak ada
Local Map for %s
Peta Lokal untuk %s
view
lihat
################################################################################
# modules/open-proxy.pl
################################################################################
Self-ban by %s
Pemblokiran sendiri oleh %s
You have banned your own IP.
Anda telah memblokir alamat IP Anda sendiri.
################################################################################
# modules/orphans.pl
################################################################################
Orphan List
laman-laman Yatim
################################################################################
# modules/page-trail.pl
################################################################################
Trail:
Lintasan:
################################################################################
# modules/page-type.pl
################################################################################
None
Tidak ada
Type
Tipe
################################################################################
# modules/paragraph-link.pl
################################################################################
Permalink to "%s"
Pranala permanen ke "%s"
anchor first defined here: %s
anchor pertama kali didefinisikan di sini: %s
the page %s also exists
laman %s juga ada
################################################################################
# modules/permanent-anchors.pl
################################################################################
Click to search for references to this permanent anchor
Klik untuk mencari laman yang merujuk ke jangkar permanen ini
Include permanent anchors
Sertakan jangkar permanen
################################################################################
# modules/pingback-server.pl
################################################################################
Only XML-RPC POST requests recognised
Hanya permintaan XML-RPC POST yang diterima
################################################################################
# modules/portrait-support.pl
################################################################################
Portrait
Potret
################################################################################
# modules/preview.pl
################################################################################
Pages with changed HTML
Laman dengan HTML yang diubah
Preview changes in HTML output
Pratinjau perubahan keluaran HTML
################################################################################
# modules/private-pages.pl
################################################################################
This page is password protected. If you know the password, you can %s. Once you have done that, return and reload this page.
Laman ini dilindungi oleh kata sandi. Jika Anda mengetahui kata sandi, Anda dapat %s. Kemudian kembali dan muat ulang laman ini.
supply the password now
beri kata sandi sekarang
################################################################################
# modules/private-wiki.pl
################################################################################
This error should not happen. If your password is set correctly and you are still seeing this message, then it is a bug, please report it. If you are just a stranger and trying to get unsolicited access, then keep in mind that all of the data is encrypted with AES-256 and the key is not stored on the server, good luck.
Galat ini tidak seharusnya terjadi. Jika kata sandi telah diatur dengan benar dan Anda masih melihat pesan ini, maka itu adalah kekutu (bug), mohon laporkan. Jika Anda adalah orang asing dan mencoba mengakses ini, maka ingatlah bahwa semua data dienkripsi dengan AES-256 dan kunci enkripsinya tidak disimpan di peladen. Semoga beruntung.
Attempt to read encrypted data without a password.
Percobaan untuk membaca data terenkripsi tanpa kata sandi.
Cannot refresh index.
Tidak dapat memperbaharui indeks.
################################################################################
# modules/publish.pl
################################################################################
Publish %s
Terbitkan %s
No target wiki was specified in the config file.
Tidak ada wiki yang diatur sebagai target di berkas konfigurasi.
The target wiki was misconfigured.
Wiki target tidak dikonfigurasi secara benar.
################################################################################
# modules/put.pl
################################################################################
Upload is limited to %s bytes
Ukuran unggahan dibatasi %s bytes
################################################################################
# modules/questionasker.pl
################################################################################
To save this page you must answer this question:
Untuk menyimpan laman ini, jawab pertanyaan berikut:
################################################################################
# modules/recaptcha.pl
################################################################################
Please type the following two words:
Mohon ketik dua kata berikut:
Please answer this captcha:
Mohon jawab captcha berikut:
################################################################################
# modules/referrer-rss.pl
################################################################################
Referrers
Referer
################################################################################
# modules/referrer-tracking.pl
################################################################################
All Referrers
Semua Referer
################################################################################
# modules/rename-pages.pl
################################################################################
Target page already exists.
Halaman tujuan telah ada.
Source page does not exist.
Halaman sumber tidak ada.
Copied from %s
Disalin dari %s
Moved to %s
Dipindahkan ke %s
################################################################################
# modules/search-list.pl
################################################################################
Page list for %s
Daftar halaman untuk %s
################################################################################
# modules/small.pl
################################################################################
Index of all small pages
Indeks semua halaman kecil
################################################################################
# modules/sort.pl
################################################################################
Sort alphabetically
Urutkan secara alfabetis
Sorted alphabetically
Diurutkan secara alfabetis
Sorted by last update first
Diurutkan berdasarkan terakhir diperbaharui dahulu
Sort by last update
Urutkan berdasarkan terakhir diperbaharui
Sorted by creation date
Diurutkan berdasarkan tanggal dibuat
Sort by creation date
Urutkan berdasarkan tanggal dibuat
################################################################################
# modules/static-copy.pl
################################################################################
Static Copy
Salinan Statis
Back to %s
Kembali ke %s
################################################################################
# modules/static-hybrid.pl
################################################################################
Editing not allowed for %s.
Suntingan tidak diizinkan untuk %s
################################################################################
# modules/svg-edit.pl
################################################################################
Edit image in the browser
Sunting gambar di peramban
Summary of your changes:
Ringkasan perubahan:
################################################################################
# modules/sync.pl
################################################################################
Copy to %1 succeeded: %2.
Berhasil menyalin ke %1: %2.
Copy to %1 failed: %2.
Gagal menyalin %1: %2.
################################################################################
# modules/tags.pl
################################################################################
Tag
Label
Feed for this tag
Umpan web untuk label ini
Tag Cloud
Awan Label
Rebuilding index not done.
Rekontruksi index belum selesai.
(Rebuilding the index can only be done once every 12 hours.)
(Rekontruksi index hanya dapat dilakukan sekali setiap 12 jam.)
Rebuild tag index
Merekontruksi index label
tag cloud
awan label
################################################################################
# modules/templates.pl
################################################################################
Alternatively, use one of the following templates:
Sebagai alternatif, pilih salah satu dari templat berikut:
################################################################################
# modules/throttle.pl
################################################################################
Too many instances.  Only %s allowed.
Terlalu banyak instansi. Hanya %s dizinkan.
Please try again later. Perhaps somebody is running maintenance or doing a long search. Unfortunately the site has limited resources, and so we must ask you for a bit of patience.
Mohon coba lagi nanti. Mungkin seseorang menjalankan maintenance script atau melakukan pencarian besar-besaran. Sayangnya situs ini memiliki sumber daya komputasi terbatas dan oleh karena itu kami memohon kesabaran Anda.
################################################################################
# modules/thumbs.pl
################################################################################
thumb
thumb
Error creating thumbnail from nonexisting page %s.
Kesalahan saat membuat thumbnail dari laman yang tidak ada %s.
Can not create thumbnail for file type %s.
Tidak dapat membuat thumbnail untuk jenis file %s.
Can not create thumbnail for a text document
Tidak dapat membuat thumbnail untuk dokumen teks
Can not create path for thumbnail - %s
Tidak dapat membuat jalur untuk thumbnail - %s
Could not open %s for writing whilst trying to save image before creating thumbnail. Check write permissions.
Tidak dapat membuka %s untuk penulisan saat mencoba menyimpan gambar sebelum membuat thumbnail. Periksa izin penulisan.
Failed to run %1 to create thumbnail: %2
Gagal menjalankan %1 untuk membuat thumbnail: %2
%s ran into an error
%s mengalami kesalahan
%s produced no output
%s tidak menghasilkan output
Failed to parse %s.
Gagal memproses %s.
################################################################################
# modules/timezone.pl
################################################################################
Timezone
Zona waktu
Pick your timezone:
Pilih zona waktu:
Set
Atur
################################################################################
# modules/toc-headers.pl
################################################################################
Contents
Daftar Isi
################################################################################
# modules/today.pl
################################################################################
Create a new page for today
Buat halaman baru untuk hari ini
################################################################################
# modules/translation-links.pl
################################################################################
Add Translation
Tambahkan Terjemahan
Added translation: %1 (%2)
Terjemahan ditambahkan: %1 (%2)
Translate %s
Terjemahkan %s
Thank you for writing a translation of %s.
Terima kasih telah menulis terjemahan untuk %s.
Please indicate what language you will be using.
Silakan tentukan bahasa yang akan Anda gunakan.
Language is missing
Bahasa tidak tersedia
Suggested languages:
Bahasa yang disarankan:
Please indicate a page name for the translation of %s.
Silakan tentukan nama laman untuk terjemahan %s.
More help may be available here: %s.
Bantuan tambahan mungkin tersedia di sini: %s.
Translated page:
laman yang diterjemahkan:
Please provide a different page name for the translation.
Silakan berikan nama laman yang berbeda untuk terjemahan.
################################################################################
# modules/translations.pl
################################################################################
This page is a translation of %s.
Halaman ini adalah terjemahan dari %s.
The translation is up to date.
Terjemahan ini sudah diperbarui.
The translation is outdated.
Terjemahan ini kedaluwarsa.
The page does not exist.
Halaman ini tidak ada.
################################################################################
# modules/upgrade.pl
################################################################################
Upgrading Database
Memperbaharui Basis data
Did the previous upgrade end with an error? A lock was left behind.
Apakah pembaharuan sebelumnya memunculkan galat? Kunci masih tertinggal.
Unlock wiki
Buka kunci wiki
Upgrade complete.
Pembaharuan selesai
Upgrade complete. Please remove $ModuleDir/upgade.pl, now.
Penbaharuan selesai. Mohon hapus $ModuleDir/upgrade.pl, now.
################################################################################
# modules/usemod.pl
################################################################################
https://en.wikipedia.org/wiki/Special:BookSources/%s
https://en.wikipedia.org/wiki/Special:BookSources/%s
################################################################################
# modules/wanted.pl
################################################################################
Wanted Pages
Halaman Diinginkan
%s pages
%s halaman
%s, referenced from:
%s, direfrensikan dari:
################################################################################
# modules/webapp.pl
################################################################################
Web application for offline browsing
Aplikasi web untuk berselancar luring
################################################################################
# modules/webdav.pl
################################################################################
Upload of %s file
Unggah %s berkas
################################################################################
# modules/weblog-1.pl
################################################################################
Blog
Blog
################################################################################
# modules/weblog-3.pl
################################################################################
Matching pages:
Kecocokan laman:
New
Baru
Edit %s.
Sunting %s.
################################################################################
# modules/weblog-4.pl
################################################################################
Tags:
Label:
################################################################################
# modules/webmention.pl
################################################################################
Webmention module requires $CommentsPrefix to be set
Modul Webmention memerlukan pengaturan $CommentsPrefix
Webmention requires a POST request
Webmention memerlukan permintaan POST
Webmention requires x-www-form-urlencoded requests
Webmention memerlukan permintaan x-www-form-urlencoded
Webmention must mention a specific page
Webmention harus menyebutkan laman tertentu
Webmention must mention a valid page
Webmention harus menyebutkan laman yang valid
Your IP number is blocked: %s
Alamat IP Anda diblokir: %s
Webmention must mention an existing page
Webmention harus menyebutkan laman yang sudah ada
Webmention must mention source
Webmention harus menyebutkan sumber
Webmention must mention target
Webmention harus menyebutkan target
The URL is blocked: %s
URL diblokir: %s
Webmention source cannot be verified: %1 returns %2 %3
Sumber Webmention tidak dapat diverifikasi: %1 menghasilkan %2 %3
Webmention source does not link to %s
Sumber Webmention tidak tertaut ke %s
Webmention for %s already exists
Webmention untuk %s sudah ada
Webmention OK!
Webmention berhasil!
Add webmentions
Tambahkan Webmention
Webmentioning others from %s
Mengirim Webmention ke orang lain dari %s
Webmention!
Webmention!
No links found.
Tidak ditemukan tautan.
Webmentioning somebody from %s
Mengirim webmention ke seseorang dari %s
Contacting %s
Menghubungi %s
Target reports an error: %s
Target melaporkan kesalahan: %s
No Webmention URL found
Tidak ditemukan URL webmention
Success: %s
Sukses: %s
Failure: %s
Gagal: %s
#
END_OF_TRANSLATION
