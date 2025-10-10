# This script generates a detailed gap report between Master.xsl and Child.xsl.
# It shows which templates, variables, and params are missing, and where they are defined in Master.xsl.
# Usage: python detailed_xsl_gap_report.py

import re

master_file = 'Print/Master.xsl'
child_file = 'Print/Child.xsl'

def find_definitions(file_path, tag, attr, names):
    pattern = re.compile(fr'<{tag}[^>]*{attr}="([^"]+)"')
    locations = {}
    with open(file_path, encoding='utf-8') as f:
        for i, line in enumerate(f, 1):
            for match in pattern.findall(line):
                if match in names:
                    locations.setdefault(match, []).append(i)
    return locations

def get_missing(master_set, child_set):
    return master_set - child_set

def extract_names(file_path, tag, attr):
    pattern = re.compile(fr'<{tag}[^>]*{attr}="([^"]+)"')
    names = set()
    with open(file_path, encoding='utf-8') as f:
        for line in f:
            for match in pattern.findall(line):
                names.add(match)
    return names

master_templates = extract_names(master_file, 'xsl:template', 'name')
child_templates = extract_names(child_file, 'xsl:template', 'name')
master_vars = extract_names(master_file, 'xsl:variable', 'name')
child_vars = extract_names(child_file, 'xsl:variable', 'name')
master_params = extract_names(master_file, 'xsl:param', 'name')
child_params = extract_names(child_file, 'xsl:param', 'name')

gap_report = []

def add_gap_section(label, master_set, child_set, tag, attr):
    missing = get_missing(master_set, child_set)
    if not missing:
        gap_report.append(f"All {label.lower()} from Master are present in Child.\n")
        return
    gap_report.append(f"{label} missing in Child (defined in Master):\n")
    locations = find_definitions(master_file, tag, attr, missing)
    for name in sorted(missing):
        lines = ', '.join(str(l) for l in locations.get(name, []))
        gap_report.append(f"  - {name} (line(s): {lines})")
    gap_report.append("")

add_gap_section('Templates', master_templates, child_templates, 'xsl:template', 'name')
add_gap_section('Variables', master_vars, child_vars, 'xsl:variable', 'name')
add_gap_section('Params', master_params, child_params, 'xsl:param', 'name')

with open('xsl_gap_report.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(gap_report))

print("Detailed gap report written to xsl_gap_report.txt")
