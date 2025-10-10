# PythonFiles

# xsl_porter.py Usage

This script automates the porting of all templates, variables, and params from `Print/Master.xsl` to `Print/Child_ported.xsl`, adapting XPaths for the child XML structure. It also generates an Excel validation report.

## How to Use

1. Ensure you have Python 3.8+ and the following packages installed:
   - pandas
   - openpyxl

   You can install them with:
   ```bash
   pip install pandas openpyxl
   ```

2. Place your XSL files in the `Print/` directory:
   - `Master.xsl` (source)
   - `Child.xsl` (original child stylesheet)
   - `Child_ported.xsl` (target, will be updated)
   - `Quote.xml` (for XPath adaptation, if needed)

3. Run the script:
   ```bash
   python xsl_porter.py
   ```
   or, if using a virtual environment:
   ```bash
   .venv/bin/python xsl_porter.py
   ```

4. Output:
   - All missing templates, variables, and params from `Master.xsl` will be appended to `Child_ported.xsl`.
   - An Excel report `porting_validation_report.xlsx` will be generated, showing porting status.

## Notes
- The script adapts XPaths in select, test, and match attributes to fit the child XML structure.
- Ensure `Child_ported.xsl` contains the following markers for correct insertion:
  - `<!-- END PORTED VARIABLES -->`
  - `<!-- END PORTED PARAMS -->`
- Review the output for any manual adjustments needed for complex XPaths or logic.

---