/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for APT_StandardPricingTrigger
*/
@isTest
private class ZZTEST_APT_StandardPricingTrigger {
	public static testMethod void testLockPricingTemplate(){
		Integer batchSize = 200;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
		ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        Pricing_Group__c pricingGroup = pricingGroupFactory.getInsertedProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        List<Pricing_Deal_Product__c> pricingDealProducts = new List<Pricing_Deal_Product__c>();
        for(Integer i=0; i<batchSize; i++){
        	Pricing_Deal_Product__c pricingDealProduct = pricingDealProductFactory.getProduct(ZZTEST_F_PricingDealProduct.PricingDealProductRecordType.DEFAULT_PRICING_DEAL_PRODUCT, dataContainer);
        	pricingDealProduct.Pricing_Group__c = pricingGroup.Id;
        	pricingDealProducts.add(pricingDealProduct);
        }
        insert pricingDealProducts;

        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);
        pricingTemplate.Locked__c = true;
        insert pricingTemplate;

        List<Standard_Pricing__c> standardPricings = new List<Standard_Pricing__c>();
        for(Pricing_Deal_Product__c pricingDealProduct : pricingDealProducts){
        	standardPricings.add(new Standard_Pricing__c(Pricing_Template__c=pricingTemplate.Id, Pricing_Deal_Product__c=pricingDealProduct.Id, Price__c='1000'));
        }

        Test.startTest();
        
        try{
        	insert standardPricings;
        } catch(DmlException ex){
        	System.assertEquals(ex.getDmlMessage(0), Label.errMsg_NotAllowedToAddStandardPricing);
        }
		
		pricingTemplate.Locked__c = false;
        update pricingTemplate;
        insert standardPricings;

        pricingTemplate.Locked__c = true;
        update pricingTemplate;

        try{
        	update standardPricings;
        } catch(DmlException ex){
        	System.assertEquals(ex.getDmlMessage(0), Label.errMsg_NotAllowedToChangeStandardPricing);
        }

        try{
        	delete standardPricings;
        } catch(DmlException ex){
        	System.assertEquals(ex.getDmlMessage(0), Label.errMsg_NotAllowedToDeleteStandardPricing);
        }

        Test.stopTest();
	}
}