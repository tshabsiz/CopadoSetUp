/**
* Date   : 2017-02-22
* Author : RN - CloudSmiths
* Desc   : Test class for teh web2case sites page controller
**/

@isTest(SeeAllData=true)
public class CM_External_Page_Ext_Test {
    
    public static testMethod void web2casePageTest(){
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //test data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
    	insert sm;
        Contact c = CSC_TestDataFactory.getDefaultEmailSupportContact();
        //insert c;
       
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'Complaint' , UserInfo.getUserId() );
        caseInsertList[0].Queue__c = 'Complaints Client';
       	caseInsertList[0].Service_Type__c = 'Delays';
        caseInsertList[0].Service_Sub_Category__c = 'Takes to Long';
        caseInsertList[0].Service_Category__c = 'Complaint';
        //insert caseInsertList;
		
        Test.startTest();
        
        ApexPages.standardController controller = new ApexPages.standardController(caseInsertList[0]);
        CM_External_Page_Ext theCont = new CM_External_Page_Ext(controller);
        
        theCont.submitCase();
        
        Test.stopTest();
    }
}