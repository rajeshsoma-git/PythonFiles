#!/usr/bin/env python3
"""
Remove empty spacer rows from Final.xsl
These are <tr> elements with only empty <td> cells used for spacing
"""

import re

def remove_empty_spacer_rows(file_path):
    """Remove empty <tr> rows with only empty <td> cells."""
    
    print("Reading file...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_length = len(content)
    original_lines = content.count('\n')
    
    # Pattern: <tr> with 2 or more empty <td> cells (with whitespace)
    # Matches patterns like:
    # <tr>
    #   <td>
    #   </td>
    #   <td>
    #   </td>
    #   ...
    # </tr>
    
    pattern = r'<tr>\s*(?:<td>\s*</td>\s*){2,}</tr>'
    
    matches = re.findall(pattern, content)
    count_before = len(matches)
    
    print(f"\nFound {count_before} empty spacer rows")
    
    if count_before > 0:
        print("\nExample of what will be removed:")
        print(matches[0][:300] + "...")
    
    print("\nRemoving empty spacer rows...")
    content_cleaned = re.sub(pattern, '', content)
    
    # Calculate savings
    new_length = len(content_cleaned)
    new_lines = content_cleaned.count('\n')
    bytes_saved = original_length - new_length
    lines_saved = original_lines - new_lines
    
    # Verify removal
    matches_after = re.findall(pattern, content_cleaned)
    
    print(f"\nCleanup complete!")
    print(f"  Original: {original_lines:,} lines, {original_length:,} bytes")
    print(f"  New: {new_lines:,} lines, {new_length:,} bytes")
    print(f"  Removed: {count_before} empty rows")
    print(f"  Saved: {lines_saved:,} lines ({lines_saved/original_lines*100:.2f}%), {bytes_saved:,} bytes ({bytes_saved/original_length*100:.2f}%)")
    print(f"  Remaining empty rows: {len(matches_after)}")
    
    # Create backup
    backup_path = file_path + '.before_empty_row_removal'
    print(f"\nCreating backup: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(open(file_path, 'r', encoding='utf-8').read())
    
    # Write cleaned content
    print(f"Writing cleaned file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content_cleaned)
    
    return {
        'rows_removed': count_before,
        'bytes_saved': bytes_saved,
        'lines_saved': lines_saved
    }

if __name__ == '__main__':
    result = remove_empty_spacer_rows('/workspaces/PythonFiles/Print/Final.xsl')
    
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"✓ Removed {result['rows_removed']} empty spacer rows")
    print(f"✓ Saved {result['lines_saved']:,} lines and {result['bytes_saved']:,} bytes")
    print("\nThese rows were redundant - CSS table margins provide spacing!")
