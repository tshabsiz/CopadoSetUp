/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JlocTrigger_Helper
*              Tests executed:
*               1 - sendJlocToSecretary()
*                   Test that JLOC is shared with Secretary after it is submitted.
*               2 - sendJlocToCommittee()
*                   Test that JLOC is shared with JLOC Committee Attendees.
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska  Testing for adding deal team members as JLOC followers
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_JlocTrigger {
    public static testMethod void sendJlocToSecretary() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u1 = userFactory.getExistingUserByProfile('Barclays Administrator');
        User u2 = userFactory.getBarclaysStandardUser();
        
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
            for(Integer i=0; i <= batchSize; i++) {
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

            Group jlocSecretary = [SELECT Id, Name FROM Group WHERE Name = :JlocTrigger_Helper.GROUP_JLOC_SECRETARY];
            INSERT new GroupMember(GroupId=jlocSecretary.Id, UserOrGroupId=u2.Id);

            //Change JLOC status to "Submitted to Secretary"
            for(JLOC__c jloc : jlocs) {
                jloc.JLOC_Status__c = JlocTrigger_Helper.STATUS_SUBMITTED_TO_SECRETARY;
            }
            srList = Database.update(jlocs,dml);

            Test.stopTest();

            List<JLOC__Share> secretarySharings = [SELECT Id FROM JLOC__Share WHERE UserOrGroupId = :u2.Id AND ParentId IN :jlocIds AND RowCause = :JlocTrigger_Helper.JLOC_SECRETARY];
            System.assertEquals(secretarySharings.size(), batchSize+1);
            List<EntitySubscription> subscriptions = [SELECT Id FROM EntitySubscription WHERE SubscriberId = :u2.Id AND ParentId IN :jlocIds LIMIT 500];
            System.assertEquals(subscriptions.size(), batchSize+1);
        }
    }

    public static testMethod void sendJlocToCommittee() {
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

            Integer batchSize = 20;
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

            for(JLOC__c jloc : jlocs) {
                jloc.JLOC_Status__c = JlocTrigger_Helper.STATUS_SUBMITTED_TO_SECRETARY;
            }
            UPDATE jlocs;

            //Add Attendees
            List<JLOC_Attendee__c> attendeesToIns = new List<JLOC_Attendee__c>();
            for(JLOC__c jloc : jlocs) {
                attendeesToIns.add(new JLOC_Attendee__c(JLOC__c=jloc.Id,User__c=u2.Id,Group__c='Trade'));
            }
            INSERT attendeesToIns;

            //Change JLOC status to "Sent to Committee"
            for(JLOC__c jloc : jlocs) {
                jloc.JLOC_Status__c = JlocTrigger_Helper.STATUS_SENT_TO_COMMITTEE;
            }
            UPDATE jlocs;

            Test.stopTest();

            List<EntitySubscription> subscriptions = [SELECT Id FROM EntitySubscription WHERE SubscriberId = :u2.Id AND ParentId IN :jlocIds LIMIT 500];
            System.assertEquals(subscriptions.size(), batchSize+1);
        }
    }
}