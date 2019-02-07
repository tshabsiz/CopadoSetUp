/**
* 22/03/2017 - DF   - Created Class.
* 2018-04-30 - RN - CloudSmiths - Increase code coverage
**/
@IsTest
private class lscDropzoneExt_test 
{
    @IsTest
    static void lscDropzoneExt_test()
    {
        string base64 = 'test,test';
        case testCase = new case();
        testCase.Queue__c = 'EBSH - Absa Electronic Banking';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';
        testCase.Priority = 'High';  
        testcase.Department__c = 'EBSH';
        testCase.Full_Department__c = 'Absa Electronic Banking Helpdesk';

        insert testCase;
        
        lscDropzoneExt.getClipBoardImage(base64, string.valueOf(testCase.id) , base64);
        
        //createContent start
        blob testblob = blob.valueOf('test');
        contact testCon = new contact(lastname = 'testDropZone', Firstname = 'testDropZone');
        insert testCon;
        delete testCon;
        lscDropzoneExt.createContent(testblob,testCon.id , 'Test');
       
    }
    
}