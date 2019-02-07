/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for BuyingGroupConfigController
*/
@isTest
private class ZZTEST_BuyingGroupConfigController {
	public static testMethod void testConfigureBuyingGroup() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;

		Account buyingGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);

		List<Account> accounts = new List<Account>();
		Account ikea = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer);
		Account ingkaHolding = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer);
		Account ingkaFoundation = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer);
		ikea.Name = 'IKEA';
		ingkaHolding.Name = 'INGKA Holding';
		ingkaFoundation.Name = 'INGKA Foundation';
		accounts.add(ikea);
		accounts.add(ingkaHolding);
		accounts.add(ingkaFoundation);

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accounts,dml);
		
		Test.startTest();

        PageReference BuyingGroupConfig = Page.BuyingGroupConfig;
        Test.setCurrentPage(BuyingGroupConfig);

    	ApexPages.currentPage().getParameters().put('id', buyingGroup.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(buyingGroup);
        BuyingGroupConfigController controller = new BuyingGroupConfigController(stc);	
        System.assertEquals(controller.portfolioItems.size(), 0);

        controller.accountName = 'i';
        controller.runSearch();
        System.assertEquals(controller.accounts.size(), 0);
        controller.accountName = 'in';
        controller.runSearch();
        System.assertEquals(controller.accounts.size(), 2);

        controller.setShowSearchResults();

        List<String> clients = new List<String>{ikea.Id, ingkaHolding.Id, ingkaFoundation.Id};
        BuyingGroupConfigController.addClientsToPortfolio(clients, buyingGroup.Id);
        System.assertEquals(controller.portfolioItems.size(), 3);

        ApexPages.currentPage().getParameters().put('clientId', ikea.Id);
        controller.removePortfolioItem();
        System.assertEquals(controller.portfolioItems.size(), 2);
		
		Test.stopTest();
	}
}