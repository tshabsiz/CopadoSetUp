trigger CallReportTrigger on Call_Report__c (after insert, after update) {
	//after insert
    if(trigger.isAfter && trigger.isInsert){
    	CallReportTrigger_Helper.craeteBarclaysAttendee(trigger.new);
    	//SF2SFConnectionHandler.newCallReportShare(trigger.new);
    }
}