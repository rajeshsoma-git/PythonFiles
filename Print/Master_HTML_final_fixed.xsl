<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl"><xsl:param name="EMAIL_RECIPIENT_NUMFORMAT_PREF" select="&#39;&#39;"/><xsl:param name="BM_IMAGESERVER_TOKEN" select="&#39;&#39;"/><xsl:param name="TIME_ZONE" select="&#39;&#39;"/><xsl:param name="TEMPLATE_ID" select="&#39;&#39;"/><xsl:param name="TRANSACTION_ID" select="&#39;&#39;"/><xsl:param name="PRINT_TIME" select="&#39;&#39;"/><xsl:param name="PRINT_CODE" select="&#39;&#39;"/><xsl:output method="html"/><!-- <xsl:include href="http://localhost:8080/xsl/templateengine/xhtml-to-fo-full.xsl"/> --><xsl:variable name="FILEATTACHMENT_DELIM" select="&#39;|^|&#39;"/>

<!-- Template to copy all nodes, given a root node. E.g. Used to copy RTE attribute as it is, in email templates, from the input XML  -->
<xsl:template name="copyNodes">
    <xsl:param name="rootNode" />
    <xsl:copy-of select="$rootNode/*" />
</xsl:template>

<xsl:template name="BMI_universalFormatPriceCustom">
    <!-- 
        The currency symbol and number format are separate variables in this template.
        Currency symbol can appear before number, after number, or not at all.
    -->
    <xsl:param name="price"/>
    
    <xsl:param name="multiplier" select="1"/>
    <xsl:param name="showCents" select="true()"/>
    <xsl:param name="precision" select="2"/>
    
    <xsl:param name="currency" select="'USD'"/> <!-- /transaction/data_xml/@currency -->
    <xsl:param name="showCurrencySymbol"/> <!-- 0: None, 1: Before, 2: After -->
    <xsl:param name="decimalFormatClass" /><!-- determines decimal and group separators -->
    
    <!--<xsl:param name="format" />  group and decimal pattern - TODO pattern is made by xsl with adjusted precision -->
    
    <!-- the format for printing currency symbol -->
    <xsl:variable name="currencyFormatForSymbol" select="$currencySymbolsAndLabels/currencies/currency[@name=$currency]"/>
    
    <!-- the currency symbol's whitespace -->
    <xsl:variable name="whiteSpace">
        <xsl:choose>
            <!-- using a normal space here to avoid conflicts with number formats which use a non-breaking space for the grouping separator; like hungarian. -->
            <!-- this will be replaced by a non-breaking space after formatting -->
            <xsl:when test="$currencyFormatForSymbol/hasWhitespaceSeparator = boolean(1)"><xsl:value-of select="' '"/></xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <!-- currency transaction value is stored in -->
    <xsl:variable name="fromCurrency" select="/transaction/data_xml/@currency"/><!-- transaction data is stored in trans currency format. Ex: "1234,56" for EUR -->
    <xsl:variable name="fromCurrencyFormat" select="$currencySymbolsAndLabels/currencies/currency[@name=$fromCurrency]"/>
    
    <!-- adjusted precision value -->
    <xsl:variable name="safePrecision">
        <xsl:choose>
            <xsl:when test="number($precision) &gt;= 0 and number($precision) &lt;= 8">
                <xsl:value-of select="$precision"/>
            </xsl:when>
            <xsl:otherwise>2</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- price value with adjusted precision -->
    <xsl:variable name="safePrice">
        <xsl:call-template name="BMI_calculateSafePrice">
            <xsl:with-param name="price" select="$price"/>
            <xsl:with-param name="currencyFormat" select="$fromCurrencyFormat"/>
            <xsl:with-param name="multiplier" select="$multiplier"/>
            <xsl:with-param name="showCents" select="$showCents"/>
            <xsl:with-param name="safePrecision" select="$safePrecision"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- final decimal format class name. if empty, use format from incoming currency -->
    <xsl:variable name="dfcName">
        <xsl:choose>
            <xsl:when test="$decimalFormatClass and string-length($decimalFormatClass) &gt; 0">
                <xsl:value-of select="$decimalFormatClass"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="boolean($currencyFormatForSymbol/decimal-format)">
                        <xsl:value-of select="$currencyFormatForSymbol/decimal-format/@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'american'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- 'decimal-format' xml node present in currency xml -->
    <xsl:variable name="outputFormatNode" select="$currencySymbolsAndLabels/currencies/decimal-format[@name=$dfcName]"/>
    
    <!-- final symbol location -->
    <xsl:variable name="symbolLocation">
        <xsl:choose>
            <xsl:when test="number($showCurrencySymbol) = number($showCurrencySymbol) and number($showCurrencySymbol) &gt;= 0">
                <xsl:value-of select="number($showCurrencySymbol)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$currencyFormatForSymbol/location">
                        <xsl:value-of select="number($currencyFormatForSymbol/location)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- get format pattern -->
    <xsl:variable name="format">
        <xsl:call-template name="BMI_formatCurrencyValue">
            <xsl:with-param name="currencyFormat"   select="$outputFormatNode"/>
            <xsl:with-param name="showCents"        select="$showCents"/>
            <xsl:with-param name="safePrecision"    select="$safePrecision"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="CURRENCY_LABEL_PLACEHOLDER" select="'CURRENCYLABELPLACEHOLDER'"/>
    
    <!-- Format with Symbol and WhiteSpace-->
    <xsl:variable name="finalFormat">
        <xsl:call-template name="appendCurrencyPlaceHolder">
            <xsl:with-param name="CURRENCY_LABEL_PLACEHOLDER"   select="$CURRENCY_LABEL_PLACEHOLDER"/>
            <xsl:with-param name="symbolLocation"               select="$symbolLocation"/>
            <xsl:with-param name="whiteSpace"                   select="$whiteSpace"/>
            <xsl:with-param name="value"                        select="$format"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- Formated Number without symbol -->
    <xsl:variable name="formattedNumber">
        <xsl:variable name="withPossibleWhitespace">
            <xsl:choose>
                <!-- indian value formated by java -->
                <xsl:when test="$dfcName = 'indian'">
                    <xsl:call-template name="appendCurrencyPlaceHolder">
                        <xsl:with-param name="CURRENCY_LABEL_PLACEHOLDER"   select="$CURRENCY_LABEL_PLACEHOLDER"/>
                        <xsl:with-param name="symbolLocation"               select="$symbolLocation"/>
                        <xsl:with-param name="whiteSpace"                   select="$whiteSpace"/>
                        <xsl:with-param name="value"                        select="number($safePrice)"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- other values formated by xsl -->
                <xsl:otherwise>
                    <xsl:value-of select="format-number($safePrice, $finalFormat, $dfcName)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- replacing the symbol whitespace separator with a non-breaking space to ensure the entire currency string stays on the same line -->
        <xsl:value-of select="translate($withPossibleWhitespace, ' ', '&#160;')"/>
    </xsl:variable>

    <!-- Return number with currency symbol -->
    <xsl:choose>
        <xsl:when test="$symbolLocation &gt;= 1">
            <!-- get the currency label -->
            <xsl:variable name="currencySymbol">
                <xsl:call-template name="BMI_addCurrencyLabelOnly">
                    <xsl:with-param name="currencyFormat" select="$currencyFormatForSymbol"/>
                    <xsl:with-param name="currency" select="$currency"/>
                </xsl:call-template>
            </xsl:variable>

            <!-- replace the currency label placeholder with the actual currency label -->
            <xsl:variable name="before" select="substring-before($formattedNumber, $CURRENCY_LABEL_PLACEHOLDER)"/>
            <xsl:variable name="after" select="substring-after($formattedNumber, $CURRENCY_LABEL_PLACEHOLDER)"/>

            <!-- final currency string -->
            
            <!-- combine currency symbol and formatted number -->
            <xsl:choose>
                <xsl:when test="count($currencyFormatForSymbol/font)&gt;0">
                    <xsl:value-of select="$before"/>
                    <span style="font-family: {$currencyFormatForSymbol/font}">
                        <xsl:value-of select="$currencySymbol"/>
                    </span>
                    <xsl:value-of select="$after"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($before, $currencySymbol, $after)"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:when>

        <xsl:otherwise>
            <!-- we aren't showing the currency symbol, so no need to do the replace -->
            <xsl:value-of select="$formattedNumber"/>
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>

