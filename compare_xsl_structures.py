# Compare Master.xsl and Child.xsl for missing templates, variables, and params
# Usage: python compare_xsl_structures.py

import re

master_file = 'Print/Master.xsl'
child_file = 'Print/Child.xsl'

def extract_names(file_path, tag, attr):
    pattern = re.compile(fr'<{tag}[^>]*{attr}="([^"]+)"')
    names = set()
    with open(file_path, encoding='utf-8') as f:
        for line in f:
            for match in pattern.findall(line):
                names.add(match)
    return names

def extract_template_names(file_path):
    # <xsl:template name="..."
    return extract_names(file_path, 'xsl:template', 'name')

def extract_variable_names(file_path):
    # <xsl:variable name="..."
    return extract_names(file_path, 'xsl:variable', 'name')

def extract_param_names(file_path):
    # <xsl:param name="..."
    return extract_names(file_path, 'xsl:param', 'name')

master_templates = extract_template_names(master_file)
child_templates = extract_template_names(child_file)
master_vars = extract_variable_names(master_file)
child_vars = extract_variable_names(child_file)
master_params = extract_param_names(master_file)
child_params = extract_param_names(child_file)

def print_diff(label, master_set, child_set):
    missing = master_set - child_set
    if missing:
        print(f"\n{label} present in Master but missing in Child:")
        for name in sorted(missing):
            print(f"  {name}")
    else:
        print(f"\nAll {label.lower()} from Master are present in Child.")

print_diff('Templates', master_templates, child_templates)
print_diff('Variables', master_vars, child_vars)
print_diff('Params', master_params, child_params)
