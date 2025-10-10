import pandas as pd
import lxml.etree as LET
def validate_porting_and_generate_report(master_templates, master_vars, master_params, child_templates, child_vars, child_params, report_path):
    """
    Validate if all templates, variables, and params from Master.xsl are present in Child_ported.xsl.
    Generate an Excel file with columns: Name, Type, Master, Child, XPath, XPathMatchesQuote
    """
    # Load Quote.xml for XPath validation
    try:
        quote_tree = LET.parse('Print/Quote.xml')
        quote_root = quote_tree.getroot()
    except Exception as e:
        quote_tree = None
        quote_root = None
        print(f"Warning: Could not load Quote.xml for XPath validation: {e}")

    def get_xpath(elem):
        # Try to extract a relevant XPath from select, test, or match attributes
        for attr in ["select", "test", "match"]:
            if attr in elem.attrib:
                return elem.attrib[attr]
        return ''

    def xpath_matches(xml_root, xpath_expr):
        if not xml_root or not xpath_expr or not isinstance(xpath_expr, str):
            return ''
        try:
            # Remove $ prefix for variables, as lxml expects context nodes
            xpath_expr = xpath_expr.replace('$', '')
            result = xml_root.xpath(xpath_expr)
            return 'Yes' if result else 'No'
        except Exception:
            return 'Error'

    records = []
    # Templates
    for name, elem in master_templates.items():
        xpath = get_xpath(elem)
        match = xpath_matches(quote_root, xpath)
        records.append({
            'Name': name,
            'Type': 'template',
            'Master': 'Yes',
            'Child': 'Yes' if name in child_templates else 'No',
            'XPath': xpath,
            'XPathMatchesQuote': match
        })
    # Variables
    for name, elem in master_vars.items():
        xpath = get_xpath(elem)
        match = xpath_matches(quote_root, xpath)
        records.append({
            'Name': name,
            'Type': 'variable',
            'Master': 'Yes',
            'Child': 'Yes' if name in child_vars else 'No',
            'XPath': xpath,
            'XPathMatchesQuote': match
        })
    # Params
    for name, elem in master_params.items():
        xpath = get_xpath(elem)
        match = xpath_matches(quote_root, xpath)
        records.append({
            'Name': name,
            'Type': 'param',
            'Master': 'Yes',
            'Child': 'Yes' if name in child_params else 'No',
            'XPath': xpath,
            'XPathMatchesQuote': match
        })
    df = pd.DataFrame(records)
    df.sort_values(['Type', 'Name'], inplace=True)
    df.to_excel(report_path, index=False)
    print(f"Validation report written to {report_path}")
"""
xsl_porter.py

Automates the porting of missing templates, variables, and params from Master.xsl to Child.xsl, adapting XPaths for the child XML structure.

Steps:
1. Parse Master.xsl and Child.xsl to extract all templates, variables, and params.
2. Identify missing elements in Child.xsl.
3. (To be implemented) Adapt XPaths to match child XML structure (Quote.xml).
4. (To be implemented) Write ported elements to Child_ported.xsl.

Usage:
    python xsl_porter.py
"""


import xml.etree.ElementTree as ET
import re
from collections import defaultdict


# File paths (update as needed)
MASTER_XSL = 'Print/Master.xsl'
CHILD_XSL = 'Print/Child.xsl'
QUOTE_XML = 'Print/Quote.xml'



def extract_elements(xsl_path):
    """Extracts templates, variables, and params from an XSL file."""
    tree = ET.parse(xsl_path)
    root = tree.getroot()
    ns = {'xsl': 'http://www.w3.org/1999/XSL/Transform'}

    templates = {}
    variables = {}
    params = {}

    for elem in root.findall('.//xsl:template', ns):
        name = elem.get('name')
        if name:
            templates[name] = elem
    for elem in root.findall('.//xsl:variable', ns):
        name = elem.get('name')
        if name:
            variables[name] = elem
    for elem in root.findall('.//xsl:param', ns):
        name = elem.get('name')
        if name:
            params[name] = elem
    return templates, variables, params


