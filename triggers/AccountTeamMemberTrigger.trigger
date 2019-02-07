trigger AccountTeamMemberTrigger on Account_Team_Member__c (before insert, after insert, after update, after delete) {
	//before insert
	if(Trigger.isBefore && Trigger.isInsert){
		AccountTeamMemberTrigger_Helper.checkForDuplicates(Trigger.new);
	}
	//after insert
	if(Trigger.isAfter && Trigger.isInsert){
		AccountTeamMemberTrigger_Helper.createAccountTeamMembers(Trigger.new);
		AccountTeamMemberTrigger_Helper.followAccountByTeamMember(Trigger.new);
		AccountTeamMemberTrigger_Helper.addPostToAttendee(Trigger.newMap.keySet());
		AccountTeamMemberTrigger_Helper.shareClientPlans(Trigger.new);
        AccountTeamMemberTrigger_Helper.shareAnnualPricing(Trigger.new);
	}
	//after update
	if(Trigger.isAfter && Trigger.isUpdate){
		AccountTeamMemberTrigger_Helper.updateAccountTeamMembers(Trigger.oldMap, Trigger.newMap);
	}
	//after delete
	if(Trigger.isAfter && Trigger.isDelete){
		AccountTeamMemberTrigger_Helper.deleteAccountTeamMembers(Trigger.old);
		AccountTeamMemberTrigger_Helper.stopFollowingCallReportByAttendee(Trigger.old);
		AccountTeamMemberTrigger_Helper.unshareClientPlans(Trigger.old);
	}

}