<!-- DEPRECATED -->
<xsl:template name="BMI_addCurrencyLabelOnly">
    <xsl:param name="currencyFormat"/>
    <xsl:param name="currency"/>
    <xsl:choose>
        <xsl:when test="$currencyFormat">
            <xsl:choose>
                <xsl:when test="count($currencyFormat/font)&gt;0">
                    <span style="font-family: {$currencyFormat/font}">
                        <xsl:value-of select="$currencyFormat/label"/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$currencyFormat/label"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$currency"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- adds currency placeholder string with whitespace to left, right, or none of the 'value' string -->
<!-- use a placeholder for the currency symbol/label, as it may contain special characters used by format-number. -->
<!-- the label is required in the format string in order for negative prices to be formatted correctly -->
<xsl:template name="appendCurrencyPlaceHolder">
    <xsl:param name="symbolLocation" select="1" />
    <xsl:param name="CURRENCY_LABEL_PLACEHOLDER" select="CLP" />
    <xsl:param name="whiteSpace"/>
    <xsl:param name="value"/>

    <xsl:choose>
        <!-- add symbol placeholder after -->
        <xsl:when test="$symbolLocation &gt; 1">
            <xsl:value-of select="concat($value, $whiteSpace, $CURRENCY_LABEL_PLACEHOLDER)"/>
        </xsl:when>
        
        <!-- add symbol placeholder before -->
        <xsl:when test="$symbolLocation = 1">
            <xsl:value-of select="concat($CURRENCY_LABEL_PLACEHOLDER, $whiteSpace, $value)"/>
        </xsl:when>
        
        <!-- no symbol needed -->
        <xsl:otherwise>
            <xsl:value-of select="$value"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    
