/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_GeneratePricingLetter page.
* @Date:		09/2015
* @ConstructorParam:		stdController - Standard Controller for "Annual Pricing" object
* @TestClass:	ZZTEST_APT_GeneratePricingLetterCtr
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_GeneratePricingLetterController {
	private Annual_Pricing__c annualPricing;

	public APT_GeneratePricingLetterController(ApexPages.StandardController stdController) {
		annualPricing = (Annual_Pricing__c)stdController.getRecord();

		if(String.isBlank(annualPricing.Billing_Street__c) && String.isBlank(annualPricing.Billing_City__c) && String.isBlank(annualPricing.Billing_Zip_Postal_Code__c)){
			annualPricing.Billing_Street__c = annualPricing.Organisation__r.BillingStreet;
			annualPricing.Billing_City__c = annualPricing.Organisation__r.BillingCity;
			annualPricing.Billing_Zip_Postal_Code__c = annualPricing.Organisation__r.BillingPostalCode;
		}
		if(String.isBlank(annualPricing.Name_of_group_of_companies__c) && String.isBlank(annualPricing.Name_of_holding_company__c)){
			annualPricing.Name_of_group_of_companies__c = annualPricing.Organisation__r.Name;
			annualPricing.Name_of_holding_company__c = annualPricing.Organisation__r.Name;
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to generate Pricing Letter in MS Word and save it as attachment.
	* @param 		None
	* @Returns:		View page for Annual Pricing object
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference generateMsWord(){
		try{
			PageReference pricingLetterPageRef = Page.APT_PricingLetter;
			pricingLetterPageRef.getParameters().put('id', annualPricing.Id);
			pricingLetterPageRef.setRedirect(true);

			Attachment att = new Attachment();
			Blob body = Test.isRunningTest() ? Blob.ValueOf('dummy text') : pricingLetterPageRef.getContent();
			att.Body = body;
			att.Name='Pricing_Letter_' + System.now().format('yyyyMMdd') + '.doc';
			att.parentId = annualPricing.id;
			insert att;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		PageReference pageRef = new ApexPages.StandardController(annualPricing).view();
		return pageRef;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to generate Pricing Letter in PDF and save it as attachment.
	* @param 		None
	* @Returns:		View page for Annual Pricing object
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference generatePdf(){
		try{
			PageReference pricingLetterPageRef = Page.APT_PricingLetterPdf;
			pricingLetterPageRef.getParameters().put('id', annualPricing.Id);
			pricingLetterPageRef.setRedirect(true);

			Attachment att = new Attachment();
			Blob body = Test.isRunningTest() ? Blob.ValueOf('dummy text') : pricingLetterPageRef.getContent();
			att.Body = body;
			att.Name='Pricing_Letter_' + System.now().format('yyyyMMdd') + '.pdf';
			att.parentId = annualPricing.id;
			insert att;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}
		PageReference pageRef = new ApexPages.StandardController(annualPricing).view();
		return pageRef;
	}
}