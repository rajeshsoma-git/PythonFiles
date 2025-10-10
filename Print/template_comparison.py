import re

def get_template_names(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Find template names: <xsl:template name="...">
    templates = re.findall(r'<\s*xsl:template[^>]*\sname\s*=\s*["\']([^"\']+)["\'][^>]*>', content, re.IGNORECASE)
    return set(templates)

def get_call_template_names(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Find call-template names: <xsl:call-template name="...">
    calls = re.findall(r'<\s*xsl:call-template[^>]*\sname\s*=\s*["\']([^"\']+)["\'][^>]*>', content, re.IGNORECASE)
    return set(calls)

master_templates = get_template_names('Master.xsl')
child_calls = get_call_template_names('Child.xsl')

print(f"Templates defined in Master.xsl: {len(master_templates)}")
print(f"Call-templates in Child.xsl: {len(child_calls)}")

used_in_child = master_templates.intersection(child_calls)
not_used = master_templates - child_calls
extra_calls = child_calls - master_templates

print(f"Templates from Master used in Child: {len(used_in_child)}")
print(f"Templates from Master not used in Child: {len(not_used)}")
print(f"Call-templates in Child not defined in Master: {len(extra_calls)}")

with open('template_comparison.txt', 'w') as f:
    f.write("Template Comparison between Master.xsl and Child.xsl\n\n")
    f.write(f"Templates defined in Master.xsl ({len(master_templates)}):\n")
    for t in sorted(master_templates):
        f.write(f"  {t}\n")
    
    f.write(f"\nCall-templates in Child.xsl ({len(child_calls)}):\n")
    for t in sorted(child_calls):
        f.write(f"  {t}\n")
    
    f.write(f"\nTemplates from Master used in Child ({len(used_in_child)}):\n")
    for t in sorted(used_in_child):
        f.write(f"  {t}\n")
    
    f.write(f"\nTemplates from Master not used in Child ({len(not_used)}):\n")
    for t in sorted(not_used):
        f.write(f"  {t}\n")
    
    f.write(f"\nCall-templates in Child not defined in Master ({len(extra_calls)}):\n")
    for t in sorted(extra_calls):
        f.write(f"  {t}\n")

print("Comparison saved to template_comparison.txt")