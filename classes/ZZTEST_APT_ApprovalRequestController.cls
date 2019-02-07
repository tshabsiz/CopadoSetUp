/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for APT_ApprovalRequestController
*              Tests executed:
*               1 - testSubmitForApproval()
*                   Test that all Annual Pricing Items submitted for approval have change the status for "Pending First Approval".
*/
@isTest
private class ZZTEST_APT_ApprovalRequestController {
	public static testMethod void testSubmitForApproval(){
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

        Annual_Pricing__c annualPricing = new Annual_Pricing__c();
        annualPricing.Organisation__c = account.Id;
        annualPricing.Pricing_Template__c = pricingTemplate.Id;
       // annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED;
        annualPricing.Approval_Status__c = APT_AnnualPricingUtils.STATUS_STANDARD_PRICING;
        insert annualPricing;

        List<Annual_Pricing_Item__c> annualPricingItems = new List<Annual_Pricing_Item__c>();
        for(Standard_Pricing__c standardPricing : standardPricings){
        	Annual_Pricing_Item__c annualPricingItem = new Annual_Pricing_Item__c();
        	annualPricingItem.Annual_Pricing__c = annualPricing.Id;
        	annualPricingItem.Pricing_Deal_Product__c = standardPricing.Pricing_Deal_Product__c;
        	annualPricingItem.Standard_Pricing__c = standardPricing.Id;
        	annualPricingItem.Final_Price__c = '2000';
        	annualPricingItem.Approval_Required__c = true;
        	annualPricingItems.add(annualPricingItem);
        }
        insert annualPricingItems;

        Test.startTest();

		PageReference APT_ApprovalRequest = Page.APT_ApprovalRequest;
        Test.setCurrentPage(APT_ApprovalRequest);

    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(annualPricing);
        APT_ApprovalRequestController controller = new APT_ApprovalRequestController(stc);
		
		controller.submit();
		System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.errMsg_ApproverRequired);

		controller.selectedApprover =UserInfo.getUserId();
        controller.setSecondApprover();
		controller.submit();

		Annual_Pricing__c annualPricingAfterUpd = [SELECT Id, Approval_Status__c FROM Annual_Pricing__c WHERE Id = :annualPricing.Id];
		System.assertEquals(annualPricingAfterUpd.Approval_Status__c, APT_AnnualPricingUtils.STATUS_PENDING);

		for(Annual_Pricing_Item__c annualPricingItem : [SELECT Id, Approval_Status__c FROM Annual_Pricing_Item__c WHERE Annual_Pricing__c = :annualPricing.Id]){
			System.assertEquals(annualPricingItem.Approval_Status__c, APT_AnnualPricingUtils.STATUS_PENDING_FIRST_APPROVAL);
		}

        Test.stopTest();
	}
    
    @TestSetup static void setupTestData()
    {
        Annual_Pricing_Approver__c APA = new Annual_Pricing_Approver__c(First_line_Approver__c = UserInfo.getUserId(),Second_line_Approver__c=UserInfo.getUserId());
        insert APA;
    }
}