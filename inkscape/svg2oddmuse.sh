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

PAGENAME="${DOCNAME%.odd}"
mv "$INK_SVG.attrs" "$DOCBASE/$PAGENAME.attrs"  # debug info
cp "$INK_SVG" "$DOCBASE/$PAGENAME.svg"

NOTES="$DOCBASE/notes.txt"
if [[ ! -f "$NOTES" ]]; then
    echo "notes.txt, describing wiki, not found" 1>&2
    exit 1
fi
USERNAME=`cat "$NOTES" | grep -e "^username" | cut -d" " -f2`
SUMMARY="Inkscape-to-Oddmuse"
URLBASE=`cat "$NOTES" | grep -e "^urlbase" | cut -d" " -f2`
SRC="$DOCBASE/$PAGENAME.svg"
TARGET="${URLBASE}${PAGENAME}Source"
"$EXEC_DIR/oddmuse-upload.py" -u "$USERNAME" -s "$SUMMARY" "$SRC" "$TARGET" 1>&2

inkscape --export-area-drawing --file="$DOCBASE/$PAGENAME.svg" --export-png="$DOCBASE/$PAGENAME.png"
SRC="$DOCBASE/$PAGENAME.png"
TARGET="${URLBASE}${PAGENAME}Image"
"$EXEC_DIR/oddmuse-upload.py" -u "$USERNAME" -s "$SUMMARY" "$SRC" "$TARGET" 1>&2
