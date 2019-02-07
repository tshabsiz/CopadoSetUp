/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_InviteParticipantsController
*              Tests executed:
*               1 - testInvateParticipants()
*                   Test that JLOC Attendees can be added to JLOC related list.
*               2 - testInvateDealTeamMembers()
*                   Test that Deal Team Members can be added to JLOC related list.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska   Add testing for inviting Deal Team Members
* 22/09/2016  Mohsin Wadee		 On line 25 checked for existing Collaboration Group to avoid conflict with actual one in PRD.
* -----------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true)
private class ZZTEST_JLOC_InviteParticipantsController {

	public static testMethod void testInvateParticipants(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
        //Create chatter group
        CollaborationGroup cg = null;
        List<CollaborationGroup> collabGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'JLOC Coverage' LIMIT 1];
        IF (collabGroup.size() > 0) {
            cg = collabGroup.get(0);
        }
        ELSE
        {
            cg = new CollaborationGroup(Name='JLOC Coverage', CollaborationType='Public');
            INSERT cg;
        }

        Test.startTest();

		PageReference JLOC_InviteParticipants = Page.JLOC_InviteParticipants;
        Test.setCurrentPage(JLOC_InviteParticipants);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_InviteParticipantsController controller = new JLOC_InviteParticipantsController(stc);


        for(JLOC_InviteParticipantsController.ChatterGroupWrapper chatterGroupWrapper : controller.chatterGroups) {
        	chatterGroupWrapper.isSelected = true;
        }
        controller.next();

        //Add JLOC Other Attendees
        controller.addOtherAttendee();
        controller.addOtherAttendee();

        for(JLOC_InviteParticipantsController.OtherAttendeeWrapper otherAttendeeWrapper : controller.otherJlocAttendees) {
        	otherAttendeeWrapper.otherJlocAttendee.User__c = UserInfo.getUserId();
        }

        controller.otherJlocAttendeeToDel = 0;
        controller.removeOtherAttendee();

        controller.save();

        Test.stopTest();

        List<JLOC_Attendee__c> jlocAttendees = [SELECT Id, Name FROM JLOC_Attendee__c WHERE JLOC__c = :jloc.Id];
        System.assert(jlocAttendees.size() >= 1);
	}

    public static testMethod void testInvateDealTeamMembers() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        //Give this user JLOC permissions
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
        INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        System.runAs(u) {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
            ZZTEST_F_Opportunity oppFactory = ZZTEST_DataFactoryFacade.opportunity;

            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            Opportunity opp = oppFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);

            opp.JLOC__c = jloc.Id;
            UPDATE opp;

            Test.startTest();

            PageReference JLOC_InviteParticipants = Page.JLOC_InviteParticipants;
            Test.setCurrentPage(JLOC_InviteParticipants);

            ApexPages.currentPage().getParameters().put('id', jloc.Id);
            Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
            JLOC_InviteParticipantsController controller = new JLOC_InviteParticipantsController(stc);

            for(JLOC_InviteParticipantsController.ChatterGroupWrapper chatterGroupWrapper : controller.chatterGroups) {
                chatterGroupWrapper.isSelected = true;
            }
            controller.next();

            for(JLOC_InviteParticipantsController.DealTeamMemberWrapper dealTeamMemberWrapper : controller.dealTeamMembers) {
                dealTeamMemberWrapper.isSelected = true;
            }

            controller.save();

            Test.stopTest();

            List<JLOC_Attendee__c> jlocAttendees = [SELECT Id, Name FROM JLOC_Attendee__c WHERE JLOC__c = :jloc.Id];
            System.assert(jlocAttendees.size() >= 1);
        }
    }
}