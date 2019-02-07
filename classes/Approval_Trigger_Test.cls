@isTest(SeeAllData=false)
/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***
11/01/2018 - PG     - Not sure what or who create this test, however testData was in the incorrect place.   Corrected this now. 
19/03/2018 - TdB	- Add testDrawDown() and testAgreement()
**/ 
private class Approval_Trigger_Test 
{	
    public static Map <String, Schema.RecordTypeInfo> mapAppRecordTypes = Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
    static testMethod void testUpdateLitigation()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();

        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
        insert random;
        
        //advpm__Matter__c parent = new advpm__Matter__c();
        //insert parent;
        //Test.startTest();
        Fit_To_Lend_Checklist__c checklist = new Fit_To_Lend_Checklist__c(Deal__c = testData.TestMatter.Id, Status__c = 'New');
        insert checklist;
        
        
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        attach.Description = 'System Generated';   
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=checklist.id;  
        insert attach;
        
        Approval__c testRecord = new Approval__c
        (
            Matter_Deal__c = testData.TestMatter.id,
            Fit_To_Lend_Checklist__c = checklist.Id,
            recordTypeID =  mapAppRecordTypes.get('Litigation Matter').getRecordTypeId()
        );
        insert testRecord;
        testRecord.Litigation_Matter_Approved__c = 'yes';
        testRecord.Status__c = 'Approved';
        update testRecord;
        test.stopTest();
    }	
    
    static testMethod void testUpdateFitToLend()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();

        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
        insert random;
        
        //advpm__Matter__c parent = new advpm__Matter__c();
        //insert parent;
        //Test.startTest();
        Fit_To_Lend_Checklist__c checklist = new Fit_To_Lend_Checklist__c(Deal__c = testData.TestMatter.Id, Status__c = 'New');
        insert checklist;
        
        
        Attachment attach=new Attachment();   	
        attach.Name='Unit Test Attachment';
        attach.Description = 'System Generated';   
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=checklist.id;  
        insert attach;
        
        Approval__c testRecord = new Approval__c
        (
            Matter_Deal__c = testData.TestMatter.id,
            Fit_To_Lend_Checklist__c = checklist.Id,
            recordTypeID =  mapAppRecordTypes.get('Fit To Lend Approval').getRecordTypeId()
        );
        insert testRecord;
        testRecord.Litigation_Matter_Approved__c = 'yes';
        testRecord.Status__c = 'Approved';
        update testRecord;
        test.stopTest();
    }	
    
    
    static testMethod void testDrawDown()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();
		
        Map <String, Schema.RecordTypeInfo> mapDrawdownRecordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
        insert random;
        
        Drawdown__c drawdownItem = new Drawdown__c
        (
            Name = 'TestDown', 
            Agreement__c = testData.TestAgreement.Id,
            Status__c = 'Governance and Documentation Check  Incomplete', 
            Advance_Amount__c = 100,
            Current_Utilisation__c = 50,
            Facility_Limit__c = 200,
            Account_Name__c = 'Test Acc Name',
            Account_Number__c = '123',
            Account_Branch__c = '123', 
            Account_Bank__c = 'Test Bank Acc',
            Advance_Date__c = Date.today(),
            Reference__c = 'Blah blah',
            Request_Date__c = Date.today(),
            CurrencyISOCode = 'ZAR',
            RecordTypeId = mapDrawdownRecordTypes.get('Drawdown').getRecordTypeId()
        );
        insert drawdownItem;
        
        Approval__c testRecord = new Approval__c
        (
            Matter_Deal__c = testData.TestMatter.id,
            Drawdown__c = drawdownItem.Id,
            recordTypeID =  mapAppRecordTypes.get('Drawdown Approval').getRecordTypeId()
        );
        insert testRecord;
        
        Approval__c testRecord2 = new Approval__c
        (
            Matter_Deal__c = testData.TestMatter.id,
            Drawdown__c = drawdownItem.Id
            //recordTypeID =  mapAppRecordTypes.get('Drawdown Approval').getRecordTypeId()
        );
        insert testRecord2;

        testRecord.Status__c = 'Approved';
        update testRecord;
        test.stopTest();
    }	
    
    static testMethod void testAgreement()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();

        Map <String, Schema.RecordTypeInfo> mapAppRecordTypes = Approval__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
        insert random;
        
        Agreement__c TestAgreement = new Agreement__c
        (
            Matter_Deal__c =  TestData.TestMatter.id,
            Name = 'Test',
            Agreement_Type__c =    TestData.TestProductAgreement.id,
            TMG_Product_Level_3__c = TestData.TestProductLevel3.id,
            Signature_Date__c = Date.today().addDays(5),
            Effective_Date__c = Date.today().addDays(5),
            Limit__c = 10000
        );
        Insert TestAgreement;   
        
        Approval__c testRecord = new Approval__c
        (
            Matter_Deal__c = testData.TestMatter.id,
            Agreement__c = TestAgreement.Id,
            recordTypeID =  mapAppRecordTypes.get('Agreement Approval').getRecordTypeId()
        );
        insert testRecord;

        testRecord.Status__c = 'Approved';
        update testRecord;
        test.stopTest();
    }	
    
    static testMethod void testUpdateMatter()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Test.startTest();        

        list<BoxTestMockCallout.MockResponse> responses = new list<BoxTestMockCallout.MockResponse>();
        BoxTestMockCallout.MockResponse retryResponse = new BoxTestMockCallout.MockResponse('{"status":"retry"}', 'ERROR', 500);
        responses.add(retryResponse);
        BoxTestMockCallout.MockResponse successResponse = new BoxTestMockCallout.MockResponse('{"status":"success"}', 'OK', 200);
        responses.add(successResponse);
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(responses));
        
        //advpm__Matter__c matter = new advpm__Matter__c();
        //insert matter;
        
        Approval__c testRecord = new Approval__c(Matter_Deal__c = testData.TestMatter.Id);
        insert testRecord;
        
        testRecord.Litigation_Matter_Approved__c = 'Yes';
        update testRecord;

        Test.stopTest();
    }
}