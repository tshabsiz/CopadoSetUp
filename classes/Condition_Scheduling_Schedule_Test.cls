/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 26/09/2017 - PG    - Created class.

**/ 
@isTest
private class Condition_Scheduling_Schedule_Test 
{	
	@isTest static void testSchedule() 
	{
		//Start test.
		Test.StartTest();

		//Test Data Class
		Cloudsmiths_TestDataClass testData =  new Cloudsmiths_TestDataClass();

		//Activate a condition
		testData.testConditionFC.Active__c = true;
		update testData.testConditionFC;

		//Load Schedule + Class
		Condition_Scheduling_Schedule scheduledClass = new Condition_Scheduling_Schedule();  
		String cronSchedule = '0 0 23 * * ?';
		String jobId = System.schedule('Test Schedule', cronSchedule, scheduledClass);
		
		//Execute
		scheduledClass.execute(null);

		//Stop test.
		Test.StopTest(); 
	}	
}