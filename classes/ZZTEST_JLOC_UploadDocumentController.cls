/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_SubmitToSecretaryController
*              Tests executed:
*               1 - testUploadPricingAndReturns()
*                   Test that Pricing and Returns document can be uploaded and attached.
*               2 - testUploadConflictClearance()
*                   Test that Conflict Clearance document can be uploaded and attached.
*               3 - testUploadPreScreening()
*                   Test that Pre-screening document can be uploaded and attached.
*/
@isTest
private class ZZTEST_JLOC_UploadDocumentController {

	public static testMethod void testUploadPricingAndReturns(){
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

		PageReference JLOC_UploadDocument = Page.JLOC_UploadDocument;
        Test.setCurrentPage(JLOC_UploadDocument);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        ApexPages.currentPage().getParameters().put('fileType', 'PricingAndReturns');
        ApexPages.currentPage().getParameters().put('anchor','/7');
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_UploadDocumentController controller = new JLOC_UploadDocumentController(stc);

        controller.attachment.Name = 'test.pdf';
        controller.attachment.Body = Blob.ValueOf('test attachment');
        controller.save();
        controller.Cancel();

        Test.stopTest();

        //Check that the Pricing and Returns ID pointer has changed
        jloc = [SELECT Id, Pricing_and_Returns_Document_ID__c FROM JLOC__c WHERE Id = :jloc.Id];

        System.assertEquals(false, String.isBlank(jloc.Pricing_and_Returns_Document_ID__c));
        System.assertNotEquals(attachment.Id, jloc.Pricing_and_Returns_Document_ID__c);
	}

    public static testMethod void testUploadAncillaryCalculation(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'second_test.png';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Ancillary_Calculation_Document_ID__c = attachment.Id;
        UPDATE jloc;
        
        Test.startTest();

        PageReference JLOC_UploadDocument = Page.JLOC_UploadDocument;
        Test.setCurrentPage(JLOC_UploadDocument);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        ApexPages.currentPage().getParameters().put('fileType', 'AncillaryCalculation');
        ApexPages.currentPage().getParameters().put('anchor','/7');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_UploadDocumentController controller = new JLOC_UploadDocumentController(stc);

        controller.attachment.Name = 'test.pdf';
        controller.attachment.Body = Blob.ValueOf('test attachment');
        controller.save();

        Test.stopTest();

        //Check that the Ancillary Calculation ID pointer has changed
        jloc = [SELECT Id, Ancillary_Calculation_Document_ID__c FROM JLOC__c WHERE Id = :jloc.Id];

        System.assertEquals(false, String.isBlank(jloc.Ancillary_Calculation_Document_ID__c));
        System.assertNotEquals(attachment.Id, jloc.Ancillary_Calculation_Document_ID__c);
    }
    public static testMethod void testUploadStressCaseForeCast(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'second_test.png';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Stress_Case_ID__c = attachment.Id;
        UPDATE jloc;
        
        Test.startTest();

        PageReference JLOC_UploadDocument = Page.JLOC_UploadDocument;
        Test.setCurrentPage(JLOC_UploadDocument);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        ApexPages.currentPage().getParameters().put('fileType', 'StressCase');
        ApexPages.currentPage().getParameters().put('anchor','/3');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_UploadDocumentController controller = new JLOC_UploadDocumentController(stc);

        controller.attachment.Name = 'test.pdf';
        controller.attachment.Body = Blob.ValueOf('test attachment');
        controller.save();

        Test.stopTest();

        //Check that the Ancillary Calculation ID pointer has changed
        jloc = [SELECT Id, Stress_Case_ID__c FROM JLOC__c WHERE Id = :jloc.Id];

        System.assertEquals(false, String.isBlank(jloc.Stress_Case_ID__c));
        System.assertNotEquals(attachment.Id, jloc.Stress_Case_ID__c);
    }
    public static testMethod void testUploadBankCaseForeCast(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'second_test.png';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Banker_Case_ID__c = attachment.Id;
        UPDATE jloc;
        
        Test.startTest();

        PageReference JLOC_UploadDocument = Page.JLOC_UploadDocument;
        Test.setCurrentPage(JLOC_UploadDocument);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        ApexPages.currentPage().getParameters().put('fileType', 'BankCase');
        ApexPages.currentPage().getParameters().put('anchor','/3');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_UploadDocumentController controller = new JLOC_UploadDocumentController(stc);

        controller.attachment.Name = 'test.pdf';
        controller.attachment.Body = Blob.ValueOf('test attachment');
        controller.save();

        Test.stopTest();

        //Check that the Ancillary Calculation ID pointer has changed
        jloc = [SELECT Id, Banker_Case_ID__c FROM JLOC__c WHERE Id = :jloc.Id];

        System.assertEquals(false, String.isBlank(jloc.Banker_Case_ID__c));
        System.assertNotEquals(attachment.Id, jloc.Banker_Case_ID__c);
    }
    public static testMethod void testUploadManagementCaseForeCast(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        Attachment attachment = new Attachment();
        attachment.ParentId = jloc.Id;
        attachment.Name = 'second_test.png';
        attachment.Body = Blob.ValueOf('first test attachment');
        INSERT attachment;

        jloc.Management_Case_ID__c = attachment.Id;
        UPDATE jloc;
        
        Test.startTest();

        PageReference JLOC_UploadDocument = Page.JLOC_UploadDocument;
        Test.setCurrentPage(JLOC_UploadDocument);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
        ApexPages.currentPage().getParameters().put('fileType', 'ManagementCase');
        ApexPages.currentPage().getParameters().put('anchor','/3');
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_UploadDocumentController controller = new JLOC_UploadDocumentController(stc);

        controller.attachment.Name = 'test.pdf';
        controller.attachment.Body = Blob.ValueOf('test attachment');
        controller.save();

        Test.stopTest();

        //Check that the Ancillary Calculation ID pointer has changed
        jloc = [SELECT Id, Management_Case_ID__c FROM JLOC__c WHERE Id = :jloc.Id];

        System.assertEquals(false, String.isBlank(jloc.Management_Case_ID__c));
        System.assertNotEquals(attachment.Id, jloc.Management_Case_ID__c);
    }
}