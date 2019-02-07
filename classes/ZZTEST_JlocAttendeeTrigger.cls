/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JlocAttendeeTriggerHelper
*              Tests executed:
*               1 - testShareJlocWithAttendees()
*                   Test that JLOC is shared with JLOC Attendees.
*               2 - testJlocApprovalStatus()
*                   Test that JLOC Status is changed after all attendees vote.
*/
@isTest
private class ZZTEST_JlocAttendeeTrigger {
        public static testMethod void testShareJlocWithAttendees() {
                //First create a User
                ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
                User u1 = userFactory.getBarclaysStandardUser();
                User u2 = userFactory.getExistingUserByProfile('Barclays Administrator');

                //Give these users JLOC permissions
                PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
                try {
                        INSERT new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
                } catch(Exception e) {}
                try {
                        INSERT new PermissionSetAssignment(AssigneeId = u2.id, PermissionSetId = ps.Id);
                } catch(Exception e) {}

                System.runAs(u1) {
        		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        		Integer batchSize = 200;
        		List<JLOC__c> jlocs = new List<JLOC__c>();
        		for(Integer i=0; i<=batchSize; i++) {
        			jlocs.add(jlocFactory.getProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer));
        		}

        		Database.DMLOptions dml = new Database.DMLOptions(); 
                        dml.DuplicateRuleHeader.AllowSave = true;

                        Test.startTest();

                        List<Database.SaveResult> srList = Database.INSERT(jlocs, dml);
                        Set<Id> jlocIds = new Set<Id>();
                        for(Database.SaveResult sr : srList) {
                	       if(sr.isSuccess()) {
                		      jlocIds.add(sr.getId());
                	       }
                        }

        		//Add Attendees
        		List<JLOC_Attendee__c> attendeesToIns = new List<JLOC_Attendee__c>();
                        for(JLOC__c jloc : jlocs) {
                	       attendeesToIns.add(new JLOC_Attendee__c(JLOC__c=jloc.Id,User__c=u2.Id,Group__c='Other'));
                        }
                        INSERT attendeesToIns;

                        List<JLOC__Share> attendeesSharingsAfterIns = [SELECT Id FROM JLOC__Share WHERE UserOrGroupId = :u2.Id AND ParentId IN :jlocIds];
                        System.assertEquals(attendeesSharingsAfterIns.size(), batchSize+1);

                        DELETE [SELECT Id FROM JLOC_Attendee__c WHERE JLOC__c IN :jlocIds];

                        List<JLOC__Share> attendeesSharingsAfterDel = [SELECT Id FROM JLOC__Share WHERE UserOrGroupId = :u2.Id AND ParentId IN :jlocIds];
                        System.assertEquals(attendeesSharingsAfterDel.size(), 0);

        		Test.stopTest();
                }
	}

	public static testMethod void testJlocApprovalStatus() {
                //First create a User
                ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
                User u = userFactory.getBarclaysStandardUser();

                //Give this user JLOC permissions
                PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'JLOC'];
                INSERT new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

                System.runAs(u) {
        		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        		User attendee = userFactory.getBarclaysStandardUser();

        		Integer batchSize = 20;
        		List<JLOC__c> jlocs = new List<JLOC__c>();
        		for(Integer i=0; i<=batchSize; i++) {
        			jlocs.add(jlocFactory.getProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer));
        		}

        		Database.DMLOptions dml = new Database.DMLOptions(); 
                        dml.DuplicateRuleHeader.AllowSave = true;

                        Test.startTest();

                        List<Database.SaveResult> srList = Database.insert(jlocs,dml);
                        Set<Id> jlocIds = new Set<Id>();
                        for(Database.SaveResult sr : srList) {
                	       if(sr.isSuccess()) {
                		      jlocIds.add(sr.getId());
                	       }
                        }

        		//Add Attendees
        		List<JLOC_Attendee__c> jlocAttendees = new List<JLOC_Attendee__c>();
                        for(JLOC__c jloc : jlocs) {
                	       jlocAttendees.add(new JLOC_Attendee__c(JLOC__c=jloc.Id,User__c=attendee.Id,Group__c='Trade'));
                        }
                        INSERT jlocAttendees;

                        for(JLOC_Attendee__c jlocAttendee : jlocAttendees) {
                	       jlocAttendee.Vote__c = JlocAttendeeTriggerHelper.STATUS_APPROVED;
                        }
                        UPDATE jlocAttendees;

                        for(JLOC__c jloc : [SELECT Id, JLOC_Status__c FROM JLOC__c WHERE Id IN :jlocIds]) {
                	       System.assertEquals(jloc.JLOC_Status__c, JlocAttendeeTriggerHelper.STATUS_APPROVED);
                        }

        		Test.stopTest();
                }
	}
}