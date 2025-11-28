#!/usr/bin/env python3
"""
Fix malformed strong tags in Final.xsl where opening <strong> has closing </span>
"""

import re

def fix_strong_tags(content):
    """Fix malformed strong tags by replacing </span> with </strong> after <strong>"""

    # Find all <strong> tags and their corresponding closing tags
    # This is tricky because of nesting, but we'll use a simple approach

    # Pattern to find <strong> followed by content and then </span>
    # We'll replace the closing </span> with </strong> when it follows <strong>

    lines = content.split('\n')
    fixed_lines = []
    strong_depth = 0

    for line in lines:
        # Count opening strong tags
        strong_openings = line.count('<strong>')
        strong_depth += strong_openings

        # If we're inside a strong tag, replace </span> with </strong>
        if strong_depth > 0:
            # Replace </span> with </strong> but only for the strong tags we opened
            # This is a simple heuristic - replace all </span> that come after <strong>
            # in the same line or when strong_depth > 0
            line = line.replace('</span>', '</strong>', strong_depth)

            # Decrease depth by the number of closing strong tags we just added
            strong_closings = line.count('</strong>')
            strong_depth -= strong_closings

        fixed_lines.append(line)

    return '\n'.join(fixed_lines)

def main():
    input_file = '/workspaces/PythonFiles/Print/Final.xsl'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Original content length: {len(content)}")

    # Count strong tags
    strong_open_count = content.count('<strong>')
    strong_close_count = content.count('</strong>')
    span_close_count = content.count('</span>')

    print(f"Strong opening tags: {strong_open_count}")
    print(f"Strong closing tags: {strong_close_count}")
    print(f"Span closing tags: {span_close_count}")

    # Fix the malformed tags
    fixed_content = fix_strong_tags(content)

    # Count again
    strong_close_count_fixed = fixed_content.count('</strong>')
    print(f"Strong closing tags after fix: {strong_close_count_fixed}")

    with open(input_file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print("Fixed malformed strong tags")

if __name__ == '__main__':
    main()