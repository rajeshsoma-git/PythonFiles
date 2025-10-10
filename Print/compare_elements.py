import re

def extract_unique_elements(filename, output_file):
    with open(filename, 'r') as f:
        content = f.read()

    # Find all opening tags, capture the full tag name
    tags = re.findall(r'<\s*([^\s>]+)', content)

    # Extract local names (after : if present)
    local_tags = []
    for tag in tags:
        if ':' in tag:
            local_name = tag.split(':', 1)[1]
        else:
            local_name = tag
        # Skip comments and closing tags
        if not local_name.startswith('!') and not local_name.startswith('/'):
            local_tags.append(local_name)

    # Get unique tags
    unique_tags = sorted(set(local_tags))

    # Write to txt file
    with open(output_file, 'w') as f:
        f.write(f"Unique XML elements in {filename}:\n\n")
        for tag in unique_tags:
            f.write(tag + '\n')

    print(f"Unique elements extracted and saved to {output_file}")

def extract_elements(filename, output_file):
    with open(filename, 'r') as f:
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
    with open(output_file, 'w') as f:
        f.write(f"Elements with names in {filename}:\n\n")
        f.write("Element, Name\n")
        for element, name in element_name_list:
            f.write(f"{element}, {name}\n")

    print(f"Elements with names extracted and saved to {output_file}")

# Extract unique elements for Master.xsl
extract_unique_elements('Master.xsl', 'master_unique_elements.txt')

# Extract unique elements for Child.xsl
extract_unique_elements('Child.xsl', 'child_unique_elements.txt')

# Extract for Master.xsl
extract_elements('Master.xsl', 'master_elements_with_names.txt')

# Extract for Child.xsl
extract_elements('Child.xsl', 'child_elements_with_names.txt')