def adapt_xpath(xpath_expr):
    """
    Adapt XPaths from Master.xsl to match the child XML structure (Quote.xml).
    - /transaction/data_xml/@currency  => //document[@document_var_name='transaction']/@currency
    - /transaction/data_xml/field      => //document[@document_var_name='transaction']/field
    - Handles array/set structures as well.
    """
    # Replace /transaction/data_xml/field with //document[@document_var_name='transaction']/field
    xpath_expr = re.sub(r"/transaction/data_xml/?", "//document[@document_var_name='transaction']/", xpath_expr)
    # Replace $rootNode/* with //document[@document_var_name='transaction']/*
    xpath_expr = re.sub(r"\$rootNode/\*", "//document[@document_var_name='transaction']/*", xpath_expr)
    # Add more rules as needed for your XML structure
    return xpath_expr



def update_xpaths_in_element(elem):
    """Recursively update XPath expressions in select, test, match attributes."""
    def fix_tag(e):
        # If the tag is an XSLT element (param, variable, template, etc.), force xsl: prefix
        local = e.tag.split('}')[-1] if '}' in e.tag else e.tag
        if local in {"param", "variable", "template", "choose", "when", "otherwise", "if", "call-template", "with-param", "value-of", "for-each", "copy-of", "stylesheet", "output", "include", "import", "key", "element", "attribute", "text", "number", "sort", "apply-templates", "message", "comment", "processing-instruction", "fallback", "namespace-alias", "decimal-format", "strip-space", "preserve-space", "attribute-set", "document"}:
            e.tag = f"xsl:{local}"
        for attr in ["select", "test", "match"]:
            if attr in e.attrib:
                e.attrib[attr] = adapt_xpath(e.attrib[attr])
        for child in e:
            fix_tag(child)
    fix_tag(elem)
    return elem





