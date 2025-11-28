#!/usr/bin/env python3
"""
Better migration script that properly parses XML templates
"""

import re
import os
from xml.etree import ElementTree as ET

def extract_templates_from_xsl(content):
    """Extract all named templates from XSL content, excluding match="/" template"""
    templates = []

    # Find all template start tags
    template_starts = list(re.finditer(r'<xsl:template[^>]*name="[^"]*"[^>]*>', content))

    for i, start_match in enumerate(template_starts):
        template_name = re.search(r'name="([^"]*)"', start_match.group(0)).group(1)

        # Skip the main match="/" template
        if template_name == "match" and 'match="/"' in start_match.group(0):
            continue

        start_pos = start_match.start()

        # Find the corresponding end tag
        end_pos = find_matching_end_tag(content, start_pos, 'xsl:template')

        if end_pos > start_pos:
            template_content = content[start_pos:end_pos + len('</xsl:template>')]
            templates.append((template_name, template_content))

    return templates

def find_matching_end_tag(content, start_pos, tag_name):
    """Find the matching closing tag for a given start position"""
    open_count = 0
    pos = start_pos

    while pos < len(content):
        # Look for opening tags
        open_match = re.search(rf'<{tag_name}[^>]*>', content[pos:])
        # Look for closing tags
        close_match = re.search(rf'</{tag_name}>', content[pos:])

        if open_match and (not close_match or open_match.start() < close_match.start()):
            open_count += 1
            pos += open_match.end() + pos
        elif close_match:
            open_count -= 1
            if open_count == 0:
                return pos + close_match.start()
            pos += close_match.end() + pos
        else:
            break

    return -1

def migrate_templates():
    # Read the original messy file
    with open('Master_HTML.xsl', 'r', encoding='utf-8') as f:
        original_content = f.read()

    # Read the clean file
    with open('Master_HTML_clean.xsl', 'r', encoding='utf-8') as f:
        clean_content = f.read()

    # Extract templates
    templates = extract_templates_from_xsl(original_content)

    print(f"Found {len(templates)} utility templates to migrate")

    # Remove existing migrated templates section
    clean_content = re.sub(
        r'<!-- ===== PRICE FORMATTING TEMPLATES ===== -->.*?<xsl:template match="/">',
        '<!-- ===== PRICE FORMATTING TEMPLATES ===== -->\n<!-- ===== MAIN TEMPLATE ===== -->\n<xsl:template match="/">',
        clean_content,
        flags=re.DOTALL
    )

    # Insert templates before the main template
    main_template_pos = clean_content.find('<xsl:template match="/">')
    if main_template_pos > 0:
        before_main = clean_content[:main_template_pos]
        after_main = clean_content[main_template_pos:]

        # Add templates
        template_section = "<!-- ===== PRICE FORMATTING TEMPLATES ===== -->\n"
        for name, template in templates:
            template_section += template + "\n\n"

        template_section += "<!-- ===== END PRICE FORMATTING TEMPLATES ===== -->\n\n"

        clean_content = before_main + template_section + after_main

        # Write back
        with open('Master_HTML_clean.xsl', 'w', encoding='utf-8') as f:
            f.write(clean_content)

        print("✅ Successfully migrated all utility templates to Master_HTML_clean.xsl")
        print(f"Migrated {len(templates)} templates")
    else:
        print("❌ Could not find main template in clean file")

if __name__ == "__main__":
    os.chdir('/workspaces/PythonFiles/Print')
    migrate_templates()