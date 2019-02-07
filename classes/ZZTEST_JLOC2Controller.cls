@isTest
private class ZZTEST_JLOC2Controller
{
	public static testMethod void testJlocVisibility(){
		//Create ManyWho settings
		ManyWho_Settings__c mwSettings = new ManyWho_Settings__c();
		mwSettings.Name = 'jloc';
		mwSettings.FlowId__c = 'FlowId';
		mwSettings.Tenant__c = 'TenantId';
		insert mwSettings;

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select ID from User where iD =:userInfo.getUserId()];
        
       	System.runAs(user1)
        {
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
		JLOC__C jloc = jlocFactory.getProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
		jloc.ManyWho_Join_URL__c = '?join=1234';
		insert jloc;

		PageReference JLOC2 = Page.JLOC2;
        Test.setCurrentPage(JLOC2);
        ApexPages.currentPage().getParameters().put('id', jloc.Id);        
    	ApexPages.currentPage().getParameters().put('join', '1234');
    	ApexPages.currentPage().getParameters().put('initialization', 'false');

    	ApexPages.StandardController stdController = new ApexPages.StandardController(jloc);

    	//Run As Current User
    	JLOC2Controller controller;
    	controller = new JLOC2Controller(stdController);
    	System.assertEquals(controller.isVisible, true);
    	//Run As Barclays Standard User
    	User BarclaysStdUser = userFactory.getBarclaysStandardUser();
    	System.runAs(BarclaysStdUser) {
    		controller = new JLOC2Controller(stdController);
    		System.assertEquals(controller.isVisible, false);
        }
		
    	}
	}
}