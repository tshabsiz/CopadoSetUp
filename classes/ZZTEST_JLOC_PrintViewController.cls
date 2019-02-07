/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_PrintViewController
*              Tests executed:
*               1 - testJlocPrintView()
*                   Test that JLOC Print View can be generated.
*               2 - testJlocPrintViewWithDealTeamAndProducts()
*                   Test that Deal Team and Products lists are displayed on JLOC Print View.
*               3 - testGetRadioOptions()
*                   Tests getter of radio options.
*/
@isTest
public class ZZTEST_JLOC_PrintViewController {
	public static testMethod void testJlocPrintView() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

		JLOC__c jloc = new JLOC__c();

		Test.startTest();

        
		PageReference JLOC_PrintView = Page.JLOC_PrintView;
        JLOC_PrintView.getParameters().put('status','Submitted to Secretary');
        Test.setCurrentPage(JLOC_PrintView);

    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_PrintViewController controller = new JLOC_PrintViewController(stc);	

        System.assertEquals(controller.jlocDealTeam.size(), 0);
        System.assertEquals(controller.jlocProposedProducts.size(), 0);

        Test.stopTest();
	}

	public static testMethod void testJlocPrintViewWithDealTeamAndNoProducts() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
		ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User stdUser = userFactory.getBarclaysStandardUser();

		//Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = stdUser.id, PermissionSetId = ps.Id);

		System.runAs(stdUser) {
			JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
			Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			opp.JLOC__c = jloc.Id;
			INSERT opp;

			jloc.Opportunity__c = opp.Id;
			UPDATE jloc;

			OpportunityTeamMember otm = new OpportunityTeamMember();
			otm.OpportunityId = opp.Id;
			otm.UserId = stdUser.Id;
			otm.I_confirm_team_member_has_been_cleared__c = true;
			INSERT otm;

			Test.startTest();

			PageReference JLOC_PrintView = Page.JLOC_PrintView;
	        Test.setCurrentPage(JLOC_PrintView);

	    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
	        JLOC_PrintViewController controller = new JLOC_PrintViewController(stc);	

	        //Verify we have 2 people on the deal team (1 real user and 1 empty record)
	        System.assertEquals(2, controller.jlocDealTeam.size());

	        //Verify we have no products on the JLOC (nothing on the Opportunity)
	        System.assertEquals(0, controller.jlocProposedProducts.size());

	        Test.stopTest();
	    }
	}

	public static testMethod void testJlocPrintViewWithClientPlan() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
		ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User stdUser = userFactory.getBarclaysStandardUser();

		//Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = stdUser.id, PermissionSetId = ps.Id);

		System.runAs(stdUser) {
			JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
			Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			opp.JLOC__c = jloc.Id;
			INSERT opp;

			jloc.Opportunity__c = opp.Id;
			jloc.Pricing_and_Returns_Document_ID__c = '0000000000';
			UPDATE jloc;

			//Create CLientPlan test data
			Client_Plan__c cp = new Client_Plan__c();
			cp.Relationship__c = opp.AccountId;
			INSERT cp;

			Client_Plan_Borrowers_Guarantors__c borrower = new Client_Plan_Borrowers_Guarantors__c();
			borrower.Relationship__c = opp.AccountId;
			borrower.Type__c = 'Borrower';
			borrower.Value__c = 'A';
			INSERT borrower;

			Client_Plan_Borrowers_Guarantors__c guarantor = new Client_Plan_Borrowers_Guarantors__c();
			guarantor.Relationship__c = opp.AccountId;
			guarantor.Type__c = 'Guarantor';
			guarantor.Value__c = 'B';
			INSERT guarantor;

			Financial_Information__c finInfo = new Financial_Information__c();
			finInfo.Relationship__c = opp.AccountId;
			finInfo.Year__c = '2016';
			finInfo.Net_Asset_Value__c = 1;
			finInfo.EBITDA__c = 2;
			INSERT finInfo;

			Budget_Revenue__c budRev = new Budget_Revenue__c();
			budRev.Client_Plan__c = cp.Id;
			budRev.Actual_RoRWA__c = 10.0;
			INSERT budRev;

			Client_Plan_Facility__c cpFac = new Client_Plan_Facility__c();
			cpFac.Relationship__c = opp.AccountId;
			cpFac.Type_Of_Facility__c = 'OTHER';
            cpFac.Limit__c = 2000;
			INSERT cpFac;

			Country_Presence__c pres = new Country_Presence__c();
			pres.Client_Plan__c = cp.Id;
			pres.Banking_Country__c = 'South Africa';
			INSERT pres;

			Client_Plan_Security__c sec = new Client_Plan_Security__c();
			sec.Relationship__c = opp.AccountId;
			sec.Security_Description__c = 'XXX';
			sec.Value__c = 100000;
			INSERT sec;

			Client_Plan_Revenue_By_Product__c revByProduct = new Client_Plan_Revenue_By_Product__c();
			revByProduct.Client_Plan__c = cp.Id;
			INSERT revByProduct;

			Test.startTest();

			PageReference JLOC_PrintView = Page.JLOC_PrintView;
	        Test.setCurrentPage(JLOC_PrintView);

	    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
	        JLOC_PrintViewController controller = new JLOC_PrintViewController(stc);	

	        Test.stopTest();

	        //Verify we have a RevByProduct var which means we processed everything
	        System.assertEquals(true, controller.jlocRevByProduct != null, 'We should have a Client_Plan_Revenue_By_Product__c reference');
	    }
	}
}