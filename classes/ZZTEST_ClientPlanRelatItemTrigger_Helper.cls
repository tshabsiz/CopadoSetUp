/**
* @Author:        Svatopluk Sejkora
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanRelationshipItemTrigger_Helper
*                   Tests executed:
*                   1 - testcheckPrimaryUniqueness()
*                       Checks that user cannot add another Client_Plan_Relationship_Item__c marked as primary
*                   2 - testcheckPrimaryUniquenessBulk()
*                       Checks that user cannot add another Client_Plan_Relationship_Item__c marked as primary for bulk operation
*                       
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 14.10.2015    Svatopluk Sejkora   Adding Test methods for ClientPlanRelationshipItemTrigger_Helper - US - 0490
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_ClientPlanRelatItemTrigger_Helper {
    
    public class TestException extends Exception{}
    
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
                    accPlanRelItem.Primary_Contact__c = true;
                accPlanRelItemList.add(accPlanRelItem); 
            }
        }   
        insert  accPlanRelItemList;
    }

    @isTest
    public static void testcheckPrimaryUniqueness() {
        //prepare data
        createTestData(1,1);

        Client_Plan_Relationship__c accPlanRel = [SELECT Id FROM Client_Plan_Relationship__c];

        Client_Plan_Relationship_Item__c accPlanRelItem = new Client_Plan_Relationship_Item__c();
            accPlanRelItem.Client_Plan_Relationship__c = accPlanRel.Id;
            accPlanRelItem.Primary_Contact__c = true;

        Test.startTest();
            try {
                insert accPlanRelItem;
                throw new TestException();
            } catch (exception e) {
                System.AssertEquals(true, e.getMessage().contains(Label.errMsg_OneContactMax));
            }   
        Test.stopTest();
    }

    @isTest
    public static void testcheckPrimaryUniquenessBulk() {
        //prepare data
        createTestData(1, 200);

        List<Client_Plan_Relationship_Item__c> accPlanRelItemList = new List<Client_Plan_Relationship_Item__c>();

        for(Client_Plan_Relationship__c accPlanRelList : [SELECT Id FROM Client_Plan_Relationship__c]) {
            Client_Plan_Relationship_Item__c accPlanRelItem = new Client_Plan_Relationship_Item__c();
                accPlanRelItem.Client_Plan_Relationship__c = accPlanRelList.Id;
                accPlanRelItem.Primary_Contact__c = true;
            accPlanRelItemList.add(accPlanRelItem);
        }

        Test.startTest();
            try {
                insert accPlanRelItemList;
                throw new TestException();
            } catch (exception e) {
                System.AssertEquals(true, e.getMessage().contains(Label.errMsg_OneContactMax));
            }   
        Test.stopTest();
    }
    
    @isTest
    public static void testcheckDupContact() {
        //prepare data
        createTestData(1,1);

        Client_Plan_Relationship__c accPlanRel = [SELECT Id FROM Client_Plan_Relationship__c];
        User barclaysContact = [SELECT Id FROM User WHERE IsActive = true AND Profile.UserLicense.Name = 'Salesforce' LIMIT 1];

        List<Client_Plan_Relationship_Item__c> accPlanRelItems = new List<Client_Plan_Relationship_Item__c>();
        accPlanRelItems.add(new Client_Plan_Relationship_Item__c(
            Client_Plan_Relationship__c = accPlanRel.Id,
            Primary_Contact__c = false,
            Barclays_Contact_User__c = barclaysContact.Id
        ));
        accPlanRelItems.add(new Client_Plan_Relationship_Item__c(
            Client_Plan_Relationship__c = accPlanRel.Id,
            Primary_Contact__c = false,
            Barclays_Contact_User__c = barclaysContact.Id
        ));

        Test.startTest();
            try {
                insert accPlanRelItems;
                System.debug('Got past insert');
                throw new TestException();
            } catch (exception e) {
                System.debug('MyError:' + e.getMessage());
                System.AssertEquals(true, e.getMessage().contains(Label.errMsg_SameContact));
            }   
        Test.stopTest();
    }
}