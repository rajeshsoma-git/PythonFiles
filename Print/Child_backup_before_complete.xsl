<!--  
  Oracle CPQ Document Designer XSL Template
  Author: Rajesh Soma
  Created: September 2025
  Modified: October 2, 2025 - Added 15 features, fixed Quote Date mapping
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:document="http://www.bigmachines.com/2003/Document" xmlns:exsl="http://exslt.org/common" xmlns:DateUtil="com.bm.xchange.util.DateUtil" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:HeadingUtil="com.bm.xchange.services.templateengine.headingstyle.TeHeadingStyleUtil" xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" xmlns:FunctionUtil="com.bm.xchange.services.templateengine.utils.TeFunctionUtil" version="1.0" extension-element-prefixes="exsl">
<!--  Parameters from Master.xsl  -->
<xsl:param name="EMAIL_RECIPIENT_NUMFORMAT_PREF" select="''"/>
<xsl:param name="BM_IMAGESERVER_TOKEN" select="''"/>
<xsl:param name="TIME_ZONE" select="''"/>
<xsl:param name="TEMPLATE_ID" select="''"/>
<xsl:param name="TRANSACTION_ID" select="''"/>
<xsl:param name="PRINT_TIME" select="''"/>
<xsl:param name="PRINT_CODE" select="''"/>
<xsl:output method="html" encoding="UTF-8" indent="yes"/>
<!--  Global variables from Master.xsl  -->
<xsl:variable name="FILEATTACHMENT_DELIM" select="'|^|'"/>
<!--  Global variables matching Master.xsl exactly  -->
<!--  Decimal format declarations from Master.xsl  -->
<xsl:decimal-format name="american" grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="indian" grouping-separator="," decimal-separator="."/>
<xsl:decimal-format name="zimbabwe" grouping-separator="&#160;" decimal-separator="."/>
<xsl:decimal-format name="swiss" grouping-separator="'" decimal-separator="."/>
<xsl:decimal-format name="euro" grouping-separator="." decimal-separator=","/>
<xsl:decimal-format name="hungarian" grouping-separator="&#160;" decimal-separator=","/>
<!--  Critical variables from Master.xsl  -->
<!-- <xsl:variable name="currencySymbolsAndLabels" select="document('$XSL_URL$/xsl/documenteditor/currencies.xml')"/> -->
<xsl:variable name="printDateFormat" select="'dd-MMM-yyyy'"/>
<xsl:variable name="quoteCurrency" select="string($_dsMain1/currency_t)"/>

<!-- External includes matching Master.xsl -->
<!-- Commented out - external files not available
<xsl:include href="/bmfsweb/netappinctest/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest1/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest2/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest3/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest4/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest5/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest6/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest7/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest8/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest9/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest10/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest11/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest12/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest13/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest14/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest15/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappinctest16/image/Output/jsonToXML.xsl"/>
<xsl:include href="/bmfsweb/netappincprod/image/Output/jsonToXML.xsl"/>
-->

<!--  Global variables matching Master.xsl exactly  -->
<xsl:variable name="_dsMain1" select="/transaction/data_xml/document[@document_var_name='transaction']"/>
<xsl:variable name="_dsUser" select="/transaction/bm_user"/>
<xsl:variable name="pricingTier" select="$_dsMain1/pricingTierForPrint_t_c"/>

