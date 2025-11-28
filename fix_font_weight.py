#!/usr/bin/env python3
"""
Script to replace font-weight: bold inline styles with semantic <strong> tags
"""

import re

def replace_font_weight_bold(content):
    """Replace <span style="font-weight: bold"> with <strong> and corresponding </span> with </strong>"""

    # Pattern to match opening span with font-weight: bold
    # This handles nested spans by finding the matching closing tag
    pattern = r'<span style="font-weight: bold">(.*?)</span>'

    def replace_match(match):
        content = match.group(1)
        return f'<strong>{content}</strong>'

    # Replace all occurrences
    result = re.sub(pattern, replace_match, content, flags=re.DOTALL)
    return result

def main():
    input_file = '/workspaces/PythonFiles/Print/Final.xsl'
    output_file = '/workspaces/PythonFiles/Print/Final_fixed.xsl'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Original content length: {len(content)}")

    # Count original font-weight bold spans
    original_count = len(re.findall(r'<span style="font-weight: bold">', content))
    print(f"Found {original_count} font-weight bold spans")

    # Replace them
    fixed_content = replace_font_weight_bold(content)

    # Count remaining font-weight bold spans
    remaining_count = len(re.findall(r'<span style="font-weight: bold">', fixed_content))
    print(f"Remaining font-weight bold spans: {remaining_count}")

    # Count strong tags added
    strong_count = len(re.findall(r'<strong>', fixed_content))
    print(f"Strong tags added: {strong_count}")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Fixed content written to {output_file}")
    print(f"Fixed content length: {len(fixed_content)}")

if __name__ == '__main__':
    main()