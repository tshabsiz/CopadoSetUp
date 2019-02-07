/**                                           
*** CHANGE LOG ***

16/11/2017 - TdB    - Created Trigger.

**/ 

trigger Margin_Ratchet_Trigger on Margin_Ratchet__c(after update, before update) 
{
    if(trigger.isAfter && Trigger.isUpdate)
    { 
        //Call method to update all open watcher records linked to the Margin Ratchet modified
        Margin_Ratchet_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
    }
    
    if(trigger.isBefore && Trigger.isUpdate)
    {
        //Call method to update Scheduled Start and End Date on Margin Ratchet
        Margin_Ratchet_Helper.updateStartEndDates(Trigger.New);
    }
}