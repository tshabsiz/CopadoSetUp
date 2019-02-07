/*======================================================
@Description : Test Class for AddViewCharge_Ext
@Created Date : Mabhedle Tonga 
@Created BY : 2017-11-02
========================================================*/

@isTest(SeeAllData=true)
public class AddViewCharge_Ext_Test {
    
    
    static testMethod void myUnitTest()
    {
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        list<Case> manualCase = CSC_TestDataFactory.getTestCaseList('CSC Manual Cases',  UserInfo.getUserId());
        manualCase[0].Queue__c = 'EBSH - Passwords';
        manualCase[0].Department__c = 'EBSH';
        manualCase[0].Service_Type__c = 'System';
        manualCase[0].Email_Status__c = 'New';
        
        insert manualCase[0];
         Test.startTest();
        ApexPages.StandardController stcontroller = new ApexPages.StandardController(manualCase[0]);
        
        AddViewCharge_Ext addViewController = new AddViewCharge_Ext(stcontroller);
        
        
        addViewController.addnewLine();
        
        addViewController.chargeWrapperList[0].charge.cost_Centre__c = '123';
        addViewController.chargeWrapperList[0].charge.Charge_Account_No__c = '123';
        addViewController.chargeWrapperList[0].charge.Charge_Amount__c = 123;
        addViewController.chargeWrapperList[0].charge.Transaction_Code__c = '613';
        addViewController.chargeWrapperList[0].charge.Corp_Code__c = 'BNK';
        addViewController.chargeWrapperList[0].charge.CR_Ref__c = '123';
        addViewController.chargeWrapperList[0].charge.DR_Ref__c = '123';
        addViewController.chargeWrapperList[0].charge.CR_Account_No__c = '123';
		addViewController.chargeWrapperList[0].charge.Effective_Date__c = Date.today();
       	
        
        addViewController.SaveUpdates();
        
        List<Charge__c> chargeList = [Select ID from Charge__c where Case__c =:manualCase[0].ID];
        System.assertEquals(1, chargeList.size());
        addViewController.LockCharges();
        addViewController.unlock();
        addViewController.addnewLine();
        addViewController.SaveUpdates();
        addViewController.CRID = 0;
        addViewController.DeleteItem();
        addViewController.addnewLine();
        
    
        
         chargeList = [Select ID from Charge__c where Case__c =:manualCase[0].ID];
        System.assertEquals(0, chargeList.size());
       
		Test.stopTest();
    }
}