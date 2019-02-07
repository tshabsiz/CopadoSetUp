/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Collateral_Monitoring_Helper_Test 
{
    public static testMethod void testClass()
	{
        Date todaysDate = System.today();
        List<Collateral_Monitoring__c> collateralMonitoringList = new List<Collateral_Monitoring__c>();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        collateralMonitoringList.add(testDataClass.testCollateralMonitoring);
        
        test.startTest();
        
        testDataClass.testCollateralMonitoring.Frequency__c = 'Once Off';
        testDataClass.testCollateralMonitoring.Due_Date__c = todaysDate.addDays(100);
        
        update testDataClass.testCollateralMonitoring;
        
        testDataClass.testCollateralMonitoring.Frequency__c = 'Monthly';
        testDataClass.testCollateralMonitoring.Relative_Date__c = 'Other';
        testDataClass.testCollateralMonitoring.Number_Of_Days__c = 5;
        testDataClass.testCollateralMonitoring.Days__c = 'Days After';
        testDataClass.testCollateralMonitoring.Other_Relative_Date__c = todaysDate.addDays(50);
        testDataClass.testCollateralMonitoring.Due_Date__c = null;
        
        update testDataClass.testCollateralMonitoring;
        
        testDataClass.TestAgreement.Termination_Date__c = todaysDate.addYears(5) ;       
        update testDataClass.TestAgreement;
        
        Collateral_Monitoring_Helper.insertWatcherOccurence(collateralMonitoringList);
        
        test.stopTest();
    }

}