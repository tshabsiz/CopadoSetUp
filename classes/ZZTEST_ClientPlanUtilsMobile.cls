/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanUtilsMobile class
*                 Tests executed:
*                 1 - testConvertUnqOpty()
*                   Tests conversion of potential opportunity to opportunity
*                 2 - testCheckUnqOptyConvertibility()
*                   Tests checking if potential opportunity is convertible to opportunity
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanUtilsMobile {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }

    static testMethod void testConvertUnqOpty() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        Client_Plan_Strategy__c strategy = new Client_Plan_Strategy__c(Name = 'Primary Strategy', 
            Client_Plan__c = plan.Id);
        insert strategy;

        Potential_Opportunity__c opty = new Potential_Opportunity__c(Name = 'Potential Opp 2', 
            Client_Plan__c = plan.Id, Client_Plan_Strategy__c = strategy.Id, Type__c = 'Cross Sell');
        insert opty;

        //null opty id
        Boolean result = ClientPlanUtilsMobile.convertUnqOpty(null);
        System.assertEquals(true, result);

        //not-existing opty id
        result = ClientPlanUtilsMobile.convertUnqOpty('asdf');
        System.assertEquals(true, result);

        //not-convertible opty
        result = ClientPlanUtilsMobile.convertUnqOpty(opty.Id);
        System.assertEquals(true, result);

        //working code
        opty.Close_Date__c = Date.today();
        update opty;

        result = ClientPlanUtilsMobile.convertUnqOpty(opty.Id);
        System.assertEquals(false, result);

        List<Opportunity> optys = [
            SELECT Id, Name, CloseDate, Type, StageName, AccountId, Client_Plan_Strategy__c
            FROM Opportunity
        ];
        System.assertEquals(1, optys.size());
        System.assertEquals(opty.Name, optys[0].Name);
        System.assertEquals(opty.Close_Date__c, optys[0].CloseDate);
        System.assertEquals(opty.Type__c, optys[0].Type);
        System.assertEquals('Opportunity Identified', optys[0].StageName);
        System.assertEquals(plan.Relationship__c, optys[0].AccountId);
        System.assertEquals(opty.Client_Plan_Strategy__c, optys[0].Client_Plan_Strategy__c);

        List<Potential_Opportunity__c> potOptys = [
            SELECT IsConverted__c, Opportunity__c
            FROM Potential_Opportunity__c
            WHERE Id = :opty.Id
        ];
        System.assertEquals(1, potOptys.size());
        System.assertEquals(true, potOptys[0].IsConverted__c);
        System.assertEquals(optys[0].Id, potOptys[0].Opportunity__c);
    }

    static testMethod void testCheckUnqOptyConvertibility() {
        Potential_Opportunity__c opty = new Potential_Opportunity__c();

        //null name
        Boolean result = ClientPlanUtilsMobile.checkUnqOptyConvertibility(opty);
        System.assertEquals(false, result);

        //empty string name
        opty.Name = '';
        result = ClientPlanUtilsMobile.checkUnqOptyConvertibility(opty);
        System.assertEquals(false, result);

        //null close date
        opty.Name = 'asdf';
        result = ClientPlanUtilsMobile.checkUnqOptyConvertibility(opty);
        System.assertEquals(false, result);

        //working code
        opty.Name = 'asdf';
        opty.Close_Date__c = Date.today();
        result = ClientPlanUtilsMobile.checkUnqOptyConvertibility(opty);
        System.assertEquals(true, result);
    }

}