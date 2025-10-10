#!/usr/bin/env python3
"""
Master XSL Fixer - Comprehensive script to apply all fixes to Master_HTML.xsl
Tracks every change made for complete audit trail.
"""

import re
import os
from datetime import datetime
import hashlib

class XSLFixer:
    def __init__(self, input_file, output_file=None):
        self.input_file = input_file
        self.output_file = output_file or f"{input_file}_fixed_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xsl"
        self.changes_log = []
        self.original_content = None
        self.current_content = None

    def log_change(self, change_type, description, before_count=None, after_count=None, details=None):
        """Log a change with timestamp and details."""
        timestamp = datetime.now().isoformat()
        log_entry = {
            'timestamp': timestamp,
            'type': change_type,
            'description': description,
            'before_count': before_count,
            'after_count': after_count,
            'details': details or []
        }
        self.changes_log.append(log_entry)
        print(f"[{timestamp}] {change_type}: {description}")
        if before_count is not None and after_count is not None:
            print(f"  Count: {before_count} → {after_count}")

    def load_file(self):
        """Load the input file and calculate initial hash."""
        with open(self.input_file, 'r', encoding='utf-8') as f:
            self.original_content = f.read()
        self.current_content = self.original_content
        original_hash = hashlib.md5(self.original_content.encode()).hexdigest()
        self.log_change('FILE_LOAD', f'Loaded {self.input_file}',
                       details=[f'Original size: {len(self.original_content)} chars',
                               f'MD5: {original_hash}'])

    def save_file(self):
        """Save the fixed content to output file."""
        with open(self.output_file, 'w', encoding='utf-8') as f:
            f.write(self.current_content)
        final_hash = hashlib.md5(self.current_content.encode()).hexdigest()
        self.log_change('FILE_SAVE', f'Saved to {self.output_file}',
                       details=[f'Final size: {len(self.current_content)} chars',
                               f'MD5: {final_hash}'])

    def fix_external_includes(self):
        """Comment out external xsl:include statements."""
        pattern = r'(\s*)<xsl:include\s+href="[^"]*"/>'
        matches = re.findall(pattern, self.current_content)

        if matches:
            # Replace with commented version
            def comment_replacer(match):
                return match.group(1) + '<!-- ' + match.group(0).strip() + ' -->'

            new_content = re.sub(pattern, comment_replacer, self.current_content)
            self.log_change('EXTERNAL_INCLUDES', 'Commented out external xsl:include statements',
                           len(matches), len(matches), [f'Pattern: {pattern}'])
            self.current_content = new_content

    def fix_comment_syntax(self):
        """Fix malformed XML comments."""
        fixes = [
            (r'<!---', '<!--', 'Fix malformed comment start'),
            (r'--->', '-->', 'Fix malformed comment end'),
            (r'<!--([^>]*)--([^>]*)-->', r'<!--\1--\2-->', 'Fix double hyphens in comments')
        ]

        for pattern, replacement, description in fixes:
            matches = re.findall(pattern, self.current_content)
            if matches:
                self.current_content = re.sub(pattern, replacement, self.current_content)
                self.log_change('COMMENT_SYNTAX', description, len(matches), len(matches))

    def merge_duplicate_styles(self):
        """Merge duplicate style attributes in the same element."""
        # Pattern to find elements with multiple style attributes
        pattern = r'(<[^>]+)style="([^"]*)"([^>]*style="[^"]*")([^>]*>)'

        def merge_styles(match):
            element_start = match.group(1)
            style1 = match.group(2)
            middle = match.group(3)
            element_end = match.group(4)

            # Extract second style value
            style2_match = re.search(r'style="([^"]*)"', middle)
            if style2_match:
                style2 = style2_match.group(1)
                # Combine styles
                combined_style = f'{style1}; {style2}'
                # Remove the second style attribute
                middle_clean = re.sub(r'\s*style="[^"]*"', '', middle)
                return f'{element_start}style="{combined_style}"{middle_clean}{element_end}'
            return match.group(0)

        original_content = self.current_content
        self.current_content = re.sub(pattern, merge_styles, self.current_content)

        # Count changes
        changes = original_content != self.current_content
        if changes:
            self.log_change('STYLE_MERGE', 'Merged duplicate style attributes', 1, 1)

    def fix_tag_mismatches(self):
        """Fix div-container and fo:block-container tag mismatches."""
        fixes = [
            (r'<div-container([^>]*)>', r'<div\1>', 'Replace div-container opening tags'),
            (r'</fo:block-container>', r'</div>', 'Replace fo:block-container closing tags')
        ]

        for pattern, replacement, description in fixes:
            matches = re.findall(pattern, self.current_content)
            if matches:
                self.current_content = self.current_content.replace(pattern, replacement)
                self.log_change('TAG_MISMATCH', description, len(matches), len(matches))

    def validate_xml(self):
        """Validate the XML structure using xmllint."""
        import subprocess
        import tempfile

        with tempfile.NamedTemporaryFile(mode='w', suffix='.xsl', delete=False) as temp_file:
            temp_file.write(self.current_content)
            temp_file_path = temp_file.name

        try:
            result = subprocess.run(['xmllint', '--noout', temp_file_path],
                                  capture_output=True, text=True, cwd='.')

            if result.returncode == 0:
                self.log_change('VALIDATION', 'XML validation passed', details=['✓ Valid XML structure'])
                return True
            else:
                self.log_change('VALIDATION', 'XML validation failed', details=[result.stderr.strip()])
                return False
        finally:
            os.unlink(temp_file_path)

    def generate_report(self):
        """Generate a comprehensive change report."""
        report = []
        report.append("=" * 80)
        report.append("XSL FIXER COMPREHENSIVE REPORT")
        report.append("=" * 80)
        report.append(f"Input File: {self.input_file}")
        report.append(f"Output File: {self.output_file}")
        report.append(f"Processing Date: {datetime.now().isoformat()}")
        report.append("")

        total_changes = 0
        for log_entry in self.changes_log:
            report.append(f"[{log_entry['timestamp']}] {log_entry['type']}")
            report.append(f"  Description: {log_entry['description']}")
            if log_entry['before_count'] is not None:
                report.append(f"  Changes: {log_entry['before_count']} → {log_entry['after_count']}")
                total_changes += log_entry['before_count']
            if log_entry['details']:
                for detail in log_entry['details']:
                    report.append(f"  {detail}")
            report.append("")

        report.append(f"Total Changes Applied: {total_changes}")
        report.append("=" * 80)

        return "\n".join(report)

    def run_all_fixes(self):
        """Run all fixes in sequence."""
        print("Starting comprehensive XSL fixes...")
        print("=" * 50)

        self.load_file()

        self.fix_external_includes()
        self.fix_comment_syntax()
        self.merge_duplicate_styles()
        self.fix_tag_mismatches()

        validation_passed = self.validate_xml()

        self.save_file()

        report = self.generate_report()
        print("\n" + report)

        # Save report to file
        report_file = f"{self.output_file}.report.txt"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"\nDetailed report saved to: {report_file}")

        return validation_passed

def main():
    input_file = 'Master_HTML.xsl'
    output_file = f"Master_HTML_fixed_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xsl"

    fixer = XSLFixer(input_file, output_file)
    success = fixer.run_all_fixes()

    if success:
        print("\n✅ All fixes applied successfully! XML validation passed.")
        print(f"Fixed file: {output_file}")
    else:
        print("\n⚠️  Fixes applied but XML validation failed. Check the report for details.")

if __name__ == '__main__':
    main()