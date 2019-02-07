trigger InitiativeTeamMemberTrigger on Initiative_Team_Member__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareInitiativesWithTeamMembers(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingInitiativesWithTeamMembers(Trigger.old);
	}
}