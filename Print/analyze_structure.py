# Analyze the table structure to understand the nesting
with open('generated_quote_final.html', 'r') as f:
    content = f.read()

lines = content.split('\n')
in_main_table = False
depth = 0

for i, line in enumerate(lines[700:1100], start=701):
    if '<table' in line.lower():
        if 'table-container-borderless' in line:
            print(f"Line {i}: {'  ' * depth}BORDERLESS TABLE START")
        else:
            print(f"Line {i}: {'  ' * depth}TABLE START")
        depth += 1
    if '</table>' in line.lower():
        depth -= 1
        print(f"Line {i}: {'  ' * depth}TABLE END")
    if i in [920, 940, 960, 980]:
        print(f"Line {i}: {line[:120]}")
