/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_CheckPresenceController
*              Tests executed:
*               1 - testCheckPresence()
*                   Test that JLOC Attendees Present field is updated.
*               2 - testCheckPresenceDmlExeption()
*                   Test that DML Exceptions are displayed.
*/
@isTest
private class ZZTEST_JLOC_CheckPresenceController {

	public static testMethod void testCheckPresence(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        List<JLOC_Attendee__c> jlocAttendees = new List<JLOC_Attendee__c>();
        jlocAttendees.add(new JLOC_Attendee__c(JLOC__c = jloc.Id, Group__c = 'Other', User__c = UserInfo.getUserId()));
        insert jlocAttendees;
        
        Test.startTest();

		PageReference JLOC_CheckPresence = Page.JLOC_CheckPresence;
        Test.setCurrentPage(JLOC_CheckPresence);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_CheckPresenceController controller = new JLOC_CheckPresenceController(stc);

        for(JLOC_Attendee__c attendee : controller.jlocAttendees){
        	attendee.Present__c = true;
        }

        controller.save();

        for(JLOC_Attendee__c jlocAttendee : [SELECT Id, Present__c FROM JLOC_Attendee__c WHERE JLOC__c = :jloc.Id]){
            System.assertEquals(jlocAttendee.Present__c, true);
        }

        Test.stopTest();
	}

	public static testMethod void testCheckPresenceDmlExeption(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);

        List<JLOC_Attendee__c> jlocAttendees = new List<JLOC_Attendee__c>();
        jlocAttendees.add(new JLOC_Attendee__c(JLOC__c = jloc.Id, Group__c = 'Other', User__c = UserInfo.getUserId()));
        insert jlocAttendees;
        
        Test.startTest();

		PageReference JLOC_CheckPresence = Page.JLOC_CheckPresence;
        Test.setCurrentPage(JLOC_CheckPresence);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_CheckPresenceController controller = new JLOC_CheckPresenceController(stc);

        for(JLOC_Attendee__c attendee : controller.jlocAttendees){
        	attendee.Present__c = null;
        }

        controller.save();

        System.assertEquals(ApexPages.getMessages().size(), controller.jlocAttendees.size());

        Test.stopTest();
	}
}