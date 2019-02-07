trigger BxdMarginRatchetTrigger on Margin_Ratchet__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdMarginRatchetService.createBoxFolderTrigger(Trigger.new);
        }
    }
}