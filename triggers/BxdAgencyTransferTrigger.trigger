trigger BxdAgencyTransferTrigger on Agency_Transfer__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdAgencyTransferService.createBoxFolderTrigger(Trigger.new);
        }
    }
}