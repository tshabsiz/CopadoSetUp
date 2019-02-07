@isTest(SeeAllData=false)
private class Fit_To_Lend_Trigger_Test 
{
    static testMethod void testUpdate()
    {
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomadin.com');
        insert random;

        Fit_To_Lend_Checklist__c testRecord = new Fit_To_Lend_Checklist__c(Deal__c = testData.TestMatter.Id, Status__c = 'New');
        insert testRecord;

        Attachment file = new Attachment(ParentId = testRecord.Id, Body = Blob.valueOf('Blob'), Name = 'Test File', Description = 'System Generated');
        insert file;
        
        Test.startTest();

        testRecord.Status__c = 'Approved';
        update testRecord;

        Test.stopTest();
    }   
}