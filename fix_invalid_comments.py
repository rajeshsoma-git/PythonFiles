import re

def fix_invalid_comments(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix patterns like "--><!--" by replacing with "--> <!--"
    content = re.sub(r'--><!--', r'--> <!--', content)

    # Fix patterns like "</tag--><!--" by replacing with "</tag><!--"
    content = re.sub(r'(--)><!--', r'\1> <!--', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Fixed invalid comment patterns in", file_path)

# Run the fix
fix_invalid_comments('/workspaces/PythonFiles/Print/Master_HTML.xsl')