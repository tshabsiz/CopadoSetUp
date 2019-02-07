/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanSummaryController
*                 Tests executed:
*                 1 - testConstructorErrors()
*                   Tests errors handling of constructor
*                 2 - testConstructor()
*                   Tests constructor
*                 3 - testGetOrganogramData()
*                   Tests preparation of data for organogram
*                 4 - testQueryCountries()
*                   Tests preparation of data for country presence map
*                 5 - testGetStakeholdersHierarchyData()
*                   Tests preparation of data for stakeholders hierarchy
*                 6 - testQueryOrgStructureImageErrors()
*                   Tests errors handling during querying organogram image
*                 7 - testQueryOrgStructureImage()
*                   Tests querying organogram image
*                 8 - testGetDocumentIdErrors()
*                   Tests errors handling during querying Id of previously generated PDF
*                 9 - testGetDocumentId()
*                   Tests querying Id of previously generated PDF
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanSummaryController {
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        INSERT ap;
    }
    
    static testMethod void testConstructorErrors() {
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', 'asdfasdf');
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();
        Test.stopTest();
        
        System.assertEquals(false, ctrl.planLoaded);
        
        System.assertEquals(null, ctrl.detailsCtrl);
        System.assertEquals(null, ctrl.overviewController);
        System.assertEquals(null, ctrl.sectorOverview);
        System.assertEquals(null, ctrl.clientOverview);
        System.assertEquals(null, ctrl.orgStructureController);
        System.assertEquals(null, ctrl.financialsController);
        System.assertEquals(null, ctrl.presenceController);
        System.assertEquals(null, ctrl.strategyController);
        System.assertEquals(null, ctrl.planController);
    }
    
    static testMethod void testConstructor() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();
        Test.stopTest();
        
        System.assertEquals(plan.Id, ctrl.planId);
        System.assertEquals(true, ctrl.planLoaded);
        
        System.assertNotEquals(null, ctrl.detailsCtrl);
        System.assertNotEquals(null, ctrl.overviewController);
        System.assertNotEquals(null, ctrl.sectorOverview);
        System.assertNotEquals(null, ctrl.clientOverview);
        System.assertNotEquals(null, ctrl.orgStructureController);
        System.assertNotEquals(null, ctrl.financialsController);
        System.assertNotEquals(null, ctrl.presenceController);
        System.assertNotEquals(null, ctrl.strategyController);
        System.assertNotEquals(null, ctrl.planController);
    }
    
    static testMethod void testGetOrganogramData() {
        //planId null
        String result = ClientPlanSummaryController.getOrganogramData(null);
        System.assertEquals('', result);
        
        //planId not exists
        result = ClientPlanSummaryController.getOrganogramData('asdfasdf');
        System.assertEquals('', result);
    
        //planId exists
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        result = ClientPlanSummaryController.getOrganogramData(plan.Id);
        System.assertNotEquals(null, result);
    }
    
    static testMethod void testQueryCountries() {
        //planId null
        String result = ClientPlanSummaryController.queryCountries(null);
        System.assertNotEquals('', result);
        
        //planId not exists
        result = ClientPlanSummaryController.queryCountries('asdfasdf');
        System.assertNotEquals('', result);
    
        //planId exists
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        result = ClientPlanSummaryController.queryCountries(plan.Id);
        System.assertNotEquals(null, result);
    }
    
    static testMethod void testGetStakeholdersHierarchyData() {
        //planId null
        String result = ClientPlanSummaryController.getStakeholdersHierarchyData(null);
        System.assertNotEquals(null, result);
        
        //planId not exists
        result = ClientPlanSummaryController.getStakeholdersHierarchyData('asdfasdf');
        System.assertNotEquals(null, result);
    
        //planId exists
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        result = ClientPlanSummaryController.getStakeholdersHierarchyData(plan.Id);
        System.assertNotEquals(null, result);
    }
    
    static testMethod void testGeneratePdf() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();

        try {
            ClientPlanSummaryController.savePresenceImg(plan.Id, '');
        } catch(Exception e) {
            //This should fail
            System.assertEquals(true, e.getMessage().indexOf('both planId and imgSrc are required') >= 0);
        }
        ClientPlanSummaryController.saveGroupImg(plan.Id, 'x');

        ClientPlanSummaryController.savePresenceImg(plan.Id, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA+gAAAKHCAYAAAASdmLfAAAgAElEQVR');
        ClientPlanSummaryController.saveGroupImg(plan.Id, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA+gAAAKHCAYAAAASdmLfAAAgAElEQVR');
        
        ctrl.generatePdf();
        Test.stopTest();
        
        //Check if we have a PDF attached to the ClientPlan
        List<Attachment> pdfAttachments = [SELECT Id from Attachment WHERE parentId = :plan.Id AND ContentType = 'application/pdf'];

        //Check if we have PNG attached to the ClientPlan
        List<Attachment> pngAttachments = [SELECT Id from Attachment WHERE parentId = :plan.Id AND ContentType = 'image/png'];

        //And we can retrieve the timestamp
        String docTimeStamp = ctrl.getDocumentTimestamp();

        System.assertEquals(1, pdfAttachments.size());
        System.assertEquals(2, pngAttachments.size());
        System.assertNotEquals(null, docTimeStamp);
    }
    
    static testMethod void testQueryOrgStructureImage() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        Attachment att = new Attachment();
        att.ParentId = plan.Id;
        att.Name = 'Something.png';
        att.ContentType = 'image/png';
        att.Body = Blob.valueOf('Something');
        INSERT att;

        plan.Org_Structure_Image_ID__c = att.Id;
        UPDATE plan;
        
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();
        Test.stopTest();
        
        System.assertEquals(att.Id, ctrl.plan.Org_Structure_Image_ID__c);
    }
    
    static testMethod void testGetDocumentIdErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();
        
        Test.startTest();
        String result = ctrl.getDocumentId();
        Test.stopTest();
        
        System.assertEquals(null, result);
    }
    
    static testMethod void testGetDocumentId() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Attachment att = new Attachment();
        att.ParentId = plan.Id;
        att.Name = 'Something.pdf';
        att.ContentType = 'application/pdf';
        att.Body = Blob.valueOf('Something');
        INSERT att;
        
        PageReference pr = Page.ClientPlanSummary;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanSummaryController ctrl = new ClientPlanSummaryController();
        
        Test.startTest();
        String result = ctrl.getDocumentId();
        Test.stopTest();
        
        System.assertEquals(att.Id, result);
    }
}