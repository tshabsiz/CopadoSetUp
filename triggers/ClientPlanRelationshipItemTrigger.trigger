trigger ClientPlanRelationshipItemTrigger on Client_Plan_Relationship_Item__c (before insert, before update) {

    //before insert
    if (Trigger.isBefore && Trigger.isInsert) {
        ClientPlanRelationshipItemTrigger_Helper.checkPrimaryUniqueness(Trigger.new);
    }
    
    //before update
    if (Trigger.isBefore && Trigger.isUpdate) {
        ClientPlanRelationshipItemTrigger_Helper.checkPrimaryUniqueness(Trigger.new);
    }

}