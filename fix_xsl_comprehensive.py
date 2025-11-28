import re

def fix_xsl_file(file_path):
    """Fix all issues in the XSL file to make it valid XML for XSL processing."""

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    print("Original content length:", len(content))

    # 1. Fix invalid comment start markers: <!--- -> <!--
    content = re.sub(r'<!---', '<!--', content)

    # 2. Fix invalid comment end markers: ---> -> -->
    content = re.sub(r'--->', '-->', content)

    # 3. Fix "--" in comments by replacing with different characters
    # But preserve comment structure
    def fix_double_dash_in_comments(match):
        full_comment = match.group(0)
        # Replace "--" with "- " inside the comment content only
        # Find content between <!-- and -->
        start = full_comment.find('<!--') + 4
        end = full_comment.rfind('-->')
        if start < end:
            before = full_comment[:start]
            content = full_comment[start:end]
            after = full_comment[end:]
            fixed_content = content.replace('--', '- ')
            return before + fixed_content + after
        return full_comment

    # Apply to all comments
    content = re.sub(r'<!--.*?-->', fix_double_dash_in_comments, content, flags=re.DOTALL)

    # 4. Fix duplicate style attributes
    def merge_styles(match):
        styles = []
        for i in range(1, 5):
            if match.group(i):
                styles.append(match.group(i))
        merged = '; '.join(styles)
        return f'style="{merged}"'

    # Pattern to match multiple style attributes
    style_pattern = r'style="([^"]*)"\s+style="([^"]*)"(?:\s+style="([^"]*)")?(?:\s+style="([^"]*)")?'
    content = re.sub(style_pattern, merge_styles, content)

    # 5. Remove any remaining invalid comment patterns
    # Fix any remaining "--" in comments by replacing with single "-"
    content = re.sub(r'(<!--.*?)(--)(.*-->)', r'\1-\3', content, flags=re.DOTALL)

    print("Fixed content length:", len(content))

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Successfully fixed {file_path}")

    # Validate that we don't have obvious issues
    invalid_patterns = [
        r'<!---',
        r'--->',
        r'<!--.*?--.*?-->',
        r'style="[^"]*"\s+style="[^"]*"'
    ]

    for pattern in invalid_patterns:
        if re.search(pattern, content, re.DOTALL):
            print(f"WARNING: Still found invalid pattern: {pattern}")

if __name__ == "__main__":
    fix_xsl_file('/workspaces/PythonFiles/Print/Master_HTML.xsl')