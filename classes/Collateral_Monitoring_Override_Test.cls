/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Collateral_Monitoring_Override_Test 
{
	public static testMethod void testClass()
	{
        Date todaysDate = System.today();
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		//VF page
        PageReference pageRef = Page.Collateral_Monitoring_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.testCollateralMonitoring);
		Collateral_Monitoring_Override ec = new Collateral_Monitoring_Override(sc);
        
        test.startTest();

        Limits.getQueries(); 

		ec.participantsWrapper[0].selected = true;
		ec.distroGroupsWrapper[0].selected = true; 

		//Methods
        ec.saveRecord();
        ec.DealParticipants();
        
        testDataClass.testCollateralMonitoring.Due_Date__c = todaysDate.addDays(-60);
        testDataClass.testCollateralMonitoring.Frequency__c = 'Once Off';
        
        ec.saveRecord();
        
        test.stopTest();
    }
}