/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanController
*                 Tests executed:
*                 1 - testPlanIdInIdParam()
*                   Tests situation when planId is in 'id' param
*                 2 - testMissingPlanIdParam()
*                   Tests error handling when planId param is missing
*                 3 - testQueryOrgNameErrors()
*                   Tests errors handling during querying org name
*                 4 - testQueryOrgName()
*                   Tests querying org name
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanHeaderController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testPlanIdInIdParam() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlan;
        pr.getParameters().put('id', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanHeaderController ctrl = new ClientPlanHeaderController();
        System.assertEquals(plan.Id, ctrl.planId);
    }
    
    static testMethod void testMissingPlanIdParam() {
        PageReference pr = Page.ClientPlan;
        Test.setCurrentPage(pr);
        
        ClientPlanHeaderController ctrl = new ClientPlanHeaderController();
        System.assertEquals('', ctrl.orgName);
    }
    
    static testMethod void testQueryOrgNameErrors() {
        PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', 'adsfasdf');
        Test.setCurrentPage(pr);
        
        ClientPlanHeaderController ctrl = new ClientPlanHeaderController();
        System.assertEquals('', ctrl.orgName);
    }
    
    static testMethod void testQueryOrgName() {
        Client_Plan__c plan = [SELECT Id, Relationship__r.Name FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanHeaderController ctrl = new ClientPlanHeaderController();
        System.assertEquals(plan.Relationship__r.Name, ctrl.orgName);
    }
    
}