<xsl:template name="BMI_getImageSrc">
    <xsl:param name="attachmentID" select="-1" />
    <xsl:param name="defaultUrl" select="''"/>
    <!-- returns FILEATTACHMENT#{attachmentID} if the file attachment is an image, 
         otherwise it returns defaultUrl. if defaultUrl is a FILE_MANAGER#{file path} string,
         it encodes the file path with valid url characters before returning it -->
    <xsl:value-of select="'stubbed-image-url'"/>
</xsl:template>

<xsl:template name="BM_getEmbedDocSrc">
    <xsl:param name="attachmentID" select="-1"/>
    <!-- returns FILEATTACHMENT#{attachmentID} if the file attachment is a PDF,
        otherwise returns an empty string -->
    <xsl:value-of select="'stubbed-doc-url'"/>
</xsl:template>


<!-- returns 1 or 0 depending on specifc values passed in.
Used for Custom XSL for Conditions and Loop Filters -->
  <xsl:template name="getCustomXslTruth">
    <xsl:param name="var"/>
    <xsl:choose>
        <!-- is a number -->
        <xsl:when test="number($var)=number($var)">
            <xsl:value-of select="number(boolean(number($var)))"/>
        </xsl:when>
        <!-- empty string -->
        <xsl:when test="string-length($var)=0">
            <xsl:value-of select="number(0)"/>
        </xsl:when>
        <!-- string says 'false' -->
        <xsl:when test="$var='false' or $var='False' or $var='FALSE'">
            <xsl:value-of select="number(0)"/>
        </xsl:when>
        <!-- string says 'true' -->
        <xsl:when test="$var='true' or $var='True' or $var='TRUE'">
            <xsl:value-of select="number(1)"/>
        </xsl:when>
        <!-- string says something else -->
        <xsl:when test="string-length($var)&gt;0">
            <xsl:value-of select="number(1)"/>
        </xsl:when>
        <!-- other -->
        <xsl:otherwise>
            <xsl:value-of select="number(0)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>



<!-- split a text delimiter 'list' into "node" elements, can be used to create a node set array.
    set $wrdBrk to be the list delimiter -->
<xsl:template name="splitTextIntoElementList">

    <!-- $wrdBrk break on this character for a attribute:value combo -->
    <xsl:param name="wrdBrk" select="','" />

    <!-- start with nothing in $word and all the words in $remaining -->
    <xsl:param name="word" select="''" />
    <xsl:param name="remaining" select="." />

    <!-- === print value in word ==== -->
    <xsl:if test="$word">
         <Node><xsl:value-of select="$word"/></Node>
    </xsl:if>

    <xsl:choose>
        <!-- if $remaining contains another word -->
        <xsl:when test="substring-before($remaining, $wrdBrk)">
            <xsl:call-template name="splitTextIntoElementList">
                <!--  move the first word of $remaining to $word,
                        remove the word from $remaining, and recurse. &lt;Node&gt;
                -->
                <xsl:with-param name="word" select="substring-before($remaining, $wrdBrk)" />
                <xsl:with-param name="remaining" select="substring-after($remaining, $wrdBrk)" />
                <xsl:with-param name="wrdBrk" select=" $wrdBrk" />
            </xsl:call-template>
        </xsl:when>
        <!-- if $remaining contains a single value, set to $word and recurse one more time -->
        <xsl:when test="$remaining">
            <xsl:call-template name="splitTextIntoElementList">
                <xsl:with-param name="word" select="$remaining" />
                <xsl:with-param name="remaining" select="null" />
                <xsl:with-param name="wrdBrk" select=" $wrdBrk" />
            </xsl:call-template>
        </xsl:when>
    </xsl:choose>

     <!-- === if $remaining is null, split is done ==== -->
</xsl:template>


<!-- formats a float/decimal value into the specified number format using the given precision. -->
<!-- currently supports 'EUR' for the '#.##0,00' format, otherwise defaults to '#,##0.00' -->
<xsl:template name="BMI_formatFloat">
    <xsl:param name="val"/>
    <xsl:param name="numFormat" select="'USD'"/>
    <xsl:param name="precision" select="2"/>
    <xsl:variable name="pattern">
        <xsl:variable name="groupingSeparator">
            <xsl:choose>
                <xsl:when test="$numFormat = 'EUR'">
                    <xsl:value-of select="'.'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="','"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="decimalSeparator">
            <xsl:choose>
                <xsl:when test="$numFormat = 'EUR'">
                    <xsl:value-of select="','"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'.'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="wholePart" select="concat('#', $groupingSeparator, '##0')"/>
        <xsl:variable name="decimalPart">
            <xsl:choose>
                <xsl:when test="$precision &gt; 0">
                    <xsl:value-of select="concat($decimalSeparator, substring('0000000000000000', 1, $precision) )"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($wholePart, $decimalPart)"/>
    </xsl:variable>
    <xsl:variable name="format">
        <xsl:choose>
            <xsl:when test="$numFormat = 'EUR'">
                <xsl:value-of select="'euro'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'american'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="format-number($val, $pattern, $format)"/>
