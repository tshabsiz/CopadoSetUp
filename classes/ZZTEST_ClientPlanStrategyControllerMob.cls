/**
* @Author:        Marta Malinowska
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanStrategyControllerMobile class
*                 Tests executed:
*                 1 - testGetStrategies()
*                   Tests query of strategies for client plan
*                 2 - testGetStrategiesByName()
*                   Tests query of strategies for client plan and name started with provided text
*                 3 - testGetStrategy()
*                   Tests query of strategy
*                 4 - testAddStrategy()
*                   Tests adding new strategy for client plan
*                 5 - testAddStrategyError()
*                   Tests error while adding new strategy for client plan
*                 6 - testEditStrategy()
*                   Tests editing of strategy
*                 7 - testEditStrategyError()
*                   Tests error while editing of strategy
*                 8 - testRemoveStrategy()
*                   Tests removing strategy from client plan
*                 9 - testRemoveStrategyError()
*                   Tests error while removing strategy from client plan
*                 10 - testUnlinkOpty()
*                   Tests unlinking opportunities from strategy
*                 11 - testUnlinkOptyError()
*                   Tests error while unlinking opportunities from strategy
*                 12 - testRemovePotOpty()
*                   Tests removing potential opportunity from strategy
*                 13 - testRemovePotOptyError()
*                   Tests error while removing potential opportunity from strategy
*                 14 - testAddPotOpty()
*                   Tests adding new potential opportunity to strategy
*                 15 - testAddPotOptyError()
*                   Tests error while adding new potential opportunity to strategy
*                 16 - testAddOpty()
*                   Tests adding new opportunity and link to strategy
*                 17 - testAddOptyError()
*                   Tests error while adding new opportunity and link to strategy
*                 18 - testEditPotOpty()
*                   Tests editing potential opportunity
*                 19 - testEditPotOptyError()
*                   Tests error while editing potential opportunity
*                 20 - testLinkOptys()
*                   Tests linking opportunities to strategy
*                 21 - testEditRichtextField()
*                   Tests editation of rich texts fields on a strategy
*                 22 - testConvertUnqOpty()
*                   Tests conversion of pot opty to opty
*                 23 - testGetOptysToLink()
*                   Tests getter of potential opportunities available for linking
*                 24 - testLinkPotOptys()
*                   Tests linking if potential opportunities to strategies
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanStrategyControllerMob {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
            Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
            
            Client_Plan__c ap = new Client_Plan__c();
            ap.Relationship__c = acc1.Id;
            insert ap;
            
            List<Client_Plan_Strategy__c> strategies = new List<Client_Plan_Strategy__c>();
            Client_Plan_Strategy__c primaryStrategy = new Client_Plan_Strategy__c(Name='Primary Strategy', Client_Plan__c=ap.Id);
            Client_Plan_Strategy__c otherStrategy1 = new Client_Plan_Strategy__c(Name='Other Strategy 1', Client_Plan__c=ap.Id);
            Client_Plan_Strategy__c otherStrategy2 = new Client_Plan_Strategy__c(Name='Other Strategy 2', Client_Plan__c=ap.Id);
            strategies.add(primaryStrategy);
            strategies.add(otherStrategy1);
            strategies.add(otherStrategy2);
            insert strategies;
            
            List<Opportunity> opportunities = new List<Opportunity>();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            for(Integer i=0; i<4; i++){
                Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opp.AccountId = acc1.Id;
                opp.Client_Plan_Strategy__c = Math.mod(i, 2) == 0 ? primaryStrategy.Id : null;
                opportunities.add(opp);
            }
            insert opportunities;
            
            List<Potential_Opportunity__c> potentialOpportunities = new List<Potential_Opportunity__c>();
            potentialOpportunities.add(new Potential_Opportunity__c(Name='Potential Opp 1', Client_Plan__c=ap.Id, Client_Plan_Strategy__c=primaryStrategy.Id));
            potentialOpportunities.add(new Potential_Opportunity__c(Name='Potential Opp 2', Client_Plan__c=ap.Id, Client_Plan_Strategy__c=primaryStrategy.Id));
            insert potentialOpportunities;
        }
        
    }

    static testMethod void testGetStrategies() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        List<Client_Plan_Strategy__c> result = ClientPlanStrategyControllerMobile.getStrategies(plan.Id, null);
        System.assertEquals(3, result.size());
    }

    static testMethod void testGetStrategiesByName() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        List<Client_Plan_Strategy__c> result = ClientPlanStrategyControllerMobile.getStrategies(plan.Id, 'Primary');
        System.assertEquals(1, result.size());
    }

    static testMethod void testGetStrategy() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Client_Plan_Strategy__c result = ClientPlanStrategyControllerMobile.getStrategy(strategy.Id);
        System.assertEquals('Primary Strategy', result.Name);
    }

    static testMethod void testAddStrategy() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        Boolean result = ClientPlanStrategyControllerMobile.addStrategy(plan.Id, 'New Strategy');
        System.assertEquals(false, result);

        List<Client_Plan_Strategy__c> newStrategies = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                                        WHERE Client_Plan__c = :plan.Id AND Name = 'New Strategy'];
        System.assertEquals(1, newStrategies.size());
    }

    static testMethod void testAddStrategyError() {
        Boolean result = ClientPlanStrategyControllerMobile.addStrategy(null, null);
        System.assertEquals(true, result);
    }

    static testMethod void testEditStrategy() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Boolean result = ClientPlanStrategyControllerMobile.editStrategy(strategy.Id, 'Primary Strategy - UPDATED');
        System.assertEquals(false, result);

        List<Client_Plan_Strategy__c> primaryStrategies = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                                        WHERE Client_Plan__c = :plan.Id AND Name = 'Primary Strategy - UPDATED'];
        System.assertEquals(1, primaryStrategies.size());    
        }
        
    }

    static testMethod void testEditStrategyError() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Boolean result = ClientPlanStrategyControllerMobile.editStrategy(null, null);
            System.assertEquals(true, result);    
        }
        
    }

    static testMethod void testRemoveStrategy() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Boolean result = ClientPlanStrategyControllerMobile.removeStrategy(strategy.Id);
        System.assertEquals(false, result);

        List<Client_Plan_Strategy__c> primaryStrategies = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                                        WHERE Client_Plan__c = :plan.Id AND Name = 'Primary Strategy'];
        System.assertEquals(0, primaryStrategies.size());
    }

    static testMethod void testRemoveStrategyError() {
        Boolean result = ClientPlanStrategyControllerMobile.removeStrategy(null);
        System.assertEquals(true, result);
    }

    static testMethod void testUnlinkOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name, (SELECT Id, Name FROM Opportunities__r) FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Boolean result = ClientPlanStrategyControllerMobile.unlinkOpty(strategy.Opportunities__r[0].Id);
        System.assertEquals(false, result);

        List<Opportunity> linkedOpportunities = [SELECT Id, Name FROM Opportunity WHERE Client_Plan_Strategy__c = :strategy.Id];
        System.assertEquals(1, linkedOpportunities.size());
    }

    static testMethod void testUnlinkOptyError() {
        Boolean result = ClientPlanStrategyControllerMobile.unlinkOpty(null);
        System.assertEquals(true, result);
    }

    static testMethod void testRemovePotOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name, (SELECT Id, Name FROM Unqualified_Opportunities__r) FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Boolean result = ClientPlanStrategyControllerMobile.removePotOpty(strategy.Unqualified_Opportunities__r[0].Id);
        System.assertEquals(false, result);

        List<Potential_Opportunity__c> potentialOpportunities = [SELECT Id, Name FROM Potential_Opportunity__c WHERE Client_Plan_Strategy__c = :strategy.Id];
        System.assertEquals(1, potentialOpportunities.size());
    }

    static testMethod void testRemovePotOptyError() {
        Boolean result = ClientPlanStrategyControllerMobile.removePotOpty(null);
        System.assertEquals(true, result);
    }

    static testMethod void testAddPotOpty() {
      
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        Datetime dt = Datetime.now();
        String closeDate = String.valueOf(dt.getTime());

        Map<String, List<String>> metadata = ClientPlanStrategyControllerMobile.getPotOptyMetadata();
        List<String> stages = metadata.get('stage');
        List<String> types = metadata.get('type');

        Boolean result = ClientPlanStrategyControllerMobile.addPotOpty(plan.Id, strategy.Id, 'New Potential Opp', closeDate, 
            productLvl31.Id, stages[0], '50', types[0]);
        System.assertEquals(false, result);

        List<Potential_Opportunity__c> potentialOpportunities = [SELECT Id, Name FROM Potential_Opportunity__c WHERE Client_Plan_Strategy__c = :strategy.Id];
        System.assertEquals(3, potentialOpportunities.size());    
        }
        
    }

    static testMethod void testAddPotOptyError() {
        Boolean result = ClientPlanStrategyControllerMobile.addPotOpty(null, null, 'New Potential Opp', null, null, null, null, null);
        System.assertEquals(true, result);
    }

    static testMethod void testAddOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Datetime dt = Datetime.now();
        String closeDate = String.valueOf(dt.getTime());

        Map<String, List<String>> metadata = ClientPlanStrategyControllerMobile.getOptyMetadata();
        List<String> stages = metadata.get('stage');
        List<String> types = metadata.get('type');

        Boolean result = ClientPlanStrategyControllerMobile.addOpty(plan.Id, strategy.Id, 'New Opportunity', closeDate, stages[0], null, types[0]);
        System.assertEquals(false, result);

        List<Opportunity> linkedOpportunities = [SELECT Id, Name FROM Opportunity WHERE Client_Plan_Strategy__c = :strategy.Id];
        System.assertEquals(3, linkedOpportunities.size());
    }

    static testMethod void testAddOptyError() {
        Boolean result = ClientPlanStrategyControllerMobile.addOpty(null, null, 'New Opportunity', null, null, null, null);
        System.assertEquals(true, result);
    }

    static testMethod void testEditPotOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name, (SELECT Id, Name FROM Unqualified_Opportunities__r) FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);

        Id potOppId = strategy.Unqualified_Opportunities__r[0].Id;

        Datetime dt = Datetime.now();
        String closeDate = String.valueOf(dt.getTime());

        Map<String, List<String>> metadata = ClientPlanStrategyControllerMobile.getOptyMetadata();
        List<String> stages = metadata.get('stage');
        List<String> types = metadata.get('type');

        Boolean result = ClientPlanStrategyControllerMobile.editPotOpty(potOppId, 'Opportunity - UPDATED', closeDate, 
            productLvl31.Id, stages[0], null, types[0]);
        System.assertEquals(false, result);

        Potential_Opportunity__c potentialOpp = [SELECT Id, Name, Close_Date__c, Product_Level_3__c, Stage__c, Probability__c, Type__c 
                                                FROM Potential_Opportunity__c WHERE Id = :potOppId];
        System.assertEquals('Opportunity - UPDATED', potentialOpp.Name);
        System.assertEquals(dt.date(), potentialOpp.Close_Date__c);
        System.assertEquals(productLvl31.Id, potentialOpp.Product_Level_3__c);
        System.assertEquals(stages[0], potentialOpp.Stage__c);
        System.assertEquals(types[0], potentialOpp.Type__c);
    }

    static testMethod void testEditPotOptyError() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            Boolean result = ClientPlanStrategyControllerMobile.editPotOpty(null, 'Opportunity - UPDATED', null, null, null, null, null);
            System.assertEquals(true, result);    
        }
        
    }

    static testMethod void testLinkOptys() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        List<Opportunity> optysToLink = ClientPlanStrategyControllerMobile.getOptysToLink(plan.Id);
        System.assertEquals(2, optysToLink.size());

        List<String> optysToLinkIds = new List<String>();
        for(Opportunity opp : optysToLink){
            optysToLinkIds.add(opp.Id);
        }

        Boolean result = ClientPlanStrategyControllerMobile.linkOptys(strategy.Id, optysToLinkIds);
        System.assertEquals(false, result);
    }

    static testMethod void testEditRichtextField() {
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [
            SELECT Id, Client_Strategy__c, Bank_Strategy__c 
            FROM Client_Plan_Strategy__c 
            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1
        ];

        //not-existing strategyId
        Boolean result = ClientPlanStrategyControllerMobile.editRichtextField(null, null, true);
        System.assertEquals(true, result);
        
        //client editation
        result = ClientPlanStrategyControllerMobile.editRichtextField(strategy.Id, 'aaa', true);
        System.assertEquals(false, result);

        List<Client_Plan_Strategy__c> strategies = [
            SELECT Id, Client_Strategy__c, Bank_Strategy__c 
            FROM Client_Plan_Strategy__c 
            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1
        ];
        System.assertEquals(false, strategies.isEmpty());
        System.assertEquals('aaa', strategies[0].Client_Strategy__c);

        //bank editation
        result = ClientPlanStrategyControllerMobile.editRichtextField(strategy.Id, 'bbb', false);
        System.assertEquals(false, result);

        strategies = [
            SELECT Id, Client_Strategy__c, Bank_Strategy__c 
            FROM Client_Plan_Strategy__c 
            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1
        ];
        System.assertEquals(false, strategies.isEmpty());
        System.assertEquals('bbb', strategies[0].Bank_Strategy__c);    
        }
        
    }

    //coverage test, this functionality is tested in ZZTEST_ClientPlanUtils
    static testMethod void testConvertUnqOpty() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [
            SELECT Id, Client_Strategy__c, Bank_Strategy__c 
            FROM Client_Plan_Strategy__c 
            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1
        ];

        Boolean result = ClientPlanStrategyControllerMobile.convertUnqOpty(strategy.Id);
        System.assertEquals(true, result);
    }

    static testMethod void testGetPotOptysToLink() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Potential_Opportunity__c opty = new Potential_Opportunity__c(Name = 'Potential Opp 1', Client_Plan__c = plan.Id);
        insert opty;

        List<Potential_Opportunity__c> result = ClientPlanStrategyControllerMobile.getPotOptysToLink(plan.Id);
        System.assertEquals(1, result.size());
        System.assertEquals(opty.Id, result[0].Id);
    }

    static testMethod void testLinkPotOptys() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        Client_Plan_Strategy__c strategy = [SELECT Id, Name FROM Client_Plan_Strategy__c 
                                            WHERE Client_Plan__c = :plan.Id AND Name like 'Primary%' LIMIT 1];

        Potential_Opportunity__c opty = new Potential_Opportunity__c(Name = 'Potential Opp 1', Client_Plan__c = plan.Id);
        insert opty;

        //null strategyId
        Boolean result = ClientPlanStrategyControllerMobile.linkPotOptys(null, null);
        System.assertEquals(true, result);

        //null list of potIds
        result = ClientPlanStrategyControllerMobile.linkPotOptys(strategy.Id, null);
        System.assertEquals(true, result);

        //not-existing strategyId
        result = ClientPlanStrategyControllerMobile.linkPotOptys('asdf', new List<String>{opty.Id});
        System.assertEquals(true, result);

        //empty list of potIds
        result = ClientPlanStrategyControllerMobile.linkPotOptys(strategy.Id, new List<String>());
        System.assertEquals(false, result);

        //working code
        result = ClientPlanStrategyControllerMobile.linkPotOptys(strategy.Id, new List<String>{opty.Id});
        System.assertEquals(false, result);

        List<Potential_Opportunity__c> optysResult = [
            SELECT Client_Plan_Strategy__c
            FROM Potential_Opportunity__c
            WHERE Id = :opty.Id
        ];
        System.assertEquals(1, optysResult.size());
        System.assertEquals(strategy.Id, optysResult[0].Client_Plan_Strategy__c);
    }

}