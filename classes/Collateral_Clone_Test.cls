/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***
17/07/2017 - PG    	- Created Class.
31/10/2017 - PG 	- Added second method to test collateral with ACM facilities.

**/ 

@isTest
public class Collateral_Clone_Test 
{	
	public static testMethod void Collateral_Clone_Test()
	{
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		Test.startTest();

		Limits.getQueries(); 

		ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestCollateral);
		Collateral_Clone ec = new Collateral_Clone(sc);

		//Main method.
		ec.cloneCollateral(); 

		Test.stopTest();
	}

	public static testMethod void Collateral_Clone_Test_Facility()
	{
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		Test.startTest();

		Limits.getQueries(); 

		ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestCollateral2);
		Collateral_Clone ec = new Collateral_Clone(sc); 

		//Main method.
		ec.cloneCollateral(); 

		Test.stopTest(); 
	}
}