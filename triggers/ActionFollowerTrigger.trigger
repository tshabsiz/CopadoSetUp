trigger ActionFollowerTrigger on Action_Follower__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareActionsWithFollowers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingActionsWithFollowers(Trigger.old);
	}
}