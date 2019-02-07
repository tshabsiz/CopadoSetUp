@isTest
public class evScheduleExtension_Controller_Test {
    
    public static testMethod void testClass()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        TestData.TestSessionBooking.isSpeaker__c = true;
        
        ApexPages.StandardController sc = new ApexPages.standardController(TestData.TestEvent);
		evScheduleExtension_Controller con = new evScheduleExtension_Controller(sc);
        
        con.delAgendaItem = TestData.TestSession.Id;
        con.addWalkIn();
        
        String TestSessionBookingString = String.valueOf(TestData.TestSessionBooking.Id);
        evScheduleExtension_Controller.updateAttendance(TestSessionBookingString, 'Attended');
    }

}