trigger BxdLegalHoldTrigger on advpm__Matter_Legal_Hold_Acknowledgement__c (after insert, after update) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            for (advpm__Matter_Legal_Hold_Acknowledgement__c legalHoldAck : Trigger.new) {
                BxdMatterDealService.createLegalHoldPolicyAssignment(legalHoldAck.Id);
            }
        }
        //INSERT context end.
    }
    //AFTER Context end.    
}