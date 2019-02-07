trigger MeetingTrigger on Meeting__c (after insert) {

	if(Trigger.isAfter && Trigger.isInsert){
		MeetingTrigger_Helper.copyDefaultDataFromCommittee(Trigger.new);
	}
}