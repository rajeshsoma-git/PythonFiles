#!/usr/bin/env python3
"""
Final fixes for XSL transformation issues.
"""

import re

def fix_final_issues(content):
    """Fix the final XSL transformation issues."""

    # Fix the malformed comment on line 1384 with extra ')'
    # Look for the pattern ")-><!-" and fix it
    content = content.replace(")-><!-", "><!--")

    # Comment out the convertJsonToXml function call since it's not available
    # Replace the call with a stub that returns empty XML
    convert_pattern = r'<xsl:call-template name="convertJsonToXml">\s*<xsl:with-param name="jsonStr"[^>]*>\s*</xsl:with-param>\s*</xsl:call-template>'
    content = re.sub(convert_pattern, '<AccountXml></AccountXml>', content, flags=re.MULTILINE | re.DOTALL)

    # Comment out or stub the addHeadingStyle function calls
    heading_pattern = r'HeadingUtil:addHeadingStyle\([^)]+\)'
    content = re.sub(heading_pattern, "'stub-heading-style'", content)

    # Also handle any other extension function calls that might cause issues
    # Comment out FunctionUtil:endswith calls
    content = re.sub(r'FunctionUtil:endswith\([^)]+\)', 'false()', content)

    return content

def main():
    input_file = 'Master_HTML_final.xsl'
    output_file = 'Master_HTML_final_fixed.xsl'

    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    print(f"Processing {input_file} ({len(content)} chars)")

    fixed_content = fix_final_issues(content)

    print(f"Fixed content: {len(fixed_content)} chars")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Saved to {output_file}")

    # Validate XML
    import subprocess
    result = subprocess.run(['xmllint', '--noout', output_file],
                          capture_output=True, text=True, cwd='.')

    if result.returncode == 0:
        print("✅ XML validation passed!")
        # Try XSL transformation
        transform_result = subprocess.run([
            'java', '-cp', 'xalan-j_2_7_3/xalan.jar',
            'org.apache.xalan.xslt.Process',
            '-IN', 'Quote.xml',
            '-XSL', output_file,
            '-OUT', 'output_final_fixed.html'
        ], capture_output=True, text=True, cwd='.')

        if transform_result.returncode == 0:
            print("✅ XSL transformation successful!")
            print("Output saved to output_final_fixed.html")
        else:
            print("❌ XSL transformation failed:")
            print(transform_result.stderr[:500])
    else:
        print("❌ XML validation failed:")
        lines = result.stderr.strip().split('\n')[:5]
        for line in lines:
            print(f"  {line}")

if __name__ == '__main__':
    main()