trigger BxdConditionTrigger on Condition__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            for (Condition__c condition : Trigger.new) {
                //BxdConditionService.createFolderForRecord(condition.Id);
            }
        }
        //INSERT context end.
    }
    //AFTER Context end.
}