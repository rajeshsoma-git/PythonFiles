#!/usr/bin/env python3
"""
Targeted fixes for remaining XSL validation issues.
"""

import re

def fix_remaining_issues(content):
    """Fix the remaining validation issues."""

    # Fix the nested comment at the beginning
    content = content.replace('<!-- <!-- <xsl:include href="http://localhost:8080/xsl/templateengine/xhtml-to-fo-full.xsl"/> --> -->',
                             '<!-- <xsl:include href="http://localhost:8080/xsl/templateengine/xhtml-to-fo-full.xsl"/> -->')

    # Fix remaining div-container tags that weren't caught by the previous regex
    # The issue was that the regex didn't account for the exact format
    content = re.sub(r'<div-container([^>]*?)>', r'<div\1>', content)

    # Fix any remaining fo:block-container closing tags
    content = content.replace('</fo:block-container>', '</div>')

    # Fix table-cell vs td mismatches - convert table-cell to td
    content = re.sub(r'<table-cell([^>]*?)>', r'<td\1>', content)
    content = re.sub(r'</table-cell>', '</td>', content)

    # Fix table-row vs tr mismatches
    content = re.sub(r'<table-row([^>]*?)>', r'<tr\1>', content)
    content = re.sub(r'</table-row>', '</tr>', content)

    # Fix table-body vs tbody mismatches
    content = re.sub(r'<table-body([^>]*?)>', r'<tbody\1>', content)
    content = re.sub(r'</table-body>', '</tbody>', content)

    # Fix table-column (this might not be valid HTML, but let's see)
    content = re.sub(r'<table-column([^>]*?)>', r'<col\1>', content)
    content = content.replace('</table-column>', '</col>')

    return content

def main():
    input_file = 'Master_HTML_fixed_20251010_025125.xsl'
    output_file = 'Master_HTML_final.xsl'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Processing {input_file} ({len(content)} chars)")

    fixed_content = fix_remaining_issues(content)

    print(f"Fixed content: {len(fixed_content)} chars")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Saved to {output_file}")

    # Validate
    import subprocess
    result = subprocess.run(['xmllint', '--noout', output_file],
                          capture_output=True, text=True, cwd='.')

    if result.returncode == 0:
        print("✅ XML validation passed!")
    else:
        print("❌ XML validation failed:")
        # Show first few errors
        lines = result.stderr.strip().split('\n')[:10]
        for line in lines:
            print(f"  {line}")

if __name__ == '__main__':
    main()