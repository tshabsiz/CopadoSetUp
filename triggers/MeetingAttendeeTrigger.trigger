trigger MeetingAttendeeTrigger on Meeting_Attendee__c (after insert, after delete) {

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareMeetingsWithAttendees(Trigger.new);
		CollaborationSharingUtils.shareAgendasWithAttendees(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isDelete){
		CollaborationSharingUtils.stopSharingMeetingsWithAttendees(Trigger.old);
		CollaborationSharingUtils.stopSharingAgendasWithAttendees(Trigger.old);
	}
}