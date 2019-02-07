trigger ActionTrigger on Action__c (before insert, after insert, before update, after update) {

	if(Trigger.isBefore && Trigger.isInsert){
		ActionTrigger_Helper.copyActionOwner(Trigger.new);
		ActionTrigger_Helper.updateFieldsBeforeInsert(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isInsert){
		ActionTrigger_Helper.assignActionToOwner(Trigger.new);
		ActionTrigger_Helper.followActionByCreator(Trigger.new);
	}

	if(Trigger.isBefore && Trigger.isUpdate){
		ActionTrigger_Helper.copyActionOwner(Trigger.new);
		ActionTrigger_Helper.updateFieldsBeforeUpdate(Trigger.oldMap, Trigger.newMap);
	}

	if(Trigger.isAfter && Trigger.isUpdate){
		ActionTrigger_Helper.followActionByCreator(Trigger.oldMap, Trigger.newMap);
	}
}