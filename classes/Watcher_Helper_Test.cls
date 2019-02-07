/**
*** CHANGE LOG ***
 
10/01/2018 - TdB    - Created Class.
12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 

@isTest(SeeAllData=false)
public class Watcher_Helper_Test {
    
    static testMethod void Watcher_Test()
    {       
        Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();
        
        Test.startTest();
        
        //Margin Ratchet
        testData.testMarginRatchetWatcher.Watcher_Status__c = 'Breached';
        update testData.testMarginRatchetWatcher;
        
        //Collateral Valuation
        testData.testCollateralValuationWatcher.Report_Grading__c = 'Concern';
        testData.testCollateralValuationWatcher.Comments__c = 'Testing';
        update testData.testCollateralValuationWatcher;
        
        //Collateral Monitoring
         testData.testCollateralMonitoringWatcher.Result__c = 'Expectation Not Met';
         testData.testCollateralMonitoringWatcher.Comments__c = 'Testing';
        update testData.testCollateralMonitoringWatcher;
        
        
        //Trigger
         testData.testTriggerWatcher.Watcher_Status__c = 'Breached with Action';
         testData.testTriggerWatcher.Comments__c = 'Testing';
        update testData.testTriggerWatcher;
        
        testData.testTrigger.Frequency__c = 'Monthly';
        testData.testTrigger.Relative_Date__c = 'Other';
        testData.testTrigger.Other_Relative_Date__c = System.today();
        testData.testTrigger.Due_Date__c = null;
        testData.testTrigger.Number_of_Days__c = 2;
        testData.testTrigger.Days__c = '    Days After';
        
        Watcher_Helper.calculateWatcherDueDate(testData.testTrigger, System.today());
        
        testData.testTrigger.Frequency__c = 'Quarterly';
        Watcher_Helper.calculateWatcherDueDate(testData.testTrigger, System.today());
        
        testData.testTrigger.Frequency__c = 'Bi-Annually';
        Watcher_Helper.calculateWatcherDueDate(testData.testTrigger, System.today());
        
        testData.testTrigger.Frequency__c = 'Annually';
        Watcher_Helper.calculateWatcherDueDate(testData.testTrigger, System.today());

        Test.stopTest();      
    }

}