</xsl:template><xsl:variable name="currencySymbolsAndLabels" select="document('$XSL_URL$/xsl/documenteditor/currencies.xml')"/>

<xsl:decimal-format name="american"     grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="indian"       grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="zimbabwe"     grouping-separator="&#160;" decimal-separator="."/>
<xsl:decimal-format name="swiss"        grouping-separator="'" decimal-separator="."/>
<xsl:decimal-format name="euro"         grouping-separator="." decimal-separator=","/>
<xsl:decimal-format name="hungarian"    grouping-separator="&#160;" decimal-separator=","/>

    <xsl:template name="BMI_formatLongDate">
         <xsl:param name="date"/>
         <xsl:param name="separator"/>
         <!-- Month -->
         <xsl:variable name="month" select="number(substring($date, 6, 2))"/>
         <xsl:choose>
             <xsl:when test="$date!=''">
                 <xsl:choose>
                     <xsl:when test="$month=1">January</xsl:when>
                     <xsl:when test="$month=2">February</xsl:when>
                     <xsl:when test="$month=3">March</xsl:when>
                     <xsl:when test="$month=4">April</xsl:when>
                     <xsl:when test="$month=5">May</xsl:when>
                     <xsl:when test="$month=6">June</xsl:when>
                     <xsl:when test="$month=7">July</xsl:when>
                     <xsl:when test="$month=8">August</xsl:when>
                     <xsl:when test="$month=9">September</xsl:when>
                     <xsl:when test="$month=10">October</xsl:when>
                     <xsl:when test="$month=11">November</xsl:when>
                     <xsl:when test="$month=12">December</xsl:when>
                     <xsl:otherwise>INVALID MONTH</xsl:otherwise>
                 </xsl:choose>
                 <xsl:text> </xsl:text>
                 <!-- Day -->
                 <xsl:value-of select="number(substring($date, 9, 2))"/>
                 <xsl:text>, </xsl:text>
                 <!-- Year -->
                 <xsl:value-of select="substring($date, 1, 4)"/>
             </xsl:when>
         </xsl:choose>
    </xsl:template>
    <!-- Format a date of the form "2004-09-28 " into "09/28/2004" -->
    <xsl:template name="BMI_formatShortDate">
         <xsl:param name="date"/>
         <xsl:param name="separator"/>
         <xsl:variable name="month" select="number(substring($date, 6, 2))"/>
         <xsl:variable name="day" select="number(substring($date, 9, 2))"/>
         <xsl:variable name="year" select="substring($date, 1, 4)"/>
         <xsl:choose>
            <xsl:when test="$date!=''">
                <xsl:choose>
                    <xsl:when test="$separator='.'">
                        <xsl:value-of select="concat($day,$separator,$month,$separator,$year)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($month,$separator,$day,$separator,$year)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
         </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_universalFormatPrice">
        <xsl:param name="price"/>
        <xsl:param name="currency"/>
        <xsl:param name="multiplier" select="1"/>
        <xsl:param name="showCents" select="true()"/>
        <xsl:param name="showCurrencySymbol" select="true()"/>
        <xsl:param name="precision" select="2"/>
        <xsl:variable name="fromCurrency" select="/transaction/data_xml/@currency"/>
        <xsl:variable name="fromCurrencyFormat" select="$currencySymbolsAndLabels/currencies/currency[@name=$fromCurrency]"/>
        <xsl:variable name="currencyFormat" select="$currencySymbolsAndLabels/currencies/currency[@name=$currency]"/>
        <xsl:variable name="decimalFormatClass">
            <xsl:choose>
                <xsl:when test="$currencyFormat">
                    <xsl:choose>
                        <xsl:when test="count($currencyFormat/decimal-format)&gt;0">
                            <xsl:value-of select="$currencyFormat/decimal-format/@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'american'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="'american'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="safePrecision">
            <xsl:choose>
                <xsl:when test="number($precision) &gt;= 0 and number($precision) &lt;= 8">
                    <xsl:value-of select="$precision"/>
                </xsl:when>
                <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="safePrice">
            <xsl:call-template name="BMI_calculateSafePrice">
                <xsl:with-param name="price" select="$price"/>
                <xsl:with-param name="currencyFormat" select="$fromCurrencyFormat"/>
                <xsl:with-param name="multiplier" select="$multiplier"/>
                <xsl:with-param name="showCents" select="$showCents"/>
                <xsl:with-param name="safePrecision" select="$safePrecision"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="format">
            <xsl:call-template name="BMI_formatCurrencyValue">
                <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                <xsl:with-param name="showCents" select="$showCents"/>
                <xsl:with-param name="safePrecision" select="$safePrecision"/>
            </xsl:call-template>
        </xsl:variable>             
        <xsl:variable name="currencySymbol">
            <xsl:if test="$showCurrencySymbol">
                <xsl:call-template name="BMI_addCurrencyLabel">
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currency" select="$currency"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="format-number($safePrice,concat($currencySymbol, $format),$decimalFormatClass)"/>           
    </xsl:template>
    
    <xsl:template name="BMI_calculateSafePrice">
        <xsl:param name="price"/>
        <xsl:param name="currencyFormat"/>
        <xsl:param name="multiplier"/>
        <xsl:param name="showCents"/>
        <xsl:param name="safePrecision"/>
        <xsl:variable name="decimalSeparator">
            <xsl:call-template name="BMI_determineDecimalSeparator">
                <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="formattedPrice">
            <xsl:choose>
                <xsl:when test="$decimalSeparator!='.'">
                    <xsl:call-template name="BMI_replaceSubstring">
                        <xsl:with-param name="base_string" select="$price"/>
                        <xsl:with-param name="string_to_replace" select="$decimalSeparator"/>
                        <xsl:with-param name="string_to_replace_with" select="'.'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$price"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="priceWithoutMult">
            <xsl:choose>
                <xsl:when test="string(number($formattedPrice))!='NaN'">
                    <xsl:value-of select="$formattedPrice"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="multipliedPrice">
            <xsl:value-of select="$priceWithoutMult*$multiplier"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($showCents)">
                <xsl:value-of select="round($multipliedPrice)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ignoreHalfEvenRounding">
                    <xsl:with-param name="fullNumber" select="$multipliedPrice"/>
                    <xsl:with-param name="safePrecision" select="$safePrecision"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_determineDecimalSeparator">
        <xsl:param name="currencyFormat"/>
        <xsl:choose>
            <xsl:when test="$currencyFormat">
                <xsl:choose>
                    <xsl:when test="count($currencyFormat/decimal-format)&gt;0">
                        <xsl:value-of select="$currencyFormat/decimal-format/@decimal-separator"/>
                    </xsl:when>
                    <xsl:when test="$currencyFormat/@decimal-separator">
                        <xsl:value-of select="$currencyFormat/@decimal-separator"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'.'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_determineGroupingSeparator">
        <xsl:param name="currencyFormat"/>
        <xsl:choose>
            <xsl:when test="$currencyFormat">
                <xsl:choose>
                    <xsl:when test="count($currencyFormat/decimal-format)&gt;0">
                        <xsl:value-of select="$currencyFormat/decimal-format/@grouping-separator"/>
                    </xsl:when>
                    <xsl:when test="$currencyFormat/@grouping-separator">
                        <xsl:value-of select="$currencyFormat/@grouping-separator"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="','"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="','"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_formatCurrencyValue">
        <xsl:param name="currencyFormat"/>
        <xsl:param name="showCents"/>
        <xsl:param name="safePrecision"/>
        <xsl:variable name="decimalSeparator">
            <xsl:call-template name="BMI_determineDecimalSeparator">
                <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="groupingSeparator">
            <xsl:call-template name="BMI_determineGroupingSeparator">
                <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>                    
            <xsl:when test="$showCents and number($safePrecision) &gt; 0">
                <xsl:value-of disable-output-escaping="yes" select="concat('#', $groupingSeparator, '##0', $decimalSeparator, substring('00000000', 1, $safePrecision))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of disable-output-escaping="yes" select="concat('#', $groupingSeparator, '##0')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_addCurrencyLabel">
        <xsl:param name="currencyFormat"/>
        <xsl:param name="currency"/>
        <xsl:choose>
            <xsl:when test="$currencyFormat">
                <xsl:choose>
                    <xsl:when test="count($currencyFormat/font)&gt;0">
                        <span style="font-family: {$currencyFormat/font}">
                            <xsl:value-of select="$currencyFormat/label"/><xsl:if test="$currencyFormat/hasWhitespaceSeparator='true'">&#160;</xsl:if>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$currencyFormat/label"/><xsl:if test="$currencyFormat/hasWhitespaceSeparator='true'">&#160;</xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$currency"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_universalNumber">
        <xsl:param name="val"/>
        <xsl:param name="numFormat"/>
        <xsl:param name="formatForDisplay" select="''"/>
        <xsl:variable name="realNumber">
            <xsl:choose>
                <xsl:when test="$numFormat = 'EUR'">
                    <xsl:variable name="reverseSeperators" select="translate($val,',.','.,')"/>
                    <xsl:call-template name="BMI_replaceSubstring">
                        <xsl:with-param name="base_string" select="$reverseSeperators"/>
                        <xsl:with-param name="string_to_replace">,</xsl:with-param>
                        <xsl:with-param name="string_to_replace_with" select="''"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="number($val) != 'NaN' ">
                    <xsl:value-of select="$val"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$formatForDisplay='USD'">
                <xsl:value-of select="format-number($realNumber,'#,##0.00','american')"/>
            </xsl:when>
            <xsl:when test="$formatForDisplay='EUR'">
                <xsl:value-of select="format-number($realNumber,'#.###,00','euro')"/>
            </xsl:when>
            <xsl:when test="$formatForDisplay='GBP'">
                <xsl:value-of select="format-number($realNumber,'#,##0.00','american')"/>
            </xsl:when>
            <xsl:when test="$formatForDisplay='CAD'">
                <xsl:value-of select="format-number($realNumber,'#,##0.00','american')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$realNumber"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BMI_replaceSubstring">
        <xsl:param name="base_string"/>
        <xsl:param name="string_to_replace"/>
        <xsl:param name="string_to_replace_with"/>
        <xsl:variable name="resultString" select="concat(substring-before($base_string,$string_to_replace),$string_to_replace_with,substring-after($base_string,$string_to_replace))"/>
        <xsl:choose>
            <xsl:when test="string-length($resultString) = string-length($string_to_replace_with)">
                <xsl:value-of select="$base_string"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="BMI_replaceSubstring">
                    <xsl:with-param name="base_string" select="$resultString"/>
                    <xsl:with-param name="string_to_replace" select="$string_to_replace"/>
                    <xsl:with-param name="string_to_replace_with" select="$string_to_replace_with"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ignoreHalfEvenRounding">
        <xsl:param name="fullNumber"/>
        <xsl:param name="decimalSeparator" select="'.'"/>
        <xsl:param name="safePrecision" select="2"/>
        
        <xsl:variable name="decimalPrice" select="substring-after($fullNumber, $decimalSeparator)"/>
        
        <xsl:choose>
            <xsl:when test="number($safePrecision) &gt; 0 and number(substring($decimalPrice, (number($safePrecision)+1), 1)) &gt; 4">
                <xsl:variable name="precisionPlusOne" select="number($safePrecision) + 1"/>
                <xsl:variable name="decimalPlaceOffset" select="number(substring('10000000000000', 1, $precisionPlusOne))"/>
                <xsl:choose>
                    <xsl:when test="number($fullNumber) &gt; 0">
                        <xsl:value-of select="ceiling(number($fullNumber) * number($decimalPlaceOffset)) div number($decimalPlaceOffset)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="floor(number($fullNumber) * number($decimalPlaceOffset)) div number($decimalPlaceOffset)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$fullNumber"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest1/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest2/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest3/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest4/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest5/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest6/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest7/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest8/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest9/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest10/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest11/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest12/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest13/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest14/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappincprod/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest15/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappinctest16/image/Output/jsonToXML.xsl"/> -->
