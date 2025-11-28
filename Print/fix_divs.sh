#!/bin/bash

# This will process the file multiple times to remove layers of nested divs
# Pattern: Remove one layer at a time

cp Final.xsl Final.xsl.temp

# Remove patterns where we have <td> followed by 3 plain <div> then <div class=...>
# We'll use Python with better control

python3 << 'PYTHON'
import re

with open('Final.xsl.temp', 'r') as f:
    content = f.read()

# Pattern: <td...>\n  <div>\n    <div>\n      <div>\n        <div class="..."
# Replace with: <td...>\n        <div class="..."
# And also remove the corresponding 3 closing </div> tags before </td>

# First, let's handle opening tags - remove 3 wrapper divs before div with attributes
lines = content.split('\n')
result = []
i = 0

while i < len(lines):
    line = lines[i]
    
    # Check if line is <td...>
    if re.match(r'^\s*<td[^>]*>$', line):
        result.append(line)
        i += 1
        
        # Collect next lines to check pattern
        if i < len(lines) and re.match(r'^\s*<div>$', lines[i]):
            div1_indent = len(lines[i]) - len(lines[i].lstrip())
            if i+1 < len(lines) and re.match(r'^\s*<div>$', lines[i+1]):
                if i+2 < len(lines) and re.match(r'^\s*<div>$', lines[i+2]):
                    if i+3 < len(lines) and re.match(r'^\s*<div\s+[^>]+>$', lines[i+3]):
                        # Found the pattern! Skip first 3 divs, keep the 4th
                        result.append(lines[i+3])
                        i += 4
                        continue
        
        # No pattern, continue normally
        continue
    
    result.append(line)
    i += 1

content = '\n'.join(result)

# Now handle closing tags - remove 3 extra </div> before </td>
lines = content.split('\n')
result = []
i = 0

while i < len(lines):
    line = lines[i]
    
    # Look for pattern: </div>\n  </div>\n</div>\n</div>\n  </td>
    # Should become: </div>\n  </td>
    if re.match(r'^\s*</div>$', line):
        # Check if followed by 3 more </div> and then </td>
        if (i+1 < len(lines) and re.match(r'^\s*</div>$', lines[i+1]) and
            i+2 < len(lines) and re.match(r'^\s*</div>$', lines[i+2]) and
            i+3 < len(lines) and re.match(r'^\s*</div>$', lines[i+3]) and
            i+4 < len(lines) and re.match(r'^\s*</td>', lines[i+4])):
            # Keep first </div>, skip next 3, continue with </td>
            result.append(line)
            i += 4  # Skip 3 closing divs
            continue
    
    result.append(line)
    i += 1

content = '\n'.join(result)

with open('Final.xsl', 'w') as f:
    f.write(content)

print("Done")
PYTHON

