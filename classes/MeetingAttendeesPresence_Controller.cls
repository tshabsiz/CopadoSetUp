public with sharing class MeetingAttendeesPresence_Controller {
	private Id meetingId;
	private Meeting__c meeting;
	public List<Meeting_Attendee__c> attendees { get; set; }
	public Boolean isAttendeesNotEmpty { get; set; }

	public MeetingAttendeesPresence_Controller(ApexPages.StandardController stdController) {
		meetingId = ApexPages.currentPage().getParameters().get('id');
		meeting = (Meeting__c) stdController.getRecord(); 

		if (String.isNotBlank(meetingId)) {
            attendees = [SELECT Id, Attendee__c, Present__c FROM Meeting_Attendee__c WHERE Meeting__c = :meetingId];
        } else {
        	attendees = new List<Meeting_Attendee__c>();
        }

        if(attendees.isEmpty()){
        	isAttendeesNotEmpty = false;
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There is no attendee related to this meeting.'));
        } else{
        	isAttendeesNotEmpty = true;
        }
	}

	public PageReference save() {
		update attendees;
		return new ApexPages.StandardController(meeting).view();
	}
}