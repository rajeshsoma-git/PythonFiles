#!/usr/bin/env python3
"""
Migrate utility templates from Master_HTML.xsl to Master_HTML_clean.xsl
"""

import re
import os

def migrate_templates():
    # Read the original messy file
    with open('Master_HTML.xsl', 'r', encoding='utf-8') as f:
        original_content = f.read()

    # Read the clean file
    with open('Master_HTML_clean.xsl', 'r', encoding='utf-8') as f:
        clean_content = f.read()

    # Extract all templates from original (excluding the main match="/" template)
    template_pattern = r'(<xsl:template[^>]*name="[^"]*"[^>]*>.*?</xsl:template>)'
    templates = re.findall(template_pattern, original_content, re.DOTALL)

    # Filter out the main template (match="/")
    utility_templates = []
    for template in templates:
        if 'match="/"' not in template:
            utility_templates.append(template)

    print(f"Found {len(utility_templates)} utility templates to migrate")

    # Insert templates into clean file in the appropriate section
    # Find the placeholder comment for price formatting templates
    placeholder = "<!-- ===== PRICE FORMATTING TEMPLATES ===== -->\n<!-- BMI_universalFormatPriceCustom and other price formatting templates would go here -->\n<!-- [TEMPLATES TO BE MIGRATED FROM ORIGINAL Master_HTML.xsl] -->"

    if placeholder in clean_content:
        # Replace placeholder with actual templates
        migrated_templates = "\n<!-- ===== PRICE FORMATTING TEMPLATES ===== -->\n" + "\n\n".join(utility_templates) + "\n\n<!-- ===== END PRICE FORMATTING TEMPLATES ===== -->\n"

        clean_content = clean_content.replace(placeholder, migrated_templates)

        # Write back the migrated clean file
        with open('Master_HTML_clean.xsl', 'w', encoding='utf-8') as f:
            f.write(clean_content)

        print("✅ Successfully migrated all utility templates to Master_HTML_clean.xsl")
        print(f"Migrated {len(utility_templates)} templates")
    else:
        print("❌ Could not find placeholder in clean file")

if __name__ == "__main__":
    os.chdir('/workspaces/PythonFiles/Print')
    migrate_templates()