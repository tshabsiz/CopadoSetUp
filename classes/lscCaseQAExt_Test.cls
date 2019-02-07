/**
 * Lightning conversion from classic quick action
* @Author : Rudolf Niehaus - CloudSmiths
* @Date :   2018-04-16
* @Desc : Test Class for the lightning quick action Aura bundle lscCaseQA
*
**/

@isTest
public class lscCaseQAExt_Test {
    
    @isTest
    static void lscCaseQAExt_test()
    { 
        case testCase = new case();
        
        testCase.Queue__c = 'EBSH - Absa Electronic Banking';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        testCase.Priority = 'High';  
        testcase.Department__c = 'EBSH';
        testCase.Full_Department__c = 'Absa Electronic Banking Helpdesk';
        
        insert testCase;
        
        Group testq = new Group();
        testq.Name = 'testq';
        testq.Type = 'Queue'; 
        insert testq;
        
        Service_Mapping__c testMapping = new Service_Mapping__c
            (
                Queue_Name__c = 'testq', 
                queue__c = 'EBSH - Absa Electronic Banking',
                Team__c= 'Absa Electronic Banking',
                Department__c ='EBSH', 
                Business_Hours__c= '  Monday to Friday 06:00 - 19:00', 
                Full_Department__c = 'Absa Electronic Banking Helpdesk',
                Effective_Date__c = date.today(),
                Email_SLA_Time_Measure__c = 'Hour', 
                Email_SLA_Units__c = '1'
                
            );
        insert testMapping;
        
        Case_Checklist_Template__c testTemplate = new Case_Checklist_Template__c
            (
                BusinessArea__c = 'RSCS',
                ChecklistName__c = 'test'
            );
        insert testTemplate;
        
        Case_Checklist__c testChecklist = new Case_Checklist__c
            (
                
                ChecklistTemplate__c =testTemplate.id,
                RelatedCase__c = testCase.id,
                SubmittedBy__c =  UserInfo.getUserId(),
                SavedResults__c = 'test|test'
                
            );
        
        insert testChecklist;
        
        
        lscCaseQAExt.getChecklistTemplateRecord();
        lscCaseQAExt.getQAtemplateRecord();
        lscCaseQAExt.getCaseChecklistRecords(testCase.id,testTemplate.id);
        
        String CaseID =String.valueOf(testCase.id);
        String TemplateID =String.valueOf(testTemplate.id);
        String SavedResults =String.valueOf(testChecklist.id);
        
        lscCaseQAExt.updateCaseChecklistRecord(CaseID, TemplateID, SavedResults, CaseID);
        //lscCaseQAExtFormSelection();
    }
    @IsTest
    static void lscCaseQAExt_test_Negitve(){
        
        lscCaseQAExt.getChecklistTemplateRecord();
        lscCaseQAExt.getQAtemplateRecord();
        lscCaseQAExt.getCaseChecklistRecords(null,null);
        lscCaseQAExt.updateCaseChecklistRecord(null,null, null, null);
        
        
        
    }
     @IsTest
    static void lscCaseQAExt_test_Postive(){
        
         case testCase = new case();
        
        testCase.Queue__c = 'EBSH - Absa Electronic Banking';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        testCase.Priority = 'High';  
        testcase.Department__c = 'EBSH';
        testCase.Full_Department__c = 'Absa Electronic Banking Helpdesk';
        
        insert testCase;
        
        Group testq = new Group();
        testq.Name = 'testq';
        testq.Type = 'Queue'; 
        insert testq;
        
        Service_Mapping__c testMapping = new Service_Mapping__c
            (
                Queue_Name__c = 'testq', 
                queue__c = 'EBSH - Absa Electronic Banking',
                Team__c= 'Absa Electronic Banking',
                Department__c ='EBSH', 
                Business_Hours__c= '  Monday to Friday 06:00 - 19:00', 
                Full_Department__c = 'Absa Electronic Banking Helpdesk',
                Effective_Date__c = date.today(),
                Email_SLA_Time_Measure__c = 'Hour', 
                Email_SLA_Units__c = '1'
                
            );
        insert testMapping;
        
        Case_Checklist_Template__c testTemplate = new Case_Checklist_Template__c
            (
                BusinessArea__c = 'RSCS',
                ChecklistName__c = 'test'
            );
        insert testTemplate;
        
        Case_Checklist_Question__c testQuestion = new Case_Checklist_Question__c
            (
                
             Checklist_Template__c = testTemplate.id,
             Heading__c = 'Test',
             Question__c= 'What is the test?'
                
            );
        insert testQuestion;
        
        Case_Checklist__c testChecklist = new Case_Checklist__c
            (
                
                ChecklistTemplate__c =testTemplate.id,
                RelatedCase__c = testCase.id,
                SubmittedBy__c =  UserInfo.getUserId()
               // SavedResults__c = 'This is a test'
                
            );
        
        insert testChecklist;
        
        
        lscCaseQAExt.getChecklistTemplateRecord();
        lscCaseQAExt.getQAtemplateRecord();
        lscCaseQAExt.getCaseChecklistRecords(testCase.id,testTemplate.id);
        
        String CaseID =String.valueOf(testCase.id);
        String TemplateID =String.valueOf(testTemplate.id);
        String SavedResults =String.valueOf(testChecklist.id);
        
        lscCaseQAExt.updateCaseChecklistRecord(CaseID, TemplateID, SavedResults, CaseID);
        
    }
    
}