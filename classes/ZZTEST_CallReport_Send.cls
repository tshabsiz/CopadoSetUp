@isTest
private class ZZTEST_CallReport_Send {
	
	@isTest static void testCallReportEmailSend() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        //Create a user
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
        	//Create an Account
        	ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        	Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        	//Create a Call Report for it
        	ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
			Call_Report__c callRep = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, dataContainer);

        	//Now try to trigger the email
        	Test.startTest();

        	PageReference pr = Page.CallReport_Send;
	        pr.getParameters().put('returnUrl', callRep.Id);
	        Test.setCurrentPage(pr);
        	CallReport_Send ctrl = new CallReport_Send(new ApexPages.StandardController(callRep));

        	//Check the User Lists - we should get Active users in the system with a max of 25
        	List<SelectOption> availableUsers = ctrl.getAvailableUsers();
        	System.assertEquals(true, (1 <= availableUsers.size()) && (availableUsers.size() <= 25));

        	List<SelectOption> selectedUsers = ctrl.getSelectedUsers();
        	System.assertEquals(0, selectedUsers.size());

        	//Do a search for something that doesn't exist - the lastname of the only user in the system concattened with garbage
        	ctrl.whereClause = u.lastname + 'XXXXXXXX' + Datetime.now();
        	ctrl.filterAvailableOptions();
        	System.assertEquals(0, ctrl.getAvailableUsers().size());

        	//Now send an e-mail that will fail
        	ctrl.toAddresses = 'not an email address';
			ctrl.sendTemplatedEmail();
			System.assertEquals(false, ctrl.emailResult);

			//Now send another e-mail that will fail
        	ctrl.toAddresses = 'not an email address';
        	ctrl.ccAddresses = 'another bad email address, and, some, more #N@N#@ garbage;;;,,,, @@@';
			ctrl.sendTemplatedEmail();
			System.assertEquals(false, ctrl.emailResult);

			//Now send one that should work
			//first reset the available list
			ctrl.whereClause = '';
        	ctrl.filterAvailableOptions();
        	//quick check if we have users listed
        	System.assertEquals(true, ctrl.getAvailableUsers().size() > 0);
        	//add this user to the recipients
			ctrl.selectedUserIds.add(ctrl.getAvailableUsers().get(0).getValue());
			ctrl.addUser();
			//quick check if this user is now selected
			System.assertEquals(1, ctrl.getSelectedUsers().size());
			//add manually entered addresses - 1 not whitelisted and 1 whitelisted
        	ctrl.toAddresses = 'test@example.com';
        	ctrl.ccAddresses = 'test@Barclays.com';
			ctrl.sendTemplatedEmail();
			System.assertEquals(true, ctrl.emailResult);

	        Test.stopTest();
	    }
	}
}