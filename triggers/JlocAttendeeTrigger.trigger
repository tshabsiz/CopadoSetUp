trigger JlocAttendeeTrigger on JLOC_Attendee__c (after insert, after update, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		JlocAttendeeTriggerHelper.shareJlocWithCommitteeAttendees(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isUpdate){
		JlocAttendeeTriggerHelper.checkJlocApprovalStatus(Trigger.newMap, Trigger.oldMap);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		JlocAttendeeTriggerHelper.stopSharingJlocWithCommitteeAttendees(Trigger.old);
	}
}