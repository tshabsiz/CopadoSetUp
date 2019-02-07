/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for APT_NewAnnualPricingController
*              Tests executed:
*               1 - testPricingGroupNotConfigured()
*                   Test that Pricing Groups are configured - at least one Pricing Group should be existing in the system.
*               2 - testPricingGroupRequired()
*                   Test that at least one Pricing Group has been selected.
*               3 - testCreateAnnualPricing()
*                   Test that Annual Pricing and all related Annual Pricing Items can be saved.
*/
@isTest
private class ZZTEST_APT_NewAnnualPricingController {

	public static testMethod void testPricingGroupNotConfigured(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getInsertedProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);
        
        Test.startTest();

		PageReference APT_NewAnnualPricing = Page.APT_NewAnnualPricing;
        Test.setCurrentPage(APT_NewAnnualPricing);

    	Annual_Pricing__c annualPricing = new Annual_Pricing__c();
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(annualPricing);
        APT_NewAnnualPricingController controller = new APT_NewAnnualPricingController(stc);
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;

        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.Error);	
        System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.errMsg_PricingGroupsNotConfigured);

        Test.stopTest();
	}
	
	public static testMethod void testPricingGroupRequired(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
		ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        Pricing_Group__c pricingGroup1 = pricingGroupFactory.getProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        Pricing_Group__c pricingGroup2 = pricingGroupFactory.getProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        List<Pricing_Group__c> pricingGroups = new List<Pricing_Group__c>{pricingGroup1, pricingGroup2};
        insert pricingGroups;
        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getInsertedProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);

        Test.startTest();

		PageReference APT_NewAnnualPricing = Page.APT_NewAnnualPricing;
        Test.setCurrentPage(APT_NewAnnualPricing);

    	Annual_Pricing__c annualPricing = new Annual_Pricing__c();
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(annualPricing);
        APT_NewAnnualPricingController controller = new APT_NewAnnualPricingController(stc);
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;

        for(APT_NewAnnualPricingController.PricingGroupWrapper pricingGroup : controller.pricingGroups){
            pricingGroup.isSelected = false;
        }

        controller.next();
        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.Error);	
        System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.errMsg_AtLeastOnePricingGroupRequired);

        Test.stopTest();
	}

	public static testMethod void testCreateAnnualPricing(){
		Integer GROUP_ITEMS_SIZE = 30;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
		ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        Pricing_Group__c pricingGroup1 = pricingGroupFactory.getProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        Pricing_Group__c pricingGroup2 = pricingGroupFactory.getProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        List<Pricing_Group__c> pricingGroups = new List<Pricing_Group__c>{pricingGroup1, pricingGroup2};
        insert pricingGroups;
        List<Pricing_Deal_Product__c> pricingDealProducts = new List<Pricing_Deal_Product__c>();
        for(Integer i=0; i<GROUP_ITEMS_SIZE; i++){
        	Pricing_Deal_Product__c pricingDealProduct1 = pricingDealProductFactory.getProduct(ZZTEST_F_PricingDealProduct.PricingDealProductRecordType.DEFAULT_PRICING_DEAL_PRODUCT, dataContainer);
        	Pricing_Deal_Product__c pricingDealProduct2 = pricingDealProductFactory.getProduct(ZZTEST_F_PricingDealProduct.PricingDealProductRecordType.DEFAULT_PRICING_DEAL_PRODUCT, dataContainer);
        	pricingDealProduct1.Pricing_Group__c = pricingGroup1.Id;
        	pricingDealProduct2.Pricing_Group__c = pricingGroup2.Id;
        	pricingDealProducts.add(pricingDealProduct1);
        	pricingDealProducts.add(pricingDealProduct2);
        }
        insert pricingDealProducts;
        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getInsertedProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);
        List<Standard_Pricing__c> standardPricings = new List<Standard_Pricing__c>();
        for(Pricing_Deal_Product__c pricingDealProduct : pricingDealProducts){
        	standardPricings.add(new Standard_Pricing__c(Pricing_Template__c=pricingTemplate.Id, Pricing_Deal_Product__c=pricingDealProduct.Id, Price__c='1000'));
        }
        insert standardPricings;

        Test.startTest();

		PageReference APT_NewAnnualPricing = Page.APT_NewAnnualPricing;
        Test.setCurrentPage(APT_NewAnnualPricing);

    	Annual_Pricing__c annualPricing = new Annual_Pricing__c();
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(annualPricing);
        APT_NewAnnualPricingController controller = new APT_NewAnnualPricingController(stc);
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;
        for(APT_NewAnnualPricingController.PricingGroupWrapper pricingGroup : controller.pricingGroups){
        	pricingGroup.isSelected = true;
        }
        controller.next();

        for(APT_NewAnnualPricingController.PricingGroupWrapper pricingGroup : controller.pricingGroups){
            for(APT_NewAnnualPricingController.PricingDealProductWrapper pricingDealProduct : pricingGroup.pricingDealProducts){
                pricingDealProduct.isSelected = false;
            }
        }

        //Save
        controller.save();
        System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.Error);	
        System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.errMsg_AtLeastOnePricingDealProductRequired);

        for(APT_NewAnnualPricingController.PricingGroupWrapper pricingGroup : controller.pricingGroups){
            for(APT_NewAnnualPricingController.PricingDealProductWrapper pricingDealProduct : pricingGroup.pricingDealProducts){
            	pricingDealProduct.isSelected = true;
            }
		}
		controller.save();
		Annual_Pricing__c annualPricingAfterIns = [SELECT Id, Name, Approval_Status__c, (SELECT Id, Name FROM Annual_Pricing_Items__r) 
											FROM Annual_Pricing__c WHERE Organisation__c = :account.Id AND Pricing_Template__c = :pricingTemplate.Id
											LIMIT 1];
		//System.assertEquals(annualPricingAfterIns.Approval_Status__c, APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED);
        System.assertEquals(annualPricingAfterIns.Approval_Status__c, APT_AnnualPricingUtils.STATUS_STANDARD_PRICING);
		System.assertEquals(annualPricingAfterIns.Annual_Pricing_Items__r.size(), 2*GROUP_ITEMS_SIZE);

        Test.stopTest();
	}
}