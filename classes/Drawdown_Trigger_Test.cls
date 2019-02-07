@isTest(SeeAllData=false)
private class Drawdown_Trigger_Test 
{   
    static testMethod void testUpdate()
    {
        //Setup data data
        BXDtesclassdata.setupFolder();

        Test.startTest();

        Contact random = new Contact(LastName = 'Smit', FirstName = 'Jan', Email = 'test@fakeDomain.com');
        insert random;

        Agreement__c testAgreement = new Agreement__c();
        insert testAgreement;

        Drawdown__c testRecord = new Drawdown__c(Agreement__c = testAgreement.Id, Advance_Amount__c = 1);
        insert testRecord;

        testRecord.Supporting_Documentation_Uploaded__c = true;
        update testRecord;

        Test.stopTest();
    }   
}