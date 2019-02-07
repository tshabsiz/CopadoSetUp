/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
* @Description:   Unit Tests for RPFCalculator
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_RPFCalculator {
	public static testMethod void testRPFValidations() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);    
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
			
            Test.startTest();
            
			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			INSERT sampleProduct;

			PricebookEntry priceBookEntry = pricebookEntryFactory.getProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, dataContainer);
			priceBookEntry.Product2Id = sampleProduct.Id;
			INSERT priceBookEntry;
		
            oli1.DrawPercentageCurrentYear__c = 10;
            oli1.DrawPercentageNextYear__c = 30;
            oli1.StartDate__c = Date.newInstance(2017, 8, 1);
            oli1.Hold_Size__c = 520000000;
            oli1.Margin__c = 3.75;
            oli1.Committment_Fee__c = 0.75;
            oli1.Arranging_Fee__c = 0.29;
            oli1.Arranging_Fee_Deferred__c = false;
            UPDATE oli1;
            
            Test.stopTest();
            
			PageReference RPFCalculator = Page.RPFCalculator;
			Test.setCurrentPage(RPFCalculator);
		
            RPFCalculator controller = new RPFCalculator();
            System.assertEquals(true, controller.renderErrorMessage); // No oli query string, render error message
            
			ApexPages.currentPage().getParameters().put('oliId', oli1.Id);
			controller = new RPFCalculator();
            
            System.assertEquals(true, controller.renderErrorMessage); // No term years, render error message
        }
    }
    
    public static testMethod void testUtilisationAssumptionChange() {
    	//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);    
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
            
            Test.startTest();
            
			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			INSERT sampleProduct;

			PricebookEntry priceBookEntry = pricebookEntryFactory.getProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, dataContainer);
			priceBookEntry.Product2Id = sampleProduct.Id;
			INSERT priceBookEntry;
		
            oli1.DrawPercentageCurrentYear__c = 10;
            oli1.DrawPercentageNextYear__c = 30;
            oli1.StartDate__c = Date.newInstance(2017, 8, 1);
            oli1.Hold_Size__c = 520000000;
            oli1.Margin__c = 3.75;
            oli1.Committment_Fee__c = 0.75;
            oli1.Arranging_Fee__c = 0.29;
            oli1.Arranging_Fee_Deferred__c = false;
            oli1.Terms_Years__c = 7;
            UPDATE oli1;
            
            Test.stopTest();
            
			PageReference RPFCalculator = Page.RPFCalculator;
			Test.setCurrentPage(RPFCalculator);
		
            RPFCalculator controller = new RPFCalculator();            
			ApexPages.currentPage().getParameters().put('oliId', oli1.Id);
            controller = new RPFCalculator();
            controller.reCalculate();
            
            // Test Utilisation Assumption Change
            controller.MonthChange = 'Aug 2017';
            controller.AmountChange = 13000000;
            List<RPFCalculation__c> RPFCs = [SELECT Id FROM RPFCalculation__c WHERE OpportunityLineItemId__c =: String.ValueOf(oli1.Id) AND Month__c = 'Aug 2017'];
            List<Drawdowns__c> DDs = [SELECT Id FROM Drawdowns__c WHERE Opportunity__c =: String.ValueOf(oli1.OpportunityId)];
            System.assertEquals(0, RPFCs.size());
            System.assertEquals(17, DDs.size());
            controller.changeUA();
            RPFCs = [SELECT Id FROM RPFCalculation__c WHERE OpportunityLineItemId__c =: String.ValueOf(oli1.Id) AND Month__c = 'Aug 2017'];
            System.assertEquals(1, RPFCs.size());
            
            // Test constants for Row Headers and Column Headers
            System.assertEquals(6, controller.RPFRows.size());
            System.assertEquals(1, controller.UARows.size());
		}
	}
    
    public static testMethod void testArrangingFeeChange() {
    	//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);    
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
            
            Test.startTest();
            
			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			INSERT sampleProduct;

			PricebookEntry priceBookEntry = pricebookEntryFactory.getProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, dataContainer);
			priceBookEntry.Product2Id = sampleProduct.Id;
			INSERT priceBookEntry;
		
            oli1.DrawPercentageCurrentYear__c = 10;
            oli1.DrawPercentageNextYear__c = 30;
            oli1.StartDate__c = Date.newInstance(2017, 8, 1);
            oli1.Hold_Size__c = 520000000;
            oli1.Margin__c = 3.75;
            oli1.Committment_Fee__c = 0.75;
            oli1.Arranging_Fee__c = 0.29;
            oli1.Arranging_Fee_Deferred__c = false;
            oli1.Terms_Years__c = 7;
            UPDATE oli1;
            
            Test.stopTest();
            
			PageReference RPFCalculator = Page.RPFCalculator;
			Test.setCurrentPage(RPFCalculator);
		
            RPFCalculator controller = new RPFCalculator();            
			ApexPages.currentPage().getParameters().put('oliId', oli1.Id);
            controller = new RPFCalculator();
            controller.reCalculate();
            
            // Test Arranging Fee Change
            controller.ArrangingFeeDeferredAmount = 1258000;
            controller.ArrangingFeeUpfrontAmount = 250000;
            List<RPFCalculation__c> RPFCs = [SELECT Id FROM RPFCalculation__c WHERE OpportunityLineItemId__c =: String.ValueOf(oli1.Id) AND Month__c IN ('ArrangingFeeDeferredAmount','ArrangingFeeUpfrontAmount')];
            System.assertEquals(0, RPFCs.size());
            controller.changeArrangingFee();
            RPFCs = [SELECT Id FROM RPFCalculation__c WHERE OpportunityLineItemId__c =: String.ValueOf(oli1.Id) AND Month__c IN ('ArrangingFeeDeferredAmount','ArrangingFeeUpfrontAmount')];
            System.assertEquals(2, RPFCs.size());
		}
	}
}