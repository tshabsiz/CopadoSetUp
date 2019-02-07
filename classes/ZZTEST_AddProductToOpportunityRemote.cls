/**
* @Author:        Marta Malinowska
* @Company:       Deloitte
* @Description:   Unit Tests for AddProductToOpportunityRemote
*                 Tests executed:
*                 1 - testStdController()
*                   
*                 2 - testSimple()
*                   
*                 3 - testCoverageRemote()
*                   
*                 4 - testCreateOppProductItem_Validations_ProductPrice()
*                   
*                 5 - testCreateOppProductItem_Validations_Fees()
*                   
*                 6 - testCreateOppProductItem_ProductTree()
*                   
*                 7 - testCreateOppProductItem_Values()
*
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 3.12.2015   Marek Cech         modified testCreateOppProductItem_Values - values in asserts according to added
*                                    calculations in trigger
* 07-Dec-2015 Mohsin Wadee 		US-0775 - Call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
											method in following methods:
										testCreateOppProductItem_Validations_ProductPrice
										testCreateOppProductItem_ProductTree
										testCreateOppProductItem_Values
* 10-Dec-2015 Mohsin Wadee 		US-0775 - Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*										with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
* 07-Jul-2016	Mohsin Wadee	In setup() method specified Stage as Opportunity Identified, otherwise further rules will apply,
*								and specified Accountable Banker.
* -------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class ZZTEST_AddProductToOpportunityRemote {

    private final static String OPP_NAME = 'Test Opp 123';
    private final static String COUNTRY_NAME = 'Cov. Country 1';
    private final static String PROD1_NAME = 'Good Product lvl1';
    private final static String PROD1_PRICE_NAME = 'Good Product lvl1 - with price';
    private final static String PROD2_NAME = 'Good Product lvl2';
    private final static String PROD3_NAME = 'Good Product lvl3';
    
    @testSetup
    static void setup() {
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Account a = new Account();
        a.Name = 'aaaa';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.name = OPP_NAME;
        o.StageName = 'Opportunity Identified';
        o.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        o.CloseDate = Date.newInstance(Date.today().year(), 12, 31);
        o.Pricebook2Id = Test.getStandardPricebookId();
        o.The_accountable_banker_has_been_cleared__c = true;
        insert o;
        
        Product2 p = new Product2();
        p.Name = PROD1_NAME;
        p.IsActive = true;
        insert p;
        
        Product2 p2 = new Product2();
        p2.Name = PROD1_PRICE_NAME;
        p2.IsActive = true;
        insert p2;
        
        PriceBookEntry pe = new PriceBookEntry();
        pe.Product2Id = p2.Id;
        pe.IsActive = true;
        pe.Pricebook2Id = Test.getStandardPricebookId();
        pe.UnitPrice = 10000;
        pe.UseStandardPrice = false;
        insert pe;
        
        Product_Level_2__c  pl2 = new Product_Level_2__c();
        pl2.Product__c = p2.Id;
        pl2.Name = PROD2_NAME;
        insert pl2;
        
        Product_Level_3__c  pl3 = new Product_Level_3__c();
        pl3.Product_Level_2__c = pl2.Id;
        pl3.Name = PROD3_NAME;
        insert pl3;
        
        Coverage_Country__c co = new Coverage_Country__c();
        co.Name = COUNTRY_NAME;
        insert co;
        }
        
    }

    @IsTest
    static void testStdController() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            try {
                AddProductToOpportunityRemoteController c = new AddProductToOpportunityRemoteController(null);
                System.assert(false, 'OppId missing, must throw BarclaysException');
            } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
                System.assert(true);
            }
        }
        
    }
    
    
    @IsTest
    static void testSimple() {
        Opportunity o = [Select Id FROM Opportunity WHERE Name =: OPP_NAME];
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Test.startTest();
            
            ApexPages.CurrentPage().getparameters().put('id', o.Id);
            AddProductToOpportunityRemoteController c = new AddProductToOpportunityRemoteController(null);
            c.getProducts();
            
            List<SelectOption> centres = c.getBookingCentres();
            List<SelectOption> recurringFees = c.getRecurringFeesPeriod();
            
            Test.stopTest();
            
            System.assert(centres.size() > 0);
            System.assert(centres.size() > 4);
            
        }
        
    }
    
    @IsTest
    static void testCoverageRemote() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Product2 p = [SELECT Id FROM Product2 WHERE Name =: PROD1_NAME];
        
        Test.startTest();
        
        AddProductToOpportunityRemoteController.getProductsLevel2(p.Id);
        AddProductToOpportunityRemoteController.getProductsLevel3(p.Id);
        
        Test.stopTest();
        }
        
    }
    
     
    @IsTest
    static void testCreateOppProductItem_Validations_ProductPrice() {
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        
        Product2 p = [SELECT Id FROM Product2 WHERE Name =: PROD1_NAME];
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name =: PROD1_PRICE_NAME];
        Opportunity o = [Select Id FROM Opportunity WHERE Name =: OPP_NAME];
        
        Test.startTest();
        try {
            AddProductToOpportunityRemoteController.createProduct(
                o.Id, null, null, null, null,
                1, 0, 2, // Fees & balance not null
                '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(false, 'Can\'t pass - no product specified');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(true);
        }
        
        try {
            AddProductToOpportunityRemoteController.createProduct(
                o.Id, null, p.Id, null, null,
                1, 0, 2, // Fees & balance not null
                '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(false, 'Can\'t pass - no price specified');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(true);
        }
        
        try {
            AddProductToOpportunityRemoteController.createProduct(
                null, o.Id, p2.Id, null, null, 
                1, 0, 2, // Fees & balance not null
                '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(true, 'Must pass - price specified');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(false, 'Can\'t fail - price is specified: ' + ex.getMessage());
        }
        
        Test.stopTest();
        }
        
    }
     
    @IsTest
    static void testCreateOppProductItem_Validations_Fees() {
        Product2 p = [SELECT Id FROM Product2 WHERE Name =: PROD1_PRICE_NAME];
        Opportunity o = [Select Id FROM Opportunity WHERE Name =: OPP_NAME];
        
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Test.startTest();
        
        try {
            AddProductToOpportunityRemoteController.createProduct(
                o.Id, null, p.Id, null, null,
                0, 0, 2, // Fees = 0
                '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(false, 'Can\'t pass - Fees required');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(true);
        }
        
        try {
            AddProductToOpportunityRemoteController.createProduct(
                o.Id, null, p.Id, null, null,
                1, 0, 0, // balance = 0
                '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(false, 'Must fail - balance required');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(true);
        }
        
        Test.stopTest();
        }
        
    }
    
    @IsTest
    static void testCreateOppProductItem_ProductTree() {
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        Product2 p = [SELECT Id FROM Product2 WHERE Name =: PROD1_PRICE_NAME];
        Product_Level_2__c p2 = [SELECT Id FROM Product_Level_2__c WHERE Name =: PROD2_NAME];
        Product_Level_3__c p3 = [SELECT Id FROM Product_Level_3__c WHERE Name =: PROD3_NAME];
        Opportunity o = [Select Id FROM Opportunity WHERE Name =: OPP_NAME];
        Coverage_Country__c co = [SELECT Id FROM Coverage_Country__c WHERE Name =: COUNTRY_NAME];
        
        try {
            // All product tree
            AddProductToOpportunityRemoteController.createProduct(
                null, o.Id, p.Id, p2.Id, p3.Id,
                1, 0, 1, co.Id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 'Monthly'
            );
            System.assert(true);
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(false, 'Must pass: ' + ex.getMessage());
        }
        }
        
    }
    
    @IsTest
    static void testCreateOppProductItem_Values() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);

        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Product2 p = [SELECT Id FROM Product2 WHERE Name =: PROD1_PRICE_NAME];
        Opportunity o = [Select Id FROM Opportunity WHERE Name =: OPP_NAME];
        
        Test.startTest();
        
        List<OpportunityLineItem> prodList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: o.Id];
        System.assertEquals(prodList.size(), 0);
                
        try {
            // test case: all params of "createProduct" are stored to DB
            AddProductToOpportunityRemoteController.createProduct(
                null, o.Id, p.Id, null, null,
                1, 2, 3,
                '',
                4, 5,
                6, 7,
                8, 9, 10,
                11, 12, 13, 100, 'Monthly'
            );
            System.assert(true, 'Must pass');
        } catch (AddProductToOpportunityRemoteController.BarclaysException ex) {
            System.assert(false, 'Can\'t fail: ' + ex.getMessage());
        }
        
                
        prodList = [
            SELECT
                Id, Fees__c, Annualised_Income__c, Balance__c, Booking_Centre__c, Estimated_Utilisation__c,
                Existing_Facility_Balance__c, Income_this_Year__c, Net_Facility_Balance__c, Margin__c, New_Facility__c,
                New_Facility_Balance__c, ROEC__c, RoRWA__c, Terms_Years__c, Recurring_Fees_Period__c, Recurring_Fees__c
            FROM OpportunityLineItem
            WHERE OpportunityId =: o.Id
        ];
        
        Test.stopTest();
        
        System.assertEquals(prodList.size(), 1);
        
        OpportunityLineItem ol = prodList.get(0);
        
        System.assertEquals(ol.Fees__c, 1);
        System.assertEquals(ol.Annualised_Income__c, 1201);
        System.assertEquals(ol.Balance__c, 3);
        System.assertEquals(ol.Estimated_Utilisation__c, 4);
        System.assertEquals(ol.Existing_Facility_Balance__c, 5);
        System.assertEquals(ol.Income_this_Year__c, 1);
        System.assertEquals(ol.Net_Facility_Balance__c, 7);
        System.assertEquals(ol.Margin__c, 8);
        System.assertEquals(ol.New_Facility__c, 1201);
        System.assertEquals(ol.New_Facility_Balance__c, 10);
        System.assertEquals(ol.ROEC__c, 11);
        System.assertEquals(ol.RoRWA__c, 12);
        System.assertEquals(ol.Terms_Years__c, 13);
        System.assertEquals(ol.Recurring_Fees_Period__c, 'Monthly');
        System.assertEquals(ol.Recurring_Fees__c, 100);		
        }
        
        
    }
}