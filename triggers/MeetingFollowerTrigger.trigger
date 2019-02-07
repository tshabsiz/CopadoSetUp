trigger MeetingFollowerTrigger on Meeting_Follower__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareMeetingsWithFollowers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingMeetingsWithFollowers(Trigger.old);
	}
}