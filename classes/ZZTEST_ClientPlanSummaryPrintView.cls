@isTest
private class ZZTEST_ClientPlanSummaryPrintView {
	
	@isTest static void testSummaryPrint() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

		Client_Plan__c cp = new Client_Plan__c();
		cp.Relationship__c = acc1.Id;
		INSERT cp;

		PageReference pr = Page.ClientPlanSummaryPrintView;
		pr.getParameters().put('id', cp.Id);
		Test.setCurrentPage(pr);

		Test.startTest();
		ClientPlanSummaryPrintViewController ctrl = new ClientPlanSummaryPrintViewController(new ApexPages.StandardController(cp));
		Test.stopTest();
	}
}