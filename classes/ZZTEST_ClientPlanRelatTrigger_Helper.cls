/**
* @Author:        Svatopluk Sejkora
* @Company:       Deloitte
* @Description:   Unit Tests for AccountPlanRelationshipTrigger_Helper
*                   Tests executed:
*                   1 - testDeleteRelationshipItems()
*                       Checks that relationship items are deletedd after deletion of account plan relationship table
*                   2 - testDeleteRelationshipItemsBulk()
*                       Checks that relationship items are deleted after deletion of account plan relationship table for bulk operation
*                       
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 14.10.2015    Svatopluk Sejkora   Adding Test methods for AccountPlanRelationshipTrigger_Helper - US - 0490
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_ClientPlanRelatTrigger_Helper {
    
    private static void createTestData(Integer repeatItem, Integer repeatRela) {
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_COntact contactFactory = ZZTEST_DataFactoryFacade.contact;

        Contact con = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);

        Client_Plan__c accPlan = new Client_Plan__c();
        accPlan.Relationship__c = con.AccountId;
        insert accPlan;

        createTestDataRelationship(repeatItem, repeatRela, accPlan.Id, con.Id);
    }

    private static void createTestDataRelationship(Integer repeatItem, Integer repeatRela, Id accPlanId, Id contactId) {    

        List<Client_Plan_Relationship__c> accPlanRelList = new List<Client_Plan_Relationship__c>();

        for(Integer i = 0; i < repeatRela; i++) {
            Client_Plan_Relationship__c accPlanRel = new Client_Plan_Relationship__c();
                accPlanRel.Client_Plan__c = accPlanId;
                accPlanRel.Client_Strength__c = '3';
                accPlanRel.Comment__c = 'Comment';
                accPlanRel.Contact__c = contactId;
            accPlanRelList.add(accPlanRel); 
        }   
        insert accPlanRelList;

        createTestDataItems(repeatItem, accPlanRelList);
    }
    
    private static void createTestDataItems(Integer repeat, List<Client_Plan_Relationship__c> accPlanRelList) {    

        List<Client_Plan_Relationship_Item__c> accPlanRelItemList = new List<Client_Plan_Relationship_Item__c>();


        for(Client_Plan_Relationship__c accPlanRel : accPlanRelList) {
            for(Integer i = 0; i < repeat; i++) {
                Client_Plan_Relationship_Item__c accPlanRelItem = new Client_Plan_Relationship_Item__c();
                    accPlanRelItem.Client_Plan_Relationship__c = accPlanRel.Id;
                accPlanRelItemList.add(accPlanRelItem); 
            }
        }   
        insert  accPlanRelItemList;
    }

    @isTest
    public static void testDeleteRelationshipItems() {
        // prepare data
        createTestData(4, 1);

        Test.startTest();
            Client_Plan_Relationship__c accPlanSoql = [SELECT Id FROM Client_Plan_Relationship__c];
            delete accPlanSoql;
        Test.stopTest();

        List<Client_Plan_Relationship_Item__c> accPlanRelItemSoql = [SELECT Id FROM Client_Plan_Relationship_Item__c];

        System.assertEquals(0, accPlanRelItemSoql.size());
    }

    @isTest
    public static void testDeleteRelationshipItemsBulk() {
        //prepare data
        createTestData(2, 200);

        Test.startTest();
            List<Client_Plan_Relationship__c> accPlanSoql = [SELECT Id FROM Client_Plan_Relationship__c];
            delete accPlanSoql;
        Test.stopTest();

        List<Client_Plan_Relationship_Item__c> accPlanRelItemSoql = [SELECT Id FROM Client_Plan_Relationship_Item__c];

        System.assertEquals(0, accPlanRelItemSoql.size());
    }
    
}