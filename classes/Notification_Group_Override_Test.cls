/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 14/01/2017 - PG    - Created Class. 

**/
@IsTest
public class Notification_Group_Override_Test 
{
	@IsTest
	public static void testOverrideDrawdown() 
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

		Test.startTest();
		
		PageReference pageRef = Page.Notification_Group_Override;
		Test.setCurrentPage(pageRef);

		//Add param
		pageRef.getParameters().put('parentId', testData.TestDrawdown.Id);

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestNotificationGroup_F2L_Public);
		Notification_Group_Override ec = new Notification_Group_Override(sc); 

		Test.stopTest();
	}

	@IsTest
	public static void testOverrideFitToLend() 
	{
		CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

		Test.startTest();
		
		PageReference pageRef = Page.Notification_Participant_Override;
		Test.setCurrentPage(pageRef);

		//Add param
		pageRef.getParameters().put('parentId', testData.TestFitToLend.Id);

		//Controller + Extension
		ApexPages.StandardController sc = new ApexPages.standardController(testData.TestNotificationGroup_F2L_Public);
		Notification_Group_Override ec = new Notification_Group_Override(sc); 

		Test.stopTest();
	}
}