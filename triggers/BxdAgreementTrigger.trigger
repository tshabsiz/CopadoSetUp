trigger BxdAgreementTrigger on Agreement__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdAgreementService.createBoxFolderTrigger(Trigger.new);
        }
        //INSERT context end.
    }
    //AFTER Context end.
}