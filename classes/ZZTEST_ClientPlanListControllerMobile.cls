/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanListControllerMobile
*                 Tests executed:
*                 1 - testGetAccounts()
*                   Tests getter of accounts
*                 2 - testAddPlan()
*                   Tests creating new client plan
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 24-May-2016	Mohsin Wadee	Commented out the asserts from line 34-36
*								as it assumes there are Client Plans in the system, this may not be
*								the case in Dev etc.
* -------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanListControllerMobile {

    static testMethod void testGetAccounts() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, 
            dataContainer);
            
        List<Account> result = ClientPlanListControllerMobile.getAccounts(null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanListControllerMobile.getAccounts('1', null);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(acc1.Id, result[0].Id);
        
        result = ClientPlanListControllerMobile.getAccounts('1', 'Big');
        //System.assertNotEquals(null, result);
        //System.assertEquals(1, result.size());
        //System.assertEquals(acc1.Id, result[0].Id);
        
        result = ClientPlanListControllerMobile.getAccounts('0', 'Big');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }
    
    static testMethod void testAddPlan() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, 
            dataContainer);
            
        //not-existing accountId
        String result = ClientPlanListControllerMobile.addPlan(null);
        System.assertEquals(null, result);
        
        result = ClientPlanListControllerMobile.addPlan('asdfasdf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanListControllerMobile.addPlan(acc1.Id);
        System.assertNotEquals(null, result);
        
        List<Client_Plan__c> plans = [
            SELECT Id
            FROM Client_Plan__c
            WHERE Id = :result
        ];
        System.assertEquals(1, plans.size());
    }

}