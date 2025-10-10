#!/usr/bin/env python3
"""
Fix tag mismatches in Master_HTML.xsl from FO-to-HTML conversion.
Replaces <div-container> with <div> and fixes closing tags.
"""

import re

def fix_tag_mismatches(content):
    """Fix div-container and fo:block-container tag mismatches."""

    # Replace opening <div-container with <div
    content = re.sub(r'<div-container([^>]*)>', r'<div\1>', content)

    # Replace closing </fo:block-container> with </div> when it follows div-container pattern
    # This is tricky because we need to match the closing tags that correspond to div-container openings
    # For now, let's replace all </fo:block-container> with </div> since they seem to be the mismatched closings
    content = content.replace('</fo:block-container>', '</div>')

    return content

def main():
    input_file = 'Master_HTML.xsl'
    output_file = 'Master_HTML_fixed.xsl'

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()

        print(f"Original file size: {len(content)} characters")

        fixed_content = fix_tag_mismatches(content)

        print(f"Fixed file size: {len(fixed_content)} characters")

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(fixed_content)

        print(f"Fixed XSL saved to {output_file}")

        # Validate the XML structure
        import subprocess
        result = subprocess.run(['xmllint', '--noout', output_file],
                              capture_output=True, text=True, cwd='.')

        if result.returncode == 0:
            print("✓ XML validation passed!")
        else:
            print("✗ XML validation failed:")
            print(result.stderr)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()</content>
<parameter name="filePath">/workspaces/PythonFiles/Print/fix_tag_mismatches.py