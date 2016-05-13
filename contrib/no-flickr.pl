#! /usr/bin/perl -w

# Copyright (C) 2005-2016  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use Modern::Perl;
use LWP::UserAgent;
use utf8;
binmode(STDOUT, ":utf8");

my $ua = LWP::UserAgent->new;

sub url_encode {
  my $str = shift;
  return '' unless $str;
  utf8::encode($str); # turn to byte string
  my @letters = split(//, $str);
  my %safe = map {$_ => 1} ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '-', '_', '.', '!', '~', '*', "'", '(', ')', '#');
  foreach my $letter (@letters) {
    $letter = sprintf("%%%02x", ord($letter)) unless $safe{$letter};
  }
  return join('', @letters);
}

sub get_raw {
  my $uri = shift;
  my $response = $ua->get($uri);
  return $response->content if $response->is_success;
}

sub get_wiki_page {
  my ($wiki, $id, $password) = @_;
  $id = $id;
  my $parameters = [
    pwd => $password,
    action => 'browse',
    id => $id,
    raw => 1,
      ];
  my $response = $ua->post($wiki, $parameters);
  return $response->decoded_content if $response->is_success;
  die "Getting $id returned " . $response->status_line;
}

sub post_wiki_page {
  my ($wiki, $id, $username, $password, $text) = @_;
  my $parameters = [
    username => $username,
    pwd => $password,
    recent_edit => 'on',
    text => $text,
    title => $id,
      ];
  my $response = $ua->post($wiki, $parameters);
  die "Posting to $id returned " . $response->status_line unless $response->code == 302;
}

my %seen = ();

sub write_flickr {
  my ($id, $flickr, $dir, $file) = @_;
  say "Found $flickr";
  warn "$file was seen before: " . $seen{$file} if $seen{$file};
  die "$file contains unknown characters" if $file =~ /[^a-z0-9_.]/;
  $seen{$file} = "$id used $flickr";
  my $bytes = get_raw($flickr) or die("No data for $id");
  open(my $fh, '>', "$dir/$file") or die "Cannot write $dir/$file";
  binmode($fh);
  print $fh $bytes;
  close($fh);
}

