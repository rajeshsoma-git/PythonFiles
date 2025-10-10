# This script counts and lists all unique line types in Master.xsl.
# Usage: python classify_xsl_types_summary.py

xsl_file = 'Print/Master.xsl'

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

from collections import defaultdict

type_lines = defaultdict(list)

with open(xsl_file, encoding='utf-8') as f:
    for i, line in enumerate(f, 1):
        line_type = classify_line(line)
        type_lines[line_type].append((i, line.rstrip()))

print("Line types found:")
for t in sorted(type_lines):
    print(f"\nType: {t} (Total: {len(type_lines[t])})")
    for idx, content in type_lines[t][:5]:  # Show up to 5 examples per type
        print(f"  Line {idx}: {content}")
    if len(type_lines[t]) > 5:
        print(f"  ...and {len(type_lines[t]) - 5} more lines of this type.")
