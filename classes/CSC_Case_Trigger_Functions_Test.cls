/**
* Date   : 08-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Case_Trigger_Functions
* 2017-04-20 - Rudolf Niehaus - CloudSmiths : Update for code covarage
**/
@IsTest(SeeAllData=true)
public class CSC_Case_Trigger_Functions_Test {
    
    public static testMethod void triggerTest() {
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //test data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        Contact cont = CSC_TestDataFactory.getDefaultEmailSupportContact();
        //insert cont;
        
        User approver = CSC_TestDataFactory.createUser('Barclays CSC User', 'approver@rudix.com');
        insert approver; 
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        u.DelegatedApproverId = approver.Id;
        insert u;
        
        
        list<Case> manualCase = CSC_TestDataFactory.getTestCaseList('CSC Manual Cases', u.Id);
        manualCase[0].Queue__c = 'EBSH - Absa Electronic Banking';
        manualCase[0].Department__c = 'EBSH';
        manualCase[0].Service_Type__c = 'System';
        manualCase[0].Email_Status__c = 'New';
        
        list<Case> emailCase = CSC_TestDataFactory.getTestCaseList('CSC Emails', u.Id);
        emailCase[0].Queue__c = 'EBSH - Absa Electronic Banking';
        emailCase[0].Department__c = 'EBSH';
        emailCase[0].Service_Type__c = 'System';
        emailCase[0].Email_Status__c = 'New';
        emailCase[0].Email_From_Address__c = 'test@test.com';
        
        //insert manualCase;
        list<Case> caseComp = CSC_TestDataFactory.getTestCaseList( 'Complaint' , UserInfo.getUserId());
        caseComp[0].Resolving_Area__c = 'Electronic Banking';
        caseComp[0].Resolving_Team__c = 'EBSH Complaints';
        caseComp[0].Complaint_Service_Type__c = 'ATM Related Issues';
          caseComp[0].Queue__c = 'EBSH Complaints';
        caseComp[0].Complaint_Service_Category__c = 'Complaint';
        caseComp[0].MNPI__c = true; 
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'Complaint' , UserInfo.getUserId() );
        CaseInsertList[0].Resolving_Area__c = 'Electronic Banking';
        caseInsertList[0].Resolving_Team__c = 'EBSH Complaints';
        caseInsertList[0].Complaint_Service_Type__c = 'ATM Related Issues';
          caseInsertList[0].Queue__c = 'EBSH Complaints';
        caseInsertList[0].Complaint_Service_Category__c = 'Complaint';
        caseInsertList[0].Email_Status__c = 'New';
        
        caseInsertList.add(caseComp[0]);
        caseInsertList.add(manualCase[0]);
        caseInsertList.add(emailCase[0]); 
        
        
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment(); 
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        emailService.handleInboundEmail(email, env);
        
        Test.startTest();
        
        insert caseInsertList;
        
        list<Case> newCase = [Select Id, Queue__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1]; 
        
        map<Id,Case> oldVal = new map<Id, Case>(newCase);
        
        
        newCase[0].Queue__c = 'EBSH - Absa Electronic Banking';
        newCase[0].Email_Status__c = 'Promoted';
        newCase[0].OwnerId = [Select Id From Group Where DeveloperName = 'EBSH' limit 1].Id;
        
        //update newCase;
        
        CSC_Case_Trigger_Functions_Complaint.updateServiceMapping(newCase, oldVal);
        
        manualCase[0].Queue__c = sm.Queue__c;
        manualCase[0].Department__c = sm.Department__c; 
        manualCase[0].Service_Type__c = sm.Service_Type__c;
        CSC_Case_Trigger_Functions.convertManualCases(manualCase,true);
        CSC_Case_Trigger_Functions.convertManualCases(manualCase,false);
        
        newCase[0].Queue__c = sm.Queue__c;
        newCase[0].Resolving_Team__c = sm.Queue__c;
        newCase[0].Department__c = sm.Department__c; 
        newCase[0].Service_Type__c = sm.Service_Type__c;
        newCase[0].Status = 'Awaiting Feedback - Client';
        newCase[0].MNPI__c = true;
        //update newCase[0];
        
        Test.stopTest();
        
    }
    
}