sub convert_page {
  my ($wiki, $pics, $dir, $username, $password, $id) = @_;
  say $id;
  my $text = get_wiki_page($wiki, $id, $password);
  my $is_changed = 0;
  while ($text =~ m!(https://[a-z0-9.]+.flickr.com/(?:[a-z0-9.]+/)?([a-z0-9_]+\.(?:jpg|png)))!) {
    my $flickr = $1;
    my $file = $2;
    write_flickr($id, $flickr, $dir, $file);
    $is_changed = 1;
    my $re = quotemeta($flickr);
    $text =~ s!$flickr!$pics/$file!g;
  }
  if ($is_changed) {
    post_wiki_page($wiki, $id, $username, $password, $text);
  } else {
    # die "$id has no flickr matches?\n$text";
  }
  sleep(5);
}

sub convert_site {
  my ($wiki, $pics, $dir, $username, $password) = @_;

  for my $id (qw(2004-10-14_Iraq 2005-11-25_India_Pictures
2005-11-26_India_Pictures 2006-04-20_Oddmuse 2006-06-22_Swiss_Alps
2006-08-03_Picture_Service 2006-08-21_Day_One_at_WikiSym_2006
2006-08-28_Verlängertes_Wochenende_in_Graubünden
2006-09-07_First_False_Positive_Pain 2006-09-11_Switzerland_Group_on_Flickr
2006-10-13_Land_of_Plenty 2006-11-11_Sikkim_Trekking 2006-11-14_Arrival
2006-11-15_Chinatown 2006-11-16_Ayutthaya 2006-11-17_Sanam_Luang
2006-11-18_Chatuchak_Weekend_Market 2006-11-19_Around_Parliament
2006-11-20_Giant_Swing 2006-11-21_Patunam 2006-11-22_Cabbage_Field_Palace
2006-11-23_Time_to_Go 2006-11-25_Flickr 2006-12-04_The_Shire
2006-12-07_New_Camera 2006-12-09_Oblivion 2006-12-11_Early_Christmas
2006-12-21_Züri_Flickr_Meeting 2006-12-25_Forgotten_Things
2007-02-02_Gimping_my_Brainz_Out 2007-02-27_One-on-one_RPG
2007-03-12_Back_from_Montana 2007-03-18_Samstag_in_Zürich 2007-04-01_Kren
2007-05-19_Hiking_in_Rio 2007-05-20_Rain 2007-05-21_Corcovado 2007-05-22_Niterói
2007-05-23_Tijuca 2007-05-25_Tijuca 2007-05-26_Ipanema
2007-05-30_Dungeons_and_Dragons_3.5 2007-06-06_Hex_Mapping_–_Roads
2007-06-15_Diagrams_on_Flickr 2007-07-08_Aldergrove 2007-08-05_Lanthana
2007-09-15_Flug_nach_Japan 2007-09-16_Shinjuku 2007-09-17_Meiji
2007-09-18_Geschlossen 2007-09-19_Osaka 2007-09-20_History 2007-09-21_Nara
2007-09-22_Kyoto 2007-09-23_Tempel_Überdosis 2007-09-24_Before_the_Rain
2007-09-25_Abseits_der_Touristenpfade 2007-09-26_Sleepyheads
2007-09-27_Schon_wieder_Salsa 2007-09-28_Last_Day 2007-09-29_End_Of_A_Trip
2007-09-30_Flickr 2007-09-30_Radiation 2007-10-06_More_pictures 2007-10-16_ATC
2007-10-24_Simpsonize 2007-11-30_Org_Mode_for_Todo_Lists
2007-12-26_Printing_Pictures 2008-01-10_Flickr_Porn
2008-01-20_Kaiserschmarrn_mit_Bildern 2008-01-20_Tiroler_Cake
2008-01-28_Death_of_a_Cat 2008-02-21_Flickr
2008-04-20_Palace_of_the_Silver_Princess 2008-06-09_Back
2008-06-28_Von_Kandersteg_nach_Adelboden 2008-06-29_Von_Adelboden_nach_Lenk
2008-06-30_Von_Lenk_nach_Lauenen 2008-07-01_Von_Lauenen_nach_Gsteig
2008-07-10_I_suck_as_a_DJ 2008-07-12_Aliev_Bleh_Orkestar
2008-07-24_Geschönte_Bilder 2008-09-06_Kitsunemori_Campaign_Start
2008-09-08_First_Day_at_WikiSym_2008 2008-10-11_Taking_Notes
2008-10-13_Map_Density 2008-11-04_La_Fortuna 2008-11-09_Monteverde
2008-12-16_How_to_Host_a_Dungeon 2008-12-19_More_Than_I_Can_Chew
2008-12-22_My_Sandbox_Game 2009-01-02_Mobile_Phone_Cameras
2009-01-07_Spontanes_Kurzabenteuer_mit_Karte 2009-02-15_I_Play 2009-02-22_I_Play
2009-03-12_I_Play 2009-03-12_Noch_mehr_Spieler 2009-03-15_Bergkönig,_Teil_2
2009-03-21_Playing_and_Doodling 2009-03-24_Überleben_ist_überbewertet
2009-04-13_Herr_der_Labyrinthe_in_der_Bäckeranlage 2009-05-07_Monday_Games
2009-05-15_The_Real_One_Page_Dungeon 2009-05-15_Water_Temple
2009-05-25_B_⁄_X_Affordances 2009-05-31_Fair_Use_Or_Not 2009-06-15_I_Play
2009-06-26_My_New_RPG_Network_Logo_Using_Inkscape 2009-07-01_Personal_Favorites
2009-07-05_Geysir 2009-07-06_Kirkjubaejarklaustur 2009-07-07_Laki_Ebene
2009-07-08_Skaftafell 2009-07-09_Fjord_und_Fjörder 2009-07-10_Fosshóll
2009-07-10_Grosse_Fahrt 2009-07-11_Kleines_Programm 2009-07-12_Wasserfälle
2009-08-04_Mythodea 2009-08-04_RPG_Circus_Inspiration 2009-08-10_Back_Online
2009-08-13_Kaylash_Subsector 2009-08-26_No_Map_Required_for_Urban_Adventures
2009-09-13_Hohtürli 2009-10-14_Love_the_Blue_Room
2009-10-19_Spirit_of_the_Century_in_China 2009-11-19_Vorbereitung_aufs_Spiel
2009-12-02_Hexcrawl 2009-12-11_Looking_for_Headphones 2010-01-25_One_Page_Notes
2010-02-26_Eine_Woche_Krank 2010-03-09_Status_Update
2010-03-16_Best_Props_Are_Maps 2010-03-18_Session_Preparation 2010-04-08_Spring
2010-05-21_Artist_Fail 2010-05-23_Ping_Pong 2010-06-09_Work_Work
2010-06-11_Game_Day_With_The_Kids 2010-07-07_Dice_Color 2010-08-12_Last.fm
2010-08-29_Mitspieler_in_Zürich_gesucht 2010-09-29_Otherworld_Miniatures
2010-11-01_Inspiration_and_Mediocrity 2010-11-27_Mauritius
2010-12-04_New_Compact_Camera 2010-12-23_Love_Bots
2011-01-10_One_Page_Dungeons_Still_Useful 2011-01-12_Low_Res,_Fake_Colors
2011-01-13_Campaign_Start 2011-01-15_Achievable_Ends 2011-01-18_Facebook_Werbung
2011-01-18_Old_School_vs._Old_Age 2011-01-21_With_Kids
2011-02-08_Der_Geist_Mesopotamiens_–_ein_kurzes,_deutsches_Fate
2011-02-12_Map_Making_Using_Inkscape
2011-03-03_Publishing_Last_Year’s_One_Page_Dungeon_Contest_Submissions
2011-03-11_GM_Style_Manual 2011-03-14_My_Goblins
2011-03-15_Character_Generation_Shortcuts_PDF 2011-03-21_My_Shadow_Elves
2011-03-21_The_Underdark_Gazette_is_Full_of_Win
2011-03-22_Archipelago_is_a_Game_Master_Training_Game
2011-03-24_Old_School_House_Rules_Link_Collection
2011-03-25_Protecting_Party_Members_In_Combat
2011-03-31_How_To_Organize_Adventure_Notes
2011-04-01_Judging_the_One_Page_Dungeon_Contest_Entries
2011-04-06_Yoga_is_the_new_Wisdom 2011-04-11_Rise_of_the_Rune_Lords_Campaign_End
2011-04-20_Computer_RPG_To_Play_List
2011-04-20_The_Passage_Of_Time_In_Your_Campaign
2011-04-24_My_One_Page_Dungeon_Contest_Nominations
2011-04-28_My_Sandbox_Starts_With_A_Mission
2011-04-30_Map_Drawing_Using_Polygons 2011-05-05_Erste_Ferienwoche
2011-05-05_Tools_for_a_Sandbox_Referee 2011-05-09_Der_Rollenspiel-Nerd
2011-05-09_Ich_habe_lieber_keine_sozialen_Fertigkeiten_im_Spiel
2011-05-09_Role_Play_Convention_(RPC)_in_Köln
2011-05-10_Den_Mitspielern_eine_Reibefläche_bieten
2011-05-10_Kaufrausch_an_der_Messe
2011-05-10_Warum_ich_bei_Labyrinth_Lord_bleibe
2011-05-11_German_Posting_Explained 2011-05-12_Dinge_für_mich_zeichnen_lassen
2011-05-14_Role_Play,_not_Wish_Fulfilment
2011-05-24_I_Want_A_Lot_Of_Labels_On_My_Maps 2011-05-25_Party_Like_It’s_99
2011-06-01_Tables_to_Generate_Setting 2011-06-06_Labyrinth_Lord_Party_Level_12
2011-06-07_First_Play_Test_Results 2011-06-08_Party_Size 2011-06-09_Delays
2011-06-10_Writing_a_New_RPG_(Dungeon_Crawl_Classics_RPG)
2011-06-16_Session_Reports_Are_Read_Just_Once,_If_At_All
2011-06-21_I_Prefer_Traditional_Games,_I_Think
2011-06-24_The_Priest_of_Law_Said… 2011-06-27_Älter_Werden
2011-07-14_Fraktionen_im_Spiel
2011-07-17_One_Page_Dungeon_Contest_–_Lack_Of_Transparency 2011-07-19_Dublin
2011-07-19_Laragh 2011-07-21_Cork 2011-07-23_Limerick 2011-07-24_Galway
2011-07-26_Sligo 2011-07-27_Donegal 2011-07-29_Belfast 2011-07-30_Carrickcarnon
2011-08-01_Zürich 2011-08-09_Funding 2011-08-10_Darkness_Beneath
2011-08-10_Mein_Weg_zum_schwarzen_Auge 2011-08-16_Spending_Time_With_Books
2011-08-20_Building_a_Better_GM 2011-08-25_Death 2011-09-04_Systemwechsel
2011-09-05_Zorceror_of_Zo_im_Wallis
2011-09-08_Interesting_RPG_posts_on_Google_Plus 2011-09-08_Player_Agency
2011-09-17_Video_Recording_Tourists 2011-09-30_Solar_System_vs._Old_School_D&D
2011-10-03_Apocalypse_World 2011-10-24_Old_School_D&D_Monsters_Online
2011-11-11_The_Ruination_of_Tenamen 2011-11-15_Occupy 2011-12-13_Paris
2011-12-23_Gewalt_im_Rollenspiel 2011-12-28_My_RPG_Year
2011-12-28_Recommended_RPG_Reading_On_This_Blog
2012-01-07_Old_School_RPG_Artists
2012-01-07_Preparing_for_a_Session_of_Solar_System_RPG 2012-01-10_Fifth_Edition
2012-01-13_It_Feels_Different 2012-01-17_Skiing 2012-01-18_Answers_for_Zak
2012-01-24_Changing_Gameplay_Over_Time 2012-01-25_Player_Contribution
2012-01-31_Iz 2012-02-01_Kubo 2012-02-02_Selbst_Geschrieben
2012-02-04_What_I'd_like_to_see_from_artists 2012-02-05_Favorite_Monster_Manuals
2012-02-08_Werkzeugkiste 2012-02-09_How_To_Write_A_Module
2012-02-09_Social_Skills_Revisited 2012-02-28_I_don't_like_Bennies
2012-03-04_Old_School_Fanzines 2012-03-05_The_Bane_of_Character_Builds
2012-03-20_Not_Smart_Enough 2012-03-20_Spielvorbereitung 2012-04-05_Krank
2012-04-16_Last.fm 2012-04-25_One_Page_Dungeon_Contest_Deadline_Approaching_Fast
2012-04-25_Podcast_Appearance
2012-05-06_One_Page_Dungeon_Contest_Submissions_Available
2012-05-09_Commenting_As_I_Go_(1PDC) 2012-05-11_Using_One_Page_Dungeons
2012-05-12_More_One_Page_Dungeon_Recommendations
2012-05-13_More_Recommended_Dungeons 2012-05-20_Unregelmässige_Spieler
2012-05-21_Intensives_Spielerlebnis 2012-05-22_Even_More_Recommended_Dungeons
2012-05-22_Thinking_About_Solar_System_RPG
2012-05-25_Persistent_Campaign_Setting 2012-05-28_Regarding_My_Nominations
2012-05-30_Bottomless_Pit 2012-05-30_The_Last_Batch_Of_Favorites
2012-06-10_Best_Of_1PDC_2012 2012-06-19_Alignment,_Paladins
2012-06-20_Hexcrawl_Procedure 2012-06-25_Monster_Stats 2012-06-27_Mystara
2012-07-03_City_Prep 2012-07-06_Training_Players 2012-07-10_Reputation_Revisited
2012-07-18_Marillenknödel 2012-07-30_Für_Anfänger 2012-07-31_Setting_Books
2012-08-03_Free_French_OCR_for_Mac 2012-08-10_Buying_Modules
2012-08-14_Threat_Level 2012-08-16_Simple_Burning_Wheel
2012-08-18_Defending_a_Ship 2012-09-09_Wir_sind_in_Hawaii
2012-09-10_Whither_the_West_Marches 2012-09-11_Rochen_und_Schildkröten
2012-09-14_Schiff_verpasst 2012-09-17_Strandleben
2012-09-20_Das_Ende_der_Ferien_naht 2012-09-22_Zurück_in_Honolulu
2012-10-05_Sandbox_and_Megadungeon_Advice_Links
2012-10-11_Traveller,_Spelljammer,_Planescape 2012-10-12_Agency
2012-10-15_New_Blogs 2012-10-19_More_about_the_Mashup 2012-10-25_DRM
2012-10-28_Charakter_Portraits 2012-11-04_Basteln 2012-11-08_Temple_of_Set
2012-11-17_How_To_Build_A_Dungeon 2012-11-26_Caverns_of_Slime
2012-11-28_Mapping_using_Inkscape 2012-11-29_Temptation_of_Imps
2012-12-01_Commando_Mission 2012-12-04_Short_Descriptions 2012-12-06_Cold
2012-12-07_Female_Warriors 2012-12-11_Player_Engagement 2012-12-20_Monsters
2012-12-22_More_Monsters 2012-12-23_Social_Media_this_Year
2013-01-08_Online_Photos 2013-01-11_Trying_LaTeX_Again 2013-01-22_Changers
2013-01-23_Handyman 2013-01-29_Meine_Probleme_mit_Burning_Wheel
2013-02-15_Players_Mapping 2013-02-16_Spell_Book_Notation
2013-02-18_Notes_To_Remember 2013-02-18_Red_Heart_Fortress
2013-02-20_Moldvay_Preisliste
2013-02-21_Character_Generator_and_Price_Differences
2013-02-27_New_Text_Mapper_Shapes 2013-02-27_SVG_Filters 2013-03-08_Talaric
2013-03-24_Hellebarden_und_Helme 2013-03-26_Quick_Sketch
2013-04-08_Hellebarden_und_Helme_ist_ziemlich_lang_geworden
2013-04-21_Raspberry_Pi 2013-04-22_PiMAME
2013-05-13_My_One_Page_Dungeon_Contest_Nominations
2013-05-13_Other_Favorite_Entries 2013-05-14_Scrobbling_Fail
2013-05-15_Treasure_Hunting_In_Niflheim 2013-05-17_Pendragon_RPG
2013-05-23_One_Page_Dungeon_Contest_Status_Update 2013-05-26_Popularity
2013-06-03_Identifying_Magic_Items 2013-06-05_Another_Gnomeyland_Example
2013-06-05_Gnomeyland_and_Text_Mapper 2013-06-27_Text_Mapper_for_Traveller
2013-06-28_Red_Hand_of_Doom_Treasure 2013-07-02_Initiative
2013-07-16_Inkscape_Mapping_and_mkhexgrid 2013-07-29_Urban_Campaigns
2013-07-30_Politics 2013-08-06_The_Seclusium_of_Orphone_of_the_Three_Visions
2013-08-21_Moldvay_Dungeon_Stocking_vs._Seclusium 2013-08-30_Nergal_Tempel
2013-09-23_Furkapass 2013-11-08_Adventure_Design_Contest
2013-11-23_Über_den_Konsum 2013-12-17_Boxed_Text
2013-12-22_Sepulchre_of_the_Clone 2014-01-02_Bryce_Likes_My_Adventure
2014-01-12_Good_Night,_Pyrobombus 2014-02-19_Huge_Parties
2014-03-10_Twenty_Two_Years 2014-05-16_Firefox_and_DRM
2014-06-27_New_Hosting_Sometime_Soon 2014-07-15_Soon_to_be_Moving 2014-08-04
2014-08-15_HTTPS 2014-08-24_Darkening_Skies 2014-09-10_Twitter_Alternatives
2014-09-20 2014-10-09_Back_from_Portugal 2014-10-15_Adventure_Prep
2014-10-15_fail2ban 2014-10-31_Pictures 2014-11-08_Vermicelles
2014-11-11_Oddmuse_Development
2014-12-08_Character_Generator_with_Random_Pictures
2014-12-19_Emacs_Wiki_Migration 2014-12-22_Emacs_Wiki_Migration
2014-12-24_Emacs_Wiki_Migration 2014-12-26_Emacs_Wiki_Migration
2014-12-28_Emacs_Wiki_Migration 2015-01-06_B⧸X_D&D 2015-02-06_New_Campaign
2015-02-07_Megadungeon_Prep 2015-02-10_Gridmapper 2015-02-11_Gridmapper_Progress
2015-02-14_Gridmapper_with_Demo 2015-02-20_Gridmapper_Variant_Madness
2015-02-26_Gridmapper_Library 2015-03-09_Magister_Lor
2015-03-10_Twenty_Three_Years 2015-03-23_Sagas_of_the_Icelanders
2015-03-31_Garaskis 2015-04-02_Ostern 2015-04-06_Mass_Effect 2015-04-12_Bhutan
2015-04-30_Hexcrawling 2015-06-24_Die_Männerwelt 2015-07-12_Schwyz
2015-07-14_Monsters 2015-07-21_Spam_AI
2015-09-03_How_to_add_a_new_Character_Sheet_to_Halberds_n’_Helmets
2015-09-13_Highgate
2015-09-21_Looking_for_an_Artist_to_help_with_my_RPG_Face_Generator
2015-09-28_Better 2015-10-06_Pink_Bliss 2015-11-02_Fronts 2015-11-08_Moves
2015-11-15_Prep 2015-11-18_Dungeon_World 2015-11-20_Chur 2015-11-21_Fountain_Pen
2015-11-30_Introduction 2015-12-15_Using_Fronts 2015-12-20_BX64
2016-03-23_Atreus Aurin Auroleva Bangkok Bloggertreffen_2005_BE
Comments_on_2006-08-03_Picture_Service
Comments_on_2006-09-11_Switzerland_Group_on_Flickr
Comments_on_2006-10-28_Bar_Camp_Zürich Comments_on_2006-12-07_New_Camera
Comments_on_2007-02-15_Gimp_and_Photoshop Comments_on_2007-05-19_Hiking_in_Rio
Comments_on_2008-06-27_More_Hiking Comments_on_2009-02-22_I_Play
Comments_on_2009-05-25_B_⁄_X_Affordances Comments_on_2009-05-31_Fair_Use_Or_Not
Comments_on_2009-07-30_Wandern Comments_on_2010-10-01_iPad_Keyboard
Comments_on_2010-12-02_Poster_Gesucht
Comments_on_2011-02-12_Map_Making_Using_Inkscape
Comments_on_2011-04-01_Judging_the_One_Page_Dungeon_Contest_Entries
Comments_on_2011-04-11_Rise_of_the_Rune_Lords_Campaign_End
Comments_on_2011-06-01_Tables_to_Generate_Setting
Comments_on_2011-06-27_Älter_Werden
Comments_on_2011-09-30_Solar_System_vs._Old_School_D&D
Comments_on_2012-05-07_iPhoto_and_Facebook_Privacy_Disaster
Comments_on_2012-09-01_SVG_Character_Sheet
Comments_on_2012-11-28_Mapping_using_Inkscape
Comments_on_2013-02-27_New_Text_Mapper_Shapes
Comments_on_2013-08-21_Moldvay_Dungeon_Stocking_vs._Seclusium
Comments_on_2013-09-04_Thinking_about_a_new_camera
Comments_on_2015-03-10_Twenty_Three_Years Comments_on_2015-05-29_Born_to_Run
Comments_on_2015-09-21_Looking_for_an_Artist_to_help_with_my_RPG_Face_Generator
Contact Costa_Rica Der_Kaiser_und_der_Kronprinz_als_Paten Gridmapper
Hellebarden_&_Helme Japan_2007 Kanzleistrasse_222 Maps Mirabel MyFaces
Märchen_Fudge Names No_Battlemap Old_School_Hex_Map_Tutorial Play
Retracing_Maps_Using_Inkscape Sardinien_2013 SoftwareUsed Subjective_Fudge_of_Zo
Swiss_Referee_Style_Manual TollkirschenWald )) {
    convert_page($wiki, $pics, $dir, $username, $password, $id);
  }
}

our $AdminPass;
do "/home/alex/password.pl";
convert_site('https://alexschroeder.ch/wiki',
	     'https://alexschroeder.ch/pics',
	     '/home/alex/alexschroeder.ch/pics',
	     'Alex Schroeder',
	     $AdminPass);
