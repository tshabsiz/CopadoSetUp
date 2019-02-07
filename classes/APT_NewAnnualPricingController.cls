/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_NewAnnualPricing page.
* @Date:		09/2015
* @ConstructorParam:	stdController - Standard Controller for "Annual Pricing" object
* @TestClass:	ZZTEST_APT_NewAnnualPricingController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_NewAnnualPricingController {
	public Boolean arePricingGroupsConfigured { get; set; }
	public Boolean isPricingGroupSelected { get; set; }
	public Boolean areAllPricingGroupsSelected { get; set; }
	public String organisation { get; set; }
	public String pricingTemplate { get; set; }
	private Annual_Pricing__c annualPricing;
	public List<PricingGroupWrapper> pricingGroups { get; set; }
	public Map<Id, PricingGroupWrapper> pricingGroupsMap { get; set; }

	public APT_NewAnnualPricingController(ApexPages.StandardController stdController) {
		annualPricing = (Annual_Pricing__c)stdController.getRecord();
		arePricingGroupsConfigured = true;
		isPricingGroupSelected = false;
		areAllPricingGroupsSelected = true;

		pricingGroupsMap = new Map<Id, PricingGroupWrapper>();
		for(Pricing_Group__c pricingGroup : [SELECT Id, Name FROM Pricing_Group__c ORDER BY Report_Sequence__c]){
			pricingGroupsMap.put(pricingGroup.Id, new PricingGroupWrapper(pricingGroup));
		}
		pricingGroups = pricingGroupsMap.values();
		if(pricingGroups.isEmpty()){
			arePricingGroupsConfigured = false;
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_PricingGroupsNotConfigured));
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to query Pricing Deal Products for all selected Pricing Groups.
	* @param 		None
	* @Returns:		current page with list of Pricing Deal Products
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference next(){
        Set<Id> pricingGroupIds = new Set<Id>();
        for(PricingGroupWrapper pricingGroupWrapper : pricingGroups){
        	if(pricingGroupWrapper.isSelected){
        		pricingGroupIds.add(pricingGroupWrapper.pricingGroup.Id);
        	}
        }
        if(pricingGroupIds.isEmpty()){
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_AtLeastOnePricingGroupRequired));
        	return null;
        } else{
        	isPricingGroupSelected = true;
        }

        Set<Id> pricingDealProductIds = new Set<Id>();
        for(Standard_Pricing__c standardPricing : [SELECT Pricing_Deal_Product__c FROM Standard_Pricing__c 
        											WHERE Pricing_Template__c = :annualPricing.Pricing_Template__c]){
        	pricingDealProductIds.add(standardPricing.Pricing_Deal_Product__c);
        }

        Map<Id, List<PricingDealProductWrapper>> mapPricingDealProductWrapp = new Map<Id, List<PricingDealProductWrapper>>();
        for(Pricing_Deal_Product__c pricingDealProduct : [SELECT Id,  Name, Pricing_Deal_Product_Name__c, Pricing_Group__c, Product_Category__c, Product_Type__c
        										FROM Pricing_Deal_Product__c 
        										WHERE  Id IN :pricingDealProductIds AND Pricing_Group__c IN :pricingGroupIds
        										ORDER BY Pricing_Group__r.Report_Sequence__c, Report_Sequence__c]){
        	if(mapPricingDealProductWrapp.containsKey(pricingDealProduct.Pricing_Group__c)){
        		mapPricingDealProductWrapp.get(pricingDealProduct.Pricing_Group__c).add(new PricingDealProductWrapper(pricingDealProduct));
        	} else{
        		mapPricingDealProductWrapp.put(pricingDealProduct.Pricing_Group__c, new List<PricingDealProductWrapper>{new PricingDealProductWrapper(pricingDealProduct)});
			}
        }

        for(PricingGroupWrapper pricingGroupWrapper : pricingGroups){
        	if(mapPricingDealProductWrapp.containsKey(pricingGroupWrapper.pricingGroup.Id)){
        		pricingGroupWrapper.pricingDealProducts = mapPricingDealProductWrapp.get(pricingGroupWrapper.pricingGroup.Id);
        		pricingGroupWrapper.isEmpty = pricingGroupWrapper.pricingDealProducts.isEmpty() ? true : false;
        	}
        }

        try{
        	Account acc = [SELECT Name FROM Account WHERE Id = :annualPricing.Organisation__c];
        	Pricing_Template__c pt = [SELECT Name FROM Pricing_Template__c WHERE Id = :annualPricing.Pricing_Template__c];
        	organisation = acc.Name;
        	pricingTemplate = pt.Name;
        } catch(QueryException ex){
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        	return null;
        }

		return null;
    }

    /**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to save new Annual Pricing and all related Annual Pricing Items.
	* @param 		None
	* @Returns:		View page for created Annual Pricing - if saved successfully
	*				null - in case of errors
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
    public PageReference save() {
		//annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED;
        annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_STANDARD_PRICING;
        Set<Id> pricingDealProductIds = new Set<Id>();
        for(PricingGroupWrapper pricingGroupWrapper : pricingGroups){
        	for(PricingDealProductWrapper pricingDealProductWrapper : pricingGroupWrapper.pricingDealProducts){
        		if(pricingDealProductWrapper.isSelected){
        			pricingDealProductIds.add(pricingDealProductWrapper.pricingDealProduct.Id);
        		}
        	}
        }
        
        if(pricingDealProductIds.isEmpty()){
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_AtLeastOnePricingDealProductRequired));
        	return null;
        }

        Savepoint sp = Database.setSavepoint();
        try{
			insert annualPricing;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        	return null;
		}

		Map<Id, Standard_Pricing__c> mapStandardPricings = new Map<Id, Standard_Pricing__c>();
		for(Standard_Pricing__c standardPricing : [SELECT Id, Pricing_Deal_Product__c, Price__c, VAT_Inclusive__c
														FROM Standard_Pricing__c  
														WHERE Pricing_Template__c = :annualPricing.Pricing_Template__c
														AND Pricing_Deal_Product__c IN :pricingDealProductIds]){
			mapStandardPricings.put(standardPricing.Pricing_Deal_Product__c, standardPricing);
		}

		List<Annual_Pricing_Item__c> annualPricingItems = new List<Annual_Pricing_Item__c>();
		for(Pricing_Deal_Product__c pricingDealProduct : [SELECT Id,  Name FROM Pricing_Deal_Product__c 
															WHERE Id IN :pricingDealProductIds
															ORDER BY Pricing_Group__r.Report_Sequence__c, Report_Sequence__c]){
			Annual_Pricing_Item__c annualPricingItem = new Annual_Pricing_Item__c();
			annualPricingItem.Annual_Pricing__c = annualPricing.Id;
			annualPricingItem.Pricing_Deal_Product__c = pricingDealProduct.Id;
			if(mapStandardPricings.containsKey(pricingDealProduct.Id)){
				annualPricingItem.Standard_Pricing__c = mapStandardPricings.get(pricingDealProduct.Id).Id;
			}
			annualPricingItems.add(annualPricingItem);
		}

		try{
			insert annualPricingItems;
		} catch(DmlException ex){
			Database.rollback(sp);
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		return new ApexPages.StandardController(annualPricing).view();
    }

	public class PricingGroupWrapper {
		public Boolean isSelected { get; set; }		//Indicates if Pricing Group is selected
		public Boolean isEmpty { get; set; }		//Indicates if Pricing Group contains any Pricing Deal Product
		public Boolean areAllPricingDealProductsSelected { get; set; }	//Indicates if all Pricing Deal Products /within this Pricing Group/ are selected
		public Pricing_Group__c pricingGroup { get; set; }
		public List<PricingDealProductWrapper> pricingDealProducts { get; set; }

		public PricingGroupWrapper(Pricing_Group__c pricingGroup){
			this.isSelected = true;
			this.isEmpty = true;
			this.areAllPricingDealProductsSelected = true;
			this.pricingGroup = pricingGroup;
			this.pricingDealProducts = new List<PricingDealProductWrapper>();
		}
	}

	public class PricingDealProductWrapper {
		public Boolean isSelected { get; set; }
		public Pricing_Deal_Product__c pricingDealProduct { get; set; }

		public PricingDealProductWrapper(Pricing_Deal_Product__c pricingDealProduct){
			this.isSelected = true;
			this.pricingDealProduct = pricingDealProduct;
		}
	}
}