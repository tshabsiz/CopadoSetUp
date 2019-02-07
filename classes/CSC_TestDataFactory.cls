/**
* Date   : 06-08-2016
* Author : RN - CloudSmiths
* Desc   : Test Data factory for CSC Service Cloud Code, some methods could be use to generate data outside of the CSC implimentation 
**/

@isTest
public class CSC_TestDataFactory {
    
    //default number of records to create
    public static Integer testDataSize = 10;
    
    // Get Contact Record type Map
    public static Map <String, Schema.RecordTypeInfo> mapContactRecordTypes = Contact.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    // Get Account Record type Map
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    // Get Case Record type Map
    public static Map <String, Schema.RecordTypeInfo> mapCaseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    /**
* @Description Method to create a user
* @Param Profile Name, User Name
* @Return User
**/
    public static User createUser(string profile, string username) {
        username = Math.random()+ username;
        user newUser;
        try {
            Profile userProfile = [select Name from Profile where Name = :profile];
            newUser = new User(Alias = 'test',
                               Email = 'one@test.sbsa.co.za',
                               Emailencodingkey = 'UTF-8',
                               Lastname = profile + ' User',
                               Languagelocalekey = 'en_US',
                               City = 'Johannesburg',
                               Country = 'South Africa',
                               Division__c = 'Barclays',
                               BRID__c = String.valueOf(Math.random()).left(9),
                               Localesidkey = 'en_US',
                               Profileid = userProfile.Id,
                               Timezonesidkey = 'America/Los_Angeles',
                               Username = username);
        } Catch(Exception e) {
            system.assertEquals('List has no rows for assignment to SObject Profile', e.getMessage());
        }
        return newUser;
    }
    
    /**
* @Description Create Account records
* @Param RecordTypeId
* @Return List<Account>
**/
    
    public static list<Account> getTestAccountList(String recordTypeName) {
        
        list <Account> lstAccount = new list <Account> ();
        
        for (Integer i = 0; i < testDataSize; i++) {
            
            Account testAccount = new Account();
            testAccount.recordTypeId = mapAccountRecordTypes.get(recordTypeName).getRecordTypeId();
            testAccount.Name = 'Cloudsmiths ' +  recordTypeName  + i;
            testAccount.ShippingCountry = 'South Africa';
            
            lstAccount.add(testAccount);
        }
        return lstAccount;
    }  
    
    /**
* @Description Populate Contact record
* @Param List<Account>
* @Return List<Contact>
**/
    
    public static list<Contact> getTestContactList(list<Account> lstAccount) {
        
        list <Contact> lstcontact = new list <Contact> ();
        
        for (Integer i = 0; i < lstAccount.size(); i++) {
            
            Contact con = new Contact();
            con.AccountId = lstAccount[i].Id;
            con.LastName = 'testcontact' + i;
            con.FirstName = 'test' + i;
            con.MobilePhone = '0823343399';
            con.Email = Math.Random()+'absa@test.co.za';
            lstcontact.add(con);
        }
        return lstcontact;
    }  
    
    /**
* @Description Returns the default Contact used in all CSC comms on email template outbound emails 
* @Param NONE 
* @Return Contact
**/
    public static Contact getDefaultEmailSupportContact() {
        
        Contact con = new Contact();
        //con.AccountId = lstAccount[i].Id;
        con.LastName = 'Support';
        con.FirstName = 'Agent';
        con.MobilePhone = '27 11 237 1434';
        con.Email = 'agents@support.co.za';
        
        return con;
    }  
    /**
* @Description Populate one sservice mapping record
* @Param NONE 
* @Return Service_Mapping__c
**/
    public static Service_Mapping__c getServiceMapRecord() {
        
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
        return sm;
    }       
    
    /**
* @Description Create Case records
* @Param RecordTypeId
* @Param OwnerId
* @Return list<Case>
**/
    
    public static list<Case> getTestCaseList(String recordTypeName, String ownerId) {
        
        list<Case> lstCases = new list<Case>();
        
        for (Integer i = 0; i < testDataSize; i++) {
            
            Case testCase = new Case();
            testCase.recordTypeId = mapCaseRecordTypes.get(recordTypeName).getRecordTypeId();
            testCase.Subject = 'Support test ' +  recordTypeName  + i;
            testCase.OwnerId = ownerId;
            testCase.Origin = 'Email';
            testCase.Status = 'New';
            testCase.Priority = 'High';
            testCase.Email_From_Address__c = 'wouter@styne.co.za';
            lstCases.add(testCase);
        }
        
        return lstCases;
    }  
    
