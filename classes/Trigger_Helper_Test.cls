/**
*** CHANGE LOG ***

10/01/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Trigger_Helper_Test {
    
    public static testMethod void testAgreementLevel()
    {
        Date todaysDate = System.today();
        List<Trigger__c> triggerList = new List<Trigger__c>();
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        triggerList.add(testDataClass.testTrigger);
        
        test.startTest();
        
        testDataClass.testTrigger.Frequency__c = 'Once Off';
        testDataClass.testTrigger.Due_Date__c = todaysDate.addDays(100);
        
        update testDataClass.testTrigger;
        
        testDataClass.testTrigger.Frequency__c = 'Monthly';
        testDataClass.testTrigger.Relative_Date__c = 'Other';
        testDataClass.testTrigger.Number_Of_Days__c = 5;
        testDataClass.testTrigger.Days__c = 'Days After';
        testDataClass.testTrigger.Other_Relative_Date__c = todaysDate.addDays(50);
        testDataClass.testTrigger.Due_Date__c = null;
        
        update testDataClass.testTrigger;
        
        testDataClass.TestAgreement.Termination_Date__c = todaysDate.addYears(5) ;       
        update testDataClass.TestAgreement;
        
        trigger_Helper.insertWatcherOccurence(triggerList);
        
        test.stopTest();
        
    }
}