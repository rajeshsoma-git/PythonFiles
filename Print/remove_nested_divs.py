import re

with open('Final.xsl', 'r') as f:
    lines = f.readlines()

# Track changes
changes = 0
i = 0
output = []

while i < len(lines):
    line = lines[i]
    
    # Check if this is a td opening tag
    if re.match(r'^\s*<td[^>]*>\s*$', line):
        output.append(line)
        i += 1
        
        # Count consecutive plain <div> tags
        div_lines = []
        div_indents = []
        j = i
        
        while j < len(lines) and re.match(r'^\s*<div>\s*$', lines[j]):
            div_lines.append(j)
            div_indents.append(len(lines[j]) - len(lines[j].lstrip()))
            j += 1
        
        # If we have 3+ plain divs followed by a div with attributes
        if len(div_lines) >= 3 and j < len(lines):
            # Check if next line is a div with class or attributes
            if re.match(r'^\s*<div\s+[^>]+>\s*$', lines[j]):
                # Skip the 3 wrapper divs, keep the one with attributes
                output.append(lines[j])
                i = j + 1
                
                # Now we need to find and remove the corresponding 3 closing </div> tags
                # We'll collect lines until we hit the closing </td>
                content_lines = []
                depth = 1  # We're inside one div (the one with class)
                
                while i < len(lines):
                    curr = lines[i]
                    
                    if '</div>' in curr:
                        depth -= 1
                        if depth == 0:
                            # This closes the div with class
                            output.append(curr)
                            i += 1
                            
                            # Now skip the next 3 plain </div> closing tags
                            skipped = 0
                            while i < len(lines) and skipped < 3:
                                if re.match(r'^\s*</div>\s*$', lines[i]):
                                    skipped += 1
                                    i += 1
                                else:
                                    break
                            changes += 1
                            break
                        else:
                            content_lines.append(curr)
                    elif '<div' in curr:
                        depth += 1
                        content_lines.append(curr)
                    else:
                        content_lines.append(curr)
                    
                    i += 1
                
                output.extend(content_lines)
                continue
        
        # No pattern match, continue normally
        for idx in div_lines:
            output.append(lines[idx])
        i = j
    else:
        output.append(line)
        i += 1

with open('Final.xsl', 'w') as f:
    f.writelines(output)

print(f"Removed nested divs in {changes} locations")
