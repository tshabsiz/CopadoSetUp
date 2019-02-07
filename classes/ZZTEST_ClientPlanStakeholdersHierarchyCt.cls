/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanOrgStructureController
*                 Tests executed:
*                 1 - testGetHierarchyChartDataErrors()
*                   Tests errors handling of getHierarchyChartDataErrors method
*                 2 - testGetHierarchyChartData()
*                   Tests getting of hierarchy data
*                 3 - testAddNewContactErrors()
*                   Tests errors handling during adding new Contact
*                 4 - testAddNewContact()
*                   Tests adding new Barclays Contact
*                 5 - testAddRelationshipErrors()
*                   Tests errors handling during adding relationship
*                 6 - testAddRelationship()
*                   Tests adding of relationship
*                 7 - testEditContactErrors()
*                   Tests errors handling during editing of relationship
*                 8 - testEditContact()
*                   Tests editing of relationship
*                 9 - testAddNewBarclaysContactErrors()
*                   Tests errors handling during adding new Barclays Contact User
*                 10 - testAddNewBarclaysContact()
*                   Tests adding new Barclays Contact User
*                 11 - testEditBarclaysContactError()
*                   Tests errors handling during editing Barclays Contact User
*                 12 - testEditBarclaysContact()
*                   Tests editing Barclays Contact
*                 13 - testRemoveBarclaysContactErrors()
*                   Tests errors handling during removing Barclays Contact User
*                 14 - testRemoveBarclaysContact()
*                   Tests removing Barclays Contact User
*                 15 - testSaveCommentErrors()
*                   Tests errors handling during saving comments
*                 16 - testSaveComment()
*                   Tests adding updating of comments
*                 17 - testSearchErrors()
*                   Tests error handling during contact searching
*                 18 - testSearchAccountRestrictions()
*                   Tests contact searching with account restrictions
*                 19 - testSearch()
*                   Tests contact searching
*                 20 - testSearchBarclaysContactUser()
*                   Tests Barclays contact user searching
*                 21 - testGetContactById()
*                   Tests method for obtaining contact by id
*                 22 - testSaveMapSlidersNoRecords()
*                   Tests saving of map sliders when there are no records
*                 23 - testSaveMapSliders()
*                   Tests saving of map sliders
*                 24 - testGetString()
*                   Tests getString method
*                 25 - testGetOptions()
*                   Tests get options for Picklist Entries
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanStakeholdersHierarchyCt {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testGetHierarchyChartDataErrors() {
        String result = ClientPlanStakeholdersHierarchyCtr.getHierarchyChartData('asdf');
        System.assertEquals('', result);
    }
    
    static testMethod void testGetHierarchyChartData() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c cpr = new Client_Plan_Relationship__c();
        cpr.Client_Plan__c = plan.Id;
        cpr.Contact__c = cont.Id;
        cpr.Comment__c = 'This is a comment.';
        cpr.Client_Strength__c = '3';
        insert cpr;

        Client_Plan_Relationship_Item__c cpri = new Client_Plan_Relationship_Item__c();
        cpri.Client_Plan_Relationship__c = cpr.Id;
        cpri.Barclays_Contact_User__c = UserInfo.getUserId();
        cpri.Primary_Contact__c = true;
        insert cpri;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.getHierarchyChartData(plan.Id);
        Test.stopTest();

        User user = [SELECT Id, Name, Senior_Sponsor__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        String expected = '[{"title":"Pepa Flaska","parent":null,"jobTitle":"","jobRole":"Chief Investment Officer",' + '"id":"' + cont.Id 
            + '","comment":"This is a comment.","clientStrength":"3","barclaysContacts":[{"seniorSponsor":' + user.Senior_Sponsor__c 
            + ',"primary":true,"name":"' + user.Name +'","id":"' + cpri.Id + '","clientStrength":""}],"aprId":"' + cpr.Id + '"}]';
        
        System.assertEquals(expected, result);
    }

    static testMethod void testAddNewContactErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String result;

        Test.startTest();
        //Add root contact
        result = ClientPlanStakeholdersHierarchyCtr.addNewContact('', '', '', '', '', '', '', '1', plan.Id, null, null);
        System.assertEquals(true, String.isNotBlank(result));
        
        Test.stopTest();
    }

    static testMethod void testAddNewContact() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String result;

        Test.startTest();
        //Add root contact
        result = ClientPlanStakeholdersHierarchyCtr.addNewContact('John', 'Smith', '', '', '', '', '', '1', plan.Id, null, null);
        System.assertEquals(null, result);

        List<Client_Plan_Relationship__c> aprs = [SELECT Id, Contact__c FROM Client_Plan_Relationship__c];
        System.assertEquals(1, aprs.size());

        //Add new contact above
        result = ClientPlanStakeholdersHierarchyCtr.addNewContact('John', 'Snow', '', '', '', '', '', '1', plan.Id, null, aprs[0].Id);
        System.assertEquals(null, result);

        //Add new contact below
        result = ClientPlanStakeholdersHierarchyCtr.addNewContact('John', 'Summer', '', '', '', '', '', '1', plan.Id, aprs[0].Contact__c, aprs[0].Id);
        System.assertEquals(null, result);

        aprs = [SELECT Id, Contact__c FROM Client_Plan_Relationship__c];
        System.assertEquals(3, aprs.size());
        
        Test.stopTest();
    }

    static testMethod void testAddRelationshipErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.addRelationship(null, null, null, cont.Id, '1');
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(result));
        
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Id
            FROM Client_Plan_Relationship__c
        ];
        System.assertEquals(0, aprs.size());
    }
    
    static testMethod void testAddRelationship() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont1 = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Contact cont2 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        cont2.FirstName = 'aaa';
        cont2.LastName = 'Test1';
        insert cont2;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.addRelationship(plan.Id, null, null, cont1.Id, '1');
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Id
            FROM Client_Plan_Relationship__c
        ];
        System.assertEquals(1, aprs.size());
    }

    static testMethod void testEditContactErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.editContact(null, '5');
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(result));
        
    }

    static testMethod void testEditContact() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = cont.Id,
                                                                                        Reports_to__c = null);
        insert relationship;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.editContact(relationship.Id, '5');
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan_Relationship__c> aprs = [SELECT Id, Client_Strength__c FROM Client_Plan_Relationship__c];
        System.assertEquals('5', aprs[0].Client_Strength__c);
    }

    static testMethod void testAddNewBarclaysContactErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = cont.Id,
                                                                                        Reports_to__c = null);
        insert relationship;
        
        String result;
        Test.startTest();
        result = ClientPlanStakeholdersHierarchyCtr.addNewBarclaysContact(null, '', relationship.Id, false);
        System.assertEquals(true, String.isNotBlank(result));
        result = ClientPlanStakeholdersHierarchyCtr.addNewBarclaysContact(UserInfo.getUserId(), '', null, false);
        System.assertEquals(true, String.isNotBlank(result));
        Test.stopTest();
        
    }

    static testMethod void testAddNewBarclaysContact() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = cont.Id,
                                                                                        Reports_to__c = null);
        insert relationship;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.addNewBarclaysContact(UserInfo.getUserId(), '', relationship.Id, false);
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan_Relationship_Item__c> apris = [SELECT Id FROM Client_Plan_Relationship_Item__c];
        System.assertEquals(1, apris.size());
    }

    static testMethod void testEditBarclaysContactError() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.editBarclaysContact(null, '', false);
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(result));
    }

    static testMethod void testEditBarclaysContact() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = cont.Id,
                                                                                        Reports_to__c = null);
        insert relationship;

        Client_Plan_Relationship_Item__c relationshipItem = new Client_Plan_Relationship_Item__c(Client_Plan_Relationship__c = relationship.Id,
                                                                                                    Barclays_Contact_User__c = UserInfo.getUserId());
        insert relationshipItem;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.editBarclaysContact(relationshipItem.Id, 'At Risk', true);
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan_Relationship_Item__c> apris = [SELECT Id, Strength_of_Relationship__c, Primary_Contact__c FROM Client_Plan_Relationship_Item__c];
        System.assertEquals(1, apris.size());
        System.assertEquals('At Risk', apris[0].Strength_of_Relationship__c);
        System.assertEquals(true, apris[0].Primary_Contact__c);
    }

    static testMethod void testRemoveBarclaysContactErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.removeBarclaysContact(null);
        Test.stopTest();
        
        System.assertEquals(null, result);
    }

    static testMethod void testRemoveBarclaysContact() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c(Client_Plan__c = plan.Id,
                                                                                        Contact__c = cont.Id,
                                                                                        Reports_to__c = null);
        insert relationship;

        Client_Plan_Relationship_Item__c relationshipItem = new Client_Plan_Relationship_Item__c(Client_Plan_Relationship__c = relationship.Id,
                                                                                                    Barclays_Contact_User__c = UserInfo.getUserId());
        insert relationshipItem;
        
        Test.startTest();
        String result = ClientPlanStakeholdersHierarchyCtr.removeBarclaysContact(relationshipItem.Id);
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan_Relationship_Item__c> apris = [SELECT Id, Strength_of_Relationship__c, Primary_Contact__c FROM Client_Plan_Relationship_Item__c];
        System.assertEquals(0, apris.size());
    }
    
    static testMethod void testSaveCommentErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        //wrong contact Id
        Boolean result = ClientPlanStakeholdersHierarchyCtr.saveComment('asdf', plan.Id, 'something');
        System.assertEquals(false, result);
        
        //wrong plan Id
        result = ClientPlanStakeholdersHierarchyCtr.saveComment(cont.Id, 'asdf', 'something');
        System.assertEquals(false, result);
    }
    
    static testMethod void testSaveComment() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Client_Plan_Relationship__c apr = new Client_Plan_Relationship__c();
        apr.Client_Plan__c = plan.Id;
        apr.Contact__c = cont.Id;
        apr.Comment__c = 'aaa';
        insert apr;
        
        String newComment = 'bbb';
        
        Test.startTest();
        Boolean result = ClientPlanStakeholdersHierarchyCtr.saveComment(cont.Id, plan.Id, newComment);
        Test.stopTest();
        
        System.assertEquals(true, result);
        
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Client_Plan__c, Contact__c, Comment__c
            FROM Client_Plan_Relationship__c
            WHERE Id = :apr.Id
        ];
        
        System.assertEquals(1, aprs.size());
        System.assertEquals(plan.Id, aprs[0].Client_Plan__c);
        System.assertEquals(cont.Id, aprs[0].Contact__c);
        System.assertEquals(newComment, aprs[0].Comment__c);
    }
    
    static testMethod void testSearchErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont2 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        cont2.FirstName = 'aaa';
        cont2.LastName = 'Test2';
        cont2.AccountId = acc2.Id;
        insert cont2;
        
        Test.startTest();
        List<ClientPlanStakeholdersHierarchyCtr.SearchResult> result = ClientPlanStakeholdersHierarchyCtr.search('aaa', false, new List<Id>(), 'fff');
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals(cont2.Id, result[0].value);
        
        String expectedLabel = cont2.FirstName + ' ' + cont2.LastName + ' - ' + acc2.Name;
        System.assertEquals(expectedLabel, result[0].label);
    }
    
    static testMethod void testSearchAccountRestrictions() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        //contact we don't want to get
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont2 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        cont2.FirstName = 'aaa';
        cont2.LastName = 'Test3';
        cont2.AccountId = acc2.Id;
        insert cont2;
        
        Test.startTest();
        List<ClientPlanStakeholdersHierarchyCtr.SearchResult> result = ClientPlanStakeholdersHierarchyCtr.search('aaa', false, new List<Id>(), plan.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('value', result[0].value);
        System.assertEquals('label', result[0].label);
    }
    
    static testMethod void testSearch() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont2 = contactFactory.getProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        cont2.FirstName = 'aaa';
        cont2.LastName = 'Test4';
        cont2.AccountId = acc2.Id;
        insert cont2;
        
        Test.startTest();
        List<ClientPlanStakeholdersHierarchyCtr.SearchResult> result = ClientPlanStakeholdersHierarchyCtr.search('aaa', true, new List<Id>(), plan.Id);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals(cont2.Id, result[0].value);
        
        String expectedLabel = cont2.FirstName + ' ' + cont2.LastName + ' - ' + acc2.Name;
        System.assertEquals(expectedLabel, result[0].label);
    }

    static testMethod void testSearchBarclaysContactUser(){
        Test.startTest();
        List<ClientPlanStakeholdersHierarchyCtr.SearchResult> result = ClientPlanStakeholdersHierarchyCtr.searchBarclaysContactUser(UserInfo.getUserName());
        Test.stopTest();
    }
    
    static testMethod void testGetContactById() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        ClientPlanStakeholdersHierarchyCtr.SearchResult result = ClientPlanStakeholdersHierarchyCtr.getContactById(null);
        System.assertEquals(null, result);
        
        result = ClientPlanStakeholdersHierarchyCtr.getContactById(cont.Id);
        
        String expectedLabel = cont.FirstName + ' ' + cont.LastName + ' - ' + acc2.Name;
        System.assertEquals(expectedLabel, result.label);
        System.assertEquals(cont.Id, result.value);
    }
    
    static testMethod void testSaveMapSlidersNoRecords() {
        //no records to update
        List<ClientPlanStakeholdersHierarchyCtr.ValueRecordDto> dtos = new
            List<ClientPlanStakeholdersHierarchyCtr.ValueRecordDto>();
            
        Boolean result = ClientPlanStakeholdersHierarchyCtr.saveMapSliders(dtos);
        System.assertEquals(true, result);
    }
    
    static testMethod void testSaveMapSliders() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont1 = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
    
        Client_Plan_Relationship__c apr1 = new Client_Plan_Relationship__c();
        apr1.Client_Plan__c = plan.Id;
        apr1.Contact__c = cont1.Id;
        apr1.Client_Strength__c = '2';
        insert apr1;
        
        ClientPlanStakeholdersHierarchyCtr.ValueRecordDto dto = new ClientPlanStakeholdersHierarchyCtr.ValueRecordDto();
        dto.value = '4';
        dto.record = apr1.Id;
    
        //no records to update
        List<ClientPlanStakeholdersHierarchyCtr.ValueRecordDto> dtos = new
            List<ClientPlanStakeholdersHierarchyCtr.ValueRecordDto>{dto};
            
        Boolean result = ClientPlanStakeholdersHierarchyCtr.saveMapSliders(dtos);
        System.assertEquals(true, result);
        
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Client_Plan__c, Contact__c, Client_Strength__c
            FROM Client_Plan_Relationship__c
        ];
        
        System.assertEquals(1, aprs.size());
        System.assertEquals('4', aprs[0].Client_Strength__c);
        System.assertEquals(plan.Id, apr1.Client_Plan__c);
        System.assertEquals(cont1.Id, apr1.Contact__c);
    }
    
    static testMethod void testGetString() {
        String result = ClientPlanStakeholdersHierarchyCtr.getString(null);
        System.assertEquals('', result);
        
        result = ClientPlanStakeholdersHierarchyCtr.getString('');
        System.assertEquals('', result);
        
        String expectedResult = 'asdf';
        result = ClientPlanStakeholdersHierarchyCtr.getString(expectedResult);
        System.assertEquals(expectedResult, result);
    }

    static testMethod void testGetOptions() {
        ClientPlanStakeholdersHierarchyCtr ctrl = new ClientPlanStakeholdersHierarchyCtr();
        
        List<Schema.PicklistEntry> jobRolePicklistEntries = Contact.Job_Role__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> relationshipStrengthPicklistEntries = Client_Plan_Relationship_Item__c.Strength_of_Relationship__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> influencePicklistEntries = Client_Plan_Relationship__c.Client_Strength__c.getDescribe().getPicklistValues();

        List<SelectOption> jobRoleOptions = ctrl.getJobRoleOptions();
        for(Integer i=0; i< jobRoleOptions.size(); i++){
            System.assertEquals(jobRolePicklistEntries[i].getLabel(), jobRoleOptions[i].getLabel());
            System.assertEquals(jobRolePicklistEntries[i].getValue(), jobRoleOptions[i].getValue());
        }
        
        List<SelectOption> relationshipStrengthOptions = ctrl.getRelationshipStrengthOptions();
        for(Integer i=0; i< relationshipStrengthOptions.size(); i++){
            System.assertEquals(relationshipStrengthPicklistEntries[i].getLabel(), relationshipStrengthOptions[i].getLabel());
            System.assertEquals(relationshipStrengthPicklistEntries[i].getValue(), relationshipStrengthOptions[i].getValue());
        }

        List<SelectOption> influenceOptions = ctrl.getInfluenceOptions();
        for(Integer i=0; i< relationshipStrengthOptions.size(); i++){
            System.assertEquals(influencePicklistEntries[i].getLabel(), influenceOptions[i].getLabel());
            System.assertEquals(influencePicklistEntries[i].getValue(), influenceOptions[i].getValue());
        }
    }
    
}