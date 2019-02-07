/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanOverviewControllerMobile
*                 Tests executed:
*                 1 - testGetClientPlan()
*                   Tests querying of client plan
*                 2 - testEditRichtextField()
*                   Tests querying of client plan
*                 3 - testGetClientScores()
*                   Tests getter of client scores
*                 4 - testAddScore()
*                   Tests adding of client score
*                 5 - testEditScore()
*                   Tests client score editation
*                 6 - testRemoveScore()
*                   Tests removing of client score
*                 7 - testGetImageId()
*                   Tests getter of organogram image Id
*                 8 - testGetOrganogramData()
*                   Tests getter of organogram data
*                 9 - testAddOrgItem()
*                   Tests adding of organogram item
*                 10 - testEditOrgItem()
*                   Tests editation of organogram item
*                 11 - testRemoveOrgItem()
*                   Tests removing of organogram item
*                 12 - testDeleteImage()
*                   Tests deleting of organogram image
*                 13 - testSavingSmallImage()
*                   Tests saving of small organogram image
*                 14 - testSavingLargeImage()
*                   Tests saving of large organogram image
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanOverviewControllerMob {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }

    static testMethod void testGetClientPlan() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        //not-existing planId
        Client_Plan__c result = ClientPlanOverviewControllerMobile.getClientPlan(null);
        System.assertEquals(null, result);
        
        result = ClientPlanOverviewControllerMobile.getClientPlan('asdfasdf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanOverviewControllerMobile.getClientPlan(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(plan.Id, result.Id);
    }

    static testMethod void testEditRichtextField() {

        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];

        //not-existing planId
        Boolean result = ClientPlanOverviewControllerMobile.editRichtextField(null, null, true);
        System.assertEquals(true, result);

        //sector editation
        result = ClientPlanOverviewControllerMobile.editRichtextField(plan.Id, 'aaa', true);
        System.assertEquals(false, result);

        List<Client_Plan__c> plans = [
            SELECT Sector_Overview__c
            FROM Client_Plan__c
            WHERE Id = :plan.Id
        ];
        System.assertEquals(false, plans.isEmpty());
        System.assertEquals('aaa', plans[0].Sector_Overview__c);

        //client editation
        result = ClientPlanOverviewControllerMobile.editRichtextField(plan.Id, 'bbb', false);
        System.assertEquals(false, result);

        plans = [
            SELECT Client_Overview__c
            FROM Client_Plan__c
            WHERE Id = :plan.Id
        ];
        System.assertEquals(false, plans.isEmpty());
        System.assertEquals('bbb', plans[0].Client_Overview__c);
    }

    static testMethod void testGetClientScores() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String scoreId = prepareScore(plan.Id);
        
        //not-existind planId
        List<Client_Score__c> result = ClientPlanOverviewControllerMobile.getClientScores(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanOverviewControllerMobile.getClientScores('asdfasdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanOverviewControllerMobile.getClientScores(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(scoreId, result[0].Id);
    }
    
    static testMethod void testAddScore() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //not-existing planId
        Boolean result = ClientPlanOverviewControllerMobile.addScore(null, null, null, null);
        System.assertEquals(true, result);
        
        List<Client_Score__c> scoresResult = [
            SELECT Id
            FROM Client_Score__c
        ];
        System.assertEquals(0, scoresResult.size());
        
        //working code
        result = ClientPlanOverviewControllerMobile.addScore(plan.Id, 'Str 1', 'desc', 'Strength');
        System.assertEquals(false, result);
        
        scoresResult = [
            SELECT Id, Client_Plan__c, Name, Description__c, Score_Type__c
            FROM Client_Score__c
        ];
        System.assertEquals(1, scoresResult.size());
        System.assertEquals(plan.Id, scoresResult[0].Client_Plan__c);
        System.assertEquals('Str 1', scoresResult[0].Name);
        System.assertEquals('desc', scoresResult[0].Description__c);
        System.assertEquals('Strength', scoresResult[0].Score_Type__c);
    }
    
    static testMethod void testEditScore() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String scoreId = prepareScore(plan.Id);
        
        //not-existing scoreId
        Boolean result = ClientPlanOverviewControllerMobile.editScore(null, null, null);
        System.assertEquals(true, result);
        
        List<Client_Score__c> scoresResult = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
        ];
        System.assertEquals(1, scoresResult.size());
        System.assertEquals('Str 1', scoresResult[0].Name);
        System.assertEquals('something', scoresResult[0].Description__c);
        
        //errors checking
        String newName = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            
        result = ClientPlanOverviewControllerMobile.editScore(scoreId, newName, null);
        System.assertEquals(true, result);
        
        scoresResult = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
        ];
        System.assertEquals(1, scoresResult.size());
        System.assertEquals('Str 1', scoresResult[0].Name);
        System.assertEquals('something', scoresResult[0].Description__c);
        
        //working code
        result = ClientPlanOverviewControllerMobile.editScore(scoreId, 'new name', 'new desc');
        System.assertEquals(false, result);
        
        scoresResult = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
        ];
        System.assertEquals(1, scoresResult.size());
        System.assertEquals('new name', scoresResult[0].Name);
        System.assertEquals('new desc', scoresResult[0].Description__c);
    }
    
    static testMethod void testRemoveScore() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String scoreId = prepareScore(plan.Id);
        
        //not-existing scoreId
        Boolean result = ClientPlanOverviewControllerMobile.removeScore(null);
        System.assertEquals(true, result);
        
        List<Client_Score__c> scoresResult = [
            SELECT Id
            FROM Client_Score__c
        ];
        System.assertEquals(1, scoresResult.size());
        
        //working code
        result = ClientPlanOverviewControllerMobile.removeScore(scoreId);
        System.assertEquals(false, result);
        
        scoresResult = [
            SELECT Id
            FROM Client_Score__c
        ];
        System.assertEquals(0, scoresResult.size());
    }
    
    static testMethod void testGetImageId() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Attachment a = new Attachment();
        a.ParentId = plan.Id;
        a.Name = 'an att';
        a.Body = Blob.valueOf('a body');
        insert a;
        
        //not-existing planId
        String result = ClientPlanOverviewControllerMobile.getImageId(null);
        System.assertEquals('', result);
        
        result = ClientPlanOverviewControllerMobile.getImageId('asdfadsf');
        System.assertEquals('', result);
        
        //working code
        result = ClientPlanOverviewControllerMobile.getImageId(plan.Id);
        System.assertEquals(a.Id, result);
    }
    
    static testMethod void testGetOrganogramData() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String itemId = prepareOrganogramItem(plan.Id);
        
        //not-existing planId
        List<Organisation_Structure_Item__c> result = ClientPlanOverviewControllerMobile.getOrganogramData(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanOverviewControllerMobile.getOrganogramData('asdfasdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //working code
        result = ClientPlanOverviewControllerMobile.getOrganogramData(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(itemId, result[0].Id);
    }
    
    static testMethod void testAddOrgItemErrors() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String itemId = prepareOrganogramItem(plan.Id);
        
        Boolean result = ClientPlanOverviewControllerMobile.addOrgItem(null, null, null, null);
        System.assertEquals(true, result);
        
        result = ClientPlanOverviewControllerMobile.addOrgItem('asdfasdf', null, null, true);
        System.assertEquals(true, result);
        
        result = ClientPlanOverviewControllerMobile.addOrgItem(plan.Id, 'dep', 'asdf', false);
        System.assertEquals(true, result);
    }
    
    static testMethod void testAddOrgItem() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String itemId = prepareOrganogramItem(plan.Id);
        
        Boolean result = ClientPlanOverviewControllerMobile.addOrgItem(plan.Id, 'dep', itemId, false);
        System.assertEquals(false, result);
        
        List<Organisation_Structure_Item__c> items = [
            SELECT Id
            FROM Organisation_Structure_Item__c
        ];
        System.assertEquals(2, items.size());
    }
    
    static testMethod void testEditOrgItem() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String itemId = prepareOrganogramItem(plan.Id);
        
        //null params
        Boolean result = ClientPlanOverviewControllerMobile.editOrgItem(null, null);
        System.assertEquals(true, result);
        
        
        //not-existing item id
        result = ClientPlanOverviewControllerMobile.editOrgItem(null, 'asdfasdf');
        System.assertEquals(true, result);
        
        //errors handling
        String newDescription = '';
        for (Integer i = 0; i < 25; i++) {
            newDescription += 'aaaaaaaaaaa';
        }
        result = ClientPlanOverviewControllerMobile.editOrgItem(newDescription, itemId);
        System.assertEquals(true, result);
        
        //working code
        result = ClientPlanOverviewControllerMobile.editOrgItem('aaa', itemId);
        System.assertEquals(false, result);
    
        List<Organisation_Structure_Item__c> items = [
            SELECT Description__c
            FROM Organisation_Structure_Item__c
        ];
        
        System.assertEquals(1, items.size());
        System.assertEquals(itemId, items[0].Id);
        System.assertEquals('aaa', items[0].Description__c);
    }
    
    static testMethod void testRemoveOrgItem() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String item1Id = prepareOrganogramItem(plan.Id);
        String item2Id = prepareOrganogramItem(plan.Id);
        
        Boolean result = ClientPlanOverviewControllerMobile.removeOrgItem(null);
        System.assertEquals(true, result);
        
        result = ClientPlanOverviewControllerMobile.removeOrgItem(new List<String>());
        System.assertEquals(true, result);
        
        result = ClientPlanOverviewControllerMobile.removeOrgItem(new List<String>{item1Id, item2Id});
        System.assertEquals(false, result);
        
        List<Organisation_Structure_Item__c> items = [
            SELECT Description__c
            FROM Organisation_Structure_Item__c
        ];
        
        System.assertEquals(0, items.size());
    }
    
    static testMethod void testDeleteImage() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String attId = prepareAttachment(plan.Id);
        
        //not-existing attachment id
        ClientPlanOverviewControllerMobile.deleteImage(null);
        
        List<Attachment> atts = [
            SELECT Id
            FROM Attachment
        ];
        System.assertEquals(1, atts.size());
        
        //not-existing attachment id
        ClientPlanOverviewControllerMobile.deleteImage('asdf');
        
        atts = [
            SELECT Id
            FROM Attachment
        ];
        System.assertEquals(1, atts.size());
        
        //existing attachment id
        ClientPlanOverviewControllerMobile.deleteImage(attId);
        
        atts = [
            SELECT Id
            FROM Attachment
        ];
        System.assertEquals(0, atts.size());
    }
    
    static testMethod void testSavingSmallImage() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //null params handling
        Boolean result = ClientPlanOverviewControllerMobile.saveImageChunk(null, null, null, null, null);
        System.assertEquals(true, result);
        
        //not-existing planId
        result = ClientPlanOverviewControllerMobile.saveImageChunk('asdf', 'name', 'data', 'type', false);
        System.assertEquals(true, result);
        
        //working code
        result = ClientPlanOverviewControllerMobile.saveImageChunk(plan.Id, 'name', 'data', 'type', false);
        System.assertEquals(false, result);
        
        List<Attachment> atts = [
            SELECT ParentId, Name, Body, ContentType
            FROM Attachment
        ];
        System.assertEquals(1, atts.size());
        System.assertEquals(plan.Id, atts[0].ParentId);
        System.assertEquals('name', atts[0].Name);
        System.assertEquals('data', EncodingUtil.base64Encode(atts[0].Body));
        System.assertEquals('type', atts[0].ContentType);
    }
    
    static testMethod void testSavingLargeImage() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //no attachment present
        Boolean result = ClientPlanOverviewControllerMobile.saveImageChunk(plan.Id, 'name', 'b', 'type', true);
        System.assertEquals(true, result);
        
        //preparing attachment
        ClientPlanOverviewControllerMobile.saveImageChunk(plan.Id, 'name', 'data', 'type', false);
        
        result = ClientPlanOverviewControllerMobile.saveImageChunk(plan.Id, 'name', 'something', 'type', true);
        System.assertEquals(false, result);
        
        List<Attachment> atts = [
            SELECT ParentId, Name, Body, ContentType
            FROM Attachment
        ];
        System.assertEquals(1, atts.size());
        System.assertEquals(plan.Id, atts[0].ParentId);
        System.assertEquals('name', atts[0].Name);
        System.assertEquals('datasomethin', EncodingUtil.base64Encode(atts[0].Body));
        System.assertEquals('type', atts[0].ContentType);
    }
    
    private static String prepareAttachment(String planId) {
        
        Attachment a = new Attachment();
        a.ParentId = planId;
        a.Name = 'an attachment';
        a.Body = Blob.valueOf('a');
        a.ContentType = 'image/png';
        insert a;
        
        return a.Id;
    }
    
    private static String prepareScore(String planId) {
        Client_Score__c sc = new Client_Score__c();
        sc.Client_Plan__c = planId;
        sc.Name = 'Str 1';
        sc.Description__c = 'something';
        sc.Score_Type__c = 'Strength';
        insert sc;
        
        return sc.Id;
    }
    
    private static String prepareOrganogramItem(String planId) {
        Organisation_Structure_Item__c i = new Organisation_Structure_Item__c();
        i.Description__c = 'desc';
        i.Related_To__c = null;
        i.Client_Plan__c = planId;
        insert i;
        
        return i.Id;
    }

}