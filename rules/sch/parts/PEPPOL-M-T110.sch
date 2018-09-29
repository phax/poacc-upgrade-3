<?xml version="1.0" encoding="UTF-8"?>    
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:u="utils" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        schemaVersion="iso" queryBinding="xslt2">

	<title>Rules for PEPPOL BIS 3.0 Order Agreement</title>


	<ns prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"/>
	<ns prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"/>
	<ns prefix="ubl" uri="urn:oasis:names:specification:ubl:schema:xsd:OrderResponse-2"/>
	<ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
	<ns uri="utils" prefix="u"/>


	<!-- Functions -->
	
	<function xmlns="http://www.w3.org/1999/XSL/Transform" name="u:slack" as="xs:boolean">
		<param name="exp" as="xs:decimal"/>
		<param name="val" as="xs:decimal"/>
		<param name="slack" as="xs:decimal"/>
		<value-of select="xs:decimal($exp + $slack) &gt;= $val and xs:decimal($exp - $slack) &lt;= $val"/>
	</function>
	
	<pattern id="business_rules">

		<let name="documentCurrencyCode" value="/ubl:OrderResponse/cbc:DocumentCurrencyCode"/>
		<rule context="cac:Price">
			<assert id="PEPPOL-T110-R001"
                    test="number(cbc:PriceAmount) &gt;=0"    
                    flag="fatal">Prices of items SHALL not be negative.
			</assert>   
		</rule>
		<rule context="cac:Item">
			<assert id= "PEPPOL-T110-R002"
                    test="(cac:StandardItemIdentification/cbc:ID) or  (cac:SellersItemIdentification/cbc:ID)"
                    flag="fatal">Each item in an Order agreement line SHALL be identifiable by either “item sellers identifier” or “item standard identifier”                 
			</assert>
			<assert id= "PEPPOL-T110-R003"
                    test="(cbc:Name)"
                    flag="fatal">Each Order agreement line SHALL contain the item name                 
			</assert>
		</rule>   
		<rule context="cbc:Amount | cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:PriceAmount | cbc:BaseAmount | cac:LegalMonetaryTotal/cbc:*">      
			<assert id="PEPPOL-T110-R004"
                    test="not(@currencyID) or @currencyID = $documentCurrencyCode"
                    flag="fatal">All amounts SHALL have same currency code as document currency</assert>
			<assert id="PEPPOL-T110-R013"
				test="ancestor::node()/local-name() = 'Price' or string-length(substring-after(., '.')) &lt;= 2"
				flag="fatal">Elements of data type amount cannot have more than 2 decimals (I.e. all amounts except unit price amounts)</assert>
		</rule>

		<rule context="cac:LegalMonetaryTotal">

			<let name="lineExtensionAmount" value="xs:decimal(if (cbc:LineExtensionAmount) then cbc:LineExtensionAmount else 0)"/>
			<let name="allowanceTotalAmount" value="xs:decimal(if (cbc:AllowanceTotalAmount) then cbc:AllowanceTotalAmount else 0)"/>
			<let name="chargeTotalAmount" value="xs:decimal(if (cbc:ChargeTotalAmount) then cbc:ChargeTotalAmount else 0)"/>
			<let name="taxExclusiveAmount" value="xs:decimal(if (cbc:TaxExclusiveAmount) then cbc:TaxExclusiveAmount else 0)"/>
			<let name="taxInclusiveAmount" value="xs:decimal(if (cbc:TaxInclusiveAmount) then cbc:TaxInclusiveAmount else 0)"/>
			<let name="payableRoundingAmount" value="xs:decimal(if (cbc:PayableRoundingAmount) then cbc:PayableRoundingAmount else 0)"/>
			<let name="payableAmount" value="xs:decimal(if (cbc:PayableAmount) then cbc:PayableAmount else 0)"/>
			<let name="prepaidAmount" value="xs:decimal(if (cbc:PrepaidAmount) then cbc:PrepaidAmount else 0)"/>


			<let name="taxTotal" value="xs:decimal(if (/ubl:OrderResponse/cac:TaxTotal/cbc:TaxAmount) then (/ubl:OrderResponse/cac:TaxTotal/cbc:TaxAmount) else 0)"/>
			<let name="allowanceTotal" value="xs:decimal(sum(/ubl:OrderResponse/cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount))"/>
			<let name="chargeTotal" value="xs:decimal(sum(/ubl:OrderResponse/cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount))"/>
			<let name="lineExtensionTotal" value="xs:decimal(sum(//cac:OrderLine/cac:LineItem/cbc:LineExtensionAmount))"/>

			<assert id="PEPPOL-T110-R014"
				test="count(//cac:OrderLine) = count(//cac:LineItem/cbc:LineExtensionAmount)"
				flag="fatal">If document totals is provided, all order agreement lines SHALL have a line extension amount</assert>

			<assert id="PEPPOL-T110-R005"
              test="not(cbc:PayableAmount) or cbc:PayableAmount &gt;= 0"
              flag="fatal">Total amount for payment SHALL NOT be negative, if expected total amount for payment is provided.</assert>

			<assert id="PEPPOL-T110-R006"
              test="$lineExtensionAmount &gt;= 0"
              flag="fatal">Total amount for payment SHALL NOT be negative, if expected total amount for payment is provided.</assert>

			<assert id="PEPPOL-T110-R007"
              test="not(cbc:LineExtensionAmount) or $lineExtensionAmount = $lineExtensionTotal"
              flag="fatal">Total sum of line amounts SHALL equal the sum of the order line amounts at order line level, if total sum of line amounts is provided.</assert>

			<assert id="PEPPOL-T110-R008"
              test="not(cbc:ChargeTotalAmount) or $chargeTotalAmount = $chargeTotal"
              flag="fatal">Total sum of charges at document level SHALL be equal to the sum of charges at document level, if total sum of charges at document level is provided.</assert>

			<assert id="PEPPOL-T110-R009"
              test="not(cbc:AllowanceTotalAmount) or $allowanceTotalAmount = $allowanceTotal"
              flag="fatal">Total sum of allowance at document level SHALL be equal to the sum of allowance amounts at document level, if total sum of allowance at document level is provided.</assert>

			<assert id="PEPPOL-T110-R010"
              test="not(cbc:TaxExclusiveAmount) or $taxExclusiveAmount = $lineExtensionAmount + $chargeTotalAmount - $allowanceTotalAmount"
              flag="fatal">Tax exclusive amount SHALL equal the sum of line amount plus total charge amount at document level less total allowance amount at document level if tax exclusive amount is provided.</assert>

			<assert id="PEPPOL-T110-R011"
              test="$taxInclusiveAmount = $taxExclusiveAmount + $taxTotal"
              flag="fatal">Tax inclusive amount SHALL equal tax exclusive amount plus total tax amount.</assert>

			<assert id="PEPPOL-T110-R012"
              test="not(cbc:PayableAmount) or $payableAmount = $taxInclusiveAmount - $prepaidAmount + $payableRoundingAmount"
              flag="fatal">Total amount for payment SHALL be equal to the tax inclusive amount minus the prepaid amount plus rounding amount</assert>

		</rule>
		
		<!-- Allowance/Charge -->
		<rule context="cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]">
			<assert id="PEPPOL-T110-R015"
				test="false()"
				flag="fatal">Allowance/charge base amount SHALL be provided when allowance/charge percentage is provided.</assert>
		</rule>
		
		<rule context="cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]">
			<assert id="PEPPOL-T110-R016"
				test="false()"
				flag="fatal">Allowance/charge percentage SHALL be provided when allowance/charge base amount is provided.</assert>
		</rule>  
		
		<rule context="//ubl:OrderResponse/cac:AllowanceCharge">
			<assert id="PEPPOL-T110-R017"
				test="not(cbc:MultiplierFactorNumeric and cbc:BaseAmount) or u:slack(if (cbc:Amount) then cbc:Amount else 0, (xs:decimal(cbc:BaseAmount) * xs:decimal(cbc:MultiplierFactorNumeric)) div 100, 0.02)"
				flag="fatal">Allowance/charge amount SHALL equal base amount * percentage/100 if base amount and percentage exists</assert>
			<assert id="PEPPOL-T110-R018"
				test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)"
				flag="fatal">Each document or line level allowance SHALL have an allowance reason text or an allowance reason code.</assert>
		</rule>
		
		<rule context="cac:TaxCategory | cac:ClassifiedTaxCategory">
			<assert id="PEPPOL-T110-R019"
				test="cbc:Percent or (normalize-space(cbc:ID)='O')"
				flag="fatal">Each Tax Category SHALL have a VAT category rate, except if the order is not subject to VAT.</assert>            
			<assert id="PEPPOL-T110-R020"
				test="not(normalize-space(cbc:ID)='S') or (cbc:Percent) &gt; 0" 
				flag="fatal">When VAT category code is "Standard rated" (S) the VAT rate SHALL be greater than zero.</assert>            
		</rule>

	</pattern>
</schema>