<!-- <xsl:include xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" href="/bmfsweb/netappcpq/image/Output/jsonToXML.xsl"/> -->

<xsl:variable name="AccountXml">
	<!-- Simplified: convertJsonToXml function not available, using empty XML -->
	<root/>
</xsl:variable>

<xsl:variable xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="quoteCurrency" select="string($_dsMain1/currency_t)"/>
<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="netapp_formatPrice">
    <xsl:param name="price"/>
    <xsl:param name="basePrecision" select="2"/>
    <!-- meant to fix a few issues with the oracle standard currency library
        1. JPY Should always be 0 decimal places
        2. Indian rupees are formatted by java but there's an outstanding bug with helvetica where it renders over the number
    -->
    <xsl:variable name="precision">
        <xsl:choose>
        <xsl:when test="$quoteCurrency='JPY'">0</xsl:when>
        <xsl:otherwise><xsl:value-of select="$basePrecision"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
        <xsl:variable name="formattedPriceVal">
    <xsl:call-template name="BMI_universalFormatPriceCustom">
        <xsl:with-param name="price" select="$price"/>
        <xsl:with-param name="currency" select="$quoteCurrency"/>
        <xsl:with-param name="showCurrencySymbol" select="-1"/>
        <xsl:with-param name="precision" select="$precision"/>
    </xsl:call-template>
    </xsl:variable>
        <xsl:choose>
        <xsl:when test="$quoteCurrency='INR'">
            <!--bug with helvetica/some browsers where it renders over number-->
            <xsl:value-of select="concat(substring-before($formattedPriceVal,'₹'),substring-after($formattedPriceVal,'₹'))"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$formattedPriceVal"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="addendumTotalPrint">
  <xsl:param name="label" select="''"/>
  <xsl:param name="sum" select="0"/>
  <xsl:param name="align" select="'right'"/>
  <div style="line-height: 12pt; text-align: {$align}">
    <span style="color: #000000; font-size: 12pt; font-family: Helvetica">
      <span style="font-size: 8pt; font-family: helvetica">
        <span style="font-weight: bold"><xsl:value-of select="$label"/></span>
        <xsl:call-template name="netapp_formatPrice">
        <xsl:with-param name="price" select="number( translate($sum, ',', '.') )"/>
      </xsl:call-template>
      </span>
    </span>
  </div>
