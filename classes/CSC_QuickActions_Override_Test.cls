/*
 * 2017-03-31 - RN - CloudSmiths
 * Test class for CSC_QuickActions_Override
 * 2017-06-07: Rudolf Niehaus - CloudSmiths
 */
@isTest(SeeAllData=true)
public class CSC_QuickActions_Override_Test {
    static Case myCase {get;set;}
    static EmailMessage myMsg {get;set;}

    static testmethod void CSC_QuickActions_Override_Test() {
        Exception failureDuringExecution = null;
        init();

        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>{
          new Map<String, Object>{
                'targetSObject' => new EmailMessage(),
                'contextId' => myCase.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        
        Test.startTest();
        try {
            (new CSC_QuickActions_Override()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e; 
        }

        Test.stopTest();
        
    }
    static testmethod void EmailPublisherLoader_WithReplyToId() {
        Exception failureDuringExecution = null;
        init();

        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'replyToId' => myMsg.Id,
                'contextId' => myCase.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'salesforce@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        Test.startTest();
        try {
            (new CSC_QuickActions_Override()).onInitDefaults(defaultsSettings);
        }
        catch(Exception e) {
            failureDuringExecution = e; 
        }

        Test.stopTest();
    }

    static void init(){
        
        CSC_TestDataFactory.testDataSize = 1;
         
        //test data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        User approver = CSC_TestDataFactory.createUser('Barclays CSC User', 'approver@rudix.com');
        insert approver; 
         
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        u.DelegatedApproverId = approver.Id;
        insert u;
        
        list<Case> emailCase = CSC_TestDataFactory.getTestCaseList('CSC Emails', u.Id);
        emailCase[0].Queue__c = 'EBSH - Passwords';
        emailCase[0].Department__c = 'EBSH';
        emailCase[0].Service_Type__c = 'System';
        emailCase[0].Email_Status__c = 'New';
        emailCase[0].Email_From_Address__c = 'test@test.com';
        emailCase[0].Service_Mapping_Entry__c = sm.Id;
        
        myCase = emailCase[0];
        insert myCase;

        myMsg = new EmailMessage(ParentId = myCase.Id);
        insert myMsg;
    }
}