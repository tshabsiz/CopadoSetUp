trigger CommitteeFollowerTrigger on Committee_Follower__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareCommitteesWithFollowers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingCommitteesWithFollowers(Trigger.old);
	}
}