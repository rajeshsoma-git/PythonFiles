#!/usr/bin/env python3

import subprocess
import sys
import os

def transform_with_java_xalan():
    """Try to use Java Xalan processor"""
    try:
        # Try with system Java and Xalan
        result = subprocess.run([
            'java', 
            'org.apache.xalan.xslt.Process',
            '-in', 'Quote_eosl_cleaned.xml',
            '-xsl', 'Final.xsl',
            '-out', 'excel_generic_output.html'
        ], capture_output=True, text=True, cwd='/workspaces/PythonFiles/Print')
        
        if result.returncode == 0:
            print("✓ Successfully generated excel_generic_output.html with Java Xalan")
            return True
        else:
            print(f"Java Xalan failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"Java Xalan error: {e}")
        return False

def transform_with_lxml():
    """Try to use Python lxml"""
    try:
        from lxml import etree
        
        # Load XML and XSL
        with open('/workspaces/PythonFiles/Print/Quote_eosl_cleaned.xml', 'r') as f:
            xml_doc = etree.parse(f)
        
        with open('/workspaces/PythonFiles/Print/Final.xsl', 'r') as f:
            xsl_doc = etree.parse(f)
        
        # Transform
        transform = etree.XSLT(xsl_doc)
        result = transform(xml_doc)
        
        # Write output
        with open('/workspaces/PythonFiles/Print/excel_generic_output.html', 'w') as f:
            f.write(str(result))
        
        print("✓ Successfully generated excel_generic_output.html with Python lxml")
        return True
        
    except Exception as e:
        print(f"Python lxml error: {e}")
        return False

def main():
    print("Attempting XSLT transformation with Excel-optimized stylesheet...")
    
    # Change to the correct directory
    os.chdir('/workspaces/PythonFiles/Print')
    
    # Try Java Xalan first
    if transform_with_java_xalan():
        return
    
    # Try Python lxml
    if transform_with_lxml():
        return
    
    print("❌ All XSLT transformation methods failed")
    sys.exit(1)

if __name__ == "__main__":
    main()