/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 10/11/2017 - PG    - Created Class. 

**/ 
trigger HotDocs_Request_Trigger on HotDocs_Request__c (after insert) 
{
	if(Trigger.isAfter && Trigger.isInsert)
	{
		for(HotDocs_Request__c request : Trigger.new) 
		{
			if(!Test.isRunningTest())
			{
				//Enqueue job.
				String jobId = System.enqueueJob(new HotDocs_Request_Queue(request.Id)); 
			}
		}
	}
}