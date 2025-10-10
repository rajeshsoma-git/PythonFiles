# This script lists templates, variables, and params that are present in both Master.xsl and Child.xsl.
# Usage: python xsl_common_elements.py

import re

def extract_names(file_path, tag, attr):
    pattern = re.compile(fr'<{tag}[^>]*{attr}="([^"]+)"')
    names = set()
    with open(file_path, encoding='utf-8') as f:
        for line in f:
            for match in pattern.findall(line):
                names.add(match)
    return names

master_file = 'Print/Master.xsl'
child_file = 'Print/Child.xsl'

master_templates = extract_names(master_file, 'xsl:template', 'name')
child_templates = extract_names(child_file, 'xsl:template', 'name')
master_vars = extract_names(master_file, 'xsl:variable', 'name')
child_vars = extract_names(child_file, 'xsl:variable', 'name')
master_params = extract_names(master_file, 'xsl:param', 'name')
child_params = extract_names(child_file, 'xsl:param', 'name')

def print_common(label, master_set, child_set):
    common = master_set & child_set
    if common:
        print(f"\n{label} present in BOTH Master and Child:")
        for name in sorted(common):
            print(f"  * {name}")
    else:
        print(f"\nNo {label.lower()} are common between Master and Child.")

print_common('Templates', master_templates, child_templates)
print_common('Variables', master_vars, child_vars)
print_common('Params', master_params, child_params)
