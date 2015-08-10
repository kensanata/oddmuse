#!/bin/bash
#
# Import SVG from Oddmuse wiki

ODD_STUB="$1"

# get the page name,
WIKI_DIR=`dirname "$ODD_STUB"`
PAGENAME=`basename "$ODD_STUB"`
PAGENAME="${PAGENAME%.odd}Source"
echo "WIKI_DIR: $WIKI_DIR" > "/tmp/oddmuse2svg.report"
echo "PAGENAME: $PAGENAME" >> "/tmp/oddmuse2svg.report"

# download it
NOTES="$WIKI_DIR/notes.txt"
URLBASE=`cat "$NOTES" | grep -e "^urlbase" | cut -d" " -f2`
FULLURL="${URLBASE}download/${PAGENAME}"
echo "NOTES: $NOTES" >> "/tmp/oddmuse2svg.report"
echo "URLBASE: $URLBASE" >> "/tmp/oddmuse2svg.report"
echo "FULLURL: $FULLURL" >> "/tmp/oddmuse2svg.report"

WGET=`which wget`
CURL=`which CURL`
if test -x "$WGET"; then
    echo "USERAGENT: wget" >> "/tmp/oddmuse2svg.report"
    $WGET "$FULLURL" -o "$WIKI_DIR"/download.log -nv -O-
elif test -x "$CURL"; then
    echo "USERAGENT: curl" >> "/tmp/oddmuse2svg.report"
    $CURL --silent --show-error "$FULLURL"
else
    echo "USERAGENT: none" >> "/tmp/oddmuse2svg.report"
    echo Neither wget nor curl were found in $PATH 1>&2
fi
