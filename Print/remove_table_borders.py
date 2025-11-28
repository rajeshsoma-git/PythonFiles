#!/usr/bin/env python3
"""
Remove all table borders by setting them to 0px.
Handles both CSS styles and inline border attributes.
"""

import re

def remove_table_borders(file_path):
    """Set all table borders to 0px (keeping the attributes/styles)."""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Fix CSS border definitions in style blocks
    # Change "border: 1px solid #..." to "border: 0px solid #..." (keep color but set to 0px)
    content = re.sub(r'border:\s*\d+\.?\d*(px|pt)\s+solid\s+(#[0-9a-fA-F]+);', r'border: 0px solid \2;', content)
    
    # Change specific border sides in CSS (border-top, border-bottom, etc.)
    content = re.sub(r'border-(top|bottom|left|right):\s*\d+\.?\d*(px|pt)\s+solid\s+(#[0-9a-fA-F]+|[a-z]+);', r'border-\1: 0px solid \3;', content)
    
    # 2. Fix inline border attributes on td/table elements
    # Change border-top="1px solid #..." to border-top="0px solid #..."
    content = re.sub(r'border-(top|bottom|left|right)="(\d+\.?\d*)(px|pt)\s+solid\s+([^"]+)"', r'border-\1="0px solid \4"', content)
    
    # Change border="1px solid #..." to border="0px solid #..."
    content = re.sub(r'border="(\d+\.?\d*)(px|pt)\s+solid\s+([^"]+)"', r'border="0px solid \3"', content)
    
    # 3. Fix !important rules
    content = re.sub(r'border:\s*\d+\.?\d*(px|pt)\s+solid\s+(#[0-9a-fA-F]+)\s*!important;', r'border: 0px solid \2 !important;', content)
    
    # Count changes
    changes = len([i for i, (c1, c2) in enumerate(zip(original_content, content)) if c1 != c2])
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return changes > 0

if __name__ == '__main__':
    import shutil
    
    file_path = 'Final.xsl'
    backup_path = 'Final.xsl.before_border_removal'
    
    # Create backup
    print(f"Creating backup: {backup_path}")
    shutil.copy2(file_path, backup_path)
    
    # Remove borders
    print("Setting all table borders to 0px...")
    if remove_table_borders(file_path):
        print("✓ Borders set to 0px successfully")
        print(f"  Backup: {backup_path}")
        print(f"  Modified: {file_path}")
    else:
        print("! No changes made")
