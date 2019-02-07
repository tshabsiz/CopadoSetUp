/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

23/03/2017 - DF   - Created Class.

**/
@IsTest
private class lscTransferCaseExt_test 
{
    @IsTest
    static void lscTransferCaseExt_test()
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
                Business_Hours__c= '	Monday to Friday 06:00 - 19:00', 
                Full_Department__c = 'Absa Electronic Banking Helpdesk',
                Effective_Date__c = date.today(),
                Email_SLA_Time_Measure__c = 'Hour', 
                Email_SLA_Units__c = '1'
                
            );
        insert testMapping;
        
        lscTransferCaseExt.transferCase(testCase.id, 'EBSH - Absa Electronic Banking');
        
        
        
    }
}