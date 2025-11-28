import re

with open('generated_quote_final.html', 'r') as f:
    content = f.read()

# Find all tables and their context
lines = content.split('\n')
table_depth = 0
for i, line in enumerate(lines[460:600], start=461):  # Focus on body tables
    if '<table' in line:
        indent = '  ' * table_depth
        print(f"{i}: {indent}TABLE OPEN (depth {table_depth})")
        table_depth += 1
    if '</table>' in line:
        table_depth -= 1
        indent = '  ' * table_depth
        print(f"{i}: {indent}TABLE CLOSE (depth {table_depth})")
    if table_depth > 0 and i < 480:
        print(f"{i}: {line[:100]}")
