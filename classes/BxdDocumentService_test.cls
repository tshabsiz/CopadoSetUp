@isTest
public class BxdDocumentService_test {
    public static testmethod void testDealBoxDocument(){        
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Matter__c = testDataClass.TestMatter.Id;
        TestBoxDocument.Owner_Type__c = 'advpm__Matter__c';
        TestBoxDocument.Name= 'Test Box Document 1';
        TestBoxDocument.Type__c = 'Deal Matter';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00001';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();        
    }
    
    public static testmethod void testAgreementBoxDocument() {       
        
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT       
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Agreement__c = testDataClass.TestAgreement.Id;
        TestBoxDocument.Owner_Type__c = 'Agreement__c';
        TestBoxDocument.Name= 'Test Box Document 2';
        TestBoxDocument.Type__c = 'Agreement';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00002';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();        
    }
    
    public static testmethod void testConditionBoxDocument(){       
        
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Condition__c = testDataClass.testConditionGC.Id;
        TestBoxDocument.Owner_Type__c = 'Condition__c';
        TestBoxDocument.Name= 'Test Box Document 3';
        TestBoxDocument.Type__c = 'Governance Check';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00003';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();         
    }
    
    public static testmethod void testConditionOccurenceBoxDocument(){             
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Condition_Occurrence__c = testDataClass.TestConditionOcc.Id;
        TestBoxDocument.Owner_Type__c = 'Condition_Occurrence__c';
        TestBoxDocument.Name= 'Occ Box Document 4';
        TestBoxDocument.Type__c = 'Financial Covenant';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00004';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();        
    }
    
    public static testmethod void testCollateralBoxDocument(){          
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Collateral__c = testDataClass.TestCollateral.Id;
        TestBoxDocument.Owner_Type__c = 'Collateral__c';
        TestBoxDocument.Name= 'Collateral Box Document 4';
        TestBoxDocument.Type__c = 'Collateral Cession';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00005';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();      
    }
    
    public static testmethod void testDrawdownsBoxDocument(){    
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Drawdown__c = testDataClass.TestDrawdown.Id;
        TestBoxDocument.Owner_Type__c = 'Drawdown__c';
        TestBoxDocument.Name= 'Drawdown Box Document 4';
        TestBoxDocument.Type__c = 'Drawdown';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789';
        TestBoxDocument.Box_Unique_Id__c = '00006';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();     
    }
    
    public static testmethod void testCreateBoxCaseFolder(){      
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        //BOX DOCUMENT       
        test.startTest();
        BoxDocument__c TestBoxDocument = new BoxDocument__c();
        TestBoxDocument.PII__c = 'Yes';
        TestBoxDocument.Expiry_Date__c = Date.today().addDays(15);
        TestBoxDocument.Agreement__c = testDataClass.TestAgreement.Id;
        TestBoxDocument.Owner_Type__c = 'Agreement__c';
        TestBoxDocument.Name= 'Test Box Document 2';
        TestBoxDocument.Type__c = 'Agreement';
        TestBoxDocument.Status__c = 'Final';
        TestBoxDocument.Box_Location__c = 'http://test.box.com/123456789'; 
        TestBoxDocument.Box_Unique_Id__c = '00002';
        TestBoxDocument.Upload_Date__c = DateTime.now();
        insert TestBoxDocument;
        Test.stopTest();
        
        Blob bodyBlob=Blob.valueOf('TestBoxDocument Attachment Test Attachment Body');
        BxdDocumentService.uploadHotDocsToBox(TestBoxDocument.Id, bodyBlob);
    }
}