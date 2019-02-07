/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Collateral_Valuation_Override_Test 
{
	public static testMethod void testClass()
	{
        Date todaysDate = System.today();

        //Test Data
		Cloudsmiths_TestDataClass testDataClass = new Cloudsmiths_TestDataClass(); 

		//VF page
        PageReference pageRef = Page.Collateral_Valuation_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.testCollateralValuation);
		Collateral_Valuation_Override ec = new Collateral_Valuation_Override(sc);
        
        test.startTest();

        Limits.getQueries(); 

		ec.participantsWrapper[0].selected = true;
		ec.distroGroupsWrapper[0].selected = true; 

		//Methods
        ec.saveRecord();
        ec.DealParticipants();
        
        testDataClass.testCollateralValuation.Due_Date__c = todaysDate.addDays(-60);
        
        ec.saveRecord();
        
        test.stopTest();

    }
}