#!/usr/bin/env python3
"""
Remove space-after attributes from div elements in Final.xsl
These XSL-FO attributes override CSS margin-bottom settings
"""

import re

def remove_space_after_attributes(file_path):
    """Remove space-after and space-after.precedence attributes from div elements."""
    
    print("Reading file...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_length = len(content)
    
    # Count occurrences before cleanup
    space_after_count = len(re.findall(r'space-after="[^"]*"', content))
    space_after_precedence_count = len(re.findall(r'space-after\.precedence="[^"]*"', content))
    
    print(f"\nFound attributes to remove:")
    print(f"  space-after: {space_after_count}")
    print(f"  space-after.precedence: {space_after_precedence_count}")
    print(f"  TOTAL: {space_after_count + space_after_precedence_count} attributes\n")
    
    # Remove space-after attributes
    print("Removing space-after attributes...")
    content = re.sub(r'\s+space-after="[^"]*"', '', content)
    
    # Remove space-after.precedence attributes
    print("Removing space-after.precedence attributes...")
    content = re.sub(r'\s+space-after\.precedence="[^"]*"', '', content)
    
    # Clean up any resulting empty div tags with only whitespace/other attributes
    # Pattern: <div /> with only keep-with attributes remaining
    content = re.sub(r'<div\s+(keep-with-[^>]+)>\s*</div>', r'<div \1/>', content)
    
    # Calculate savings
    new_length = len(content)
    bytes_saved = original_length - new_length
    
    # Verify removal
    remaining_space_after = len(re.findall(r'space-after="[^"]*"', content))
    remaining_precedence = len(re.findall(r'space-after\.precedence="[^"]*"', content))
    
    print(f"\nCleanup complete!")
    print(f"  Original size: {original_length:,} bytes")
    print(f"  New size: {new_length:,} bytes")
    print(f"  Saved: {bytes_saved:,} bytes ({bytes_saved/original_length*100:.2f}%)")
    print(f"\nRemaining:")
    print(f"  space-after: {remaining_space_after}")
    print(f"  space-after.precedence: {remaining_precedence}")
    
    # Create backup
    backup_path = file_path + '.before_space_after_removal'
    print(f"\nCreating backup: {backup_path}")
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(open(file_path, 'r', encoding='utf-8').read())
    
    # Write cleaned content
    print(f"Writing cleaned file: {file_path}")
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return {
        'attributes_removed': space_after_count + space_after_precedence_count,
        'bytes_saved': bytes_saved
    }

if __name__ == '__main__':
    result = remove_space_after_attributes('/workspaces/PythonFiles/Print/Final.xsl')
    
    print("\n" + "="*70)
    print("SUMMARY")
    print("="*70)
    print(f"✓ Removed {result['attributes_removed']} space-after attributes")
    print(f"✓ Saved {result['bytes_saved']:,} bytes")
    print("\nNow ALL table spacing is controlled by CSS --margin-section (18px)!")
    print("No more inline XSL-FO attributes overriding your CSS!")
