/**
*** CHANGE LOG ***

10/01/2018 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Trigger_Override_Test {
    
    public static testMethod void testAgreementLevel()
    {
         Date todaysDate = System.today();
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

        //VF page
        PageReference pageRef = Page.Trigger_Override;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.testTrigger);
        Trigger_Override ec = new Trigger_Override(sc);
        
        test.startTest();

        ec.participantsWrapper[0].selected = true;
        ec.distroGroupsWrapper[0].selected = true; 

        //Methods
        ec.populateLookups();
        ec.saveRecord();
        
        testDataClass.testTrigger.Due_Date__c = todaysDate.addDays(-60);
        
        ec.saveRecord();
        
        test.stopTest();

    }

}