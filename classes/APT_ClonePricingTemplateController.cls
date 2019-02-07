/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_ClonePricingTemplate page.
* @Date:		09/2015
* @ConstructorParam:	stdController - Standard Controller for "Pricing Template" object
* @TestClass:	ZZTEST_APT_ClonePricingTemplateCtr
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_ClonePricingTemplateController {
	private Pricing_Template__c pricingTemplate;
	private Id pricingTemplateId;
	private Map<Id, PricingGroupWrapper> mapPricingGroups;
	public List<PricingGroupWrapper> pricingGroups { get; set; }
	public List<StandardPricingWrapper> standardPricings { get; set; }

	public APT_ClonePricingTemplateController(ApexPages.StandardController stdController) {
		pricingTemplate = (Pricing_Template__c)stdController.getRecord();
		pricingTemplateId = ApexPages.currentPage().getParameters().get('id');

		mapPricingGroups = new Map<Id, PricingGroupWrapper>();
		standardPricings = new List<StandardPricingWrapper>();
		for(Standard_Pricing__c standardPricing : [SELECT Id, Name, Pricing_Deal_Product__c, Pricing_Deal_Product__r.Pricing_Group__c, 
													Pricing_Group__c, Product_Category__c, Product_Type__c, Pricing_Deal_Product_Name__c,
													VAT_Inclusive__c, Price__c
													FROM Standard_Pricing__c WHERE Pricing_Template__c = :pricingTemplateId
													ORDER BY Pricing_Deal_Product__r.Pricing_Group__r.Report_Sequence__c,
													Pricing_Deal_Product__r.Report_Sequence__c]){
			Standard_Pricing__c newStandardPricing = new Standard_Pricing__c();
			newStandardPricing.Pricing_Deal_Product__c = standardPricing.Pricing_Deal_Product__c;
			newStandardPricing.Price__c = standardPricing.Price__c;
			
			Id pricingGroupId = standardPricing.Pricing_Deal_Product__r.Pricing_Group__c;
			standardPricings.add(new StandardPricingWrapper(standardPricing, newStandardPricing));

			if(!mapPricingGroups.containsKey(pricingGroupId)){
				mapPricingGroups.put(pricingGroupId, new PricingGroupWrapper(standardPricing.Pricing_Group__c));
			} 
			mapPricingGroups.get(pricingGroupId).standardPricings.add(new StandardPricingWrapper(standardPricing, newStandardPricing));
		}
		pricingGroups = mapPricingGroups.values();
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to save new Pricing Template and related Standard Pricings.
	* @param 		None
	* @Returns:		View page for created Pricing Template - if saved successfully
	*				null - in case of errors
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference save(){
		Pricing_Template__c newPricingTemplate = new Pricing_Template__c();
		newPricingTemplate.Name = pricingTemplate.Name;
		newPricingTemplate.Type__c = pricingTemplate.Type__c;
		newPricingTemplate.Year__c = pricingTemplate.Year__c;
		newPricingTemplate.Address__c = pricingTemplate.Address__c;
		newPricingTemplate.Phone_Fax__c = pricingTemplate.Phone_Fax__c;
		newPricingTemplate.Website__c = pricingTemplate.Website__c;
		newPricingTemplate.Title__c = pricingTemplate.Title__c;
		newPricingTemplate.Section_1__c = pricingTemplate.Section_1__c;
		newPricingTemplate.Section_2__c = pricingTemplate.Section_2__c;
		newPricingTemplate.On_Behalf__c = pricingTemplate.On_Behalf__c;
		newPricingTemplate.Title_for_Group_Entities__c = pricingTemplate.Title_for_Group_Entities__c;
		newPricingTemplate.Title_for_Pricing_Groups__c = pricingTemplate.Title_for_Pricing_Groups__c;
		newPricingTemplate.Section_3__c = pricingTemplate.Section_3__c;
		newPricingTemplate.Legal_Info__c = pricingTemplate.Legal_Info__c;

		Savepoint sp = Database.setSavepoint();
		try{
			insert newPricingTemplate;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		List<Standard_Pricing__c> standardPricingsToIns = new List<Standard_Pricing__c>();
		for(StandardPricingWrapper standardPricingWrapp : standardPricings){
			if(standardPricingWrapp.isSelected){
				standardPricingWrapp.newStandardPricing.Pricing_Template__c = newPricingTemplate.Id;
				standardPricingsToIns.add(standardPricingWrapp.newStandardPricing);
			}
		}

		try{
			insert standardPricingsToIns;
		} catch(DmlException ex){
			Database.rollback(sp);
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		return new ApexPages.StandardController(newPricingTemplate).view();
	}

	public class PricingGroupWrapper{
		public Boolean isSelected { get; set; }
		public String name { get; set; }
		public List<StandardPricingWrapper> standardPricings { get; set; }

		public PricingGroupWrapper(String name){
			this.isSelected = true;
			this.name = name;
			this.standardPricings = new List<StandardPricingWrapper>();
		}
	}

	public class StandardPricingWrapper {
		public Boolean isSelected { get; set; }
		public Standard_Pricing__c standardPricing { get; set; }
		public Standard_Pricing__c newStandardPricing { get; set; }

		public StandardPricingWrapper(Standard_Pricing__c standardPricing, Standard_Pricing__c newStandardPricing){
			this.isSelected = true;
			this.standardPricing = standardPricing;
			this.newStandardPricing = newStandardPricing;
		}
	}
}