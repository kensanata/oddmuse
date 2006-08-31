#!/bin/bash
#
# Export image to Oddmuse wiki
#
# Use with wikiupload.py, svgattrs.py, and odd_output.inx

INK_SVG="$1"
EXEC_DIR=`dirname "$0"`

cat "$INK_SVG" | "$EXEC_DIR/svgattrs.py" > "$INK_SVG.attrs"
DOCNAME=`grep -e "^sodipodi:docname" "$INK_SVG.attrs" | cut -d" " -f2`
DOCBASE=`grep -e "^sodipodi:docbase" "$INK_SVG.attrs" | cut -d" " -f2`
WIDTH=`grep -e "^width" "$INK_SVG.attrs" | cut -d" " -f2`
HEIGHT=`grep -e "^height" "$INK_SVG.attrs" | cut -d" " -f2`

if [[ "${WIDTH%pt}" == "$WIDTH" ||
      "${HEIGHT%pt}" == "$HEIGHT" ]]; then
    echo "Error: svg2oddmuse.sh only accepts pt-based sizes."
    echo "  Width: $WIDTH  Height: $HEIGHT"
    echo "Change the Document Preferences to 'pt' units."
    echo "(In Inkscape, File | Document Preferences, Custom Canvas)"
else
    WIDTH="${WIDTH%pt}"
    HEIGHT="${HEIGHT%pt}"
fi

PAGENAME="${DOCNAME%.odd}"
mv "$INK_SVG.attrs" "$DOCBASE/$PAGENAME.attrs"  # debug info
echo "$DOCNAME/$DOCBASE  ($WIDTH x $HEIGHT)"
cp "$INK_SVG" "$DOCBASE/$PAGENAME.svg"

NOTES="$DOCBASE/notes.txt"
if [[ ! -f "$NOTES" ]]; then
    echo "notes.txt, describing wiki, not found" > /dev/stderr
    exit 1
fi
USERNAME=`cat "$NOTES" | grep -e "^username" | cut -d" " -f2`
SUMMARY="Inkscape-to-Oddmuse"
URLBASE=`cat "$NOTES" | grep -e "^urlbase" | cut -d" " -f2`
SRC="$DOCBASE/$PAGENAME.svg"
TARGET="${URLBASE}${PAGENAME}Source"
"$EXEC_DIR/oddmuse-upload.py" -u "$USERNAME" -s "$SUMMARY" "$SRC" "$TARGET" 2>&1

inkscape --file="$DOCBASE/$PAGENAME.svg" --export-png="$DOCBASE/$PAGENAME.png" --export-area "0:0:$WIDTH:$HEIGHT"
SRC="$DOCBASE/$PAGENAME.png"
TARGET="${URLBASE}${PAGENAME}Image"
"$EXEC_DIR/oddmuse-upload.py" -u "$USERNAME" -s "$SUMMARY" "$SRC" "$TARGET" 2>&1
