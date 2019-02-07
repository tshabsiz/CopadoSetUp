@isTest
public class LscCaseQaFormController_Test {
    
  @isTest
    static void LscCaseQaFormController_Postive_test()
    { 
        case testCase = new case();
        
        testCase.Queue__c = 'EBSH - Absa Electronic Banking';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        testCase.Priority = 'High';  
        testCase.Department__c = 'EBSH';
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
                Business_Hours__c= '	Monday to Friday 06:00 - 19:00', 
                Full_Department__c = 'Absa Electronic Banking Helpdesk',
                Effective_Date__c = date.today(),
                Email_SLA_Time_Measure__c = 'Hour', 
                Email_SLA_Units__c = '1'
                
            );
        insert testMapping;
        
        
        Case_QA_Template__c QATemplate = new Case_QA_Template__c
          (
        
        	QAName__c ='EBSH',
            BusinessArea__c ='EBSH'
        
           );
                  
        insert QATemplate;
         
 
        
        Case_QA_Question__c CaseQA = new Case_QA_Question__c
            (
          	
            QATemplate__c = QATemplate.id,
            Heading__c = 'Test',
            QAQuestion__c = 'Test',
            Weighting__c = 12
        
        );
        
         insert CaseQA;
     
        
        Case_QA__c TestQustions = new Case_QA__c
        (
            
             RelatedCase__c= testCase.id,
             submittedBy__c = UserInfo.getUserId(),
             QATemplate__c = QATemplate.id,
             SavedResults__c = 'test|test'
     
        );
            insert TestQustions;
                system.debug(QATemplate.id+' Test 11111111111111111111111111111111111111111111111111111111111111111111111111111111111');
        
         LscCaseQaFormController.getCaseQaRecords(testCase.id,QATemplate.id);
         LscCaseQaFormController.fetchAgentRecords('test', 'Account');
        
        /* String CaseID =String.valueOf(testCase.id);
        String TemplateID =String.valueOf(testTemplate.id);
        String SavedResults =String.valueOf(testChecklist.id);
        
        lscCaseQAExt.updateCaseChecklistRecord(CaseID, TemplateID, SavedResults, CaseID);
        lscCaseQAExtFormSelection(); */
    }

     

/* @isTest
    static void LscCaseQaFormController_Postive(){
        
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
                Business_Hours__c= '	Monday to Friday 06:00 - 19:00', 
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
            
             
         LscCaseQaFormController.getCaseQaRecords(testCase.id,testTemplate.id);
         //LscCaseQaFormController.updateCaseChecklistRecord(testCase);
         LscCaseQaFormController.fetchAgentRecords('test', 'Account');
   
    
    } */
    

}