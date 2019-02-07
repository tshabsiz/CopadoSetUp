/**
* @Author:        Marta Malinowska
* @Company:       Deloitte
* @Description:   Unit Tests for AddProductToOpportunity
*                 Tests executed:
*                 1 - testSaveFull()
*                   Tests saving of opporptunity product
*                 2 - testOnProductChanged()
*                   Tests handling of product changes
*                 3 - testSaveAndNew()
*                   Tests saving of opportunity product and redirect to adding new one
*                 4 - testEditExisting()
*                   Tests editation of opportunity product
*                 5 - testErrorMessage()
*                   Tests handling of error messages
*                 6 - testGetDebt()
*                   Tests getter of 'Debt' string
*                 7 - testQueryProductsLvl3()
*                   Tests querying of level 3 products
*				  8 - testUpdateProductPartner()
*					Tests the Product Partner becomes a Opportunity Team Member and the Opportunity Product Partner is updated
*				  9 - testProductPartnerExclusion()
*					Tests functionality to set default Product Partner to Opportunity Owner based on certain conditions
*				 10 - testProductPartnerValidation()
*					Tests validation of only certain products for specific Product partners Team.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 3.12.2015   Marek Cech         added testGetDebt method, modified testOnProductLevel1Changed to test product family handling
* 07-Dec-2015 Mohsin Wadee US-0775 Call method ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem 
									in following methods:
*                                   testOnProductLevel1Changed
*                                   testGetDebt
*                                   testErrorMessage
*                                   testEditExisting
* 10-Dec-2015 Mohsin Wadee US-0775 Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*       with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
* 11-Apr-2016 Marek Cech replaced testOnProductLvl1Changed with testOnProductChanged, added testQueryProductsLvl3 method
* 12-Jul-2017 Dino Scarcella 	 Added test to make sure the ProductPartnerExclusion functionality works
* 28-Feb-2018 Dino Scarcella	 Added test to make sure the ProductPartnerValidation functionality works
* ------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_AddProductToOpportunity {

	public static testMethod void testSaveFull() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;

			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProductLevel1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			
			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;

			Product_Level_2__c sampleProductLevel2 = new Product_Level_2__c(Name=sampleProductLevel1.Name, Product__c=sampleProductLevel1.Id);
			INSERT sampleProductLevel2;
			
			Product_Level_3__c sampleProductLevel3 = new Product_Level_3__c(Name=sampleProductLevel1.Name, Product_Level_2__c=sampleProductLevel2.Id);
			INSERT sampleProductLevel3;

			Test.startTest();            
            
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
			
			// Get picklist values for products 
			List<SelectOption> productSelectOptions = controller.getProducts();
			controller.product = sampleProductLevel1.Id;
			List<SelectOption> productLevel2SelectOptions = controller.getProductsLevel2();
			oli1.Product_Level_2__c = sampleProductLevel2.Id;
			List<SelectOption> productLevel3SelectOptions = controller.getProductsLevel3();
			oli1.Product_Level_3__c = sampleProductLevel3.Id;
			
            
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);

			// Test calculations
			oli1.Balance__c = 10.0;
			oli1.Margin__c = 20.0;
			oli1.Estimated_Utilisation__c = 30.0;
			oli1.Fees__c = 40.0;
			oli1.New_Facility_Balance__c = 100;
            oli1.Volume__c = 60;

			System.debug('### Triggering Controller save');
			controller.save();

			//Assert what has been saved - first re-query the only OppLineItem in the system (which we just created)
			oli1 = [
                SELECT  OpportunityId, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
                FROM    OpportunityLineItem 
            ][0];

            System.assertNotEquals(null, oli1);
            System.assertEquals(sampleProductLevel3.Id, oli1.Product_Level_3__c);
            System.assertEquals(sampleProductLevel2.Id, oli1.Product_Level_2__c);
            System.assertEquals(sampleProductLevel1.Id, oli1.PricebookEntry.Product2Id);

			Test.stopTest();
            
            System.assertNotEquals(null, controller.Calculate());
		}
	}
	
	public static testMethod void testOnProductChanged() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;

			Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
		 
			ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
			Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
				
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('Id', oli1.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController ctrl = new AddProductToOpportunityController(stc);
			
			//clearing product
			ctrl.selectedProductId = '';
			ctrl.selectedProductLevel = '';
			PageReference result = ctrl.onProductChanged();
			
			System.assertEquals(null, result);
			System.assertEquals(null, ctrl.product);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_2__c);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_3__c);
			System.assertEquals('', ctrl.productFamily);
			
			//setting product
			ctrl.selectedProductId = productLvl3.Id;
			ctrl.selectedProductLevel = '3';
			result = ctrl.onProductChanged();

			System.assertEquals(null, result);
			System.assertEquals(productLvl3.Product_Level_2__r.Product__c, ctrl.product);
			System.assertEquals(productLvl3.Product_Level_2__c, ctrl.oppLineItem.Product_Level_2__c);
			System.assertEquals(productLvl3.Id, ctrl.oppLineItem.Product_Level_3__c);
			System.assertEquals('Standard', ctrl.productFamily);

			//Reset the product again
			ctrl.selectedProductId = '';
			ctrl.selectedProductLevel = '';
			result = ctrl.onProductChanged();
			
			System.assertEquals(null, result);
			System.assertEquals(null, ctrl.product);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_2__c);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_3__c);
			System.assertEquals('', ctrl.productFamily);

			//And now only set the level 1
			Product2 productLvl1 = productLvl3.Product_Level_2__r.Product__r;
			ctrl.selectedProductId = productLvl1.Id;
			ctrl.selectedProductLevel = '1';
			result = ctrl.onProductChanged();

			System.assertEquals(null, result);
			System.assertEquals(productLvl3.Product_Level_2__r.Product__c, ctrl.product);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_2__c);
			System.assertEquals(null, ctrl.oppLineItem.Product_Level_3__c);
			System.assertEquals('Standard', ctrl.productFamily);
            System.assertEquals(false, ctrl.isTrade);
            System.assertEquals(false, ctrl.isWorkingCapital);
			System.assertEquals(false, ctrl.isAssetFinance);
            System.assertEquals(false, ctrl.isTradeFinance);
            System.assertEquals(false, ctrl.isCPF);
            System.assertEquals(false, ctrl.isRPF);
			System.assertEquals(false, ctrl.isBond);
            System.assertEquals(false, ctrl.isForeignExchange);
            System.assertEquals(false, ctrl.isExternal);
            System.assertEquals(false, ctrl.isGlobalFinance);
            System.assertEquals('', ctrl.ProductLevel3Name);
            
			Test.stopTest();
		}
	}
	
	public static testMethod void testSaveAndNew() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;

			dataContainer.put(u);

			Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;

			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
			
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);

			// Test calculations
			oli1.Balance__c = 10.0;
			oli1.Margin__c = 20.0;
			oli1.Estimated_Utilisation__c = 30.0;
			oli1.Fees__c = 40.0;
			oli1.New_Facility_Balance__c = 100;

			controller.product = sampleProduct.Id;
			PageReference pageRef = controller.saveAndNew();
			System.assertNotEquals(null, pageRef);

			pageRef = controller.cancel();
			System.assertNotEquals(null, pageRef);
			
			Test.stopTest();
		}
	}

	public static testMethod void testEditExisting() {
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
		
            Test.stopTest();
            
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);
		
			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			ApexPages.currentPage().getParameters().put('id', oli1.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
		
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);
			
			controller.product = priceBookEntry.Product2Id;
			controller.save();
			
			for(OpportunityLineItem oppLineItem : [
					SELECT 	Id, Name, Product2Id 
					FROM 	OpportunityLineItem 
					WHERE 	Id = :oli1.Id]
				) {
				System.assertEquals(oppLineItem.Product2Id, sampleProduct.Id);
			}
		}
	}
	
	public static testMethod void testErrorMessage() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;

			Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			ApexPages.currentPage().getParameters().put('id', oli1.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
			
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);

			//Try to save without having a product - this will fail the validation
			controller.product = '';
			PageReference pageRef = controller.save();
            PageReference calcPageRef = controller.calculate();
			System.assertEquals(null, pageRef);
            System.assertEquals(null, calcPageRef);
			System.assertEquals(false, ApexPages.getMessages().isEmpty());

			Test.stopTest();
		}
	}
	
	public static testMethod void testGetDebt() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;

			Test.startTest();

			OpportunityLineItem oli1 = oliFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);
			
			ApexPages.currentPage().getParameters().put('id', oli1.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController ctrl = new AddProductToOpportunityController(stc);
			
			String result = ctrl.getDebt();
			System.assertEquals('Debt', result);

			Test.stopTest();
		}
	}
	
	public static testMethod void testUpdateProductPartner() {
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    	
    	System.runAs (thisUser) {
	    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
		
			User anotherUser = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ManagerId != NULL AND IsActive = true LIMIT 1];
			dataContainer.put(anotherUser);
		
			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProduct = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;
        
	        oli1.OpportunityId = opp.id;
	        oli1.ProductPartner__c = anotherUser.Id;
	        insert oli1;
	        
	        Opportunity insertedOpp = [SELECT ProductPartner__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
	        System.assertEquals(insertedOpp.ProductPartner__c, anotherUser.Id);
	        
	        OpportunityTeamMember oppteammember = [SELECT UserId FROM OpportunityTeamMember WHERE TeamMemberRole = 'Product Partner Approver' AND OpportunityId =: opp.id LIMIT 1];
	        System.assertEquals(oppteammember.UserId, anotherUser.Id);
        }
    }
	
	public static testMethod void testProductPartnerExclusion() {
		//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;

			Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);		 	
            Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

			INSERT sampleProduct;
			
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController ctrl = new AddProductToOpportunityController(stc);

			//Now set the level 1
			ctrl.selectedProductId = sampleProduct.Id;
            ctrl.selectedProductLevel = '1';
            ctrl.selectedProductName = 'Karel Kakadu';
            ctrl.product = sampleProduct.Id;
			PageReference result = ctrl.onProductChanged();

            System.assertEquals(false, ctrl.ExcludeProductPartner);
            
            sampleProduct.Name = 'Trade';
            update sampleProduct;
            ctrl = new AddProductToOpportunityController(stc);
            ctrl.selectedProductId = sampleProduct.Id;
            ctrl.selectedProductLevel = '1';
            ctrl.selectedProductName = 'Trade';
            ctrl.product = sampleProduct.Id;
            result = ctrl.onProductChanged();
            
            System.assertEquals(true, ctrl.ExcludeProductPartner);
            
			Test.stopTest();
		}
	}
    
    public static testMethod void testUpdatePrimaryBankingIndicator()
    {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;

			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProductLevel1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			
			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;

			Product_Level_2__c sampleProductLevel2 = new Product_Level_2__c(Name=sampleProductLevel1.Name, Product__c=sampleProductLevel1.Id);
			INSERT sampleProductLevel2;
			
			Product_Level_3__c sampleProductLevel3 = new Product_Level_3__c(Name=sampleProductLevel1.Name, Product_Level_2__c=sampleProductLevel2.Id);
			INSERT sampleProductLevel3;

            Test.startTest();
            
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
			
			// Get picklist values for products 
			List<SelectOption> productSelectOptions = controller.getProducts();
			controller.product = sampleProductLevel1.Id;
			List<SelectOption> productLevel2SelectOptions = controller.getProductsLevel2();
			oli1.Product_Level_2__c = sampleProductLevel2.Id;
			List<SelectOption> productLevel3SelectOptions = controller.getProductsLevel3();
			oli1.Product_Level_3__c = sampleProductLevel3.Id;
			
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);

			// Test calculations
			oli1.Balance__c = 10.0;
			oli1.Margin__c = 20.0;
			oli1.Estimated_Utilisation__c = 30.0;
			oli1.Fees__c = 40.0;
			oli1.New_Facility_Balance__c = 100;
            oli1.Volume__c = 60;

			System.debug('### Triggering Controller save');
			controller.save();

			//Assert what has been saved - first re-query the only OppLineItem in the system (which we just created)
			oli1 = [
                SELECT  OpportunityId, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
                FROM    OpportunityLineItem 
            ][0];

            System.assertNotEquals(null, oli1);
            System.assertEquals(sampleProductLevel3.Id, oli1.Product_Level_3__c);
            System.assertEquals(sampleProductLevel2.Id, oli1.Product_Level_2__c);
            System.assertEquals(sampleProductLevel1.Id, oli1.PricebookEntry.Product2Id);

			Test.stopTest();
            
            System.assertNotEquals(null, controller.Calculate());
    }
    }
    
    public static testMethod void testProductPartnerValidation() {
        List<Product_Setting__mdt> ProductSettings = [SELECT Product_Partner_Team__c FROM Product_Setting__mdt WHERE ProductSet__c = 'ProductPartnerFilter'];
        // Build a list of Product Partner Teams for the validation so we can avoid a validation error
        Set<String> ProductPartnerTeams = new Set<String>();
        for(Product_Setting__mdt ps : ProductSettings) ProductPartnerTeams.add(ps.Product_Partner_Team__c);
        //Create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
			ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;

            User anotherUser = [SELECT Id, Team__c FROM User WHERE Id != :UserInfo.getUserId() AND ManagerId != NULL AND Team__c IN : ProductPartnerTeams AND IsActive = true LIMIT 1];
			dataContainer.put(anotherUser);
            
			Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
            Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);

			INSERT sampleProduct;
			
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

            ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController ctrl = new AddProductToOpportunityController(stc);

			//Now set the level 1
			ctrl.selectedProductId = sampleProduct.Id;
            ctrl.selectedProductLevel = '1';
            ctrl.selectedProductName = 'Karel Kakadu';
            ctrl.product = sampleProduct.Id;
			PageReference result = ctrl.onProductChanged();

            System.assertEquals(NULL, ctrl.checkProductPartnerTeam());
            
            oli1.ProductPartner__c = anotherUser.Id;
            stc = new ApexPages.StandardController(oli1);
			ctrl = new AddProductToOpportunityController(stc);
            
            //Now set the level 1
			ctrl.selectedProductId = sampleProduct.Id;
            ctrl.selectedProductLevel = '1';
            ctrl.selectedProductName = 'Karel Kakadu';
            ctrl.product = sampleProduct.Id;

            System.assertNotEquals(NULL, ctrl.checkProductPartnerTeam());
            
			Test.stopTest();
		}
    }
    public static testMethod void testcheckFacilitySize()
    {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        u.team__c ='Cib';
        update u;
        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;

			dataContainer.put(u);

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			Product2 sampleProductLevel1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			
			//Update pricebook reference on Opp
			opp.Pricebook2Id = Test.getStandardPricebookId();
			UPDATE opp;

			Product_Level_2__c sampleProductLevel2 = new Product_Level_2__c(Name='Institutional Trade', Product__c=sampleProductLevel1.Id);
			INSERT sampleProductLevel2;
			
			Product_Level_3__c sampleProductLevel3 = new Product_Level_3__c(Name='Institutional Trade', Product_Level_2__c=sampleProductLevel2.Id);
			INSERT sampleProductLevel3;

            Test.startTest();
            
			PageReference AddProductToOpportunity = Page.AddProductToOpportunity;
			Test.setCurrentPage(AddProductToOpportunity);

			ApexPages.currentPage().getParameters().put('oppId', opp.Id);
			Apexpages.Standardcontroller stc = new ApexPages.StandardController(oli1);
			AddProductToOpportunityController controller = new AddProductToOpportunityController(stc);
			
			// Get picklist values for products 
			List<SelectOption> productSelectOptions = controller.getProducts();
			controller.product = sampleProductLevel1.Id;
			List<SelectOption> productLevel2SelectOptions = controller.getProductsLevel2();
			oli1.Product_Level_2__c = sampleProductLevel2.Id;
			List<SelectOption> productLevel3SelectOptions = controller.getProductsLevel3();
			oli1.Product_Level_3__c = sampleProductLevel3.Id;
			
			//Add mock Probability Setting
			controller.PROBABILITY_THRESHHOLD = ZZTEST_F_ProbabilityThreshholdSetting.InstantiateProbabilityThreshholdSetting(30);

			// Test calculations
			oli1.Balance__c = 10.0;
			oli1.Margin__c = 20.0;
			oli1.Estimated_Utilisation__c = 30.0;
			oli1.Fees__c = 40.0;
			oli1.New_Facility_Balance__c = 100;
            oli1.Volume__c = 60;

			System.debug('### Triggering Controller save');
			controller.save();

			

			Test.stopTest();
        }            
    }
}