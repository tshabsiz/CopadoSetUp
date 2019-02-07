/* 
_____ _                 _ _____           _ _   _        
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

22/03/2017 - DF   - Created Class.

**/
@IsTest
private class lscLinkCaseExt_test 
{
    @IsTest
    static void lscLinkCaseExt_test()
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
        
        lscLinkCaseExt.getRelatedCase(testCase.id);
        
        lscLinkCaseExt.searchCases('test', 'test');
        
        EmailMessage testEmail = new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = testCase.id, isOriginalEmail__c = true); 
        
        
        insert testEmail;
        
        lscLinkCaseExt.linkEmailToCase(testCase.id, testCase.id);
    }
}