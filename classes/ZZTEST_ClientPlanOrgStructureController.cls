/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanOrgStructureController
*                 Tests executed:
*                 1 - testGetDataErrors()
*                   Tests errors handling of getData method
*                 2 - testGetData()
*                   Tests getting of org structure data
*                 3 - testAddOrgItemErrors()
*                   Tests errors handling during adding item
*                 4 - testAddOrgItemWithNullParent()
*                   Tests adding of item with null parent
*                 5 - testAddOrgItem()
*                   Tests adding of item
*                 6 - testEditStructureItemErrors()
*                   Tests errors handling during editing item
*                 7 - testEditStructureItem()
*                   Tests item editation
*                 8 - testRemoveStructureItem()
*                   Tests removing of items
*                 9 - testConstructor()
*                   Tests constructor
*                 10 - testUploadImageErrors()
*                   Tests errors handling during image upload
*                 11 - testUploadImage()
*                   Tests image upload
*                 12 - testDeleteImage()
*                   Tests deleting image
*                 13 - testQueryImage()
*                   Tests querying image
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanOrgStructureController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        INSERT ap;
    }
    
    static testMethod void testGetDataErrors() {
        String result = ClientPlanOrgStructureController.getData('asdf');
        System.assertEquals('', result);
    }
    
    static testMethod void testGetData() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        String result = ClientPlanOrgStructureController.getData(plan.Id);
        System.assertEquals('', result);
        
        Organisation_Structure_Item__c i1 = new Organisation_Structure_Item__c();
        i1.Client_Plan__c = plan.Id;
        i1.Related_To__c = null;
        i1.Description__c = 'aaa';
        INSERT i1;
        
        Organisation_Structure_Item__c i2 = new Organisation_Structure_Item__c();
        i2.Client_Plan__c = plan.Id;
        i2.Related_To__c = i1.Id;
        i2.Description__c = 'bbb';
        INSERT i2;
        
        Test.startTest();
        result = ClientPlanOrgStructureController.getData(plan.Id);
        Test.stopTest();
        
        String expected1 = '{"parent":null,"id":"' + i1.Id + '","description":"aaa"}';
        System.assertEquals(true, result.contains(expected1));
        
        String expected2 = '{"parent":"' + i1.Id + '","id":"' + i2.Id + '","description":"bbb"}';
        System.assertEquals(true, result.contains(expected2));
    }
    
    static testMethod void testAddOrgItemErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        //wrong planId
        Boolean result = ClientPlanOrgStructureController.addOrgItem(plan.Id, 'asdfasdf', false, 'ccc');
        System.assertEquals(false, result);
        
        result = ClientPlanOrgStructureController.addOrgItem('aaa', '', false, 'ccc');
        System.assertEquals(false, result);
        
        //wrong parentId
        result = ClientPlanOrgStructureController.addOrgItem(plan.Id, 'bbb', true, 'ccc');
        System.assertEquals(false, result);
        
        DELETE plan;
        result = ClientPlanOrgStructureController.addOrgItem(plan.Id, null, false, 'ccc');
        System.assertEquals(false, result);
    }
    
    static testMethod void testAddOrgItemWithNullParent() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String description = 'ccc';
        
        Boolean result = ClientPlanOrgStructureController.addOrgItem(plan.Id, null, true, description);
        
        System.assertEquals(true, result);
        
        List<Organisation_Structure_Item__c> osis = [
            SELECT Client_Plan__c, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
        ];
        
        System.assertEquals(1, osis.size());
        System.assertEquals(plan.Id, osis[0].Client_Plan__c);
        System.assertEquals(null, osis[0].Related_To__c);
        System.assertEquals(description, osis[0].Description__c);
    }
    
    static testMethod void testAddOrgItem() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Organisation_Structure_Item__c i1 = new Organisation_Structure_Item__c();
        i1.Client_Plan__c = plan.Id;
        i1.Related_To__c = null;
        i1.Description__c = 'aaa';
        INSERT i1;
        
        String description = 'ccc';
        
        Boolean result = ClientPlanOrgStructureController.addOrgItem(plan.Id, i1.Id, false, description);
        
        System.assertEquals(true, result);
        
        List<Organisation_Structure_Item__c> osis = [
            SELECT Client_Plan__c, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
            WHERE Id != :i1.Id
        ];
        
        System.assertEquals(1, osis.size());
        System.assertEquals(plan.Id, osis[0].Client_Plan__c);
        System.assertEquals(null, osis[0].Related_To__c);
        System.assertEquals(description, osis[0].Description__c);
    }
    
    static testMethod void testEditStructureItemErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String description = 'ccc';
    
        Organisation_Structure_Item__c i1 = new Organisation_Structure_Item__c();
        i1.Client_Plan__c = plan.Id;
        i1.Related_To__c = null;
        i1.Description__c = description;
        INSERT i1;
    
        //wrong itemId
        Boolean result = ClientPlanOrgStructureController.editStructureItem('aaa', 'ccc');
        System.assertEquals(false, result);
        
        //dml exception handling - string too long
        String tooLongDescription = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            
        result = ClientPlanOrgStructureController.editStructureItem(i1.Id, tooLongDescription);
        System.assertEquals(false, result);
        
        List<Organisation_Structure_Item__c> osis = [
            SELECT Client_Plan__c, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
            WHERE Id = :i1.Id
        ];
        
        System.assertEquals(1, osis.size());
        System.assertEquals(plan.Id, osis[0].Client_Plan__c);
        System.assertEquals(null, osis[0].Related_To__c);
        System.assertEquals(description, osis[0].Description__c);
    }
    
    static testMethod void testEditStructureItem() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Organisation_Structure_Item__c i1 = new Organisation_Structure_Item__c();
        i1.Client_Plan__c = plan.Id;
        i1.Related_To__c = null;
        i1.Description__c = 'ccc';
        INSERT i1;
        
        String newDescription = 'ddd';
        
        Test.startTest();
        Boolean result = ClientPlanOrgStructureController.editStructureItem(i1.Id, newDescription);
        Test.stopTest();
        
        System.assertEquals(true, result);
        
        List<Organisation_Structure_Item__c> osis = [
            SELECT Client_Plan__c, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
            WHERE Id = :i1.Id
        ];
        
        System.assertEquals(1, osis.size());
        System.assertEquals(plan.Id, osis[0].Client_Plan__c);
        System.assertEquals(null, osis[0].Related_To__c);
        System.assertEquals(newDescription, osis[0].Description__c);
    }
    
    static testMethod void testRemoveStructureItem() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String description = 'aaa';
        
        Organisation_Structure_Item__c i1 = new Organisation_Structure_Item__c();
        i1.Client_Plan__c = plan.Id;
        i1.Related_To__c = null;
        i1.Description__c = description;
        INSERT i1;
        
        Organisation_Structure_Item__c i2 = new Organisation_Structure_Item__c();
        i2.Client_Plan__c = plan.Id;
        i2.Related_To__c = i1.Id;
        i2.Description__c = 'bbb';
        INSERT i2;
        
        Organisation_Structure_Item__c i3 = new Organisation_Structure_Item__c();
        i3.Client_Plan__c = plan.Id;
        i3.Related_To__c = i2.Id;
        i3.Description__c = 'ccc';
        INSERT i3;
    
        Test.startTest();
        Boolean result = ClientPlanOrgStructureController.removeStructureItem(new List<Id>{i2.Id, i3.Id});
        Test.stopTest();
        
        System.assertEquals(true, result);
        
        List<Organisation_Structure_Item__c> osis = [
            SELECT Id, Client_Plan__c, Related_To__c, Description__c
            FROM Organisation_Structure_Item__c
        ];
        
        System.assertEquals(1, osis.size());
        System.assertEquals(i1.Id, osis[0].Id);
        System.assertEquals(plan.Id, osis[0].Client_Plan__c);
        System.assertEquals(null, osis[0].Related_To__c);
        System.assertEquals(description, osis[0].Description__c);
    }
    
    static testMethod void testConstructor() {
        //no planId url parameter
        PageReference pr = Page.ClientOverview;
        Test.setCurrentPage(pr);
        ClientPlanOrgStructureController ctrl = new ClientPlanOrgStructureController();
        System.assertEquals(null, ctrl.plan);
        
        //planId url parameter with wrong value
        pr = Page.ClientOverview;
        pr.getParameters().put('planId', 'asdf');
        Test.setCurrentPage(pr);
        ctrl = new ClientPlanOrgStructureController();
        System.assertEquals(null, ctrl.plan);
        
        //correct planId
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ctrl = new ClientPlanOrgStructureController();
        System.assertEquals(plan.Id, ctrl.plan.Id);
    }
    
    static testMethod void testUploadImageErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanOrgStructureController ctrl = new ClientPlanOrgStructureController();
        
        PageReference result = ctrl.uploadImage();
        System.assertEquals(null, result);
        
        List<Attachment> ats = [SELECT Id FROM Attachment];
        System.assertEquals(0, ats.size());
    }
    
    static testMethod void testUploadImage() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanOrgStructureController ctrl = new ClientPlanOrgStructureController();
        
        String expName = 'asdf';
        String expCT = 'image/jpeg';
        String expBody = 'kjbhgjbasdf';
        ctrl.imageContentType = expCT;
        ctrl.imageName = expName;
        ctrl.imageBody = Blob.valueOf(expBody);
        
        PageReference result = ctrl.uploadImage();
        System.assertEquals(null, result);
        
        List<Attachment> ats = [SELECT Id, Name, ContentType, Body FROM Attachment];
        System.assertEquals(1, ats.size());
        
        Attachment at = ats[0];

        System.assertEquals(expName, at.Name);
        System.assertEquals(expCT, at.ContentType);
        System.assertEquals(expBody, at.Body.toString());

        //Is it linked to the ClientPlan?
        plan = [SELECT Id, Org_Structure_Image_ID__c FROM Client_Plan__c LIMIT 1];
        System.assertEquals(plan.Org_Structure_Image_ID__c, at.Id);
    }
    
    static testMethod void testDeleteImage() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Attachment a = new Attachment();
        a.ParentId = plan.Id;
        a.Name = 'asdf';
        a.Body = Blob.valueOf('bbnmkh');
        INSERT a;

        plan.Org_Structure_Image_ID__c = a.Id;
        UPDATE plan;
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanOrgStructureController ctrl = new ClientPlanOrgStructureController();
        
        PageReference result = ctrl.deleteImage();
        System.assertEquals(null, result);
        
        //Check if it's removed from ClientPlan
        plan = [SELECT Id, Org_Structure_Image_ID__c FROM Client_Plan__c LIMIT 1];
        System.assertEquals(plan.Org_Structure_Image_ID__c, null);
    }

    static testMethod void borrowersGuarantors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientPlanOrgStructureController ctrl = new ClientPlanOrgStructureController();

        Test.startTest();

        //Add a borrower
        ctrl.borrowerGuarantorType = 'Borrower';
        ctrl.borrowerGuarantorValue = 'A';
        ctrl.modifyBorrowerGuarantor();

        System.assertEquals(ctrl.borrowers.size(), 1);

        //Add a guarantor
        ctrl.borrowerGuarantorType = 'Guarantor';
        ctrl.borrowerGuarantorValue = 'B';
        ctrl.modifyBorrowerGuarantor();   

        System.assertEquals(ctrl.guarantors.size(), 1);

        //Modify the borrower
        Client_Plan_Borrowers_Guarantors__c borrowerRecord = ctrl.borrowers.get(0);
        ctrl.borrowerGuarantorId = borrowerRecord.Id;
        ctrl.borrowerGuarantorValue = 'C';
        ctrl.borrowerGuarantorType = borrowerRecord.Type__c;
        ctrl.modifyBorrowerGuarantor();   

        System.assertEquals(ctrl.borrowers.size(), 1);

        //Delete the Guarantor
        Client_Plan_Borrowers_Guarantors__c guarantorRecord = ctrl.guarantors.get(0);
        ctrl.borrowerGuarantorId = guarantorRecord.Id;
        ctrl.removeBorrowerGuarantor();

        System.assertEquals(ctrl.guarantors.size(), 0);

        Test.stopTest();
    }
}