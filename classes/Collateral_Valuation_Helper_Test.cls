/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Collateral_Valuation_Helper_Test 
{
    public static testMethod void testClass()
	{
        Date todaysDate = System.today();
        List<Collateral_Valuation__c> collateralValuationList = new List<Collateral_Valuation__c>();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        collateralValuationList.add(testDataClass.testCollateralValuation);
        
        test.startTest();

        Limits.getQueries(); 
        
        testDataClass.testCollateralValuation.Frequency__c = 'Once Off';
        testDataClass.testCollateralValuation.Due_Date__c = todaysDate.addDays(100);
        
        update testDataClass.testCollateralValuation;
        
        testDataClass.testCollateralValuation.Frequency__c = 'Monthly';
        testDataClass.testCollateralValuation.Relative_Date__c = 'Other';
        testDataClass.testCollateralValuation.Number_Of_Days__c = 5;
        testDataClass.testCollateralValuation.Days__c = 'Days After';
        testDataClass.testCollateralValuation.Other_Relative_Date__c = todaysDate.addDays(50);
        testDataClass.testCollateralValuation.Due_Date__c = null;
        
        update testDataClass.testCollateralValuation;
        
        testDataClass.TestAgreement.Termination_Date__c = todaysDate.addYears(5) ;       
        update testDataClass.TestAgreement;
        
        Collateral_Valuation_Helper.insertWatcherOccurence(collateralValuationList);
        
        test.stopTest();
    }

}