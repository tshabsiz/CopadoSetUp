@isTest
public class BoxDocumentDetailController_test {
    
    @isTest static void viewRecordTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentView?bxdId=' + bxdId + '&BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        Test.stopTest();        
    }
    
    @isTest static void viewAgreementRecordTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        BoxDocumentViewHelper_test.createAgreement();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.AgreementId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentEditStep1?BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        Test.stopTest();        
    }
    
    @isTest static void viewConditionRecordTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        BoxDocumentViewHelper_test.createAgreement();
        BoxDocumentViewHelper_test.createCondition();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.ConditionId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentView?BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        Test.stopTest();        
    }
    
    @isTest static void saveTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentView?BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        bxdDetailContr.boxDocument.Name = 'TestingBxD_Attach';
        bxdDetailContr.boxDocument.Expiry_Date__c = date.today();
        bxdDetailContr.boxDocument.PII__c = 'Yes';
        bxdDetailContr.save();
        Test.stopTest();
    }

    @isTest static void cancelTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentView?bxdId=' + bxdId + '&BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        bxdDetailContr.Cancel();
        Test.stopTest();
    }
    
    @isTest static void cancelAndDeleteTest() {
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        
        BoxDocumentViewHelper_test.createBxd();
        
        BxdDocumentHelper helper = new BxdDocumentHelper(BoxDocumentViewHelper_test.boxDocument, 'filename.txt');
        List<BxdDocumentHelper> uploadDocuments = new List<BxdDocumentHelper>();
        uploadDocuments.add(helper);
        
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentEditStep3?BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        bxdDetailContr.uploadDocuments = uploadDocuments;
        bxdDetailContr.Cancel();
        Test.stopTest();
    }
    
    @isTest static void saveTestCases() {
        BXDtesclassdata.setupFolder();
        BoxDocumentViewHelper_test.createAccountDeal();
        string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
        string bxdId = BoxDocumentViewHelper_test.BxdId;
        PageReference BxdView = new PageReference('/apex/BoxDocumentView?BxdOwnerId=' + BxdOwnerId);
        Test.setCurrentPage(BxdView);
        Test.startTest();
        BoxDocumentDetailController bxdDetailContr = new  BoxDocumentDetailController();
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        bxdDetailContr.boxDocument.Name = 'TestingBxD_Attach';
        bxdDetailContr.boxDocument.Expiry_Date__c = date.today();
        bxdDetailContr.boxDocument.PII__c = 'Yes';
        
        // Create box doc
        
        BoxDocument__c box = new BoxDocument__c();
        box.Name = 'TestingBxD_Attach';
        box.Expiry_Date__c = date.today();
        box.PII__c = 'Yes';
        box.Box_Location__c = 'test.url';
        box.Box_Unique_Id__c = 'testId';
        bxdDetailContr.uploadDocuments.add(new BxdDocumentHelper(box, box.Name));   
        
        // Test cases 
        bxdDetailContr.curStep = 2;
        bxdDetailContr.next();
        bxdDetailContr.previous();
        bxdDetailContr.save();
        
        // Test Other methods
        String responseJSON = '[{"id":"278633831388","name":"boxupload8.pdf","url":"https://account.box.com/file/278633831388","parent":"46182294024"}]';
        bxdDetailContr.uploadedResponse = responseJSON;
        
        BxdDocumentHelper helper = new BxdDocumentHelper(BoxDocumentViewHelper_test.boxDocument, 'filename.txt');
        List<BxdDocumentHelper> uploadDocuments = new List<BxdDocumentHelper>();
        uploadDocuments.add(helper);
        bxdDetailContr.supportingDocuments = uploadDocuments;
        
        bxdDetailContr.curStep = 3;
        bxdDetailContr.next();
        
        bxdDetailContr.supportingDocuments.add(new BxdDocumentHelper(box, box.Name));
        bxdDetailContr.actionBoxCreateFolder();
        bxdDetailContr.getUploadedDocuments();
        bxdDetailContr.RefreshAttachments();
        bxdDetailContr.getPageTitle();
        
        bxdDetailContr.OwnerSelectedVal = 'Account';
        bxdDetailContr.RenderSec();
        
        bxdDetailContr.OwnerSelectedVal = 'Agreement__c';
        bxdDetailContr.RenderSec();
        
        bxdDetailContr.OwnerSelectedVal = 'Condition__c';
        bxdDetailContr.RenderSec();
        
        bxdDetailContr.OwnerSelectedVal = 'Collateral__c';
        bxdDetailContr.RenderSec();
        
        bxdDetailContr.OwnerSelectedVal = 'Condition_Occurrence__c';
        bxdDetailContr.RenderSec();
        
        bxdDetailContr.OwnerSelectedVal = 'Drawdown__c';
        bxdDetailContr.RenderSec();     
        
        Test.stopTest();
    }
}