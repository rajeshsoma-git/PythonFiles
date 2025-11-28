#!/usr/bin/env python3
"""
Apply date formatting to all date fields in Final.xsl
"""

import re

def apply_date_formatting(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    changes_made = 0
    
    # Pattern 1: Simple xsl:value-of with date fields (serviceStartDate_l_c, serviceEndDate_l_c, etc.)
    # Match patterns like: <xsl:value-of select=" ./serviceStartDate_l_c"/>
    patterns_to_replace = [
        (r'<xsl:value-of select="\s*\./serviceStartDate_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./serviceStartDate_l_c"/></xsl:call-template>'),
        
        (r'<xsl:value-of select="\s*\./serviceEndDate_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./serviceEndDate_l_c"/></xsl:call-template>'),
        
        (r'<xsl:value-of select="\s*\./addOnStartDate_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./addOnStartDate_l_c"/></xsl:call-template>'),
        
        (r'<xsl:value-of select="\s*\./warrantyEndDate_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./warrantyEndDate_l_c"/></xsl:call-template>'),
        
        (r'<xsl:value-of select="\s*\./targetReadinessDateKS_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./targetReadinessDateKS_l_c"/></xsl:call-template>'),
        
        (r'<xsl:value-of select="\s*\./targetSiteReadinessDate_KFS_l_c\s*"/>', 
         '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="./targetSiteReadinessDate_KFS_l_c"/></xsl:call-template>'),
    ]
    
    for pattern, replacement in patterns_to_replace:
        new_content = re.sub(pattern, replacement, content)
        count = len(re.findall(pattern, content))
        if count > 0:
            print(f"Replaced {count} occurrences of: {pattern[:50]}...")
            changes_made += count
            content = new_content
    
    # Special handling for display_value patterns (EOSL dates, etc.)
    # Pattern: <xsl:value-of select="$_dsTxnArray/attribute[@var_name='eOSLDate_renewalAssets_Array_l_c']/@display_value"/>
    eosl_display_pattern = r'<xsl:value-of select="\$_dsTxnArray/attribute\[@var_name=\'eOSLDate_renewalAssets_Array_l_c\'\]/@display_value"/>'
    eosl_replacement = '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="$_dsTxnArray/attribute[@var_name=\'eOSLDate_renewalAssets_Array_l_c\']/@display_value"/></xsl:call-template>'
    
    eosl_count = len(re.findall(eosl_display_pattern, content))
    if eosl_count > 0:
        content = re.sub(eosl_display_pattern, eosl_replacement, content)
        print(f"Replaced {eosl_count} EOSL display_value date occurrences")
        changes_made += eosl_count
    
    # Pattern for apply-templates fallback for EOSL
    eosl_apply_pattern = r'<xsl:apply-templates select="\$_dsTxnArray/attribute\[@var_name=\'eOSLDate_renewalAssets_Array_l_c\'\]"/>'
    eosl_apply_replacement = '<xsl:call-template name="BMI_formatDateDDMMMYYYY"><xsl:with-param name="date" select="$_dsTxnArray/attribute[@var_name=\'eOSLDate_renewalAssets_Array_l_c\']"/></xsl:call-template>'
    
    eosl_apply_count = len(re.findall(eosl_apply_pattern, content))
    if eosl_apply_count > 0:
        content = re.sub(eosl_apply_pattern, eosl_apply_replacement, content)
        print(f"Replaced {eosl_apply_count} EOSL apply-templates date occurrences")
        changes_made += eosl_apply_count
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\n✅ Total changes made: {changes_made}")
        print(f"✅ File updated successfully: {file_path}")
        return True
    else:
        print("⚠️ No changes were made to the file")
        return False

if __name__ == "__main__":
    file_path = "/workspaces/PythonFiles/Print/Final.xsl"
    apply_date_formatting(file_path)
