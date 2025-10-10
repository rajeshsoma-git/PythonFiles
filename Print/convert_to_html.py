import re

# Read the file
with open('Master_HTML.xsl', 'r') as f:
    content = f.read()

# Replace fo: elements with HTML
# Note: This is a basic conversion, may need refinement

# fo:block -> div
content = re.sub(r'<fo:block([^>]*)>', r'<div\1>', content)
content = re.sub(r'</fo:block>', r'</div>', content)

# fo:inline -> span
content = re.sub(r'<fo:inline([^>]*)>', r'<span\1>', content)
content = re.sub(r'</fo:inline>', r'</span>', content)

# fo:table -> table
content = re.sub(r'<fo:table([^>]*)>', r'<table\1>', content)
content = re.sub(r'</fo:table>', r'</table>', content)

# fo:table-row -> tr
content = re.sub(r'<fo:table-row([^>]*)>', r'<tr\1>', content)
content = re.sub(r'</fo:table-row>', r'</tr>', content)

# fo:table-cell -> td
content = re.sub(r'<fo:table-cell([^>]*)>', r'<td\1>', content)
content = re.sub(r'</fo:table-cell>', r'</td>', content)

# fo:table-body -> tbody
content = re.sub(r'<fo:table-body([^>]*)>', r'<tbody\1>', content)
content = re.sub(r'</fo:table-body>', r'</tbody>', content)

# fo:root -> remove or replace with div
content = re.sub(r'<fo:root[^>]*>', r'<div>', content)
content = re.sub(r'</fo:root>', r'</div>', content)

# fo:layout-master-set -> remove
content = re.sub(r'<fo:layout-master-set[^>]*>.*?</fo:layout-master-set>', r'', content, flags=re.DOTALL)

# fo:simple-page-master -> remove
content = re.sub(r'<fo:simple-page-master[^>]*>.*?</fo:simple-page-master>', r'', content, flags=re.DOTALL)

# fo:region-body -> remove
content = re.sub(r'<fo:region-body[^>]*>', r'', content)
content = re.sub(r'</fo:region-body>', r'', content)

# fo:page-sequence -> remove
content = re.sub(r'<fo:page-sequence[^>]*>', r'', content)
content = re.sub(r'</fo:page-sequence>', r'', content)

# fo:flow -> remove
content = re.sub(r'<fo:flow[^>]*>', r'', content)
content = re.sub(r'</fo:flow>', r'', content)

# Now, convert FO attributes to CSS styles
# This is tricky, but let's do some basic ones

# Function to convert attributes
def convert_attributes(match):
    attrs = match.group(1)
    # Basic conversions
    attrs = re.sub(r'font-family="([^"]*)"', r'style="font-family: \1"', attrs)
    attrs = re.sub(r'font-size="([^"]*)"', r'style="font-size: \1"', attrs)
    attrs = re.sub(r'color="([^"]*)"', r'style="color: \1"', attrs)
    attrs = re.sub(r'text-align="([^"]*)"', r'style="text-align: \1"', attrs)
    attrs = re.sub(r'line-height="([^"]*)"', r'style="line-height: \1"', attrs)
    attrs = re.sub(r'margin="([^"]*)"', r'style="margin: \1"', attrs)
    attrs = re.sub(r'padding="([^"]*)"', r'style="padding: \1"', attrs)
    # Remove FO specific attributes
    attrs = re.sub(r'\s*linefeed-treatment="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*background-repeat="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*background-position-[^=]*="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*overflow="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*column-count="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*column-gap="[^"]*"', '', attrs)
    attrs = re.sub(r'\s*margin-[^=]*="[^"]*"', '', attrs)  # Remove specific margins, keep general
    return f'<div{attrs}>'

# Apply to divs (formerly fo:block)
content = re.sub(r'<div([^>]*)>', convert_attributes, content)

# Similar for span
def convert_span_attributes(match):
    attrs = match.group(1)
    attrs = re.sub(r'font-family="([^"]*)"', r'style="font-family: \1"', attrs)
    attrs = re.sub(r'font-size="([^"]*)"', r'style="font-size: \1"', attrs)
    attrs = re.sub(r'color="([^"]*)"', r'style="color: \1"', attrs)
    attrs = re.sub(r'font-weight="([^"]*)"', r'style="font-weight: \1"', attrs)
    return f'<span{attrs}>'

content = re.sub(r'<span([^>]*)>', convert_span_attributes, content)

# Change output method to html
content = re.sub(r'method="[^"]*"', 'method="html"', content)

# Write back
with open('Master_HTML.xsl', 'w') as f:
    f.write(content)

print("Converted Master.xsl to HTML format as Master_HTML.xsl")