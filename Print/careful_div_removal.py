import re
import sys

with open('Final.xsl', 'r') as f:
    lines = f.readlines()

output = []
i = 0
changes = 0

while i < len(lines):
    line = lines[i]
    
    # Check if this is a <td> line
    if re.match(r'^\s*<td[^>]*>\s*$', line):
        output.append(line)
        i += 1
        
        # Check for pattern: 3 plain <div> followed by <div with attributes>
        if (i < len(lines) and re.match(r'^\s*<div>\s*$', lines[i]) and
            i+1 < len(lines) and re.match(r'^\s*<div>\s*$', lines[i+1]) and
            i+2 < len(lines) and re.match(r'^\s*<div>\s*$', lines[i+2]) and
            i+3 < len(lines) and re.match(r'^\s*<div\s+[^>]+>\s*$', lines[i+3])):
            
            # Found pattern! Save the div with attributes
            output.append(lines[i+3])
            i += 4
            
            # Now collect content until we find the closing structure
            # We need to track div depth and find where to remove closing divs
            content = []
            div_depth = 1  # We're inside the div with attributes
            found_closing = False
            
            while i < len(lines) and not found_closing:
                curr_line = lines[i]
                
                if '<div' in curr_line and not '</div>' in curr_line:
                    # Opening div
                    div_depth += 1
                    content.append(curr_line)
                    i += 1
                elif '</div>' in curr_line and '<div' not in curr_line:
                    # Closing div
                    div_depth -= 1
                    if div_depth == 0:
                        # This closes our div with attributes
                        content.append(curr_line)
                        i += 1
                        
                        # Now we should have 3 plain </div> closing tags
                        removed_closing = 0
                        while (i < len(lines) and removed_closing < 3 and 
                               re.match(r'^\s*</div>\s*$', lines[i])):
                            removed_closing += 1
                            i += 1
                        
                        if removed_closing == 3:
                            changes += 1
                            found_closing = True
                        else:
                            # Pattern didn't match completely, something is wrong
                            # Add back what we skipped
                            for _ in range(removed_closing):
                                i -= 1
                            found_closing = True
                    else:
                        content.append(curr_line)
                        i += 1
                else:
                    # Regular content line
                    content.append(curr_line)
                    i += 1
            
            output.extend(content)
            continue
    
    output.append(line)
    i += 1

# Write output
with open('Final.xsl', 'w') as f:
    f.writelines(output)

print(f"Successfully removed {changes} nested div structures")
print(f"Original: {len(lines)} lines")
print(f"New: {len(output)} lines")
print(f"Removed: {len(lines) - len(output)} lines")
