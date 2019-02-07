trigger ClientPlanRelationshipTrigger on Client_Plan_Relationship__c (before delete) {
    
    //before delete
    if (Trigger.isBefore && Trigger.isDelete) {
        ClientPlanRelationshipTrigger_Helper.deleteRelationshipItems(Trigger.oldMap);
    }
    
}