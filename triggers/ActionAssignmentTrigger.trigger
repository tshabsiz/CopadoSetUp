trigger ActionAssignmentTrigger on Action_Assignment__c (after insert, after delete) {
	
	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareActionsWithAssignedUsers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingActionsWithAssignedUsers(Trigger.old);
	}
}