/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPresenceController
*                 Tests executed:
*                 1 - testAddCountryErrors()
*                   Tests adding country presence
*                 2 - testAddCountry()
*                   Tests adding country presence
*                 3 - testEditCountryErrors()
*                   Tests errors handling during editation of country presence
*                 4 - testEditCountryErrors()
*                   Tests editation of country presence
*                 5 - testRemoveCountryErrors()
*                   Tests errors handling during country presence removing
*                 6 - testRemoveCountry()
*                   Tests removing of country presence
*                 7 - testQueryCountriesErrors()
*                   Tests error handling during querying of country presence
*                 8 - testQueryCountries()
*                   Tests querying of country presence
*                 9 - testPreparePrimaryBankOptions()
*                   Tests preparation of primary bank options
*                 10 - testPrepareEngagedOptions()
*                   Tests preparation of engaged options
*                 11 - testQueryPlanErrors()
*                   Tests errors handling during plan querying
*                 12 - testQueryPlan()
*                   Tests querying of client plan
*                 13 - testQueryPlanWithWrongId()
*                   Tests querying of client plan with errors
*                 14 - testJsonGetters()
*                   Tests getters of jsons
*                 15 - testWrapCountries()
*                   Tests method which is converting presences to DTOs
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPresenceController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testAddCountryErrors() {
        String result = ClientPresenceController.addCountry(null, null, null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.contains(Label.errMsg_ErrorAddingCountryPresence));
        
        List<Country_Presence__c> cps = [SELECT Id, Banking_Country__c, Engaged__c, Primary_Bank__c FROM Country_Presence__c];
        System.assertEquals(0, cps.size());
    }

    static testMethod void testAddCountry() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ClientPresenceController.countriesMap = new Map<String, String>();
        ClientPresenceController.countriesMap.put('South Africa', 'za');
        
        ClientPresenceController.engagedMap = new Map<String, String>();
        ClientPresenceController.engagedMap.put('Primary Bank', '#000');
        
        String result = ClientPresenceController.addCountry(plan.Id, 'South Africa', 'Primary Bank', 'Barclays');
        System.assertNotEquals(null, result);
        
        List<Country_Presence__c> cps = [SELECT Id, Banking_Country__c, Engaged__c, Primary_Bank__c FROM Country_Presence__c];
        System.assertEquals(1, cps.size());
        System.assertEquals('South Africa', cps[0].Banking_Country__c);
        System.assertEquals('Primary Bank', cps[0].Engaged__c);
        System.assertEquals('Barclays', cps[0].Primary_Bank__c);
    }
    
    static testMethod void testEditCountryErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //record not found
        String result = ClientPresenceController.editCountry(null, null, null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.contains(Label.errMsg_RecordNotFound));
        
        //dml error handling
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan.Id;
        cp1.Banking_Country__c = 'South Africa';
        cp1.Engaged__c = 'Primary Bank';
        cp1.Primary_Bank__c = 'Barclays';
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan.Id;
        cp2.Banking_Country__c = 'Australia';
        cp2.Engaged__c = 'Primary Bank';
        cp2.Primary_Bank__c = 'Barclays';
        
        insert new List<Country_Presence__c>{cp1, cp2};
        
        result = ClientPresenceController.editCountry(cp2.Id, 'South Africa', cp2.Engaged__c, cp2.Primary_Bank__c);
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.contains(Label.errMsg_ErrorEditingCountryPresence));
        
        List<Country_Presence__c> cps = [SELECT Banking_Country__c FROM Country_Presence__c WHERE Id = :cp2.Id];
        System.assertEquals(1, cps.size());
        System.assertEquals(cp2.Banking_Country__c, cps[0].Banking_Country__c);
    }
    
    static testMethod void testEditCountry() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan.Id;
        cp1.Banking_Country__c = 'South Africa';
        cp1.Engaged__c = 'Primary Bank';
        cp1.Primary_Bank__c = 'Barclays';
        
        Country_Presence__c cp2 = new Country_Presence__c();
        cp2.Client_Plan__c = plan.Id;
        cp2.Banking_Country__c = 'Australia';
        cp2.Engaged__c = 'Primary Bank';
        cp2.Primary_Bank__c = 'Barclays';
        
        insert new List<Country_Presence__c>{cp1, cp2};
        
        String result = ClientPresenceController.editCountry(cp2.Id, 'China', 'Not Primary Bank', 'Nedbank');
        
        List<Country_Presence__c> cps = [SELECT Banking_Country__c, Engaged__c, Primary_Bank__c FROM Country_Presence__c WHERE Id = :cp2.Id];
        System.assertEquals(1, cps.size());
        System.assertEquals('China', cps[0].Banking_Country__c);
        System.assertEquals('Not Primary Bank', cps[0].Engaged__c);
        System.assertEquals('Nedbank', cps[0].Primary_Bank__c);
    }
    
    static testMethod void testRemoveCountryErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Boolean result = ClientPresenceController.removeCountry(null);
        System.assertEquals(false, result);
    }
    
    static testMethod void testRemoveCountry() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan.Id;
        cp1.Banking_Country__c = 'South Africa';
        cp1.Engaged__c = 'Primary Bank';
        cp1.Primary_Bank__c = 'Barclays';
        insert cp1;
        
        Boolean result = ClientPresenceController.removeCountry(cp1.Id);
        System.assertEquals(true, result);
        
        List<Country_Presence__c> cps = [SELECT Id FROM Country_Presence__c];
        System.assertEquals(0, cps.size());
    }
    
    static testMethod void testQueryCountriesErrors() {
        String result = ClientPresenceController.queryCountries('asdfasdf', 'asd()))(');
        System.assertEquals(null, result);
    }
    
    static testMethod void testQueryCountries() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Client_Plan__c = plan.Id;
        cp1.Banking_Country__c = 'South Africa';
        cp1.Engaged__c = 'Primary Bank';
        cp1.Primary_Bank__c = 'Barclays';
        insert cp1;
    
        String result = ClientPresenceController.queryCountries(plan.Id, '');
        System.assertNotEquals(null, result);
    }
    
    static testMethod void testPreparePrimaryBankOptions() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPresence;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
    
        Schema.DescribeFieldResult f = Country_Presence__c.Primary_Bank__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        
        ClientPresenceController ctrl = new ClientPresenceController();
        List<SelectOption> result = ctrl.primaryBankOptions;
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());    
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testPrepareEngagedOptions() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPresence;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
    
        Schema.DescribeFieldResult f = Country_Presence__c.Engaged__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        
        ClientPresenceController ctrl = new ClientPresenceController();
        List<SelectOption> result = ctrl.engagedOptions;
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());    
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testQueryPlanErrors() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPresence;
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPresenceController ctrl = new ClientPresenceController();
        Test.stopTest();
        
        System.assertEquals(null, ctrl.plan);
        System.assertEquals(false, ctrl.planLoaded);
    }
    
    static testMethod void testQueryPlan() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPresence;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPresenceController ctrl = new ClientPresenceController();
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl.plan);
        System.assertEquals(plan.Id, ctrl.plan.Id);
        System.assertEquals(true, ctrl.planLoaded);
    }
    
    static testMethod void testQueryPlanWithWrongId() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPresence;
        pr.getParameters().put('planId', 'asdfasdf');
        Test.setCurrentPage(pr);
        
        Test.startTest();
        ClientPresenceController ctrl = new ClientPresenceController();
        Test.stopTest();
        
        System.assertEquals(null, ctrl.plan);
        System.assertEquals(false, ctrl.planLoaded);
    }
    
    static testMethod void testJsonGetters() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String expEngagedJson = 'a';
        String expBankingCountriesJson = 'b';
        String expBarclaysPresenceJson = 'c';
        
        ClientPresenceController.engagedJson = expEngagedJson;
        ClientPresenceController.bankingCountriesJson = expBankingCountriesJson;
        ClientPresenceController.barclaysPresenceJson = expBarclaysPresenceJson;
        
        System.assertEquals(expEngagedJson, ClientPresenceController.getEngagedJson());
        System.assertEquals(expBankingCountriesJson, ClientPresenceController.getBankingCountriesJson());
        System.assertEquals(expBarclaysPresenceJson, ClientPresenceController.getBarclaysPresenceJson());
    }
    
    static testMethod void testWrapCountries() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        ClientPresenceController.countriesMap = new Map<String, String>();
        ClientPresenceController.countriesMap.put('South Africa', 'za');
        
        ClientPresenceController.engagedMap = new Map<String, String>();
        ClientPresenceController.engagedMap.put('Primary Bank', '#000');
        
        Country_Presence__c cp1 = new Country_Presence__c();
        cp1.Banking_Country__c = 'South Africa';
        cp1.Engaged__c = 'Primary Bank';
        cp1.Primary_Bank__c = 'Barclays';
        
        List<Country_Presence__c> countries = new List<Country_Presence__c>{cp1};
        
        List<ClientPresenceController.CountryPresenceMapWrapper> result = ClientPresenceController.wrapCountries(countries);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        
        ClientPresenceController.CountryPresenceMapWrapper r = result[0];
        System.assertEquals(null, r.id);
        System.assertEquals('za', r.countryCode);
        System.assertEquals(cp1.Banking_Country__c, r.country);
        System.assertEquals('#000', r.color);
        System.assertEquals(cp1.Engaged__c, r.engaged);
        System.assertEquals(cp1.Primary_Bank__c, r.primaryBank);
    }
    
    private static List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
    
}