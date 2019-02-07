/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanStrategyController
*                 Tests executed:
*                 1- testGetStrategiesList()
*                   Tests quering strategies with related opportunities
*                 2 - testAddStrategyErrors()
*                   Tests errors handling during adding client plan strategy
*                 3 - testAddStrategy()
*                   Tests adding of client plan strategy
*                 4 - testDeleteStrategyErrors()
*                   Tests errors handling during deleting client plan strategy
*                 5 - testDeleteStrategyDmlErrors()
*                   Tests dml errors handling during deleting client plan strategy
*                 6 - testDeleteStrategy()
*                   Tests deleting of client plan strategy
*                 7 - testEditRichTextDmlErrors()
*                   Tests dml errors handling during rich text editation
*                 8 - testEditRichTextErrors()
*                   Tests errors handling during rich text editation
*                 9 - testEditRichText()
*                   Tests rich text editation
*                 10 - testloadUnqOptyErrors()
*                   Tests error handling during loading potential opportunity
*                 11 - testloadUnqOpty()
*                   Tests loading of potential opportunity
*                 12 - testAddOptyErrors()
*                   Tests errors handling during adding opportunity
*                 13 - testAddOpty()
*                   Tests adding of opportunity
*                 14 - testAddUnqOptyErrors()
*                   Tests errors handling during adding potential opportunity
*                 15 - testAddUnqOptyDmlErrors()
*                   Tests dml errors handling during adding potential opportunity
*                 16 - testAddUnqOpty()
*                   Tests adding of potential opportunity
*                 17 - testEditUnqOptyDmlErrors()
*                   Tests dml errors handling during editing of potential opportunity
*                 18 - testEditUnqOptyErrors()
*                   Tests errors handling during editing of potential opportunity
*                 19 - testEditUnqOpty()
*                   Tests editing of potential opportunity
*                 20 - testConvertCloseDateMillis()
*                   Tests conversion of timestamp to date
*                 21 - testConstructor()
*                   Tests constructor
*                 22 - testCheckUnqOptyConvertibility()
*                   Tests method which checks whether potential opty is convertible
*                 23 - testGetSetErrorMessage()
*                   Tests getter and setter of error message
*                 24 - testConvertUnqOptyErrors()
*                   Tests errors handling during converting potential opty
*                 25 - testConvertUnqOpty()
*                   Tests converting of potential opty
*                 26 - testLinkOptysErrors()
*                   Tests errors handling during linking optys
*                 27 - testLinkOptysErrors2()
*                   Tests errors handling during linking optys (part 2)
*                 28 - testLinkOptys()
*                   Tests linking of opportunities to a strategy
*                 29 - testUnlinkOptysErrors()
*                   Tests errors handling during unlinking opty
*                 30 - testUnlinkOptys()
*                   Tests unlinking of opty from a strategy
*                 31 - testAddOpportunity()
*                   Tests adding new opportunity and linking it to strategy
*                 32 - testDeleteUnqOpty()
*                   Tests removing Potential Opportunity
*                 33 - testLinkPotOptysErrors()
*                   Tests that all errors are covered when linkyng potential opportunity
*                 34 - testLinkPotOptysErrors2()
*                   Tests that all errors are covered when linkyng potential opportunity
*                 35 - testLinkPotOptys()
*                   Tests that link potential opportunity works
*                 36 - testLinkPotOptys()
*                   Tests that all errors are covered when unlinking potential opportunity
*                 37 - testUnlinkPotOptys()
*                   Tests that unlink potential opportunity works as intended
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 2.3.2016      Svata Sejkora       adding test methods to new functionality (33 - 37)
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanStrategyController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        INSERT ap;
    }

    static testMethod void testGetStrategiesList(){
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;

        List<Client_Plan_Strategy__c> result = ClientPlanStrategyController.getStrategiesList('', plan.Id);
        System.assertEquals(1, result.size());
    }
    
    static testMethod void testAddStrategyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        String planId = 'asdf';
        Test.startTest();
        String result = ClientPlanStrategyController.addStrategy('Strategy Name', '', '', planId);
        Test.stopTest();
        
        System.assertEquals('Error: '+Label.errMsg_AddStrategy, result);
    }
    
    static testMethod void testAddStrategy() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        Test.startTest();
        String result = ClientPlanStrategyController.addStrategy('Strategy Name', '', '', plan.Id);
        Test.stopTest();
        
        List<Client_Plan_Strategy__c> cpss = [SELECT Id FROM Client_Plan_Strategy__c LIMIT 1];
        System.assertEquals(1, cpss.size());

        System.assertEquals(cpss[0].Id, result);
    }
    
    static testMethod void testDeleteStrategyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        //test with no strategyId set
        String result = ClientPlanStrategyController.removeStrategy('invalidId');
        System.assertEquals(Label.errMsg_ErrorDeletingStrategy, result);
        
        //test strategy with unqualified opp
        String strategyId = cps.Id;
        
        Potential_Opportunity__c uo = new Potential_Opportunity__c();
        uo.Client_Plan__c = plan.Id;
        uo.Client_Plan_Strategy__c = strategyId;
        uo.Name = 'Test Potential Opportunity';
        List<Potential_Opportunity__c> uos = new List<Potential_Opportunity__c>{uo};
        insert uos;
        
        result = ClientPlanStrategyController.removeStrategy(cps.Id);
        System.assertEquals(Label.errMsg_StrategyHasOpportunities, result);
    }
    
    static testMethod void testDeleteStrategyDmlErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps1 = new Client_Plan_Strategy__c();
        cps1.Client_Plan__c = plan.Id;
        //insert cps1;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        String strategyId = cps1.Id;
        
        Test.startTest();
        String result = ClientPlanStrategyController.removeStrategy(strategyId);
        Test.stopTest();
        
        System.assertEquals(Label.errMsg_ErrorDeletingStrategy, result);
        //System.assertEquals(Label.errMsg_ErrorDeletingStrategy, ctrl.errorMessage);
    }
    
    static testMethod void testDeleteStrategy() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        String strategyId = cps.Id;
        
        Test.startTest();
        String result = ClientPlanStrategyController.removeStrategy(strategyId);
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
    }
    
    static testMethod void testEditRichTextDmlErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps1 = new Client_Plan_Strategy__c();
        cps1.Client_Plan__c = plan.Id;
        cps1.Bank_Strategy__c = 'something';
        insert cps1;
        
        Client_Plan_Strategy__c cps2 = new Client_Plan_Strategy__c();
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.isClientStrategy = false;
        ctrl.strategyId = cps1.Id;     
        ctrl.strategiesMap.put(cps1.Id, cps2);
        ctrl.clientContent = 'asdf';
    
        Test.startTest();
        PageReference result = ctrl.editStrategy();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringSaving, ctrl.errorMessage);
    }
    
    static testMethod void testEditRichTextErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        Test.startTest();
        PageReference result = ctrl.editStrategy();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringSaving, ctrl.errorMessage);
    }
    
    static testMethod void testEditRichText() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        cps.Client_Strategy__c = 'something';
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.isClientStrategy = true;
        ctrl.strategyId = cps.Id;
        
        String expextedContent = 'other thing';
        ctrl.clientContent = expextedContent;
        
        Test.startTest();
        PageReference result = ctrl.editStrategy();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        System.assertEquals(expextedContent, ctrl.strategiesMap.get(cps.Id).Client_Strategy__c);
        
        List<Client_Plan_Strategy__c> cpss = [SELECT Client_Strategy__c FROM Client_Plan_Strategy__c 
            WHERE Id = :cps.Id];
            
        System.assertEquals(1, cpss.size());
        System.assertEquals(expextedContent, cpss[0].Client_Strategy__c);
    }
    
    static testMethod void testloadUnqOptyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        Test.startTest();
        PageReference result = ctrl.loadUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorLoadingData, ctrl.errorMessage);
        System.assertEquals(null, ctrl.unqOptyJson);
    }
    
    static testMethod void testloadUnqOpty() {
        //First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
            Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
            
            Client_Plan__c plan = new Client_Plan__c();
            plan.Relationship__c = acc1.Id;
            INSERT plan;

            plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

            //ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
            Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, dataContainer);
        
            Potential_Opportunity__c uo = new Potential_Opportunity__c();
            uo.Client_Plan__c = plan.Id;
            uo.Name = 'Opp 1';
            
            //1420149600000 millis
            uo.Close_Date__c = Date.newInstance(2015, 1, 1);
            uo.Product_Level_3__c = productLvl3.Id;
            uo.Stage__c = 'Potential Opportunity Identified';
            uo.Type__c = 'Cross Sell';
            INSERT uo;
            
            PageReference pr = Page.ClientPlanStrategy;
            pr.getParameters().put('planId', plan.Id);
            Test.setCurrentPage(pr);
            
            ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
            ctrl.unqOptyId = uo.Id;
            
            Test.startTest();
            PageReference result = ctrl.loadUnqOpty();
            Test.stopTest();
            
            System.assertEquals(null, result);
            System.assertEquals(null, ctrl.errorMessage);
            System.assertNotEquals(null, ctrl.unqOptyJson);
            
            String expextedJson = '{"type":"Cross Sell","stage":"Potential Opportunity Identified"' +
                ',"productLvl3Name":"' + productLvl3.Name + '","productLvl3Id":"' + productLvl3.Id + '","productLvl2Name":null,"productLvl2Id":null,"productLvl1Name":null,"productLvl1Id":null,"probability":1,"opportunity":null,"name":"Opp 1","id":"' + uo.Id +
                '","closeDate":1420149600000}';

            System.assertEquals(expextedJson, ctrl.unqOptyJson);
        }
    }
    
    static testMethod void testAddOptyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.closeDateMillisString = 'asdf';
        PageReference result = ctrl.manageOpty();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringAddingOpty, ctrl.errorMessage);
        
        ctrl.closeDateMillisString = '1420149600000';
        result = ctrl.manageOpty();
        System.assertEquals(null, result);
        System.assertEquals(true, ctrl.errorMessage.contains(Label.errMsg_ErrorDuringAddingOpty));
    }
    
    static testMethod void testAddOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.closeDateMillisString = '1420070400000';
        ctrl.optyToAdd.Client_Plan_Strategy__c = cps.Id;
        
        String expectedName = 'Opty 1';
        ctrl.optyToAdd.Name = expectedName;
        
        String expectedStageName = 'Opportunity Identified';
        ctrl.optyToAdd.StageName = expectedStageName;
        
        String expectedType = 'Cross Sell';
        ctrl.optyToAdd.Type = expectedType;
        
        Test.startTest();
        PageReference result = ctrl.manageOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Opportunity> optys = [
            SELECT Name, CloseDate, Client_Plan_Strategy__c, StageName, Type
            FROM Opportunity
        ];
        System.assertEquals(1, optys.size());
        
        Opportunity o = optys[0];
        System.assertEquals(expectedName, o.Name);
        System.assertEquals(Date.newInstance(2015, 1, 1), o.CloseDate);
        System.assertEquals(cps.Id, o.Client_Plan_Strategy__c);
        System.assertEquals(expectedStageName, o.StageName);
        System.assertEquals(expectedType, o.Type);
    }
    
    static testMethod void testAddUnqOptyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.closeDateMillisString = 'asdf';
        ctrl.managedUnqOptyId = '';
        
        Test.startTest();
        PageReference result = ctrl.manageUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringAddingPotOpty, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> optys = [SELECT Id FROM Potential_Opportunity__c];
        System.assertEquals(0, optys.size());
    }
    
    static testMethod void testAddUnqOptyDmlErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        //1.1.2015
        ctrl.closeDateMillisString = '1420063200000';
        ctrl.unqOptyToAdd.Name = '';
        ctrl.managedUnqOptyId = '';
        
        Test.startTest();
        PageReference result = ctrl.manageUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringAddingPotOpty, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> optys = [SELECT Id FROM Potential_Opportunity__c];
        System.assertEquals(0, optys.size());
    }
    
    static testMethod void testAddUnqOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c uo = new Potential_Opportunity__c();
        uo.Client_Plan__c = plan.Id;
        uo.Name = 'Opp 1';
        uo.Client_Plan_Strategy__c = cps.Id;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        //1.1.2015
        ctrl.closeDateMillisString = '1420063200000';
        ctrl.unqOptysMap.put(cps.Id, new List<Potential_Opportunity__c>());
        ctrl.unqOptyToAdd = uo;
        ctrl.managedUnqOptyId = '';
        
        Test.startTest();
        PageReference result = ctrl.manageUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> uos = [SELECT Id FROM Potential_Opportunity__c 
            LIMIT 1];
        System.assertEquals(1, uos.size());
        System.assertEquals(1, ctrl.unqOptysMap.get(cps.Id).size());
        System.assertEquals(1, ctrl.unqOptys.size());
    }
    
    static testMethod void testEditUnqOptyDmlErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c uo = new Potential_Opportunity__c();
        uo.Client_Plan__c = plan.Id;
        uo.Name = 'Opp 1';
        uo.Client_Plan_Strategy__c = cps.Id;
        insert uo;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        //1.1.2015
        ctrl.closeDateMillisString = '1420063200000';
        ctrl.unqOptyToAdd.Name = '';
        ctrl.managedUnqOptyId = uo.Id;
        
        Test.startTest();
        PageReference result = ctrl.manageUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringEditingPotOpty, ctrl.errorMessage);
    }
    
    static testMethod void testEditUnqOptyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.managedUnqOptyId = 'asdf';
        ctrl.closeDateMillisString = 'asdf';
        
        //millis unconvertable
        PageReference result = ctrl.manageUnqOpty();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringEditingPotOpty, ctrl.errorMessage);
        
        //opty not connected to client plan
        //1.1.2015
        ctrl.closeDateMillisString = '1420063200000';
        result = ctrl.manageUnqOpty();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringEditingPotOpty, ctrl.errorMessage);
    }
    
    static testMethod void testEditUnqOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c uo = new Potential_Opportunity__c();
        uo.Client_Plan__c = plan.Id;
        uo.Name = 'Opp 1';
        uo.Client_Plan_Strategy__c = cps.Id;
        insert uo;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.managedUnqOptyId = uo.Id;
        ctrl.closeDateMillisString = '1420063200000';
        
        String expectedName = 'Opp 1 edited';
        ctrl.unqOptyToAdd.Name = expectedName;
        
        Test.startTest();
        PageReference result = ctrl.manageUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> uos = [SELECT Name FROM Potential_Opportunity__c 
            WHERE Id = :uo.Id];
        System.assertEquals(1, uos.size());
        System.assertEquals(expectedName, uos[0].Name);
        
        System.assertEquals(1, ctrl.unqOptys.size());
        System.assertEquals(expectedName, ctrl.unqOptys[0].Name);
    }
    
    static testMethod void testConvertCloseDateMillis() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        //millis = 0
        ctrl.closeDateMillisString = '0';
        Boolean result = ctrl.convertCloseDateMillis(true);
        System.assertEquals(false, result);
        
        //millis unconvertable
        ctrl.closeDateMillisString = 'asdf';
        result = ctrl.convertCloseDateMillis(true);
        System.assertEquals(true, result);
        
        //millis = 1.1.2015
        ctrl.closeDateMillisString = '1420070400000';
        result = ctrl.convertCloseDateMillis(true);
        System.assertEquals(false, result);
        
        Date expexted = Date.newInstance(2015, 1, 1);
        System.assertEquals(expexted, ctrl.unqOptyToAdd.Close_Date__c);
    }
    
    static testMethod void testConstructor() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c uo1 = new Potential_Opportunity__c();
        uo1.Client_Plan__c = plan.Id;
        uo1.Name = 'Opp 1';
        uo1.Client_Plan_Strategy__c = cps.Id;
        
        Potential_Opportunity__c uo2 = new Potential_Opportunity__c();
        uo2.Client_Plan__c = plan.Id;
        uo2.Name = 'Opp 1';
        uo2.Client_Plan_Strategy__c = cps.Id;
        
        List<Potential_Opportunity__c> uos = new List<Potential_Opportunity__c>{uo1, uo2};
        insert uos;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
        //unq opty to add
        System.assertEquals('0', ctrl.closeDateMillisString);
        System.assertEquals(plan.Id, ctrl.unqOptyToAdd.Client_Plan__c);
        
        //plan querying
        System.assertEquals(true, ctrl.planLoaded);
        System.assertEquals(plan.Id, ctrl.plan.Id);
        
        //strategies querying
        System.assertEquals(1, ctrl.strategies.size());
        System.assertEquals(cps.Id, ctrl.strategies[0].Id);
        System.assertEquals(true, ctrl.strategiesMap.containsKey(ctrl.strategies[0].Id));
        
        //unq optys querying
        System.assertEquals(2, ctrl.unqOptys.size());
        System.assertEquals(true, ctrl.unqOptysMap.containsKey(cps.Id));
        System.assertEquals(2, ctrl.unqOptysMap.get(cps.Id).size());
    }
    
    static testMethod void testCheckUnqOptyConvertibility() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
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
    
    static testMethod void testGetSetErrorMessage() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        String errorMessage = 'something';
        
        //setter
        ctrl.setErrorMessage(errorMessage);
        System.assertEquals(errorMessage, ctrl.errorMessage);
        
        //getter
        String result = ctrl.getErrorMessage();
        System.assertEquals(errorMessage, result);
        System.assertEquals(null, ctrl.errorMessage);
    }
    
    static testMethod void testConvertUnqOptyErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c uo1 = new Potential_Opportunity__c();
        uo1.Client_Plan__c = plan.Id;
        uo1.Name = 'Opp 1';
        uo1.Client_Plan_Strategy__c = cps.Id;
        insert uo1;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        
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
        insert cps;
        
        Potential_Opportunity__c uo1 = new Potential_Opportunity__c();
        uo1.Client_Plan__c = plan.Id;
        uo1.Client_Plan_Strategy__c = cps.Id;
        uo1.Name = 'Opp 1';
        uo1.Close_Date__c = Date.today();
        uo1.Type__c = 'Cross Sell';
        uo1.Stage__c = 'Potential Opportunity Convert';
        insert uo1;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.managedUnqOptyId = uo1.Id;
        
        Test.startTest();
        PageReference result = ctrl.convertUnqOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> uos = [
            SELECT Opportunity__c, Client_Plan_Strategy__r.Client_Plan__r.Relationship__c
            FROM Potential_Opportunity__c 
            WHERE Id = :uo1.Id];
        System.assertEquals(1, uos.size());    
        System.assertNotEquals(null, uos[0].Opportunity__c);
        
        List<Opportunity> optys = [SELECT Name, CloseDate, Type, StageName, AccountId 
            FROM Opportunity WHERE Id = :uos[0].Opportunity__c];
        System.assertEquals(1, optys.size());
        
        Opportunity opty = optys[0];
        System.assertEquals(uo1.Name, opty.Name);
        System.assertEquals(uo1.Close_Date__c, opty.CloseDate);
        System.assertEquals(uo1.Type__c, opty.Type);
        System.assertEquals('Opportunity Identified', opty.StageName);
        System.assertEquals(uos[0].Client_Plan_Strategy__r.Client_Plan__r.Relationship__c,
            opty.AccountId);
    }
    
    static testMethod void testLinkOptysErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //fake id preparation
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.optysToLinkJson = 'asdf';
        PageReference result = ctrl.linkOptys();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringLinkingOptys, ctrl.errorMessage);
        
        ctrl.optysToLinkJson = '["' + cps.Id + '"]';
        result = ctrl.linkOptys();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringLinkingOptys, ctrl.errorMessage);
    }
    
    static testMethod void testLinkOptysErrors2() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Administrator');

        System.runAs(u1) {
            Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
            cps.Client_Plan__c = plan.Id;
            INSERT cps;
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
                
            opty.AccountId = plan.Relationship__c;
            UPDATE opty;
            
            PageReference pr = Page.ClientPlanStrategy;
            pr.getParameters().put('planId', plan.Id);
            Test.setCurrentPage(pr);
            
            ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
            ctrl.optysToLinkJson = '["' + opty.Id + '"]';
            ctrl.strategyId = 'asdf';
            
            PageReference result = ctrl.linkOptys();
            System.assertEquals(null, result);
            System.assertEquals(Label.errMsg_ErrorDuringLinkingOptys, ctrl.errorMessage);
        }
    }
    
    static testMethod void testLinkOptys() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Administrator');

        System.runAs(u1) {
            Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
            cps.Client_Plan__c = plan.Id;
            INSERT cps;
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
                
            opty.AccountId = plan.Relationship__c;
            UPDATE opty;
            
            PageReference pr = Page.ClientPlanStrategy;
            pr.getParameters().put('planId', plan.Id);
            Test.setCurrentPage(pr);
            
            ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
            ctrl.optysToLinkJson = '["' + opty.Id + '"]';
            ctrl.strategyId = cps.Id;
            
            PageReference result = ctrl.linkOptys();
            System.assertEquals(null, result);
            System.assertEquals(null, ctrl.errorMessage);
            
            List<Opportunity> optys = [SELECT Client_Plan_Strategy__c FROM Opportunity WHERE Id = :opty.Id];
            System.assertEquals(1, optys.size());
            System.assertEquals(cps.Id, optys[0].Client_Plan_Strategy__c);
        }
    }
    
    static testMethod void testUnlinkOptysErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.optyId = 'asdf';
        
        PageReference result = ctrl.unlinkOpty();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorUnlinkingOptys, ctrl.errorMessage);
    }
    
    static testMethod void testUnlinkOptys() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Administrator');

        System.runAs(u1) {
            Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
            cps.Client_Plan__c = plan.Id;
            INSERT cps;
            
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                dataContainer);
                
            opty.AccountId = plan.Relationship__c;
            opty.Client_Plan_Strategy__c = cps.Id;
            UPDATE opty;
            
            PageReference pr = Page.ClientPlanStrategy;
            pr.getParameters().put('planId', plan.Id);
            Test.setCurrentPage(pr);
            
            ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
            ctrl.optyId = opty.Id;
            
            Test.startTest();
            PageReference result = ctrl.unlinkOpty();
            Test.stopTest();
            
            System.assertEquals(null, result);
            System.assertEquals(null, ctrl.errorMessage);
            
            List<Opportunity> optys = [SELECT Client_Plan_Strategy__c FROM Opportunity WHERE Id = :opty.Id];
            System.assertEquals(1, optys.size());
            System.assertEquals(null, optys[0].Client_Plan_Strategy__c);
        }
    }
    
    static testMethod void testAddOpportunity(){
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;

        //1.1.2015
        String closeDate = '1420063200000';

        String result = ClientPlanStrategyController.addOpportunity(cps.Id, 'Test Opp', 'Identified', '', '', closeDate, plan.Id);

        List<Opportunity> opptys = [SELECT Id, Name FROM Opportunity WHERE Client_Plan_Strategy__c = :cps.Id];
        System.assertEquals(1, opptys.size());
        System.assertEquals(result, opptys[0].Id);
    }

    static testMethod void testDeleteUnqOpty(){
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;

        Potential_Opportunity__c uo = new Potential_Opportunity__c();
        uo.Client_Plan__c = plan.Id;
        uo.Client_Plan_Strategy__c = cps.Id;
        uo.Name = 'Opp 1';
        
        //1420149600000 millis
        uo.Close_Date__c = Date.newInstance(2015, 1, 1);
        uo.Product_Level_3__c = productLvl31.Id;
        uo.Stage__c = 'Potential Opportunity Identified';
        uo.Type__c = 'Cross Sell';
        insert uo;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.unqOptyId = uo.Id;

        Test.startTest();

        List<Potential_Opportunity__c> potentialOpptys = [SELECT Id, Name FROM Potential_Opportunity__c WHERE Client_Plan_Strategy__c = :cps.Id];
        System.assertEquals(1, potentialOpptys.size());

        PageReference result = ctrl.deleteUnqOpty();

        potentialOpptys = [SELECT Id, Name FROM Potential_Opportunity__c WHERE Client_Plan_Strategy__c = :cps.Id];
        System.assertEquals(0, potentialOpptys.size());

        Test.stopTest();
    }



