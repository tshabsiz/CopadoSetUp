trigger BxdFacilityTrigger on Facility__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdFacilityService.createBoxFolderTrigger(Trigger.new);
        }
    }
}