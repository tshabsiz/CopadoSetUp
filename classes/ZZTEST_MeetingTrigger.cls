/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for MeetingTrigger
*/
@isTest
private class ZZTEST_MeetingTrigger {
	public static testMethod void testCopyDataFromCommittee(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1=[Select Id from user where ID=:userInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Committee committeeFactory = ZZTEST_DataFactoryFacade.committee;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		//Create Committee
		Committee__c committee = committeeFactory.getInsertedProduct(ZZTEST_F_Committee.CommitteeRecordType.DEFAULT_COMMITTEE, dataContainer);

		//Create Standing Agenda
		List<Standing_Agenda__c> standingAgendas = new List<Standing_Agenda__c>();
		standingAgendas.add(new Standing_Agenda__c(Name='Section1', Order__c = 1, Committee__c=committee.Id));
		standingAgendas.add(new Standing_Agenda__c(Name='Section2', Order__c = 2, Committee__c=committee.Id));
		insert standingAgendas;

		User barclaysStdUser = userFactory.getBarclaysStandardUser();

		//Add Members
		List<Committee_Member__c> committeeMembers = new List<Committee_Member__c>();
        committeeMembers.add(new Committee_Member__c(Committee__c=committee.Id, Committee_Member__c=barclaysStdUser.Id));
        committeeMembers.add(new Committee_Member__c(Committee__c=committee.Id, Committee_Member__c=UserInfo.getUserId()));
        insert committeeMembers;
		//Add Followers
		List<Committee_Follower__c> committeeFollowers = new List<Committee_Follower__c>();
		committeeFollowers.add(new Committee_Follower__c(Committee__c=committee.Id, Follower__c=barclaysStdUser.Id));
        committeeFollowers.add(new Committee_Follower__c(Committee__c=committee.Id, Follower__c=UserInfo.getUserId()));
        insert committeeFollowers;

        Test.startTest();

        Meeting__c meeting = meetingFactory.getProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
        meeting.Committee__c = committee.Id;
        insert meeting;

        List<Meeting_Attendee__c> meetingAttendees = [SELECT Id FROM Meeting_Attendee__c WHERE Meeting__c = :meeting.Id];
        List<Meeting_Follower__c> meetingFollowers = [SELECT Id FROM Meeting_Follower__c WHERE Meeting__c = :meeting.Id];
        List<Agenda__c> meetingAgendas = [SELECT Id FROM Agenda__c WHERE Meeting__c = :meeting.Id];
        System.assertEquals(meetingAttendees.size(), 2);
        System.assertEquals(meetingFollowers.size(), 2);
        System.assertEquals(meetingAgendas.size(), 2);

		Test.stopTest();
        }
		
	}
}