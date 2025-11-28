<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:template match="/">
<html>
<head>
    <title>Test Quote</title>
</head>
<body>
    <h1>Quote Test</h1>
    <p>Quote Number: <xsl:value-of select="/transaction/data_xml/document/quoteNumber_t_c"/></p>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
