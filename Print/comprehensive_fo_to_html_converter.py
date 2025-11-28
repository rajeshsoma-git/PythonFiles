import re

def convert_fo_to_html(input_file, output_file=None):
    """Convert XSL-FO elements to HTML equivalents"""

    if output_file is None:
        output_file = input_file

    # Read the file
    with open(input_file, 'r') as f:
        content = f.read()

    print(f"Converting FO elements in {input_file}...")

    # Remove FO namespace from root element if present
    content = re.sub(r'xmlns:fo="http://www\.w3\.org/1999/XSL/Format"', '', content)

    # Convert structural elements
    # fo:block -> div
    content = re.sub(r'<fo:block([^>]*)>', r'<div\1>', content)
    content = re.sub(r'</fo:block>', r'</div>', content)

    # fo:inline -> span
    content = re.sub(r'<fo:inline([^>]*)>', r'<span\1>', content)
    content = re.sub(r'</fo:inline>', r'</span>', content)

    # fo:block-container -> div with container class
    content = re.sub(r'<fo:block-container([^>]*)>', r'<div class="container"\1>', content)
    content = re.sub(r'</fo:block-container>', r'</div>', content)

    # Table elements
    content = re.sub(r'<fo:table([^>]*)>', r'<table\1>', content)
    content = re.sub(r'</fo:table>', r'</table>', content)

    content = re.sub(r'<fo:table-body([^>]*)>', r'<tbody\1>', content)
    content = re.sub(r'</fo:table-body>', r'</tbody>', content)

    content = re.sub(r'<fo:table-row([^>]*)>', r'<tr\1>', content)
    content = re.sub(r'</fo:table-row>', r'</tr>', content)

    content = re.sub(r'<fo:table-cell([^>]*)>', r'<td\1>', content)
    content = re.sub(r'</fo:table-cell>', r'</td>', content)

    content = re.sub(r'<fo:table-column([^>]*)>', r'<col\1>', content)
    content = re.sub(r'</fo:table-column>', r'</col>', content)

    # fo:external-graphic -> img
    content = re.sub(r'<fo:external-graphic([^>]*)>', r'<img\1>', content)
    content = re.sub(r'</fo:external-graphic>', '', content)  # Remove closing tag

    # fo:leader -> hr
    content = re.sub(r'<fo:leader([^>]*)>', r'<hr\1>', content)
    content = re.sub(r'</fo:leader>', '', content)  # Remove closing tag

    # fo:static-content -> header/footer based on context
    # This is tricky, let's use a more sophisticated approach
    def convert_static_content(match):
        attrs = match.group(1)
        if 'region-before' in attrs or 'header' in attrs.lower():
            return f'<header{attrs}>'
        elif 'region-after' in attrs or 'footer' in attrs.lower():
            return f'<footer{attrs}>'
        else:
            return f'<div class="static-content"{attrs}>'

    content = re.sub(r'<fo:static-content([^>]*)>', convert_static_content, content)
    content = re.sub(r'</fo:static-content>', r'</div>', content)

    # Page layout elements - remove or convert to div
    content = re.sub(r'<fo:root[^>]*>', '<div class="document">', content)
    content = re.sub(r'</fo:root>', '</div>', content)

    content = re.sub(r'<fo:layout-master-set[^>]*>.*?</fo:layout-master-set>', '', content, flags=re.DOTALL)
    content = re.sub(r'<fo:simple-page-master[^>]*>.*?</fo:simple-page-master>', '', content, flags=re.DOTALL)

    content = re.sub(r'<fo:region-body[^>]*>', '<div class="page-body">', content)
    content = re.sub(r'</fo:region-body>', '</div>', content)

    content = re.sub(r'<fo:region-before[^>]*>', '<header class="page-header">', content)
    content = re.sub(r'</fo:region-before>', '</header>', content)

    content = re.sub(r'<fo:region-after[^>]*>', '<footer class="page-footer">', content)
    content = re.sub(r'</fo:region-after>', '</footer>', content)

    content = re.sub(r'<fo:region-start[^>]*>', '<aside class="page-start">', content)
    content = re.sub(r'</fo:region-start>', '</aside>', content)

    content = re.sub(r'<fo:region-end[^>]*>', '<aside class="page-end">', content)
    content = re.sub(r'</fo:region-end>', '</aside>', content)

    content = re.sub(r'<fo:page-sequence[^>]*>', '<div class="page-sequence">', content)
    content = re.sub(r'</fo:page-sequence>', '</div>', content)

    content = re.sub(r'<fo:flow[^>]*>', '<div class="content-flow">', content)
    content = re.sub(r'</fo:flow>', '</div>', content)

    # fo:bookmark-tree -> nav
    content = re.sub(r'<fo:bookmark-tree([^>]*)>', r'<nav class="bookmarks"\1>', content)
    content = re.sub(r'</fo:bookmark-tree>', r'</nav>', content)

    # fo:page-number -> span with page number class
    content = re.sub(r'<fo:page-number([^>]*)>', r'<span class="page-number"\1>', content)
    content = re.sub(r'</fo:page-number>', r'</span>', content)

    # fo:page-number-citation-last -> span
    content = re.sub(r'<fo:page-number-citation-last([^>]*)>', r'<span class="page-number-citation"\1>', content)
    content = re.sub(r'</fo:page-number-citation-last>', r'</span>', content)

    # Convert FO attributes to CSS styles
    def convert_fo_attributes(match):
        tag = match.group(1)
        attrs = match.group(2)
        if not attrs:
            return f'<{tag}>'

        # Convert common FO attributes to CSS
        conversions = {
            'font-family': 'font-family',
            'font-size': 'font-size',
            'font-weight': 'font-weight',
            'color': 'color',
            'text-align': 'text-align',
            'line-height': 'line-height',
            'margin': 'margin',
            'margin-top': 'margin-top',
            'margin-bottom': 'margin-bottom',
            'margin-left': 'margin-left',
            'margin-right': 'margin-right',
            'padding': 'padding',
            'padding-top': 'padding-top',
            'padding-bottom': 'padding-bottom',
            'padding-left': 'padding-left',
            'padding-right': 'padding-right',
            'border': 'border',
            'border-top': 'border-top',
            'border-bottom': 'border-bottom',
            'border-left': 'border-left',
            'border-right': 'border-right',
            'background-color': 'background-color',
            'width': 'width',
            'height': 'height'
        }

        styles = []
        remaining_attrs = []

        # Parse attributes
        attr_pattern = r'(\w[-\w]*)\s*=\s*["\']([^"\']*)["\']'
        for attr_match in re.finditer(attr_pattern, attrs):
            attr_name, attr_value = attr_match.groups()

            if attr_name in conversions:
                styles.append(f'{conversions[attr_name]}: {attr_value}')
            elif attr_name not in ['linefeed-treatment', 'background-repeat', 'background-position-horizontal',
                                 'background-position-vertical', 'overflow', 'column-count', 'column-gap',
                                 'reference-orientation', 'writing-mode', 'absolute-position', 'table-layout',
                                 'float', 'border-collapse', 'autoFit', 'within-page', 'column-width',
                                 'number-columns-spanned', 'cpq-cell', 'clip', 'text-align-last',
                                 'rule-thickness', 'leader-pattern', 'tab-position', 'tab-align',
                                 'flow-name', 'xfc', 'axf']:
                remaining_attrs.append(f'{attr_name}="{attr_value}"')

        # Build new tag
        new_attrs = ' '.join(remaining_attrs)
        if styles:
            style_attr = f'style="{"; ".join(styles)}"'
            if new_attrs:
                new_attrs += f' {style_attr}'
            else:
                new_attrs = style_attr

        result = f'<{tag} {new_attrs}>' if new_attrs else f'<{tag}>'

        # Fix duplicate style attributes by merging them
        if 'style=' in result:
            # Find all style attributes
            style_pattern = r'style="([^"]*)"'
            styles_found = re.findall(style_pattern, result)
            if len(styles_found) > 1:
                # Merge all style values
                merged_styles = '; '.join(styles_found)
                # Remove all style attributes and add merged one
                result = re.sub(style_pattern, '', result)
                result = re.sub(r'<(\w+)([^>]*)>', f'<\\1\\2 style="{merged_styles}">', result)

        return result

    # Apply attribute conversion to common tags
    for tag in ['div', 'span', 'img', 'hr', 'header', 'footer', 'nav']:
        pattern = f'<({tag})([^>]*)>'
        content = re.sub(pattern, convert_fo_attributes, content)

    # Convert src attribute for images (fo:external-graphic had src attribute)
    content = re.sub(r'src="([^"]*)"', r'src="\1"', content)

    # Change output method to html if not already
    content = re.sub(r'method="[^"]*"', 'method="html"', content)

    # Write back
    with open(output_file, 'w') as f:
        f.write(content)

    print(f"Conversion complete. Output saved to {output_file}")

if __name__ == "__main__":
    # Convert Master_HTML_final.xsl
    convert_fo_to_html('Master_HTML_final.xsl', 'Master_HTML_final_converted.xsl')