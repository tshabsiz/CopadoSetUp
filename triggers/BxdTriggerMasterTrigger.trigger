trigger BxdTriggerMasterTrigger on Trigger__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdTriggerMasterService.createBoxFolderTrigger(Trigger.new);
        }
    }
}