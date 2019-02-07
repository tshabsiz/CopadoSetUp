trigger JlocTrigger on JLOC__c (after update) {
    // After Update
    if(Trigger.isAfter && Trigger.isUpdate){
        JlocTrigger_Helper.executeAfterUpdateActions(Trigger.newMap, Trigger.oldMap);
    }
}