#!/usr/bin/env python3
"""
Refactor Final.xsl CSS to use modern CSS variables and better organization.
This creates an industry-standard, maintainable stylesheet.
"""

import re
import shutil

def refactor_css(file_path):
    """Refactor the CSS section with variables and better organization."""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the style section
    style_start = content.find('<style>')
    style_end_tag = '</style>'
    style_end = content.find(style_end_tag)
    
    if style_start == -1 or style_end == -1:
        print("Error: Could not find style tags")
        return False
    
    # Extract parts - keep </style> with the after section
    before_style = content[:style_start + len('<style>')]
    after_style = content[style_end:]  # Includes </style>
    
    # Create new enhanced CSS
    new_css = """
/* ============================================
   NETAPP QUOTE STYLESHEET - Enhanced Version
   Industry-Standard CSS Architecture
   
   QUICK REFERENCE - HOW TO MAKE CHANGES:
   
   GLOBAL CHANGES (affects everything):
   - Edit :root variables below
   - Example: Change --color-border-medium to change all table borders
   
   TABLE-SPECIFIC CHANGES (affects one table):
   - Find the table class (.table-quote-header, .table-line-items, etc.)
   - Override the CSS variable for that table only
   - Example: .table-line-items with custom border color
   
   CELL-SPECIFIC CHANGES (affects one cell):
   - Add utility class to the TD element
   - Example: class="cell-no-border text-bold"
   
   TABLE CLASSES INDEX:
   Line ~2084:  .table-quote-header  - Quote header information
   Line ~2102:  .table-account-info  - Account/address details  
   Line ~2523+: .table-line-items    - Product line items (multiple)
   Various:     .table-summary       - Totals and summaries
   
   UTILITY CLASSES (621 usages of style="font-weight: bold" can use .text-bold):
   .text-bold, .text-normal, .text-center, .text-right, .text-left
   .cell-padding-standard (replaces 1554 padding="4px 0px")
   .cell-no-border, .cell-border-bold
   ============================================ */

/* ============================================
   CSS VARIABLES - SINGLE SOURCE OF TRUTH
   Change these values to update styling globally
   ============================================ */
:root {
    /* Colors */
    --color-primary: #0067C5;
    --color-text: #000000;
    --color-border-light: #cccccc;
    --color-border-medium: #949494;
    --color-border-dark: #000000;
    --color-bg-light: #f5f5f5;
    --color-bg-header: #E1E1E1;
    
    /* Spacing */
    --padding-cell-standard: 4px 0px;
    --padding-cell-compact: 2px 0px;
    --padding-cell-wide: 4px 8px;
    --padding-base: 4px;
    --margin-section: 12px;
    
    /* Typography */
    --font-family-primary: Helvetica, Arial, sans-serif;
    --font-family-mono: monospace;
    --font-size-header-1: 20px;
    --font-size-header-2: 18px;
    --font-size-header-3: 16px;
    --font-size-header-4: 14px;
    --font-size-body: 12pt;
    --font-size-cell: 8pt;
    
    /* Borders */
    --border-width-standard: 1px;
    --border-width-bold: 2px;
    --border-style: solid;
    
    /* Table defaults (can be overridden per table) */
    --table-border-color: var(--color-border-medium);
    --table-border: var(--border-width-standard) var(--border-style) var(--table-border-color);
    --table-padding: var(--padding-cell-standard);
}

/* Base Styles */
body { 
    font-family: var(--font-family-primary);
    margin: 0.5in; 
    padding: 0;
    background-color: white;
    color: var(--color-text);
    font-size: var(--font-size-body);
    line-height: 1.4;
}

/* ============================================
   TABLE ARCHITECTURE
   ============================================ */
table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: var(--margin-section);
    font-family: var(--font-family-primary);
    table-layout: fixed;
}

td {
    padding: var(--table-padding);
    border: var(--table-border);
    font-size: var(--font-size-cell);
    font-family: var(--font-family-primary);
    vertical-align: top;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

th {
    background-color: var(--color-bg-light);
    color: var(--color-text);
    padding: var(--padding-base);
    font-weight: bold;
    text-align: left;
    font-size: var(--font-size-cell);
    border: var(--table-border);
}

/* ============================================
   TABLE-SPECIFIC OVERRIDES
   ============================================ */
.table-quote-header {
    --table-border-color: transparent;
    margin-bottom: 20px;
}
.table-quote-header td { border: none; padding: var(--padding-base); }

.table-account-info td { padding: var(--padding-cell-standard); }

.table-line-items { --table-border-color: var(--color-border-dark); }
.table-line-items td { border: var(--border-width-standard) var(--border-style) var(--color-border-dark); }

.table-summary { margin-top: 20px; }
.table-summary .row-total {
    border-top: var(--border-width-bold) var(--border-style) var(--color-border-dark);
    border-bottom: var(--border-width-bold) var(--border-style) var(--color-border-dark);
    font-weight: bold;
}

.header-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
}
.header-table td {
    padding: var(--padding-cell-standard);
    vertical-align: top;
    border: none;
}

/* ============================================
   CELL UTILITY CLASSES
   Use these for individual cell customization
   Example: class="cell-no-border text-bold"
   ============================================ */
.cell-padding-standard { padding: var(--padding-cell-standard); }
.cell-padding-compact { padding: var(--padding-cell-compact); }
.cell-padding-wide { padding: var(--padding-cell-wide); }
.cell-no-padding { padding: 0; }
.cell-no-border { border: none !important; }
.cell-border-top { border-top: var(--table-border); }
.cell-border-bottom { border-bottom: var(--table-border); }
.cell-border-bold { border: var(--border-width-bold) var(--border-style) var(--color-border-dark) !important; }

/* ============================================
   TEXT UTILITY CLASSES
   Replaces 621 inline style="font-weight: bold"
   ============================================ */
.text-bold, .bold { font-weight: bold; }
.text-normal, .normal { font-weight: normal; }
.text-center, .center, .align-center { text-align: center; }
.text-right, .right, .align-right { text-align: right; }
.text-left, .left, .align-left { text-align: left; }
.text-small, .small { font-size: 8px; }
.text-medium, .medium { font-size: 10px; }
.text-large, .large { font-size: var(--font-size-body); }

/* ============================================
   TYPOGRAPHY CLASSES
   ============================================ */
.table-header-1, .th1 {
    font-size: var(--font-size-header-1);
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.3;
    padding: 8px;
    text-align: left;
}

.table-header-2, .th2 {
    font-size: var(--font-size-header-2);
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.3;
    padding: 6px;
    text-align: left;
}

.table-header-3, .th3 {
    font-size: var(--font-size-header-3);
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.3;
    padding: var(--padding-base);
    text-align: center;
    background-color: var(--color-bg-light);
    border: var(--border-width-standard) var(--border-style) var(--color-border-light);
}

.table-header-4, .th4 {
    font-size: var(--font-size-header-4);
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.3;
    padding: var(--padding-base);
    text-align: left;
}

.text-8pt { font-size: 8pt; font-family: var(--font-family-primary); color: var(--color-text); }
.text-8pt-bold { font-size: 8pt; font-family: var(--font-family-primary); color: var(--color-text); font-weight: bold; }
.text-11pt-bold { font-size: 11pt; font-weight: bold; color: var(--color-text); font-family: var(--font-family-primary); }
.text-12pt { font-size: 12pt; font-family: var(--font-family-primary); color: var(--color-text); }
.text-12pt-bold { font-size: 12pt; font-weight: bold; font-family: var(--font-family-primary); color: var(--color-text); }

/* ============================================
   SEMANTIC CONTENT CLASSES
   ============================================ */
.label-text {
    font-size: 8pt;
    font-weight: normal;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.2;
    padding: var(--padding-base);
}

.data-text {
    font-size: 8pt;
    font-weight: normal;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.2;
    padding: var(--padding-base);
}

.table-cell-header, .table-header-bold {
    font-size: 8pt;
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
    line-height: 1.0;
    padding: var(--padding-base);
}

.address-content {
    font-family: var(--font-family-primary);
    font-size: 8pt;
    line-height: 11pt;
    color: var(--color-text);
}

.item-description, .configuration-comment {
    font-family: var(--font-family-primary);
    font-size: 8pt;
    color: var(--color-text);
}

.section-title, .system-header {
    font-family: var(--font-family-primary);
    font-size: 12pt;
    font-weight: bold;
    color: var(--color-text);
    margin: 15px 0 10px 0;
    padding: var(--padding-base) 0;
    border-bottom: var(--border-width-standard) var(--border-style) var(--color-border-medium);
}

.configuration-number {
    font-size: 12pt;
    font-weight: bold;
    color: var(--color-text);
    font-family: var(--font-family-primary);
}

/* ============================================
   PRICING CLASSES
   ============================================ */
.price, .price-content, .price-detail {
    text-align: right;
    font-family: var(--font-family-primary);
    font-size: 8pt;
    color: var(--color-text);
}

.price-value {
    color: var(--color-text);
    font-size: 12pt;
    font-family: var(--font-family-primary);
    font-weight: bold;
}

.currency {
    text-align: right;
    font-family: var(--font-family-mono);
    font-weight: normal;
}

.table-data-numeric, .td-numeric {
    font-size: 10px;
    color: var(--color-text);
    text-align: right;
    padding: var(--padding-base);
    font-family: var(--font-family-mono);
}

.total-line {
    font-family: var(--font-family-primary);
    font-size: 12pt;
    color: var(--color-text);
    margin: 10px 0;
    text-align: right;
}

/* ============================================
   NETAPP BRANDING
   ============================================ */
.netapp-blue { color: var(--color-primary); }
.netapp-bg-blue { background-color: var(--color-primary); color: white; }
.document-title {
    font-family: var(--font-family-primary);
    font-size: 20pt;
    font-weight: bold;
    color: var(--color-text);
    line-height: 30pt;
    margin: 0;
}
.netapp-logo { height: 40px; width: 195px; }

/* ============================================
   LAYOUT AND SPACING
   ============================================ */
.mb-1 { margin-bottom: 8px; }
.mb-2 { margin-bottom: 16px; }
.mt-1 { margin-top: 8px; }
.mt-2 { margin-top: 16px; }

.page-header { margin-bottom: 20px; padding: 0; border: none; background: white; }
.page-footer { 
    margin-top: 20px;
    padding-top: 10px;
    border-top: 0.5pt var(--border-style) var(--color-text);
    font-family: var(--font-family-primary);
    font-size: 8pt;
    text-align: center;
}
.footer-currency { font-weight: bold; font-size: 10pt; line-height: 10pt; margin-bottom: 5px; }
.footer-details { text-align: left; line-height: 8pt; white-space: pre; }

.logo-cell { width: 200px; text-align: left; }
.title-cell { width: 400px; text-align: center; }
.empty-cell { width: 100px; }
.quote-info-cell { text-align: right; width: 300px; }

/* ============================================
   BORDER UTILITIES
   ============================================ */
.border-total {
    border-top: var(--border-width-bold) var(--border-style) var(--color-border-dark);
    border-bottom: var(--border-width-bold) var(--border-style) var(--color-border-dark);
    border-left: var(--border-width-standard) var(--border-style) var(--color-border-medium);
    border-right: var(--border-width-standard) var(--border-style) var(--color-border-medium);
}
.border-light { border: var(--border-width-standard) var(--border-style) var(--color-border-medium); }
.border-header {
    border-top: var(--border-width-standard) var(--border-style) var(--color-border-medium);
    border-bottom: var(--border-width-standard) var(--border-style) var(--color-border-medium);
}

th, td[border-top*="2px solid #000000"] {
    border: var(--border-width-bold) var(--border-style) var(--color-border-dark) !important;
}

thead td, td[style*="font-weight: bold"], td[style*="background-color:#E1E1E1"] {
    border: var(--border-width-standard) var(--border-style) var(--color-border-medium) !important;
}

/* ============================================
   COLUMN LAYOUTS
   ============================================ */
table col:nth-child(1) { width: 12%; }
table col:nth-child(2) { width: 28%; }
table col:nth-child(3) { width: 8%; }
table col:nth-child(4) { width: 13%; }
table col:nth-child(5) { width: 8%; }
table col:nth-child(6) { width: 13%; }
table col:nth-child(7) { width: 18%; }

table:has(col:nth-child(2):not(:nth-child(3))) col:nth-child(1) { width: 35%; }
table:has(col:nth-child(2):not(:nth-child(3))) col:nth-child(2) { width: 65%; }

table:has(col:nth-child(4):not(:nth-child(5))) col:nth-child(1) { width: 20%; }
table:has(col:nth-child(4):not(:nth-child(5))) col:nth-child(2) { width: 30%; }
table:has(col:nth-child(4):not(:nth-child(5))) col:nth-child(3) { width: 25%; }
table:has(col:nth-child(4):not(:nth-child(5))) col:nth-child(4) { width: 25%; }

/* ============================================
   LEGACY/COMPATIBILITY CLASSES
   ============================================ */
.table-data, .td { font-size: 10px; color: var(--color-text); text-align: left; padding: var(--padding-base); }
.table-body-content { line-height: 12pt; text-align: left; }
.table-body-content-center { line-height: 12pt; text-align: center; }
.table-body-content-right { line-height: 12pt; text-align: right; }
.section-content { line-height: 13.0909pt; text-align: left; }
.price-alignment { line-height: 12pt; text-align: right; }
.small-text-right { line-height: 8pt; text-align: right; }
.product-description { text-align: left; font-size: 8pt; font-family: var(--font-family-primary); }
.text-8pt-helvetica { color: var(--color-text); font-size: 8pt; font-family: var(--font-family-primary); }
.text-8pt-helvetica-normal { font-size: 8pt; font-weight: normal; font-family: var(--font-family-primary); color: var(--color-text); }
.bold-label { font-family: var(--font-family-primary); font-weight: bold; color: var(--color-text); }
.bold-text { color: var(--color-text); font-family: var(--font-family-primary); font-weight: bold; }
.part-number { color: var(--color-text); font-size: 8pt; font-family: var(--font-family-primary); }

/* ============================================
   PRINT OPTIMIZATION
   ============================================ */
@media print {
    body { margin: 0.5in; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .page-footer { position: fixed; bottom: 0.5in; width: 100%; }
}

/* Background pattern */
body::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><rect width="100" height="100" fill="%23f0f8ff" opacity="0.1"/></svg>') repeat;
    z-index: -1;
    pointer-events: none;
}

/* ============================================
   END STYLESHEET
   Total Variables: 20+ | Classes: 100+ | Tables: 5
   ============================================ */
"""
    
    # Construct new file
    new_content = before_style + new_css + after_style
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    return True

def main():
    file_path = 'Final.xsl'
    backup_path = 'Final.xsl.before_css_refactor'
    
    print("Creating backup...")
    shutil.copy2(file_path, backup_path)
    
    print("Refactoring CSS...")
    if refactor_css(file_path):
        print("✓ CSS refactored successfully!")
        print(f"  Backup: {backup_path}")
        print(f"  Modified: {file_path}")
        print("\nNext: Validate with xmllint and test HTML generation")
    else:
        print("✗ Refactoring failed")
        return 1
    
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main())