</xsl:template>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="currencyFormattedPrice">
  <xsl:param name="price"/>
  <xsl:param name="align" select="'right'"/>
  <xsl:param name="fontSize" select="'12pt'"/>
  <xsl:param name="fontWeight" select="'bold'"/>
  <div style="line-height: 12pt; text-align: {$align}">
    <span style="color: #000000; font-size: 12pt; font-family: Helvetica">
      <span style="font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: helvetica">
        <xsl:call-template name="netapp_formatPrice">
        <xsl:with-param name="price" select="number($price)"/>
      </xsl:call-template>
      </span>
    </span>
  </div>
</xsl:template>


<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="formatFloatPercent">
    <xsl:param name="val"/>
    <xsl:param name="zeroDisplay" select="false()"/>
    <xsl:param name="formatDisplay" select="true()"/>
    <xsl:variable name="formatForDisplay">
        <xsl:choose>
            <xsl:when test="not($formatDisplay)">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$quoteCurrency"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="($val='') and not($zeroDisplay)">
            <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="($val=0)">
            <xsl:value-of select="'0.00'"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$formatForDisplay='USD'">
                    <xsl:value-of select="concat(format-number($val,'#,##0.##','american'), '%')"/>
                </xsl:when>
                <!--xsl:when test="$formatForDisplay='EUR'">
                    <xsl:value-of select="concat(format-number($val,'#.###,##','euro'), '%')" />
                </xsl:when-->
                <xsl:when test="$formatForDisplay='GBP'">
                    <xsl:value-of select="concat(format-number($val,'#,##0.##','american'), '%')"/>
                </xsl:when>
                <xsl:when test="$formatForDisplay='CAD'">
                    <xsl:value-of select="concat(format-number($val,'#,##0.##','american'), '%')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(format-number($val,'0.##'), '%')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- This will print all elements-->
