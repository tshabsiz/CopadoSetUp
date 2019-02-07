trigger BxdCollateralMonitoringTrigger on Collateral_Monitoring__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdCollateralMonitoringService.createBoxFolderTrigger(Trigger.new);
        }
    }
}