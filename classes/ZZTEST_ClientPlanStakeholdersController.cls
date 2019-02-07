/**
* @Author:        Marta Malinowska
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanStakeholdersController
*                 Tests executed:
*                 1 - testRemoveStakeholders()
*                   Tests removing contact and its subordinates from stakeholders hierarchy
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanStakeholdersController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

        Contact cont1 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        Contact cont2 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        Contact cont3 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        cont1.LastName = 'Test 1';
        cont2.LastName = 'Test 2';
        cont3.LastName = 'Test 3';
        List<Contact> contacts = new List<Contact>{cont1, cont2, cont3};
        insert contacts;
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testRemoveStakeholders() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact];

        Client_Plan_Relationship__c parentRelationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = contacts[0].Id,
                                                                                        Reports_to__c = null);
        insert parentRelationship;
        List<Client_Plan_Relationship__c> childRelationships = new List<Client_Plan_Relationship__c>();
        for(Integer i=1; i<contacts.size(); i++){
            childRelationships.add(new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                    Contact__c = contacts[i].Id,
                                                                    Reports_to__c = parentRelationship.Contact__c));
        }
        insert childRelationships;
        
        PageReference pr = Page.ClientPlanStakeholders;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ClientPlanStakeholdersController ctrl = new ClientPlanStakeholdersController();
        ctrl.contactId = parentRelationship.Contact__c;

        Test.startTest();
        ctrl.remove();
        Test.stopTest();
        
        List<Client_Plan_Relationship__c> relationshipsAfterDel = [SELECT Id FROM Client_Plan_Relationship__c WHERE Client_Plan__c = :plan.Id];
        System.assertEquals(0, relationshipsAfterDel.size());
        
    }
    
}