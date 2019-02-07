/**
* Date   : 2017-01-04
* Author : RN - CloudSmiths
* Desc   : Test class for the default attachment trigger and helper class
**/

@IsTest(seeAllData=true)
public class Attachment_Trigger_Test {
    
    public static testMethod void attTriggerTest(){
        //Test data factory
        CSC_TestDataFactory.testDataSize = 1;
        
        Contact c = CSC_TestDataFactory.getDefaultEmailSupportContact();
        //insert c; 
        
        //generate test case
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'Complaint' , UserInfo.getUserId() );
        
        CaseInsertList[0].Resolving_Area__c = 'Electronic Banking';
        caseInsertList[0].Resolving_Team__c = 'EBSH Complaints';
        caseInsertList[0].Complaint_Service_Type__c = 'ATM Related Issues';
        caseInsertList[0].Queue__c = 'EBSH Complaints';
        caseInsertList[0].Complaint_Service_Category__c = 'Complaint';
        insert caseInsertList[0];
        
        //generate att for test case 
        Attachment att = CSC_TestDataFactory.getAttachment(caseInsertList[0].Id);
        insert att;
        
        
        
        Test.startTest();
        
        try{
            delete att;
        }catch(DMLException e){
            String msg = e.getMessage();
            System.assertEquals(msg.contains('You cannot delete a Complaint Case attachment'), true);
        }
        
        Test.stopTest();
    }
}