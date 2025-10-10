import re

with open('Master.xsl', 'r') as f:
    content = f.read()

# Find all opening tags with name attribute
# Regex to match <tag name="value">
name_elements = re.findall(r'<\s*([^\s>]+)[^>]*\sname\s*=\s*["\']([^"\']+)["\'][^>]*>', content, re.IGNORECASE)

# Extract local names and names
element_name_list = []
for full_tag, name in name_elements:
    if ':' in full_tag:
        element = full_tag.split(':', 1)[1]
    else:
        element = full_tag
    element_name_list.append((element, name))

# Sort by element
element_name_list.sort(key=lambda x: x[0])

# Write to txt file
with open('elements_with_names.txt', 'w') as f:
    f.write("Elements with names in Master.xsl:\n\n")
    f.write("Element, Name\n")
    for element, name in element_name_list:
        f.write(f"{element}, {name}\n")

print("Elements with names extracted and saved to elements_with_names.txt")