<!-- Additional data processing variables for full functionality matching Master.xsl -->
<xsl:variable name="EffectiveCapacityLines" select="/transaction/data_xml/document[(normalize-space(./@data_type)='2') and ./model_l/_model_name = 'Cluster Manager' and ./fusionEstiUsableCapacity_l_c!='']"/>
<xsl:variable name="AddpartLines" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and _parent_doc_number='']"/>
<xsl:variable name="AddpartHardwareLines" select="$AddpartLines[printGrouping_l_c = 'HARDWARE']"/>
<xsl:variable name="AddpartSoftwareLines" select="$AddpartLines[printGrouping_l_c = 'SOFTWARE']"/>
<xsl:variable name="AddpartServicesLines" select="$AddpartLines[printGrouping_l_c = 'SERVICES']"/>
<xsl:variable name="AddpartStorageLines" select="$AddpartLines[printGrouping_l_c = 'STORAGE']"/>
<xsl:variable name="StoragecapacityLines" select="$AddpartLines[printGrouping_l_c = 'STORAGECAPACITY']"/>
<xsl:variable name="ObjectStorageLines" select="$AddpartLines[printGrouping_l_c = 'OBJECTSTORAGE']"/>
<xsl:variable name="SimplifiedFlag" select="//simplifiedPrinting_l_c"/>
<xsl:variable name="serviceLines" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and (lineType_l = 'SERVICE' or printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Additional Service' or starts-with(item_l/_part_number, 'CS-'))]"/>
<xsl:variable name="AccountXml">
    <!-- convertJsonToXml template not available - using empty value -->
    <account></account>
</xsl:variable>

<!-- Serial Number Processing Variables -->
<xsl:variable name="serialNumberList">
	<xsl:variable name="tmpSerialNumberList">
		<xsl:for-each select="./_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
			<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
			<xsl:if test="./attribute[@var_name='serialNumber_serialNumber_Array_l_c']!=''">
				<xsl:choose>
					<xsl:when test="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']!='' or ./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']!=null">
						<xsl:value-of select="concat(./attribute[@var_name='serialNumber_serialNumber_Array_l_c'],', ',./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'], ', ')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(./attribute[@var_name='serialNumber_serialNumber_Array_l_c'],', ')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="substring($tmpSerialNumberList, 1,string-length($tmpSerialNumberList)-2)"/>
</xsl:variable>

<!-- Date Formatting Template - HTML equivalent to PrintUtil:convertDBToPattern -->
<xsl:template name="formatDateForHTML">
	<xsl:param name="dateValue"/>
	<xsl:param name="format" select="$printDateFormat"/>
	<xsl:choose>
		<xsl:when test="$dateValue and $dateValue != ''">
			<xsl:choose>
				<xsl:when test="$format = 'dd-MMM-yyyy'">
					<xsl:call-template name="convertToddMMMyyy">
						<xsl:with-param name="date" select="$dateValue"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$dateValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Date Conversion Template - Convert date to dd-MMM-yyyy format -->
<xsl:template name="convertToddMMMyyy">
	<xsl:param name="date"/>
	<xsl:if test="$date != ''">
		<!-- Extract year, month, day from date (assumes YYYY-MM-DD format) -->
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="number(substring($date, 6, 2))"/>
		<xsl:variable name="day" select="number(substring($date, 9, 2))"/>
		
		<!-- Format complete date as single string -->
		<xsl:variable name="formattedDate">
			<!-- Day with leading zero if needed -->
			<xsl:if test="$day &lt; 10">0</xsl:if>
			<xsl:value-of select="$day"/>
			<!-- Month abbreviation -->
			<xsl:choose>
				<xsl:when test="$month = 1">-Jan-</xsl:when>
				<xsl:when test="$month = 2">-Feb-</xsl:when>
				<xsl:when test="$month = 3">-Mar-</xsl:when>
				<xsl:when test="$month = 4">-Apr-</xsl:when>
				<xsl:when test="$month = 5">-May-</xsl:when>
				<xsl:when test="$month = 6">-Jun-</xsl:when>
				<xsl:when test="$month = 7">-Jul-</xsl:when>
				<xsl:when test="$month = 8">-Aug-</xsl:when>
				<xsl:when test="$month = 9">-Sep-</xsl:when>
				<xsl:when test="$month = 10">-Oct-</xsl:when>
				<xsl:when test="$month = 11">-Nov-</xsl:when>
				<xsl:when test="$month = 12">-Dec-</xsl:when>
				<xsl:otherwise>-???-</xsl:otherwise>
			</xsl:choose>
			<!-- Year -->
			<xsl:value-of select="$year"/>
		</xsl:variable>
		<xsl:value-of select="$formattedDate"/>
	</xsl:if>
</xsl:template>

<!-- Multi-Tier Pricing Logic Templates -->
<!-- Template to get tier-specific extended net price -->
<xsl:template name="getTierSpecificExtNetPrice">
	<xsl:param name="lineItem"/>
	<xsl:variable name="extNetPrice">
		<xsl:choose>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
				<xsl:value-of select="$lineItem/extendedNetPrice_l_c"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
				<xsl:value-of select="$lineItem/extNetPriceResellerfloat_l_c"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
				<xsl:value-of select="$lineItem/extnetPriceEndCustomerfloat_l_c"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="-1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$extNetPrice"/>
</xsl:template>

<!-- Template to get tier-specific discount -->
<xsl:template name="getTierSpecificDiscount">
	<xsl:param name="lineItem"/>
	<xsl:variable name="discounts">
		<xsl:choose>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
				<xsl:value-of select="$lineItem/currentDiscount_l_c"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
				<xsl:value-of select="$lineItem/currentDiscountReseller_l_c"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
				<xsl:value-of select="$lineItem/currentDiscountEndCustomer_l_c"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="-1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$discounts"/>
</xsl:template>

<!-- Template to get tier-specific renewal total calculation -->
<xsl:template name="getTierSpecificRenewalTotal">
	<xsl:param name="renewalCalculation"/>
	<xsl:variable name="renewalTotal">
		<xsl:choose>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
				<xsl:value-of select="sum($renewalCalculation/extendedNetPrice_l_c)"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
				<xsl:value-of select="sum($renewalCalculation/extNetPriceResellerfloat_l_c)"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
				<xsl:value-of select="sum($renewalCalculation/extnetPriceEndCustomerfloat_l_c)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$renewalTotal"/>
</xsl:template>

<!-- Template to get tier-specific platform price total -->
<xsl:template name="getTierSpecificPlatformTotal">
	<xsl:param name="platformLines"/>
	<xsl:variable name="platformTotal">
		<xsl:choose>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
				<xsl:value-of select="sum($platformLines/extendedNetPrice_l_c)"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
				<xsl:value-of select="sum($platformLines/extNetPriceResellerfloat_l_c)"/>
			</xsl:when>
			<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
				<xsl:value-of select="sum($platformLines/extnetPriceEndCustomerfloat_l_c)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="$platformTotal"/>
</xsl:template>

<!-- Service Processing Templates and Variables -->
<!-- Template to get service dates for a line item -->
<xsl:template name="getServiceDates">
	<xsl:param name="lineItemNumber"/>
	<xsl:variable name="ChildLines" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and (lineType_l = 'SERVICE' or printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Additional Service' or starts-with(item_l/_part_number, 'CS-'))]"/>
	<xsl:variable name="ServiceStartDate">
		<xsl:value-of select="$ChildLines/serviceStartDate_l_c"/>
	</xsl:variable>
	<xsl:variable name="ServiceEndDate">
		<xsl:value-of select="$ChildLines/serviceEndDate_l_c"/>
	</xsl:variable>
	<xsl:variable name="ServiceDuration">
		<xsl:value-of select="$ChildLines/serviceDuration_l_c"/>
	</xsl:variable>
	
	<!-- Return service dates as a structured result -->
	<serviceData>
		<startDate><xsl:value-of select="$ServiceStartDate"/></startDate>
		<endDate><xsl:value-of select="$ServiceEndDate"/></endDate>
		<duration><xsl:value-of select="$ServiceDuration"/></duration>
	</serviceData>
</xsl:template>

<!-- Template to format service start date -->
<xsl:template name="formatServiceStartDate">
	<xsl:param name="serviceStartDate"/>
	<xsl:param name="format" select="'dd-MMM-yyyy'"/>
	<xsl:call-template name="formatDateForHTML">
		<xsl:with-param name="dateValue" select="$serviceStartDate"/>
		<xsl:with-param name="format" select="$format"/>
	</xsl:call-template>
</xsl:template>

<!-- Template to format service end date -->
<xsl:template name="formatServiceEndDate">
	<xsl:param name="serviceEndDate"/>
	<xsl:param name="format" select="'dd-MMM-yyyy'"/>
	<xsl:call-template name="formatDateForHTML">
		<xsl:with-param name="dateValue" select="$serviceEndDate"/>
		<xsl:with-param name="format" select="$format"/>
	</xsl:call-template>
</xsl:template>

<!-- Template to get installed address (service location) -->
<xsl:template name="getInstalledAddress">
	<xsl:param name="lineItem"/>
	<xsl:variable name="installedat" select="concat($lineItem/installedAtAddress_l_c,' ',$lineItem/installedAtStateProvince_l_c,' ',$lineItem/installedAtCountry_l_c,' ', $lineItem/installedAtPostalCode_l_c)"/>
	<xsl:choose>
		<xsl:when test="$installedat='   ' or $installedat=''">
			<span class="service-address">Not Specified</span>
		</xsl:when>
		<xsl:otherwise>
			<span class="service-address"><xsl:value-of select="$installedat"/></span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Template to handle asset type specific service dates -->
<xsl:template name="getAssetTypeServiceDates">
	<xsl:param name="assetType"/>
	<xsl:param name="lineItem"/>
	<xsl:choose>
		<xsl:when test="$assetType = 'Renew'">
			<div class="service-dates">
				<span class="service-label"><strong>Start Date of Extension:</strong></span>
				<span class="service-date">
					<xsl:call-template name="formatServiceStartDate">
						<xsl:with-param name="serviceStartDate" select="$lineItem/serviceStartDate_l_c"/>
					</xsl:call-template>
				</span>
			</div>
			<div class="service-dates">
				<span class="service-label"><strong>Extension Subscription End Date:</strong></span>
				<span class="service-date">
					<xsl:call-template name="formatServiceEndDate">
						<xsl:with-param name="serviceEndDate" select="$lineItem/serviceEndDate_l_c"/>
					</xsl:call-template>
				</span>
			</div>
		</xsl:when>
		<xsl:when test="$assetType = 'Amend'">
			<div class="service-dates">
				<span class="service-label"><strong>Existing Subscription End Date:</strong></span>
				<span class="service-date">
					<xsl:call-template name="formatServiceEndDate">
						<xsl:with-param name="serviceEndDate" select="$lineItem/serviceEndDate_l_c"/>
					</xsl:call-template>
				</span>
			</div>
		</xsl:when>
		<xsl:otherwise>
			<div class="service-dates">
				<span class="service-label"><strong>Service Start Date:</strong></span>
				<span class="service-date">
					<xsl:call-template name="formatServiceStartDate">
						<xsl:with-param name="serviceStartDate" select="$lineItem/serviceStartDate_l_c"/>
					</xsl:call-template>
				</span>
			</div>
			<div class="service-dates">
				<span class="service-label"><strong>Service End Date:</strong></span>
				<span class="service-date">
					<xsl:call-template name="formatServiceEndDate">
						<xsl:with-param name="serviceEndDate" select="$lineItem/serviceEndDate_l_c"/>
					</xsl:call-template>
				</span>
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Catalog Code Management Templates -->
<!-- Template to get catalog codes for service lines -->
<xsl:template name="getCatalogCodes">
	<xsl:param name="parentDocNum"/>
	<xsl:variable name="ChildServiceLines" select="exsl:node-set(/transaction/data_xml/document[normalize-space(./@data_type)='3' and cPQVirtualPart_l_c = 'CSITEMCHILD' and _parent_doc_number = $parentDocNum])"/>
	<xsl:variable name="dynamicCatCode">
		<xsl:value-of select="$ChildServiceLines/dynamicCatCode_l_c"/>
	</xsl:variable>
	<xsl:variable name="legacyCatCode">
		<xsl:value-of select="$ChildServiceLines/item_l/_part_custom_field463"/>
	</xsl:variable>
	
	<!-- Return catalog codes as structured result -->
	<catalogCodes>
		<dynamic><xsl:value-of select="$dynamicCatCode"/></dynamic>
		<legacy><xsl:value-of select="$legacyCatCode"/></legacy>
	</catalogCodes>
</xsl:template>

<!-- Template to display discount category based on catalog code type -->
<xsl:template name="displayDiscountCategory">
	<xsl:param name="catCodeType"/> <!-- 'dynamic' or 'legacy' -->
	<xsl:param name="dynamicCatCode"/>
	<xsl:param name="legacyCatCode"/>
	
	<div class="discount-category">
		<xsl:choose>
			<xsl:when test="$catCodeType = 'dynamic'">
				<xsl:choose>
					<xsl:when test="$dynamicCatCode != ''">
						<span class="discount-cat-label"><strong>[ Discount Cat: </strong></span>
						<span class="discount-cat-value"><xsl:value-of select="$dynamicCatCode"/></span>
						<span class="discount-cat-label"><strong> ]</strong></span>
					</xsl:when>
					<xsl:otherwise>
						<span class="discount-cat-none">No Dynamic Discount Category</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$catCodeType = 'legacy'">
				<xsl:choose>
					<xsl:when test="$legacyCatCode != ''">
						<span class="discount-cat-label"><strong>[ Legacy Cat: </strong></span>
						<span class="discount-cat-value"><xsl:value-of select="$legacyCatCode"/></span>
						<span class="discount-cat-label"><strong> ]</strong></span>
					</xsl:when>
					<xsl:otherwise>
						<span class="discount-cat-none">No Legacy Discount Category</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Auto-detect based on availability -->
				<xsl:choose>
					<xsl:when test="$dynamicCatCode != ''">
						<span class="discount-cat-label"><strong>[ Discount Cat: </strong></span>
						<span class="discount-cat-value"><xsl:value-of select="$dynamicCatCode"/></span>
						<span class="discount-cat-label"><strong> ]</strong></span>
					</xsl:when>
					<xsl:when test="$legacyCatCode != ''">
						<span class="discount-cat-label"><strong>[ Legacy Cat: </strong></span>
						<span class="discount-cat-value"><xsl:value-of select="$legacyCatCode"/></span>
						<span class="discount-cat-label"><strong> ]</strong></span>
					</xsl:when>
					<xsl:otherwise>
						<span class="discount-cat-none">No Discount Category</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</div>
</xsl:template>

<!-- Template to get catalog codes for hardware lines -->
<xsl:template name="getHardwareCatalogCodes">
	<xsl:param name="parentDocNum"/>
	<xsl:variable name="ServiceLines" select="exsl:node-set(/transaction/data_xml/document[normalize-space(./@data_type)='3' and _parent_doc_number = $parentDocNum])"/>
	<xsl:variable name="dynamicCatCode">
		<xsl:value-of select="$ServiceLines/dynamicCatCode_l_c"/>
	</xsl:variable>
	<xsl:variable name="legacyCatCode">
		<xsl:value-of select="$ServiceLines/item_l/_part_custom_field463"/>
	</xsl:variable>
	
	<!-- Return catalog codes as structured result -->
	<catalogCodes>
		<dynamic><xsl:value-of select="$dynamicCatCode"/></dynamic>
		<legacy><xsl:value-of select="$legacyCatCode"/></legacy>
	</catalogCodes>
</xsl:template>

<!-- Template for conditional catalog code display -->
<xsl:template name="conditionalCatalogDisplay">
	<xsl:param name="showCatalogCodes" select="'false'"/> <!-- Control display -->
	<xsl:param name="dynamicCatCode"/>
	<xsl:param name="legacyCatCode"/>
	<xsl:param name="catCodeType"/> <!-- 'dynamic', 'legacy', or 'auto' -->
	
	<xsl:if test="$showCatalogCodes = 'true' or $showCatalogCodes = '1'">
		<xsl:call-template name="displayDiscountCategory">
			<xsl:with-param name="catCodeType" select="$catCodeType"/>
			<xsl:with-param name="dynamicCatCode" select="$dynamicCatCode"/>
			<xsl:with-param name="legacyCatCode" select="$legacyCatCode"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Service Duration List Variable -->
<xsl:variable name="serviceDurationList">
	<xsl:for-each select="$serviceLines/serviceDuration_l_c">
		<xsl:sort data-type="number" select="." order="descending"/>
		<xsl:if test=". > 0">
			<xsl:copy-of select="."/>
		</xsl:if>
	</xsl:for-each>
</xsl:variable>
<!--  === MASTER.XSL COMPATIBILITY TEMPLATES ===  -->
<!--  Template to copy all nodes, given a root node. E.g. Used to copy RTE attribute as it is, in email templates, from the input XML  -->
<xsl:template name="copyNodes">
<xsl:param name="rootNode"/>
<xsl:copy-of select="$rootNode/*"/>
</xsl:template>
<!--  BMI_calculateSafePrice - Safe price calculation with multipliers and precision handling  -->
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
<!--  BMI_determineDecimalSeparator - Determines decimal separator for currency formatting  -->
<xsl:template name="BMI_determineDecimalSeparator">
<xsl:param name="currencyFormat"/>
<xsl:choose>
<xsl:when test="$currencyFormat">
<xsl:choose>
<xsl:when test="count($currencyFormat/decimal-format)>0">
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
<!--  BMI_replaceSubstring - String replacement utility  -->
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
<!--  splitTextIntoElementList - Splits text into elements based on delimiter  -->
<xsl:template name="splitTextIntoElementList">
<!--  $wrdBrk break on this character for a attribute:value combo  -->
<xsl:param name="wrdBrk" select="','"/>
<!--  start with nothing in $word and all the words in $remaining  -->
<xsl:param name="word" select="''"/>
<xsl:param name="remaining" select="."/>
<!--  === print value in word ====  -->
<xsl:if test="$word">
<Node>
<xsl:value-of select="$word"/>
</Node>
</xsl:if>
<xsl:choose>
<!--  if $remaining contains another word  -->
<xsl:when test="substring-before($remaining, $wrdBrk)">
<xsl:call-template name="splitTextIntoElementList">
<!--   move the first word of $remaining to $word,
                            remove the word from $remaining, and recurse. &lt;Node>
                     -->
<xsl:with-param name="word" select="substring-before($remaining, $wrdBrk)"/>
<xsl:with-param name="remaining" select="substring-after($remaining, $wrdBrk)"/>
<xsl:with-param name="wrdBrk" select=" $wrdBrk"/>
</xsl:call-template>
</xsl:when>
<!--  if $remaining contains a single value, set to $word and recurse one more time  -->
<xsl:when test="$remaining">
<xsl:call-template name="splitTextIntoElementList">
<xsl:with-param name="word" select="$remaining"/>
<xsl:with-param name="remaining" select="null"/>
<xsl:with-param name="wrdBrk" select=" $wrdBrk"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<!-- No remaining text to process -->
</xsl:otherwise>
</xsl:choose>
<!--  === if $remaining is null, split is done ====  -->
</xsl:template>
<!--  ignoreHalfEvenRounding - Custom rounding logic avoiding half-even rounding  -->
<xsl:template name="ignoreHalfEvenRounding">
<xsl:param name="fullNumber"/>
<xsl:param name="decimalSeparator" select="'.'"/>
<xsl:param name="safePrecision" select="2"/>
<xsl:variable name="decimalPrice" select="substring-after($fullNumber, $decimalSeparator)"/>
<xsl:choose>
<xsl:when test="number($safePrecision) > 0 and number(substring($decimalPrice, (number($safePrecision)+1), 1)) > 4">
<xsl:variable name="precisionPlusOne" select="number($safePrecision) + 1"/>
<xsl:variable name="decimalPlaceOffset" select="number(substring('10000000000000', 1, $precisionPlusOne))"/>
<xsl:choose>
<xsl:when test="number($fullNumber) > 0">
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
<!--  BMI_formatCurrencyValue - Creates currency format patterns for number formatting  -->
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
<xsl:when test="$showCents and number($safePrecision) > 0">
<xsl:value-of disable-output-escaping="yes" select="concat('#', $groupingSeparator, '##0', $decimalSeparator, substring('00000000', 1, $safePrecision))"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of disable-output-escaping="yes" select="concat('#', $groupingSeparator, '##0')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  BMI_determineGroupingSeparator - Determines grouping separator for currency formatting  -->
<xsl:template name="BMI_determineGroupingSeparator">
<xsl:param name="currencyFormat"/>
<xsl:choose>
<xsl:when test="$currencyFormat">
<xsl:choose>
<xsl:when test="count($currencyFormat/decimal-format)>0">
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
<!--  appendCurrencyPlaceHolder - Places currency symbol placeholder in formatted number string  -->
<xsl:template name="appendCurrencyPlaceHolder">
<xsl:param name="symbolLocation" select="1"/>
<xsl:param name="CURRENCY_LABEL_PLACEHOLDER" select="'CURRENCYLABELPLACEHOLDER'"/>
<xsl:param name="whiteSpace"/>
<xsl:param name="value"/>
<xsl:choose>
<!--  add symbol placeholder after  -->
<xsl:when test="$symbolLocation > 1">
<xsl:value-of select="concat($value, $whiteSpace, $CURRENCY_LABEL_PLACEHOLDER)"/>
</xsl:when>
<!--  add symbol placeholder before  -->
<xsl:when test="$symbolLocation = 1">
<xsl:value-of select="concat($CURRENCY_LABEL_PLACEHOLDER, $whiteSpace, $value)"/>
</xsl:when>
<!--  no symbol needed  -->
<xsl:otherwise>
<xsl:value-of select="$value"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  BMI_addCurrencyLabelOnly - Returns currency symbol/label for display  -->
<xsl:template name="BMI_addCurrencyLabelOnly">
<xsl:param name="currencyFormat"/>
<xsl:param name="currency"/>
<xsl:choose>
<xsl:when test="$currencyFormat">
<xsl:choose>
<xsl:when test="count($currencyFormat/font)>0">
<span style="font-family: {$currencyFormat/font};">
<xsl:value-of select="$currencyFormat/label"/>
</span>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$currencyFormat/label"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  BMI_addCurrencyLabel - Returns currency symbol/label for display  -->
<xsl:template name="BMI_addCurrencyLabel">
<xsl:param name="currencyFormat"/>
<xsl:param name="currency"/>
<xsl:choose>
<xsl:when test="$currencyFormat">
<xsl:choose>
<xsl:when test="count($currencyFormat/font)>0">
<span style="font-family: {$currencyFormat/font};">
<xsl:value-of select="$currencyFormat/label"/>
<xsl:if test="$currencyFormat/hasWhitespaceSeparator='true'"> </xsl:if>
</span>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$currencyFormat/label"/>
<xsl:if test="$currencyFormat/hasWhitespaceSeparator='true'"> </xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  BMI_formatLongDate - Formats date as "January 15, 2023"  -->
<xsl:template name="BMI_formatLongDate">
<xsl:param name="date"/>
<xsl:param name="separator"/>
<!--  Month  -->
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
<!--  Day  -->
<xsl:value-of select="number(substring($date, 9, 2))"/>
<xsl:text>, </xsl:text>
<!--  Year  -->
<xsl:value-of select="substring($date, 1, 4)"/>
</xsl:when>
</xsl:choose>
</xsl:template>
<!--  BMI_formatShortDate - Formats date as "09/28/2004" or "28.09.2004"  -->
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
<!--  Master.xsl Pricing Tier Logic - Enhanced  -->
<xsl:template name="getExtendedNetPrice">
<xsl:param name="lineNode"/>
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$lineNode/extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$lineNode/extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$lineNode/extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="-1"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="sumExtendedNetPrices">
<xsl:param name="lines"/>
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($lines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($lines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($lines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($lines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Unit Pricing Logic  -->
<xsl:template name="getUnitNetPrice">
<xsl:param name="lineNode"/>
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$lineNode/netPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$lineNode/resellerUnitNetPricefloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$lineNode/endCustomerUnitNetPricefloat_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="-1"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Discount Logic  -->
<xsl:template name="getDiscountPercentage">
<xsl:param name="lineNode"/>
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$lineNode/currentDiscount_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$lineNode/currentDiscountReseller_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$lineNode/currentDiscountEndCustomer_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="-1"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl List Price Logic  -->
<xsl:template name="sumExtendedListPrices">
<xsl:param name="lines"/>
<xsl:value-of select="sum($lines/extendedListPrice_l_c)"/>
</xsl:template>
<!--  Master.xsl SupportEdge Renewals Logic Enhanced  -->
<xsl:template name="getSESRenewalsLines">
<xsl:param name="configNumber"/>
<xsl:value-of select="//extractedLineItems/lineItem[configNumber_l_c = $configNumber and renewalIndicator_l_c = 'Y' and _part_number = 'SES-SYSTEM']"/>
</xsl:template>
<!--  Master.xsl Configuration Grouping Logic  -->
<xsl:template name="getSubLines">
<xsl:param name="lineNumber"/>
<xsl:param name="expansionLineNum" select="-1"/>
<xsl:param name="bomLevel"/>
<xsl:param name="lineType"/>
<xsl:copy-of select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and ((topModelLineID_l_c = $lineNumber or topModelLineID_l_c = $expansionLineNum) or (modelReferenceLineID_l_c = $lineNumber and _line_bom_level > $bomLevel)) and lineType_l != $lineType]"/>
</xsl:template>
<!--  Master.xsl Hardware Lines Filtering  -->
<xsl:template name="getHardwareLines">
<xsl:param name="subLines"/>
<xsl:value-of select="$subLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and (printGrouping_l_c = 'HARDWARE' or printGrouping_l_c = 'PLATFORM' or printGrouping_l_c = 'STORAGE' or printGrouping_l_c = 'Hardware')]"/>
</xsl:template>
<!--  Master.xsl Software Lines Filtering  -->
<xsl:template name="getSoftwareLines">
<xsl:param name="subLines"/>
<xsl:value-of select="$subLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and (item_l/_part_custom_field474 = 'SOFTWARE' or item_l/_part_custom_field474 = 'OS') and item_l/_part_custom_field476 = 'Software' and item_l/_part_custom_field479 = 'Y']"/>
</xsl:template>
<!--  Master.xsl Subscription Lines Filtering  -->
<xsl:template name="getSubscriptionLines">
<xsl:param name="subLines"/>
<xsl:value-of select="$subLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and item_l/_part_custom_field474 = 'SUBSCRIPTION' and item_l/_part_custom_field479 = 'Y']"/>
</xsl:template>
<!--  Master.xsl Summary Calculation Logic  -->
<xsl:template name="shouldShowPricing">
<xsl:param name="subtotalGrandTotal"/>
<xsl:choose>
<xsl:when test="$subtotalGrandTotal != 'noPricing'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="shouldShowListPricing">
<xsl:param name="subtotalGrandTotal"/>
<xsl:choose>
<xsl:when test="$subtotalGrandTotal = 'listDiscountAndNetPricing'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="shouldShowNetPricing">
<xsl:param name="subtotalGrandTotal"/>
<xsl:choose>
<xsl:when test="$subtotalGrandTotal = 'onlyNetPricing' or $subtotalGrandTotal = 'listDiscountAndNetPricing'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Line Type Logic  -->
<xsl:template name="isStandardOrService">
<xsl:param name="lineType"/>
<xsl:choose>
<xsl:when test="$lineType = 'STD' or $lineType = 'SERVICE'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Trade-in Logic  -->
<xsl:template name="isTradeIn">
<xsl:param name="summaryPrintGrouping"/>
<xsl:choose>
<xsl:when test="$summaryPrintGrouping = 'Trade-in'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Display Condition Logic  -->
<xsl:template name="shouldDisplayLine">
<xsl:param name="extendedListPrice"/>
<xsl:param name="hasDonotPrint"/>
<xsl:param name="summaryPrintGrouping"/>
<xsl:param name="lineType"/>
<xsl:param name="renewalIndicator"/>
<!-- RAJ-Corrected the condition: original had unescaped < '0' which needed &lt; '0' -->
<xsl:choose>
<xsl:when test="(($extendedListPrice > '0' or $hasDonotPrint) or ($extendedListPrice &lt; '0' and $summaryPrintGrouping = 'Trade-in') or $lineType = 'SERVICE') and $renewalIndicator != 'Y'">
<xsl:text>true</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>false</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Master.xsl Service Period Logic Enhanced  -->
<xsl:template name="getServicePeriodInfo">
<xsl:param name="lineItemNumber"/>
<xsl:variable name="serviceLines" select="//extractedLineItems/lineItem[modelReferenceLineID_l_c = $lineItemNumber and printGrouping_l_c = 'SERVICE']"/>
<xsl:if test="count($serviceLines) > 0">
<xsl:value-of select="$serviceLines[1]/serviceStartDate_l_c"/>
to
<xsl:value-of select="$serviceLines[1]/serviceEndDate_l_c"/>
(
<xsl:value-of select="$serviceLines[1]/serviceDuration_l_c"/>
months)
</xsl:if>
</xsl:template>
<!--  Master.xsl Formatted Service Dates  -->
<xsl:template name="getFormattedServiceStartDate">
<xsl:param name="lineNode"/>
<xsl:param name="dateFormat" select="'dd-MMM-yyyy'"/>
<xsl:value-of select="$lineNode/serviceStartDate_l_c"/>
</xsl:template>
<xsl:template name="getFormattedServiceEndDate">
<xsl:param name="lineNode"/>
<xsl:param name="dateFormat" select="'dd-MMM-yyyy'"/>
<xsl:value-of select="$lineNode/serviceEndDate_l_c"/>
</xsl:template>
<!--  Master.xsl Asset Type Logic  -->
<xsl:template name="getAssetTypeLabel">
<xsl:param name="assetType"/>
<xsl:choose>
<xsl:when test="$assetType = 'Renew'">
<xsl:text>Start Date of Extension:</xsl:text>
</xsl:when>
<xsl:when test="$assetType = 'Amend'">
<xsl:text>Existing Subscription End Date:</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>Service Period:</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Essential Master.xsl template for conditional logic  -->
<xsl:template name="getCustomXslTruth">
<xsl:param name="var"/>
<xsl:choose>
<xsl:when test="$var">
<xsl:value-of select="1"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="0"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Format float values with correct decimal formatting - from Master.xsl  -->
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
<xsl:when test="$precision > 0">
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
</xsl:template>
<!--  Universal currency formatting template from Master.xsl  -->
<xsl:template name="BMI_universalFormatPriceCustom">
<xsl:param name="price"/>
<xsl:param name="multiplier" select="1"/>
<xsl:param name="showCents" select="true()"/>
<xsl:param name="precision" select="2"/>
<xsl:param name="currency" select="'USD'"/>
<xsl:param name="showCurrencySymbol"/>
<xsl:param name="decimalFormatClass"/>
<xsl:variable name="safePrecision">
<!-- RAJ-Corrected the condition: original had unescaped >= and <= which needed >= and &lt;= -->
<xsl:choose>
<xsl:when test="number($precision) >= 0 and number($precision) &lt;= 8">
<xsl:value-of select="$precision"/>
</xsl:when>
<xsl:otherwise>2</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="safePrice">
<xsl:choose>
<xsl:when test="$showCents = true()">
<xsl:value-of select="$price * $multiplier"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="floor($price * $multiplier)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="dfcName">
<xsl:choose>
<xsl:when test="$decimalFormatClass and string-length($decimalFormatClass) > 0">
<xsl:value-of select="$decimalFormatClass"/>
</xsl:when>
<xsl:when test="$currency = 'EUR'">
<xsl:value-of select="'euro'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'american'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="format">
<xsl:choose>
<xsl:when test="$showCents = true() and $safePrecision > 0">
<xsl:choose>
<xsl:when test="$dfcName = 'euro'">
<xsl:value-of select="concat('#.##0,', substring('00000000', 1, $safePrecision))"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat('#,##0.', substring('00000000', 1, $safePrecision))"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:choose>
<xsl:when test="$dfcName = 'euro'">
<xsl:value-of select="'#.##0'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'#,##0'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="formattedNumber" select="format-number($safePrice, $format, $dfcName)"/>
<!-- RAJ-Corrected the condition: original had unescaped >= which needed >= -->
<xsl:choose>
<xsl:when test="number($showCurrencySymbol) >= 1">
<xsl:variable name="currencySymbol">
<xsl:choose>
<xsl:when test="$currency = 'USD'">$</xsl:when>
<xsl:when test="$currency = 'EUR'">€</xsl:when>
<xsl:when test="$currency = 'GBP'">£</xsl:when>
<xsl:otherwise>
<xsl:value-of select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="number($showCurrencySymbol) = 1">
<xsl:value-of select="concat($currencySymbol, ' ', $formattedNumber)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat($formattedNumber, ' ', $currencySymbol)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$formattedNumber"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  BMI_universalFormatPrice - Universal price formatting with currency symbols  -->
<xsl:template name="BMI_universalFormatPrice">
<xsl:param name="price"/>
<xsl:param name="currency"/>
<xsl:param name="multiplier" select="1"/>
<xsl:param name="showCents" select="true()"/>
<xsl:param name="showCurrencySymbol" select="true()"/>
<xsl:param name="precision" select="2"/>
<xsl:variable name="safePrecision">
<xsl:choose>
<xsl:when test="number($precision) >= 0 and number($precision) &lt;= 8">
<xsl:value-of select="$precision"/>
</xsl:when>
<xsl:otherwise>2</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="safePrice">
<xsl:call-template name="BMI_calculateSafePrice">
<xsl:with-param name="price" select="$price"/>
<xsl:with-param name="multiplier" select="$multiplier"/>
<xsl:with-param name="showCents" select="$showCents"/>
<xsl:with-param name="safePrecision" select="$safePrecision"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="format">
<xsl:call-template name="BMI_formatCurrencyValue">
<xsl:with-param name="showCents" select="$showCents"/>
<xsl:with-param name="safePrecision" select="$safePrecision"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="currencySymbol">
<xsl:if test="$showCurrencySymbol">
<xsl:call-template name="BMI_addCurrencyLabel">
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</xsl:if>
</xsl:variable>
<xsl:value-of select="format-number($safePrice,concat($currencySymbol, $format),'american')"/>
</xsl:template>
<!--  BMI_universalNumber - Universal number formatting for different currencies  -->
<xsl:template name="BMI_universalNumber">
<xsl:param name="val"/>
<xsl:param name="numFormat"/>
<xsl:param name="formatForDisplay" select="''"/>
<xsl:variable name="realNumber">
<xsl:choose>
<xsl:when test="$numFormat = 'EUR'">
<xsl:variable name="reverseSeperators" select="translate($val,',.','.,')"/>
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
<!--  Image source template from Master.xsl  -->
<xsl:template name="BMI_getImageSrc">
<xsl:param name="attachmentID" select="-1"/>
<xsl:param name="defaultUrl" select="''"/>
<xsl:choose>
<xsl:when test="$attachmentID != -1">
<xsl:value-of select="concat('FILEATTACHMENT#', $attachmentID)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$defaultUrl"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="BM_getEmbedDocSrc">
    <xsl:param name="attachmentID" select="-1"/>
    <!-- returns FILEATTACHMENT#{attachmentID} if the file attachment is a PDF,
        otherwise returns an empty string - adapted for HTML output -->
    <!-- Commented out Java extension function to avoid WebLogic/Xalan compatibility issues -->
    <!-- <xsl:value-of xmlns:PrintUtil="com.bm.xchange.services.templateengine.utils.TePrintUtil" select="PrintUtil:getEmbedDocSrc($attachmentID)"/> -->
    
    <!-- Fallback implementation for environments without PrintUtil -->
    <xsl:choose>
        <xsl:when test="$attachmentID != -1">
            <xsl:value-of select="concat('FILEATTACHMENT#', $attachmentID)"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
</xsl:template>
<!--  Essential formatting templates from Master.xsl  -->
<xsl:template name="currencyFormattedPrice">
<xsl:param name="price"/>
<xsl:param name="align" select="'right'"/>
<xsl:param name="fontSize" select="'12pt'"/>
<xsl:param name="fontWeight" select="'bold'"/>
<div style="text-align: {$align}; font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: Helvetica;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($price)"/>
</xsl:call-template>
</div>
</xsl:template>
<xsl:template name="addendumTotalPrint">
<xsl:param name="label" select="''"/>
<xsl:param name="sum" select="0"/>
<xsl:param name="align" select="'right'"/>
<div style="text-align: {$align}; font-size: 8pt; font-family: Helvetica;">
<strong>
<xsl:value-of select="$label"/>
</strong>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number(translate($sum, ',', '.'))"/>
</xsl:call-template>
</div>
</xsl:template>
<xsl:template name="discountFormattedPrint">
<xsl:param name="label" select="''"/>
<xsl:param name="discPct" select="0"/>
<xsl:param name="fontSize" select="'12pt'"/>
<xsl:param name="fontWeight" select="'bold'"/>
<xsl:param name="align" select="'center'"/>
<div style="text-align: {$align}; font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: Helvetica;">
<strong>
<xsl:value-of select="$label"/>
</strong>
<xsl:call-template name="BMI_formatFloat">
<xsl:with-param name="val" select="$discPct"/>
<xsl:with-param name="numFormat" select="'USD'"/>
<xsl:with-param name="precision" select="2"/>
</xsl:call-template>
%
</div>
</xsl:template>
<xsl:template name="NewcurrencyFormattedPrice">
<xsl:param name="price"/>
<xsl:param name="align" select="'right'"/>
<xsl:param name="fontSize" select="'12pt'"/>
<xsl:param name="fontWeight" select="'bold'"/>
<xsl:param name="precision" select="4"/>
<div style="text-align: {$align}; font-size: {$fontSize}; font-weight: {$fontWeight}; font-family: Helvetica;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($price)"/>
</xsl:call-template>
</div>
</xsl:template>
<xsl:template name="summaryPrintList">
<xsl:param name="label" select="''"/>
<xsl:param name="list"/>
<div style="font-size: 8pt; font-family: Helvetica;">
<strong>
<xsl:value-of select="$label"/>
</strong>
<xsl:if test="count($list) > 0">
<xsl:for-each select="$list[not(. = preceding::*)]">
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
</div>
</xsl:template>
<xsl:template name="summaryPrintListALL">
<xsl:param name="label" select="''"/>
<xsl:param name="list"/>
<div style="font-size: 8pt; font-family: Helvetica;">
<strong>
<xsl:value-of select="$label"/>
</strong>
<xsl:if test="count($list) > 0">
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
</div>
</xsl:template>
<xsl:template name="printSumNumeric">
<xsl:param name="label" select="''"/>
<xsl:param name="suffix" select="''"/>
<xsl:param name="sum" select="0"/>
<div style="font-size: 8pt; font-family: Helvetica;">
<strong>
<xsl:value-of select="$label"/>
</strong>
<xsl:value-of select="concat($sum, $suffix)"/>
</div>
</xsl:template>
<!--  Template to get extended list price from line item  -->
<xsl:template name="getExtendedListPrice">
<xsl:param name="lineItem"/>
<xsl:value-of select="$lineItem/extendedListPrice_l_c"/>
</xsl:template>
<!--  Template to format date from YYYY-MM-DD to DD-Mon-YYYY  -->
<xsl:template name="formatDate">
<xsl:param name="dateString"/>
<xsl:variable name="year" select="substring($dateString, 1, 4)"/>
<xsl:variable name="month" select="substring($dateString, 6, 2)"/>
<xsl:variable name="day" select="substring($dateString, 9, 2)"/>
<xsl:variable name="formattedDate">
<xsl:value-of select="$day"/>
<xsl:choose>
<xsl:when test="$month = '01'">-Jan-</xsl:when>
<xsl:when test="$month = '02'">-Feb-</xsl:when>
<xsl:when test="$month = '03'">-Mar-</xsl:when>
<xsl:when test="$month = '04'">-Apr-</xsl:when>
<xsl:when test="$month = '05'">-May-</xsl:when>
<xsl:when test="$month = '06'">-Jun-</xsl:when>
<xsl:when test="$month = '07'">-Jul-</xsl:when>
<xsl:when test="$month = '08'">-Aug-</xsl:when>
<xsl:when test="$month = '09'">-Sep-</xsl:when>
<xsl:when test="$month = '10'">-Oct-</xsl:when>
<xsl:when test="$month = '11'">-Nov-</xsl:when>
<xsl:when test="$month = '12'">-Dec-</xsl:when>
<xsl:otherwise>-???-</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="$year"/>
</xsl:variable>
<xsl:value-of select="$formattedDate"/>
</xsl:template>
<!--  Main template matching the transaction root  -->
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html>
</xsl:text>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title>Solution Quotation</title>
<style>
/* ===== PDF-EXACT MATCHING STYLES - CENTRALIZED REUSABLE SYSTEM ===== */

/* ===== PAGE LAYOUT - EXACT FO REPLICATION ===== */
@page { size: 8.5in 11in; margin: 0.2in 0.5in 0.5in 0.5in; }
body { 
	font-family: Helvetica, Arial, sans-serif; 
	font-size: 12pt; 
	line-height: 100%; 
	color: #000000; 
	background-color: #ffffff; 
	margin: 0.75in 0.5in 1.0in 0.5in; 
	text-align: left; 
}

/* ===== CORE TYPOGRAPHY SYSTEM - PDF EXACT MATCH ===== */
.pdf-header-title { font-family: Helvetica; font-size: 20pt; color: #000000; font-weight: bold; text-align: center; line-height: 30pt; }
.pdf-text-8pt { font-family: Helvetica; font-size: 8pt; color: #000000; line-height: 8pt; }
.pdf-text-8pt-bold { font-family: Helvetica; font-size: 8pt; color: #000000; font-weight: bold; line-height: 8pt; }
.pdf-text-10pt { font-family: Helvetica; font-size: 10pt; color: #000000; line-height: 10pt; }
.pdf-text-12pt { font-family: Helvetica; font-size: 12pt; color: #000000; line-height: 12pt; }
.pdf-text-12pt-bold { font-family: Helvetica; font-size: 12pt; color: #000000; font-weight: bold; line-height: 12pt; }

/* ===== PDF TABLE SYSTEM - EXACT FO MATCH ===== */
.pdf-table { table-layout: fixed; width: 100%; border-collapse: collapse; float: left; font-family: Helvetica; }
.pdf-table-cell { padding: 4px 0px; vertical-align: top; overflow: hidden; }
.pdf-table-cell-bordered { padding: 4px 0px; vertical-align: top; border: 1px solid #000000; overflow: hidden; }

/* ===== PDF COLUMN WIDTH SYSTEM - EXACT PROPORTIONAL MATCH ===== */
.pdf-col-100 { width: 8.33%; }   /* 100/1200 */
.pdf-col-200 { width: 16.67%; }  /* 200/1200 */
.pdf-col-350 { width: 29.17%; }  /* 350/1200 */
.pdf-col-400 { width: 33.33%; }  /* 400/1200 */

/* ===== PDF TEXT ALIGNMENT SYSTEM ===== */
.pdf-text-left { text-align: left; }
.pdf-text-center { text-align: center; }
.pdf-text-right { text-align: right; }

/* ===== PDF SPACING SYSTEM - EXACT FO MATCH ===== */
.pdf-space-1pt { line-height: 1pt; font-size: 1pt; margin: 0; padding: 0; }
.pdf-margin-left-3px { margin-left: 3px; }
.pdf-block-margin { margin-right: 0in; margin-left: 0in; margin-bottom: 0in; margin-top: 0in; }

/* ===== PDF HEADER/FOOTER SYSTEM ===== */
.pdf-logo { height: 40px; width: 195px; }
.pdf-footer-text { font-family: Helvetica; font-size: 8pt; color: #000000; text-align: left; line-height: 8pt; }

/* ===== PDF SECTION HEADERS ===== */
.pdf-section-header { font-family: Helvetica; font-size: 12pt; color: #000000; font-weight: bold; text-align: left; line-height: 12pt; }
.pdf-section-spacing { margin-bottom: 0.1in; }

/* ===== PDF RENEWALS TABLE HEADERS - EXACT UI.XSL MATCH ===== */
.pdf-renewals-header { 
	font-family: Helvetica; 
	font-size: 8pt; 
	color: rgba(0, 0, 0, 0.9); 
	background-color: #ffffff; 
	font-weight: bold; 
	text-align: center; 
	padding: 4px 0px; 
	border: 1px solid #000000; 
}

/* ===== PDF CURRENCY FORMATTING ===== */
.pdf-currency { text-align: right; font-family: Helvetica; font-size: 8pt; color: #000000; }

/* ===== PDF SERVICE TABLE STYLING ===== */
.pdf-service-table { table-layout: fixed; width: 100%; border-collapse: collapse; border: 1px solid #000000; margin: 10px 0; }
.pdf-service-header { 
	background-color: #E1E1E1; 
	color: #000000; 
	padding: 4px; 
	text-align: center; 
	border: 1px solid #000000; 
	font-weight: bold; 
	font-size: 8pt; 
	font-family: Helvetica; 
}
.pdf-service-cell { padding: 4px; border: 1px solid #000000; font-size: 8pt; font-family: Helvetica; vertical-align: top; }

/* ===== PDF GRAND TOTAL STYLING ===== */
.pdf-grand-total { font-family: Helvetica; font-size: 10pt; font-weight: bold; text-align: right; }
.pdf-grand-total-border { border-top: 3px solid #000; padding-top: 8px; }

/* ===== LEGACY COMPATIBILITY LAYER (maintains existing functionality) ===== */
.header { font-family: Helvetica, Arial, sans-serif; font-size: 20pt; font-weight: bold; color: #000000; text-align: center; line-height: 30pt; margin-bottom: 20px; }
.small-text { font-family: Helvetica, Arial, sans-serif; font-size: 8pt; color: #000000; line-height: 8pt; }
.normal-text { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; color: #000000; line-height: 12pt; }
.bold-text { font-weight: bold; }
.section-header { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; font-weight: bold; color: #000000; text-align: left; line-height: 13pt; }
table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 12pt; }
table td, table th { padding: 0; vertical-align: top; text-align: left; font-weight: normal; }
.text-right { text-align: right; }
.text-center { text-align: center; }
.text-left { text-align: left; }
.header-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 0; }
.info-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 10pt; }
.main-table { table-layout: fixed; width: 100%; border-collapse: collapse; margin-bottom: 3pt; }
.col-100 { width: 8.33%; }
.col-200 { width: 16.67%; }
.col-250 { width: 20.83%; }
.col-300 { width: 25%; }
.col-400 { width: 33.33%; }
.table-cell { padding: 4px 0px; vertical-align: top; }
.spacing-1pt { line-height: 1pt; font-size: 1pt; margin: 0; padding: 0; }
.margin-left-7pt { margin-left: 7pt; }
.currency { text-align: right; font-family: Helvetica, Arial, sans-serif; font-size: 10pt; color: #000000; }
.logo-container { text-align: left; padding: 4px 0px; }
.logo-img { height: 40px; width: 195px; }
.section-break { margin-top: 15pt; margin-bottom: 10pt; }
.keep-together { page-break-inside: avoid; }

/* ===== PDF PRINT OPTIMIZATION ===== */
@media print {
	body { margin: 0.75in 0.5in 1.0in 0.5in; print-color-adjust: exact; -webkit-print-color-adjust: exact; }
	.pdf-table, .main-table, .header-table, .info-table { page-break-inside: avoid; }
	.keep-together { page-break-inside: avoid; }
	.pdf-section-header { page-break-after: avoid; }
}
</style>
</head>
<body>
<!--  Page Header - Mirroring FO region-before  -->
<header class="page-header">
<table class="pdf-table">
<tr>
<td class="col-200 logo-container">
<img src="https://netappinctest3.bigmachines.com/bmfsweb/netappinctest3/image/logo/NetApp_Logo_QE.png" alt="NetApp Logo" class="logo-img"/>
</td>
<td class="col-400 text-center">
<div class="header">
Solution Quotation
<xsl:value-of select="//document[@document_var_name='transaction']/quoteNumber_t_c"/>
</div>
</td>
<td class="col-100"/>
</tr>
</table>
</header>
<!--  Quote Info Header - Mirroring FO info table structure  -->
<div class="section-break">
<table class="pdf-table keep-together">
<colgroup>
<col class="col-200"/>
<col class="col-250"/>
<col class="col-200"/>
<col class="col-200"/>
</colgroup>
<tr>
<td class="table-cell text-right small-text">Quote Name:</td>
<td class="table-cell small-text" colspan="3">
<div class="margin-left-7pt">
<xsl:value-of select="//document[@document_var_name='transaction']/quoteNameTextArea_t_c"/>
</div>
</td>
</tr>
<tr>
<td class="table-cell text-right small-text">Quote Date:</td>
<td class="table-cell small-text">
<div class="margin-left-7pt">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(//document[@document_var_name='transaction']/quoteExportDate_t_c, 1, 10)"/>
</xsl:call-template>
</div>
</td>
<td class="table-cell text-right small-text">Quote Valid Until:</td>
<td class="table-cell small-text">
<div class="margin-left-7pt">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(//document[@document_var_name='transaction']/expiresOnDate_t_c, 1, 10)"/>
</xsl:call-template>
</div>
</td>
</tr>
<tr>
<td class="table-cell text-right small-text">Contact Name:</td>
<td class="table-cell small-text" colspan="3">
<div class="margin-left-7pt">
<xsl:value-of select="//document[@document_var_name='transaction']/salesRep_t_c"/>
</div>
</td>
</tr>
<tr>
<td class="table-cell text-right small-text">Email:</td>
<td class="table-cell small-text" colspan="3">
<div class="margin-left-7pt">
<xsl:value-of select="//document[@document_var_name='transaction']/opportunityOwnerEmail_t_c"/>
</div>
</td>
</tr>
<tr>
<td>Quote To:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='accounts_Array_t_c']/_array_set_row[@_row_number='2']/attribute[@var_name='company_accounts_Array_t_c']"/>
,
<xsl:value-of select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='accounts_Array_t_c']/_array_set_row[@_row_number='2']/attribute[@var_name='address_accounts_Array_t_c']"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td class="table-cell text-right small-text">Quote From:</td>
<td class="table-cell small-text" colspan="3">
<div class="margin-left-7pt">
<xsl:value-of select="//document[@document_var_name='transaction']/legalEntities_t_c"/>
,
<xsl:value-of select="//document[@document_var_name='transaction']/legalEntityAddress_t_c"/>
</div>
</td>
</tr>
<tr>
<td class="table-cell text-right small-text">
<xsl:choose>
<xsl:when test="$_dsMain1/keyStone_t_c = 'Yes'">End User:</xsl:when>
<xsl:otherwise>End Customer:</xsl:otherwise>
</xsl:choose>
</td>
<td>
<!--  Master uses AccountXml (parsed JSON) for End Customer address
                                     Since we can't parse JSON without external jsonToXML.xsl,
                                     we'll do basic text extraction from accountsJsonArray_t_c
                                     Format: [{"type":"End Customer","name":"...","address1":"...","city":"...","state":"...","country":"...","zipCode":"..."}]
                                 -->
<!-- RAJ-Corrected the condition: changed select attributes from single quotes to double quotes to fix XPath quote escaping -->
<xsl:variable name="accountsJson" select="//document[@document_var_name='transaction']/accountsJsonArray_t_c"/>
<!--  Extract End Customer name: text between "name":" and next " after type":"End Customer"  -->
<xsl:variable name="afterEndCustomer" select="substring-after($accountsJson, '&quot;type&quot;:&quot;End Customer&quot;')"/>
<xsl:variable name="afterName" select="substring-after($afterEndCustomer, '&quot;name&quot;:&quot;')"/>
<xsl:variable name="endCustomerName" select="substring-before($afterName, '&quot;')"/>
<!--  Extract address1  -->
<xsl:variable name="afterAddress1" select="substring-after($afterEndCustomer, '&quot;address1&quot;:&quot;')"/>
<xsl:variable name="endCustomerAddress" select="substring-before($afterAddress1, '&quot;')"/>
<!--  Extract city  -->
<xsl:variable name="afterCity" select="substring-after($afterEndCustomer, '&quot;city&quot;:&quot;')"/>
<xsl:variable name="endCustomerCity" select="substring-before($afterCity, '&quot;')"/>
<!--  Extract state  -->
<xsl:variable name="afterState" select="substring-after($afterEndCustomer, '&quot;state&quot;:&quot;')"/>
<xsl:variable name="endCustomerState" select="substring-before($afterState, '&quot;')"/>
<!--  Extract country (full name, not code!)  -->
<xsl:variable name="afterCountry" select="substring-after($afterEndCustomer, '&quot;country&quot;:&quot;')"/>
<xsl:variable name="endCustomerCountry" select="substring-before($afterCountry, '&quot;')"/>
<!--  Extract zipCode  -->
<xsl:variable name="afterZip" select="substring-after($afterEndCustomer, '&quot;zipCode&quot;:&quot;')"/>
<xsl:variable name="endCustomerZip" select="substring-before($afterZip, '&quot;')"/>
<!--  Build address string  -->
<xsl:value-of select="$endCustomerName"/>
<xsl:if test="$endCustomerAddress!=''">
<xsl:text>, </xsl:text>
<xsl:value-of select="$endCustomerAddress"/>
</xsl:if>
<xsl:if test="$endCustomerCity!=''">
<xsl:text> </xsl:text>
<xsl:value-of select="$endCustomerCity"/>
</xsl:if>
<xsl:if test="$endCustomerState!=''">
<xsl:text> </xsl:text>
<xsl:value-of select="$endCustomerState"/>
</xsl:if>
<xsl:if test="$endCustomerCountry!=''">
<xsl:text> </xsl:text>
<xsl:value-of select="$endCustomerCountry"/>
</xsl:if>
<xsl:if test="$endCustomerZip!=''">
<xsl:text> </xsl:text>
<xsl:value-of select="$endCustomerZip"/>
</xsl:if>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Quote Status:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/quoteStatus_t_c"/>
</td>
<td>Fulfilment Method:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/fulfillmentMethod_t_c"/>
</td>
</tr>
</table>
</div>
<!--  Service Period Section - SES-SYSTEM Renewal MODEL items (matching Master.xsl logic)  -->
<!--  Master.xsl Condition: Only show if serviceRenewal_t_c field has value  -->
<xsl:if test="$_dsMain1/serviceRenewal_t_c!=''">
<xsl:variable name="renewalModelLines" select="/transaction/data_xml/document[ normalize-space(./@data_type)='3' and ./renewalIndicator_l_c = 'Y' and ./lineType_l = 'MODEL' and ./item_l/_part_number = 'SES-SYSTEM' ]"/>
<xsl:if test="count($renewalModelLines) > 0">
<!--  Master.xsl Column Visibility Variables  -->
<xsl:variable name="COLUMN97146a5d-d8d0-43a1-9c13-84344296d864">
<xsl:choose>
<xsl:when test="$_dsMain1/subtotalGrandTotal_t_c = 'listDiscountAndNetPricing'">true</xsl:when>
<xsl:otherwise>false</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="COLUMN70f9dcc8-13e3-468a-ab57-a5ea0d9c03b7">
<xsl:choose>
<xsl:when test="$_dsMain1/subtotalGrandTotal_t_c = 'onlyNetPricing' or $_dsMain1/subtotalGrandTotal_t_c = 'listDiscountAndNetPricing'">true</xsl:when>
<xsl:otherwise>false</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<div class="section-break">
<!--  Section Header - Mirroring FO product name style  -->
<div class="pdf-section-header pdf-section-spacing">SupportEdge Renewals Pricing Summary</div>
<div class="pdf-space-1pt"> </div>
<!--  Main Data Table - Exact PDF Structure  -->
<table class="pdf-table keep-together">
<colgroup>
<col class="pdf-col-350"/>
<!--  Serial Number / Quote Linkage  -->
<col class="pdf-col-200"/>
<!--  Service Period Duration  -->
<col class="pdf-col-200"/>
<!--  Service Period Start Date  -->
<col class="pdf-col-200"/>
<!--  Service Period End Date  -->
<xsl:if test="$COLUMN97146a5d-d8d0-43a1-9c13-84344296d864='true'">
<col class="col-200"/>
<!--  Ext. List Price  -->
</xsl:if>
<xsl:if test="$COLUMN70f9dcc8-13e3-468a-ab57-a5ea0d9c03b7='true'">
<col class="col-200"/>
<!--  Ext. Net Price  -->
</xsl:if>
</colgroup>
<thead>
<tr>
<th class="pdf-renewals-header">Serial Number / Quote Linkage</th>
<th class="pdf-renewals-header">Service Period Duration</th>
<th class="pdf-renewals-header">Service Period Start Date</th>
<th class="pdf-renewals-header">Service Period End Date</th>
<!--  Conditional columns based on Master.xsl pricing display settings  -->
<xsl:if test="$COLUMN97146a5d-d8d0-43a1-9c13-84344296d864='true'">
<th class="pdf-renewals-header">Ext. List Price</th>
</xsl:if>
<xsl:if test="$COLUMN70f9dcc8-13e3-468a-ab57-a5ea0d9c03b7='true'">
<th class="pdf-renewals-header">Ext. Net Price</th>
</xsl:if>
</tr>
</thead>
<tbody>
<xsl:for-each select="$renewalModelLines">
<xsl:sort select="./@_document_number" data-type="number" order="ascending"/>
<!--  Master.xsl Variable Definitions  -->
<xsl:variable name="_dsSub1" select="."/>
<xsl:variable name="lineItemNumber" select="$_dsSub1/lineItemNumber_l_c"/>
<xsl:variable name="ChildLines" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and (lineType_l = 'SERVICE' or printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Additional Service' or starts-with(item_l/_part_number, 'CS-'))]"/>
<xsl:variable name="ServiceStartDate">
<xsl:value-of select="$ChildLines/serviceStartDate_l_c"/>
</xsl:variable>
<xsl:variable name="ServiceEndDate">
<xsl:value-of select="$ChildLines/serviceEndDate_l_c"/>
</xsl:variable>
<xsl:variable name="ServiceDuration">
<xsl:value-of select="$ChildLines/serviceDuration_l_c"/>
</xsl:variable>
<tr>
<!--  Serial Number / Quote Linkage - Mirroring Master.xsl first column  -->
<td class="pdf-table-cell-bordered pdf-text-center">
<xsl:choose>
<xsl:when test="$_dsSub1/addOnOriginalQuoteNumberSearch_l_c != ''">
<div class="pdf-text-8pt">
<xsl:value-of select="$_dsSub1/serialNumber_l_c"/>
</div>
</xsl:when>
<xsl:otherwise>
<div class="pdf-text-8pt">
<!-- No add-on quote linkage, show standard serial number -->
<xsl:value-of select="$_dsSub1/serialNumber_l_c"/>
</div>
</xsl:otherwise>
</xsl:choose>
<!--  Serial Number Array Display - Mirroring Master.xsl nested table  -->
<div class="serial-numbers">
<table class="pdf-table">
<tbody>
<xsl:for-each select="./_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
<xsl:variable name="_dsTxnArray" select="."/>
<tr>
<td class="serial-cell">
<xsl:if test="$_dsTxnArray/attribute[@var_name='serialNumber_serialNumber_Array_l_c'] != ''">
<xsl:value-of select="$_dsTxnArray/attribute[@var_name='serialNumber_serialNumber_Array_l_c']"/>
</xsl:if>
</td>
<td class="serial-cell">
<xsl:if test="$_dsTxnArray/attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'] != ''">
<xsl:value-of select="concat(', ', $_dsTxnArray/attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'])"/>
</xsl:if>
</td>
</tr>
</xsl:for-each>
</tbody>
</table>
</div>
</td>
<!--  Service Period Duration - Mirroring Master.xsl second column  -->
<td class="table-cell text-center normal-text">
<xsl:choose>
<xsl:when test="$ServiceDuration>'0'">
<xsl:value-of select="$ServiceDuration"/>
<xsl:choose>
<xsl:when test="$ServiceDuration = '1'">
<xsl:value-of select="' Month'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="' Months'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$_dsSub1/serviceDuration_l_c"/>
<xsl:choose>
<xsl:when test="$_dsSub1/serviceDuration_l_c = '1'">
<xsl:value-of select="' Month'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="' Months'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</td>
<!--  Service Period Start Date - Mirroring Master.xsl third column  -->
<td class="table-cell text-center normal-text">
<xsl:choose>
<xsl:when test="$ServiceDuration>'0'">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($ServiceStartDate, 1, 10)"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($_dsSub1/serviceStartDate_l_c, 1, 10)"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</td>
<!--  Service Period End Date - Mirroring Master.xsl fourth column  -->
<td class="table-cell text-center normal-text">
<xsl:choose>
<xsl:when test="$ServiceDuration>'0'">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($ServiceEndDate, 1, 10)"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($_dsSub1/serviceEndDate_l_c, 1, 10)"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</td>
<!--  Conditional Pricing Columns  -->
<xsl:if test="$COLUMN97146a5d-d8d0-43a1-9c13-84344296d864='true'">
<td class="table-cell currency">
<xsl:call-template name="currencyFormattedPrice">
<xsl:with-param name="price" select="$_dsSub1/extendedListPrice_l_c"/>
<xsl:with-param name="align" select="'right'"/>
<xsl:with-param name="fontSize" select="'10pt'"/>
<xsl:with-param name="fontWeight" select="'normal'"/>
</xsl:call-template>
</td>
</xsl:if>
<xsl:if test="$COLUMN70f9dcc8-13e3-468a-ab57-a5ea0d9c03b7='true'">
<td class="table-cell currency">
<!-- RAJ-Corrected the condition: fixed parameter name from 'lineItem' to 'lineNode' to match template parameter -->
<xsl:call-template name="currencyFormattedPrice">
<xsl:with-param name="price">
<xsl:call-template name="getExtendedNetPrice">
<xsl:with-param name="lineNode" select="$_dsSub1"/>
</xsl:call-template>
</xsl:with-param>
<xsl:with-param name="align" select="'right'"/>
<xsl:with-param name="fontSize" select="'10pt'"/>
<xsl:with-param name="fontWeight" select="'normal'"/>
</xsl:call-template>
</td>
</xsl:if>
</tr>
</xsl:for-each>
<!--  Renewal Totals Row - Mirroring Master.xsl logic  -->
<tr>
<td class="table-cell text-right section-header" colspan="5">Renewals Grand Total:</td>
<!--  Master.xsl RenewalTotalCalculation Variable  -->
<xsl:variable name="RenewalTotalCalculation" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and lineType_l = 'MODEL' and renewalIndicator_l_c = 'Y' and ./item_l/_part_number = 'SES-SYSTEM']"/>
<!--  Total Ext. List Price (conditional)  -->
<xsl:if test="$COLUMN97146a5d-d8d0-43a1-9c13-84344296d864='true'">
<td class="table-cell currency bold-text">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="sum($RenewalTotalCalculation/extendedListPrice_l_c)"/>
</xsl:call-template>
</td>
</xsl:if>
<!--  Total Ext. Net Price (conditional with tier support)  -->
<xsl:if test="$COLUMN70f9dcc8-13e3-468a-ab57-a5ea0d9c03b7='true'">
<td class="table-cell currency bold-text">
<xsl:variable name="extNetPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($RenewalTotalCalculation/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($RenewalTotalCalculation/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($RenewalTotalCalculation/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="-1"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="$extNetPrice"/>
</xsl:call-template>
</td>
</xsl:if>
</tr>
</tbody>
</table>
</div>
</xsl:if>
<!--  End count($renewalModelLines) > 0  -->
</xsl:if>
<!--  End serviceRenewal_t_c != ''  -->
<!--  Detailed Section Header - Mirroring FO section structure  -->
<div class="section-break">
<div class="section-header">Product Details</div>
<div class="spacing-1pt"> </div>
</div>
<!--  For renewal quotes, loop through SERVICE lines (not MODEL) to show detailed sections  -->
<!--  For renewal quotes, show detailed services - one section per SERVICE line  -->
<!--  Include all CS- services regardless of lineType_l field since it's inconsistently populated  -->
<xsl:for-each select="//document[normalize-space(./@data_type)='3' and ./renewalIndicator_l_c = 'Y' and (./lineType_l = 'SERVICE' or starts-with(./item_l/_part_number, 'CS-')) and ./doNotPrintFlag_l_c != 'Y']">
<xsl:sort select="./@_document_number" data-type="number" order="ascending"/>
<!--  Get parent MODEL line using modelReferenceLineID_l_c  -->
<xsl:variable name="modelReferenceID" select="./modelReferenceLineID_l_c"/>
<xsl:variable name="parentMODEL" select="exsl:node-set(//document[ normalize-space(./@data_type)='3' and ./lineType_l = 'MODEL' and ./lineItemNumber_l_c = $modelReferenceID ])"/>
<!--  Get the MODEL line with service period data (may be data_type='2')  -->
<xsl:variable name="servicePeriodMODEL" select="exsl:node-set(//document[ ./lineType_l = 'MODEL' and ./virtualConfigName_l_c = $parentMODEL/virtualConfigName_l_c ])"/>
<xsl:variable name="configID" select="$parentMODEL/virtualConfigName_l_c"/>
<xsl:variable name="modelName">
<xsl:choose>
<!--  First try: Use model_l/_model_bom with special Renewal handling  -->
<xsl:when test="$parentMODEL/model_l/_model_bom != ''">
<xsl:choose>
<xsl:when test="$parentMODEL/model_l/_model_name = 'Renewal Products'">
<!--  Extract text before 'Renewal' and add ' Renewal Services'  -->
<xsl:value-of select="concat( substring-before($parentMODEL/model_l/_model_bom, 'Renewal'), ' Renewal Services' )"/>
</xsl:when>
<xsl:otherwise>
<!--  Use full model_bom + ' Renewal Services'  -->
<xsl:value-of select="concat($parentMODEL/model_l/_model_bom, ' Renewal Services')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<!--  Fallback 1: partDescription_l_c  -->
<xsl:when test="$parentMODEL/partDescription_l_c != ''">
<xsl:value-of select="$parentMODEL/partDescription_l_c"/>
</xsl:when>
<!--  Fallback 2: item_l/_part_custom_field8  -->
<xsl:when test="$parentMODEL/item_l/_part_custom_field8 != ''">
<xsl:value-of select="$parentMODEL/item_l/_part_custom_field8"/>
</xsl:when>
<!--  Final fallback: topModel_l_c + ' Renewal'  -->
<xsl:otherwise>
<xsl:value-of select="$parentMODEL/topModel_l_c"/>
Renewal
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  NetApp Services Header  -->
<div style="margin-top: 20px; margin-bottom: 10px;">
<div class="section-header">NetApp Services</div>
</div>
<!--  Config ID  -->
<div class="section-header section-break">
Config#
<xsl:value-of select="$configID"/>
</div>
<!--  Configuration Comments (if present)  -->
<xsl:if test="$parentMODEL/comment_l_c != ''">
<div style="font-size: 10pt; margin-bottom: 10px;">
<strong>Configuration Comments:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$parentMODEL/comment_l_c"/>
</div>
</xsl:if>
<!--  Model Name (e.g., "FAS 8300A Renewal")  -->
<div style="font-size: 13pt; font-weight: bold; margin-bottom: 10px;">
<xsl:value-of select="$modelName"/>
</div>
<!--  Services Section with conditional Estimated label  -->
<div style="margin-bottom: 10px;">
<div class="section-header">Services</div>
<!--  Show 'Estimated' only if PVR not approved  -->
<xsl:variable name="pvrStatus" select="//document[@document_var_name='transaction']/pvrStatus_t_c"/>
<xsl:if test="not($pvrStatus = 'Approved' or $pvrStatus = 'Approval Not Required' or $pvrStatus = 'Pre Approved')">
<p style="font-style: italic;">Estimated</p>
</xsl:if>
</div>
<!--  Services Table - Mirroring FO table structure  -->
<table class="main-table">
<colgroup>
<col class="col-200"/>
<col class="col-300"/>
<col class="col-100"/>
<col class="col-150"/>
<col class="col-100"/>
<col class="col-150"/>
<col class="col-150"/>
</colgroup>
<thead>
<tr>
<th class="table-cell text-left product-name">Part Number</th>
<th class="table-cell text-left product-name">Product Description</th>
<th class="table-cell text-center product-name">Ext. Qty</th>
<th class="table-cell text-right product-name">Unit List Price</th>
<th class="table-cell text-right product-name">Disc%</th>
<th class="table-cell text-right product-name">Unit Net Price</th>
<th class="table-cell text-right product-name">Ext. Net Price</th>
</tr>
</thead>
<tbody>
<tr style="border-top: 1px solid #949494;">
<!--  Part Number  -->
<td style="padding: 4px;">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<!--  Product Description with Discount Category (Multi-line format)  -->
<td style="padding: 4px;">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<!--  Discount Category Code - Dynamic or Legacy based on catCodes_t_c  -->
<xsl:variable name="catCodesMode" select="//document[@document_var_name='transaction']/catCodes_t_c"/>
<xsl:choose>
<!--  Dynamic Cat Code Mode  -->
<xsl:when test="$catCodesMode = 'dynamic'">
<xsl:variable name="serviceLines" select="exsl:node-set(//document[ normalize-space(./@data_type)='3' and ./cPQVirtualPart_l_c = 'CSITEMCHILD' and ./modelReferenceLineID_l_c = ./lineItemNumber_l_c ])"/>
<xsl:variable name="dynamicCat">
<xsl:choose>
<xsl:when test="$serviceLines/dynamicCatCode_l_c != ''">
<xsl:value-of select="$serviceLines/dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:if test="$dynamicCat != ''">
<strong> [Discount Cat: </strong>
<xsl:value-of select="$dynamicCat"/>
<strong>]</strong>
</xsl:if>
</xsl:when>
<!--  Legacy Cat Code Mode  -->
<xsl:when test="$catCodesMode = 'legacy'">
<xsl:variable name="serviceLines" select="exsl:node-set(//document[ normalize-space(./@data_type)='3' and ./cPQVirtualPart_l_c = 'CSITEMCHILD' and ./modelReferenceLineID_l_c = ./lineItemNumber_l_c ])"/>
<xsl:variable name="legacyCat">
<xsl:choose>
<xsl:when test="$serviceLines/item_l/_part_custom_field463 != ''">
<xsl:value-of select="$serviceLines/item_l/_part_custom_field463"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:if test="$legacyCat != ''">
<strong> [Discount Cat: </strong>
<xsl:value-of select="$legacyCat"/>
<strong>]</strong>
</xsl:if>
</xsl:when>
<!--  Default: Show dynamic if available  -->
<xsl:otherwise>
<xsl:if test="./dynamicCatCode_l_c != '' or ./item_l/_part_custom_field463 != ''">
<strong> [Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</td>
<!--  Extended Quantity  -->
<td class="table-cell text-center normal-text">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<!--  Unit List Price  -->
<td class="table-cell currency">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<!--  Discount %  -->
<td class="table-cell text-right normal-text">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<!--  Unit Net Price  -->
<td class="table-cell currency">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<!--  Extended Net Price  -->
<td class="table-cell currency">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</tbody>
</table>
<!--  Serial Number and Service Period Info - Get comma-separated serial numbers from parent MODEL or child lines  -->
<div style="margin: 10px 0; font-size: 10pt;">
<strong>Serial Number: </strong>
<xsl:variable name="serialNumberList">
<xsl:choose>
<xsl:when test="$parentMODEL/_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<!--  Get serial numbers from array and display comma-separated  -->
<xsl:for-each select="$parentMODEL/_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<xsl:value-of select="./attribute[@var_name='serialNumber_serialNumber_Array_l_c']"/>
<xsl:if test="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']!=''">
<xsl:text>, </xsl:text>
<xsl:value-of select="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']"/>
</xsl:if>
<xsl:if test="position() != last()">
<xsl:text>, </xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./serialNumber_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Display serial number list from array or NonSES child lines  -->
<xsl:choose>
<xsl:when test="$serialNumberList != ''">
<xsl:value-of select="$serialNumberList"/>
</xsl:when>
<xsl:otherwise>
<!--  Fallback: Get serial number from child CSITEMCHILD lines (NonSES)  -->
<xsl:variable name="childLines" select="exsl:node-set(//document[ normalize-space(./@data_type)='3' and (./lineItemNumber_l_c = ./modelReferenceLineID_l_c or ./item_l/_part_number = ./coveredItem_l_c) and ./virtualLineID_l_c = ./virtualLineID_l_c ])"/>
<xsl:value-of select="$childLines/serialNumber_l_c"/>
</xsl:otherwise>
</xsl:choose>
<br/>
<br/>
<!--  Linked Quote (for add-ons/amendments)  -->
<xsl:if test="./addOnOriginalQuoteNumberSearch_l_c != ''">
<strong>Linked Quote : </strong>
<xsl:value-of select="./addOnOriginalQuoteNumberSearch_l_c"/>
<br/>
<br/>
</xsl:if>
<strong>Includes : </strong>
Renewals
<br/>
<br/>
<strong>Service Period Start Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($servicePeriodMODEL/serviceStartDate_l_c, 1, 10)"/>
</xsl:call-template>
<xsl:text> </xsl:text>
<strong>Service Period End Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($servicePeriodMODEL/serviceEndDate_l_c, 1, 10)"/>
</xsl:call-template>
<br/>
<!--  Warranty Expiration Date (if present)  -->
<xsl:if test="$servicePeriodMODEL/warrantyEndDate_l_c != ''">
<strong>Warranty Expiration Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring($servicePeriodMODEL/warrantyEndDate_l_c, 1, 10)"/>
</xsl:call-template>
<br/>
</xsl:if>
<!--  Service Period Duration with Month/Months logic  -->
<xsl:text> </xsl:text>
<strong>Service Period Duration:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$servicePeriodMODEL/serviceDuration_l_c"/>
<xsl:choose>
<xsl:when test="$servicePeriodMODEL/serviceDuration_l_c = '1'"> Month</xsl:when>
<xsl:otherwise> Months</xsl:otherwise>
</xsl:choose>
<br/>
<xsl:if test="./installedAtAddress_l_c!='' or $servicePeriodMODEL/installedAtAddress_l_c!=''">
<strong>Service Address:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="./installedAtAddress_l_c!=''">
<xsl:value-of select="./installedAtAddress_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="./installedAtStateProvince_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="./installedAtCountry_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="./installedAtPostalCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$servicePeriodMODEL/installedAtAddress_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="$servicePeriodMODEL/installedAtStateProvince_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="$servicePeriodMODEL/installedAtCountry_l_c"/>
<xsl:text> </xsl:text>
<xsl:value-of select="$servicePeriodMODEL/installedAtPostalCode_l_c"/>
</xsl:otherwise>
</xsl:choose>
<br/>
</xsl:if>
<!--  Quick Ship Messages (if present)  -->
<xsl:if test="./quickShipMessages_l_c != ''">
<br/>
<strong>Message:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="./quickShipMessages_l_c = 'SSP for:'">
<xsl:text>SSP for: </xsl:text>
<xsl:value-of select="./coveredItem_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./quickShipMessages_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
<!--  Line-Level Comments (if present)  -->
<xsl:if test="./comment_l_c != ''">
<br/>
<strong>Comment : </strong>
<xsl:value-of select="./comment_l_c"/>
</xsl:if>
</div>
<!--  Service Details Table (showing service component details)  -->
<!--  Exclude REINST part numbers from detailed sections  -->
<xsl:if test="not(contains(./item_l/_part_number, 'REINST'))">
<div style="margin: 15px 0;">
<strong>Service Details</strong>
<table style="width: 100%; border-collapse: collapse; margin-top: 5px;">
<thead>
<tr style="border-bottom: 1px solid #ccc;">
<th style="text-align: left; padding: 4px; width: 50%;">Product</th>
<th style="text-align: center; padding: 4px; width: 10%;">Qty</th>
<th style="text-align: center; padding: 4px; width: 15%;">Service Start Date</th>
<th style="text-align: center; padding: 4px; width: 15%;">Service End Date</th>
<th style="text-align: center; padding: 4px; width: 10%;">Duration</th>
</tr>
</thead>
<tbody>
<tr>
<td style="padding: 4px;">
<xsl:value-of select="./item_l/_part_desc"/>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(./serviceStartDate_l_c, 1, 10)"/>
</xsl:call-template>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(./serviceEndDate_l_c, 1, 10)"/>
</xsl:call-template>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:value-of select="./serviceDuration_l_c"/>
</td>
</tr>
</tbody>
</table>
</div>
<!--  System Details (from renewalAssets_Array on parent MODEL) with Deduplication  -->
<!--  Exclude REINST part numbers  -->
<div style="margin: 15px 0;">
<strong>System Details:</strong>
<table style="width: 100%; border-collapse: collapse; margin-top: 5px;">
<thead>
<tr style="border-bottom: 1px solid #ccc;">
<th style="text-align: left; padding: 4px; width: 60%;">Product</th>
<th style="text-align: center; padding: 4px; width: 20%;">Qty</th>
<th style="text-align: center; padding: 4px; width: 20%;">EOSL Date</th>
</tr>
</thead>
<tbody>
<!--  Deduplicate by creating unique key: partDescription + quantity + eOSLDate  -->
<xsl:for-each select="$parentMODEL/_commerce_array_set_attr_info[@setName='renewalAssets_Array_l_c']/_array_set_row">
<xsl:variable name="currentKey" select="concat( ./attribute[@var_name='partDescription_renewalAssets_Array_l_c'], '+', ./attribute[@var_name='quantity_renewalAssets_Array_l_c'], '+', ./attribute[@var_name='eOSLDate_renewalAssets_Array_l_c'] )"/>
<!--  Only show if this is the first occurrence of this key  -->
<xsl:variable name="precedingKeys">
<xsl:for-each select="preceding-sibling::_array_set_row">
<xsl:value-of select="concat( ./attribute[@var_name='partDescription_renewalAssets_Array_l_c'], '+', ./attribute[@var_name='quantity_renewalAssets_Array_l_c'], '+', ./attribute[@var_name='eOSLDate_renewalAssets_Array_l_c'] )"/>
<xsl:text>|</xsl:text>
</xsl:for-each>
</xsl:variable>
<xsl:if test="not(contains($precedingKeys, concat($currentKey, '|')))">
<tr>
<td style="padding: 4px;">
<xsl:value-of select="./attribute[@var_name='partDescription_renewalAssets_Array_l_c']"/>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:value-of select="./attribute[@var_name='quantity_renewalAssets_Array_l_c']"/>
</td>
<td style="text-align: center; padding: 4px;">
<xsl:value-of select="./attribute[@var_name='eOSLDate_renewalAssets_Array_l_c']"/>
</td>
</tr>
</xsl:if>
</xsl:for-each>
</tbody>
</table>
<p style="font-size: 9pt; font-style: italic; margin-top: 5px;"> Please see the quote footer for additional information on EOS limitations. </p>
</div>
</xsl:if>
<!--  End REINST exclusion  -->
<!--  Don't show subtotal per service - only at MODEL/config level  -->
</xsl:for-each>
<!--  Show Estimated Services Subtotals per MODEL (Config)  -->
<xsl:for-each select="//document[normalize-space(./@data_type)='3' and ./lineType_l = 'MODEL' and ./item_l/_part_number = 'SES-SYSTEM']">
<xsl:sort select="./@_document_number" data-type="number" order="ascending"/>
<xsl:variable name="lineItemNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="childServiceLines" select="exsl:node-set(//document[ normalize-space(./@data_type)='3' and ./modelReferenceLineID_l_c = $lineItemNumber and (./lineType_l = 'SERVICE' or starts-with(./item_l/_part_number, 'CS-')) and ./doNotPrintFlag_l_c != 'Y' ])"/>
<!--  Services Subtotal per Config with conditional 'Estimated' label  -->
<xsl:variable name="pvrStatus" select="//document[@document_var_name='transaction']/pvrStatus_t_c"/>
<table style="width: 100%; border-collapse: collapse; margin: 15px 0;">
<tr style="border-top: 1px solid #949494; border-bottom: 1px solid #949494;">
<td style="padding: 8px; font-weight: bold;">
<xsl:choose>
<xsl:when test="$pvrStatus = 'Approved' or $pvrStatus = 'Approval Not Required' or $pvrStatus = 'Pre Approved'"> NetApp Services Sub Total: </xsl:when>
<xsl:otherwise> Estimated NetApp Services Sub Total: </xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; text-align: right;">
<strong>Ext. List Price:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="sum($childServiceLines/extendedListPrice_l_c)"/>
</xsl:call-template>
</td>
<td style="padding: 8px; text-align: right;">
<strong>Discount:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td style="padding: 8px; text-align: right;">
<strong>Ext. Net Price:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="sum($childServiceLines/extendedNetPrice_l_c)"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:for-each>
<!--  SES-SYSTEM Service Period Logic from Master.xsl  -->
<!--  Process MODEL lines with their corresponding config labels  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and lineType_l='MODEL' and doNotPrintFlag_l_c != 'Y' and (extendedListPrice_l_c != '0.0' or extendedNetPrice_l_c != '0.0')]">
<xsl:sort select="./_parent_doc_number" data-type="number"/>
<xsl:sort select="./@_document_number" order="ascending"/>
<!--  Only process if parent is a SUBROOT  -->
<xsl:if test="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and cPQVirtualPart_l_c='SUBROOT' and _document_number = current()/_parent_doc_number]">
<!--  Get the parent SUBROOT's config name for this MODEL  -->
<xsl:variable name="parentSubroot" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and cPQVirtualPart_l_c='SUBROOT' and _document_number = current()/_parent_doc_number]"/>
<xsl:variable name="virtualLineID" select="$parentSubroot/virtualLineID_l_c"/>
<xsl:variable name="parentConfigName" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and cPQVirtualPart_l_c='ROOT' and virtualLineID_l_c=$virtualLineID]/virtualConfigName_l_c"/>
<!--  Config Label - display parent ROOT config name for each table  -->
<div class="config-label">
<xsl:value-of select="$parentConfigName"/>
</div>
<xsl:variable name="lineNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="bom_level" select="./_line_bom_level"/>
<xsl:variable name="top_model_name" select="./topModel_l_c"/>
<!--  Use direct XPath expressions to avoid RTREEFRAG issues in Apache Xalan  -->
<!--  Filter lines by category and summaryPrint flag using direct XPath  -->
<xsl:variable name="platformLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and (summaryPrintGrouping_l_c='Platform' or summaryPrintGrouping_l_c='PLATFORM') and summaryPrint_l_c='Y'])"/>
<xsl:variable name="capacityLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Capacity' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="networkingLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPrintGrouping_l_c='Networking' or summaryPrintGrouping_l_c='Network Adapters') and summaryPrint_l_c='Y'])"/>
<xsl:variable name="switchesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Switches' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="BridgesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Bridges' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="SoftwareLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and summaryPrintGrouping_l_c='Software' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="subscriptionLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='SUBSCRIPTION' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="otherserviceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPrintGrouping_l_c='SERVICES' or summaryPrintGrouping_l_c='Services') and summaryPrint_l_c='Y'])"/>
<xsl:variable name="AddserviceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Additional Service' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="ProfserviceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Professional Services' and summaryPrint_l_c='Y'])"/>
<xsl:variable name="dataNodesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and summaryPrintGrouping_l_c='Data Compute Node' and summaryPrint_l_c='Y'])"/>
<!--  Price grouping lines (for aggregating prices) using direct XPath  -->
<xsl:variable name="platformpriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Platform' or summaryPriceGrouping_l_c='PLATFORM' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Platform') or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='PLATFORM'))])"/>
<xsl:variable name="capacitypriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Capacity' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Capacity'))])"/>
<xsl:variable name="networkingpricesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Networking' or summaryPriceGrouping_l_c='Network Adapters' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Networking') or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Network Adapters'))])"/>
<xsl:variable name="switchespricesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Switches' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Switches'))])"/>
<xsl:variable name="BridgespricesLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Bridges' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Bridges'))])"/>
<xsl:variable name="SoftwarepriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Software' or summaryPriceGrouping_l_c='SOFTWARE' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Software') or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='SOFTWARE'))])"/>
<xsl:variable name="subscriptionpriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='SUBSCRIPTION' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='SUBSCRIPTION'))])"/>
<xsl:variable name="otherservicepriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='SERVICES' or summaryPriceGrouping_l_c='Services' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='SERVICES') or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Services'))])"/>
<xsl:variable name="AddservicepriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Additional Service' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Additional Service'))])"/>
<xsl:variable name="ProfservicepriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Professional Services' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Professional Services'))])"/>
<xsl:variable name="dataNodespriceLines" select="exsl:node-set(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and topModelLineID_l_c=$lineNumber and lineType_l!='MODEL' and cPQVirtualPart_l_c!='CSITEMCHILD' and bundleChild_l_c='false' and (summaryPriceGrouping_l_c='Data Compute Node' or (summaryPriceGrouping_l_c='' and summaryPrintGrouping_l_c='Data Compute Node'))])"/>
<!--  System Group Box  -->
<div class="system-group">
<div class="system-header">
<xsl:choose>
<xsl:when test="./configType_l_c='ADD ON' and ./hasAddOnStorage_l_c='STORAGE'">
<xsl:value-of select="./item_l/_part_number"/>
<xsl:text> (Storage Addendum)</xsl:text>
</xsl:when>
<xsl:when test="./configType_l_c='ADD ON' and ./hasAddOnStorage_l_c!='STORAGE'">
<xsl:value-of select="$top_model_name"/>
<xsl:text> (Addendum)</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$top_model_name"/>
</xsl:otherwise>
</xsl:choose>
</div>
<!--  Gap #4: Serial Number Display  -->
<div style="font-family: Arial, sans-serif; font-size: 10px; margin-top: 5px; padding: 2px 5px;">
<!--  Build serial number list from array  -->
<xsl:variable name="serialNumberList">
<xsl:variable name="tmpSerialNumberList">
<xsl:for-each select="./_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
<xsl:if test="./attribute[@var_name='serialNumber_serialNumber_Array_l_c']!=''">
<xsl:choose>
<xsl:when test="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']!=''">
<xsl:value-of select="concat(./attribute[@var_name='serialNumber_serialNumber_Array_l_c'], ', ', ./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'], ', ')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat(./attribute[@var_name='serialNumber_serialNumber_Array_l_c'], ', ')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<xsl:value-of select="substring($tmpSerialNumberList, 1, string-length($tmpSerialNumberList)-2)"/>
</xsl:variable>
<!--  Display serial numbers or linked quote  -->
<xsl:choose>
<xsl:when test="$serialNumberList!=''">
<strong>Serial Number: </strong>
<xsl:value-of select="$serialNumberList"/>
</xsl:when>
<xsl:when test="./serialNumber_l_c!='' and ./addOnOriginalLineNumberSearch_l_c=''">
<strong>Serial Number: </strong>
<xsl:value-of select="./serialNumber_l_c"/>
</xsl:when>
<xsl:when test="./addOnOriginalQuoteNumberSearch_l_c!=''">
<strong>Linked Quote: </strong>
<xsl:value-of select="concat(./addOnOriginalQuoteNumberSearch_l_c, '-', ./addOnOriginalLineNumberSearch_l_c)"/>
</xsl:when>
<xsl:otherwise>
<!-- No serial number or quote linkage available -->
<span class="no-serial">No Serial Number</span>
</xsl:otherwise>
</xsl:choose>
</div>
<!--  Summary Table - shown when SimplifiedFlag != 'false'  -->
<xsl:if test="$SimplifiedFlag != 'false'">
<table class="category-table">
<!--  Product Section Header  -->
<xsl:if test="count($platformLines) > 0 or count($capacityLines) > 0 or count($networkingLines) > 0 or count($switchesLines) > 0 or count($BridgesLines) > 0 or count($dataNodesLines) > 0">
<tr class="bg-mg">
<td class="category-label"/>
<td class="category-desc"/>
<td class="category-price">
<strong>Estimated</strong>
</td>
</tr>
<tr class="section-header">
<td class="category-label">Product</td>
<td class="category-desc"/>
<td class="category-price">Ext. Net Price</td>
</tr>
</xsl:if>
<!--  Platform  -->
<xsl:if test="count($platformLines) > 0">
<tr>
<td class="category-label">Platform:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$platformLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="platformTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($platformpriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($platformpriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($platformpriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($platformpriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($platformTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Capacity - Dynamically calculated  -->
<xsl:if test="count($capacityLines) > 0">
<tr>
<td class="category-label">Capacity:</td>
<td class="category-desc">
<!--  Calculate SSD and HDD capacity dynamically  -->
<xsl:variable name="ssdCapacity">
<xsl:call-template name="sumDriveCapacity">
<xsl:with-param name="rows" select="$capacityLines[contains(item_l/_part_custom_field284, 'SSD')]"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="hdCapacity">
<xsl:call-template name="sumDriveCapacity">
<xsl:with-param name="rows" select="$capacityLines[contains(item_l/_part_custom_field284, 'HDD')]"/>
</xsl:call-template>
</xsl:variable>
<!--  Display capacity based on what's available  -->
<xsl:choose>
<xsl:when test="number($hdCapacity) > 0 and number($ssdCapacity) > 0">
<xsl:value-of select="concat($hdCapacity, 'TB HDD storage, ', $ssdCapacity, 'TB SSD storage')"/>
</xsl:when>
<xsl:when test="number($hdCapacity) > 0">
<xsl:value-of select="concat($hdCapacity, 'TB HDD storage')"/>
</xsl:when>
<xsl:when test="number($ssdCapacity) > 0">
<xsl:value-of select="concat($ssdCapacity, 'TB SSD storage')"/>
</xsl:when>
<xsl:otherwise>
<!--  Fallback to summaryPrintLabel if calculation fails  -->
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$capacityLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</td>
<td class="category-price">
<xsl:variable name="capacityTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($capacitypriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($capacitypriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($capacitypriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($capacitypriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($capacityTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Data Compute Node  -->
<xsl:if test="count($dataNodesLines) > 0">
<tr>
<td class="category-label">Data Compute Node:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$dataNodesLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="dataNodesTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($dataNodespriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($dataNodespriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($dataNodespriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($dataNodespriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($dataNodesTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Networking  -->
<xsl:if test="count($networkingLines) > 0">
<tr>
<td class="category-label">Networking:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$networkingLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="networkingpricesLinesTotal">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($networkingpricesLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($networkingpricesLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($networkingpricesLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($networkingpricesLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($networkingpricesLinesTotal)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Switches  -->
<xsl:if test="count($switchesLines) > 0">
<tr>
<td class="category-label">Switches:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$switchesLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="switchespricesLinesTotal">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($switchespricesLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($switchespricesLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($switchespricesLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($switchespricesLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($switchespricesLinesTotal)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Bridges  -->
<xsl:if test="count($BridgesLines) > 0">
<tr>
<td class="category-label">Bridges:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$BridgesLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="BridgespricesLinesTotal">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($BridgespricesLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($BridgespricesLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($BridgespricesLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($BridgespricesLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($BridgespricesLinesTotal)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Software Section  -->
<xsl:if test="count($SoftwareLines) > 0">
<tr class="section-header">
<td class="category-label">Software</td>
<td class="category-desc"/>
<td class="category-price">Ext. Net Price</td>
</tr>
<tr>
<td class="category-label">Software:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$SoftwareLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="SoftwareTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($SoftwarepriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($SoftwarepriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($SoftwarepriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($SoftwarepriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($SoftwareTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Subscription Section  -->
<xsl:if test="count($subscriptionLines) > 0">
<tr class="section-header">
<td class="category-label">Subscription</td>
<td class="category-desc"/>
<td class="category-price">Ext. Net Price</td>
</tr>
<tr>
<td class="category-label">Subscription:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$subscriptionLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
<!--  Gap #7: Subscription Duration  -->
<xsl:if test="./subscriptionDuration_l_c!='' and ./subscriptionDuration_l_c!='0'">
<br/>
<strong>Duration: </strong>
<xsl:value-of select="./subscriptionDuration_l_c"/>
<xsl:choose>
<xsl:when test="./subscriptionDuration_l_c='1'"> Month</xsl:when>
<xsl:otherwise> Months</xsl:otherwise>
</xsl:choose>
</xsl:if>
</td>
<td class="category-price">
<xsl:variable name="subscriptionTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($subscriptionpriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($subscriptionpriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($subscriptionpriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($subscriptionpriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($subscriptionTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Services Section Header  -->
<xsl:if test="count($otherserviceLines) > 0 or count($AddserviceLines) > 0 or count($ProfserviceLines) > 0">
<tr class="section-header">
<td class="category-label">Services</td>
<td class="category-desc"/>
<td class="category-price">Ext. Net Price</td>
</tr>
<!--  Duration  -->
<tr>
<td class="category-label">Duration:</td>
<td class="category-desc">60 Months</td>
<td class="category-price"/>
</tr>
</xsl:if>
<!--  Service  -->
<xsl:if test="count($otherserviceLines) > 0">
<tr>
<td class="category-label">Service:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$otherserviceLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="otherserviceTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($otherservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($otherservicepriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($otherservicepriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($otherservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($otherserviceTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Additional Service  -->
<xsl:if test="count($AddserviceLines) > 0">
<tr>
<td class="category-label">Additional Service:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$AddserviceLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="AddserviceTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($AddservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($AddservicepriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($AddservicepriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($AddservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($AddserviceTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Professional Services  -->
<xsl:if test="count($ProfserviceLines) > 0">
<tr>
<td class="category-label">Professional Services:</td>
<td class="category-desc">
<xsl:call-template name="createCommaSeparatedList">
<xsl:with-param name="list" select="$ProfserviceLines/summaryPrintLabel_l_c"/>
</xsl:call-template>
</td>
<td class="category-price">
<xsl:variable name="ProfserviceTotalPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($ProfservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($ProfservicepriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($ProfservicepriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($ProfservicepriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($ProfserviceTotalPrice)"/>
</xsl:call-template>
</td>
</tr>
</xsl:if>
<!--  Calculate all priceLines (union of all price categories)  -->
<xsl:variable name="allPriceLines" select="$platformpriceLines | $capacitypriceLines | $networkingpricesLines | $switchespricesLines | $BridgespricesLines | $SoftwarepriceLines | $subscriptionpriceLines | $otherservicepriceLines | $AddservicepriceLines | $ProfservicepriceLines | $dataNodespriceLines"/>
<!--  Subtotal Row  -->
<tr class="subtotal-row">
<!--  Calculate totals at tr level for use across all td elements  -->
<xsl:variable name="allListPriceTotal" select="sum($allPriceLines/extendedListPrice_l_c)"/>
<xsl:variable name="allPricesNetTotal">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($allPriceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($allPriceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($allPriceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($allPriceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<td class="category-label" style="width: 15%;">
Estimated
<xsl:value-of select="$top_model_name"/>
Sub Total:
</td>
<td class="category-desc" style="width: 30%;">
Ext. List Price:
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="$allListPriceTotal"/>
</xsl:call-template>
</td>
<td style="width: 15%;">
Discount:
<xsl:value-of select="format-number((1 - number($allPricesNetTotal) div number($allListPriceTotal)) * 100, '0.00')"/>
%
</td>
<td class="category-price" style="width: 40%; white-space: nowrap;">
Ext. Net Price:
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($allPricesNetTotal)"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:if>
</div>

<!--  Detailed Line Items - shown when SimplifiedFlag = 'false'  -->
<xsl:if test="$SimplifiedFlag = 'false'">
<!--  Get the parent ROOT/SUBROOT document number for this MODEL  -->
<xsl:variable name="rootDocNumber" select="./_parent_doc_number"/>
<div class="detailed-section" style="margin-top: 20px; margin-bottom: 20px;">
<h3 class="h3" style="background-color: #E1E1E1; padding: 8px; border: 1px solid #949494; margin-bottom: 10px;">
Detailed Line Items
</h3>

<!--  Detailed line items table  -->
<table class="detailed-table" style="width: 100%; border-collapse: collapse;">
<tr style="background-color: #E1E1E1;">
<th style="padding: 8px; border: 1px solid #949494; text-align: left;">Part Number</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: left;">Description</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: center;">Qty</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: right;">Unit List Price</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: right;">Disc %</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: right;">Unit Net Price</th>
<th style="padding: 8px; border: 1px solid #949494; text-align: right;">Ext. Net Price</th>
</tr>

<!--  Loop through all detailed lines  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = $rootDocNumber and lineType_l != 'MODEL' and doNotPrintFlag_l_c != 'Y' and (extendedListPrice_l_c != '0.0' or extendedNetPrice_l_c != '0.0')]">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr>
<td style="padding: 8px; border: 1px solid #949494;">
<xsl:choose>
<xsl:when test="./item_l/_part_number/@display_value">
<xsl:value-of select="./item_l/_part_number/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./item_l/_part_number"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494;">
<xsl:choose>
<xsl:when test="./item_l/_part_desc/@display_value">
<xsl:value-of select="./item_l/_part_desc/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./item_l/_part_desc"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: center;">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: right;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: right;">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>%
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: right;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: right;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="./extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="./extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="./extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./extendedNetPrice_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:with-param>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</table>
</div>
</xsl:if>
</xsl:if>
</xsl:for-each>
<!--  Add Master.xsl Business Logic for each config  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and cPQVirtualPart_l_c='SUBROOT']">
<xsl:variable name="configNumber" select="./virtualConfigName_l_c"/>
<xsl:call-template name="renderEnhancedMasterLogic">
<xsl:with-param name="configNumber" select="$configNumber"/>
<xsl:with-param name="transactionData" select="$_dsMain1"/>
</xsl:call-template>
</xsl:for-each>
<!--  Grand Total Section #1: Before Detailed Section  -->
<!--  Shows for: Non-Keystone quotes OR Keystone Amend/Renew  -->
<xsl:if test="($_dsMain1/keyStone_t_c!='Yes') or ($_dsMain1/keyStone_t_c = 'Yes' and ($_dsMain1/sMPType_t_c = 'Amend' or $_dsMain1/sMPType_t_c = 'Renew'))">
<div class="grand-total-section" style="margin-top: 30px;">
<!--  Calculate grand totals with pricing tier support - Using Master.xsl approach  -->
<xsl:variable name="grandNetPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$_dsMain1/quoteNetPrice_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$_dsMain1/quoteNetPriceSecondTier_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$_dsMain1/quoteNetPriceThirdTier_t_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$_dsMain1/quoteNetPrice_t_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="grandListPrice" select="$_dsMain1/quoteListPrice_t_c"/>
<table>
<tr class="grand-total-row">
<td style="width: 15%;">List Grand Total:</td>
<td style="width: 35%;"/>
<td style="width: 15%;"/>
<td style="width: 35%; text-align: right;"><xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="$grandListPrice"/>
</xsl:call-template>
</td>
</tr>
<tr class="grand-total-row">
<td style="width: 15%;">Total Discount:</td>
<td style="width: 35%;"/>
<td style="width: 15%;"/>
<td style="width: 35%; text-align: right;">
<xsl:variable name="discount">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$_dsMain1/quoteCurrentDiscount_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$_dsMain1/quoteCurrentDiscountSecondTier_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$_dsMain1/quoteCurrentDiscountEndCustomer_t_c"/>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="format-number($discount, '0.00')"/>%
</td>
</tr>
<tr class="grand-total-row">
<td style="width: 15%; border-top: 3px solid #000; padding-top: 8px;">Net Grand Total:</td>
<td style="width: 35%; border-top: 3px solid #000;"/>
<td style="width: 15%; border-top: 3px solid #000;"/>
<td style="width: 35%; text-align: right; border-top: 3px solid #000; padding-top: 8px;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($grandNetPrice)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
<!--  DETAILED PART LISTING SECTION  -->
<!--  Master.xsl Logic: Show detailed section ONLY if KeyStone=Yes OR (Non-KeyStone AND serviceRenewal != '100% Renewals')  -->
<xsl:if test="$_dsMain1/keyStone_t_c = 'Yes' or ($_dsMain1/keyStone_t_c != 'Yes' and $_dsMain1/serviceRenewal_t_c != '100% Renewals')">
<div class="section-header" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16px; font-weight: bold;">Detailed Section</h2>
</div>
<!--  Loop through each ROOT config to get Config ID  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and (_parent_doc_number = '' or cPQVirtualPart_l_c='ROOT' or cPQVirtualPart_l_c='SUBROOT')]">
<xsl:variable name="configID" select="./virtualConfigName_l_c"/>
<!--  Service Address from ROOT/SUBROOT document (matches PDF master template)  -->
<xsl:variable name="installedat" select="concat(./installedAtAddress_l_c,' ',./installedAtStateProvince_l_c,' ',./installedAtCountry_l_c,' ', ./installedAtPostalCode_l_c)"/>
<!--  SimplifiedFlag for conditional display modes  -->
<xsl:variable name="parentLoopDocNumber" select="./_parent_doc_number"/>
<xsl:variable name="SimplifiedFlag">
<xsl:choose>
<xsl:when test="cPQVirtualPart_l_c='SUBROOT'">
<xsl:value-of select="/transaction/data_xml/document[_document_number = $parentLoopDocNumber]/simplifiedPrinting_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./simplifiedPrinting_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!--  SMP Variables from Master.xsl  -->
<xsl:variable name="AutoRenew" select="./autoRenew_l_c"/>
<xsl:variable name="BillingFrequency" select="./billingFrequency_l_c"/>
<xsl:variable name="SelectedTech" select="./selectedTechnologies_l_c"/>
<xsl:variable name="smplines" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = ./_document_number and oRCL_ABO_ActionCode_l != 'DELETE' and downstreamFulfillment_l_c = 'SMP']"/>
<xsl:variable name="serviceDuration">
<xsl:choose>
<xsl:when test="$smplines/serviceDuration_l_c">
<xsl:value-of select="$smplines/serviceDuration_l_c"/>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Display Config ID  -->
<xsl:if test="$configID != ''">
<div style="margin-top: 15px; margin-bottom: 10px;">
<h3 style="font-size: 12pt; font-weight: bold;">
<xsl:value-of select="$configID"/>
</h3>
</div>
</xsl:if>
<!--  Loop through each MODEL in this ROOT/SUBROOT  -->
<!--  Include all MODELs except those with zero prices and doNotPrintFlag (e.g., SW-SMIRROR-CLD-ONTAP-ONE)  -->
<!--  Note: SMP lines are processed separately in their own section below  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = ./_document_number and lineType_l = 'MODEL' and doNotPrintFlag_l_c != 'Y' and (extendedListPrice_l_c != '0.0' or extendedNetPrice_l_c != '0.0')]">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="lineNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="bom_level" select="./_line_bom_level"/>
<xsl:variable name="top_model_name">
<xsl:choose>
<xsl:when test="./topModel_l_c != ''">
<xsl:value-of select="./topModel_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_number"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Select all component lines for this MODEL (without summaryPrint filter)  -->
<xsl:variable name="allComponentLines" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and (topModelLineID_l_c = $lineNumber or (modelReferenceLineID_l_c = $lineNumber and _line_bom_level > $bom_level)) and lineType_l != 'MODEL' and cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and bundleChild_l_c = 'false']"/>
<!--  Line grouping variables for SimplifiedFlag conditional display  -->
<xsl:variable name="allSubLines" select="$allComponentLines"/>
<xsl:variable name="platformLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and ( summaryPrintGrouping_l_c = 'Platform' or summaryPrintGrouping_l_c = 'PLATFORM') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasplatformLines" select="boolean(count($platformLines) > 0)"/>
<xsl:variable name="capacityLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and ( summaryPrintGrouping_l_c = 'Capacity') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hascapacityLines" select="boolean(count($capacityLines) > 0)"/>
<xsl:variable name="networkingLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false'  and (  summaryPrintGrouping_l_c = 'Networking' or summaryPrintGrouping_l_c = 'Network Adapters') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasnetworkingLines" select="boolean(count($networkingLines) > 0)"/>
<xsl:variable name="switchesLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and ( summaryPrintGrouping_l_c = 'Switches') and summaryPrint_l_c = 'Y' and not(item_l/_part_custom_field14  = 'MODEL SUB NETAPP' and doNotPrintFlag_l_c = 'Y')]"/>
<xsl:variable name="hasswitchesLines" select="boolean(count($switchesLines) > 0)"/>
<xsl:variable name="BridgesLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and ( summaryPrintGrouping_l_c = 'Bridges') and summaryPrint_l_c = 'Y' and not(item_l/_part_custom_field14  = 'MODEL SUB NETAPP' and doNotPrintFlag_l_c = 'Y')]"/>
<xsl:variable name="hasBridgessLines" select="boolean(count($BridgesLines) > 0)"/>
<xsl:variable name="dataNodesLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and ( summaryPrintGrouping_l_c = 'Data Compute Node') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasdataNodesLines" select="boolean(count($dataNodesLines) > 0)"/>
<xsl:variable name="otherhardwareLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and (printGrouping_l_c = 'HARDWARE' or printGrouping_l_c = 'PLATFORM' or printGrouping_l_c = 'STORAGE' or printGrouping_l_c = 'Hardware') and (summaryPrintGrouping_l_c = '' or summaryPrintGrouping_l_c = 'None') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasotherHardwareLines" select="boolean(count($otherhardwareLines) > 0)"/>
<xsl:variable name="SoftwareLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD'  and ( summaryPrintGrouping_l_c = 'Software') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasSoftwareLines" select="boolean(count($SoftwareLines) > 0)"/>
<xsl:variable name="OSLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD'  and ( summaryPrintGrouping_l_c = 'OS') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasOSLines" select="boolean(count($OSLines) > 0)"/>
<xsl:variable name="subscriptionLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and (summaryPrintGrouping_l_c = 'SUBSCRIPTION') and summaryPrint_l_c = 'Y' ]"/>
<xsl:variable name="hassubscriptionLines" select="boolean(count($subscriptionLines) > 0)"/>
<xsl:variable name="otherserviceLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false'  and ( summaryPrintGrouping_l_c = 'SERVICES' or summaryPrintGrouping_l_c = 'Services') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasothserviceLines" select="boolean(count($otherserviceLines) > 0)"/>
<xsl:variable name="AddserviceLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false' and (  summaryPrintGrouping_l_c = 'Additional Service') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasaddserviceLines" select="boolean(count($AddserviceLines) > 0)"/>
<xsl:variable name="ProfserviceLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and bundleChild_l_c = 'false'  and ( summaryPrintGrouping_l_c = 'Professional Services') and summaryPrint_l_c = 'Y']"/>
<xsl:variable name="hasprofserviceLines" select="boolean(count($ProfserviceLines) > 0)"/>
<!--  Storage line grouping variables - missing from Child.xsl  -->
<xsl:variable name="StorageplatformLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and bundleChild_l_c = 'false' and ( printGrouping_l_c = 'STORAGE' ) and (summaryPrintGrouping_l_c = 'Platform' or summaryPrintGrouping_l_c = 'PLATFORM')]"/>
<xsl:variable name="hasStorageplatformLines" select="boolean(count($StorageplatformLines) > 0)"/>
<xsl:variable name="StoragecapacityLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and bundleChild_l_c = 'false' and ( printGrouping_l_c = 'STORAGE' ) and (summaryPrintGrouping_l_c = 'Capacity')]"/>
<xsl:variable name="hasStoragecapacityLines" select="boolean(count($StoragecapacityLines) > 0)"/>
<!--  Categorize lines - separate Hardware (Platform/Networking) from Storage (Capacity)  -->
<!--  Hardware: Platform and Networking only (NOT Capacity - that goes in Storage)  -->
<xsl:variable name="hardwareLines" select="$allComponentLines[printGrouping_l_c = 'HARDWARE' or printGrouping_l_c = 'PLATFORM' or printGrouping_l_c = 'Hardware']"/>
<xsl:variable name="storageLines" select="$allComponentLines[printGrouping_l_c = 'STORAGE' or printGrouping_l_c = 'Storage']"/>
<xsl:variable name="softwareLines" select="$allComponentLines[printGrouping_l_c = 'SOFTWARE' or printGrouping_l_c = 'Software']"/>
<xsl:variable name="serviceLines" select="$allComponentLines[printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Services' or printGrouping_l_c = 'Additional Service']"/>
<xsl:if test="count($allComponentLines) > 0">
<!--  Summary view when SimplifiedFlag is enabled (not 'false')  -->
<xsl:variable name="cond_summary_view">
  <xsl:call-template name="getCustomXslTruth">
    <xsl:with-param name="var">
      <xsl:choose>
        <xsl:when test="$SimplifiedFlag != 'false'">
          1
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="number($cond_summary_view)=1">
  <!--  Summary groupings display  -->
  <div class="summary-listing" style="margin-top: 10px;">
  <h4 style="font-size: 12pt; font-weight: bold; margin-top: 5px;">
  <xsl:value-of select="$top_model_name"/>
  </h4>
  
  <!--  Platform Section  -->
  <xsl:variable name="cond_platform">
    <xsl:call-template name="getCustomXslTruth">
      <xsl:with-param name="var">
        <xsl:choose>
          <xsl:when test="$hasplatformLines and $SimplifiedFlag != 'false'">
            1
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
  <xsl:when test="number($cond_platform)=1">
    <table class="full-width">
    <tr>
    <th colspan="7" class="subsection-header">Platform</th>
    </tr>
    </table>
  </xsl:when>
  <xsl:otherwise>
    <!-- Platform section not applicable for this configuration -->
  </xsl:otherwise>
  </xsl:choose>
  
  <!--  Capacity Section  -->
  <xsl:variable name="cond_capacity">
    <xsl:call-template name="getCustomXslTruth">
      <xsl:with-param name="var">
        <xsl:choose>
          <xsl:when test="$hascapacityLines and $SimplifiedFlag != 'false'">
            1
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
  <xsl:when test="number($cond_capacity)=1">
    <table class="full-width">
    <tr>
    <th colspan="7" class="subsection-header">Capacity</th>
    </tr>
    </table>
  </xsl:when>
  </xsl:choose>
  
  <!--  Networking Section  -->
  <xsl:variable name="cond_networking">
    <xsl:call-template name="getCustomXslTruth">
      <xsl:with-param name="var">
        <xsl:choose>
          <xsl:when test="$hasnetworkingLines and $SimplifiedFlag != 'false'">
            1
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
  <xsl:when test="number($cond_networking)=1">
    <table class="full-width">
    <tr>
    <th colspan="7" class="subsection-header">Networking</th>
    </tr>
    </table>
  </xsl:when>
  </xsl:choose>
  
  <!--  Software Section  -->
  <xsl:variable name="cond_software">
    <xsl:call-template name="getCustomXslTruth">
      <xsl:with-param name="var">
        <xsl:choose>
          <xsl:when test="$hasSoftwareLines and $SimplifiedFlag != 'false'">
            1
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
  <xsl:when test="number($cond_software)=1">
    <table class="full-width">
    <tr>
    <th colspan="7" class="subsection-header">Software</th>
    </tr>
    </table>
  </xsl:when>
  </xsl:choose>
  
  </div>
</xsl:when>
<xsl:otherwise>
<!--  Detailed view when SimplifiedFlag is 'false'  -->
<div class="detailed-listing" style="margin-top: 10px;">
<h4 style="font-size: 12pt; font-weight: bold; margin-top: 5px;">
<xsl:value-of select="$top_model_name"/>
</h4>
<!--  Hardware Section  -->
<xsl:if test="count($hardwareLines) > 0">
<h4>Hardware</h4>
<table class="full-width">
<thead>
<!--  Estimated label row with grey background  -->
<tr>
<th colspan="7" class="estimated-header">
<strong>Estimated</strong>
</th>
</tr>
<!--  Column headers row  -->
<tr class="border-bottom">
<th class="column-header column-header-left">Part Number</th>
<th class="column-header column-header-left">Product Description</th>
<th class="column-header column-header-center">Ext. Qty</th>
<th class="column-header column-header-right">Unit List Price</th>
<th class="column-header column-header-right">Disc%</th>
<th class="column-header column-header-right">Unit Net Price</th>
<th class="column-header column-header-right">Ext. Net Price</th>
</tr>
</thead>
<tbody>
<!--  Platform Subsection  -->
<xsl:variable name="platformLines" select="$hardwareLines[summaryPrintGrouping_l_c='Platform' or summaryPrintGrouping_l_c='PLATFORM']"/>
<xsl:if test="count($platformLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Platform</th>
</tr>
<xsl:for-each select="$platformLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
<!--  Networking Subsection  -->
<xsl:variable name="networkingLines" select="$hardwareLines[summaryPrintGrouping_l_c='Networking' or summaryPrintGrouping_l_c='Network Adapters']"/>
<xsl:if test="count($networkingLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Networking</th>
</tr>
<xsl:for-each select="$networkingLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
</tbody>
</table>
<!--  Hardware Subsection Subtotal  -->
<xsl:variable name="hardwareExtNet">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($hardwareLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($hardwareLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($hardwareLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($hardwareLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="hardwareExtList">
<xsl:call-template name="calculate-extended-list">
<xsl:with-param name="lines" select="$hardwareLines"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="hardwareDiscount">
<xsl:choose>
<xsl:when test="number($hardwareExtList) != 0">
<xsl:value-of select="format-number(((number($hardwareExtList) - number($hardwareExtNet)) div number($hardwareExtList)) * 100, '#0.00')"/>
</xsl:when>
<xsl:otherwise>0.00</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Hardware Subsection Subtotal Table  -->
<div class="bg-mg padding-md" style="margin: 15px 0; font-weight: bold; font-size: 9pt;">
<table>
<tr class="bg-mg">
<td style="width: 20%;">
<strong>Estimated Hardware Sub Total:</strong>
</td>
<td style="width: 30%;">
Hardware Ext. List: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($hardwareExtList)"/>
</xsl:call-template>
</td>
<td style="width: 25%;">
Hardware Discount:
<xsl:value-of select="$hardwareDiscount"/>
%
</td>
<td style="width: 25%;">
Hardware Ext. Net: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($hardwareExtNet)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
<!--  Storage Section  -->
<xsl:if test="count($storageLines) > 0">
<h4>Storage</h4>
<table class="full-width">
<thead>
<!--  Estimated label row with grey background  -->
<tr>
<th colspan="7" class="estimated-header">
<strong>Estimated</strong>
</th>
</tr>
<!--  Column headers row  -->
<tr class="border-bottom">
<th class="column-header column-header-left">Part Number</th>
<th class="column-header column-header-left">Product Description</th>
<th class="column-header column-header-center">Ext. Qty</th>
<th class="column-header column-header-right">Unit List Price</th>
<th class="column-header column-header-right">Disc%</th>
<th class="column-header column-header-right">Unit Net Price</th>
<th class="column-header column-header-right">Ext. Net Price</th>
</tr>
</thead>
<tbody>
<!--  Platform Subsection  -->
<xsl:variable name="storagePlatformLines" select="$storageLines[summaryPrintGrouping_l_c='Platform' or summaryPrintGrouping_l_c='PLATFORM']"/>
<xsl:if test="count($storagePlatformLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Platform</th>
</tr>
<xsl:for-each select="$storagePlatformLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
<!--  Capacity Subsection  -->
<xsl:variable name="storageCapacityLines" select="$storageLines[summaryPrintGrouping_l_c='Capacity']"/>
<xsl:if test="count($storageCapacityLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Capacity</th>
</tr>
<xsl:for-each select="$storageCapacityLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
</tbody>
</table>
<!--  Storage Subsection Subtotal  -->
<xsl:variable name="storageExtNet">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($storageLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($storageLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($storageLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($storageLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="storageExtList">
<xsl:call-template name="calculate-extended-list">
<xsl:with-param name="lines" select="$storageLines"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="storageDiscount">
<xsl:choose>
<xsl:when test="number($storageExtList) != 0">
<xsl:value-of select="format-number(((number($storageExtList) - number($storageExtNet)) div number($storageExtList)) * 100, '#0.00')"/>
</xsl:when>
<xsl:otherwise>0.00</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Storage Subsection Subtotal Table  -->
<div class="bg-mg padding-md" style="margin: 15px 0; font-weight: bold; font-size: 9pt;">
<table>
<tr class="bg-mg">
<td style="width: 20%">
<strong>Estimated Storage Sub Total:</strong>
</td>
<td style="width: 30%">
Storage Ext. List: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($storageExtList)"/>
</xsl:call-template>
</td>
<td style="width: 25%">
Storage Discount:
<xsl:value-of select="$storageDiscount"/>
%
</td>
<td style="width: 25%">
Storage Ext. Net: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($storageExtNet)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
<!--  Software Section  -->
<xsl:if test="count($softwareLines) > 0">
<h4>Software</h4>
<table class="full-width">
<thead>
<!--  Estimated label row with grey background  -->
<tr>
<th colspan="7" class="estimated-header">
<strong>Estimated</strong>
</th>
</tr>
<!--  Column headers row  -->
<tr class="border-bottom">
<th class="column-header column-header-left">Part Number</th>
<th class="column-header column-header-left">Product Description</th>
<th class="column-header column-header-center">Ext. Qty</th>
<th class="column-header column-header-right">Unit List Price</th>
<th class="column-header column-header-right">Disc%</th>
<th class="column-header column-header-right">Unit Net Price</th>
<th class="column-header column-header-right">Ext. Net Price</th>
</tr>
</thead>
<tbody>
<!--  Software Subsection  -->
<!--  Show all software lines without filtering by summaryPrintGrouping_l_c  -->
<xsl:if test="count($softwareLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Software</th>
</tr>
<xsl:for-each select="$softwareLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
</tbody>
</table>
<!--  Software Subsection Subtotal  -->
<xsl:variable name="softwareExtNet">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($softwareLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($softwareLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($softwareLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($softwareLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="softwareExtList">
<xsl:call-template name="calculate-extended-list">
<xsl:with-param name="lines" select="$softwareLines"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="softwareDiscount">
<xsl:choose>
<xsl:when test="number($softwareExtList) != 0">
<xsl:value-of select="format-number(((number($softwareExtList) - number($softwareExtNet)) div number($softwareExtList)) * 100, '#0.00')"/>
</xsl:when>
<xsl:otherwise>0.00</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Software Subsection Subtotal Table  -->
<div class="bg-mg padding-md" style="margin: 15px 0; font-weight: bold; font-size: 9pt;">
<table>
<tr class="bg-mg">
<td style="width: 20%">
<strong>Estimated Software Sub Total:</strong>
</td>
<td style="width: 30%">
Software Ext. List: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($softwareExtList)"/>
</xsl:call-template>
</td>
<td style="width: 25%">
Software Discount:
<xsl:value-of select="$softwareDiscount"/>
%
</td>
<td style="width: 25%">
Software Ext. Net: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($softwareExtNet)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
<!--  Services Section  -->
<xsl:if test="count($serviceLines) > 0">
<h4>Services</h4>
<table class="full-width">
<thead>
<!--  Estimated label row with grey background  -->
<tr>
<th colspan="7" class="estimated-header">
<strong>Estimated</strong>
</th>
</tr>
<!--  Column headers row  -->
<tr class="border-bottom">
<th class="column-header column-header-left">Part Number</th>
<th class="column-header column-header-left">Product Description</th>
<th class="column-header column-header-center">Ext. Qty</th>
<th class="column-header column-header-right">Unit List Price</th>
<th class="column-header column-header-right">Disc%</th>
<th class="column-header column-header-right">Unit Net Price</th>
<th class="column-header column-header-right">Ext. Net Price</th>
</tr>
</thead>
<tbody>
<!--  Services Subsection  -->
<xsl:variable name="servicesOnlyLines" select="$serviceLines[summaryPrintGrouping_l_c='Services' or summaryPrintGrouping_l_c='SERVICES' or summaryPrintGrouping_l_c='' or not(summaryPrintGrouping_l_c)]"/>
<xsl:if test="count($servicesOnlyLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Services</th>
</tr>
<xsl:for-each select="$servicesOnlyLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
<!--  Additional Services Subsection  -->
<xsl:variable name="additionalServicesLines" select="$serviceLines[summaryPrintGrouping_l_c='Additional Service']"/>
<xsl:if test="count($additionalServicesLines) > 0">
<tr>
<th colspan="7" class="subsection-header">Additional Services</th>
</tr>
<xsl:for-each select="$additionalServicesLines">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_number"/>
</td>
<td class="cell-padding">
<xsl:value-of select="./item_l/_part_desc"/>
<br/>
<strong>[Discount Cat: </strong>
<xsl:choose>
<xsl:when test="./dynamicCatCode_l_c != ''">
<xsl:value-of select="./dynamicCatCode_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./item_l/_part_custom_field463"/>
</xsl:otherwise>
</xsl:choose>
<strong>]</strong>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="./extendedQuantity_l_c"/>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./listPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:value-of select="format-number(./currentDiscount_l_c, '0.00')"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./netPrice_l_c"/>
</xsl:call-template>
</td>
<td class="text-right cell-padding">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="./extendedNetPrice_l_c"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
</tbody>
</table>
<!--  Service Period Details (displayed when serviceDuration > 0)  -->
<xsl:variable name="serviceLinesWithDuration" select="$serviceLines[serviceDuration_l_c > 0]"/>
<!--  Get service address from the first ROOT/SUBROOT document that has an address  -->
<xsl:variable name="rootDocWithAddress" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and (_parent_doc_number = '' or cPQVirtualPart_l_c='ROOT' or cPQVirtualPart_l_c='SUBROOT') and installedAtAddress_l_c != ''][1]"/>
<xsl:variable name="serviceAddress" select="concat($rootDocWithAddress/installedAtAddress_l_c,' ',$rootDocWithAddress/installedAtStateProvince_l_c,' ',$rootDocWithAddress/installedAtCountry_l_c,' ', $rootDocWithAddress/installedAtPostalCode_l_c)"/>
<!--  Services Subsection Subtotal  -->
<xsl:variable name="servicesExtNet">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($serviceLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($serviceLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($serviceLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($serviceLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="servicesExtList">
<xsl:call-template name="calculate-extended-list">
<xsl:with-param name="lines" select="$serviceLines"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="servicesDiscount">
<xsl:choose>
<xsl:when test="number($servicesExtList) != 0">
<xsl:value-of select="format-number(((number($servicesExtList) - number($servicesExtNet)) div number($servicesExtList)) * 100, '#0.00')"/>
</xsl:when>
<xsl:otherwise>0.00</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Services Subsection Subtotal Table  -->
<div class="bg-mg padding-md" style="margin: 15px 0; font-weight: bold; font-size: 9pt;">
<table>
<tr class="bg-mg">
<td style="width: 20%">
<strong>Estimated Services Sub Total:</strong>
</td>
<td style="width: 30%">
Service Ext. List: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($servicesExtList)"/>
</xsl:call-template>
</td>
<td style="width: 25%">
Service Discount:
<xsl:value-of select="$servicesDiscount"/>
%
</td>
<td style="width: 25%">
Service Ext. Net: ¥
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($servicesExtNet)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
</div>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:for-each>
<!--  End MODEL loop  -->
</xsl:for-each>
<!--  End ROOT/SUBROOT loop  -->

<!--  SMP Processing Section - Software Maintenance Program lines  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and downstreamFulfillment_l_c = 'SMP' and lineType_l = 'MODEL' and doNotPrintFlag_l_c != 'Y']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="smpLineNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="smpModelName">
<xsl:choose>
<xsl:when test="./model_l/_model_name/@display_value">
<xsl:value-of select="./model_l/_model_name/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./model_l/_model_name"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<div class="smp-section" style="margin-top: 20px; margin-bottom: 20px;">
<h3 class="h3" style="background-color: #E1E1E1; padding: 8px; border: 1px solid #949494; margin-bottom: 10px;">
<xsl:value-of select="$smpModelName"/>
</h3>

<!--  SMP Model Header Table  -->
<table class="smp-table" style="width: 100%; border-collapse: collapse; margin-bottom: 15px;">
<tr>
<td colspan="4" style="padding: 8px; border: 1px solid #949494; background-color: #E1E1E1; font-weight: bold; font-size: 12pt;">
<xsl:value-of select="$smpModelName"/>
</td>
</tr>
<xsl:if test="./assetType_l_c = 'Amend' or ./assetType_l_c = 'Renew'">
<tr>
<td colspan="2" style="padding: 8px; border: 1px solid #949494; font-weight: bold;">
<xsl:choose>
<xsl:when test="./assetType_l_c = 'Amend'">Amend</xsl:when>
<xsl:when test="./assetType_l_c = 'Renew'">Renew</xsl:when>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
</tr>
</xsl:if>
<tr>
<td style="padding: 8px; border: 1px solid #949494; font-weight: bold; width: 25%;">Part Number</td>
<td style="padding: 8px; border: 1px solid #949494; font-weight: bold; width: 35%;">
<xsl:if test="./assetType_l_c = 'Amend' or ./assetType_l_c = 'Renew'">Subscription Details</xsl:if>
</td>
<td style="padding: 8px; border: 1px solid #949494; font-weight: bold; width: 15%; text-align: center;">Ext. Qty</td>
<td style="padding: 8px; border: 1px solid #949494; font-weight: bold; width: 25%; text-align: right;">
<xsl:if test="$pricingTier = '1' or $pricingTier = ''">Ext. Net Price</xsl:if>
<xsl:if test="$pricingTier = '2'">Ext. Reseller Net Price</xsl:if>
<xsl:if test="$pricingTier = '3'">Ext. End Customer Net Price</xsl:if>
</td>
</tr>
</table>

<!--  Process SMP child lines  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = ./_document_number and downstreamFulfillment_l_c = 'SMP' and _parent_doc_number = $smpLineNumber]">
<xsl:sort select="./@_document_number" order="ascending"/>
<table class="smp-line-table" style="width: 100%; border-collapse: collapse; margin-bottom: 5px;">
<tr>
<td style="padding: 8px; border: 1px solid #949494; width: 25%;">
<xsl:choose>
<xsl:when test="./item_l/_part_number/@display_value">
<xsl:value-of select="./item_l/_part_number/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./item_l/_part_number"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; width: 35%;">
<xsl:if test="./assetType_l_c = 'Amend' or ./assetType_l_c = 'Renew'">
<div style="font-weight: bold; margin-bottom: 5px;">Subscription ID: <xsl:choose>
<xsl:when test="./subscriptionNumber_l_c/@display_value">
<xsl:value-of select="./subscriptionNumber_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./subscriptionNumber_l_c"/>
</xsl:otherwise>
</xsl:choose></div>

<xsl:if test="./assetType_l_c = 'Amend'">
<div style="font-size: 10pt; margin-bottom: 3px;">
<strong>Amendment Start Date:</strong>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="./addOnStartDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 10pt; margin-bottom: 3px;">
<strong>Existing Subscription End Date:</strong>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="./serviceEndDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 10pt; margin-bottom: 3px;">
<strong>Amendment Duration:</strong>
<xsl:value-of select="format-number(./amendmentDuration_l_c, '#')"/> Days
</div>
<div style="font-size: 10pt; margin-bottom: 3px;">
<strong>Previous Total Quantity:</strong>
<xsl:choose>
<xsl:when test="./assetOriginalQuantity_l_c/@display_value">
<xsl:value-of select="./assetOriginalQuantity_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./assetOriginalQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</div>
<div style="font-size: 10pt;">
<strong>New Total Quantity:</strong>
<xsl:choose>
<xsl:when test="./assetType_l_c = 'Amend' and ./assetAmendedQty_l_c != ''">
<xsl:value-of select="./assetAmendedQty_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./extendedQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</div>
</xsl:if>

<xsl:if test="./assetType_l_c = 'Renew'">
<div style="font-size: 10pt; margin-bottom: 3px;">
<strong>Start Date of Extension:</strong>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="./serviceStartDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 10pt;">
<strong>Extension Subscription End Date:</strong>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="./serviceEndDate_l_c"/>
</xsl:call-template>
</div>
</xsl:if>
</xsl:if>
</td>
<td style="padding: 8px; border: 1px solid #949494; width: 15%; text-align: center;">
<xsl:choose>
<xsl:when test="./assetType_l_c = 'Amend' and ./assetAmendedQty_l_c != ''">
<xsl:value-of select="./assetAmendedQty_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./extendedQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; width: 25%; text-align: right;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="./extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="./extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="./extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:with-param>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:for-each>
</div>
</xsl:for-each>

<!--  NON-SMP Summary Processing Section - Alternative fulfillment channels  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and downstreamFulfillment_l_c != 'SMP' and lineType_l = 'MODEL' and doNotPrintFlag_l_c != 'Y']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="nonSmpLineNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="nonSmpModelName">
<xsl:choose>
<xsl:when test="./model_l/_model_name/@display_value">
<xsl:value-of select="./model_l/_model_name/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./model_l/_model_name"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!--  Non-SMP Model Summary Header  -->
<div class="non-smp-model-summary" style="margin: 20px 0;">
<table class="non-smp-model-header-table" style="width: 100%; border-collapse: collapse; margin-bottom: 5px;">
<tr>
<td style="padding: 10px; background-color: #f0f0f0; border: 1px solid #949494; font-weight: bold; font-size: 12pt;">
Non-SMP Model: <xsl:value-of select="$nonSmpModelName"/>
</td>
<td style="padding: 10px; background-color: #f0f0f0; border: 1px solid #949494; text-align: right; font-weight: bold;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</table>

<!--  Process Non-SMP child lines  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = ./_document_number and downstreamFulfillment_l_c != 'SMP' and _parent_doc_number = $nonSmpLineNumber]">
<xsl:sort select="./@_document_number" order="ascending"/>
<table class="non-smp-line-table" style="width: 100%; border-collapse: collapse; margin-bottom: 5px;">
<tr>
<td style="padding: 8px; border: 1px solid #949494; width: 25%;">
<xsl:choose>
<xsl:when test="./item_l/_part_number/@display_value">
<xsl:value-of select="./item_l/_part_number/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./item_l/_part_number"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; width: 50%;">
<xsl:choose>
<xsl:when test="./item_l/displayName_l/@display_value">
<xsl:value-of select="./item_l/displayName_l/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="./item_l/displayName_l"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; width: 25%; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price">
<xsl:choose>
<xsl:when test="extendedNetPrice_l_c/@display_value">
<xsl:value-of select="extendedNetPrice_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="extendedNetPrice_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:with-param>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:for-each>
</div>
</xsl:for-each>

<!--  SMP Detailed Section Processing - Missing from Master.xsl  -->
<!--  Processes SMP lines in detailed view for Keystone STaaS subscriptions  -->
<xsl:if test="(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c = 'SMP' and renewalIndicator_l_c!='Y' and $_dsMain1/keyStone_t_c!='Yes'])">
<div class="smp-detailed-section" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16pt; font-weight: bold; margin-bottom: 15px; page-break-before: auto;">Detailed Section</h2>

<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c = 'SMP' and renewalIndicator_l_c!='Y' and $_dsMain1/keyStone_t_c!='Yes' and ((_parent_doc_number = '' and cPQVirtualPart_l_c != 'ROOT') or cPQVirtualPart_l_c = 'SUBROOT')]">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="proposalLoopDocNumber" select="./_document_number"/>
<xsl:variable name="parentConfigName" select="./virtualConfigName_l_c"/>
<xsl:variable name="AutoRenew" select="./autoRenew_l_c"/>
<xsl:variable name="BillingFrequency" select="./billingFrequency_l_c"/>
<xsl:variable name="SelectedTech" select="./selectedTechnologies_l_c"/>

<!--  SMP Configuration Header  -->
<xsl:if test="downstreamFulfillment_l_c = 'SMP'">
<div class="smp-config-header" style="margin-top: 20px; margin-bottom: 10px;">
<h3 style="font-size: 12pt; font-weight: bold; color: #000;">
<xsl:choose>
<xsl:when test="starts-with($parentConfigName, 'Config#')">
<xsl:value-of select="$parentConfigName"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$parentConfigName"/>
</xsl:otherwise>
</xsl:choose>
</h3>
</div>

<!--  Configuration Comments  -->
<xsl:if test="comment_l_c != ''">
<div style="margin-bottom: 10px; font-size: 8pt;">
<strong>Configuration Comments:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="comment_l_c/@display_value">
<xsl:value-of select="comment_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="comment_l_c"/>
</xsl:otherwise>
</xsl:choose>
</div>
</xsl:if>

<!--  SMP Keystone STaaS Table  -->
<table class="smp-keystone-table" style="width: 100%; border-collapse: collapse; margin-bottom: 15px;">
<thead>
<tr>
<th colspan="4" style="padding: 8px; border: 1px solid #949494; background-color: #E1E1E1; font-weight: bold; text-align: left; font-size: 12pt;">
Keystone STaaS Subscription
</th>
<th style="padding: 8px; border: 1px solid #949494;"></th>
<th style="padding: 8px; border: 1px solid #949494;"></th>
<th style="padding: 8px; border: 1px solid #949494;"></th>
<th style="padding: 8px; border: 1px solid #949494;"></th>
</tr>

<!--  Asset Type Header (if Amend or Renew)  -->
<xsl:if test="assetType_l_c = 'Amend' or assetType_l_c = 'Renew'">
<tr>
<td colspan="2" style="padding: 8px; border: 1px solid #949494; font-size: 10pt;">
<xsl:choose>
<xsl:when test="assetType_l_c = 'Amend'">Amend</xsl:when>
<xsl:when test="assetType_l_c = 'Renew'">Renew</xsl:when>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
<td style="padding: 8px; border: 1px solid #949494;"></td>
</tr>
</xsl:if>

<!--  Estimated Header  -->
<xsl:if test="not($_dsMain1/pvrStatus_t_c = 'Approved' or $_dsMain1/pvrStatus_t_c = 'Approval Not Required' or $_dsMain1/pvrStatus_t_c = 'Pre Approved') and ($_dsMain1/lineLevelPricing_t_c = 'onlyNetPricing' or $_dsMain1/lineLevelPricing_t_c = 'listDiscountAndNetPricing')">
<tr>
<td colspan="4" style="padding: 8px; border: 1px solid #949494;"></td>
<td colspan="4" style="padding: 8px; border: 1px solid #949494; background-color: #E1E1E1; text-align: center; font-weight: bold; font-size: 8pt;">
Estimated
</td>
</tr>
</xsl:if>

<!--  Column Headers  -->
<tr>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: left;">Part Number</th>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: left;">
<xsl:if test="assetType_l_c = 'Amend' or assetType_l_c = 'Renew'">Subscription Details</xsl:if>
</th>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: center;">Ext. Qty</th>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: center;">
<xsl:if test="assetType_l_c = 'Amend'">Add'l Qty</xsl:if>
</th>
<xsl:if test="$_dsMain1/lineLevelPricing_t_c = 'listDiscountAndNetPricing'">
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: right;">Unit List Price</th>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: center;">Disc%</th>
</xsl:if>
<xsl:if test="$_dsMain1/lineLevelPricing_t_c != 'noPricing'">
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: right;">Unit Net Price</th>
<th style="padding: 8px; border: 1px solid #949494; font-weight: bold; font-size: 8pt; text-align: right;">Ext. Net Price</th>
</xsl:if>
</tr>
</thead>
<tbody>

<!--  Process SMP lines for this configuration  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = $proposalLoopDocNumber and oRCL_ABO_ActionCode_l != 'DELETE' and downstreamFulfillment_l_c = 'SMP']">
<xsl:sort select="./@_document_number" order="ascending"/>
<tr>
<td style="padding: 8px; border: 1px solid #949494; font-size: 8pt;">
<xsl:choose>
<xsl:when test="item_l/_part_number/@display_value">
<xsl:value-of select="item_l/_part_number/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="item_l/_part_number"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; font-size: 8pt;">
<xsl:if test="assetType_l_c = 'Amend' or assetType_l_c = 'Renew'">
<div style="font-size: 8pt;">
<strong>Subscription ID:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="subscriptionNumber_l_c/@display_value">
<xsl:value-of select="subscriptionNumber_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="subscriptionNumber_l_c"/>
</xsl:otherwise>
</xsl:choose>
</div>

<xsl:if test="assetType_l_c = 'Amend'">
<div style="font-size: 8pt; margin-top: 3px;">
<strong>Amendment Start Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="addOnStartDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 8pt; margin-top: 2px;">
<strong>Existing Subscription End Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="serviceEndDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 8pt; margin-top: 2px;">
<strong>Amendment Duration:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="format-number(amendmentDuration_l_c, '#')"/>
<xsl:text> Days</xsl:text>
</div>
<div style="font-size: 8pt; margin-top: 2px;">
<strong>Previous Total Quantity:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="assetOriginalQuantity_l_c/@display_value">
<xsl:value-of select="assetOriginalQuantity_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="assetOriginalQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</div>
<div style="font-size: 8pt; margin-top: 2px;">
<strong>New Total Quantity:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="extendedQuantity_l_c"/>
</div>
</xsl:if>

<xsl:if test="assetType_l_c = 'Renew'">
<div style="font-size: 8pt; margin-top: 3px;">
<strong>Start Date of Extension:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="serviceStartDate_l_c"/>
</xsl:call-template>
</div>
<div style="font-size: 8pt; margin-top: 2px;">
<strong>Extension Subscription End Date:</strong>
<xsl:text> </xsl:text>
<xsl:call-template name="BMI_formatLongDate">
<xsl:with-param name="date" select="serviceEndDate_l_c"/>
</xsl:call-template>
</div>
</xsl:if>
</xsl:if>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: center; font-size: 8pt;">
<xsl:choose>
<xsl:when test="assetType_l_c = 'Amend' and assetAmendedQty_l_c != ''">
<xsl:value-of select="assetAmendedQty_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="extendedQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: center; font-size: 8pt;">
<xsl:if test="assetType_l_c = 'Amend'">
<xsl:choose>
<xsl:when test="assetOriginalQuantity_l_c != '' and assetAmendedQty_l_c != ''">
<xsl:value-of select="assetAmendedQty_l_c - assetOriginalQuantity_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="extendedQuantity_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</td>
<xsl:if test="$_dsMain1/lineLevelPricing_t_c = 'listDiscountAndNetPricing'">
<td style="padding: 8px; border: 1px solid #949494; text-align: right; font-size: 8pt;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="monthlyUnitListPriceFloat_c * serviceDuration_l_c"/>
</xsl:call-template>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: center; font-size: 8pt;">
<xsl:value-of select="format-number(discountPercent_l_c, '0.00%')"/>
</td>
</xsl:if>
<xsl:if test="$_dsMain1/lineLevelPricing_t_c != 'noPricing'">
<td style="padding: 8px; border: 1px solid #949494; text-align: right; font-size: 8pt;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="unitNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="unitNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="unitnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:with-param>
</xsl:call-template>
</td>
<td style="padding: 8px; border: 1px solid #949494; text-align: right; font-size: 8pt;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>0</xsl:otherwise>
</xsl:choose>
</xsl:with-param>
</xsl:call-template>
</td>
</xsl:if>
</tr>
</xsl:for-each>
</tbody>
</table>

<!--  SMP Asset Type and Technology Information  -->
<xsl:if test="downstreamFulfillment_l_c = 'SMP'">
<table class="smp-info-table" style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
<tr>
<td colspan="4" style="padding: 8px; border: 1px solid #000; border-bottom: 1px solid #000;">
<!--  Selected Technologies  -->
<xsl:if test="selectedTechnologies_l_c != ''">
<div style="font-size: 8pt; margin-bottom: 5px;">
<strong>Selected Technologies:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="translate(selectedTechnologies_l_c, '~', ', ')"/>
</div>
</xsl:if>

<!--  Burst Opt-In  -->
<div style="font-size: 8pt; margin-bottom: 5px;">
<strong>Burst Opt-In:</strong>
<xsl:text> </xsl:text>
<xsl:choose>
<xsl:when test="overage_l_c = 'Yes'">Yes</xsl:when>
<xsl:otherwise>No</xsl:otherwise>
</xsl:choose>
</div>

<!--  Auto Renewal  -->
<xsl:if test="$AutoRenew != ''">
<div style="font-size: 8pt; margin-bottom: 5px;">
<strong>Auto Renewal:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$AutoRenew"/>
</div>
</xsl:if>

<!--  Billing Frequency  -->
<xsl:if test="$BillingFrequency != ''">
<div style="font-size: 8pt;">
<strong>Billing Frequency:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$BillingFrequency"/>
</div>
</xsl:if>
</td>
</tr>
</table>
</xsl:if>
</xsl:if>
</xsl:for-each>
</div>
</xsl:if>

<!--  NON-SMP Detailed Section Processing - Ported from Master.xsl  -->
<!--  Processes Non-SMP lines in detailed view for alternative fulfillment channels  -->
<xsl:if test="(//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c != 'SMP' and renewalIndicator_l_c!='Y' and $_dsMain1/keyStone_t_c!='Yes'])">
<div class="non-smp-detailed-section" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16pt; font-weight: bold; margin-bottom: 15px; page-break-before: auto;">Non-SMP Detailed Section</h2>

<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c != 'SMP' and renewalIndicator_l_c!='Y' and $_dsMain1/keyStone_t_c!='Yes' and ((_parent_doc_number = '' and cPQVirtualPart_l_c != 'ROOT') or cPQVirtualPart_l_c = 'SUBROOT')]">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="proposalLoopDocNumber" select="./_document_number"/>
<xsl:variable name="parentLoopDocNumber" select="./_parent_doc_number"/>
<xsl:variable name="parentConfigName" select="./virtualConfigName_l_c"/>
<xsl:variable name="AutoRenew" select="./autoRenew_l_c"/>
<xsl:variable name="BillingFrequency" select="./billingFrequency_l_c"/>
<xsl:variable name="SelectedTech" select="./selectedTechnologies_l_c"/>
<xsl:variable name="SimplifiedFlag">
<xsl:choose>
<xsl:when test="cPQVirtualPart_l_c='SUBROOT'">
<xsl:value-of select="//document[@document_var_name='transactionLine' and _document_number = $parentLoopDocNumber]/simplifiedPrinting_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="./simplifiedPrinting_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!--  Non-SMP Configuration Header  -->
<xsl:if test="virtualConfigName_l_c != ''">
<div class="non-smp-config-header" style="margin-top: 20px; margin-bottom: 10px;">
<h3 style="font-size: 12pt; font-weight: bold; color: #000;">
<xsl:choose>
<xsl:when test="starts-with($parentConfigName, 'Config#')">
<xsl:value-of select="$parentConfigName"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$parentConfigName"/>
</xsl:otherwise>
</xsl:choose>
</h3>
</div>
</xsl:if>

<!--  Configuration Comments  -->
<xsl:if test="comment_l_c != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Configuration Comments:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="comment_l_c"/>
</div>
</xsl:if>

<!--  Non-SMP Line Items Processing  -->
<div class="non-smp-line-items" style="margin-top: 15px;">
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = $proposalLoopDocNumber and downstreamFulfillment_l_c != 'SMP']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="modelLoopDocNumber" select="./_document_number"/>
<xsl:variable name="lineNumber" select="./lineItemNumber_l_c"/>
<xsl:variable name="bom_level" select="./_line_bom_level"/>
<xsl:variable name="top_model_name" select="./topModel_l_c"/>
<xsl:variable name="part_name" select="./item_l/_part_number"/>

<!--  Non-SMP Model Header  -->
<xsl:if test="lineType_l = 'MODEL' and extendedListPrice_l_c != '0.0'">
<div class="non-smp-model-header" style="margin: 20px 0 10px 0; padding: 10px; background-color: #f5f5f5; border-bottom: 1px solid #ccc;">
<h4 style="margin: 0; font-size: 12pt; font-weight: bold;">
<xsl:choose>
<xsl:when test="(configType_l_c = 'ADD ON' and hasAddOnStorage_l_c = 'STORAGE') or ((lineType_l = 'MODEL' or lineType_l = 'SERVICE') and topModel_l_c = '')">
<xsl:value-of select="item_l/_part_number"/>
</xsl:when>
<xsl:when test="lineType_l = 'MODEL' and topModel_l_c != ''">
<xsl:value-of select="topModel_l_c"/>
</xsl:when>
</xsl:choose>
</h4>
</div>

<!--  Non-SMP Line Items Table  -->
<table class="non-smp-items-table" style="width: 100%; border-collapse: collapse; margin: 10px 0; font-size: 8pt;">
<thead>
<tr style="background-color: #e0e0e0; font-weight: bold;">
<th style="border: 1px solid #ccc; padding: 8px; text-align: left; width: 20%;">Part Number</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: left; width: 35%;">Description</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: center; width: 10%;">Qty</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 12%;">List Price</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 8%;">Discount</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 15%;">Net Price</th>
</tr>
</thead>
<tbody>
<!--  Main Model Line  -->
<tr>
<td style="border: 1px solid #ccc; padding: 6px; font-weight: bold;">
<xsl:value-of select="item_l/_part_number"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px;">
<xsl:value-of select="item_l/displayName_l"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: center;">
<xsl:value-of select="requestedQuantity_l_c"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedListPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:value-of select="currentDiscount_l_c"/>%
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>

<!--  Process Hardware Sub-lines for Non-SMP  -->
<xsl:variable name="allSubLines" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and (topModelLineID_l_c = $lineNumber or ((modelReferenceLineID_l_c = $lineNumber or serviceReferenceLineID_l_c = $lineNumber) and _line_bom_level > $bom_level)) and lineType_l != 'MODEL']"/>
<xsl:variable name="hardwareLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and bundleChild_l_c = 'false' and (printGrouping_l_c = 'HARDWARE' or printGrouping_l_c = 'PLATFORM' or printGrouping_l_c = 'Hardware')]"/>

<!--  Hardware Section  -->
<xsl:if test="count($hardwareLines) > 0">
<tr>
<td colspan="6" style="border: 1px solid #ccc; padding: 8px; background-color: #f0f0f0; font-weight: bold;">Hardware</td>
</tr>
<xsl:for-each select="$hardwareLines">
<xsl:sort select="./lineItemNumber_l_c" data-type="number" order="ascending"/>
<tr>
<td style="border: 1px solid #ccc; padding: 4px; padding-left: 20px;">
<xsl:value-of select="item_l/_part_number"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px;">
<xsl:value-of select="item_l/displayName_l"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: center;">
<xsl:value-of select="requestedQuantity_l_c"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedListPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:value-of select="currentDiscount_l_c"/>%
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>

<!--  Software Section  -->
<xsl:variable name="softwareLines" select="$allSubLines[cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and bundleChild_l_c = 'false' and printGrouping_l_c = 'SOFTWARE']"/>
<xsl:if test="count($softwareLines) > 0">
<tr>
<td colspan="6" style="border: 1px solid #ccc; padding: 8px; background-color: #f0f0f0; font-weight: bold;">Software</td>
</tr>
<xsl:for-each select="$softwareLines">
<xsl:sort select="./lineItemNumber_l_c" data-type="number" order="ascending"/>
<tr>
<td style="border: 1px solid #ccc; padding: 4px; padding-left: 20px;">
<xsl:value-of select="item_l/_part_number"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px;">
<xsl:value-of select="item_l/displayName_l"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: center;">
<xsl:value-of select="requestedQuantity_l_c"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedListPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:value-of select="currentDiscount_l_c"/>%
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>

<!--  Services Section  -->
<xsl:variable name="serviceLines" select="$allSubLines[bundleChild_l_c = 'false' and cPQVirtualPart_l_c != 'CSITEMCHILD' and doNotPrintFlag_l_c != 'Y' and (printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Additional Service')]"/>
<xsl:if test="count($serviceLines) > 0">
<tr>
<td colspan="6" style="border: 1px solid #ccc; padding: 8px; background-color: #f0f0f0; font-weight: bold;">Services</td>
</tr>
<xsl:for-each select="$serviceLines">
<xsl:sort select="./lineItemNumber_l_c" data-type="number" order="ascending"/>
<tr>
<td style="border: 1px solid #ccc; padding: 4px; padding-left: 20px;">
<xsl:value-of select="item_l/_part_number"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px;">
<xsl:value-of select="item_l/displayName_l"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: center;">
<xsl:value-of select="requestedQuantity_l_c"/>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedListPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:value-of select="currentDiscount_l_c"/>%
</td>
<td style="border: 1px solid #ccc; padding: 4px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</xsl:if>
</tbody>
</table>

<!--  Serial Numbers for Non-SMP  -->
<xsl:variable name="serialNumbers">
<xsl:for-each select="./_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
<xsl:if test="./attribute[@var_name='serialNumber_serialNumber_Array_l_c'] != ''">
<xsl:value-of select="./attribute[@var_name='serialNumber_serialNumber_Array_l_c']"/>
<xsl:if test="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'] != ''">
<xsl:text>, </xsl:text>
<xsl:value-of select="./attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c']"/>
</xsl:if>
<xsl:if test="position() != last()">
<xsl:text>, </xsl:text>
</xsl:if>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:if test="$serialNumbers != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Serial Numbers:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$serialNumbers"/>
</div>
</xsl:if>

<!--  Quick Ship Messages for Non-SMP  -->
<xsl:if test="quickShipMessages_l_c != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Quick Ship Messages:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="quickShipMessages_l_c"/>
</div>
</xsl:if>

<!--  Selected Technologies for Non-SMP  -->
<xsl:if test="$SelectedTech != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Selected Technologies:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="translate($SelectedTech, '~', ', ')"/>
</div>
</xsl:if>
</xsl:if>
</xsl:for-each>
</div>

<!--  Auto Renewal Information for Non-SMP  -->
<xsl:if test="$AutoRenew != ''">
<div style="font-size: 8pt; margin: 10px 0;">
<strong>Auto Renewal:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$AutoRenew"/>
</div>
</xsl:if>

<!--  Billing Frequency for Non-SMP  -->
<xsl:if test="$BillingFrequency != ''">
<div style="font-size: 8pt;">
<strong>Billing Frequency:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="$BillingFrequency"/>
</div>
</xsl:if>
</xsl:for-each>
</div>
</xsl:if>

<!--  NON-SMP Renewal Section Processing - Ported from Master.xsl  -->
<!--  Processes Non-SMP renewal lines for alternative fulfillment channels  -->
<xsl:if test="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c != 'SMP' and renewalIndicator_l_c = 'Y']">
<div class="non-smp-renewal-section" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16pt; font-weight: bold; margin-bottom: 15px; page-break-before: auto;">Non-SMP Renewal Services</h2>

<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and downstreamFulfillment_l_c != 'SMP' and renewalIndicator_l_c = 'Y']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="proposalLoopDocNumber" select="./_document_number"/>
<xsl:variable name="parentLoopDocNumber" select="./_parent_doc_number"/>
<xsl:variable name="parentConfigName" select="./virtualConfigName_l_c"/>
<xsl:variable name="renewalSvcName" select="concat(substring-before(./model_l/_model_bom, 'Renewal'), ' Renewal Services')"/>
<xsl:variable name="renewalName">
<xsl:choose>
<xsl:when test="./model_l/_model_name = 'Renewal Products'">
<xsl:value-of select="concat(substring-before(./model_l/_model_bom, 'Renewal'), ' Renewal Services')"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat(./model_l/_model_bom, ' Renewal Services')"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!--  Non-SMP Renewal Configuration Header  -->
<xsl:if test="virtualConfigName_l_c != '' or $renewalName != ''">
<div class="non-smp-renewal-header" style="margin: 20px 0 10px 0;">
<h3 style="font-size: 12pt; font-weight: bold; color: #000;">
<xsl:choose>
<xsl:when test="virtualConfigName_l_c != ''">
<xsl:value-of select="virtualConfigName_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$renewalName"/>
</xsl:otherwise>
</xsl:choose>
</h3>
</div>
</xsl:if>

<!--  Non-SMP Renewal Line Items Processing  -->
<div class="non-smp-renewal-items" style="margin-top: 15px;">
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and (_parent_doc_number = $proposalLoopDocNumber or _parent_doc_number = $parentLoopDocNumber) and downstreamFulfillment_l_c != 'SMP' and renewalIndicator_l_c = 'Y' and lineType_l != 'STD']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="modelLoopDocNumber" select="./_document_number"/>
<xsl:variable name="lineNumber" select="./lineItemNumber_l_c"/>

<!--  Non-SMP Renewal Items Table  -->
<table class="non-smp-renewal-table" style="width: 100%; border-collapse: collapse; margin: 10px 0; font-size: 8pt;">
<xsl:if test="position() = 1">
<thead>
<tr style="background-color: #e0e0e0; font-weight: bold;">
<th style="border: 1px solid #ccc; padding: 8px; text-align: left; width: 20%;">Part Number</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: left; width: 35%;">Description</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: center; width: 10%;">Qty</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 12%;">List Price</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 8%;">Discount</th>
<th style="border: 1px solid #ccc; padding: 8px; text-align: right; width: 15%;">Net Price</th>
</tr>
</thead>
</xsl:if>
<tbody>
<!--  Renewal Line Item  -->
<tr>
<td style="border: 1px solid #ccc; padding: 6px; font-weight: bold;">
<xsl:value-of select="item_l/_part_number"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px;">
<xsl:value-of select="item_l/displayName_l"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: center;">
<xsl:value-of select="requestedQuantity_l_c"/>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedListPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:value-of select="currentDiscount_l_c"/>%
</td>
<td style="border: 1px solid #ccc; padding: 6px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="extendedNetPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>

<!--  Service Term and Dates for Renewals  -->
<xsl:if test="serviceStartDate_l_c != '' or serviceEndDate_l_c != '' or serviceTerm_l_c != ''">
<tr>
<td colspan="6" style="border: 1px solid #ccc; padding: 6px; background-color: #f9f9f9; font-size: 7pt;">
<div style="display: flex; justify-content: space-between;">
<xsl:if test="serviceStartDate_l_c != ''">
<span><strong>Start:</strong> <xsl:value-of select="serviceStartDate_l_c"/></span>
</xsl:if>
<xsl:if test="serviceEndDate_l_c != ''">
<span><strong>End:</strong> <xsl:value-of select="serviceEndDate_l_c"/></span>
</xsl:if>
<xsl:if test="serviceTerm_l_c != ''">
<span><strong>Term:</strong> <xsl:value-of select="serviceTerm_l_c"/></span>
</xsl:if>
</div>
</td>
</tr>
</xsl:if>
</tbody>
</table>

<!--  Installation Address for Non-SMP Renewals  -->
<xsl:variable name="installedAt" select="concat(installedAtAddress_l_c, ' ', installedAtStateProvince_l_c, ' ', installedAtCountry_l_c, ' ', installedAtPostalCode_l_c)"/>
<xsl:if test="normalize-space($installedAt) != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Installed At:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="normalize-space($installedAt)"/>
</div>
</xsl:if>

<!--  Asset Tags for Non-SMP Renewals  -->
<xsl:if test="assetTag_l_c != ''">
<div style="margin: 10px 0; font-size: 8pt;">
<strong>Asset Tag:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="assetTag_l_c"/>
</div>
</xsl:if>
</xsl:for-each>
</div>
</xsl:for-each>
</div>
</xsl:if>

<!--  KEYSTONE NEW STaaS Cost Summary Section  -->
<!--  Processes NEW KeyStone STaaS subscriptions (explicit handling for New type only)  -->
<xsl:if test="$_dsMain1/keyStone_t_c = 'Yes' and ($_dsMain1/sMPType_t_c = 'New' or ($_dsMain1/sMPType_t_c = '' or not($_dsMain1/sMPType_t_c = 'Renew' or $_dsMain1/sMPType_t_c = 'Amend')))">
<div class="keystone-cost-summary-section" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16pt; font-weight: bold; margin-bottom: 15px; page-break-before: auto;">Cost Summary</h2>

<table class="keystone-cost-table" style="width: 100%; border-collapse: collapse; margin: 10px 0; font-size: 10pt;">
<thead>
<tr>
<th style="border: 1px solid #949494; padding: 8px; text-align: right; background-color: #f0f0f0; font-weight: bold; width: 25%;">
Net Price<br/>(Excl. One Time Charge)
</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: center; background-color: #f0f0f0; font-weight: bold; width: 25%;">
Billing Frequency
</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: center; background-color: #f0f0f0; font-weight: bold; width: 25%;">
Duration
</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: right; background-color: #f0f0f0; font-weight: bold; width: 25%;">
Total
</th>
</tr>
</thead>
<tbody>

<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and $_dsMain1/keyStone_t_c='Yes' and _parent_doc_number = '']">
<xsl:sort select="./@_document_number" order="ascending"/>
<xsl:variable name="proposalLoopDocNumber" select="./_document_number"/>
<xsl:variable name="excludingOneTimeFeeLines" select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='3' and _parent_doc_number = $proposalLoopDocNumber and not(summaryPrintGrouping_l_c = 'One Time Fee' or summaryPrintGrouping_l_c = 'Add-on Service-One Time Fee' or summaryPrintGrouping_l_c = 'One-Time Charge')]"/>

<!--  Calculate net price excluding one-time fees  -->
<xsl:variable name="extNetPrice">
<xsl:choose>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
<xsl:value-of select="sum($excludingOneTimeFeeLines/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
<xsl:value-of select="sum($excludingOneTimeFeeLines/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
<xsl:value-of select="sum($excludingOneTimeFeeLines/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="sum($excludingOneTimeFeeLines/extendedNetPrice_l_c)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!--  Calculate total including one-time fees  -->
<xsl:variable name="totalWithOneTime">
<xsl:choose>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '1' or $_dsMain1/pricingTierForPrint_t_c = ''">
<xsl:value-of select="extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '2'">
<xsl:value-of select="extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$_dsMain1/pricingTierForPrint_t_c = '3'">
<xsl:value-of select="extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="extendedNetPrice_l_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<tr>
<td style="border: 1px solid #949494; padding: 8px; text-align: right;">
<xsl:if test="$_dsMain1/subtotalGrandTotal_t_c != 'noPricing'">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="$extNetPrice"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</xsl:if>
</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: center;">
<xsl:choose>
<xsl:when test="billingFrequency_l_c/@display_value">
<xsl:value-of select="billingFrequency_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="billingFrequency_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: center;">
<xsl:choose>
<xsl:when test="contractDuration_l_c/@display_value">
<xsl:value-of select="contractDuration_l_c/@display_value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="contractDuration_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: right;">
<xsl:if test="$_dsMain1/subtotalGrandTotal_t_c != 'noPricing'">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="$totalWithOneTime"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</xsl:if>
</td>
</tr>
</xsl:for-each>
</tbody>
</table>

<!--  KeyStone STaaS Contract Information  -->
<xsl:for-each select="//document[@document_var_name='transactionLine' and normalize-space(./@data_type)='2' and $_dsMain1/keyStone_t_c='Yes' and _parent_doc_number = '']">
<div class="keystone-contract-info" style="margin: 15px 0; font-size: 9pt;">
<!--  Contract Terms  -->
<xsl:if test="contractStartDate_l_c != '' or contractEndDate_l_c != ''">
<div style="margin: 5px 0;">
<strong>Contract Term:</strong>
<xsl:if test="contractStartDate_l_c != ''">
<xsl:text> From </xsl:text>
<xsl:value-of select="contractStartDate_l_c"/>
</xsl:if>
<xsl:if test="contractEndDate_l_c != ''">
<xsl:text> To </xsl:text>
<xsl:value-of select="contractEndDate_l_c"/>
</xsl:if>
</div>
</xsl:if>

<!--  Auto Renewal Information  -->
<xsl:if test="autoRenew_l_c != ''">
<div style="margin: 5px 0;">
<strong>Auto Renewal:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="autoRenew_l_c"/>
</div>
</xsl:if>

<!--  Payment Terms  -->
<xsl:if test="paymentTerms_l_c != ''">
<div style="margin: 5px 0;">
<strong>Payment Terms:</strong>
<xsl:text> </xsl:text>
<xsl:value-of select="paymentTerms_l_c"/>
</div>
</xsl:if>
</div>
</xsl:for-each>
</div>
</xsl:if>

<!--  NON-KEYSTONE Cost Summary Section (Standard Quotes)  -->
<!--  Shows when NOT KeyStone following Master.xsl logic  -->
<xsl:if test="$_dsMain1/keyStone_t_c != 'Yes'">
<div class="non-keystone-cost-summary-section" style="margin-top: 30px; margin-bottom: 20px;">
<h2 style="font-size: 16pt; font-weight: bold; margin-bottom: 15px;">Cost Summary</h2>

<table class="cost-summary-table" style="width: 100%; border-collapse: collapse; margin: 10px 0;">
<thead>
<tr>
<th style="border: 1px solid #949494; padding: 8px; text-align: left; background-color: #f0f0f0; font-weight: bold;">Description</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: right; background-color: #f0f0f0; font-weight: bold;">List Price</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: right; background-color: #f0f0f0; font-weight: bold;">Discount %</th>
<th style="border: 1px solid #949494; padding: 8px; text-align: right; background-color: #f0f0f0; font-weight: bold;">Net Price</th>
</tr>
</thead>
<tbody>
<xsl:for-each select="/transaction/data_xml/document[normalize-space(./@data_type)='2' and _parent_doc_number = '']">
<tr>
<td style="border: 1px solid #949494; padding: 8px;">Configuration Summary</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="sum(//document[normalize-space(./@data_type)='3' and _parent_doc_number = current()/_document_number]/listPrice_l_c)"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: right;">
<xsl:value-of select="format-number(discountPercent_l_c, '#0.00')"/>%
</td>
<td style="border: 1px solid #949494; padding: 8px; text-align: right;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="netPrice_l_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</xsl:for-each>
</tbody>
</table>

<!--  Grand Total for Non-KeyStone  -->
<table style="width: 100%; margin-top: 20px;">
<tr>
<td style="width: 75%; text-align: right; font-weight: bold; font-size: 14pt; border-top: 3px solid #000; padding-top: 8px;">Net Grand Total:</td>
<td style="width: 25%; text-align: right; font-weight: bold; font-size: 14pt; border-top: 3px solid #000; padding-top: 8px;">
<xsl:call-template name="NewcurrencyFormattedPrice">
<xsl:with-param name="price" select="$_dsMain1/netPrice_t_c"/>
<xsl:with-param name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>

<!--  Gap #10: Promotional Messages Section  -->
<xsl:variable name="hasPromotionalDiscount">
<xsl:for-each select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='discountSummary_Array_t_c']/_array_set_row">
<xsl:if test="attribute[@var_name='discountType_discountSummary_Array_t_c'] = 'Promotional Discount'">true</xsl:if>
</xsl:for-each>
</xsl:variable>
<xsl:if test="contains($hasPromotionalDiscount, 'true') or //document[@document_var_name='transaction']/storageEfficiencyGuarantee_t_c='true' or count(//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='promo_Array_t_c']/_array_set_row[attribute[@var_name='promoDescription_promo_Array_t_c']!='']) > 0">
<div class="promotional-messages-section" style="margin-top: 20px; margin-bottom: 20px; padding: 15px; background-color: #f9f9f9; border: 1px solid #ddd;">
<h3 style="margin-top: 0; color: #333;">Promotion Message</h3>
<!--  Storage Efficiency Guarantee Message  -->
<xsl:if test="//document[@document_var_name='transaction']/storageEfficiencyGuarantee_t_c='true'">
<div style="margin: 10px 0; padding: 10px; background-color: #fff; border-left: 4px solid #0066cc; text-align: justify; line-height: 1.6;">
<p style="margin: 0; font-size: 11pt;"> To qualify for the Efficiency Guarantee, you need to nominate your opportunity in SFDC. Checking the Storage Efficiency Guarantee box does not nominate your opportunity for the efficiency guarantee, and the nomination for the Efficiency Guarantee must be approved by the program office. In addition, the Efficiency Guarantee terms and conditions must be sent to the customer prior to the corresponding purchase order being placed. If the terms and conditions are not sent to the customer prior to the order being booked, the nomination will be disqualified from the Efficiency Guarantee Program and this will be considered a booking violation. </p>
</div>
</xsl:if>
<!--  Promotional Descriptions from Array  -->
<xsl:for-each select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='promo_Array_t_c']/_array_set_row">
<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
<xsl:variable name="promoDesc" select="attribute[@var_name='promoDescription_promo_Array_t_c']"/>
<xsl:if test="$promoDesc!=''">
<div style="margin: 10px 0; padding: 8px; background-color: #fff; border-left: 4px solid #00a651;">
<p style="margin: 0; font-size: 11pt;">
<xsl:value-of select="$promoDesc"/>
</p>
</div>
</xsl:if>
</xsl:for-each>
</div>
</xsl:if>
</xsl:if>
<!--  END DETAILED SECTION CONDITION  -->

<!--  Grand Total Section #2: At the End (before Quote Information)  -->
<!--  Shows for: Non-Keystone OR Keystone Amend/Renew (matches master PDF exactly)  -->
<xsl:if test="($_dsMain1/keyStone_t_c!='Yes') or ($_dsMain1/keyStone_t_c = 'Yes' and ($_dsMain1/sMPType_t_c = 'Amend' or $_dsMain1/sMPType_t_c = 'Renew'))">
<div class="grand-total-section" style="margin-top: 30px;">
<!--  Calculate grand totals with pricing tier support - Using Master.xsl approach  -->
<xsl:variable name="grandNetPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="$_dsMain1/quoteNetPrice_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="$_dsMain1/quoteNetPriceSecondTier_t_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="$_dsMain1/quoteNetPriceThirdTier_t_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$_dsMain1/quoteNetPrice_t_c"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:variable name="grandListPrice" select="$_dsMain1/quoteListPrice_t_c"/>
<table>
<tr class="grand-total-row">
<td style="width: 15%;">List Grand Total:</td>
<td style="width: 35%;"/>
<td style="width: 15%;"/>
<td style="width: 35%; text-align: right;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="$grandListPrice"/>
</xsl:call-template>
</td>
</tr>
<tr class="grand-total-row">
<td style="width: 15%;">Total Discount:</td>
<td style="width: 35%;"/>
<td style="width: 15%;"/>
<td style="width: 35%; text-align: right;">
<xsl:value-of select="format-number((1 - number($grandNetPrice) div $grandListPrice) * 100, '0.00')"/>
%
</td>
</tr>
<tr class="grand-total-row">
<td style="width: 15%; border-top: 3px solid #000; padding-top: 8px;">Net Grand Total:</td>
<td style="width: 35%; border-top: 3px solid #000;"/>
<td style="width: 15%; border-top: 3px solid #000;"/>
<td style="width: 35%; text-align: right; border-top: 3px solid #000; padding-top: 8px;">
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="number($grandNetPrice)"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
<!--  Quote Information Section (Repeated at End)  -->
<div class="quote-info-repeat" style="margin-top: 40px;">
<h3 style="font-size: 16pt; font-weight: bold; margin-bottom: 10px;">Quote Information</h3>
<table>
<tr>
<td style="width: 15%;">Quote Name:</td>
<td style="width: 35%;">
<xsl:value-of select="//document[@document_var_name='transaction']/quoteNameTextArea_t_c"/>
</td>
<td style="width: 15%;"/>
<td style="width: 35%;"/>
</tr>
<tr>
<td>Quote Date:</td>
<td>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(//document[@document_var_name='transaction']/quoteExportDate_t_c, 1, 10)"/>
</xsl:call-template>
</td>
<td style="font-weight: normal;">Quote Valid Until:</td>
<td>
<xsl:call-template name="formatDate">
<xsl:with-param name="dateString" select="substring(//document[@document_var_name='transaction']/expiresOnDate_t_c, 1, 10)"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td>Contact Name:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/salesRep_t_c"/>
</td>
<td>Phone:</td>
<td/>
</tr>
<tr>
<td>Email:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/opportunityOwnerEmail_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td style="font-weight: normal;">Quote To:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='accounts_Array_t_c']/_array_set_row[@_row_number='2']/attribute[@var_name='company_accounts_Array_t_c']"/>
,
<xsl:value-of select="//document[@document_var_name='transaction']/_commerce_array_set_attr_info[@setName='accounts_Array_t_c']/_array_set_row[@_row_number='2']/attribute[@var_name='address_accounts_Array_t_c']"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td style="font-weight: normal;">Quote From:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/legalEntities_t_c"/>
,
<xsl:value-of select="//document[@document_var_name='transaction']/legalEntityAddress_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>
<xsl:choose>
<xsl:when test="$_dsMain1/keyStone_t_c = 'Yes'">End User:</xsl:when>
<xsl:otherwise>End Customer:</xsl:otherwise>
</xsl:choose>
</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_company_name"/>
<xsl:text>, </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_address"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_city"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_state"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_country"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_zip"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Ship To:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_company_name"/>
<xsl:text>, </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_address"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_city"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_state"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_country"/>
<xsl:text> </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/shipTo_t/_shipTo_t_zip"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Software Delivery Contact:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/softwareDeliveryContact_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Software Delivery Email:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/softwareDeliveryEmail_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Incoterm:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/incoterm_t_c"/>
</td>
<td>Quote Status:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/quoteStatus_t_c"/>
</td>
</tr>
<tr>
<td>Fulfilment Method:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/fulfillmentMethod_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Contract Number:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/apttusAgreementNumber_t_c"/>
</td>
<td/>
<td/>
</tr>
<tr>
<td>Order Type:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/orderType_t_c"/>
</td>
<td>Contract Name:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/contractName_t"/>
</td>
</tr>
<tr>
<td>Payment Terms:</td>
<td>
<xsl:value-of select="//document[@document_var_name='transaction']/paymentTerms_t_c"/>
</td>
<td/>
<td/>
</tr>
</table>
</div>
<!--  Terms and Conditions Section  -->
<div style="margin-top: 20px; border-top: 2px solid black; padding-top: 10px;">
<h3 class="h3">Terms and Conditions</h3>
<p class="p"> This quote is presented for budgetary purposes only. All net prices and discounts are estimated values only and are subject to change. A budgetary quote cannot be used as the basis for valid purchase order. </p>
</div>
<!--  Footer Information  -->
<div style="margin-top: 30px; padding-top: 10px; border-top: 1px solid #ccc; font-size: 12pt; text-align: center; color: #666;">
<p style="margin: 5px 0;">
All amounts are in
<xsl:value-of select="//document[@document_var_name='transaction']/currency_t"/>
</p>
<p style="margin: 5px 0;">
<xsl:text>Price List: </xsl:text>
<xsl:value-of select="//document[@document_var_name='transaction']/priceList_t_c"/>
<xsl:text>Date Printed: </xsl:text>
<xsl:value-of select="substring(//document[@document_var_name='transaction']/quoteExportDate_t_c, 1, 10)"/>
</p>
</div>
</body>
</html>
</xsl:template>
<!--  Template to format currency  -->
<!--  Multi-currency formatting template with locale-aware formatting  -->
<xsl:template name="format-currency">
<xsl:param name="amount"/>
<!--  Get currency from XML  -->
<xsl:variable name="currency" select="//document[@document_var_name='transaction']/currency_t"/>
<!--  Map currency code to symbol  -->
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
<xsl:otherwise>
<xsl:value-of select="//document[@document_var_name='transaction']/currency_t"/>
<xsl:text> </xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Determine decimal places based on currency  -->
<xsl:variable name="decimalPlaces">
<xsl:choose>
<!--  Zero decimal currencies  -->
<xsl:when test="$currency = 'JPY' or $currency = 'KRW' or $currency = 'VND' or $currency = 'IDR' or $currency = 'CLP' or $currency = 'ISK' or $currency = 'PYG'">0</xsl:when>
<!--  Three decimal currencies (rare)  -->
<xsl:when test="$currency = 'BHD' or $currency = 'JOD' or $currency = 'KWD' or $currency = 'OMR' or $currency = 'TND'">3</xsl:when>
<!--  Default: 2 decimals  -->
<xsl:otherwise>2</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Format pattern based on decimal places  -->
<xsl:variable name="formatPattern">
<xsl:choose>
<xsl:when test="$decimalPlaces = '0'">#,##0</xsl:when>
<xsl:when test="$decimalPlaces = '3'">#,##0.000</xsl:when>
<xsl:otherwise>#,##0.00</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Determine if symbol goes after amount (European style)  -->
<xsl:variable name="symbolAfter">
<xsl:choose>
<xsl:when test="$currency = 'SEK' or $currency = 'NOK' or $currency = 'DKK' or $currency = 'PLN' or $currency = 'ZAR'">true</xsl:when>
<xsl:otherwise>false</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<!--  Output formatted currency  -->
<xsl:choose>
<xsl:when test="string($amount) = 'NaN' or string($amount) = ''">
<xsl:choose>
<xsl:when test="$symbolAfter = 'true'">
<xsl:text>0 </xsl:text>
<xsl:value-of select="$currencySymbol"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$currencySymbol"/>
<xsl:text>0</xsl:text>
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
<!--  Compatibility template for netapp_formatPrice (used by Xalan)  -->
<xsl:template name="netapp_formatPrice">
<xsl:param name="price"/>
<xsl:call-template name="format-currency">
<xsl:with-param name="amount" select="$price"/>
</xsl:call-template>
</xsl:template>
<!--  Template to calculate extended list price (list price * quantity)  -->
<xsl:template name="calculate-extended-list">
<xsl:param name="lines"/>
<xsl:variable name="total">
<xsl:call-template name="sum-extended-list">
<xsl:with-param name="lines" select="$lines"/>
<xsl:with-param name="index" select="1"/>
<xsl:with-param name="sum" select="0"/>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="$total"/>
</xsl:template>
<!--  Recursive template to sum extended list prices  -->
<xsl:template name="sum-extended-list">
<xsl:param name="lines"/>
<xsl:param name="index"/>
<xsl:param name="sum"/>
<!-- RAJ-Corrected the condition: original had unescaped <= which needed &lt;= -->
<xsl:choose>
<xsl:when test="$index &lt;= count($lines)">
<xsl:variable name="currentLine" select="$lines[$index]"/>
<xsl:variable name="listPrice" select="number($currentLine/listPrice_l_c)"/>
<xsl:variable name="quantity" select="number($currentLine/extendedQuantity_l_c)"/>
<xsl:variable name="extended" select="$listPrice * $quantity"/>
<xsl:call-template name="sum-extended-list">
<xsl:with-param name="lines" select="$lines"/>
<xsl:with-param name="index" select="$index + 1"/>
<xsl:with-param name="sum" select="$sum + $extended"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$sum"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Template to create comma-separated list from summaryPrintLabel  -->
<xsl:template name="createCommaSeparatedList">
<xsl:param name="list"/>
<xsl:for-each select="$list">
<xsl:value-of select="."/>
<xsl:if test="position() != last()">, </xsl:if>
</xsl:for-each>
</xsl:template>
<!--  Template to calculate total drive capacity dynamically  -->
<xsl:template name="sumDriveCapacity">
<xsl:param name="total" select="0"/>
<xsl:param name="rows"/>
<xsl:param name="counter" select="1"/>
<xsl:param name="rowCount" select="count($rows)"/>
<!-- RAJ-Corrected the condition: original had unescaped <= which needed &lt;= -->
<xsl:choose>
<xsl:when test="$counter &lt;= $rowCount">
<!--  Calculate: ((DriveCapacity * NumberOfDrives) / 1000) * qty  -->
<!--  _part_custom_field288 = DriveCapacity, _part_custom_field289 = NumberOfDrives  -->
<xsl:variable name="rowVal" select="((number($rows[position() = $counter]/item_l/_part_custom_field288) * number($rows[position() = $counter]/item_l/_part_custom_field289)) div 1000) * number($rows[position() = $counter]/extendedQuantity_l_c)"/>
<xsl:call-template name="sumDriveCapacity">
<xsl:with-param name="total" select="format-number($total + $rowVal, '0.##')"/>
<xsl:with-param name="counter" select="$counter + 1"/>
<xsl:with-param name="rows" select="$rows"/>
<xsl:with-param name="rowCount" select="$rowCount"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$total"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  Template to calculate months between two dates (YYYY-MM-DD format)  -->
<xsl:template name="calculateMonthsBetweenDates">
<xsl:param name="startDate"/>
<xsl:param name="endDate"/>
<xsl:variable name="startYear" select="number(substring($startDate, 1, 4))"/>
<xsl:variable name="startMonth" select="number(substring($startDate, 6, 2))"/>
<xsl:variable name="endYear" select="number(substring($endDate, 1, 4))"/>
<xsl:variable name="endMonth" select="number(substring($endDate, 6, 2))"/>
<!--  Calculate total months: (endYear - startYear) * 12 + (endMonth - startMonth)  -->
<xsl:variable name="months" select="($endYear - $startYear) * 12 + ($endMonth - $startMonth)"/>
<xsl:value-of select="$months"/>
</xsl:template>
<!--  Template to convert country code to full country name  -->
<xsl:template name="countryCodeToName">
<xsl:param name="code"/>
<xsl:choose>
<!--  Common country codes  -->
<xsl:when test="$code='GB'">United Kingdom</xsl:when>
<xsl:when test="$code='US'">United States</xsl:when>
<xsl:when test="$code='DE'">Germany</xsl:when>
<xsl:when test="$code='FR'">France</xsl:when>
<xsl:when test="$code='IT'">Italy</xsl:when>
<xsl:when test="$code='ES'">Spain</xsl:when>
<xsl:when test="$code='NL'">Netherlands</xsl:when>
<xsl:when test="$code='BE'">Belgium</xsl:when>
<xsl:when test="$code='CH'">Switzerland</xsl:when>
<xsl:when test="$code='AT'">Austria</xsl:when>
<xsl:when test="$code='IE'">Ireland</xsl:when>
<xsl:when test="$code='SE'">Sweden</xsl:when>
<xsl:when test="$code='NO'">Norway</xsl:when>
<xsl:when test="$code='DK'">Denmark</xsl:when>
<xsl:when test="$code='FI'">Finland</xsl:when>
<xsl:when test="$code='PL'">Poland</xsl:when>
<xsl:when test="$code='CZ'">Czech Republic</xsl:when>
<xsl:when test="$code='PT'">Portugal</xsl:when>
<xsl:when test="$code='GR'">Greece</xsl:when>
<xsl:when test="$code='CA'">Canada</xsl:when>
<xsl:when test="$code='AU'">Australia</xsl:when>
<xsl:when test="$code='NZ'">New Zealand</xsl:when>
<xsl:when test="$code='JP'">Japan</xsl:when>
<xsl:when test="$code='CN'">China</xsl:when>
<xsl:when test="$code='IN'">India</xsl:when>
<xsl:when test="$code='SG'">Singapore</xsl:when>
<xsl:when test="$code='HK'">Hong Kong</xsl:when>
<xsl:when test="$code='KR'">South Korea</xsl:when>
<xsl:when test="$code='BR'">Brazil</xsl:when>
<xsl:when test="$code='MX'">Mexico</xsl:when>
<xsl:when test="$code='AR'">Argentina</xsl:when>
<xsl:when test="$code='ZA'">South Africa</xsl:when>
<xsl:when test="$code='AE'">United Arab Emirates</xsl:when>
<xsl:when test="$code='SA'">Saudi Arabia</xsl:when>
<xsl:when test="$code='IL'">Israel</xsl:when>
<xsl:when test="$code='TR'">Turkey</xsl:when>
<xsl:when test="$code='RU'">Russia</xsl:when>
<xsl:when test="$code='UA'">Ukraine</xsl:when>
<!--  If no mapping found, return the code itself  -->
<xsl:otherwise>
<xsl:value-of select="$code"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!--  === BUSINESS LOGIC TEMPLATES (AVAILABLE BUT NOT DISPLAYED) ===  -->
<!--  Asset Management Logic from Master.xsl  -->
<xsl:template name="processAssetManagement">
<xsl:param name="lineNode"/>
<xsl:if test="$lineNode/assetType_l_c != ''">
<div class="asset-section">
<h4>Asset Information</h4>
<table class="full-width">
<tr>
<th class="column-header column-header-left">Asset Type</th>
<th class="column-header column-header-center">Original Qty</th>
<th class="column-header column-header-center">Amended Qty</th>
<th class="column-header column-header-left">Amendment Duration</th>
</tr>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="$lineNode/assetType_l_c"/>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="$lineNode/assetOriginalQuantity_l_c"/>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="$lineNode/assetAmendedQty_l_c"/>
</td>
<td class="cell-padding">
<xsl:value-of select="$lineNode/amendmentDuration_l_c"/>
months
</td>
</tr>
</table>
</div>
</xsl:if>
</xsl:template>
<!--  Billing & Auto-Renewal Logic from Master.xsl  -->
<xsl:template name="processBillingAndRenewal">
<xsl:param name="lineNode"/>
<xsl:if test="$lineNode/billingFrequency_l_c != '' or $lineNode/autoRenew_l_c != ''">
<div class="billing-section">
<!-- RAJ-Corrected the condition: replaced unescaped & with &amp; in text content -->
<h4>Billing &amp; Renewal Settings</h4>
<table class="full-width">
<tr>
<th class="column-header column-header-left">Billing Frequency</th>
<th class="column-header column-header-center">Auto Renewal</th>
<th class="column-header column-header-left">Add-On Start Date</th>
<th class="column-header column-header-left">Agreement Name</th>
</tr>
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="$lineNode/billingFrequency_l_c"/>
</td>
<td class="text-center cell-padding">
<xsl:choose>
<xsl:when test="$lineNode/autoRenew_l_c = 'Y'">✓ Enabled</xsl:when>
<xsl:otherwise>✗ Disabled</xsl:otherwise>
</xsl:choose>
</td>
<td class="cell-padding">
<xsl:value-of select="$lineNode/addOnStartDate_l_c"/>
</td>
<td class="cell-padding">
<xsl:value-of select="$lineNode/agreementName_t_c"/>
</td>
</tr>
</table>
</div>
</xsl:if>
</xsl:template>
<!--  Advanced Discount Logic from Master.xsl  -->
<xsl:template name="processAdvancedDiscounting">
<xsl:param name="lineNode"/>
<xsl:variable name="hasAdvancedDiscounts" select="$lineNode/currentDiscountEndCustomer_l_c != '' or $lineNode/currentDiscountReseller_l_c != ''"/>
<xsl:if test="$hasAdvancedDiscounts">
<div class="advanced-discount-section">
<h4>Advanced Discount Structure</h4>
<table class="full-width">
<tr>
<th class="column-header column-header-left">Customer Level</th>
<th class="column-header column-header-right">End Customer Discount</th>
<th class="column-header column-header-right">Reseller Discount</th>
<th class="column-header column-header-right">Net Price</th>
</tr>
<tr class="table-row">
<td class="cell-padding">Tiered Pricing</td>
<td class="text-right cell-padding">
<xsl:value-of select="$lineNode/currentDiscountEndCustomer_l_c"/>
%
</td>
<td class="text-right cell-padding">
<xsl:value-of select="$lineNode/currentDiscountReseller_l_c"/>
%
</td>
<td class="text-right cell-padding">
<xsl:call-template name="getExtendedNetPrice">
<xsl:with-param name="lineNode" select="$lineNode"/>
</xsl:call-template>
</td>
</tr>
</table>
</div>
</xsl:if>
</xsl:template>
<!--  Bundle Management Logic from Master.xsl  -->
<xsl:template name="processBundleManagement">
<xsl:param name="configNumber"/>
<xsl:variable name="bundleParentLines" select="//extractedLineItems/lineItem[configNumber_l_c = $configNumber and bundleParent_l_c != '']"/>
<xsl:if test="count($bundleParentLines) > 0">
<div class="bundle-section">
<h4>Product Bundle Structure</h4>
<table class="full-width">
<tr>
<th class="column-header column-header-left">Bundle Parent</th>
<th class="column-header column-header-left">Product Description</th>
<th class="column-header column-header-center">Bundle Qty</th>
<th class="column-header column-header-right">Bundle Price</th>
</tr>
<xsl:for-each select="$bundleParentLines">
<tr class="table-row">
<td class="cell-padding">
<xsl:value-of select="bundleParent_l_c"/>
</td>
<td class="cell-padding">
<xsl:value-of select="productDescription_l_c"/>
</td>
<td class="text-center cell-padding">
<xsl:value-of select="quantity_l_c"/>
</td>
<td class="text-right cell-padding">
¥
<xsl:value-of select="format-number(extendedNetPrice_l_c, '#,##0')"/>
</td>
</tr>
</xsl:for-each>
</table>
</div>
</xsl:if>
</xsl:template>
<!--  Comments & History Tracking from Master.xsl  -->
<xsl:template name="processCommentsHistory">
<xsl:param name="transactionData"/>
<xsl:if test="$transactionData/commentHistoryString_t_c != ''">
<div class="comments-section">
<!-- RAJ-Corrected the condition: replaced unescaped & with &amp; in text content -->
<h4>Quote Comments &amp; History</h4>
<div class="comment-history">
<xsl:value-of select="$transactionData/commentHistoryString_t_c"/>
</div>
</div>
</xsl:if>
</xsl:template>
<!--  Company Branding Logic from Master.xsl  -->
<xsl:template name="processCompanyBranding">
<xsl:param name="transactionData"/>
<xsl:if test="$transactionData/companyLogoURLForPrint_t_c != '' or $transactionData/companyPrintlogo_t_c != ''">
<div class="company-branding">
<xsl:if test="$transactionData/companyLogoURLForPrint_t_c != ''">
<img src="{$transactionData/companyLogoURLForPrint_t_c}" alt="Company Logo" class="company-logo"/>
</xsl:if>
<div class="company-print-info">
<xsl:value-of select="$transactionData/companyPrintlogo_t_c"/>
</div>
</div>
</xsl:if>
</xsl:template>
<!--  Contingency & Sold-To Logic from Master.xsl  -->
<xsl:template name="processContingencyInfo">
<xsl:param name="transactionData"/>
<xsl:if test="$transactionData/contingencySoldTo_t_c != ''">
<div class="contingency-section">
<h4>Contingency Information</h4>
<table class="full-width">
<tr>
<td class="category-label">Sold To:</td>
<td class="category-desc">
<xsl:value-of select="$transactionData/contingencySoldTo_t_c"/>
</td>
</tr>
</table>
</div>
</xsl:if>
</xsl:template>
<!--  Main Enhanced Template Call - Add this to your existing Child.xsl main template  -->
<xsl:template name="renderEnhancedMasterLogic">
<xsl:param name="configNumber"/>
<xsl:param name="transactionData" select="$_dsMain1"/>
<!--  Process all missing Master.xsl business logic  -->
<div class="master-logic-section">
<!--  Asset Management  -->
<xsl:for-each select="//extractedLineItems/lineItem[configNumber_l_c = $configNumber and assetType_l_c != '']">
<xsl:call-template name="processAssetManagement">
<xsl:with-param name="lineNode" select="."/>
</xsl:call-template>
</xsl:for-each>
<!--  Billing & Renewal  -->
<xsl:for-each select="//extractedLineItems/lineItem[configNumber_l_c = $configNumber and (billingFrequency_l_c != '' or autoRenew_l_c != '')]">
<xsl:call-template name="processBillingAndRenewal">
<xsl:with-param name="lineNode" select="."/>
</xsl:call-template>
</xsl:for-each>
<!--  Advanced Discounting  -->
<xsl:for-each select="//extractedLineItems/lineItem[configNumber_l_c = $configNumber and (currentDiscountEndCustomer_l_c != '' or currentDiscountReseller_l_c != '')]">
<xsl:call-template name="processAdvancedDiscounting">
<xsl:with-param name="lineNode" select="."/>
</xsl:call-template>
</xsl:for-each>
<!--  Bundle Management  -->
<xsl:call-template name="processBundleManagement">
<xsl:with-param name="configNumber" select="$configNumber"/>
</xsl:call-template>
<!--  Comments & History  -->
<xsl:call-template name="processCommentsHistory">
<xsl:with-param name="transactionData" select="$transactionData"/>
</xsl:call-template>
<!--  Company Branding  -->
<xsl:call-template name="processCompanyBranding">
<xsl:with-param name="transactionData" select="$transactionData"/>
</xsl:call-template>
<!--  SupportEdge Renewal Processing  -->
<xsl:call-template name="processSupportEdgeRenewals"/>
</div>
</xsl:template>
<!--  SupportEdge Renewal Processing Logic from Master.xsl  -->
<xsl:template name="processSupportEdgeRenewals">
<!-- RAJ-Corrected: Added complete SupportEdge renewal processing logic from Master.xsl -->
<xsl:if test="$_dsMain1/serviceRenewal_t_c != ''">
<!-- RAJ-Corrected: SES renewal lines processing -->
<xsl:variable name="SESRenewalsLines" select="/transaction/data_xml/document[(normalize-space(./@data_type)='2') and ./model_l/_model_name = 'Renewal Products']"/>
<xsl:for-each select="$SESRenewalsLines">
<xsl:variable name="_dsSub1" select="."/>
<xsl:if test="position()=1">
<xsl:variable name="hasSESRenewalsLines" select="boolean(count($SESRenewalsLines) > 0)"/>
<div class="support-edge-renewals-section">
<h3>SupportEdge Renewals Pricing Summary</h3>
<table class="full-width support-edge-table">
<!-- RAJ-Corrected: Dynamic column setup based on pricing configuration -->
<xsl:variable name="showListPrice" select="$_dsMain1/subtotalGrandTotal_t_c = 'listDiscountAndNetPricing'"/>
<xsl:variable name="showNetPrice" select="$_dsMain1/subtotalGrandTotal_t_c = 'onlyNetPricing' or $_dsMain1/subtotalGrandTotal_t_c = 'listDiscountAndNetPricing'"/>
<thead>
<tr>
<th class="column-header">Serial Number / Quote Linkage</th>
<th class="column-header">Service Period Duration</th>
<th class="column-header">Service Period Start Date</th>
<th class="column-header">Service Period End Date</th>
<xsl:if test="$showListPrice">
<th class="column-header text-right">Ext. List Price</th>
</xsl:if>
<xsl:if test="$showNetPrice">
<th class="column-header text-right">Ext. Net Price</th>
</xsl:if>
</tr>
</thead>
<tbody>
<!-- RAJ-Corrected: Process SES system renewal lines -->
<xsl:for-each select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and ./renewalIndicator_l_c = 'Y' and ./lineType_l = 'MODEL' and ./item_l/_part_number = 'SES-SYSTEM']">
<xsl:variable name="_dsSub1" select="."/>
<xsl:variable name="lineItemNumber" select="$_dsSub1/lineItemNumber_l_c"/>
<xsl:variable name="ChildLines" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and modelReferenceLineID_l_c = $lineItemNumber and (lineType_l = 'SERVICE' or printGrouping_l_c = 'SERVICE' or printGrouping_l_c = 'SERVICES' or printGrouping_l_c = 'Additional Service' or starts-with(item_l/_part_number, 'CS-'))]"/>
<xsl:variable name="ServiceStartDate" select="$ChildLines/serviceStartDate_l_c"/>
<xsl:variable name="ServiceEndDate" select="$ChildLines/serviceEndDate_l_c"/>
<xsl:variable name="ServiceDuration" select="$ChildLines/serviceDuration_l_c"/>
<tr class="table-row">
<td class="cell-padding">
<!-- RAJ-Corrected: Serial number processing -->
<xsl:choose>
<xsl:when test="$_dsSub1/addOnOriginalQuoteNumberSearch_l_c != ''">
<xsl:value-of select="$_dsSub1/serialNumber_l_c"/>
</xsl:when>
</xsl:choose>
<!-- RAJ-Corrected: Serial number array processing -->
<table class="serial-number-table">
<xsl:for-each select="./_commerce_array_set_attr_info[@setName='serialNumber_Array_l_c']/_array_set_row">
<xsl:sort select="./@_row_number" data-type="number" order="ascending"/>
<xsl:variable name="_dsTxnArray" select="."/>
<tr>
<td class="serial-cell">
<xsl:if test="$_dsTxnArray/attribute[@var_name='serialNumber_serialNumber_Array_l_c'] != ''">
<xsl:value-of select="$_dsTxnArray/attribute[@var_name='serialNumber_serialNumber_Array_l_c']"/>
</xsl:if>
</td>
<td class="serial-cell">
<xsl:if test="$_dsTxnArray/attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'] != ''">
<xsl:value-of select="concat(', ', $_dsTxnArray/attribute[@var_name='partnerSerialNumber_serialNumber_Array_l_c'])"/>
</xsl:if>
</td>
</tr>
</xsl:for-each>
</table>
</td>
<td class="text-center cell-padding">
<!-- RAJ-Corrected: Service duration display -->
<xsl:choose>
<xsl:when test="$ServiceDuration > '0'">
<xsl:value-of select="$ServiceDuration"/>
<xsl:choose>
<xsl:when test="$ServiceDuration = '1'">
<xsl:text> Month</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text> Months</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$_dsSub1/serviceDuration_l_c"/>
<xsl:choose>
<xsl:when test="$_dsSub1/serviceDuration_l_c = '1'">
<xsl:text> Month</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text> Months</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</td>
<td class="text-center cell-padding">
<!-- RAJ-Corrected: Service start date -->
<xsl:choose>
<xsl:when test="$ServiceDuration > '0'">
<!-- RAJ-Corrected: Date formatting - simplified for HTML -->
<xsl:value-of select="$ServiceStartDate"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="serviceStartDate_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<td class="text-center cell-padding">
<!-- RAJ-Corrected: Service end date -->
<xsl:choose>
<xsl:when test="$ServiceDuration > '0'">
<!-- RAJ-Corrected: Date formatting - simplified for HTML -->
<xsl:value-of select="$ServiceEndDate"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="serviceEndDate_l_c"/>
</xsl:otherwise>
</xsl:choose>
</td>
<xsl:if test="$showListPrice">
<td class="text-right cell-padding">
<!-- RAJ-Corrected: Extended list price -->
¥<xsl:value-of select="format-number(extendedListPrice_l_c, '#,##0')"/>
</td>
</xsl:if>
<xsl:if test="$showNetPrice">
<td class="text-right cell-padding">
<!-- RAJ-Corrected: Extended net price based on pricing tier -->
<xsl:variable name="extNetPrice">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="extendedNetPrice_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="extNetPriceResellerfloat_l_c"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="extnetPriceEndCustomerfloat_l_c"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'-1'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
¥<xsl:value-of select="format-number($extNetPrice, '#,##0')"/>
</td>
</xsl:if>
</tr>
</xsl:for-each>
</tbody>
</table>

<!-- RAJ-Corrected: Renewal grand total section -->
<xsl:if test="$_dsMain1/subtotalGrandTotal_t_c != 'noPricing'">
<div class="renewal-grand-total">
<table class="total-table">
<tr>
<td class="total-label">Renewals Grand Total:</td>
<td class="total-amount">
<!-- RAJ-Corrected: Calculate renewal total -->
<xsl:variable name="RenewalTotalCalculation" select="/transaction/data_xml/document[normalize-space(./@data_type)='3' and lineType_l = 'MODEL' and renewalIndicator_l_c = 'Y' and ./item_l/_part_number = 'SES-SYSTEM']"/>
<xsl:variable name="renewalGrandTotal">
<xsl:choose>
<xsl:when test="$pricingTier = '1' or $pricingTier = ''">
<xsl:value-of select="sum($RenewalTotalCalculation/extendedNetPrice_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '2'">
<xsl:value-of select="sum($RenewalTotalCalculation/extNetPriceResellerfloat_l_c)"/>
</xsl:when>
<xsl:when test="$pricingTier = '3'">
<xsl:value-of select="sum($RenewalTotalCalculation/extnetPriceEndCustomerfloat_l_c)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'-1'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
¥<strong><xsl:value-of select="format-number($renewalGrandTotal, '#,##0')"/></strong>
</td>
</tr>
</table>
</div>
</xsl:if>
</div>
</xsl:if>
</xsl:for-each>
</xsl:if>

<!-- Capacity Measurements Section -->
<xsl:variable name="EffectiveCapacityLines" select="exsl:node-set(/transaction/data_xml/document[(normalize-space(./@data_type)='2') and ./model_l/_model_name = 'Cluster Manager' and ./fusionEstiUsableCapacity_l_c!=''])"/>
<xsl:for-each select="$EffectiveCapacityLines">
	<xsl:if test="position()=1">
		<xsl:variable name="hasEffectiveCapacityLines" select="boolean(count($EffectiveCapacityLines) > 0)"/>
		<xsl:if test="$hasEffectiveCapacityLines">
			<div style="margin-top: 20px;">
				<h2 style="font-size: 18pt; font-weight: bold; color: #000000; margin-bottom: 10px;">Capacity Measurements</h2>
				<table style="border-collapse: collapse; width: 100%; margin-bottom: 20px;">
					<thead>
						<tr>
							<th style="border: 1px solid #949494; padding: 8px; background-color: #E1E1E1; text-align: left; font-weight: bold; font-size: 10pt;">Configuration</th>
							<th style="border: 1px solid #949494; padding: 8px; background-color: #E1E1E1; text-align: center; font-weight: bold; font-size: 10pt;">Storage Efficiency Factor</th>
							<th style="border: 1px solid #949494; padding: 8px; background-color: #E1E1E1; text-align: center; font-weight: bold; font-size: 10pt;">RAW Capacity (TB)</th>
							<th style="border: 1px solid #949494; padding: 8px; background-color: #E1E1E1; text-align: center; font-weight: bold; font-size: 10pt;">Effective Capacity (TB)</th>
							<th style="border: 1px solid #949494; padding: 8px; background-color: #E1E1E1; text-align: center; font-weight: bold; font-size: 10pt;">
								<xsl:choose>
									<xsl:when test="/transaction/data_xml/document/currency_t/@display_value">
										<xsl:value-of select="/transaction/data_xml/document/currency_t/@display_value"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="/transaction/data_xml/document/currency_t"/>
									</xsl:otherwise>
								</xsl:choose>
								/ TB (Effective Capacity)
							</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="$EffectiveCapacityLines">
							<xsl:sort select="./@_document_number" order="ascending"/>
							<xsl:variable name="_dsSub1" select="."/>
							<tr>
								<td style="border: 1px solid #949494; padding: 8px; text-align: left; font-size: 10pt;">
									<xsl:choose>
										<xsl:when test="$_dsSub1/virtualConfigName_l_c/@display_value">
											<xsl:value-of select="$_dsSub1/virtualConfigName_l_c/@display_value"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$_dsSub1/virtualConfigName_l_c"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td style="border: 1px solid #949494; padding: 8px; text-align: center; font-size: 10pt;">
									<!-- Note: convertJsonToXml template would be needed here for full functionality -->
									<!-- For now, showing placeholder -->
									<xsl:text>N/A</xsl:text>
								</td>
								<td style="border: 1px solid #949494; padding: 8px; text-align: center; font-size: 10pt;">
									<!-- Note: convertJsonToXml template would be needed here for full functionality -->
									<!-- For now, showing placeholder -->
									<xsl:text>N/A</xsl:text>
								</td>
								<td style="border: 1px solid #949494; padding: 8px; text-align: center; font-size: 10pt;">
									<!-- Note: convertJsonToXml template would be needed here for full functionality -->
									<!-- For now, showing placeholder -->
									<xsl:text>N/A</xsl:text>
								</td>
								<td style="border: 1px solid #949494; padding: 8px; text-align: center; font-size: 10pt;">
									<xsl:variable name="Effective">
										<!-- Note: This would need the JSON parsing logic -->
										<xsl:text>0</xsl:text>
									</xsl:variable>
									<xsl:variable name="extNetPrice">
										<xsl:choose>
											<xsl:when test="/transaction/data_xml/document/pricingTierForPrint_t_c = '1' or /transaction/data_xml/document/pricingTierForPrint_t_c = ''">
												<xsl:value-of select="extendedNetPrice_l_c"/>
											</xsl:when>
											<xsl:when test="/transaction/data_xml/document/pricingTierForPrint_t_c = '2'">
												<xsl:value-of select="extNetPriceResellerfloat_l_c"/>
											</xsl:when>
											<xsl:when test="/transaction/data_xml/document/pricingTierForPrint_t_c = '3'">
												<xsl:value-of select="extnetPriceEndCustomerfloat_l_c"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="-1"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$extNetPrice > 0">
											<xsl:value-of select="format-number(($extNetPrice div $Effective), '0.##')"/>
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>

				<!-- Capacity Measurement Information -->
				<table style="border-collapse: collapse; width: 100%;">
					<tr>
						<td style="border: 1px solid #949494; padding: 15px; background-color: #E1E1E1;">
							<h3 style="font-size: 14pt; font-weight: bold; margin: 0 0 10px 0;">Capacity Measurement Information</h3>
							<p style="margin: 0; font-size: 9pt; line-height: 1.4;">
								The table above contains estimates and is for informational purposes only. It does not constitute an offer. To apply for the NetApp Efficiency Guarantee, Customer must submit a request and provide a signed copy of the terms and conditions prior to placing a purchase order for an eligible flash solution. Contact your NetApp representative for further details.
							</p>
						</td>
					</tr>
				</table>
			</div>
		</xsl:if>
	</xsl:if>
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>