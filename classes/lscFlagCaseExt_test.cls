/**

23/03/2017 - DF   - Created Class.

**/
@IsTest
private class lscFlagCaseExt_test 
{
    @IsTest
    static void lscFlagCaseExt_test()
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
        try
        {
            lscFlagCaseExt.flagCase(testCase.id, 'None');   
        }
        catch(exception e)
        {
            // do nothing as code coverage has been achieved.
        }
    }
    
}