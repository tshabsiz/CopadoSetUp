/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanController
*                 Tests executed:
*                 1 - testUpdateCloseDatesErrors()
*                   Tests errors handling during editation of products
*                 2 - testSaveProductionValue()
*                   Tests editation of products
*                 3 - testAddPotOptyErrors()
*                   Tests errors handling during adding potential opportunity
*                 4 - testAddPotOpty()
*                   Tests adding potential opportunity
*                 5 - testEditPotOpty()
*                   Tests editation of potential opportunity
*                 6 - testEditPotOptyErrors()
*                   Tests errors handling during editation of potential opportunity
*                 7 - testModifyOptyErrors()
*                   Tests errors handling during editation of opportunity
*                 8 - testModifyOpty()
*                   Tests editation of opportunity
*                 9 - testGetPotOptyStageOptions()
*                   Tests preparation of select options of stage field (pot. opty)
*                 10 - testGetPotOptyTypeOptions()
*                   Tests preparation of select options of type field
*                 11 - testGetOptyStageOptions()
*                   Tests preparation of select options of stage field (opty)
*                 12 - testQueryBudgetRevenues()
*                   Tests querying of products
*                 13 - testPrepareTotalsOfBudgetRevenues()
*                   Tests counting of totals of products
*                 14 - testQueryUnqOptys()
*                   Tests querying of potential opportunities
*                 15 - testQueryPipelineOptys()
*                   Tests querying of opportunities
*                 16 - testQueryPlan()
*                   Tests querying of client plan
*                 17 - testQueryPlanWithWrongId()
*                   Tests error handlign during querying of client plan
*                 18 - testErrorMessages()
*                   Tests of methods handling error messaged
*                 20 - testCheckUnqOptyConvertibility()      
*                   Tests of methods checking that pot opty can be converted    
*                 21 - testConvertUnqOptyErrors()
*                   Tests of methods that handles errors when converting pot opty to opty
*                 22 - testConvertUnqOpty()
*                   Tests of methods that handles conversion of pot poty to opty
*                 23 - testEditProduct()
*                   Tests editing of product
*                 24 - testAddProduct()
*                   Tests adding of a product
*				  25 - testDeleteProduct()
*					Tests deletion of a product
*				  26 - testGetCurrencyOptions()
*					Tests retrieving the currency options
*				  27 - testGetOptyCountryOptions()
*					Tests retrieving the country options
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 22.2.2016     Svata Sejkora       Added methods to test new functionality: testCheckUnqOptyConvertibility, testConvertUnqOptyErrors, testConvertUnqOpty, testEditProduct
* 23.5.2016		Mohsin Wadee		In method testQueryPipelineOptys(), created new Client Plan using ZZTEST_ClientPlanUtils class.
* 30.5.2017     Dino Scarcella      Changed stages to CIB stages to test against for testGetOptyStageOptions
* 12.6.2017	  	Dino Scarcella	 	Added method for getting country options on the Plan Tab on Client Plan
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanController {

	@testSetup static void setup() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

		Client_Plan__c ap = new Client_Plan__c();
		ap.Relationship__c = acc1.Id;
		INSERT ap;
	}

	static testMethod void testSaveProductionValueErrors() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
		Budget_Revenue__c br = new Budget_Revenue__c();
		br.Client_Plan__c = plan.Id;
		INSERT br;

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.budgetRevenueId = br.Id;
		ctrl.productionValue = 'asdf';

		PageReference result = ctrl.saveProductionValue();
		System.assertEquals(null, result);
		System.assertEquals(Label.errMsg_ErrorDuringSaving, ctrl.getErrorMessage());
	}

	static testMethod void testSaveProductionValue() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
		Budget_Revenue__c br = new Budget_Revenue__c();
		br.Client_Plan__c = plan.Id;
		INSERT br;

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.budgetRevenueId = br.Id;
		ctrl.productionValue = '23';
		ctrl.productionFieldName = 'Next_year_budget__c';

		PageReference result = ctrl.saveProductionValue();
		System.assertEquals(null, result);

		List<Budget_Revenue__c> brs = [SELECT Next_year_budget__c FROM Budget_Revenue__c WHERE Id = :br.Id];
		System.assertEquals(1, brs.size());
		System.assertEquals(23, brs[0].Next_year_budget__c);
	}

	static testMethod void testAddPotOptyErrors() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyId = '';
		ctrl.closeDateMillis = 1;

		PageReference result = ctrl.modifyPotOpty();
		System.assertEquals(null, result);
		System.assertEquals(Label.errMsg_ErrorDuringAddingPotOpty, ctrl.getErrorMessage());
	}

	static testMethod void testAddPotOpty() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
		Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		Date today = Date.today();
		Datetime now = Datetime.now();

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyId = '';
		ctrl.potOptyName = 'name';
		ctrl.closeDateMillis = now.getTime();
		ctrl.potOptyProductLevel = '3';
		ctrl.potOptyProductId = productLvl31.Id;
		ctrl.potOptyStage = 'stage';
		ctrl.potOptyType = 'type';

		PageReference result = ctrl.modifyPotOpty();
		System.assertEquals(null, result);
		System.assertEquals(null, ctrl.getErrorMessage());

		List<Potential_Opportunity__c> optys = [
			SELECT Name, Close_Date__c, Product_Level_3__c, Stage__c, Type__c, Client_Plan__c
			FROM Potential_Opportunity__c
		];
		System.assertEquals(1, optys.size());

		Potential_Opportunity__c uo = optys[0];
		System.assertEquals('name', uo.Name);
		System.assertEquals(today, uo.Close_Date__c);
		System.assertEquals(productLvl31.Id, uo.Product_Level_3__c);
		System.assertEquals('stage', uo.Stage__c);
		System.assertEquals('type', uo.Type__c);
		System.assertEquals(plan.Id, uo.Client_Plan__c);
	}

	static testMethod void testEditPotOpty() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
		Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);

		Potential_Opportunity__c uo = new Potential_Opportunity__c();
		uo.Name = 'name';
		uo.Close_Date__c = Date.today().addDays(3);
		uo.Product_Level_3__c = null;
		uo.Stage__c = 'stage';
		uo.Type__c = 'type';
		uo.Client_Plan__c = plan.Id;
		INSERT uo;

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyId = uo.Id;
		ctrl.potOptyName = 'n';
		ctrl.closeDateMillis = Datetime.now().getTime();
		ctrl.potOptyProductLevel = '3';
		ctrl.potOptyProductId = productLvl31.Id;
		ctrl.potOptyStage = 's';
		ctrl.potOptyType = 't';

		PageReference result = ctrl.modifyPotOpty();
		System.assertEquals(null, result);
		System.assertEquals(null, ctrl.getErrorMessage());

		List<Potential_Opportunity__c> optys = [
			SELECT Name, Close_Date__c, Product_Level_3__c, Stage__c, Type__c, Client_Plan__c
			FROM Potential_Opportunity__c
		];
		System.assertEquals(1, optys.size());

		uo = optys[0];
		System.assertEquals('n', uo.Name);
		System.assertEquals(Date.today(), uo.Close_Date__c);
		System.assertEquals(productLvl31.Id, uo.Product_Level_3__c);
		System.assertEquals('s', uo.Stage__c);
		System.assertEquals('t', uo.Type__c);
		System.assertEquals(plan.Id, uo.Client_Plan__c);
	}

	static testMethod void testEditPotOptyErrors() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Potential_Opportunity__c uo = new Potential_Opportunity__c();
		uo.Name = 'name';
		uo.Close_Date__c = Date.today();
		uo.Product__c = 'product';
		uo.Stage__c = 'stage';
		uo.Type__c = 'type';
		uo.Client_Plan__c = plan.Id;
		INSERT uo;

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyName = '';
		ctrl.potOptyId = uo.Id;
		ctrl.closeDateMillis = 0;

		PageReference result = ctrl.modifyPotOpty();
		System.assertEquals(null, result);
		System.assertEquals(Label.errMsg_ErrorDuringEditingPotOpty, ctrl.getErrorMessage());
	}

	static testMethod void testModifyOptyErrors() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyName = '';
		ctrl.closeDateMillis = 1;

		PageReference result = ctrl.modifyOpty();
		System.assertEquals(null, result);
		System.assertEquals(Label.errMsg_ErrorDuringAddingOpty, ctrl.getErrorMessage());
	}

	static testMethod void testModifyOpty() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();
		ctrl.potOptyName = 'n';
		ctrl.closeDateMillis = Datetime.now().getTime();
		ctrl.potOptyStage = 's';

		PageReference result = ctrl.modifyOpty();
		System.assertEquals(null, result);
		System.assertEquals(null, ctrl.getErrorMessage());

		List<Opportunity> optys = [
			SELECT Name, CloseDate, StageName
			FROM Opportunity
		];

		System.assertEquals(1, optys.size());
		System.assertEquals('n', optys[0].Name);
		System.assertEquals(Date.today(), optys[0].CloseDate);
		System.assertEquals('s', optys[0].StageName);
	}

	static testMethod void testGetPotOptyStageOptions() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Schema.DescribeFieldResult f = Potential_Opportunity__c.Stage__c.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e: p) {
			options.add(new SelectOption(e.getLabel(), e.getValue()));
		}

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();

		List<SelectOption> result = ctrl.getPotOptyStageOptions();

		System.assertNotEquals(null, result);
		System.assertEquals(options.size(), result.size());

		for(Integer i = 0; i < options.size(); i++) {
			System.assertEquals(options[i], result[i]);
		}
	}

	static testMethod void testGetPotOptyTypeOptions() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Schema.DescribeFieldResult f = Potential_Opportunity__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e: p) {
			options.add(new SelectOption(e.getLabel(), e.getValue()));
		}

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();

		List<SelectOption> result = ctrl.getPotOptyTypeOptions();

		System.assertNotEquals(null, result);
		System.assertEquals(options.size(), result.size());

		for(Integer i = 0; i < options.size(); i++) {
			System.assertEquals(options[i], result[i]);
		}
	}

	static testMethod void testGetOptyStageOptions() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e : p) {
        	if (e.getLabel() == 'Opportunity Identified' || e.getLabel() == 'Client Engaged' || e.getLabel() == 'Needs Established' || e.getLabel() == 'Initial Solution Proposed' || e.getLabel() == 'Credit Case Submitted')
				options.add(new SelectOption(e.getLabel(), e.getValue()));
        }

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();

		List<SelectOption> result = ctrl.getOptyStageOptions();

		System.assertNotEquals(null, result);
		System.assertEquals(options.size(), result.size());

		for(Integer i = 0; i < options.size(); i++) {
			System.assertEquals(options[i], result[i]);
		}
	}

	static testMethod void testQueryBudgetRevenues() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Budget_Revenue__c br1 = new Budget_Revenue__c();
		br1.Client_Plan__c = plan.Id;
		br1.Product__c = 'prod';

		Budget_Revenue__c br2 = new Budget_Revenue__c();
		br2.Client_Plan__c = plan.Id;
		br2.Product__c = 'a prod';

		INSERT new List<Budget_Revenue__c>{br1, br2};

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();

		System.assertNotEquals(null, ctrl.brs);

        //Verify we have 3 elements (+1 because of totals)
        System.assertEquals(3, ctrl.brs.size());
        System.assertEquals('a prod', ctrl.brs[0].Product__c);
        System.assertEquals('prod', ctrl.brs[1].Product__c);
    }
    
    static testMethod void testPrepareTotalsOfBudgetRevenues() {
    	/*
    	//First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();
        */

        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        /*
        //Add this test user to the ClientPlan team
        Account_Team_Member__c memberToAdd = new Account_Team_Member__c();
        memberToAdd.Organisation__c = plan.Relationship__c;
        memberToAdd.Team_Member__c = u.Id;
        INSERT memberToAdd;
        */

        CurrencyType defaultOrgCurrency = [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = true].get(0);

		Test.startTest();

    	Budget_Revenue__c br1 = new Budget_Revenue__c();
    	br1.Client_Plan__c = plan.Id;
    	br1.Product__c = 'prod';
    	br1.Limit__c = 1000;
    	br1.CurrencyIsoCode = defaultOrgCurrency.IsoCode;

    	Budget_Revenue__c br2 = new Budget_Revenue__c();
    	br2.Client_Plan__c = plan.Id;
    	br2.Product__c = 'a prod';
    	br2.Limit__c = 2000;
    	br2.CurrencyIsoCode = defaultOrgCurrency.IsoCode;

    	System.debug('XXX Inserting [br1: ' + br1 + ', br2: ' + br2 + ']');
    	INSERT new List<Budget_Revenue__c>{br1, br2};

    	PageReference pr = Page.ClientPlan;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();

    	System.assertNotEquals(null, ctrl.brs);

        //Verify we have 3 elements (+1 because of totals) with the correct Limit sum
        System.assertEquals(3, ctrl.brs.size());
        System.assertEquals(3000, ctrl.brs[2].Limit__c);

        Test.stopTest();
    }
    
    static testMethod void testQueryUnqOptys() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	Potential_Opportunity__c uo = new Potential_Opportunity__c();
    	uo.Name = 'name';
    	uo.Close_Date__c = Date.today();
    	uo.Product__c = 'product';
    	uo.Stage__c = 'stage';
    	uo.Type__c = 'type';
    	uo.Client_Plan__c = plan.Id;
    	INSERT uo;

    	PageReference pr = Page.ClientPlan;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();
    	System.assertNotEquals(null, ctrl.unqOptys);
    	System.assertEquals(1, ctrl.unqOptys.size());
    	System.assertEquals(uo.Id, ctrl.unqOptys[0].Id);
    }
    
    static testMethod void testQueryPipelineOptys() {
    	Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

        //Create Opportunity
        List<OpportunityStage> oppStage = [SELECT MasterLabel, SortOrder FROM OpportunityStage WHERE IsWon = FALSE AND IsClosed = FALSE AND IsActive = TRUE ORDER BY SortOrder asc];

        Opportunity opp = new Opportunity();
        opp.AccountId = plan.Relationship__c;
        //opty.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        opp.Name = 'Some Opp';
        opp.StageName = oppStage[0].MasterLabel;
        opp.CloseDate = Date.today().addMonths(6);       
        opp.Description = 'Big opportunity for our company.';
        INSERT opp;

        PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanController ctrl = new ClientPlanController();
        List<Opportunity> result = ctrl.pipelineOptys;
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(opp.Id, result[0].Id);
    }
    
    static testMethod void testQueryPlan() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	PageReference pr = Page.ClientPlan;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	Test.startTest();
    	ClientPlanController ctrl = new ClientPlanController();
    	Test.stopTest();

    	System.assertNotEquals(null, ctrl.plan);
    	System.assertEquals(plan.Id, ctrl.plan.Id);
    	System.assertEquals(true, ctrl.planLoaded);
    }
    
    static testMethod void testQueryPlanWithWrongId() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	PageReference pr = Page.ClientPlan;
    	pr.getParameters().put('planId', 'asdfasdf');
    	Test.setCurrentPage(pr);

    	Test.startTest();
    	ClientPlanController ctrl = new ClientPlanController();
    	Test.stopTest();

    	System.assertEquals(null, ctrl.plan);
    	System.assertEquals(false, ctrl.planLoaded);
    }
    
    static testMethod void testErrorMessages() {
    	Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];

    	PageReference pr = Page.ClientPlan;
    	pr.getParameters().put('planId', 'asdfasdf');
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();

    	System.assertEquals(null, ctrl.errorMessage);

    	String expected = 'This is an error message';
    	ctrl.setErrorMessage(expected);
    	System.assertEquals(expected, ctrl.errorMessage);

    	String result = ctrl.getErrorMessage();
    	System.assertEquals(expected, result);
    	System.assertEquals(null, ctrl.errorMessage);

    	System.assertEquals(null, ctrl.getErrorMessage());
    }

    static testMethod void testCheckUnqOptyConvertibility() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	PageReference pr = Page.ClientPlanStrategy;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();

    	Potential_Opportunity__c uo = new Potential_Opportunity__c();
    	Boolean result = ctrl.checkUnqOptyConvertibility(uo);
    	System.assertEquals(false, result);

    	uo.Name = '';
    	result = ctrl.checkUnqOptyConvertibility(uo);
    	System.assertEquals(false, result);

    	uo.Name = 'Opp 1';
    	uo.Close_Date__c = null;
    	result = ctrl.checkUnqOptyConvertibility(uo);
    	System.assertEquals(false, result);

    	uo.Close_Date__c = Date.today();
    	result = ctrl.checkUnqOptyConvertibility(uo);
    	System.assertEquals(true, result);
    }

    static testMethod void testConvertUnqOptyErrors() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
    	cps.Client_Plan__c = plan.Id;
    	INSERT cps;

    	Potential_Opportunity__c uo1 = new Potential_Opportunity__c();
    	uo1.Client_Plan__c = plan.Id;
    	uo1.Name = 'Opp 1';
    	uo1.Client_Plan_Strategy__c = cps.Id;
    	INSERT uo1;

    	PageReference pr = Page.ClientPlanStrategy;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();

        //unq opty = null
        ctrl.managedUnqOptyId = null;
        PageReference result = ctrl.convertUnqOpty();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorConvertingOpportunity, ctrl.errorMessage);
        
        //unq opty unconvertible
        ctrl.managedUnqOptyId = uo1.Id;
        result = ctrl.convertUnqOpty();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_OptyNotConvertible, ctrl.errorMessage);
    }

    static testMethod void testConvertUnqOpty() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
    	cps.Client_Plan__c = plan.Id;
    	INSERT cps;

    	Potential_Opportunity__c uo1 = new Potential_Opportunity__c();
    	uo1.Client_Plan__c = plan.Id;
    	uo1.Client_Plan_Strategy__c = cps.Id;
    	uo1.Name = 'Opp 1';
    	uo1.Close_Date__c = Date.today();
    	uo1.Type__c = 'Cross Sell';
    	uo1.Stage__c = 'Potential Opportunity Convert';
    	INSERT uo1;

    	PageReference pr = Page.ClientPlanStrategy;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();
    	ctrl.managedUnqOptyId = uo1.Id;

    	Test.startTest();
    	PageReference result = ctrl.convertUnqOpty();
    	Test.stopTest();

    	System.assertEquals(null, result);
    	System.assertEquals(null, ctrl.errorMessage);

    	List<Potential_Opportunity__c> uos = [
    		SELECT  Opportunity__c, Client_Plan_Strategy__r.Client_Plan__r.Relationship__c
    		FROM    Potential_Opportunity__c 
    		WHERE   Id = :uo1.Id
    	];
    	System.assertEquals(1, uos.size());    
    	System.assertNotEquals(null, uos[0].Opportunity__c);

    	List<Opportunity> optys = [
    		SELECT  Name, CloseDate, Type, StageName, AccountId 
    		FROM    Opportunity 
    		WHERE   Id = :uos[0].Opportunity__c
    	];
    	System.assertEquals(1, optys.size());

    	Opportunity opty = optys[0];
    	System.assertEquals(uo1.Name, opty.Name);
    	System.assertEquals(uo1.Close_Date__c, opty.CloseDate);
    	System.assertEquals(uo1.Type__c, opty.Type);
    	System.assertEquals('Opportunity Identified', opty.StageName);
    	System.assertEquals(uos[0].Client_Plan_Strategy__r.Client_Plan__r.Relationship__c, opty.AccountId);
    }

    static testMethod void testAddAndEditProduct() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    	ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
    	Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);

    	PageReference pr = Page.ClientFinancials;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();

        //ADD NEW PRODUCT
        //Populate data
        ctrl.existingProductId = productLvl3.Id;
        ctrl.existingProductCountry = 'South Africa';
        ctrl.existingProductLgd = 100;
        ctrl.existingProductDg = 100;
        ctrl.existingProductLimit = 100;
        ctrl.existingProductUtilisation = 100;
        ctrl.existingProductMargin = 100;
        ctrl.existingProductFtp = 100;
        ctrl.existingProductArrfee = 100;
        ctrl.existingProductComfee = 100;
        ctrl.existingProductRorwa = 100;

        PageReference result = ctrl.modifyProduct();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        //Query the result
        List<Budget_Revenue__c> buReList = [
        	SELECT 	Id, Client_Plan__c, Country__c, Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, Actual_Year_Annualised_Revenues__c, Budget_Annualised__c, Next_year_budget__c, Actual_RWA__c, Actual_RoRWA__c
        	FROM 	Budget_Revenue__c
        ];

        System.assertEquals(1, buReList.size());
        System.assertEquals(productLvl3.Id, buReList[0].Product_Level_3__c);
        System.assertEquals('South Africa', buReList[0].Country__c);

        //MODIFY EXISTING PRODUCT
        ctrl.existingRecordId = buReList[0].Id;
        ctrl.existingProductId = productLvl3.Id;
        ctrl.existingProductName = productLvl3.Name;
        ctrl.existingProductCountry = 'Angola';
        ctrl.existingProductLgd = 100;
        ctrl.existingProductDg = 100;
        ctrl.existingProductLimit = 100;
        ctrl.existingProductUtilisation = 100;
        ctrl.existingProductMargin = 100;
        ctrl.existingProductFtp = 100;
        ctrl.existingProductArrfee = 100;
        ctrl.existingProductComfee = 100;
        ctrl.existingProductRorwa = 100;

        result = ctrl.modifyProduct();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());

        //Re-Query the result
        buReList = [
        	SELECT Id, Client_Plan__c, Country__c, Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, Actual_Year_Annualised_Revenues__c, Budget_Annualised__c, Next_year_budget__c, Actual_RWA__c, Actual_RoRWA__c
        	FROM Budget_Revenue__c
        ];

        System.assertEquals(1, buReList.size());
        System.assertEquals(productLvl3.Id, buReList[0].Product_Level_3__c);
        System.assertEquals('Angola', buReList[0].Country__c);
    }

    static testMethod void testDeleteProduct() {
    	Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

    	Budget_Revenue__c buRe = new Budget_Revenue__c();
    	buRe.Client_Plan__c = plan.Id;
    	buRe.Product__c = 'Ja sem produkt';
    	buRe.Previous_YTD_Revenues__c = 0;
    	buRe.Actual_YTD_Revenues__c = 0;
    	buRe.Budget_YTD__c = 0;
    	buRe.Actual_Year_Annualised_Revenues__c = 0;
    	buRe.Budget_Annualised__c = 0;
    	buRe.Next_year_budget__c = 0;
    	buRe.Actual_RWA__c = 0;
    	buRe.Actual_RoRWA__c = 0;
    	INSERT buRe;

    	PageReference pr = Page.ClientFinancials;
    	pr.getParameters().put('planId', plan.Id);
    	Test.setCurrentPage(pr);

    	ClientPlanController ctrl = new ClientPlanController();
    	ctrl.existingRecordId = buRe.Id;
    	PageReference result = ctrl.deleteProduct();

    	System.assertEquals(null, result);
    	System.assertEquals(null, ctrl.getErrorMessage());

        //Verify the record is gone
        List<Budget_Revenue__c> buReList = [SELECT Id FROM Budget_Revenue__c];

        System.assertEquals(0, buReList.size());        
    }
    
    static testMethod void testGetCurrencyOptions() {
		Schema.DescribeFieldResult f = Client_Plan_Facility__c.CurrencyIsoCode.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e: p) {
			options.add(new SelectOption(e.getLabel(), e.getValue()));
		}

		ClientPlanController ctrl = new ClientPlanController();
		List<SelectOption> result = ctrl.getCurrencyOptions();

		System.assertNotEquals(null, result);
		System.assertEquals(options.size(), result.size());

		for(Integer i = 0; i < options.size(); i++) {
			System.assertEquals(options[i], result[i]);
		}
	}
    
    static testMethod void testGetOptyCountryOptions() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

		Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();
		List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
		for(Schema.PicklistEntry e : p) {
			options.add(new SelectOption(e.getLabel(), e.getValue()));
        }

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

		ClientPlanController ctrl = new ClientPlanController();

		List<SelectOption> result = ctrl.getOptyCountryOptions();

		System.assertNotEquals(null, result);
		System.assertEquals(options.size(), result.size());

		for(Integer i = 0; i < options.size(); i++) {
			System.assertEquals(options[i], result[i]);
		}
	}
    static testMethod void testTelatedClients()
    {
        Client_Plan__c plan = [SELECT Id,Relationship__c FROM Client_Plan__c LIMIT 1];
		
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        acc1.ParentId = plan.Relationship__c;
        update acc1;
        
		Client_Plan__c ap = new Client_Plan__c();
		ap.Relationship__c = acc1.Id;
		INSERT ap;
        
        Budget_Revenue__c buRe = new Budget_Revenue__c();
    	buRe.Client_Plan__c = ap.Id;
    	buRe.Product__c = 'Ja sem produkt';
    	buRe.Previous_YTD_Revenues__c = 0;
    	buRe.Actual_YTD_Revenues__c = 0;
    	buRe.Budget_YTD__c = 0;
    	buRe.Actual_Year_Annualised_Revenues__c = 0;
    	buRe.Budget_Annualised__c = 0;
    	buRe.Next_year_budget__c = 0;
    	buRe.Actual_RWA__c = 0;
    	buRe.Actual_RoRWA__c = 0;
    	INSERT buRe;
        

		PageReference pr = Page.ClientPlan;
		pr.getParameters().put('planId', plan.Id);
		Test.setCurrentPage(pr);

        ClientPlanController ctrl = new ClientPlanController();
        ctrl.selectedClient = acc1.ID;
        ctrl.getChildClientPlans();
    }
    static testMethod void testACMIntegration() {
    	// Create the mock response based on a static resource
    	
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ACMResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
    	Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        Account parent_acc = [SELECT Id FROM Account LIMIT 1];
        Account child_acc = new Account(Name='MTN South Africa',ParentId=parent_acc.Id,SDS__c='40403149');
        insert child_acc;
        
        PageReference pr = Page.ClientPlan;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanController ctrl = new ClientPlanController();
        ctrl.selectedFacilitySDS = '40403149';
        ctrl.selectedFacilitySDSLabel = '40403149 - MTN South Africa';
        
        Test.startTest();
        System.assertEquals(2, ctrl.getSDSClients.size());
        ctrl.addFacilities();
        System.assertEquals(5, ctrl.acmfs.size());
        ClientPlanSummaryPrintViewController ctrlCPSPV = new ClientPlanSummaryPrintViewController(new ApexPages.StandardController(plan));
        System.assertEquals(1, ctrlCPSPV.acmfsLabels.size());
        ctrl.deleteFacilities();
        System.assertEquals(0, ctrl.acmfs.size());
        ctrl.modifyManualFacility();
       
        ctrl.deleteManualFacility();
        System.assertEquals(0, ctrl.acmfs.size());
        
        Test.stopTest();
    }
}