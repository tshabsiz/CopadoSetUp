trigger InitiativeFollowerTrigger on Initiative_Follower__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareInitiativesWithFollowers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingInitiativesWithFollowers(Trigger.old);
	}
}