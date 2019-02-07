/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for ZZTEST_MeetingAttendeesPresence_Controller
*/
@isTest
public class ZZTEST_MeetingAttendeesPresence_Ctr {
	public static testMethod void testUpdatePresence()
	{
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;

        Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
        List<Meeting_Attendee__c> meetingAttendees = new List<Meeting_Attendee__c>();
        meetingAttendees.add(new Meeting_Attendee__c(Meeting__c=meeting.Id, Attendee__c=UserInfo.getUserId()));
        insert meetingAttendees;

        Test.startTest();

		PageReference MeetingAttendeesPresence = Page.MeetingAttendeesPresence;
        Test.setCurrentPage(MeetingAttendeesPresence);

    	ApexPages.currentPage().getParameters().put('id', meeting.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(meeting);
        MeetingAttendeesPresence_Controller controller = new MeetingAttendeesPresence_Controller(stc);	

		// Mark Attendees as Present 
		for(Meeting_Attendee__c att : controller.attendees){
			att.Present__c = true;
		}
		controller.save();

		List<Meeting_Attendee__c> presentMeetingAttendees = [SELECT Id FROM Meeting_Attendee__c WHERE Meeting__c = :meeting.Id AND Present__c = true];
		System.assertEquals(presentMeetingAttendees.size(), meetingAttendees.size());
		
        Test.stopTest();
	}

	public static testMethod void testEmptyAttendeeList()
	{
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;

        Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
        List<Meeting_Attendee__c> meetingAttendees = new List<Meeting_Attendee__c>();

        Test.startTest();

		PageReference MeetingAttendeesPresence = Page.MeetingAttendeesPresence;
        Test.setCurrentPage(MeetingAttendeesPresence);

    	ApexPages.currentPage().getParameters().put('id', meeting.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(meeting);
        MeetingAttendeesPresence_Controller controller = new MeetingAttendeesPresence_Controller(stc);	

		System.assertEquals(ApexPages.getMessages()[0].getSeverity(), ApexPages.Severity.Info);
		
        Test.stopTest();
	}
}