trigger BxdMatterDealTrigger on advpm__Matter__c (after insert, after update) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdMatterService.createBoxFolderTrigger(Trigger.new);
        }
        //INSERT context end.
        //UPDATE context
        if(Trigger.isUpdate)
        {
            for (advpm__Matter__c matter : Trigger.new) {
                if(matter != null && !matter.advpm__Legal_Hold__c && !String.isBlank(matter.Box_Legal_Hold_Assignment_Id__c)){
                    String matterId = matter.Id;
                    String boxAssignmentId = matter.Box_Legal_Hold_Assignment_Id__c;
                    List<advpm__Matter_Legal_Hold_Acknowledgement__c> legalHolds = [SELECT Id, advpm__Matter__c, Box_Assignment_Id__c FROM advpm__Matter_Legal_Hold_Acknowledgement__c WHERE advpm__Matter__c=:matterId AND Box_Assignment_Id__c=:boxAssignmentId];
                    if(!legalHolds.isEmpty() && !String.isBlank(legalHolds[0].Box_Assignment_Id__c)){
                        advpm__Matter_Legal_Hold_Acknowledgement__c legalHold = legalHolds[0];
                        BxdMatterDealService.removeLegalHoldPolicyAssignment(matter.Id);
                        legalHold.Box_Assignment_Id__c = null;
                        update legalHold;
                    }  
                }
                
            }
        }
        //UPDATE context end.
    }
    //AFTER Context end.
}