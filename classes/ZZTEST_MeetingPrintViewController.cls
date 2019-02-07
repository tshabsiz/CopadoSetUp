/**
* @Author   Dino Scarcella
* @Company: Absa Capital
* @Description Unit Tests for MeetingPrintViewController
*              Tests executed:
*               1 - testGeneratePDF()
*                   Test Generation of the PDF
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_MeetingPrintViewController {
	public static testMethod void testGeneratePDF() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;

        Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
        List<Meeting_Attendee__c> meetingAttendees = new List<Meeting_Attendee__c>();
        meetingAttendees.add(new Meeting_Attendee__c(Meeting__c=meeting.Id, Attendee__c=UserInfo.getUserId()));
        insert meetingAttendees;
        
        Document doc_done = new Document(Name='Icon Done', AuthorId = UserInfo.getUserId(), FolderId = UserInfo.getUserId());
        insert doc_done;
        Document doc_error = new Document(Name='Icon Error', AuthorId = UserInfo.getUserId(), FolderId = UserInfo.getUserId());
        insert doc_error;
        Document doc_warning = new Document(Name='Icon Warning', AuthorId = UserInfo.getUserId(), FolderId = UserInfo.getUserId());
        insert doc_warning;
        
        //Start Test
        Test.startTest();

    	PageReference MeetingPrintView = Page.MeetingPrintView;
        Test.setCurrentPage(MeetingPrintView);

        ApexPages.currentPage().getParameters().put('id', meeting.Id);
        Apexpages.Standardcontroller stc = new ApexPages.StandardController(meeting);
        MeetingPrintViewController controller = new MeetingPrintViewController(stc);
        
        System.assert(controller.Meeting != NULL);
        
        //Stop Test
        Test.stopTest();
    }
}