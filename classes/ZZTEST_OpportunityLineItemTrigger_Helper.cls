/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for OpportunityLineItemTrigger_Helper
*                 Tests executed:
*                 1 - testCountProductTotalsBulk()
*                   Bulk test of count product totals method
*                 2 - testCountProductTotalsAnnuallyPeriod()
*                   Tests count product totals method with annually period
*                 3 - testCountProductTotalsSemiAnnuallyPeriod()
*                   Tests count product totals method with semi annually period
*                 4 - testCountProductTotalsQuarterlyPeriod()
*                   Tests count product totals method with quarterly period
*                 5 - testCountProductTotalsMonthlyPeriodWithDebtProduct()
*                   Tests count product totals method with monthly period and Debt product
*                 6 - testCountProductTotalsNullFields()
*                   Tests errors handling of count product totals method
*                 7 - testProductListValueDeletionAll()
*                   Tests product list changes while deleting all products on opportunity
*                 8 - testProductListValueDeletionSingle()
*                   Tests product list changes while deleting one products on opportunity
*                 9 - testProductListValueDeletion2remaining()
*                   Tests product list changes while 2 products remain
*                 10 - testPrepareStringListForProductChange()
*                   Tests chatter post data preparation when product changed
*                 11 - testPrepareStringListForBalanceChange()
*                   Tests chatter post data preparation when balance changed
*                 12 - testPrepareStringListForIncomeThisYChange()
*                   Tests chatter post data preparation when income this year changed
*                 13 - testPrepareStringListForAnnIncomeChange()
*                   Tests chatter post data preparation when annualised income changed
*                 14 - testGetMessageValueFromValue()
*                   Tests method returning value in param of blank value if param is null
*                 15 - testCreateChatterPostsAfterInsert()
*                   Tests creation of chatter post after oli insert
*                 16 - testCreateChatterPostsAfterDelete()
*                   Tests creation of chatter post after oli delete
*                 17 - testCreateChatterPostsAfterUpdateWithBalanceChange()
*                   Tests creation of chatter post after balance change
*                 18 - testCreateChatterPostsAfterUpdateWithProductChange()
*                   Tests creation of chatter post after product change
*                 19 - testCreateChatterPostsAfterUpdateWithSeveralChanges()
*                   Tests creation of chatter post after several changes on oli
*                 20 - testChatterPostingInsertBulk()
*                   Bulk test of oli insert
*                 21 - testChatterPostingDeleteBulk()
*                   Bulk test of oli delete
*                 22 - testChatterPostingUpdateBulk()
*                   Bulk test of oli update
*				  23 - testCrossSellDeposits()
*					Tests cross sell deposits when creating a payments opportunitylineitem
*
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 3.12.2015   Marek Cech         addeed testCountProductTotalsBulk, testCountProductTotalsAnnuallyPeriod,
*                                    testCountProsductTotalsSemiAnnuallyPeriod, testCountProductTotalsQuarterlyPeriod,
*                                    testCountProductTotalsMonthlyPeriodWithDebtProduct, testCountProductTotalsNullFields
* 07-Dec-2015 Mohsin Wadee US-0775
*                               
*                               Added call to ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem 
*                               in the following methods:
*
*                               testCountProductTotalsBulk
*                               testCountProductTotalsAnnuallyPeriod
*                               testCountProductTotalsSemiAnnuallyPeriod
*                               testCountProductTotalsQuarterlyPeriod
*                               testCountProductTotalsMonthlyPeriodWithDebtProduct
*                               testCountProductTotalsNullFields
*                               insertOliForCountProductTesting
*                               testProductListValueDeletionAll
*                               testProductListValueDeletionSingle
*                               testProductListValueDeletion2remaining
*                               testPrepareStringListForProductChange
*                               testCreateChatterPostsAfterInsert
*                               testCreateChatterPostsAfterDelete
*                               testCreateChatterPostsAfterUpdateWithBalanceChange
*                               testCreateChatterPostsAfterUpdateWithProductChange
*                               testCreateChatterPostsAfterUpdateWithSeveralChanges
*                               testChatterPostingInsertBulk
*                               testChatterPostingDeleteBulk
*                               testChatterPostingUpdateBulk
* 10-Dec-2015 Mohsin Wadee US-0775 
*       Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*       with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
* 22/01/2016  Marta Malinowska  modified testCountProductTotalsNullFields, testCountProductTotalsMonthlyPeriodWithDebtProduct
*								to calculate Once-off fees with new formula
* 08-Jul-2016	Mohsin Wadee	Commented out asserts in methods testCreateChatterPostsAfterInsert(),
*								testChatterPostingUpdateBulk(), testChatterPostingInsertBulk().
* 31-May-2017   Dino Scarcella  Included checks that ProductLevel2+3 Lists are correct in testProductListValueDeletion2remaining
* -------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class ZZTEST_OpportunityLineItemTrigger_Helper {

    private static final String SOMETHING = 'something';
    private static final String MONTHLY = OpportunityLineItemTrigger_Helper.MONTHLY;
    private static final String QUARTERLY = OpportunityLineItemTrigger_Helper.QUARTERLY;
    private static final String SEMI_ANNUALLY = OpportunityLineItemTrigger_Helper.SEMI_ANNUALLY;
    private static final String ANNUALLY = OpportunityLineItemTrigger_Helper.ANNUALLY;
    private static final String DEBT = OpportunityLineItemTrigger_Helper.DEBT;
    
    private class TestException extends Exception {}

    public static testMethod void testCountProductTotalsBulk() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {

            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            //opportunities preparation
            List<Opportunity> optys = new List<Opportunity>();
            for (Integer i = 0; i < 20; i++) {
                Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opty.CloseDate = Date.newInstance(Date.today().year(), 10, 31);
                optys.add(opty);
            }
            INSERT optys;
                    
            //opportunity products preparation
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            for (Integer i = 0; i < 20; i++) {
                OpportunityLineItem oli1 = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
                oli1.OpportunityId = optys[i].Id;
                olis.add(oli1);
            }
            
            Test.startTest();
            try {
                INSERT olis;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            Test.stopTest();
            
            List<OpportunityLineItem> results = [
                SELECT Recurring_Fees_Period__c, Margin__c, Estimated_Utilisation__c, Recurring_Fees__c, Balance__c, Fees__c,
                    Arranging_Fee__c, Participation_Fee__c, Agency_Fee__c, Committment_Fee__c, Co_ordination_Fee__c,
                    Annualised_Income__c, New_Facility__c, Income_this_Year__c
                FROM OpportunityLineItem
            ];
            System.assertEquals(20, results.size());
            
            for (OpportunityLineItem result: results) {
                System.assertEquals(MONTHLY, result.Recurring_Fees_Period__c);
                System.assertEquals(1, result.Margin__c);
                System.assertEquals(2, result.Estimated_Utilisation__c);
                System.assertEquals(3, result.Recurring_Fees__c);
                System.assertEquals(4, result.Balance__c);
                System.assertEquals(5, result.Fees__c);
                System.assertEquals(6, result.Arranging_Fee__c);
                System.assertEquals(7, result.Participation_Fee__c);
                System.assertEquals(8, result.Agency_Fee__c);
                System.assertEquals(9, result.Committment_Fee__c);
                System.assertEquals(0, result.Co_ordination_Fee__c);
                System.assertEquals(41, Math.round(result.Annualised_Income__c));
                System.assertEquals(41, Math.round(result.New_Facility__c));
                System.assertEquals(11, Math.round(result.Income_this_Year__c));
            }   
        }
    }
    
    public static testMethod void testCountProductTotalsAnnuallyPeriod() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);        

            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();        
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            opty.CloseDate = Date.newInstance(Date.today().year(), 10, 31);
            UPDATE opty;
            
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.Recurring_Fees_Period__c = ANNUALLY;
            
            try {
                INSERT oli;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            
            List<OpportunityLineItem> results = [
                SELECT Recurring_Fees_Period__c, Margin__c, Estimated_Utilisation__c, Recurring_Fees__c, Balance__c, Fees__c,
                    Arranging_Fee__c, Participation_Fee__c, Agency_Fee__c, Committment_Fee__c, Co_ordination_Fee__c,
                    Annualised_Income__c, New_Facility__c, Income_this_Year__c
                FROM OpportunityLineItem
                WHERE Id = :oli.Id
            ];
            System.assertEquals(1, results.size());
            
            OpportunityLineItem result = results[0];
            System.assertEquals(ANNUALLY, result.Recurring_Fees_Period__c);
            System.assertEquals(1, result.Margin__c);
            System.assertEquals(2, result.Estimated_Utilisation__c);
            System.assertEquals(3, result.Recurring_Fees__c);
            System.assertEquals(4, result.Balance__c);
            System.assertEquals(5, result.Fees__c);
            System.assertEquals(6, result.Arranging_Fee__c);
            System.assertEquals(7, result.Participation_Fee__c);
            System.assertEquals(8, result.Agency_Fee__c);
            System.assertEquals(9, result.Committment_Fee__c);
            System.assertEquals(0, result.Co_ordination_Fee__c);
            System.assertEquals(8, Math.round(result.Annualised_Income__c));
            System.assertEquals(8, Math.round(result.New_Facility__c));
            System.assertEquals(5, Math.round(result.Income_this_Year__c));
        }
    }
    
    public static testMethod void testCountProductTotalsSemiAnnuallyPeriod() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
            opty.CloseDate = Date.newInstance(Date.today().year(), 10, 31);
            UPDATE opty;
            
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.Recurring_Fees_Period__c = SEMI_ANNUALLY;
            
            try {
                INSERT oli;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            
            List<OpportunityLineItem> results = [
                SELECT Recurring_Fees_Period__c, Margin__c, Estimated_Utilisation__c, Recurring_Fees__c, Balance__c, Fees__c,
                    Arranging_Fee__c, Participation_Fee__c, Agency_Fee__c, Committment_Fee__c, Co_ordination_Fee__c,
                    Annualised_Income__c, New_Facility__c, Income_this_Year__c
                FROM OpportunityLineItem
                WHERE Id = :oli.Id
            ];
            System.assertEquals(1, results.size());
            
            OpportunityLineItem result = results[0];
            System.assertEquals(SEMI_ANNUALLY, result.Recurring_Fees_Period__c);
            System.assertEquals(1, result.Margin__c);
            System.assertEquals(2, result.Estimated_Utilisation__c);
            System.assertEquals(3, result.Recurring_Fees__c);
            System.assertEquals(4, result.Balance__c);
            System.assertEquals(5, result.Fees__c);
            System.assertEquals(6, result.Arranging_Fee__c);
            System.assertEquals(7, result.Participation_Fee__c);
            System.assertEquals(8, result.Agency_Fee__c);
            System.assertEquals(9, result.Committment_Fee__c);
            System.assertEquals(0, result.Co_ordination_Fee__c);
            System.assertEquals(11, Math.round(result.Annualised_Income__c));
            System.assertEquals(11, Math.round(result.New_Facility__c));
            System.assertEquals(6, Math.round(result.Income_this_Year__c));
        }
    }
    
    public static testMethod void testCountProductTotalsQuarterlyPeriod() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
            opty.CloseDate = Date.newInstance(Date.today().year(), 10, 31);
            UPDATE opty;
            
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.Recurring_Fees_Period__c = QUARTERLY;
            
            try {
                INSERT oli;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            
            List<OpportunityLineItem> results = [
                SELECT Recurring_Fees_Period__c, Margin__c, Estimated_Utilisation__c, Recurring_Fees__c, Balance__c, Fees__c,
                    Arranging_Fee__c, Participation_Fee__c, Agency_Fee__c, Committment_Fee__c, Co_ordination_Fee__c,
                    Annualised_Income__c, New_Facility__c, Income_this_Year__c
                FROM OpportunityLineItem
                WHERE Id = :oli.Id
            ];
            System.assertEquals(1, results.size());
            
            OpportunityLineItem result = results[0];
            System.assertEquals(QUARTERLY, result.Recurring_Fees_Period__c);
            System.assertEquals(1, result.Margin__c);
            System.assertEquals(2, result.Estimated_Utilisation__c);
            System.assertEquals(3, result.Recurring_Fees__c);
            System.assertEquals(4, result.Balance__c);
            System.assertEquals(5, result.Fees__c);
            System.assertEquals(6, result.Arranging_Fee__c);
            System.assertEquals(7, result.Participation_Fee__c);
            System.assertEquals(8, result.Agency_Fee__c);
            System.assertEquals(9, result.Committment_Fee__c);
            System.assertEquals(0, result.Co_ordination_Fee__c);
            System.assertEquals(17, Math.round(result.Annualised_Income__c));
            System.assertEquals(17, Math.round(result.New_Facility__c));
            System.assertEquals(7, Math.round(result.Income_this_Year__c));
        }
    }

    public static testMethod void testCountProductTotalsMonthlyPeriodWithDebtProduct() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
            opty.CloseDate = Date.newInstance(Date.today().year(), 10, 31);
            UPDATE opty;
            
            ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
            Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
                dataContainer);
            product.Family = DEBT;
            UPDATE product;
            
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.Recurring_Fees_Period__c = MONTHLY;
            oli.Terms_Years__c = 2;
            
            try {
                INSERT oli;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            
            List<OpportunityLineItem> results = [
                SELECT Recurring_Fees_Period__c, Margin__c, Estimated_Utilisation__c, Recurring_Fees__c, Balance__c, Fees__c,
                    Hold_Size__c, Arranging_Fee__c, Other_Fees__c, Participation_Fee__c, Agency_Fee__c, Committment_Fee__c, 
                	Co_ordination_Fee__c, Annualised_Income__c, New_Facility__c, Income_this_Year__c
                FROM OpportunityLineItem
                WHERE Id = :oli.Id
            ];
            System.assertEquals(1, results.size());
            
            OpportunityLineItem result = results[0];
            System.assertEquals(MONTHLY, result.Recurring_Fees_Period__c);
            System.assertEquals(1, result.Margin__c);
            System.assertEquals(2, result.Estimated_Utilisation__c);
            System.assertEquals(3, result.Recurring_Fees__c);
            System.assertEquals(4, result.Balance__c);
            System.assertEquals(25, result.Fees__c);
            System.assertEquals(100, result.Hold_Size__c);
            System.assertEquals(6, result.Arranging_Fee__c);
            System.assertEquals(4, result.Other_Fees__c);
            System.assertEquals(7, result.Participation_Fee__c);
            System.assertEquals(8, result.Agency_Fee__c);
            System.assertEquals(9, result.Committment_Fee__c);
            System.assertEquals(0, result.Co_ordination_Fee__c);
            System.assertEquals(61, Math.round(result.Annualised_Income__c));
            System.assertEquals(61, Math.round(result.New_Facility__c));
            System.assertEquals(31, Math.round(result.Income_this_Year__c));
        }
    }
    
    public static testMethod void testCountProductTotalsNullFields() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            
            ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
            Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
                dataContainer);
            product.Family = DEBT;
            UPDATE product;
            
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli = prepareOliForCountProductTesting(dataContainer, oppLineItemFactory);
            oli.Margin__c = null;
            oli.Estimated_Utilisation__c = null;
            oli.Recurring_Fees_Period__c = null;
            oli.Recurring_Fees__c = null;
            oli.Balance__c = null;
            oli.Fees__c = null;
            oli.Hold_Size__c = null;
            oli.Arranging_Fee__c = null;
            oli.Other_Fees__c = null;
            oli.Participation_Fee__c = null;
            oli.Agency_Fee__c = null;
            oli.Committment_Fee__c = null;
            oli.Co_ordination_Fee__c = null;
            oli.Terms_Years__c = 3;
            oli.Arranging_Fee_Deferred__c = false;
            oli.Other_Fees_Deferred__c = false;
            oli.Participation_Fee_Deferred__c = false;
            oli.Agency_Fee_Deferred__c = false;
            oli.Coordination_Fee_Deferred__c = false;
            
            try {
                INSERT oli;
                throw new TestException();
            } catch (Exception e) {
                System.assertEquals(true, e instanceof TestException);
            }
            
            List<OpportunityLineItem> results = [
                SELECT Margin__c, Estimated_Utilisation__c, Recurring_Fees_Period__c, Recurring_Fees__c, Balance__c,
                    Fees__c, Hold_Size__c, Arranging_Fee__c, Other_Fees__c, Participation_Fee__c, Agency_Fee__c, 
                	Committment_Fee__c, Co_ordination_Fee__c
                FROM OpportunityLineItem
            ];
            
            System.assertEquals(1, results.size());
            OpportunityLineItem result = results[0];
            
            System.assertEquals(0, result.Margin__c);
            System.assertEquals(0, result.Estimated_Utilisation__c);
            System.assertEquals('Monthly', result.Recurring_Fees_Period__c );
            System.assertEquals(0, result.Recurring_Fees__c);
            System.assertEquals(0, result.Balance__c);
            System.assertEquals(0, result.Fees__c);
            System.assertEquals(0, result.Hold_Size__c);
            System.assertEquals(0, result.Arranging_Fee__c);
            System.assertEquals(0, result.Other_Fees__c);
            System.assertEquals(0, result.Participation_Fee__c);
            System.assertEquals(0, result.Agency_Fee__c);
            System.assertEquals(0, result.Committment_Fee__c);
            System.assertEquals(0, result.Co_ordination_Fee__c);
        }
    }

    public static testMethod void testProductListValueDeletionAll() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

            // preparing data for bulk test
            for(Integer i=0; i<=10; i++){
                oppLineItems.add(oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer));
            }

            Test.startTest();
            // bulk test
            INSERT oppLineItems;

            List<Opportunity> oppToCheck = [SELECT Id, Productlist__c FROM Opportunity];
            System.assertEquals('Karel Kakadu', oppToCheck[0].Productlist__c);

            DELETE oppLineItems;
            Test.stopTest();

            oppToCheck = [SELECT Id, Productlist__c FROM Opportunity];
            System.assertEquals(null, oppToCheck[0].Productlist__c);
        }
    }

    public static testMethod void testProductListValueDeletionSingle() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

            // preparing second product
            Product2 p = new Product2();
            p.Name = 'Advisory';
            p.IsActive = true;
            p.ProductCode = 'Advisory';
            p.Description = 'Professional services';
            p.CurrencyIsoCode = 'GBP';
            INSERT p;

            // preparing pricebook entry
            PricebookEntry pe = new PricebookEntry();
            pe.IsActive = true;
            pe.Pricebook2Id = Test.getStandardPricebookId();
            pe.UnitPrice = 10000;
            pe.UseStandardPrice = false;
            pe.Product2Id = p.Id;
            pe.Product2 = p;
            INSERT pe;

            // creating OpportunityLineItems with standard product
            for(Integer i=0; i<=1; i++){
                oppLineItems.add(oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer));
            }
            oppLineItems[1].PricebookEntryId = pe.Id;

            Test.startTest();           

            INSERT oppLineItems;

            List<Opportunity> oppToCheck = [SELECT Id, Productlist__c FROM Opportunity];
            System.assertEquals('Karel Kakadu Advisory', oppToCheck[0].Productlist__c);

            DELETE oppLineItems[1];
            
            Test.stopTest();

            oppToCheck = [SELECT Id, Productlist__c FROM Opportunity];
            System.assertEquals('Karel Kakadu', oppToCheck[0].Productlist__c);
        }
    }   

    public static testMethod void testProductListValueDeletion2remaining() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

            // preparing second product
            Product2 p = new Product2();
            p.Name = 'Advisory';
            p.IsActive = true;
            p.ProductCode = 'Advisory';
            p.Description = 'Professional services';
            p.CurrencyIsoCode = 'GBP';
            INSERT p;

            // preparing pricebook entry
            PricebookEntry pe = new PricebookEntry();
            pe.IsActive = true;
            pe.Pricebook2Id = Test.getStandardPricebookId();
            pe.UnitPrice = 10000;
            pe.UseStandardPrice = false;
            pe.Product2Id = p.Id;
            pe.Product2 = p;
            INSERT pe;

            // preparing third product
            Product2 p2 = new Product2();
            p2.Name = 'lamelame';
            p2.IsActive = true;
            p2.ProductCode = 'lamelame';
            p2.Description = 'Professional services22';
            p2.CurrencyIsoCode = 'GBP';
            INSERT p2;

            // preparing pricebook entry #2
            PricebookEntry pe2 = new PricebookEntry();
            pe2.IsActive = true;
            pe2.Pricebook2Id = Test.getStandardPricebookId();
            pe2.UnitPrice = 10000;
            pe2.UseStandardPrice = false;
            pe2.Product2Id = p2.Id;
            pe2.Product2 = p2;
            INSERT pe2;

            // creating OpportunityLineItems with standard product
            for(Integer i=0; i<=3; i++){
                oppLineItems.add(oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer));
            }
            oppLineItems[0].PricebookEntryId = pe.Id;
            oppLineItems[1].PricebookEntryId = pe2.Id;

            Test.startTest();           

            INSERT oppLineItems;

            List<Opportunity> oppToCheck = [SELECT Id, Productlist__c, ProductLevel2List__c, ProductLevel3List__c FROM Opportunity];
            System.assertEquals('Advisory lamelame Karel Kakadu', oppToCheck[0].Productlist__c);
            // Test Level2 and Level3 Lists are correct (only Karel Kakadu Product has Level 2 + 3)
            System.assertEquals('Karel Kakadu lvl 2', oppToCheck[0].ProductLevel2List__c);
            System.assertEquals('Karel Kakadu lvl 3', oppToCheck[0].ProductLevel3List__c);
			
            DELETE oppLineItems[1];
            
            Test.stopTest();
            oppToCheck = [SELECT Id, Productlist__c FROM Opportunity];
            System.assertEquals(true, oppToCheck[0].Productlist__c.contains('Karel Kakadu'));
            System.assertEquals(true, oppToCheck[0].Productlist__c.contains('Advisory'));
        }
    }
    
    public static testMethod void testPrepareStringListForProductChange() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Product_Level_3__c = null;
            
            OpportunityLineItem oli2 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>{oli1, oli2};
            INSERT olis;
            
            List<OpportunityLineItem> oli2WithLvl3Name = [SELECT Product_Level_3_Name__c FROM OpportunityLineItem WHERE Id = :oli2.Id];
            System.assertEquals(1, oli2WithLvl3Name.size());
            
            Test.startTest();
            List<String> result = OpportunityLineItemTrigger_Helper.prepareStringListForProductChange(oli1, oli2WithLvl3Name[0]);
            Test.stopTest();
            
            System.assertNotEquals(null, result);
            System.assertEquals(9, result.size());
            System.assertEquals(Label.msg_ProductUpdated, result[0]);
            System.assertEquals(' ', result[1]);
            System.assertEquals(oli2WithLvl3Name[0].Product_Level_3_Name__c, result[2]);
            System.assertEquals(' ', result[3]);
            System.assertEquals(Label.lbl_to, result[4]);
            System.assertEquals(' ', result[5]);
            System.assertEquals(Label.lbl_BlankValue, result[6]);
            System.assertEquals('.', result[7]);
            System.assertEquals(' ', result[8]);
        }
    }
    
    public static testMethod void testPrepareStringListForBalanceChange() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Balance__c = 100000;
            
            OpportunityLineItem oli2 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli2.Balance__c = 200000;
            
            Test.startTest();
            List<String> result = OpportunityLineItemTrigger_Helper.prepareStringListForBalanceChange(oli1, oli2);
            Test.stopTest();
            
            System.assertNotEquals(null, result);
            System.assertEquals(9, result.size());
            System.assertEquals(Label.msg_BalanceUpdated, result[0]);
            System.assertEquals(' ', result[1]);
            System.assertEquals(String.valueOf(oli2.Balance__c), result[2]);
            System.assertEquals(' ', result[3]);
            System.assertEquals(Label.lbl_to, result[4]);
            System.assertEquals(' ', result[5]);
            System.assertEquals(String.valueOf(oli1.Balance__c), result[6]);
            System.assertEquals('.', result[7]);
            System.assertEquals(' ', result[8]);
        }
    }
    
    public static testMethod void testPrepareStringListForIncomeThisYChange() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Income_this_Year__c = 100000;
            
            OpportunityLineItem oli2 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli2.Income_this_Year__c = 200000;
            
            Test.startTest();
            List<String> result = OpportunityLineItemTrigger_Helper.prepareStringListForIncomeThisYChange(oli1, oli2);
            Test.stopTest();
            
            System.assertNotEquals(null, result);
            System.assertEquals(9, result.size());
            System.assertEquals(Label.msg_IncomeThisYearUpdated, result[0]);
            System.assertEquals(' ', result[1]);
            System.assertEquals(String.valueOf(oli2.Income_this_Year__c), result[2]);
            System.assertEquals(' ', result[3]);
            System.assertEquals(Label.lbl_to, result[4]);
            System.assertEquals(' ', result[5]);
            System.assertEquals(String.valueOf(oli1.Income_this_Year__c), result[6]);
            System.assertEquals('.', result[7]);
            System.assertEquals(' ', result[8]);
        }
    }
    
    public static testMethod void testPrepareStringListForAnnIncomeChange() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Annualised_Income__c = 100000;
            
            OpportunityLineItem oli2 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli2.Annualised_Income__c = 200000;
            
            Test.startTest();
            List<String> result = OpportunityLineItemTrigger_Helper.prepareStringListForAnnIncomeChange(oli1, oli2);
            Test.stopTest();
            
            System.assertNotEquals(null, result);
            System.assertEquals(9, result.size());
            System.assertEquals(Label.msg_AnnIncomeUpdated, result[0]);
            System.assertEquals(' ', result[1]);
            System.assertEquals(String.valueOf(oli2.Annualised_Income__c), result[2]);
            System.assertEquals(' ', result[3]);
            System.assertEquals(Label.lbl_to, result[4]);
            System.assertEquals(' ', result[5]);
            System.assertEquals(String.valueOf(oli1.Annualised_Income__c), result[6]);
            System.assertEquals('.', result[7]);
            System.assertEquals(' ', result[8]);
        }
    }
    
    public static testMethod void testGetMessageValueFromValue() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {        
            Test.startTest();
            String result1 = OpportunityLineItemTrigger_Helper.getMessageValueFromValue(SOMETHING);
            String result2 = OpportunityLineItemTrigger_Helper.getMessageValueFromValue(null);
            Test.stopTest();
            
            System.assertEquals(SOMETHING, result1);
            System.assertEquals(Label.lbl_BlankValue, result2);
        }
    }
    
    /*
    public static testMethod void testCreateChatterPostsAfterInsert() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
            
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            
            Test.startTest();
            
            INSERT oli1;
            Test.stopTest();
            
            List<FeedItem> result = [SELECT Type, ParentId, Title, LinkUrl, Body FROM FeedItem];
            List<OpportunityLineItem> expectedProductName = [SELECT Product_Name__c FROM OpportunityLineItem WHERE Id = :oli1.Id];
            
            //System.assertEquals(1, expectedProductName.size());        
            //System.assertEquals(1, result.size());
            //System.assertEquals('LinkPost', result[0].Type);
            //System.assertEquals(oli1.OpportunityId, result[0].ParentId);
            //System.assertEquals(expectedProductName[0].Product_Name__c, result[0].Title);
            //System.assertEquals('/' + oli1.Id, result[0].LinkUrl);
            //System.assertEquals(Label.msg_ProductAdded, result[0].Body);
        }
    }
    
    public static testMethod void testCreateChatterPostsAfterDelete() {
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        OpportunityLineItem oli1 = oppLineItemFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        
        //deleting chatter post created after insert
        List<FeedItem> fisToDelete = [SELECT Id FROM FeedItem];
        DELETE fisToDelete;
        
        List<OpportunityLineItem> expectedProductName = [SELECT Product_Name__c FROM OpportunityLineItem WHERE Id = :oli1.Id];
        System.assertEquals(1, expectedProductName.size());
        
        Test.startTest();
        DELETE oli1;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT ParentId, Body FROM FeedItem WHERE Type = 'TextPost'];
        System.assertEquals(1, result.size());
        System.assertEquals(oli1.OpportunityId, result[0].ParentId);
        System.assertEquals(Label.msg_ProductDeleted + ' ' + expectedProductName[0].Product_Name__c, result[0].Body);
    }
    
    public static testMethod void testCreateChatterPostsAfterUpdateWithBalanceChange() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        oli1.Balance__c = 1000;
        INSERT oli1;
        
        //deleting chatter post created after insert
        List<FeedItem> fisToDelete = [SELECT Id FROM FeedItem];
        DELETE fisToDelete;
        
        List<OpportunityLineItem> expectedProductName = [SELECT Product_Name__c FROM OpportunityLineItem WHERE Id = :oli1.Id];
        System.assertEquals(1, expectedProductName.size());
        
        //change to update
        oli1.Balance__c = 2000;
        
        Test.startTest();
        UPDATE oli1;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Type, ParentId, Title, LinkUrl, Body FROM FeedItem];
        
        System.assertEquals(1, result.size());
        System.assertEquals('LinkPost', result[0].Type);
        System.assertEquals(oli1.OpportunityId, result[0].ParentId);
        System.assertEquals(expectedProductName[0].Product_Name__c, result[0].Title);
        System.assertEquals('/' + oli1.Id, result[0].LinkUrl);
        
        String expectedBody = Label.msg_BalanceUpdated + ' 1000 ' + Label.lbl_to + ' 2000.'; 
        System.assertEquals(expectedBody, result[0].Body);
    }
    
    public static testMethod void testCreateChatterPostsAfterUpdateWithProductChange() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        
        OpportunityLineItem oli1 = oppLineItemFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
        
        //deleting chatter post created after insert
        List<FeedItem> fisToDelete = [SELECT Id FROM FeedItem];
        DELETE fisToDelete;
        
        List<OpportunityLineItem> expectedProductName = [SELECT Product_Name__c FROM OpportunityLineItem WHERE Id = :oli1.Id];
        System.assertEquals(1, expectedProductName.size());
        
        //change to update
        oli1.Product_Level_3__c = null;
        
        Test.startTest();
        UPDATE oli1;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Type, ParentId, Title, LinkUrl, Body FROM FeedItem];
        
        System.assertEquals(1, result.size());
        System.assertEquals('LinkPost', result[0].Type);
        System.assertEquals(oli1.OpportunityId, result[0].ParentId);
        System.assertEquals(expectedProductName[0].Product_Name__c, result[0].Title);
        System.assertEquals('/' + oli1.Id, result[0].LinkUrl);
        
        String expectedBody = Label.msg_ProductUpdated + ' ' + productLvl31.Name + ' ' + Label.lbl_to + ' ' + Label.lbl_BlankValue + '.'; 
        System.assertEquals(expectedBody, result[0].Body);
    }
    
    public static testMethod void testCreateChatterPostsAfterUpdateWithSeveralChanges() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        
        //preparing opportunity product
        OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        oli1.Balance__c = 150000;
        INSERT oli1;
        
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
        
        //deleting chatter post created after insert
        List<FeedItem> fisToDelete = [SELECT Id FROM FeedItem];
        DELETE fisToDelete;
        
        List<OpportunityLineItem> expectedProductName = [SELECT Product_Name__c FROM OpportunityLineItem WHERE Id = :oli1.Id];
        System.assertEquals(1, expectedProductName.size());
        
        //changes to update
        oli1.Product_Level_3__c = null;
        oli1.Balance__c = 30000;
        oli1.Fees__c = 100;
        
        Test.startTest();
        UPDATE oli1;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Type, ParentId, Title, LinkUrl, Body FROM FeedItem];
        
        System.assertEquals(1, result.size());
        System.assertEquals('LinkPost', result[0].Type);
        System.assertEquals(oli1.OpportunityId, result[0].ParentId);
        System.assertEquals(expectedProductName[0].Product_Name__c, result[0].Title);
        System.assertEquals('/' + oli1.Id, result[0].LinkUrl);
        
        String expectedBody = 
        Label.msg_ProductUpdated + ' ' + productLvl31.Name + ' ' + Label.lbl_to + ' ' + Label.lbl_BlankValue + '. ' +
        Label.msg_BalanceUpdated + ' 150000 ' + Label.lbl_to + ' 30000. ' +
        Label.msg_IncomeThisYearUpdated + ' 0 ' + Label.lbl_to + ' 100. ' +
        Label.msg_AnnIncomeUpdated + ' 0 ' + Label.lbl_to + ' 100.';
        System.assertEquals(expectedBody, result[0].Body);
    }
    
    public static testMethod void testChatterPostingInsertBulk() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        //opportunities preparation
        List<Opportunity> optys = new List<Opportunity>();
        for(Integer i = 0; i < 200; i++) {
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            optys.add(opty);
        }
        INSERT optys;
                
        //opportunity products preparation
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(Integer i = 0; i < 200; i++) {
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Balance__c = 150000;
            oli1.OpportunityId = optys[i].Id;
            olis.add(oli1);
        }
        
        Test.startTest();
        INSERT olis;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Id FROM FeedItem LIMIT 300];
        //System.assertEquals(200, result.size());
    }
    
    public static testMethod void testChatterPostingDeleteBulk() {
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        //opportunities preparation
        List<Opportunity> optys = new List<Opportunity>();
        for(Integer i = 0; i < 40; i++) {
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            optys.add(opty);
        }
        INSERT optys;
                
        //opportunity products preparation
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 40; i++) {
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Balance__c = 150000;
            oli1.OpportunityId = optys[i].Id;
            olis.add(oli1);
        }
        INSERT olis;
        
        //deleting chatter post created after insert
        List<FeedItem> fisToDelete = [SELECT Id FROM FeedItem];
        DELETE fisToDelete;
        
        Test.startTest();
        DELETE olis;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Id FROM FeedItem LIMIT 300];
        System.assertEquals(200, result.size());
    }
    
    public static testMethod void testChatterPostingUpdateBulk() {
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        //opportunities preparation
        List<Opportunity> optys = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            optys.add(opty);
        }
        INSERT optys;
                
        //opportunity products preparation
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(Integer i = 0; i < 200; i++) {
            OpportunityLineItem oli1 = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            oli1.Balance__c = 150000;
            oli1.OpportunityId = optys[i].Id;
            oli1.Income_this_Year__c = 321;
            oli1.Annualised_Income__c = 654;
            olis.add(oli1);
        }
        INSERT olis;
        
        //deleting inserted chatter posts
        List<FeedItem> fis = [SELECT Id FROM FeedItem LIMIT 300];
        DELETE fis;
        
        //changing opportunity products to update them
        for(OpportunityLineItem oli: olis) {
            oli.Balance__c = 210000;
            oli.Product_Level_3__c = null;
            oli.Income_this_Year__c = 333;
            oli.Annualised_Income__c = 666;
        }
        
        Test.startTest();
        UPDATE olis;
        Test.stopTest();
        
        List<FeedItem> result = [SELECT Id FROM FeedItem LIMIT 300];
        //System.assertEquals(200, result.size());
    }
    */
    
    public static OpportunityLineItem prepareOliForCountProductTesting(ZZTEST_DataContainer dataContainer, ZZTEST_F_OpportunityLineItem oppLineItemFactory) {
        OpportunityLineItem oli = oppLineItemFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        
        oli.Recurring_Fees_Period__c = MONTHLY;
        oli.Margin__c = 1;
        oli.Estimated_Utilisation__c = 2;
        oli.Recurring_Fees__c = 3;
        oli.Balance__c = 4;
        oli.Fees__c = 5;
        oli.Hold_Size__c = 100;
        oli.Arranging_Fee__c = 6;
        oli.Other_Fees__c = 4;
        oli.Participation_Fee__c = 7;
        oli.Agency_Fee__c = 8;
        oli.Committment_Fee__c = 9;
        oli.Co_ordination_Fee__c = 0;
        oli.Arranging_Fee_Deferred__c = false;
        oli.Other_Fees_Deferred__c = false;
        oli.Participation_Fee_Deferred__c = false;
        oli.Agency_Fee_Deferred__c = false;
        oli.Coordination_Fee_Deferred__c = false;

        return oli;
    }
    
    public static testMethod void testCrossSellDeposits() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunityLineItem oppLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        ZZTEST_F_Product_Level_3 productLevel3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
        
        System.runAs(u) {
            PrivateProducts__c pp = new PrivateProducts__c(PrivateProduct1__c='Advisory', PrivateProduct2__c='Financial Solutions Group', PrivateProduct3__c='Global Finance', 
                                                           PrivateProduct4__c='Loan Portfolio (IB)', PrivateProduct5__c='Loans Syndication – Fees', PrivateProduct6__c='Money Market Short Term Lending (IB)');
     		insert pp;
            
            Product_Level_3__c currentAccountDepositProduct = productLevel3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.CURRENT_ACCOUNT_DEPOSIT_PRODUCT, dataContainer);
            OpportunityLineItem oli1 = oppLineItemFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DOMESTIC_PAYMENTS_OPPORTUNITY_LINE_ITEM, dataContainer);
            
            Test.startTest();
            List<Opportunity> newcrosssellopp = [SELECT Id FROM Opportunity WHERE Name LIKE 'Deposit Cross-Sell - %'];
            System.assertEquals(1, newcrosssellopp.size());
            Test.stopTest();
        }
    }
}