/*================================================
@Author : Mabhedle Tonga 
@Description : Test Class
@Created Date : 2017/12/14
==================================================*/
@isTest
public class AccountHelperController_Test {

    static testMethod void isAFricaRDOwnedTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
		Account relationshipGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        
        Test.startTest();
        
        boolean isRDHolder = AccountHelperController.isAFricaRDOwned(relationshipGroup.ID);
        
        System.assertEquals(true, isRDHolder);
        
        Test.stopTest();
    }
    
    static testMethod void getNewNameTest()
    {
        insert new ProjectName__c(Name = 'Jupiter', Reserved__c = false, Used__c = false);
        
        Test.startTest();
        AccountHelperController.getNewName();
        
        ProjectName__c projectName = [SELECT Reserved__c, Used__c FROM ProjectName__c WHERE Name = 'Jupiter' LIMIT 1];
        
        System.assertEquals(true, projectName.Reserved__c);
        test.stopTest();
    }
    static testMethod void createClientPlanTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
		Account relationshipGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        
        Test.startTest();
        
        String status = AccountHelperController.createClientPlan(relationshipGroup.Id);
        System.assertNotEquals('false', status);
        
        status = AccountHelperController.createClientPlan(relationshipGroup.Id);
        
        System.assertEquals('false', status);
        
        Test.stopTest();
    }
    
    static testMethod void fetchRecordTypeValuesTest()
    {
        Test.startTest();
        
        List<String> recordTypeList = AccountHelperController.fetchRecordTypeValues();
        
        List<RecordType> DBList = [Select ID from RecordType where SObjectType = 'Call_Report__c'];
        
        ID RecordTypeId = AccountHelperController.getRecTypeID(recordTypeList[0]);
        
        System.assertEquals(DBList.size(), recordTypeList.size());
        
        Test.stopTest();
    }
}