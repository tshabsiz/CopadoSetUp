trigger BxdFacilityTrancheTrigger on Facility_Tranche__c (after insert) {
        //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdFacilityTrancheService.createBoxFolderTrigger(Trigger.new);
        }
    }
}