<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="summaryPrintListALL">
	<xsl:param name="label" select="''"/>
	<xsl:param name="list"/>
	<div>
		<div style="line-height: 12pt; text-align: left">
			<span style="color: #000000; font-size: 12pt; font-family: Helvetica">
				<span style="font-size: 8pt; font-family: helvetica">
					<span style="font-weight: bold">
						<xsl:value-of select="$label"/>
					</span>
					<xsl:if test="count($list)&gt;0">
						<xsl:for-each select="$list">
							<xsl:choose>
								<xsl:when test="position() != last()">
									<xsl:value-of select="concat(., ', ')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</span>
			</span>
		</div>
	</div>
</xsl:template>

<!-- This will only print elements that are unique -->
<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="summaryPrintList">
	<xsl:param name="label" select="''"/>
	<xsl:param name="list"/>
	<xsl:variable name="uniqueList">
	    <xsl:for-each select="$list">
	    <xsl:copy-of select="."/>
	    </xsl:for-each>
	</xsl:variable>
	<div>
		<div style="line-height: 12pt; text-align: left">
			<span style="color: #000000; font-size: 12pt; font-family: Helvetica">
				<span style="font-size: 8pt; font-family: helvetica">
					<span style="font-weight: bold">
						<xsl:value-of select="$label"/>
					</span>
					<xsl:if test="count($list)&gt;0">
						<xsl:for-each select="exsl:node-set($uniqueList)/*[not(. = preceding-sibling::*)]">
							<xsl:choose>
								<xsl:when test="position() != last()">
									<xsl:value-of select="concat(., ', ')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</span>
			</span>
		</div>
	</div>
</xsl:template>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="printSumNumeric">
  <xsl:param name="label" select="''"/>
  <xsl:param name="prefix" select="''"/>
  <xsl:param name="suffix" select="''"/>
  <xsl:param name="sum" select="0"/>
  <xsl:param name="align" select="'left'"/>
  <div style="line-height: 12pt; text-align: {align}">
    <span style="color: #000000; font-size: 12pt; font-family: Helvetica">
      <span style="font-size: 8pt; font-family: helvetica">
        <span style="font-weight: bold"><xsl:value-of select="$label"/></span>
        <span><xsl:value-of select="concat($prefix, string($sum),$suffix)"/></span>
      </span>
    </span>
  </div>
</xsl:template>



