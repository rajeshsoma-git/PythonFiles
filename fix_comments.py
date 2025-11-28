import re

def fix_comments(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace invalid comment markers
    content = re.sub(r'<!---', '<!--', content)
    content = re.sub(r'--->', '-->', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Fixed invalid comment markers in", file_path)

# Run the fix
fix_comments('/workspaces/PythonFiles/Print/Master_HTML.xsl')