    /**
* @Description Create EmailMessage records
* @Param isHtml
* @Param ParentId
* @Return list<EmailMessage>
**/
    
    public static list<EmailMessage> getTestEmailMessageList(String parentObjId, Boolean isHTML) {
        
        list<EmailMessage> lstEmailMessages = new list<EmailMessage>();
        
        for (Integer i = 0; i < testDataSize; i++) {
            
            EmailMessage testEmailMessage = new EmailMessage();
            testEmailMessage.Subject = 'Email Message test ' + i;
            testEmailMessage.ParentId = parentObjId;
            testEmailMessage.MessageDate = System.now();
            
            if(isHTML){
                testEmailMessage.HtmlBody = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Outlook</title></head><table><tr><td>Test Email HTML body</td></tr></table></html>';
            }else{
                testEmailMessage.TextBody = 'Test Email Plaintext body';
            }
            
            lstEmailMessages.add(testEmailMessage);
        }
        return lstEmailMessages;
    }  
    
    /**
* @Description Create a Queue
* @Param QueueName
* @Return QueueId
**/
    /**
    public static String getTestQueueId(String qname) {
        Group  testgroup = new group();
        testgroup.Name = qname;
        testgroup.Type = 'Queue';
        insert testgroup;
        
        QueueSobject mappingObject = new QueueSobject(QueueId = testgroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert mappingObject;
        }
        
        return testgroup.Id;
    } **/
    
    /**
* @Description Create a Queue
* @Param QueueName
* @Return QueueId
**/
    
    public static list<CaseComment> getCaseComments(String caseID, Boolean pvt) {
        list<CaseComment> newCaseComments = new list<CaseComment>();
        
        for (Integer i = 0; i < testDataSize; i++){
            
            CaseComment cc = new CaseComment();
            cc.IsPublished = pvt;
            cc.CommentBody = 'Comment Number ' + i;
            cc.ParentId = caseID;
            
            newCaseComments.add(cc); 
        }
        
        return newCaseComments;
    }  
    
    /**
* @Description Create an InboundEmail record
* @Return Messaging.InboundEmail
**/
    public static Messaging.InboundEmail getTestInboundEmail() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.htmlBody = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Outlook</title></head><table><tr><td>Pls rest my password</td></tr></table></html>';
        email.subject = 'Please reset my pwd...now!';
        email.fromName = 'Wouter Styne';
        email.fromAddress = 'wouter@styne.co.za';
        return email;
    }  
    /**
* @Description Create an InboundEnvelope record
* @Return Messaging.InboundEnvelope
**/
    public static Messaging.InboundEnvelope getTestInboundEnvelope() {
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.toAddress = 'Passwords@absa.co.za';
        env.fromAddress = 'wouter@styne.co.za';
        return env;
    } 
    /**
* @Description Create an InboundEmail BinaryAttachment record
* @Return an array of Messaging.InboundEmail.BinaryAttachment[]
**/
    public static Messaging.InboundEmail.BinaryAttachment[] getTestBinaryAttachment() {
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        return new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            }  
    
    /**
* @Description Create an Attachment record
* @Param Attachment ParentId
* @Return an Attachment Record
**/
    public static Attachment getAttachment(String pid) {
        Attachment att = new Attachment();
        att.body = blob.valueOf('my attachment text');
        att.Description = 'Test Att';
        att.Name = 'Afile.txt';
        att.ParentId = pid;
        return att;
    }  
    
    
    /**
* @Description get the thread ID of a case
* @Param Case.Id
* @Return the Thread ID as String
**/
    public static String getTestCaseThreadID(String caseID) {
        return 'ref:_'  + UserInfo.getOrganizationId().left(4)  + 'E' + UserInfo.getOrganizationId().mid(11,4) + '._' + caseID.left(4) + 'E' + caseID.mid(10,5) + ':ref';
    }      
    
   
    public static void insertCustomSetting()
    {
        Case_Resolution_Date_Setting__c CRDS = new Case_Resolution_Date_Setting__c();
        CRDS.Name='Complaint';
        CRDS.Number_of_Days_Allowed__c =3;
        CRDS.Number_of_Times_Date_Change_Limit__c=4;
        insert CRDS;
    }
}