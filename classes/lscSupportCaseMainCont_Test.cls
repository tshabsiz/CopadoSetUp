@isTest(SeeAllData=true)
public class lscSupportCaseMainCont_Test {

    @isTest
    static void lscSupportCaseMainCont_Postive(){
        
      
        case testCase = new case();
        
        testCase.Queue__c = 'EBSH - Passwords';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        testCase.Priority = 'High';  
        testcase.Department__c = 'EBSH';
        testCase.Full_Department__c = 'Absa Electronic Banking Helpdesk';
        testCase.SLA_Time_Measure__c= 'Hour(s)';
        testCase.SLA_Units__c= 2;
        
        insert testCase;
        
     Group testq = new Group();
        testq.Name = 'testq';
        testq.Type = 'Queue'; 
        insert testq;
        
        Service_Mapping__c sm = new Service_Mapping__c();
           
                sm.SLA_Time_Measure__c = 'Hour(s)';
                sm.SLA_Units__c = '2';
                sm.Email_SLA_Time_Measure__c = 'Hour(s)';
                sm.Email_SLA_Units__c = '2';
                sm.Complexity__c = 'Medium';
                sm.First_Approval__c = 'Not Applicable';
                sm.ID_V_Required__c = 'Moderate';
                sm.Priority__c = 'High';
                sm.Second_Approval__c = 'Not Applicable';
                sm.Team__c = 'Passwords';
                sm.Queue_Name__c = 'EBSH_Passwords';
                sm.First_Escalation_Time__c = 8;
                sm.Second_Escalation_Time__c = 9;
                sm.Business_Hours__c = 'Monday to Friday 08:00 - 16:30';
                sm.Channel__c = 'AMS;Authenticated Collections;AVS;Bankserv;B.Net;BDI;BI Online;BICOS;BII ICM;BII Trade Finance;Billway;C2B;Cash Focus;CF Dial Up;CLP;CSS;EDI;Filegateway;Generic Banking Processing RSC Support;H2H;International Banking Payments;Link Direct;Local Banking;Magtapes;Mailbox;NMB;Recon Focus;Statement Delivery;Zram;Not Applicable';
                sm.Department__c = 'EBSH';
                sm.Full_Department__c = 'Absa Electronic Banking Helpdesk';
                sm.Queue__c = 'EBSH - Passwords';
                sm.Effective_Date__c = System.today();
                sm.Template_Name_Email_Receipt__c = 'CSC_Email_Receipt_EBSH_Passwords';
                sm.Template_Name_Case_Creation__c = 'CSC_Case_Creation_EBSH_1';
                sm.Template_Name_Case_Close__c = 'CSC_Case_Closure_EBSH_1';
                sm.Support_Email_Address__c = 'Passwords@absa.co.za';
                sm.Service_Type__c = 'System';
                sm.Service_Category__c = 'Incident';
                sm.Priority__c = 'High';
                sm.Service_Sub_Category__c = 'Change/Enhance';
                sm.Team_Manager__c = 'Tanya Theunissen';
                sm.Template_Name_Feedback_Email__c = 'CSC_Case_Creation_EBSH_1';
                sm.Feedback_Time_Measure__c = 'Hour';
                sm.Feedback_Units__c = '1';
                sm.Response_From_Email_Address__c = 'Passwords@absa.co.za';
                sm.SLA_Pause_Status__c = 'Awaiting Feedback - Client';
                sm.SLA_Pause_Status_Internal__c = 'Awaiting Feedback - 3rd Party';
                sm.Convert_To_RecordType__c = 'CSC_Emails';
                
      
        insert sm;
        
            EmailMessage testEmailMessage = new EmailMessage();
        
        
                testEmailMessage.Subject = 'Email Message test ';
                testEmailMessage.ParentId = testCase.id;
                testEmailMessage.MessageDate = System.now();
                testEmailMessage.isOriginalEmail__c =true;
        
         insert testEmailMessage;
        
        Attachment attachment = new Attachment(); 
           
             attachment.ParentId = testEmailMessage.Id;
             attachment.Name ='Email Body.html';   
             attachment.Body = Blob.valueOf('bodyTest');
        
         insert attachment;
        
        string CaseID = String.valueOf(testCase.id);
        
        lscSupportCaseMainCont.returnSupportCase(CaseID,'true');
        
    }
    
}