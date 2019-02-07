/**
*** CHANGE LOG ***

27/11/2017 - TdB    - Created Trigger.
01/08/2018 - TdB    - Merge Collateral_Monitoring_Trigger and BxdCollateralMonitoringTrigger

**/ 

trigger Collateral_Monitoring_Trigger on Collateral_Monitoring__c (after update, before update, after Insert) 
{
    if(trigger.isAfter)
    { 
        if(Trigger.isUpdate)
        {
            //Call method to update all open watcher records linked
            Collateral_Monitoring_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
        }
        if(Trigger.isInsert)
        {
            BxdCollateralMonitoringService.createBoxFolderTrigger(Trigger.new);
        }
        
    }
    
    if(trigger.isBefore && Trigger.isUpdate)
    {
         //Call method to update Scheduled Start and End Date
        Collateral_Monitoring_Helper.updateStartEndDates(Trigger.New);
    }
}