/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_CreateNewController
*              Tests executed:
*               1 - testCreateJlocFromTab()
*                   Test that new JLOC can be created from JLOC tab.
*               2 - testCreateJlocFromAccountPage()
*                   Test that that new JLOC can be created from Account page layout.
*				3 - testCloneJloc()
*					Test that a JLOC can be cloned
*/
@isTest
private class ZZTEST_JLOC_CreateNewController {
	public static testMethod void testCreateJlocFromTab() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
    		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    		
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            OpportunityLineItem oli = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            
            ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
            Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
            
            oli.Product_Level_3__c = productLvl3.Id;
            UPDATE oli;
            
            Test.startTest();

    		PageReference JLOC_CreateNew = Page.JLOC_CreateNew;
            Test.setCurrentPage(JLOC_CreateNew);

        	JLOC__c jloc = new JLOC__c();
        	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_CreateNewController controller = new JLOC_CreateNewController(stc);

            controller.next();
            System.assertEquals(controller.isOrganisationSelected, false);	

            //Select Organisation
            controller.jloc.Organisation__c = opp.AccountId;
            controller.next();
            System.assertEquals(controller.isOrganisationSelected, true);	

            controller.save();
            System.assertEquals(ApexPages.getMessages()[0].getDetail(), System.Label.errMsg_IsThisAClosedJLOCRequired);

            List<SelectOption> isThisClosedJLOCList = controller.getIsThisClosedJLOCList();
            controller.isThisClosedJLOC = isThisClosedJLOCList[0].getValue();
            controller.save();
            System.assertEquals(ApexPages.getMessages()[1].getDetail(), System.Label.errMsg_AtLeastOneOpportunityForJLOC);

            //Select Opportunities
            for(JLOC_CreateNewController.OpportunityWrapper oppWrapp : controller.opportunityItems) {
            	oppWrapp.isSelected = true;
            }
            controller.save();

            Test.stopTest();
        }
	}

	public static testMethod void testCreateJlocFromAccountPageNoProduct() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
    		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
            Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
                    
            Test.startTest();

    		PageReference JLOC_CreateNew = Page.JLOC_CreateNew;
            Test.setCurrentPage(JLOC_CreateNew);

        	JLOC__c jloc = new JLOC__c(Organisation__c=acc.Id);
        	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_CreateNewController controller = new JLOC_CreateNewController(stc);

            System.assertEquals(controller.isOrganisationSelected, true);	
            controller.next();	

            controller.save();
            System.assertEquals(System.Label.errMsg_NoOpportunityForOrganisation, ApexPages.getMessages()[0].getDetail());

            Test.stopTest();
        }
	}

    public static testMethod void testCreateJlocFromAccountPageNoProductLvl3() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            
            ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
            Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            OpportunityLineItem oli = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
                
            ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
            Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(ZZTEST_F_Product_Level_2.ProductLevel2RecordType.DEFAULT_PRODUCT, dataContainer);
                
            oli.Product_Level_2__c = productLvl2.Id;
            UPDATE oli;

            Test.startTest();

            PageReference JLOC_CreateNew = Page.JLOC_CreateNew;
            Test.setCurrentPage(JLOC_CreateNew);

            JLOC__c jloc = new JLOC__c(Organisation__c=acc.Id);
            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_CreateNewController controller = new JLOC_CreateNewController(stc);

            System.assertEquals(controller.isOrganisationSelected, true);   
            controller.next();  

            controller.save();
            System.assertEquals(System.Label.errMsg_IsThisAClosedJLOCRequired, ApexPages.getMessages()[0].getDetail());

            List<SelectOption> isThisClosedJLOCList = controller.getIsThisClosedJLOCList();
            controller.isThisClosedJLOC = isThisClosedJLOCList[0].getValue();
            controller.save();
            System.assertEquals(System.Label.errMsg_AtLeastOneOpportunityForJLOC, ApexPages.getMessages()[1].getDetail());

            Test.stopTest();
        }
    }
    
    public static testMethod void testCloneJloc() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
    		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    		
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            OpportunityLineItem oli = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            
            ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
            Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
            
            oli.Product_Level_3__c = productLvl3.Id;
            UPDATE oli;
            
            Test.startTest();

    		PageReference JLOC_CreateNew = Page.JLOC_CreateNew;
            Test.setCurrentPage(JLOC_CreateNew);

        	JLOC__c jloc = new JLOC__c();
        	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_CreateNewController controller = new JLOC_CreateNewController(stc);

            //Select Organisation
            controller.jloc.Organisation__c = opp.AccountId;
            controller.next();

            List<SelectOption> isThisClosedJLOCList = controller.getIsThisClosedJLOCList();
            controller.isThisClosedJLOC = isThisClosedJLOCList[0].getValue();

            //Select Opportunities
            for(JLOC_CreateNewController.OpportunityWrapper oppWrapp : controller.opportunityItems) {
            	oppWrapp.isSelected = true;
            }
            PageReference result = controller.save();
            System.assertNotEquals(null, result);
            
            //Test Cloning
            PageReference JLOC_CreateNew_Clone = Page.JLOC_CreateNew;
            JLOC_CreateNew_Clone.getParameters().put('JLOCIdToClone', jloc.Id);
            Test.setCurrentPage(JLOC_CreateNew_Clone);
            JLOC__c jloc_clone = new JLOC__c();
        	Apexpages.Standardcontroller clone_stc = new ApexPages.StandardController(jloc_clone);
            JLOC_CreateNewController clone_controller = new JLOC_CreateNewController(stc);
            clone_controller.jloc.Organisation__c = opp.AccountId;
            clone_controller.next();
            clone_controller.isThisClosedJLOC = 'Yes';
            //Select Opportunities
            for(JLOC_CreateNewController.OpportunityWrapper oppWrapp : clone_controller.opportunityItems) {
            	oppWrapp.isSelected = true;
            }
            result = clone_controller.save();
            System.assertNotEquals(null, result);
            
            List<JLOC__c> jloclist = [SELECT Id FROM JLOC__c];
            System.assertEquals(2, jloclist.size());
            
            Test.stopTest();
        }
	}
}