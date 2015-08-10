#!/usr/bin/python2.3
"""Expose Inkscape SVG attributes.

Read an Inkscape SVG from stdin.
Output attributes to the "<svg>" element to stdout.
"""

import sys
import xml.sax


class InkscapeSvgHandler(xml.sax.ContentHandler):

    """Print attributes to svg element."""

    def startElement(self, name, attrs):
        if name == "svg":
            for (k,v) in attrs.items():
                print k + " " + v


if __name__ == "__main__":
    parser = xml.sax.make_parser()
    parser.setContentHandler(InkscapeSvgHandler())
    parser.parse(sys.stdin)
    sys.exit(0)
