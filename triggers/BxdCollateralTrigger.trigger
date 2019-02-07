trigger BxdCollateralTrigger on Collateral__c (after insert) {
    if(Trigger.isAfter)
    {       
        if(Trigger.isInsert)
        {
            BxdCollateralService.createBoxFolderTrigger(Trigger.new);
        }
    }
}