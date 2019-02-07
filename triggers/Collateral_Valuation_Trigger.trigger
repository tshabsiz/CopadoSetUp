/**
*** CHANGE LOG ***

20/11/2017 - TdB   - Created Trigger.

**/ 
trigger Collateral_Valuation_Trigger on Collateral_Valuation__c (after update, before update, after Insert) {
    
    if(trigger.isAfter && Trigger.isUpdate)
    { 
        //Call method to update all open watcher records linked to the Collateral Valuation modified
        Collateral_Valuation_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
    }
    
    if(trigger.isBefore && Trigger.isUpdate)
    {
        //Call method to update all open watcher records linked to the Collateral Valuation modified
        Collateral_Valuation_Helper.updateStartEndDates(Trigger.New);
    }
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
    {
        
    }
}