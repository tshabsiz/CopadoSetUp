/**
* @author Deloitte 
* @date 2015
*
* @group Utilities
*
* @description Helper class for sending emails
*/
global class EmailServices {
	/**
    * @description Sends email to given call report attendees
    * @param Id callReportId
    */
	Webservice static void sendEmailToCallReportAttendees(Id callReportId) {
		//Select Call Report with Attendees
		Call_Report__c callReport = [SELECT Id, Name, OwnerId, (SELECT Id, Name, Attendee_Email__c FROM Attendees__r) 
									FROM Call_Report__c WHERE Id = :callReportId];
		List<String> attendeeEmails = new List<String>();
		for(Attendee__c att : callReport.Attendees__r){
			attendeeEmails.add(att.Attendee_Email__c);
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(attendeeEmails);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}