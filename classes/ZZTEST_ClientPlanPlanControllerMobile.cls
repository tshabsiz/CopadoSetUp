/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanPlanControllerMobile
*                 Tests executed:
*                 1 - testGetBudgetRevenues()
*                   Tests getter of burget revenues
*                 2 - testGetPotOptys()
*                   Tests getter of potential opportunities
*                 3 - testGetOptys()
*                   Tests getter of opportunities
*                 4 - testGetBudgetRevenue()
*                   Tests getter of budget revenue
*                 5 - testAddBudgetRevenue()
*                   Tests adding of budget revenue
*                 6 - testEditBudgetRevenue()
*                   Tests editation of budget revenue
*                 7 - testRemoveBudgetRevenue()
*                   Tests removing of budget revenue
*                 8 - testConvertUnqOpty()
*                   Tests conversion of pot opty to opty
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanPlanControllerMobile {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testGetBudgetRevenues() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String brId = prepareBudgetRevenue(plan.Id);
        
        //not-existing planId
        List<Budget_Revenue__c> result = ClientPlanPlanControllerMobile.getBudgetRevenues(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanPlanControllerMobile.getBudgetRevenues('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanPlanControllerMobile.getBudgetRevenues(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(brId, result[0].Id);
    }
    
    static testMethod void testGetPotOptys() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String optyId = preparePotOpty(plan.Id);
        
        //not-existing planId
        List<Potential_Opportunity__c> result = ClientPlanPlanControllerMobile.getPotOptys(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanPlanControllerMobile.getPotOptys('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanPlanControllerMobile.getPotOptys(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(optyId, result[0].Id);
    }
    
    static testMethod void testGetOptys() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String optyId = prepareOpty(acc.Id);
        
        //not-existing planId
        List<Opportunity> result = ClientPlanPlanControllerMobile.getOptys(null);
        System.assertEquals(null, result);
        
        result = ClientPlanPlanControllerMobile.getOptys('asdf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanPlanControllerMobile.getOptys(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(optyId, result[0].Id);
    }
    
    static testMethod void testGetBudgetRevenue() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String brId = prepareBudgetRevenue(plan.Id);
        
        //not-existing brId
        List<Budget_Revenue__c> result = ClientPlanPlanControllerMobile.getBudgetRevenue(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanPlanControllerMobile.getBudgetRevenue('asdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanPlanControllerMobile.getBudgetRevenue(brId);
        System.assertNotEquals(null, result);
        System.assertEquals(brId, result[0].Id);
    }
    
    static testMethod void testAddBudgetRevenue() {

        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        
        //null planId
        Boolean result = ClientPlanPlanControllerMobile.addBudgetRevenue(null, null, null, null, null,
            null, null, null, null, null);
        System.assertEquals(true, result);
        
        //null values
        result = ClientPlanPlanControllerMobile.addBudgetRevenue(plan.Id, null, null, null, null,
            null, null, null, null, null);
        System.assertEquals(false, result);
        
        List<Budget_Revenue__c> brs = [
            SELECT Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, 
                   Actual_Year_Annualised_Revenues__c, Budget_Annualised__c, Next_year_budget__c, Actual_RWA__c, Actual_RoRWA__c
            FROM Budget_Revenue__c
        ];
        System.assertEquals(1, brs.size());
        System.assertEquals(null, brs[0].Product_Level_3__c);
        System.assertEquals(null, brs[0].Previous_YTD_Revenues__c);
        System.assertEquals(null, brs[0].Actual_YTD_Revenues__c);
        System.assertEquals(null, brs[0].Budget_YTD__c);
        System.assertEquals(null, brs[0].Actual_Year_Annualised_Revenues__c);
        System.assertEquals(null, brs[0].Budget_Annualised__c);
        System.assertEquals(null, brs[0].Next_year_budget__c);
        System.assertEquals(null, brs[0].Actual_RWA__c);
        System.assertEquals(null, brs[0].Actual_RoRWA__c);
        
        delete brs;
        
        //filled fields
        result = ClientPlanPlanControllerMobile.addBudgetRevenue(plan.Id, productLvl31.Id, 1, 2, 3,
            4, 5, 6, 7, 8);
        System.assertEquals(false, result);
        
        brs = [
            SELECT Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, 
                   Actual_Year_Annualised_Revenues__c, Budget_Annualised__c, Next_year_budget__c, Actual_RWA__c, Actual_RoRWA__c
            FROM Budget_Revenue__c
        ];
        System.assertEquals(1, brs.size());
        System.assertEquals(productLvl31.Id, brs[0].Product_Level_3__c);
        System.assertEquals(1, brs[0].Previous_YTD_Revenues__c);
        System.assertEquals(2, brs[0].Actual_YTD_Revenues__c);
        System.assertEquals(3, brs[0].Budget_YTD__c);
        System.assertEquals(4, brs[0].Actual_Year_Annualised_Revenues__c);
        System.assertEquals(5, brs[0].Budget_Annualised__c);
        System.assertEquals(6, brs[0].Next_year_budget__c);
        System.assertEquals(7, brs[0].Actual_RWA__c);
        System.assertEquals(8, brs[0].Actual_RoRWA__c);
    }
    
    static testMethod void testEditBudgetRevenue() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String brId = prepareBudgetRevenue(plan.Id);
        String prodLvl3Id = [SELECT Id FROM Product_Level_3__c].Id;
        
        //null handling
        Boolean result = ClientPlanPlanControllerMobile.editBudgetRevenue(null, null, null, null, null,
            null, null, null, null, null);
        System.assertEquals(true, result);
        
        //working code
        result = ClientPlanPlanControllerMobile.editBudgetRevenue(brId, prodLvl3Id, 21, 22, 23, 24, 25, 26, 27, 28);
        System.assertEquals(false, result);
        
        List<Budget_Revenue__c> brs = [
            SELECT Id, Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, Actual_Year_Annualised_Revenues__c,
                Budget_Annualised__c, Next_year_budget__c, Actual_RWA__c, Actual_RoRWA__c
            FROM Budget_Revenue__c
        ];
        System.assertEquals(1, brs.size());
        System.assertEquals(brId, brs[0].Id);
        System.assertEquals(prodLvl3Id, brs[0].Product_Level_3__c);
        System.assertEquals(21, brs[0].Previous_YTD_Revenues__c);
        System.assertEquals(22, brs[0].Actual_YTD_Revenues__c);
        System.assertEquals(23, brs[0].Budget_YTD__c);
        System.assertEquals(24, brs[0].Actual_Year_Annualised_Revenues__c);
        System.assertEquals(25, brs[0].Budget_Annualised__c);
        System.assertEquals(26, brs[0].Next_year_budget__c);
        System.assertEquals(27, brs[0].Actual_RWA__c);
        System.assertEquals(28, brs[0].Actual_RoRWA__c);
    }

    static testMethod void testRemoveBudgetRevenue() {

        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String brId = prepareBudgetRevenue(plan.Id);

        //null brId
        Boolean result = ClientPlanPlanControllerMobile.removeBudgetRevenue(null);
        System.assertEquals(true, result);

        //not-existing brId
        result = ClientPlanPlanControllerMobile.removeBudgetRevenue('asdf');
        System.assertEquals(true, result);

        //working code
        result = ClientPlanPlanControllerMobile.removeBudgetRevenue(brId);
        System.assertEquals(false, result);

        List<Budget_Revenue__c> brs = [
            SELECT Id
            FROM Budget_Revenue__c
            WHERE Id = :brId
        ];
        System.assertEquals(true, brs.isEmpty());
    }
    
    private static String prepareOpty(String accId) {
    
        Opportunity opty = new Opportunity();
        opty.AccountId = accId;
        opty.Name = 'Opty 1';
        opty.StageName = 'Identified';
        opty.CloseDate = Date.today();
        insert opty;
        
        return opty.Id;
    }
    
    private static String preparePotOpty(String planId) {
        
        Potential_Opportunity__c opty = new Potential_Opportunity__c();
        opty.Client_Plan__c = planId;
        opty.Name = 'opty 1';
        opty.Close_Date__c = Date.today();
        opty.Product__c = 'prod';
        opty.Stage__c = 'stage';
        opty.Probability__c = 3;
        opty.Type__c = 'type';
        insert opty;
        
        return opty.Id;
    }
    
    private static String prepareBudgetRevenue(String planId) {

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        
        Budget_Revenue__c br = new Budget_Revenue__c();
        br.Client_Plan__c = planId;
        br.Product_Level_3__c = productLvl31.Id;
        br.Previous_YTD_Revenues__c = 1;
        br.Actual_YTD_Revenues__c = 2;
        br.Budget_YTD__c = 3;
        br.Previous_Year_Annualised_Revenues__c = 4;
        br.Actual_Year_Annualised_Revenues__c = 5;
        br.Budget_Annualised__c = 6;
        br.Next_year_budget__c = 7;
        br.YTD_RWA__c = 8;
        br.Actual_RWA__c = 9;
        br.YTD_RoRWA__c = 10;
        br.Actual_RoRWA__c = 11;
        insert br;
        
        return br.Id;
    }

    //coverage test, this functionality is tested in ZZTEST_ClientPlanUtils
    static testMethod void testConvertUnqOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c strategy = new Client_Plan_Strategy__c();
        strategy.Name = 'asdf';
        strategy.Client_Plan__c = plan.Id;
        insert strategy;

        Boolean result = ClientPlanPlanControllerMobile.convertUnqOpty(strategy.Id);
        System.assertEquals(true, result);
    }
    
}