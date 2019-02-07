/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 29/09/2017 - PG    - Updated test class to use new controller logic. 
 02/11/2017 - PG 	- Updated class for main classes changes.
 01/11/2017 - PG 	- Moved testdata outside test start and stop.

**/ 
@isTest(SeeAllData=false)
private class Condition_Party_Override_Test 
{
	static testMethod void testStandardOverride()
	{
		//Insert Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//Set page.
		PageReference pageRef = Page.Condition_Party_Override;
		Test.setCurrentPage(pageRef);

		//Set page parameters.
		ApexPages.currentPage().getParameters().put('id',testData.testCondition.Id);

		//Controllers
		Condition_Party_Override controller = new Condition_Party_Override();

		//Run page action to initialise data
		controller.initialiseData();

		//Select a party
		controller.partyWrappers[0].selected = true;

		//Save data
		controller.saveRecord();

		//Call the above again to simulate exisitng agreement and parties.

		//Set page.
		PageReference pageRef2 = Page.Condition_Party_Override;
		Test.setCurrentPage(pageRef2);

		//Set page parameters.
		ApexPages.currentPage().getParameters().put('id',testData.testCondition.Id);

		//Controllers
		Condition_Party_Override controller2 = new Condition_Party_Override();

		//Run page action to initialise data
		controller2.initialiseData();

		//Select a party
		controller2.partyWrappers[0].selected = false;
		controller2.partyWrappers[1].selected = true;

		//Save data
		controller2.saveRecord();

		Test.stopTest();
	}
    
    static testMethod void testStandardOverride_GC()
	{
		//Insert Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();
        testData.TestAgreement.Limit__c = 100;
        testData.testConditionGC.Agreement__c = null;

        update testData.testConditionGC;

		Test.startTest();		

		//Set page.
		PageReference pageRef = Page.Condition_Party_Override;
		Test.setCurrentPage(pageRef);

		//Set page parameters.
		ApexPages.currentPage().getParameters().put('id',testData.testConditionGC.Id);

		//Controllers
		Condition_Party_Override controller = new Condition_Party_Override();

		//Run page action to initialise data
		try
        {
            controller.initialiseData();
        }catch(Exception error) 
        {
            //System.assert(error.getMessage().contains('Please ensure there is a &quot;Limit&quot; specified on the Agreement'));
		}
		

		
		Test.stopTest();
	}

	static testMethod void testGovernanceWithoutAgreementOverride()
	{
		//Insert Test Data
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();		

		//Set page.
		PageReference pageRef = Page.Condition_Party_Override;
		Test.setCurrentPage(pageRef);

		//Set page parameters.
		ApexPages.currentPage().getParameters().put('id',testData.testCondition.Id);

		//Controllers
		Condition_Party_Override extController = new Condition_Party_Override();

		//Run page action to initialise data
		extController.initialiseData();

		//Select a party
		extController.partyWrappers[0].selected = true;

		//Save data
		extController.saveRecord();

		Test.stopTest();
	}
}