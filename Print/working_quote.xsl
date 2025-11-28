<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:variable name="_dsMain1" select="/transaction/data_xml/document[@document_var_name='transaction']"/>

<!-- PrintUtil stub templates -->
<xsl:template name="convertDBToPattern">
    <xsl:param name="date"/>
    <xsl:value-of select="'2024-01-01'"/>
</xsl:template>

<xsl:template name="getImageSrc">
    <xsl:param name="imageId"/>
    <xsl:value-of select="'placeholder.png'"/>
</xsl:template>

<xsl:template name="getEmbedDocSrc">
    <xsl:param name="docId"/>
    <xsl:value-of select="'document.pdf'"/>
</xsl:template>

<xsl:template name="formatIndian">
    <xsl:param name="number"/>
    <xsl:value-of select="format-number($number, '#,##0.00')"/>
</xsl:template>

<xsl:template match="/">
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Solution Quotation</title>
    <style>
        body { 
            font-family: Helvetica, Arial, sans-serif; 
            font-size: 12pt; 
            margin: 20px;
        }
        .quote-header { margin-bottom: 20px; }
        .quote-section { margin: 20px 0; }
        .quote-table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        .quote-table th, .quote-table td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        .quote-table th { background-color: #f2f2f2; font-weight: bold; }
        .quote-footer { margin-top: 30px; border-top: 1px solid #ccc; padding-top: 10px; }
    </style>
</head>
<body>
    <!-- Quote Header -->
    <div class="quote-header">
        <h1>Solution Quotation</h1>
        <p><strong>Quote Number:</strong> <xsl:value-of select="$_dsMain1/quoteNumber_t_c"/></p>
        <p><strong>Date:</strong> <xsl:call-template name="convertDBToPattern"><xsl:with-param name="date" select="$_dsMain1/quoteExportDate_t_c"/></xsl:call-template></p>
        <p><strong>Quote Name:</strong> <xsl:value-of select="$_dsMain1/quoteNameTextArea_t_c"/></p>
        <p><strong>Contact:</strong> <xsl:value-of select="$_dsMain1/salesRep_t_c"/></p>
        <p><strong>Email:</strong> <xsl:value-of select="$_dsMain1/opportunityOwnerEmail_t_c"/></p>
    </div>

    <!-- Quote Information Table -->
    <div class="quote-section">
        <h2>Quote Details</h2>
        <table class="quote-table">
            <tbody>
                <tr>
                    <td><strong>Quote Name:</strong></td>
                    <td colspan="3"><xsl:value-of select="$_dsMain1/quoteNameTextArea_t_c"/></td>
                </tr>
                <tr>
                    <td><strong>Quote Date:</strong></td>
                    <td><xsl:call-template name="convertDBToPattern"><xsl:with-param name="date" select="$_dsMain1/quoteExportDate_t_c"/></xsl:call-template></td>
                    <td><strong>Quote Valid Until:</strong></td>
                    <td><xsl:call-template name="convertDBToPattern"><xsl:with-param name="date" select="$_dsMain1/quoteExportDate_t_c"/></xsl:call-template></td>
                </tr>
                <tr>
                    <td><strong>Contact Name:</strong></td>
                    <td colspan="3"><xsl:value-of select="$_dsMain1/salesRep_t_c"/></td>
                </tr>
                <tr>
                    <td><strong>Email:</strong></td>
                    <td colspan="3"><xsl:value-of select="$_dsMain1/opportunityOwnerEmail_t_c"/></td>
                </tr>
                <tr>
                    <td><strong>Quote To:</strong></td>
                    <td colspan="3">Customer Name</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Quote Footer -->
    <div class="quote-footer">
        <p><strong>Terms and Conditions:</strong> All amounts are in <xsl:value-of select="$_dsMain1/currency_t"/></p>
        <p>Generated on: <xsl:call-template name="convertDBToPattern"><xsl:with-param name="date" select="$_dsMain1/quoteExportDate_t_c"/></xsl:call-template></p>
    </div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
