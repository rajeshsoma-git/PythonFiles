# This script reads Master.xsl line by line and classifies each line type.
# Usage: python classify_xsl_lines.py

xsl_file = 'Print/Master.xsl'

# Define simple rules for classification
def classify_line(line):
    stripped = line.strip()
    if not stripped:
        return 'blank'
    if stripped.startswith('<!--'):
        return 'comment'
    if stripped.startswith('<xsl:template'):
        return 'template-definition'
    if stripped.startswith('<xsl:param'):
        return 'param-definition'
    if stripped.startswith('<xsl:variable'):
        return 'variable-definition'
    if stripped.startswith('<xsl:choose'):
        return 'choose-block'
    if stripped.startswith('<xsl:when'):
        return 'when-block'
    if stripped.startswith('<xsl:otherwise'):
        return 'otherwise-block'
    if stripped.startswith('<xsl:output'):
        return 'output-definition'
    if stripped.startswith('<xsl:include'):
        return 'include-definition'
    if stripped.startswith('<xsl:stylesheet'):
        return 'stylesheet-declaration'
    if stripped.startswith('</xsl:template'):
        return 'template-end'
    if stripped.startswith('</xsl:stylesheet'):
        return 'stylesheet-end'
    if stripped.startswith('<') and stripped.endswith('>'):
        return 'xml-tag'
    return 'other'

with open(xsl_file, encoding='utf-8') as f:
    for i, line in enumerate(f, 1):
        line_type = classify_line(line)
        print(f"Line {i:5}: {line_type:22} | {line.rstrip()}")
