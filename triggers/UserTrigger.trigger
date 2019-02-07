trigger UserTrigger on User (before insert, after insert, before update, after update) {
    // before insert
    if(trigger.isBefore && trigger.isInsert){

    }

    // after insert
    if(trigger.isAfter && trigger.isInsert){

    }

    // after update
    if(trigger.isAfter && trigger.isUpdate){
		UserTrigger_Helper.updateOpportunityAndCallReportRelationshipOwnerRole(Trigger.new, Trigger.oldMap);
    }

    // before update
    if(trigger.isBefore && trigger.isUpdate){
		
    }
}