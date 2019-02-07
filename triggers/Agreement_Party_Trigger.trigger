/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 18/06/2017 - PG    - Created Trigger. 

**/   
trigger Agreement_Party_Trigger on Agreement_Party__c (before insert, before update) 
{
	//Before Insert
	if(Trigger.isBefore && Trigger.isInsert)
	{
		Agreement_Party_Helper.beforeInsert(Trigger.new);
	}
	//Before Insert End.

	//After Update
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		Agreement_Party_Helper.beforeUpdate(Trigger.new, Trigger.oldMap);
	}
	//After Update End. 
}