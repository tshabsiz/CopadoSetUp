/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanOrgStructureController
*                 Tests executed:
*                 1 - testGetSectorOverviewErrors()
*                   Tests errors handling of getSectorOverview method
*                 2 - testGetSectorOverviewNullValue()
*                   Tests obtaining data from field with null value
*                 3 - testGetSectorOverview()
*                   Tests getSectorOverview method
*                 4 - testGetClientOverviewErrors()
*                   Tests errors handling of getClientOverview method
*                 5 - testGetClientOverviewNullValue()
*                   Tests obtaining data from field with null value
*                 6 - testGetClientOverview()
*                   Tests getClientOverview method
*                 7 - testSaveRichtextErrors()
*                   Tests error handling of saveRichtext method
*                 8 - testSaveRichtextSector()
*                   Tests saveRichtext method with sector overview
*                 9 - testSaveRichtextClient()
*                   Tests saveRichtext method with client overview
*                 10 - testConstructor()
*                   Tests constructor
*                 11 - testRemoveScoreErrors()
*                   Tests errors handling during removing score
*                 12 - testRemoveScore()
*                   Tests removing score
*                 13 - testAddScoreErrors()
*                   Tests errors handling during adding score
*                 14 - testAddWeakness()
*                   Tests adding a weakness
*                 15 - testAddStrength()
*                   Tests adding a weakness
*                 16 - testEditScoreErrors()
*                   Tests error handling during score editation
*                 17 - testEditScore()
*                   Tests score editation
*                 18 - testErrorMessages()
*                   Tests of methods handling error messaged
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*22.2.2016      Svata Sejkora     Adding test methods for new controller methods
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientOverviewController { 
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testGetSectorOverviewErrors() {
        String result = ClientOverviewController.getSectorOverview(null);
        System.assertEquals(null, result);
        
        result = ClientOverviewController.getSectorOverview('asdf');
        System.assertEquals(null, result);
    }
    
    static testMethod void testGetSectorOverviewNullValue() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String result = ClientOverviewController.getSectorOverview(plan.Id);
        System.assertEquals('', result);
    }
    
    static testMethod void testGetSectorOverview() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String content = 'Something';
        plan.Sector_Overview__c = content;
        update plan;
        
        String result = ClientOverviewController.getSectorOverview(plan.Id);
        System.assertEquals(content, result);
    }
    
    static testMethod void testGetClientOverviewErrors() {
        String result = ClientOverviewController.getClientOverview(null);
        System.assertEquals(null, result);
        
        result = ClientOverviewController.getClientOverview('asdf');
        System.assertEquals(null, result);
    }
    
    static testMethod void testGetClientOverviewNullValue() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String result = ClientOverviewController.getClientOverview(plan.Id);
        System.assertEquals('', result);
    }
    
    static testMethod void testGetClientOverview() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String content = 'Something';
        plan.Client_Overview__c = content;
        update plan;
        
        String result = ClientOverviewController.getClientOverview(plan.Id);
        System.assertEquals(content, result);
    }
    
    static testMethod void testSaveRichtextErrors() {
        Boolean result = ClientOverviewController.saveRichtext(null, '', true);
        System.assertEquals(true, result);
        
        result = ClientOverviewController.saveRichtext('asdf', '', true);
        System.assertEquals(true, result);
    }
    
    static testMethod void testSaveRichtextSector() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String sectorContent = 'Something';
        
        Test.startTest();
        Boolean result = ClientOverviewController.saveRichtext(plan.Id, sectorContent, true);
        Test.stopTest();
        
        System.assertEquals(false, result);
        
        List<Client_Plan__c> plans = [
            SELECT Sector_Overview__c
            FROM Client_Plan__c 
            WHERE Id = :plan.Id];
            
        System.assertEquals(1, plans.size());
        System.assertEquals(sectorContent, plans[0].Sector_Overview__c);
    }
    
    static testMethod void testSaveRichtextClient() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String clientContent = 'Something';
        
        Test.startTest();
        Boolean result = ClientOverviewController.saveRichtext(plan.Id, clientContent, false);
        Test.stopTest();
        
        System.assertEquals(false, result);
        
        List<Client_Plan__c> plans = [
            SELECT Client_Overview__c
            FROM Client_Plan__c 
            WHERE Id = :plan.Id];
            
        System.assertEquals(1, plans.size());
        System.assertEquals(clientContent, plans[0].Client_Overview__c);
    }
    
    static testMethod void testConstructor() {
        //no planId url parameter
        PageReference pr = Page.ClientOverview;
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        System.assertEquals(false, ctrl.planLoaded);
        
        //planId url parameter with wrong value
        pr = Page.ClientOverview;
        pr.getParameters().put('planId', 'asdf');
        Test.setCurrentPage(pr);
        ctrl = new ClientOverviewController();
        System.assertEquals(false, ctrl.planLoaded);
        
        //correct planId
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ctrl = new ClientOverviewController();
        System.assertEquals(true, ctrl.planLoaded);
    }
    
    static testMethod void testRemoveScoreErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        ctrl.scoreType = 'Strength';
        
        PageReference result = ctrl.removeScore();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_RecordNotFound, ctrl.getErrorMessage());
    }
    
    static testMethod void testRemoveScore() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Score__c cs1 = new Client_Score__c();
        cs1.Client_Plan__c = plan.Id;
        cs1.Score_Type__c = 'Strength';
        
        Client_Score__c cs2 = new Client_Score__c();
        cs2.Client_Plan__c = plan.Id;
        cs2.Score_Type__c = 'Weakness';
        
        insert new List<Client_Score__c>{cs1, cs2};
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        ctrl.scoreId = cs1.Id;
        ctrl.scoreType = 'Strength';
        
        PageReference result = ctrl.removeScore();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Score__c> css = [SELECT Id FROM Client_Score__c];
        System.assertEquals(1, css.size());
        System.assertEquals(cs2.Id, css[0].Id);
    }
    
    static testMethod void testAddScoreErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        ctrl.scoreType = 'Weakness';
        ctrl.scoreId = '';
        ctrl.scoreName = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        
        PageReference result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorAddingClientWeakness, ctrl.getErrorMessage());
        System.assertEquals(0, ctrl.weaknesses.size());
        
        ctrl.scoreType = 'Strength';
        result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorAddingClientStrength, ctrl.getErrorMessage());
        System.assertEquals(0, ctrl.strengths.size());
    }
    
    static testMethod void testAddWeakness() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        
        ctrl.scoreType = 'Weakness';
        ctrl.scoreId = '';
        String expName = 'asdf';
        ctrl.scoreName = expName;
        String expDesc = 'desc';
        ctrl.description = expDesc;
        
        PageReference result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        System.assertEquals(1, ctrl.weaknesses.size());
        
        List<Client_Score__c> css = [SELECT Client_Plan__c, Score_Type__c, Name, Description__c 
            FROM Client_Score__c];
        System.assertEquals(1, css.size());
        
        Client_Score__c cs = css[0];
        System.assertEquals(plan.Id, cs.Client_Plan__c);
        System.assertEquals('Weakness', cs.Score_Type__c);
        System.assertEquals(expName, cs.Name);
        System.assertEquals(expDesc, cs.Description__c );
    }
    
    static testMethod void testAddStrength() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        
        ctrl.scoreType = 'Strength';
        ctrl.scoreId = '';
        String expName = 'asdf';
        ctrl.scoreName = expName;
        String expDesc = 'desc';
        ctrl.description = expDesc;
        
        PageReference result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        System.assertEquals(1, ctrl.strengths.size());
        
        List<Client_Score__c> css = [SELECT Client_Plan__c, Score_Type__c, Name, Description__c 
            FROM Client_Score__c];
        System.assertEquals(1, css.size());
        
        Client_Score__c cs = css[0];
        System.assertEquals(plan.Id, cs.Client_Plan__c);
        System.assertEquals('Strength', cs.Score_Type__c);
        System.assertEquals(expName, cs.Name);
        System.assertEquals(expDesc, cs.Description__c );
    }
    
    static testMethod void testEditScoreErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Score__c cs1 = new Client_Score__c();
        cs1.Client_Plan__c = plan.Id;
        cs1.Score_Type__c = 'Weakness';
        insert cs1;
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        ctrl.scoreType = 'Weakness';
        
        //record not found
        ctrl.scoreId = 'asdf';
        PageReference result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_RecordNotFound, ctrl.getErrorMessage());
        
        //dml exception
        ctrl.scoreId= cs1.Id;
        ctrl.scoreName = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorDuringEditation, ctrl.getErrorMessage());
    }
    
    static testMethod void testEditScore() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Client_Score__c cs1 = new Client_Score__c();
        cs1.Client_Plan__c = plan.Id;
        cs1.Score_Type__c = 'Strength';
        insert cs1;
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        ctrl.scoreType = 'Strength';
        
        //dml exception
        ctrl.scoreId = cs1.Id;
        String expName = 'asdf';
        ctrl.scoreName = expName;
        String expDesc = 'desc';
        ctrl.description = expDesc; 
        
        PageReference result = ctrl.modifyScore();
        System.assertEquals(null, result);
        System.assertEquals(null, ctrl.getErrorMessage());
        
        List<Client_Score__c> css = [SELECT Id, Name, Description__c FROM Client_Score__c];
        System.assertEquals(1, css.size());
        System.assertEquals(cs1.Id, css[0].Id);
        System.assertEquals(expName, css[0].Name);
        System.assertEquals(expDesc, css[0].Description__c);
    }
    
    static testMethod void testErrorMessages() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientOverview;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        ClientOverviewController ctrl = new ClientOverviewController();
        
        System.assertEquals(null, ctrl.errorMessage);
        
        String expected = 'This is an error message';
        ctrl.setErrorMessage(expected);
        System.assertEquals(expected, ctrl.errorMessage);
        
        String result = ctrl.getErrorMessage();
        System.assertEquals(expected, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        System.assertEquals(null, ctrl.getErrorMessage());
    }
    
}