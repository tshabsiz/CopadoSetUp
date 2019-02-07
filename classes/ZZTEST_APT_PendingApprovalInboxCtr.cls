/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for APT_PendingApprovalInboxController
*              Tests executed:
*               1 - testPendingApprovalInbox()
*                   Test that at least one Annual Pricing Item needs to be selected for Approve/Reject action.
*/
@isTest(SeeAllData=true)
private class ZZTEST_APT_PendingApprovalInboxCtr{
        public static testMethod void testPendingApprovalInbox(){
	       Integer ITEMS_SIZE = 30;
	       ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
	       ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
	       ZZTEST_F_PricingDealProduct pricingDealProductFactory = ZZTEST_DataFactoryFacade.pricingDealProduct;
	       ZZTEST_F_PricingTemplate pricingTemplateFactory = ZZTEST_DataFactoryFacade.pricingTemplate;

                List<Pricing_Deal_Product__c> pricingDealProducts = new List<Pricing_Deal_Product__c>();
                for(Integer i=0; i<ITEMS_SIZE; i++){
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

                Account account = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
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
        	       annualPricingItem.Final_Price__c = '2000';
        	       annualPricingItem.Approval_Required__c = true;
        	       annualPricingItem.First_Line_Approver__c = UserInfo.getUserId();
        	       annualPricingItem.Request_Comments__c = 'Please approve';
        	       annualPricingItems.add(annualPricingItem);
                }
                insert annualPricingItems;

                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
	       for(Annual_Pricing_Item__c api : annualPricingItems){
		      // Create an approval request for the Annual Pricing Items
		      Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		      req.setComments(api.Request_Comments__c);
		      req.setObjectId(api.Id);
		      requests.add(req);
	       }
	       // Submit the approval request for the Annual Pricing Items
	       List<Approval.ProcessResult> results = Approval.process(requests);
	       Set<Id> newWorkitemIds = new Set<Id>();
	       for(Approval.ProcessResult result : results){
		      newWorkitemIds.addAll(result.getNewWorkitemIds());
	       }

                Test.startTest();

	       PageReference APT_PendingApprovalInbox = Page.APT_PendingApprovalInbox;
                Test.setCurrentPage(APT_PendingApprovalInbox);

	       APT_PendingApprovalInboxController controller = new APT_PendingApprovalInboxController();
	       controller.getActions();
	       controller.submit();
	       System.assertEquals(ApexPages.getMessages()[0].getDetail(), Label.errMsg_AtLeastOneAnnualPricingItemRequired);

                Test.stopTest();
	}
}