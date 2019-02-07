/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 31/10/2017 - PG    - Created Class. 

**/ 
@IsTest
public class Drawdown_Route_Override_Test
{
	@IsTest
	static void testOverride()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

		Test.startTest();
		
		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestDrawdownNotInserted);
		Drawdown_Route_Override ec = new Drawdown_Route_Override(sc); 

		//Methods
		ec.actionRouteRecordType();

		Test.stopTest();
	}

	@IsTest
	static void testOverrideFromClone()
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();
		Map<String, Schema.RecordTypeInfo> recordTypes = Drawdown__c.sObjectType.getDescribe().getRecordTypeInfosByName();

		//Set to read only record type.
		testData.TestDrawdownNotInserted.RecordTypeId = recordTypes.get('Drawdown ReadOnly').getRecordTypeId();

		Test.startTest();
		
		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestDrawdownNotInserted);
		Drawdown_Route_Override ec = new Drawdown_Route_Override(sc); 

		//Methods
		ec.actionRouteRecordType();

		Test.stopTest();
	}
}