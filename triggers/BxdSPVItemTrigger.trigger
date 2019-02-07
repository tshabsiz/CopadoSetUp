trigger BxdSPVItemTrigger on SPV_Items__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdSPVItemService.createBoxFolderTrigger(Trigger.new);
        }
    }
}