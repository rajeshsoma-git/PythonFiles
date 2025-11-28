import re

with open('Final.xsl', 'r') as f:
    content = f.read()

# Pattern 1: Remove 3 levels of plain div wrapping a div with class/attributes
# <div>\n<div>\n<div>\n<div class="..." ... becomes <div class="..."
pattern1 = re.compile(
    r'(<td[^>]*>\n)(\s*)<div>\n\s*<div>\n\s*<div>\n(\s*)(<div [^>]*>)',
    re.MULTILINE
)
content = pattern1.sub(r'\1\2\4', content)

# Pattern 2: Remove corresponding closing divs (3 levels before </td>)
# </div>\n</div>\n</div>\n</td> becomes </div>\n</td>
pattern2 = re.compile(
    r'(</div>)\n(\s*)</div>\n\s*</div>\n\s*</div>\n(\s*)(</td>)',
    re.MULTILINE
)
content = pattern2.sub(r'\1\n\3\4', content)

# Pattern 3: Handle 2 levels of plain div wrapping
pattern3 = re.compile(
    r'(<td[^>]*>\n)(\s*)<div>\n\s*<div>\n(\s*)(<div [^>]*>)',
    re.MULTILINE
)
content = pattern3.sub(r'\1\2\4', content)

# Pattern 4: Remove corresponding 2 closing divs
pattern4 = re.compile(
    r'(</div>)\n(\s*)</div>\n\s*</div>\n(\s*)(</td>)',
    re.MULTILINE
)
content = pattern4.sub(r'\1\n\3\4', content)

with open('Final.xsl', 'w') as f:
    f.write(content)

print("Cleanup completed")
