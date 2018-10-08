<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron">

	<rule context="ubl:Catalogue">
		<assert id="PEPPOL-T77-R001"
				test="(cac:ValidityPeriod/cbc:EndDate) and (number(translate(cac:ValidityPeriod/cbc:EndDate,'-','')) &gt;= number(translate(cbc:IssueDate,'-','')))"
				flag="fatal">The validity period end date may not be earlier than the issue date.</assert>
	</rule>

	<rule context="cac:CatalogueLine">
		<assert id="PEPPOL-T77-R002"
				test="(( normalize-space(.) = 'OTH' and (../cbc:StatusReason != ' ') ) or normalize-space(.) != 'OTH') "
				flag="fatal">Shopping cart line quantities SHALL be greater than ZERO.</assert>
	</rule>

	<rule context="cac:RequiredItemLocationQuantity/cac:Price">
		<assert id="PEPPOL-T77-R003"
				test="number(cbc:PriceAmount) &gt;=0"
				flag="fatal">Prices of items SHALL not be negative</assert>
	</rule>

	<rule context="cac:Item">
		<assert id="PEPPOL-T77-R004"
				test="(cac:StandardItemIdentification/cbc:ID) or  (cac:SellersItemIdentification/cbc:ID)"
				flag="fatal">Each item in a shopping cart line SHALL be identifiable by either "item sellers identifier" or "item standard identifier"</assert>
		<assert id="PEPPOL-T77-R005"
				test="(count(cac:ItemSpecificationDocumentReference[cbc:DocumentTypeCode = 'main_image']) &lt;= 1)"
				flag="fatal">Only one attachment may be identified as main image.</assert>
	</rule>

	<rule context="cac:CatalogueLine/cac:RequiredItemLocationQuantity">
		<assert id="PEPPOL-T77-R006"
				test="(cac:Price/cbc:BaseQuantity/@unitCode) = (cac:DeliveryUnit/cbc:BatchQuantity/@unitCode) or (not(cac:Price/cbc:BaseQuantity)) or (not(cac:DeliveryUnit/cbc:BatchQuantity))"
				flag="fatal">Unit code for price base quantity SHALL be same as for batch quantity.</assert>
	</rule>

	<rule context="cac:Item/cac:AdditionalItemProperty[cbc:Name = 'ServiceIndicator']">
		<assert id="PEPPOL-T77-R007"
				test="(cbc:Value = 'true' or cbc:Value = 'false')"
				flag="fatal">For AdditionalItemProperties where name is ServiceIndicator the value may only be "true" or "false".</assert>
	</rule>

	<rule context="cac:ClassifiedTaxCategory">
		<assert id="PEPPOL-T77-R008"
			test="cbc:Percent or (normalize-space(cbc:ID)='O')"
			flag="fatal">Each Tax Category SHALL have a VAT category rate, except if the shopping cart is not subject to VAT.</assert>
		<assert id="PEPPOL-T77-R009"
			test="not(normalize-space(cbc:ID)='S') or (cbc:Percent) &gt; 0"
			flag="fatal">When VAT category code is "Standard rated" (S) the VAT rate SHALL be greater than zero.</assert>
	</rule>
	
</pattern>
