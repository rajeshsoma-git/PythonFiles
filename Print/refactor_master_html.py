#!/usr/bin/env python3
"""
Refactor Master_HTML.xsl to follow Child.xsl's clean, organized pattern.
This will transform the messy converted FO output into a proper HTML document.
"""

import re
from datetime import datetime

def extract_css_from_master_html():
    """Extract and organize CSS from the current Master_HTML.xsl content."""

    # Read the current Master_HTML.xsl
    with open('Master_HTML.xsl', 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract style information from inline styles
    # Look for common patterns in the converted HTML

    css_classes = []

    # Common PDF-exact styling patterns from Child.xsl
    css_classes.extend([
        "/* ===== PDF-EXACT MATCHING STYLES - CENTRALIZED REUSABLE SYSTEM ===== */",
        "",
        "/* ===== PAGE LAYOUT - EXACT FO REPLICATION ===== */",
        "@page { size: 8.5in 11in; margin: 0.2in 0.5in 0.5in 0.5in; }",
        "body {",
        "    font-family: Helvetica, Arial, sans-serif;",
        "    font-size: 12pt;",
        "    line-height: 100%;",
        "    color: #000000;",
        "    background-color: #ffffff;",
        "    margin: 0.75in 0.5in 1.0in 0.5in;",
        "    text-align: left;",
        "}",
        "",
        "/* ===== CORE TYPOGRAPHY SYSTEM - PDF EXACT MATCH ===== */",
        ".pdf-header-title { font-family: Helvetica; font-size: 20pt; color: #000000; font-weight: bold; text-align: center; line-height: 30pt; }",
        ".pdf-text-8pt { font-family: Helvetica; font-size: 8pt; color: #000000; line-height: 8pt; }",
        ".pdf-text-8pt-bold { font-family: Helvetica; font-size: 8pt; color: #000000; font-weight: bold; line-height: 8pt; }",
        ".pdf-text-10pt { font-family: Helvetica; font-size: 10pt; color: #000000; line-height: 10pt; }",
        ".pdf-text-12pt { font-family: Helvetica; font-size: 12pt; color: #000000; line-height: 12pt; }",
        ".pdf-text-12pt-bold { font-family: Helvetica; font-size: 12pt; color: #000000; font-weight: bold; line-height: 12pt; }",
        "",
        "/* ===== PDF TABLE SYSTEM - EXACT FO MATCH ===== */",
        ".pdf-table { table-layout: fixed; width: 100%; border-collapse: collapse; float: left; font-family: Helvetica; }",
        ".pdf-table-cell { padding: 4px 0px; vertical-align: top; overflow: hidden; }",
        ".pdf-table-cell-bordered { padding: 4px 0px; vertical-align: top; border: 1px solid #000000; overflow: hidden; }",
        "",
        "/* ===== PDF COLUMN WIDTH SYSTEM - EXACT PROPORTIONAL MATCH ===== */",
        ".pdf-col-100 { width: 8.33%; }   /* 100/1200 */",
        ".pdf-col-200 { width: 16.67%; }  /* 200/1200 */",
        ".pdf-col-350 { width: 29.17%; }  /* 350/1200 */",
        ".pdf-col-400 { width: 33.33%; }  /* 400/1200 */",
        "",
        "/* ===== PDF TEXT ALIGNMENT SYSTEM ===== */",
        ".pdf-text-left { text-align: left; }",
        ".pdf-text-center { text-align: center; }",
        ".pdf-text-right { text-align: right; }",
        "",
        "/* ===== PDF SPACING SYSTEM - EXACT FO MATCH ===== */",
        ".pdf-space-1pt { line-height: 1pt; font-size: 1pt; margin: 0; padding: 0; }",
        ".pdf-margin-left-3px { margin-left: 3px; }",
        ".pdf-block-margin { margin-right: 0in; margin-left: 0in; margin-bottom: 0in; margin-top: 0in; }",
        "",
        "/* ===== PDF HEADER/FOOTER SYSTEM ===== */",
        ".pdf-logo { height: 40px; width: 195px; }",
        ".pdf-footer-text { font-family: Helvetica; font-size: 8pt; color: #000000; text-align: left; line-height: 8pt; }",
        "",
        "/* ===== PDF SECTION HEADERS ===== */",
        ".pdf-section-header { font-family: Helvetica; font-size: 12pt; color: #000000; font-weight: bold; text-align: left; line-height: 12pt; }",
        ".pdf-section-spacing { margin-bottom: 0.1in; }",
        "",
        "/* ===== LEGACY COMPATIBILITY LAYER ===== */",
        ".header { font-family: Helvetica, Arial, sans-serif; font-size: 20pt; font-weight: bold; color: #000000; text-align: center; line-height: 30pt; margin-bottom: 20px; }",
        ".small-text { font-family: Helvetica, Arial, sans-serif; font-size: 8pt; color: #000000; line-height: 8pt; }",
        ".normal-text { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; color: #000000; line-height: 12pt; }",
        ".bold-text { font-weight: bold; }",
        ".section-header { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; font-weight: bold; color: #000000; text-align: left; line-height: 13pt; }",
        "table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 12pt; }",
        "table td, table th { padding: 0; vertical-align: top; text-align: left; font-weight: normal; }",
        ".text-right { text-align: right; }",
        ".text-center { text-align: center; }",
        ".text-left { text-align: left; }",
        ".header-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 0; }",
        ".info-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 10pt; }",
        ".main-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 3pt; }",
        ".col-100 { width: 8.33%; }",
        ".col-200 { width: 16.67%; }",
        ".col-250 { width: 20.83%; }",
        ".col-300 { width: 25%; }",
        ".col-400 { width: 33.33%; }",
        ".table-cell { padding: 4px 0px; vertical-align: top; }",
        ".spacing-1pt { line-height: 1pt; font-size: 1pt; margin: 0; padding: 0; }",
        ".margin-left-7pt { margin-left: 7pt; }",
        ".currency { text-align: right; font-family: Helvetica, Arial, sans-serif; font-size: 10pt; color: #000000; }",
        ".logo-container { text-align: left; padding: 4px 0px; }",
        ".logo-img { height: 40px; width: 195px; }",
        ".section-break { margin-top: 15pt; margin-bottom: 10pt; }",
        ".keep-together { page-break-inside: avoid; }",
        ".section-header { font-weight: bold; font-size: 13pt; color: #000; border-bottom: 1px solid #ccc; padding-bottom: 5px; }",
        ".config-section { page-break-inside: avoid; margin-bottom: 30px; }",
        "",
        "/* ===== PDF PRINT OPTIMIZATION ===== */",
        "@media print {",
        "    body { margin: 0.75in 0.5in 1.0in 0.5in; print-color-adjust: exact; -webkit-print-color-adjust: exact; }",
        "    .pdf-table, .main-table, .header-table, .info-table { page-break-inside: avoid; }",
        "    .keep-together { page-break-inside: avoid; }",
        "    .pdf-section-header { page-break-after: avoid; }",
        "}"
    ])

    return "\n".join(css_classes)

def create_clean_master_html_structure():
    """Create a clean Master_HTML.xsl following Child.xsl's pattern."""

    css_content = extract_css_from_master_html()

    # Read the original Master_HTML.xsl to extract templates
    with open('Master_HTML.xsl', 'r', encoding='utf-8') as f:
        original_content = f.read()

    # Extract all templates from the original (this is complex due to the messy structure)
    # For now, we'll create a clean structure and note that templates need to be migrated

    clean_structure = f'''<!--  
  Oracle CPQ Document Designer XSL Template - HTML Version
  Author: Rajesh Soma
  Created: September 2025
  Modified: {datetime.now().strftime('%B %d, %Y')} - Refactored to follow Child.xsl pattern
  Description: Clean HTML version of Master.xsl with organized structure and CSS
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0"
                xmlns:DateUtil="com.bm.xchange.util.DateUtil"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil"
                xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
                xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

<!--  Parameters from Master.xsl  -->
<xsl:param name="EMAIL_RECIPIENT_NUMFORMAT_PREF" select="''"/>
<xsl:param name="BM_IMAGESERVER_TOKEN" select="''"/>
<xsl:param name="TIME_ZONE" select="''"/>
<xsl:param name="TEMPLATE_ID" select="''"/>
<xsl:param name="TRANSACTION_ID" select="''"/>
<xsl:param name="PRINT_TIME" select="''"/>
<xsl:param name="PRINT_CODE" select="''"/>

<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<!--  Global variables from Master.xsl  -->
<xsl:variable name="FILEATTACHMENT_DELIM" select="'|^|'"/>

<!--  Critical variables from Master.xsl  -->
<!-- <xsl:variable name="currencySymbolsAndLabels" select="document('$XSL_URL$/xsl/documenteditor/currencies.xml')"/> -->
<xsl:variable name="printDateFormat" select="'dd-MMM-yyyy'"/>
<xsl:variable name="quoteCurrency" select="string($_dsMain1/currency_t)"/>

<!--  Decimal format declarations from Master.xsl  -->
<xsl:decimal-format name="american" grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="indian" grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="zimbabwe" grouping-separator="&#160;" decimal-separator="."/>
<xsl:decimal-format name="swiss" grouping-separator="'" decimal-separator="."/>
<xsl:decimal-format name="euro" grouping-separator="." decimal-separator=","/>
<xsl:decimal-format name="hungarian" grouping-separator="&#160;" decimal-separator=","/>

<!-- Template to copy all nodes, given a root node. E.g. Used to copy RTE attribute as it is, in email templates, from the input XML  -->
<xsl:template name="copyNodes">
    <xsl:param name="rootNode" />
    <xsl:copy-of select="$rootNode/*" />
</xsl:template>

<!-- ===== PRICE FORMATTING TEMPLATES ===== -->
<!-- BMI_universalFormatPriceCustom and other price formatting templates would go here -->
<!-- [TEMPLATES TO BE MIGRATED FROM ORIGINAL Master_HTML.xsl] -->

<!-- ===== MAIN TEMPLATE ===== -->
<xsl:template match="/">
    <xsl:variable name="_dsMain1" select="/transaction/data_xml/document[@document_var_name='transaction']"/>
    <xsl:variable name="_dsUser" select="/transaction/bm_user"/>
    <xsl:strip-space elements="*"/>

    <!-- HTML5 Document Structure -->
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Solution Quotation - <xsl:value-of select="$_dsMain1/quoteNumber_t_c"/></title>

        <style>
{css_content}
        </style>
    </head>
    <body>
        <!-- Page Header - NetApp Logo and Title -->
        <header class="page-header">
            <table class="pdf-table">
                <tr>
                    <td class="col-200 logo-container">
                        <img src="https://netappinctest3.bigmachines.com/bmfsweb/netappinctest3/image/logo/NetApp_Logo_QE.png"
                             alt="NetApp Logo" class="logo-img"/>
                    </td>
                    <td class="col-400 text-center">
                        <div class="pdf-header-title">
                            Solution Quotation
                            <xsl:value-of select="$_dsMain1/quoteNumber_t_c"/>
                        </div>
                    </td>
                    <td class="col-100"/>
                </tr>
            </table>
        </header>

        <!-- Quote Information Table -->
        <div class="section-break">
            <table class="pdf-table keep-together">
                <colgroup>
                    <col class="col-200"/>
                    <col class="col-250"/>
                    <col class="col-200"/>
                    <col class="col-200"/>
                </colgroup>
                <tr>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Quote Name:</td>
                    <td class="pdf-table-cell pdf-text-8pt" colspan="3">
                        <div class="margin-left-7pt">
                            <xsl:value-of select="$_dsMain1/quoteNameTextArea_t_c"/>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Quote Date:</td>
                    <td class="pdf-table-cell pdf-text-8pt">
                        <div class="margin-left-7pt">
                            <xsl:call-template name="formatDateForHTML">
                                <xsl:with-param name="dateValue" select="$_dsMain1/quoteExportDate_t_c"/>
                            </xsl:call-template>
                        </div>
                    </td>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Quote Valid Until:</td>
                    <td class="pdf-table-cell pdf-text-8pt">
                        <div class="margin-left-7pt">
                            <xsl:call-template name="formatDateForHTML">
                                <xsl:with-param name="dateValue" select="$_dsMain1/expiresOnDate_t_c"/>
                            </xsl:call-template>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Contact Name:</td>
                    <td class="pdf-table-cell pdf-text-8pt" colspan="3">
                        <div class="margin-left-7pt">
                            <xsl:value-of select="$_dsMain1/salesRep_t_c"/>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Email:</td>
                    <td class="pdf-table-cell pdf-text-8pt" colspan="3">
                        <div class="margin-left-7pt">
                            <xsl:value-of select="$_dsMain1/opportunityOwnerEmail_t_c"/>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="pdf-table-cell pdf-text-right pdf-text-8pt">Quote To:</td>
                    <td class="pdf-table-cell pdf-text-8pt" colspan="3">
                        <div class="margin-left-7pt">
                            <!-- Customer information processing -->
                            Customer Address Information
                        </div>
                    </td>
                </tr>
            </table>
        </div>

        <!-- MAIN CONTENT AREA -->
        <!-- [MAIN PROCESSING TEMPLATES TO BE MIGRATED FROM ORIGINAL] -->

        <div class="section-break">
            <h2 class="pdf-section-header pdf-section-spacing">Quote Details</h2>

            <!-- Model Processing Loop -->
            <xsl:for-each select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and ./lineType_l = 'MODEL']">
                <xsl:variable name="lineItemNumber" select="./lineItemNumber_l_c"/>

                <!-- Model Header -->
                <div class="config-section">
                    <h3 class="section-header">
                        <xsl:value-of select="./item_l/_part_number"/>
                        <xsl:if test="./item_l/_part_description != ''">
                            - <xsl:value-of select="./item_l/_part_description"/>
                        </xsl:if>
                    </h3>
                </div>

                <!-- Hardware Lines -->
                <xsl:if test="count(/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and printGrouping_l_c = 'HARDWARE']) > 0">
                    <h4 class="pdf-section-header">Hardware</h4>
                    <!-- Hardware table would go here -->
                </xsl:if>

                <!-- Software Lines -->
                <xsl:if test="count(/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and printGrouping_l_c = 'SOFTWARE']) > 0">
                    <h4 class="pdf-section-header">Software</h4>
                    <!-- Software table would go here -->
                </xsl:if>

                <!-- Service Lines -->
                <xsl:if test="count(/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and (lineType_l = 'SERVICE' or printGrouping_l_c = 'SERVICE')]) > 0">
                    <h4 class="pdf-section-header">Services</h4>
                    <!-- Services table would go here -->
                </xsl:if>

            </xsl:for-each>

            <!-- Grand Total Section -->
            <div class="section-break">
                <table class="pdf-table">
                    <tr>
                        <td class="pdf-table-cell pdf-text-right pdf-grand-total pdf-grand-total-border">
                            GRAND TOTAL: $<xsl:value-of select="format-number(sum(/transaction/data_xml/document[normalize-space(./@data_type)='3']/_extended_price), '#,##0.00')"/>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- Footer -->
        <footer class="pdf-footer-text">
            <div class="text-center">
                All amounts are in <xsl:value-of select="$_dsMain1/currency_t"/>
                | Price List: <xsl:value-of select="$_dsMain1/priceList_t_c"/>
                | Date Printed: <xsl:call-template name="formatDateForHTML">
                    <xsl:with-param name="dateValue" select="$_dsMain1/quoteExportDate_t_c"/>
                </xsl:call-template>
                | Page: 1 of 1
            </div>
        </footer>

    </body>
    </html>
</xsl:template>

<!-- ===== UTILITY TEMPLATES ===== -->

<!-- Date Formatting Template -->
<xsl:template name="formatDateForHTML">
    <xsl:param name="dateValue"/>
    <xsl:param name="format" select="$printDateFormat"/>
    <xsl:choose>
        <xsl:when test="$dateValue and $dateValue != ''">
            <xsl:choose>
                <xsl:when test="$format = 'dd-MMM-yyyy'">
                    <xsl:call-template name="convertToddMMMyyy">
                        <xsl:with-param name="date" select="$dateValue"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dateValue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Date Conversion Template -->
<xsl:template name="convertToddMMMyyy">
    <xsl:param name="date"/>
    <xsl:if test="$date != ''">
        <!-- Extract year, month, day from date (assumes YYYY-MM-DD format) -->
        <xsl:variable name="year" select="substring($date, 1, 4)"/>
        <xsl:variable name="month" select="number(substring($date, 6, 2))"/>
        <xsl:variable name="day" select="number(substring($date, 9, 2))"/>

        <!-- Format complete date as single string -->
        <xsl:variable name="formattedDate">
            <!-- Day with leading zero if needed -->
            <xsl:if test="$day &lt; 10">0</xsl:if>
            <xsl:value-of select="$day"/>
            <!-- Month abbreviation -->
            <xsl:choose>
                <xsl:when test="$month = 1">-Jan-</xsl:when>
                <xsl:when test="$month = 2">-Feb-</xsl:when>
                <xsl:when test="$month = 3">-Mar-</xsl:when>
                <xsl:when test="$month = 4">-Apr-</xsl:when>
                <xsl:when test="$month = 5">-May-</xsl:when>
                <xsl:when test="$month = 6">-Jun-</xsl:when>
                <xsl:when test="$month = 7">-Jul-</xsl:when>
                <xsl:when test="$month = 8">-Aug-</xsl:when>
                <xsl:when test="$month = 9">-Sep-</xsl:when>
                <xsl:when test="$month = 10">-Oct-</xsl:when>
                <xsl:when test="$month = 11">-Nov-</xsl:when>
                <xsl:when test="$month = 12">-Dec-</xsl:when>
                <xsl:otherwise>-???-</xsl:otherwise>
            </xsl:choose>
            <!-- Year -->
            <xsl:value-of select="$year"/>
        </xsl:variable>
        <xsl:value-of select="$formattedDate"/>
    </xsl:if>
</xsl:template>

<!-- ===== BUSINESS LOGIC TEMPLATES ===== -->
<!-- [ADDITIONAL TEMPLATES TO BE MIGRATED FROM ORIGINAL Master_HTML.xsl] -->

</xsl:stylesheet>'''

    return clean_structure

def main():
    print("Refactoring Master_HTML.xsl to follow Child.xsl's clean pattern...")

    # Create the new clean structure
    clean_content = create_clean_master_html_structure()

    # Backup the original
    import shutil
    shutil.copy('Master_HTML.xsl', 'Master_HTML_original_backup.xsl')

    # Write the new clean version
    with open('Master_HTML_clean.xsl', 'w', encoding='utf-8') as f:
        f.write(clean_content)

    print("✅ Created Master_HTML_clean.xsl with Child.xsl's organized pattern")
    print("📋 Original backed up as Master_HTML_original_backup.xsl")
    print("")
    print("Next steps:")
    print("1. Migrate remaining templates from Master_HTML.xsl to Master_HTML_clean.xsl")
    print("2. Test the XSL transformation")
    print("3. Replace Master_HTML.xsl with the clean version once fully migrated")

if __name__ == '__main__':
    main()