import re

def fix_duplicate_styles(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to match multiple style attributes
    pattern = r'style="([^"]*)"\s+style="([^"]*)"(?:\s+style="([^"]*)")?(?:\s+style="([^"]*)")?'

    def merge_styles(match):
        styles = []
        for i in range(1, 5):
            if match.group(i):
                styles.append(match.group(i))
        merged = '; '.join(styles)
        return f'style="{merged}"'

    # Replace all occurrences
    fixed_content = re.sub(pattern, merge_styles, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print("Fixed duplicate style attributes in", file_path)

# Run the fix
fix_duplicate_styles('/workspaces/PythonFiles/Print/Master_HTML.xsl')