static testMethod void testLinkPotOptysErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //fake id preparation
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.potOptysToLinkJson = 'asdf';
        PageReference result = ctrl.linkPotOptys();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringLinkingPotOptys, ctrl.errorMessage);
        
        ctrl.potOptysToLinkJson = '["' + cps.Id + '"]';
        result = ctrl.linkPotOptys();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringLinkingPotOptys, ctrl.errorMessage);
    }
    
    static testMethod void testLinkPotOptysErrors2() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c potOpp = new Potential_Opportunity__c();
        potOpp.Client_Plan__c = plan.Id;
        potOpp.Name = 'test name';
        insert potOpp;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.potOptysToLinkJson = '["' + potOpp.Id + '"]';
        ctrl.strategyId = 'asdf';
        
        PageReference result = ctrl.linkPotOptys();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringLinkingPotOptys, ctrl.errorMessage);
    }
    
    static testMethod void testLinkPotOptys() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c potOpp = new Potential_Opportunity__c();
        potOpp.Client_Plan__c = plan.Id;
        potOpp.Name = 'test name';
        insert potOpp;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.potOptysToLinkJson = '["' + potOpp.Id + '"]';
        ctrl.strategyId = cps.Id;
        
        PageReference result = ctrl.linkPotOptys();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> potOptys = [SELECT Client_Plan_Strategy__c FROM Potential_Opportunity__c WHERE Id = :potOpp.Id];
        System.assertEquals(1, potOptys.size());
        System.assertEquals(cps.Id, potOptys[0].Client_Plan_Strategy__c);
    }
    
    static testMethod void testUnlinkPotOptysErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.potOptyId = 'asdf';
        
        PageReference result = ctrl.unlinkPotOpty();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorUnlinkingPotOptys, ctrl.errorMessage);
    }
    
    static testMethod void testUnlinkPotOptys() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Client_Plan__c = plan.Id;
        insert cps;
        
        Potential_Opportunity__c potOpp = new Potential_Opportunity__c();
        potOpp.Client_Plan__c = plan.Id;
        potOpp.Client_Plan_Strategy__c = cps.Id;
        potOpp.Name = 'test name';
        insert potOpp;
        
        PageReference pr = Page.ClientPlanStrategy;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStrategyController ctrl = new ClientPlanStrategyController();
        ctrl.potOptyId = potOpp.Id;
        
        Test.startTest();
        PageReference result = ctrl.unlinkPotOpty();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        List<Potential_Opportunity__c> potOptys = [SELECT Client_Plan_Strategy__c FROM Potential_Opportunity__c WHERE Id = :potOpp.Id];
        System.assertEquals(1, potOptys.size());
        System.assertEquals(null, potOptys[0].Client_Plan_Strategy__c);
    }    
    
}