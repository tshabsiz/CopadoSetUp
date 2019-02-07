/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 13/11/2017 - PG    - Created Class. 
 14/11/2017 - PG 	- Added main method logic.
 15/11/2017 - PG 	- Added Attempt limit and SOQL limit.

**/
global class HotDocs_Request_Monitoring implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		try
		{
			//Instantiate API
	    	HotDocs_API api = new HotDocs_API();

			List<HotDocs_Request__c> requests = [
				SELECT
					Id,
					Status__c
				FROM HotDocs_Request__c
				WHERE
					Status__c != 'Completed' 
					AND Attempts__c < :api.SETTINGS.Attempts_Limit__c
				LIMIT 25
			];

			//Retry requests.
			for(HotDocs_Request__c request : requests)
			{
				System.enqueueJob(new HotDocs_Request_Queue(request.Id)); 
			}
		}
		catch(Exception e)
		{
			DebugLog.create( new DebugLog.Error(e, 'HotDocs_Request_Monitoring', 'execute') );   
		}
	}
}