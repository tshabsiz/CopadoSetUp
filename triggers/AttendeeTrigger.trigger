trigger AttendeeTrigger on Attendee__c (before insert, after insert, before update, before delete, after delete,after update) {

	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
 		List<Attendee__c> attendees = [Select Id, Call_Report__r.Id, Barclays_Attendee__c, Attendee_Name__c FROM Attendee__c WHERE Id IN : Trigger.NewMap.keyset()];
    	System.debug('SYSTEM Debug');
        boolean isNew = false;
        if(Trigger.isInsert)
        {
           isNew = true;
        }
        AttendeeTrigger_Helper.shareCallReportWithAttendee(attendees,isNew,trigger.OldMap);
        
        if(Trigger.isInsert)
        {
            AttendeeTrigger_Helper.followCallReportByAttendee(Trigger.new);
            AttendeeTrigger_Helper.addPostToAttendee(Trigger.newMap.keySet());
        }
        
    }

    if(Trigger.isBefore && Trigger.isInsert)
    {
    	AttendeeTrigger_Helper.dontAllowDuplicateAttendees(trigger.new[0]);
    }

    if(Trigger.isBefore && Trigger.isDelete)
    {
    	AttendeeTrigger_Helper.deleteSharedCallReport(trigger.old[0]);
    }

    if(Trigger.isAfter && Trigger.isDelete)
    {
        AttendeeTrigger_Helper.stopFollowingCallReportByAttendee(Trigger.old);
    }
}