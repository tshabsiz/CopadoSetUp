/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_EditController
*              Tests executed:
*               1 - testEditJloc()
*                   Test that JLOC can be edited and all changes are saved.
*               2 - testJlocAttachments()
*                   Test redirection to adding Attachments page.
*               3 - testJlocUploadPricingAndReturns()
*                   Test redirection to JLOC upload document page.
*               4 - testJlocUploadConflictClearance()
*                   Test redirection to JLOC upload document page.
*               5 - testJlocUploadPreScreening()
*                   Test redirection to JLOC upload document page.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska   Saving Existing Facilities and Potential Future Opportunities fix
* 24/03/2016  Marek Cech         added testJlocUploadConflictClearance and testJlocUploadPreScreening
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_JLOC_EditController {

    private static List<SObject> selectStar(String sobjectName) {
        Set<String> fieldNames = schema.describeSObjects(new String[] {sobjectName})[0].fields.getMap().keyset();
        List<String> iterableFields = new List<String>(fieldNames);
        return Database.query(String.format('SELECT {0} FROM {1}', new String[] {String.join(iterableFields, ','), sobjectName}));
    }

	public static testMethod void testEditJlocMain() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
            //Init all Data Factories
    		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Product_Level_3 productFactory = ZZTEST_DataFactoryFacade.productLvl3;
            ZZTEST_F_Opportunity oppFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
    		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            //Create Product
            Product_Level_3__c p = productFactory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);

            //Create Opportunity
            Opportunity opp = oppFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            //Create OpportunityLineItem
            OpportunityLineItem oli = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);

            //Create JLOC
            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

            //Link JLOC to Opportunity
            Opportunity o = oli.Opportunity;
            o.JLOC__c = jloc.Id;
            UPDATE o;

            jloc.Opportunity__c = o.Id;
            UPDATE jloc;

            //Test data
            String testClientDescription = 'Client Description...';
            String testTransactionDescription = 'Transaction Description...';
            
            //Start Test
            Test.startTest();

    		PageReference JLOC_Edit = Page.JLOC_Edit;
            Test.setCurrentPage(JLOC_Edit);

            ApexPages.currentPage().getParameters().put('id', jloc.Id);
        	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_EditController controller = new JLOC_EditController(stc);

            controller.jloc.Brief_Client_Description__c = testClientDescription;
            controller.jloc.Brief_Transaction_Description__c = testTransactionDescription;
            controller.jloc.Is_this_a_closed_JLOC__c = true;

            //Set the SoftLock
            controller.checkSoftLock();
            System.assertEquals(jloc.Last_Opened_For_Editing_By__c, UserInfo.getUserId(), 'Last Opened should hold the current users userId');

            //Simulate a user changing tabs (as a result quick saving) and check SoftLock is still not cleared
            controller.quicksave();
            System.assertEquals(jloc.Last_Opened_For_Editing_By__c, UserInfo.getUserId(), 'Last Opened should hold the current users userId');
            
            controller.save();

            //Check if the SoftLock is cleared
            System.assertEquals(jloc.Last_Opened_For_Editing_By__c, null, 'Last Opened should be cleared after save');

            Test.stopTest();

            //Fetch latest JLOC
            List<JLOC__c> jlocsAfterUpdate = selectStar('JLOC__c');
            JLOC__c jlocAfterUpd = jlocsAfterUpdate.get(0);

            //Do we get all tabs?
            System.assertEquals(9, controller.tabs.size(), '9 Tabs expected');

            //Are the updated fields stored?
            System.assertEquals(testClientDescription, jlocAfterUpd.Brief_Client_Description__c, 'Field does not contain the expected updated value');
            System.assertEquals(testTransactionDescription, jlocAfterUpd.Brief_Transaction_Description__c, 'Field does not contain the expected updated value');

            //Is the Account stored
            System.assertEquals(true, jlocAfterUpd.Organisation__c == opp.AccountId, 'Account IDs do not match');

            //Is the one product on the OLI visible in the JLOC
            System.assertEquals(1, controller.products.size(), 'One Product was expected');

            //Is JLOC share team size the same as the Opp team size?
            List<OpportunityTeamMember> oppTeamMembers = [SELECT Id, Opportunity.JLOC__c, UserId FROM OpportunityTeamMember WHERE OpportunityId = :o.Id AND Opportunity.JLOC__c = :jlocAfterUpd.Id];
            List<JLOC__Share> jlocTeamMembers = [SELECT Id FROM JLOC__Share WHERE RowCause = 'Opportunity_Team_Member__c' AND ParentId = :jlocAfterUpd.Id];
            System.assertEquals(true, oppTeamMembers.size() == jlocTeamMembers.size(), 'Sharing team sizes ecxpected to be equal');           
        }
	}

    public static testMethod void testEditJlocStatus() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
            //Init all Data Factories
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Product_Level_3 productFactory = ZZTEST_DataFactoryFacade.productLvl3;
            ZZTEST_F_Opportunity oppFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

            //Create Product
            Product_Level_3__c p = productFactory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);

            //Create Opportunity
            Opportunity opp = oppFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            //Create OpportunityLineItem
            OpportunityLineItem oli = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);

            //Create JLOC
            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

            //Link JLOC to Opportunity
            Opportunity o = oli.Opportunity;
            o.JLOC__c = jloc.Id;
            UPDATE o;

            jloc.Opportunity__c = o.Id;
            UPDATE jloc;

            //Set JLOC status to submitted
            jloc.JLOC_Status__c = 'Submitted to Secretary';
            UPDATE jloc;

            //Start Test
            Test.startTest();

            PageReference JLOC_Edit = Page.JLOC_Edit;
            Test.setCurrentPage(JLOC_Edit);

            ApexPages.currentPage().getParameters().put('id', jloc.Id);
            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_EditController controller = new JLOC_EditController(stc);

            Test.stopTest();

            //Did we get the warning message it's no longer in draft?
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            boolean msgFound = false;
            for(Apexpages.Message msg : msgs) {
                if(msg.getDetail().contains('JLOC has been submitted and is not editable any more')) {
                    msgFound = true;
                }
            }

            System.assertEquals(true, msgFound, 'Warning message expected for non-Draft JLOC');
        }
    }

    public static testMethod void testEditCancel() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        String testString = 'XXXX';

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        controller.jloc.Brief_Client_Description__c = testString;

        controller.cancel();

        Test.stopTest();

         //Fetch latest JLOC
        List<JLOC__c> jlocsAfterCancellation = selectStar('JLOC__c');
        JLOC__c jlocAfterCan = jlocsAfterCancellation.get(0);

        //Verify the Description wasn't updated
        System.assertNotEquals(testString, jlocAfterCan.Brief_Client_Description__c, 'JLOC should not have saved');
    }


    public static testMethod void testJlocDeleteAttachment() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf('Test Attachment for JLOC');
		attachment.Name = 'test.txt';
		attachment.ParentId = jloc.Id;
		INSERT attachment;

		Test.startTest();

		PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

		controller.attachIdToDelete = attachment.Id;
		controller.deleteAttachment();

        PageReference pageRef = controller.addAttachment();
		controller.cancel();

		Test.stopTest();

        //Get tab# for Attachments
        Integer tabWeAreLookingFor = -1;
        Map<Integer,String> tabs = controller.tabs;
        for(Integer i : tabs.keySet()) {
            if(tabs.get(i) == 'Attachments') {
                tabWeAreLookingFor = i;
                break;
            }
        }

        PageReference attachPageRef = new PageReference('/p/attach/NoteAttach');
        attachPageRef.getParameters().put('pid', jloc.Id);
        attachPageRef.getParameters().put('retURL', '/apex/JLOC_Edit?id=' + jloc.Id + '#/' + tabWeAreLookingFor);

        List<Attachment> attachments = [
            SELECT  Id 
            FROM    Attachment 
            WHERE   ParentId = : jloc.Id
        ];

        //Verify the Attachment is gone
        System.assertEquals(0, attachments.size(), 'No attachment should exist at this stage');

        //Verify we were forwarded to the right Tab
        System.assertEquals(attachPageRef.getUrl(), pageRef.getUrl(), 'The forwarded URL is different');
    }

    public static testMethod void testJlocUploadPricingAndReturns() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'first_test.jpg';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Pricing_and_Returns_Document_ID__c = attachment.Id;
        UPDATE jloc;

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        PageReference pageRef = controller.uploadPricingAndReturnsDocument();

        Test.stopTest();

        //Verify the forward URL is correct
        System.assertEquals(true, pageRef.getUrl().contains('PricingAndReturns'), 'PricingAndReturns expected as FileType value in URL parameter');

        //Verify the Pricing_and_Returns_Document_ID__c is not counted towards the generic attachments
        System.assertEquals(0, controller.attachments.size(), 'PricingAndReturns document should not be included in generic attachments');
    }

    public static testMethod void testJlocUploadAncillaryCalculation() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'first_test.pdf';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Ancillary_Calculation_Document_ID__c = attachment.Id;
        UPDATE jloc;

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        PageReference pageRef = controller.uploadAncillaryCalculationDocument();

        Test.stopTest();

        //Verify the forward URL is correct
        System.assertEquals(true, pageRef.getUrl().contains('AncillaryCalculation'), 'AncillaryCalculation expected as FileType value in URL parameter');
    }
    
    static testMethod void RemoveForeCast()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        Attachment Bank_Case = new Attachment();
        Bank_Case.ParentId = jloc.Id;
        Bank_Case.Name = 'Bank_Case.pdf';
        Bank_Case.Body = Blob.ValueOf('first test attachment');
        INSERT Bank_Case;
        
        Attachment Stress_Case = new Attachment();
        Stress_Case.ParentId = jloc.Id;
        Stress_Case.Name = 'Stress_Case.pdf';
        Stress_Case.Body = Blob.ValueOf('first test attachment');
        INSERT Stress_Case;

        Attachment Management_Case = new Attachment();
        Management_Case.ParentId = jloc.Id;
        Management_Case.Name = 'Management_Case.pdf';
        Management_Case.Body = Blob.ValueOf('first test attachment');
        INSERT Management_Case;
        
        Attachment PricingAndReturns_Document = new Attachment();
        PricingAndReturns_Document.ParentId = jloc.Id;
        PricingAndReturns_Document.Name = 'PricingAndReturns_Document.pdf';
        PricingAndReturns_Document.Body = Blob.ValueOf('first test attachment');
        INSERT PricingAndReturns_Document;
        
        jloc.Stress_Case_ID__c = Bank_Case.Id;
        jloc.Banker_Case_ID__c = Stress_Case.Id;
        jloc.Management_Case_ID__c = Management_Case.Id;
        jloc.Pricing_and_Returns_Document_ID__c = Management_Case.Id;
        UPDATE jloc;

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        controller.removeStressCase();
        controller.removeBankCase();
        controller.removeManagementCase();
        controller.removePricingAndReturnsDocument();

        Test.stopTest();
    }
    static testMethod void uploadForeCastNotChecked()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        
        jloc.Forecast_Not_Available__c = false;
        update jloc;

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        controller.uploadStressCaseImage();
        controller.uploadBankCaseImage();
        controller.uploadManagementCaseImage();

        Test.stopTest();
    }
    static testMethod void uploadForeCast()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

      
      

        Test.startTest();

        PageReference JLOC_Edit = Page.JLOC_Edit;
        Test.setCurrentPage(JLOC_Edit);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_EditController controller = new JLOC_EditController(stc);

        controller.uploadStressCaseImage();
        controller.uploadBankCaseImage();
        controller.uploadManagementCaseImage();

        Test.stopTest();
    }
}