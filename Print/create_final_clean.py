#!/usr/bin/env python3
"""
Create final clean Master_HTML.xsl that combines Child.xsl structure with Master.xsl functionality
"""

import os

def create_final_clean_version():
    # Read Child.xsl for structure
    with open('Child.xsl', 'r', encoding='utf-8') as f:
        child_content = f.read()

    # Read Master.xsl for parameters and core functionality
    with open('Master.xsl', 'r', encoding='utf-8') as f:
        master_content = f.read()

    # Read working Master_HTML.xsl for the main template content
    with open('Master_HTML.xsl', 'r', encoding='utf-8') as f:
        master_html_content = f.read()

    # Extract key sections from Child.xsl
    # Header and declarations
    header_start = child_content.find('<!--')
    header_end = child_content.find('-->', header_start) + 3
    header_section = child_content[header_start:header_end]

    # Stylesheet declaration
    stylesheet_start = child_content.find('<xsl:stylesheet')
    stylesheet_end = child_content.find('>', stylesheet_start) + 1
    stylesheet_decl = child_content[stylesheet_start:stylesheet_end]

    # Parameters from Master.xsl
    params_start = master_content.find('<xsl:param name="EMAIL_RECIPIENT_NUMFORMAT_PREF"')
    params_end = master_content.find('<xsl:output', params_start)
    params_section = master_content[params_start:params_end]

    # Output declaration
    output_start = master_content.find('<xsl:output')
    output_end = master_content.find('>', output_start) + 1
    output_section = master_content[output_start:output_end]

    # Variables from Master.xsl
    variables_start = master_content.find('<xsl:variable name="FILEATTACHMENT_DELIM"')
    variables_end = master_content.find('<xsl:decimal-format', variables_start)
    variables_section = master_content[variables_start:variables_end]

    # Decimal formats from Master.xsl
    decimal_start = master_content.find('<xsl:decimal-format')
    decimal_end = master_content.find('<xsl:template name="copyNodes"', decimal_start)
    decimal_section = master_content[decimal_start:decimal_end]

    # Extract main template content from working Master_HTML.xsl
    main_template_start = master_html_content.find('<xsl:template match="/">')
    main_template_end = master_html_content.rfind('</xsl:template>') + len('</xsl:template>')
    main_template_content = master_html_content[main_template_start:main_template_end]

    # Extract utility templates from Master_HTML.xsl
    templates_start = master_html_content.find('<xsl:template name="copyNodes">')
    templates_end = main_template_start
    utility_templates = master_html_content[templates_start:templates_end]

    # Create the final clean XSL
    final_content = f'''{header_section}
{stylesheet_decl}
{params_section}
{output_section}
{variables_section}
{decimal_section}
<xsl:strip-space elements="*"/>

<!-- ===== UTILITY TEMPLATES ===== -->
{utility_templates}

<!-- ===== MAIN TEMPLATE ===== -->
{main_template_content}

</xsl:stylesheet>'''

    # Write the final clean version
    with open('Master_HTML_final.xsl', 'w', encoding='utf-8') as f:
        f.write(final_content)

    print("✅ Created Master_HTML_final.xsl with clean Child.xsl structure and Master.xsl functionality")

if __name__ == "__main__":
    os.chdir('/workspaces/PythonFiles/Print')
    create_final_clean_version()