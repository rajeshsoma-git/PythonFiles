#!/bin/bash

# Make a working copy
cp Final.xsl Final.xsl.working

# Pattern we're looking for (exact match with tabs):
# <td...>
# class="...">
# ... content ...
# </td>

# We'll use a Perl one-liner for better multi-line regex handling
perl -i -pe '
    # Store state between lines
    BEGIN { undef $/; }  # Read entire file
    
    # Pattern 1: Remove 3 wrapper divs after <td> before <div class=
    s#(<td[^>]*>\n)(\s*)<div>\n\s*<div>\n\s*<div>\n(\s*)(<div\s+[^>]+>)#$1$3$4#g;
    
    # Pattern 2: Remove 3 closing </div> before </td>
    s#(</div>)\n(\s*)</div>\n\s*</div>\n\s*</div>\n(\s*)(</td>)#$1\n$3$4#g;
' Final.xsl.working

# Check if valid XML
if xmllint --noout Final.xsl.working 2>/dev/null; then
    echo "SUCCESS: XML is valid after cleanup"
    mv Final.xsl.working Final.xsl
    echo "File updated"
    wc -l Final.xsl
else
    echo "ERROR: XML validation failed, keeping original"
    rm Final.xsl.working
    exit 1
fi
