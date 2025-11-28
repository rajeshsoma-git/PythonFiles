#!/usr/bin/env python3
"""
Fix all malformed strong tags in Final.xsl
"""

import re

def fix_malformed_strong(content):
    """Fix malformed strong tags where </span> should be </strong>"""

    # Pattern to find <strong> followed by content and then </span>
    # We need to replace the closing </span> with </strong> for strong tags

    # First, let's find all strong tags and their positions
    strong_positions = []
    for match in re.finditer(r'<strong>', content):
        strong_positions.append(match.start())

    # Now find all </span> tags
    span_close_positions = []
    for match in re.finditer(r'</span>', content):
        span_close_positions.append(match.start())

    # For each strong opening, find the corresponding closing span and replace it
    # This is a simple approach - replace the first </span> after each <strong> with </strong>

    result = content
    offset = 0

    for strong_pos in strong_positions:
        # Find the next </span> after this <strong>
        for span_pos in span_close_positions:
            if span_pos > strong_pos:
                # Replace this </span> with </strong>
                old_span = result[span_pos + offset:span_pos + offset + 7]
                result = result[:span_pos + offset] + '</strong>' + result[span_pos + offset + 7:]
                # Remove this position from the list to avoid double replacement
                span_close_positions.remove(span_pos)
                break

    return result

def main():
    input_file = '/workspaces/PythonFiles/Print/Final.xsl'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Original content length: {len(content)}")

    # Count malformed tags
    strong_open_count = content.count('<strong>')
    strong_close_count = content.count('</strong>')
    span_close_count = content.count('</span>')

    print(f"Strong opening tags: {strong_open_count}")
    print(f"Strong closing tags: {strong_close_count}")
    print(f"Span closing tags: {span_close_count}")

    # Fix the malformed tags
    fixed_content = fix_malformed_strong(content)

    # Count again
    strong_close_count_fixed = fixed_content.count('</strong>')
    print(f"Strong closing tags after fix: {strong_close_count_fixed}")

    with open(input_file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print("Fixed malformed strong tags")

if __name__ == '__main__':
    main()