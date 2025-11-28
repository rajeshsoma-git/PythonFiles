#!/usr/bin/env python3
"""
Clean up Final.xsl by removing unnecessary nested div wrappers.
Uses lxml to safely parse and modify the XSLT file structure.
"""

from lxml import etree
import sys

def cleanup_nested_divs(input_file, output_file):
    """
    Remove unnecessary nested plain <div> wrappers inside <td> elements.
    
    Pattern to fix:
    <td>
        <div>          <!-- Remove -->
            <div>      <!-- Remove -->
                <div>  <!-- Remove (if 3 levels) -->
                    <div class="...">  <!-- Keep - has attributes -->
                        content
                    </div>
                </div>
            </div>
        </div>
    </td>
    
    Should become:
    <td>
        <div class="...">
            content
        </div>
    </td>
    """
    
    # Parse the XSL file
    print(f"Loading {input_file}...")
    parser = etree.XMLParser(remove_blank_text=False)
    tree = etree.parse(input_file, parser)
    root = tree.getroot()
    
    # Define namespaces - the file uses XHTML as default namespace
    namespaces = {
        'xsl': 'http://www.w3.org/1999/XSL/Transform',
        'xhtml': 'http://www.w3.org/1999/xhtml'
    }
    
    changes_made = 0
    
    # Find all <td> elements (these are in XHTML namespace)
    # Try both with and without namespace
    td_elements = root.xpath(".//xhtml:td", namespaces=namespaces)
    if len(td_elements) == 0:
        # Fallback: try without namespace prefix
        td_elements = root.xpath(".//*[local-name()='td']")
    print(f"Found {len(td_elements)} <td> elements")
    
    for td in td_elements:
        # Check if td contains nested plain divs
        if len(td) > 0:
            first_child = list(td)[0]  # Get first child element
            
            # Get tag name - handle namespace properly
            if isinstance(first_child.tag, str):
                # Extract local name from namespaced tag
                if '}' in first_child.tag:
                    tag_name = first_child.tag.split('}')[1]
                else:
                    tag_name = first_child.tag
                
                if tag_name == 'div':
                    # Count consecutive plain div children
                    nested_count = 0
                    current = first_child
                    
                    # Count how many plain divs are nested
                    while current is not None:
                        # Get current tag name
                        if isinstance(current.tag, str):
                            if '}' in current.tag:
                                current_tag = current.tag.split('}')[1]
                            else:
                                current_tag = current.tag
                        else:
                            break
                        
                        if (current_tag == 'div' and
                            len(current.attrib) == 0 and  # No attributes
                            len(list(current)) == 1):      # Only one child
                            next_child = list(current)[0]
                            if isinstance(next_child.tag, str):
                                if '}' in next_child.tag:
                                    next_tag = next_child.tag.split('}')[1]
                                else:
                                    next_tag = next_child.tag
                                if next_tag == 'div':
                                    nested_count += 1
                                    current = next_child
                                else:
                                    break
                            else:
                                break
                        else:
                            break
                    
                    # If we found nested plain divs, remove the wrappers
                    # Remove if 2 or more levels of nesting
                    if nested_count >= 1:  # Changed from >= 2 to >= 1
                        # Get the innermost div with attributes/content
                        innermost = first_child
                        for _ in range(nested_count):
                            innermost = list(innermost)[0]
                        
                        # Remove the outermost wrapper and replace with innermost
                        td.remove(first_child)
                        td.insert(0, innermost)
                        changes_made += 1
    
    print(f"Removed nested divs from {changes_made} table cells")
    
    # Write the modified tree back to file
    print(f"Writing to {output_file}...")
    tree.write(output_file, 
               encoding='utf-8', 
               xml_declaration=True,
               pretty_print=False)  # Preserve original formatting
    
    print(f"Done! Changes made to {changes_made} locations.")
    return changes_made

def main():
    input_file = "Final.xsl"
    output_file = "Final_cleaned.xsl"
    backup_file = "Final.xsl.lxml_backup"
    
    # Create backup
    print(f"Creating backup: {backup_file}")
    import shutil
    shutil.copy2(input_file, backup_file)
    
    # Perform cleanup
    try:
        changes = cleanup_nested_divs(input_file, output_file)
        
        if changes > 0:
            print(f"\n✓ Success! Cleaned {changes} table cells.")
            print(f"  Original: {input_file}")
            print(f"  Cleaned:  {output_file}")
            print(f"  Backup:   {backup_file}")
            print("\nNext steps:")
            print("  1. Validate XML: xmllint --noout Final_cleaned.xsl")
            print("  2. Test transformation: java -cp xalan-j_2_7_3/... -IN Quote.xml -XSL Final_cleaned.xsl -OUT test.html")
            print("  3. If successful: mv Final_cleaned.xsl Final.xsl")
        else:
            print("\n! No changes made - no nested divs found.")
        
        return 0
        
    except Exception as e:
        print(f"\n✗ Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
