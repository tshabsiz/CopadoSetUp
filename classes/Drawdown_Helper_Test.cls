@isTest(SeeAllData=false)
private class Drawdown_Helper_Test 
{
    static testMethod void Drawdown_Helper_Test()
    {       
        Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();
        
        Test.startTest();

        //Updat documentation status.
        testData.TestDrawdown.Supporting_Documentation_Uploaded__c = true;
        update testData.TestDrawdown;

        Test.stopTest();      
    }
    
     static testMethod void Drawdown_Facility_Helper_Test()
    {       
        Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();
        
        //DRAWDOWN
        Drawdown__c TestDrawdown_Facility = new Drawdown__c
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
            Facility__c = testData.TestFacility.id
        );
        insert TestDrawdown_Facility;

        Test.startTest();

        //Updat documentation status.
        testData.TestDrawdown.Supporting_Documentation_Uploaded__c = true;
        update testData.TestDrawdown;

        Test.stopTest();      
    }
    
     static testMethod void Drawdown_Tranche_Helper_Test()
    {       
        Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();

		//DRAWDOWN
        Drawdown__c TestDrawdown_FacilityTranche = new Drawdown__c
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
            Facility__c = testData.TestFacility.id,
            Facility_Tranche__c = testData.TestFacilityTranche.id
        );
        insert TestDrawdown_FacilityTranche;
        
        Test.startTest();

        //Updat documentation status.
        testData.TestDrawdown.Supporting_Documentation_Uploaded__c = true;
        update testData.TestDrawdown;

        Test.stopTest();      
    }
}