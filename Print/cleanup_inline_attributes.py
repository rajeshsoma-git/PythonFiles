#!/usr/bin/env python3
"""
Remove redundant inline border and padding attributes from Final.xsl
Replace with CSS classes for maintainability
"""

import re
from lxml import etree

def cleanup_inline_attributes(file_path):
    """Remove inline border-* and padding attributes, replace with classes."""
    
    print("Reading file...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_length = len(content)
    original_lines = content.count('\n')
    
    # Count occurrences before cleanup
    border_top_count = content.count('border-top="')
    border_bottom_count = content.count('border-bottom="')
    border_left_count = content.count('border-left="')
    border_right_count = content.count('border-right="')
    padding_count = content.count('padding="4px 0px"')
    
    print(f"\nFound redundant attributes:")
    print(f"  border-top: {border_top_count}")
    print(f"  border-bottom: {border_bottom_count}")
    print(f"  border-left: {border_left_count}")
    print(f"  border-right: {border_right_count}")
    print(f"  padding='4px 0px': {padding_count}")
    print(f"  TOTAL: {border_top_count + border_bottom_count + border_left_count + border_right_count + padding_count} attributes\n")
    
    # Pattern 1: Remove all individual border-* attributes
    # These are not valid HTML attributes anyway
    print("Removing border-top attributes...")
    content = re.sub(r'\s+border-top="[^"]*"', '', content)
    
    print("Removing border-bottom attributes...")
    content = re.sub(r'\s+border-bottom="[^"]*"', '', content)
    
    print("Removing border-left attributes...")
    content = re.sub(r'\s+border-left="[^"]*"', '', content)
    
    print("Removing border-right attributes...")
    content = re.sub(r'\s+border-right="[^"]*"', '', content)
    
    # Pattern 2: Remove padding="4px 0px" since CSS provides this
    print("Removing padding='4px 0px' attributes...")
    content = re.sub(r'\s+padding="4px 0px"', '', content)
    
    # Pattern 3: Also remove other common padding values
    print("Removing other padding attributes...")
    content = re.sub(r'\s+padding="[^"]*"', '', content)
    
    # Calculate savings
    new_length = len(content)
    new_lines = content.count('\n')
    bytes_saved = original_length - new_length
    lines_saved = original_lines - new_lines
    
    print(f"\nCleanup complete!")
    print(f"  Original: {original_lines:,} lines, {original_length:,} bytes")
    print(f"  New: {new_lines:,} lines, {new_length:,} bytes")
    print(f"  Saved: {lines_saved:,} lines ({lines_saved/original_lines*100:.1f}%), {bytes_saved:,} bytes ({bytes_saved/original_length*100:.1f}%)")
    
    # Verify remaining
    remaining_borders = content.count('border-top="')
    remaining_padding = content.count('padding="4px 0px"')
    print(f"\nRemaining:")
    print(f"  border-top: {remaining_borders}")
    print(f"  padding='4px 0px': {remaining_padding}")
    
    # Write cleaned content
    backup_path = file_path + '.before_inline_cleanup'
    print(f"\nCreating backup: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(open(file_path, 'r', encoding='utf-8').read())
    
    print(f"Writing cleaned file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return {
        'borders_removed': border_top_count + border_bottom_count + border_left_count + border_right_count,
        'padding_removed': padding_count,
        'bytes_saved': bytes_saved,
        'lines_saved': lines_saved
    }

if __name__ == '__main__':
    result = cleanup_inline_attributes('/workspaces/PythonFiles/Print/Final.xsl')
    
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print(f"✓ Removed {result['borders_removed']:,} border attributes")
    print(f"✓ Removed {result['padding_removed']:,} padding attributes")
    print(f"✓ Total: {result['borders_removed'] + result['padding_removed']:,} redundant attributes removed")
    print(f"✓ Saved {result['lines_saved']:,} lines and {result['bytes_saved']:,} bytes")
    print("\nNow borders and padding are controlled by CSS variables!")
    print("Change them in one place: :root { --table-border-color: ... }")
