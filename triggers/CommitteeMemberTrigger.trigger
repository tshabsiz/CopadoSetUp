trigger CommitteeMemberTrigger on Committee_Member__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareCommitteesWithMembers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingCommitteesWithMembers(Trigger.old);
	}
}