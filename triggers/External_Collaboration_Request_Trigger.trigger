/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 22/03/2018 - PG    - Created initial trigger.
 
**/ 
trigger External_Collaboration_Request_Trigger on External_Collaboration_Request__c (after update) 
{
	//After Update Context
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		//Call helper.
		External_Collaboration_Request_Helper.afterUpdate(Trigger.new, Trigger.oldMap); 
	}
}