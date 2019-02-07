/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 13/09/2017 - DF    - Created class.
 27/10/2017 - PG 	- Updated logic as class was empty :)

**/ 
@isTest
public class Deal_Party_Helper_Test 
{
	@isTest
	private static void testDealParties()
	{
		//Original / clean data per test method will be generated.
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//Activate FC
		testData.testConditionFC.Active__c = true; 
		update testData.testConditionFC; 

		//Update conditions monitored by.
		testData.TestDealParty.Conditions_Monitored_By__c = testData.TestParticipant5.Id;
		update testData.TestDealParty;  

		Test.stopTest(); 
	} 
    
    public static testMethod void testDelete()
    {
        Libra_TestDataClass testData = new Libra_TestDataClass();
        
        testData.testDealParty.hAuto_Created__c = True;
        Update testData.testDealParty;
        
        Test.startTest();
        
        Try
        {
          Delete testData.testDealParty;
        }
        Catch (Exception e)
        {
            
        }
        
        Test.stopTest();
    }
}