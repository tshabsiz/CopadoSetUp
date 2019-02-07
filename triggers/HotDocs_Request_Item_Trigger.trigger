/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 23/11/2017 - PG 	- Created Trigger.
 17/01/2018 - PG 	- Added After Insert context.

**/
trigger HotDocs_Request_Item_Trigger on HotDocs_Request_Item__c (after insert, after update)  
{ 
	if(Trigger.isAfter && Trigger.isInsert)
	{
		HotDocs_Helper.afterInsert_RequestItem(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isUpdate)
	{
		HotDocs_Helper.checkRequestStatus(Trigger.new, Trigger.oldMap); 
	}
}