/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for APT_ClonePricingTemplateController
*              Tests executed:
*               1 - testClonePricingTemplate()
*                   Test that Pricing Template can be cloned and new Pricing Template together with all Standard Pricings are created.
*/
@isTest
private class ZZTEST_APT_ClonePricingTemplateCtr
{
	public static testMethod void testClonePricingTemplate(){
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
        
		PageReference APT_ClonePricingTemplate = Page.APT_ClonePricingTemplate;
        Test.setCurrentPage(APT_ClonePricingTemplate);
        ApexPages.currentPage().getParameters().put('id', pricingTemplate.Id);
        ApexPages.currentPage().getParameters().put('clone', '1');

    	Apexpages.Standardcontroller stdController = new ApexPages.StandardController(pricingTemplate);
        APT_ClonePricingTemplateController controller = new APT_ClonePricingTemplateController(stdController);

        controller.save();

        List<Pricing_Template__c> pricingTemplates = [SELECT Id FROM Pricing_Template__c WHERE Id != :pricingTemplate.Id];
        System.assertEquals(pricingTemplates.size(), 1);

        Id newPricingTemplateId = pricingTemplates[0].Id;

        List<Standard_Pricing__c> newStandardPricings = [SELECT Id, Price__c FROM Standard_Pricing__c WHERE Pricing_Template__c = :newPricingTemplateId];
        System.assertEquals(newStandardPricings.size(), standardPricings.size());

        Test.stopTest();
	}
}