<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="sumDriveCapacity">
    <xsl:param name="total" select="0"/>
    <xsl:param name="rows"/>
    <xsl:param name="counter" select="1"/>
    <xsl:param name="rowCount" select="count($rows)"/>
    <xsl:choose>
        <xsl:when test="$counter &lt;=$rowCount">
            
           <!--xsl:variable name="rowVal" select="((number($rows[position() = $counter]/item_l/_part_custom_field288) * number($rows[position() = $counter]/item_l/_part_custom_field289)) div 1000) * number($rows[position() = $counter]/price/_price_quantity)"/-->
           <xsl:variable name="rowVal" select="((number($rows[position() = $counter]/item_l/_part_custom_field288) * number($rows[position() = $counter]/item_l/_part_custom_field289)) div 1000) * number($rows[position() = $counter]/extendedQuantity_l_c)"/>
         <!--((DriveCapacity * NumberofDrives)/1000)* qty-->
            <xsl:call-template name="sumDriveCapacity">
                <!--xsl:with-param name="total" select="$total+$rowVal" -->
                <xsl:with-param name="total" select="format-number($total+$rowVal,'0.##')"/>
                <xsl:with-param name="counter" select="$counter+1"/>
                <xsl:with-param name="rows" select="$rows"/>
                <xsl:with-param name="rowCount" select="$rowCount"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$total"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="discountFormattedPrint">
  <xsl:param name="label" select="''"/>
  <xsl:param name="discPct" select="0"/>
  <xsl:param name="fontSize" select="'12pt'"/>
  <xsl:param name="fontWeight" select="'bold'"/>
  <xsl:param name="align" select="'center'"/>
  <div style="line-height: 12pt; text-align: {$align}">
    <span style="color: #000000; font-size: 12pt; font-family: Helvetica">
      <span style="font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: helvetica">
        <span style="font-weight: bold"><xsl:value-of select="$label"/></span>
		<xsl:call-template name="BMI_formatFloat">
			<xsl:with-param name="val" select="$discPct"/>
			<xsl:with-param name="numFormat" select="$EMAIL_RECIPIENT_NUMFORMAT_PREF"/>
			<xsl:with-param name="precision" select="2"/>
		</xsl:call-template>
      </span>
    </span>
  </div>
</xsl:template>

<xsl:template xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="NewcurrencyFormattedPrice">
  <xsl:param name="price"/>
  <xsl:param name="align" select="'right'"/>
  <xsl:param name="fontSize" select="'12pt'"/>
  <xsl:param name="fontWeight" select="'bold'"/>
  <xsl:param name="precision"/>
  <div style="line-height: 12pt; text-align: {$align}">
    <span style="color: #000000; font-size: 12pt; font-family: Helvetica">
      <span style="font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: helvetica">
        <xsl:call-template name="netapp_formatPrice">
        <xsl:with-param name="price" select="number($price)"/>
        <!--xsl:with-param name="precision" select="number($precision)"/-->
        <xsl:with-param name="basePrecision" select="'4'"/>
      </xsl:call-template>
      </span>
    </span>
  </div>
</xsl:template>

<xsl:variable xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" xmlns:exsl="http://exslt.org/common" name="printDateFormat" select="'dd-MMM-yyyy'"/>

<xsl:variable name="_dsMain1" select="/transaction/data_xml/document[@document_var_name='transaction']"/><xsl:variable name="_dsUser" select="/transaction/bm_user"/><xsl:strip-space elements="*"/><xsl:template match="/">
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
<body>    <!-- ===== QUOTE HEADER ===== -->
    <div class="quote-header">
        <h1>Solution Quotation</h1>
        <p><strong>Quote Number:</strong> <xsl:value-of select="$_dsMain1/quoteNumber_t_c"/></p>
        <p><strong>Date:</strong> <xsl:value-of select="$_dsMain1/quoteExportDate_t_c"/></p>
        <p><strong>Quote Name:</strong> <xsl:value-of select="$_dsMain1/quoteNameTextArea_t_c"/></p>
        <p><strong>Contact:</strong> <xsl:value-of select="$_dsMain1/salesRep_t_c"/></p>
        <p><strong>Email:</strong> <xsl:value-of select="$_dsMain1/opportunityOwnerEmail_t_c"/></p>
    </div>

    <!-- ===== QUOTE CONTENT ===== -->
    <div class="quote-section">
        <h2>Quote Details</h2>
        <p><strong>Solution Quotation</strong> <xsl:value-of select="$_dsMain1/quoteNumber_t_c"/></p>
        
        <!-- Quote Information Table -->
        <table class="quote-table">
            <tbody>
            <tr>
                <td><strong>Quote Name:</strong></td>
                <td colspan="3"><xsl:value-of select="$_dsMain1/quoteNameTextArea_t_c"/></td>
            </tr>
            <tr>
                <td><strong>Quote Date:</strong></td>
                <td><xsl:value-of select="'2024-01-01'"/></td>
                <td><strong>Quote Valid Until:</strong></td>
                <td><xsl:value-of select="'2024-01-01'"/></td>
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
                <td colspan="3"><xsl:value-of select="'Customer Name'"/></td>
            </tr></tbody></table></div>

    <!-- Quote Footer -->
    <div class="quote-footer">
        <p><strong>Terms and Conditions:</strong> All amounts are in USD</p>
        <p>Generated on: 2024-01-01</p>
    </div>

</div>
</body>
</html>
</xsl:template></xsl:stylesheet>
