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

$ModulesDescription .= '<p>$Id: national-days-de.pl,v 1.4 2004/05/15 12:19:40 as Exp $</p>';

%SpecialDays = (
		'2-16' => 'Litauen: Unabhängigkeitstag',
		'2-18' => 'Gambia: Unabhängigkeitstag',
		'2-22' => 'St. Lucia: Nationalfeiertag',
		'2-23' => 'Brunei Darussalam: Unabhängigkeitstag, Kooperative Republik Guyana: Nationalfeiertag',
		'2-24' => 'Estland: Unabhängigkeitstag',
		'3-3' => 'Bulgarien: Nationalfeiertag',
		'3-6' => 'Ghana: Nationalfeiertag',
		'3-12' => 'Mauritius: Nationalfeiertag',
		'3-15' => 'Ungarn: Nationalfeiertag',

		'4-4' => 'Senegal: Unabhängigkeitstag',
		'4-17' => 'Syrien: Nationalfeiertag',
		'4-18' => 'Simbabwe: Unabhängigkeitstag',
		'4-26' => 'Tansania: Nationalfeiertag',
		'4-27' => 'Südafrika: Nationalfeiertag, Togo: Unabhängigkeitstag',
		'4-30' => 'Niederlande: Nationalfeiertag',
		'5-3' => 'Polen: Nationalfeiertag',
		'5-7' => 'Israel: Nationalfeiertag',
		'5-15' => 'Paraguay: Nationalfeiertag',
		'5-17' => 'Norwegen: Nationalfeiertag',
		'5-20' => 'Kamerun: Nationalfeiertag, Ost-Timor: Unabhängigkeitstag',
		'5-22' => 'Jemen: Nationalfeiertag',
		'5-24' => 'Eritrea: Unabhängigkeitstag',
		'5-25' => 'Argentinien: Nationalfeiertag, Jordanien: Unabhängigkeitstag',
		'5-26' => 'Georgien: Unabhängigkeitstag',
		'5-28' => 'Aserbeidschan: Nationalfeiertag',
		'6-1' => 'Samoa: Unabhängigkeitstag': # Samoa: zwei Tage!
		'6-2' => 'Samoa: Unabhängigkeitstag, Italien: Nationalfeiertag',
		'6-4' => 'Tonga: Nationalfeiertag',
		'6-5' => 'Dänemark: Nationalfeiertag',
		'6-6' => 'Schweden: Nationalfeiertag',
		'6-10' => 'Portugal: Nationalfeiertag',

		'9-15' => 'Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua: Unabhängigkeitstag',
		'9-16' => 'Mexiko, Papua-Neuguinea: Unabhängigkeitstag',
		'9-18' => 'Chile: Unabhängigkeitstag',
		'9-21' => 'Armenien, Belize, Malta: Unabhängigkeitstag',
		'9-23' => 'Saudi-Arabien: Unabhängigkeitstag',
		'9-24' => 'Guinea-Bissau: Unabhängigkeitstag',
		'9-30' => 'Botsuana: Unabhängigkeitstag',
		'10-1' => 'China: Nationalfeiertag, Zypern, Nigeria, Tuvalu: Unabhängigkeitstag',
		'10-2' => 'Guinea: Unabhängigkeitstag',
		'10-3' => 'Deutschland, Republik Korea: Nationalfeiertag',
		'10-4' => 'Königreich Lesotho: Unabhängigkeitstag',
		'10-9' => 'Uganda: Unabhängigkeitstag',
		'10-10' => 'Republik Fidschi-Inseln: Nationalfeiertag',

               );
