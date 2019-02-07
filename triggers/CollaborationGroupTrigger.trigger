trigger CollaborationGroupTrigger on CollaborationGroup (before insert, before update) {
    // before insert
    if(trigger.isBefore && trigger.isInsert){
        CollaborationGroupTrigger_Helper.checkIfUserCanCreateCustomerGroup(Trigger.new, null);
    }
    if(trigger.isBefore && trigger.isUpdate){
        CollaborationGroupTrigger_Helper.checkIfUserCanCreateCustomerGroup(Trigger.new, Trigger.oldMap);
    }
}