def append_ported_params(missing_params, master_params, output_path):
    """Append all adapted missing params to the output XSL file after variables."""
    # Read the existing Child_ported.xsl
    with open(output_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find insertion point (before </xsl:stylesheet>)
    insert_marker = '<!-- END PORTED PARAMS -->'
    idx = content.find(insert_marker)
    if idx == -1:
        print(f"Insertion marker not found in {output_path}. Aborting param append.")
        return

    # Build param XML strings, always use <xsl:param>
    param_xml = []
    for p in sorted(missing_params):
        elem = master_params[p]
        elem = update_xpaths_in_element(elem)
        elem.tag = '{http://www.w3.org/1999/XSL/Transform}param'
        param_xml.append(ET.tostring(elem, encoding='unicode'))

    # Insert params before the marker
    new_content = content[:idx] + '\n' + '\n'.join(param_xml) + '\n' + content[idx:]

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Appended {len(missing_params)} params to {output_path}")

def append_ported_variables(missing_vars, master_vars, output_path):
    """Append all adapted missing variables to the output XSL file after templates and before params."""
    # Read the existing Child_ported.xsl
    with open(output_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find insertion point (before <!-- END PORTED VARIABLES -->)
    insert_marker = '<!-- END PORTED VARIABLES -->'
    idx = content.find(insert_marker)
    if idx == -1:
        print(f"Insertion marker not found in {output_path}. Aborting variable append.")
        return

    # Build variable XML strings, always use <xsl:variable>
    var_xml = []
    for v in sorted(missing_vars):
        elem = master_vars[v]
        elem = update_xpaths_in_element(elem)
        elem.tag = '{http://www.w3.org/1999/XSL/Transform}variable'
        var_xml.append(ET.tostring(elem, encoding='unicode'))

    # Insert variables before the marker
    new_content = content[:idx] + '\n' + '\n'.join(var_xml) + '\n' + content[idx:]

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Appended {len(missing_vars)} variables to {output_path}")




def main():
    import datetime
    import os
    today = datetime.datetime.now().strftime('%m%d%Y')
    out_xsl = f'Print/ExcelPrint_{today}.xsl'
    # Extract elements from Master and Child for deduplication and appending
    master_templates, master_vars, master_params = extract_elements(MASTER_XSL)
    child_templates, child_vars, child_params = extract_elements(CHILD_XSL)
    # Use Child.xsl as the base structure
    child_tree = ET.parse(CHILD_XSL)
    child_root = child_tree.getroot()
    new_root = ET.Element(child_root.tag, child_root.attrib)
    # ...existing code for generating the XSL file...


    # --- Post-processing: Only after the XSL file is generated and out_xsl exists ---
    if os.path.exists(out_xsl):
        import re
        # Always load the XSL as text for post-processing
        with open(out_xsl, 'r', encoding='utf-8') as f:
            xsl_content = f.read()

        # Remove <xsl:variable name="currencySymbolsAndLabels" .../>
        xsl_content = re.sub(r'<xsl:variable[^>]*name=["\']currencySymbolsAndLabels["\'][^>]*/>\s*', '', xsl_content)

        # Remove BMI_universalFormatPriceCustom template (from <xsl:template name="BMI_universalFormatPriceCustom"> to </xsl:template>)
        xsl_content = re.sub(r'<xsl:template[^>]*name=["\']BMI_universalFormatPriceCustom["\'][\s\S]*?</xsl:template>', '', xsl_content)

        # Remove netapp_formatPrice template (if present)
        xsl_content = re.sub(r'<xsl:template[^>]*name=["\']netapp_formatPrice["\'][\s\S]*?</xsl:template>', '', xsl_content)

        # Remove all variables referencing $currencySymbolsAndLabels
        xsl_content = re.sub(r'<xsl:variable[^>]*select=["\'][^"\']*\$currencySymbolsAndLabels[^"\']*["\'][^>]*/>\s*', '', xsl_content)

        # Replace all <xsl:call-template name="BMI_universalFormatPriceCustom"> and <xsl:call-template name="netapp_formatPrice"> with <xsl:call-template name="format-currency">
        xsl_content = re.sub(r'<xsl:call-template name=["\']BMI_universalFormatPriceCustom["\']>', '<xsl:call-template name="format-currency">', xsl_content)
        xsl_content = re.sub(r'<xsl:call-template name=["\']netapp_formatPrice["\']>', '<xsl:call-template name="format-currency">', xsl_content)

        # Remove all <xsl:with-param ...> for params not used by format-currency (keep only amount/price)
        # Remove with-param for multiplier, showCents, precision, currency, showCurrencySymbol, decimalFormatClass, basePrecision
        xsl_content = re.sub(r'<xsl:with-param name="(multiplier|showCents|precision|currency|showCurrencySymbol|decimalFormatClass|basePrecision)"[\s\S]*?</xsl:with-param>', '', xsl_content)

        # Rename <xsl:with-param name="price" ...> to <xsl:with-param name="amount" ...>
        xsl_content = re.sub(r'<xsl:with-param name="price"', '<xsl:with-param name="amount"', xsl_content)

        # Insert format-currency template from Child.xsl at the end (before </xsl:stylesheet>)
        # (template already extracted below as format_currency_template)
        format_currency_template = '''
    <xsl:template name="format-currency">
        <xsl:param name="amount"/>
        <!-- Get currency from XML -->
        <xsl:variable name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
        <!-- Map currency code to symbol -->
        <xsl:variable name="currencySymbol">
            <xsl:choose>
                <xsl:when test="$currency = 'JPY'">¥</xsl:when>
                <xsl:when test="$currency = 'USD'">$</xsl:when>
                <xsl:when test="$currency = 'EUR'">€</xsl:when>
                <xsl:when test="$currency = 'GBP'">£</xsl:when>
                <xsl:when test="$currency = 'INR'">₹</xsl:when>
                <xsl:when test="$currency = 'CNY'">¥</xsl:when>
                <xsl:when test="$currency = 'AUD'">A$</xsl:when>
                <xsl:when test="$currency = 'CAD'">C$</xsl:when>
                <xsl:when test="$currency = 'SGD'">S$</xsl:when>
                <xsl:when test="$currency = 'CHF'">CHF </xsl:when>
                <xsl:when test="$currency = 'SEK'">kr</xsl:when>
                <xsl:when test="$currency = 'NOK'">kr</xsl:when>
                <xsl:when test="$currency = 'DKK'">kr</xsl:when>
                <xsl:when test="$currency = 'NZD'">NZ$</xsl:when>
                <xsl:when test="$currency = 'HKD'">HK$</xsl:when>
                <xsl:when test="$currency = 'KRW'">₩</xsl:when>
                <xsl:when test="$currency = 'MXN'">$</xsl:when>
                <xsl:when test="$currency = 'BRL'">R$</xsl:when>
                <xsl:when test="$currency = 'ZAR'">R</xsl:when>
                <xsl:when test="$currency = 'RUB'">₽</xsl:when>
                <xsl:when test="$currency = 'TRY'">₺</xsl:when>
                <xsl:when test="$currency = 'PLN'">zł</xsl:when>
                <xsl:when test="$currency = 'THB'">฿</xsl:when>
                <xsl:when test="$currency = 'MYR'">RM</xsl:when>
                <xsl:when test="$currency = 'IDR'">Rp</xsl:when>
                <xsl:when test="$currency = 'PHP'">₱</xsl:when>
                <xsl:when test="$currency = 'ILS'">₪</xsl:when>
                <xsl:when test="$currency = 'AED'">د.إ</xsl:when>
                <xsl:when test="$currency = 'SAR'">﷼</xsl:when>
                <xsl:otherwise><xsl:value-of select="$currency"/><xsl:text> </xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Determine decimal places based on currency -->
        <xsl:variable name="decimalPlaces">
            <xsl:choose>
                <xsl:when test="$currency = 'JPY' or $currency = 'KRW' or $currency = 'VND' or $currency = 'IDR' or $currency = 'CLP' or $currency = 'ISK' or $currency = 'PYG'">0</xsl:when>
                <xsl:when test="$currency = 'BHD' or $currency = 'JOD' or $currency = 'KWD' or $currency = 'OMR' or $currency = 'TND'">3</xsl:when>
                <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Format pattern based on decimal places -->
        <xsl:variable name="formatPattern">
            <xsl:choose>
                <xsl:when test="$decimalPlaces = '0'">#,##0</xsl:when>
                <xsl:when test="$decimalPlaces = '3'">#,##0.000</xsl:when>
                <xsl:otherwise>#,##0.00</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Determine if symbol goes after amount (European style) -->
        <xsl:variable name="symbolAfter">
            <xsl:choose>
                <xsl:when test="$currency = 'SEK' or $currency = 'NOK' or $currency = 'DKK' or $currency = 'PLN' or $currency = 'ZAR'">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Output formatted currency -->
        <xsl:choose>
            <xsl:when test="string($amount) = 'NaN' or string($amount) = ''">
                <xsl:choose>
                    <xsl:when test="$symbolAfter = 'true'">
                        <xsl:text>0 </xsl:text><xsl:value-of select="$currencySymbol"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$currencySymbol"/><xsl:text>0</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$symbolAfter = 'true'">
                        <xsl:value-of select="format-number($amount, $formatPattern)"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$currencySymbol"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$currencySymbol"/>
                        <xsl:value-of select="format-number($amount, $formatPattern)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    '''
        # Insert before </xsl:stylesheet>
        xsl_content = re.sub(r'(</xsl:stylesheet>)', format_currency_template + r'\1', xsl_content, flags=re.IGNORECASE)

        # Replace 'Quote To' concat with two value-ofs and a comma
        xsl_content = xsl_content.replace(
            '<xsl:value-of select="concat(//document[@document_var_name=\'transaction\']/_commerce_array_set_attr_info[@setName=\'accounts_Array_t_c\']/_array_set_row[@_row_number=\'2\']/attribute[@var_name=\'company_accounts_Array_t_c\'], ", ", //document[@document_var_name=\'transaction\']/_commerce_array_set_attr_info[@setName=\'accounts_Array_t_c\']/_array_set_row[@_row_number=\'2\']/attribute[@var_name=\'address_accounts_Array_t_c\'])" />',
            '<xsl:value-of select="//document[@document_var_name=\'transaction\']/_commerce_array_set_attr_info[@setName=\'accounts_Array_t_c\']/_array_set_row[@_row_number=\'2\']/attribute[@var_name=\'company_accounts_Array_t_c\']"/>, <xsl:value-of select="//document[@document_var_name=\'transaction\']/_commerce_array_set_attr_info[@setName=\'accounts_Array_t_c\']/_array_set_row[@_row_number=\'2\']/attribute[@var_name=\'address_accounts_Array_t_c\']"/>'
        )
        # Replace 'Quote From' concat with two value-ofs and a comma
        xsl_content = xsl_content.replace(
            '<xsl:value-of select="concat(//document[@document_var_name=\'transaction\']/legalEntities_t_c, ", ", //document[@document_var_name=\'transaction\']/legalEntityAddress_t_c)" />',
            '<xsl:value-of select="//document[@document_var_name=\'transaction\']/legalEntities_t_c"/> , <xsl:value-of select="//document[@document_var_name=\'transaction\']/legalEntityAddress_t_c"/>'
        )

        # --- Clean up all invalid concat() calls in the generated XSL file ---
        def clean_concat_args(match):
            args = match.group(1)
            # Split by comma, strip whitespace
            arg_list = [a.strip() for a in args.split(',')]
            # Remove empty arguments
            arg_list = [a for a in arg_list if a]
            # Remove trailing commas (shouldn't be any after above, but just in case)
            while arg_list and not arg_list[-1]:
                arg_list.pop()
            # Rejoin
            return 'concat(' + ', '.join(arg_list) + ')'
        xsl_content = re.sub(r'concat\(([^)]*)\)', clean_concat_args, xsl_content)

        with open(out_xsl, 'w', encoding='utf-8') as f:
            f.write(xsl_content)

    # Now append only top-level params, variables, and templates from Master.xsl (with adapted XPaths, no duplicates)
    master_tree = ET.parse(MASTER_XSL)
    master_root = master_tree.getroot()
    # Append params first
    for elem in master_root.findall('xsl:param', {'xsl': 'http://www.w3.org/1999/XSL/Transform'}):
        name = elem.get('name')
        if name and name not in child_params:
            elem = update_xpaths_in_element(elem)
            elem.tag = 'xsl:param'
            new_root.append(elem)
    # Then variables
    for elem in master_root.findall('xsl:variable', {'xsl': 'http://www.w3.org/1999/XSL/Transform'}):
        name = elem.get('name')
        if name and name not in child_vars:
            elem = update_xpaths_in_element(elem)
            elem.tag = 'xsl:variable'
            new_root.append(elem)
    # Then templates
    for elem in master_root.findall('xsl:template', {'xsl': 'http://www.w3.org/1999/XSL/Transform'}):
        name = elem.get('name')
        if name and name not in child_templates:
            elem = update_xpaths_in_element(elem)
            elem.tag = 'xsl:template'
            new_root.append(elem)

    # Register the XSLT namespace with the 'xsl' prefix for output
    ET.register_namespace('xsl', 'http://www.w3.org/1999/XSL/Transform')
    ET.ElementTree(new_root).write(out_xsl, encoding='utf-8', xml_declaration=True)


    # --- Post-process using lxml to fix select attributes with concat() ---
    from lxml import etree as LET
    parser = LET.XMLParser(recover=True, remove_blank_text=False)
    tree = LET.parse(out_xsl, parser)
    root = tree.getroot()
    # Tags to check
    tags = ['{http://www.w3.org/1999/XSL/Transform}value-of', '{http://www.w3.org/1999/XSL/Transform}copy-of', '{http://www.w3.org/1999/XSL/Transform}variable', '{http://www.w3.org/1999/XSL/Transform}param']
    for elem in root.iter():
        if elem.tag in tags and 'select' in elem.attrib and 'concat(' in elem.attrib['select']:
            select = elem.attrib['select']
            # Replace all double-quoted string literals inside concat() with single quotes
            import re
            def replace_concat_literals(expr):
                # Find all concat(...) calls
                def concat_replacer(m):
                    inside = m.group(1)
                    # Replace all "..." with '...'
                    return 'concat(' + re.sub(r'"([^"]*)"', lambda qm: "'" + qm.group(1) + "'", inside) + ')'
                # Use a regex that matches concat(...) with possible newlines inside
                return re.sub(r'concat\((.*?)\)', concat_replacer, expr)
            fixed = replace_concat_literals(select)
            elem.attrib['select'] = fixed
    tree.write(out_xsl, encoding='utf-8', xml_declaration=True, pretty_print=False)

    print(f'{out_xsl} has been generated using Child.xsl as the base, with all top-level params, variables, and templates from Master.xsl appended (no duplicates, adapted XPaths, correct xsl: prefix, concat fix, and single-quote string literals).')

    # --- Validate the generated XSL by applying it to Quote.xml ---
    import lxml.etree as LET
    try:
        xsl_tree = LET.parse(out_xsl)
        xslt = LET.XSLT(xsl_tree)
    except LET.XMLSyntaxError as e:
        print(f'ERROR: Generated XSL is not well-formed XML: {e}')
        return
    except LET.XSLTParseError as e:
        print(f'ERROR: Generated XSL is not a valid XSLT stylesheet: {e}')
        return

    try:
        xml_tree = LET.parse(QUOTE_XML)
        result = xslt(xml_tree)
        print('SUCCESS: XSLT transformation ran without errors on Quote.xml.')
    except LET.XSLTApplyError as e:
        print(f'ERROR: XSLT transformation failed on Quote.xml: {e}')
    except Exception as e:
        print(f'ERROR: Unexpected error during XSLT transformation: {e}')

    # Validate and generate Excel report
    child_templates, child_vars, child_params = extract_elements('Print/Child_ported.xsl')
    validate_porting_and_generate_report(
        master_templates, master_vars, master_params,
        child_templates, child_vars, child_params,
        'porting_validation_report.xlsx'
    )

if __name__ == '__main__':
    main()
