# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA

# Die Daten stammen von der deutschen Ausgabe des Monde Diplomatique.
# Falls der Wiki nur Deutsch ist, kann man diese Datei einfach als
# Modul installieren: Im Datenverzeichnis ein neues Unterverzeichnis
# namens 'modules' erstellen, und die Datei hineinkopieren.

# If you are running a multilingual site, then you should explicitly
# load this file from your language-specific config file.

$ModulesDescription .= '<p>$Id: national-days-de.pl,v 1.2 2004/05/15 12:06:03 as Exp $</p>';

%SpecialDays = (
		'4-4' => 'Senegal, Unabhängigkeitstag',
		'4-17' => 'Syrien, Nationalfeiertag',
		'4-18' => 'Simbabwe, Unabhängigkeitstag',
		'4-26' => 'Tansania, Nationalfeiertag',
		'4-27' => 'Südafrika, Nationalfeiertag, Togo, Unabhängigkeitstag',
		'4-30' => 'Niederlande, Nationalfeiertag',
		'5-3' => 'Polen, Nationalfeiertag',
		'5-7' => 'Israel, Nationalfeiertag',
		'5-15' => 'Paraguay, Nationalfeiertag',
		'5-17' => 'Norwegen, Nationalfeiertag',
		'5-20' => 'Kamerun, Nationalfeiertag, Ost-Timor, Unabhängigkeitstag',
		'5-22' => 'Jemen, Nationalfeiertag',
		'5-24' => 'Eritrea, Unabhängigkeitstag',
		'5-25' => 'Argentinien, Nationalfeiertag, Jordanien, Unabhängigkeitstag',
		'5-26' => 'Georgien, Unabhängigkeitstag',
		'5-28' => 'Aserbeidschan, Nationalfeiertag',
		'6-1' => 'Samoa, Unabhängigkeitstag', # Samoa: zwei Tage!
		'6-2' => 'Samoa, Unabhängigkeitstag, Italien, Nationalfeiertag',
		'6-4' => 'Tonga, Nationalfeiertag',
		'6-5' => 'Dänemark, Nationalfeiertag',
		'6-6' => 'Schweden, Nationalfeiertag',
		'6-10' => 'Portugal, Nationalfeiertag',
               );
