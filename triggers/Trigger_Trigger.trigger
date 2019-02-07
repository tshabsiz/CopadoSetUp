/**
*** CHANGE LOG ***

11/12/2017 - TdB   - Created Trigger.

**/ 
trigger Trigger_Trigger on Trigger__c (after update, before update, after Insert) 
{
	 if(trigger.isAfter && Trigger.isUpdate)
    { 
        //Call method to update all open watcher records linked to the Trigger modified
        Trigger_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
    }
    
    if(trigger.isBefore && Trigger.isUpdate)
    {
        //Call method to update all open watcher records linked to the Trigger modified
        Trigger_Helper.updateStartEndDates(Trigger.New);
    }
}