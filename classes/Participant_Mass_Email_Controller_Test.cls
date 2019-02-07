/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

02/02/2018 - DF    - Created Class.

**/
@isTest
public class Participant_Mass_Email_Controller_Test 
{
    public static testMethod void Participant_Mass_Email_Controller_Test()
    {
        User testUser = Cloudsmiths_TestDataClass.createUser('TMG Standard User', 'tmg@tmg.co.za');
        Id participantContactRecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Contact' AND SObjectType = 'advpm__Participant__c' limit 1].id;     
        System.debug('participantContactRecordTypeId : ' + participantContactRecordTypeId);
        Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

        List<advpm__Participant__c> insertParticipantList = new List<advpm__Participant__c>();
        advpm__Participant__c TestParticipantRecord1 = new advpm__Participant__c
        (
            advpm__Matter__c = testData.TestMatter.Id,
            Name = 'Part 1',
            advpm__Contact__c = testData.TestContact.Id,
            advpm__Role__c = 'Agency',
            RecordTypeId = participantContactRecordTypeId
        );
        insertParticipantList.add(TestParticipantRecord1);
        advpm__Participant__c TestParticipantRecord2 = new advpm__Participant__c
        (
            advpm__Matter__c = testData.TestMatter.Id,
            Name = 'Part 2',
            advpm__Contact__c = testData.TestContact.Id,
            advpm__Role__c = 'SPV',
            RecordTypeId = participantContactRecordTypeId
        );
        insertParticipantList.add(TestParticipantRecord2);
        insert insertParticipantList;

        Test.startTest();
        
        Test.setCurrentPage(Page.Participant_Mass_Email_Selection);
        ApexPages.currentPage().getParameters().put('id', testData.TestMatter.id);
        Participant_Mass_Email_Controller Con = new Participant_Mass_Email_Controller();

        con.UpdateSearchResults();
        con.updateParticipantList();
        con.selectedRoles = con.allRoles;
        con.updateParticipantList();
        con.selectedRelationships = con.allRelationships;
        con.updateParticipantList();
        con.NextPage();
        con.getFromEmailAddressList();
        con.SendEmail();
        Con.emailSubject = 'Test';
        con.SendEmail();
        Con.emailBody= 'Test';
        con.SendEmail();
        con.Cancel();

        Test.StopTest();
    }
}