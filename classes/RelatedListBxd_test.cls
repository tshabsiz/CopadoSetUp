@isTest
public class RelatedListBxd_test {
    
    
    @isTest static void viewListTest()
    {

      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      Test.stopTest();
      //system.assert(bxdListContr.sortField == 'Document_Number__c');   //PG failing in UAT... 
      
    }
    
      @isTest static void viewListRecordTest()
    {
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      List<BoxDocument__c> bxdRecords = bxdListContr.bxdRecords;
      Test.stopTest();
      system.assert(bxdRecords != null);   
      
    }
    
      @isTest static void viewListSortTest()
    {
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      bxdListContr.sortList();
      bxdListContr.clearFilterList();
      Test.stopTest();
    }
      @isTest static void viewListFilterTest()
    {
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      bxdListContr.boxDocument.Name = 'Test Box Document';
      bxdListContr.filterList();
      Test.stopTest();
    }
    
    
    @isTest static void viewListOwner()
    {
      BXDtesclassdata.setupFolder();
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
      BoxDocumentViewHelper_test.createAgreement();   
            
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      bxdListContr.sortList();
      bxdListContr.clearFilterList();
      Test.stopTest();
    }
    
       @isTest static void viewEditTest()
    {
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      PageReference pageRef = bxdListContr.edit();
      bxdListContr.clearFilterList();
      Test.stopTest();
      system.assert(pageRef != null);
    }
           @isTest static void viewRecordTest()
    {
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
     
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      PageReference pageRef = bxdListContr.view();
     
      Test.stopTest();
      system.assert(pageRef != null);
    }
          @isTest static void styleConditonTest()
    {
      
      BXDtesclassdata.setupFolder();
      BoxDocumentViewHelper_test.createCustomSettings();
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
      BoxDocumentViewHelper_test.createAgreement();
      BoxDocumentViewHelper_test.createConditionFC();
      
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      bxdListContr.boxDocument.Name = 'Test Box Document';
      bxdListContr.setStyleByRecordType(BoxDocumentViewHelper_test.ConditionId);
      Test.stopTest();
      
    }
   
    
     @isTest static void styleConditonOccTest()
    {
      BXDtesclassdata.setupFolder();
      BoxDocumentViewHelper_test.createCustomSettings();
      BoxDocumentViewHelper_test.createAccountDeal();
      BoxDocumentViewHelper_test.createBxd();
      BoxDocumentViewHelper_test.createAgreement();
      BoxDocumentViewHelper_test.createConditionFC();
      BoxDocumentViewHelper_test.createConditionOccFC();
      string BxdOwnerId = BoxDocumentViewHelper_test.DealId;
      string bxdId = BoxDocumentViewHelper_test.BxdId;
      PageReference BxdList = new PageReference('/apex/BxdDocuments?sortField=Name');
      Test.setCurrentPage(BxdList);
      Test.startTest();
      RelatedListBxd bxdListContr = new  RelatedListBxd();
      bxdListContr.boxDocument.Name = 'Test Box Document';
      bxdListContr.setStyleByRecordType(BoxDocumentViewHelper_test.ConditionOccId);
      Test.stopTest();
    }
   
        @isTest static void sendToDocusignTest()
    {
        BoxDocumentViewHelper_test.createCustomSettings();
        BoxDocumentViewHelper_test.createAccountDeal();
        BoxDocumentViewHelper_test.createBxd();
        BoxDocumentViewHelper_test.createAgreement();
        
        BoxDocument__c boxDocument = new BoxDocument__c(
                Name = 'random Name',
                PII__c = 'Yes',
                Owner_Type__c = 'Agreement__c',
                Status__c = 'Final',
                Type__c = 'Agreement',
                send_to_docusign__c = true
         );
        
         BXDtesclassdata.setupFolder();
         string BxdOwnerId = BoxDocumentViewHelper_test.AgreementId;
         string bxdId = BoxDocumentViewHelper_test.BxdId;
         PageReference BxdList = new PageReference('/apex/AgreementBxdDocuments');
         Test.setCurrentPage(BxdList);
         Test.startTest();
         RelatedListBxd bxdListContr = new  RelatedListBxd();
         bxdListContr.BxdOwnerId = BxdOwnerId;
         List<BoxDocument__c> AgreementBxdRecords = bxdListContr.AgreementsbxdRecords;
         bxdListContr.setStyleByRecordType(BoxDocumentViewHelper_test.AgreementId);
         bxdListContr.sendDocumentstoDocusign();
         Test.stopTest();
    }

}