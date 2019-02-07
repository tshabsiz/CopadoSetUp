@isTest
private class ZZTEST_APT_AnnualPricingItemTrigger
{
	public static testMethod void testSetDefaultFinalPrice(){
		Integer BATCH_SIZE = 200;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		//ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
		ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        List<Pricing_Deal_Product__c> pricingDealProducts = new List<Pricing_Deal_Product__c>();
        for(Integer i=0; i<BATCH_SIZE; i++){
        	Pricing_Deal_Product__c pricingDealProduct = pricingDealProductFactory.getProduct(ZZTEST_F_PricingDealProduct.PricingDealProductRecordType.DEFAULT_PRICING_DEAL_PRODUCT, dataContainer);
        	pricingDealProducts.add(pricingDealProduct);
        }
        insert pricingDealProducts;

        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getInsertedProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);
        List<Standard_Pricing__c> standardPricings = new List<Standard_Pricing__c>();
        for(Pricing_Deal_Product__c pricingDealProduct : pricingDealProducts){
        	standardPricings.add(new Standard_Pricing__c(Pricing_Template__c=pricingTemplate.Id, Pricing_Deal_Product__c=pricingDealProduct.Id, Price__c='1000'));
        }
        insert standardPricings;

        Annual_Pricing__c annualPricing = new Annual_Pricing__c();
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;
        //annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_STANDARD_PRICING;
        annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED;
        insert annualPricing;

        List<Annual_Pricing_Item__c> annualPricingItems = new List<Annual_Pricing_Item__c>();
        for(Standard_Pricing__c standardPricing : standardPricings){
        	Annual_Pricing_Item__c annualPricingItem = new Annual_Pricing_Item__c();
        	annualPricingItem.Annual_Pricing__c = annualPricing.Id;
        	annualPricingItem.Pricing_Deal_Product__c = standardPricing.Pricing_Deal_Product__c;
        	annualPricingItem.Standard_Pricing__c = standardPricing.Id;
        	annualPricingItems.add(annualPricingItem);
        }
        insert annualPricingItems;

        Test.startTest();

		for(Annual_Pricing_Item__c api : [SELECT Id, Final_Price__c FROM Annual_Pricing_Item__c WHERE Annual_Pricing__c = :annualPricing.Id]){
			System.assertEquals(api.Final_Price__c, '1000');
		}

        Test.stopTest();
	}

	public static testMethod void testUpdateApprovalStatus(){
		Integer BATCH_SIZE = 200;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		//ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
		ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
		ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

        Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        List<Pricing_Deal_Product__c> pricingDealProducts = new List<Pricing_Deal_Product__c>();
        for(Integer i=0; i<BATCH_SIZE; i++){
        	Pricing_Deal_Product__c pricingDealProduct = pricingDealProductFactory.getProduct(ZZTEST_F_PricingDealProduct.PricingDealProductRecordType.DEFAULT_PRICING_DEAL_PRODUCT, dataContainer);
        	pricingDealProducts.add(pricingDealProduct);
        }
        insert pricingDealProducts;

        Pricing_Template__c pricingTemplate = pricingTemplateFactory.getInsertedProduct(ZZTEST_F_PricingTemplate.PricingTemplateRecordType.DEFAULT_PRICING_TEMPLATE, dataContainer);
        List<Standard_Pricing__c> standardPricings = new List<Standard_Pricing__c>();
        for(Pricing_Deal_Product__c pricingDealProduct : pricingDealProducts){
        	standardPricings.add(new Standard_Pricing__c(Pricing_Template__c=pricingTemplate.Id, Pricing_Deal_Product__c=pricingDealProduct.Id, Price__c='1000'));
        }
        insert standardPricings;

        Annual_Pricing__c annualPricing = new Annual_Pricing__c();
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;
        //annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED;
        annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_STANDARD_PRICING;
        insert annualPricing;

        List<Annual_Pricing_Item__c> annualPricingItems = new List<Annual_Pricing_Item__c>();
        for(Standard_Pricing__c standardPricing : standardPricings){
        	Annual_Pricing_Item__c annualPricingItem = new Annual_Pricing_Item__c();
        	annualPricingItem.Annual_Pricing__c = annualPricing.Id;
        	annualPricingItem.Pricing_Deal_Product__c = standardPricing.Pricing_Deal_Product__c;
        	annualPricingItem.Standard_Pricing__c = standardPricing.Id;
        	annualPricingItems.add(annualPricingItem);
        }
        insert annualPricingItems;

        Test.startTest();

        for(Annual_Pricing_Item__c api : annualPricingItems){
        	api.Approval_Status__c = APT_AnnualPricingUtils.STATUS_PENDING_FIRST_APPROVAL;
        }
		update annualPricingItems;

		Annual_Pricing__c annualPricingPending = [SELECT Id, Approval_Status__c FROM Annual_Pricing__c WHERE Id = :annualPricing.Id LIMIT 1];
		System.assertEquals(annualPricingPending.Approval_Status__c, APT_AnnualPricingUtils.STATUS_PENDING);

		for(Annual_Pricing_Item__c api : annualPricingItems){
        	api.Approval_Status__c = APT_AnnualPricingUtils.STATUS_REJECTED;
        }
		update annualPricingItems;

		Annual_Pricing__c annualPricingRejected = [SELECT Id, Approval_Status__c FROM Annual_Pricing__c WHERE Id = :annualPricing.Id LIMIT 1];
		System.assertEquals(annualPricingRejected.Approval_Status__c, APT_AnnualPricingUtils.STATUS_REJECTED);

        Test.stopTest();
	}
}