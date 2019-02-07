/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanPresenceControllerMobile
*                 Tests executed:
*                 1 - testQueryCountries()
*                   Tests querying of countries
*                 2 - testGetMapMetadata()
*                   Tests getter of map metadata
*                 3 - testGetFieldsMetadata()
*                   Tests getter of fields' metadata
*                 4 - testGetCountry()
*                   Tests getter of country
*                 5 - testAddCountry()
*                   Tests adding country
*                 6 - testEditCountry()
*                   Tests editation of country
*                 7 - testRemoveCountry()
*                   Tests removing country
*                 8 - testGetRoleOptions()
*                   Tests preparation of role select options
*                 9 - testGetStageOptions()
*                   Tests preparation of stage select options
*                 10 - testGetExpansionPolicyOptions()
*                   Tests preparation of expansion policy select options
*                 11 - testGetDGOptions()
*                   Tests preparation of DG select options
*                 12 - testCountProgressFromEmptyPlanObject()
*                   Tests progress counting when plan fields are null
*                 13 - testCountProgressFromFilledPlanObject()
*                   Tests progress counting when plan fields are filled
*                 14 - testCountPlanProgress()
*                   Tests progress counting
*                 15 - testQueryTeamMembers()
*                   Tests querying of team members
*                 15 - testErrorMessages()
*                   Tests of methods handling error messaged
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanPresenceControllerMob {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testQueryCountries() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String countryId = prepareCountry(plan.Id);
        
        //not-existing planId
        List<Country_Presence__c> result = ClientPlanPreseceControllerMobile.queryCountries(null);
        System.assertEquals(null, result);
        
        result = ClientPlanPreseceControllerMobile.queryCountries('asdf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanPreseceControllerMobile.queryCountries(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(countryId, result[0].Id);
        System.assertEquals('engaged', result[0].Engaged__c );
        System.assertEquals('bank', result[0].Primary_Bank__c );
        System.assertEquals('country', result[0].Banking_Country__c );
    }
    
    static testMethod void testGetMapMetadata() {
        
        String result = ClientPlanPreseceControllerMobile.getMapMetadata();
        System.assertNotEquals(null, result);
        
        ClientPlanPreseceControllerMobile.MetadataWrapper wrapper = (ClientPlanPreseceControllerMobile.MetadataWrapper) JSON.deserialize(result,
            ClientPlanPreseceControllerMobile.MetadataWrapper.class);
           
        System.assertEquals(JsonUtils.TEST_JSON_RETURN, wrapper.barclaysPresenceJson);
        
        Map<String,String> testJsonMap = JsonUtils.returnPicklistMap(JsonUtils.TEST_JSON_RETURN);
        
        System.assertEquals(Json.serialize(testJsonMap.keySet()), wrapper.bankingCountriesJson);
        System.assertEquals(testJsonMap, wrapper.engagedMap);
        System.assertEquals(testJsonMap, wrapper.countriesMap); 
    }
    
    static testMethod void testGetFieldsMetadata() {
    
        Schema.DescribeFieldResult fieldResult = Country_Presence__c.Engaged__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> engagedOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            engagedOptions.add(f.getLabel());
        }
        
        fieldResult = Country_Presence__c.Primary_Bank__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        List<String> bankOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            bankOptions.add(f.getLabel());
        }
        
        Map<String, List<String>> result = ClientPlanPreseceControllerMobile.getFieldsMetadata();
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.keyset().size());
        
        System.assertNotEquals(null, result.get('engaged'));
        System.assertEquals(engagedOptions.size(), result.get('engaged').size());
        for (Integer i = 0; i < engagedOptions.size(); i++) {
            System.assertEquals(engagedOptions[i], result.get('engaged')[i]);   
        }
        
        System.assertNotEquals(null, result.get('primaryBank'));
        System.assertEquals(bankOptions.size(), result.get('primaryBank').size());
        for (Integer i = 0; i < bankOptions.size(); i++) {
            System.assertEquals(bankOptions[i], result.get('primaryBank')[i]);   
        }
    }
    
    static testMethod void testGetCountry() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String countryId = prepareCountry(plan.Id);
        
        //not-existing countryId
        Country_Presence__c result = ClientPlanPreseceControllerMobile.getCountry(null);
        System.assertEquals(null, result);
        
        result = ClientPlanPreseceControllerMobile.getCountry('asdfadsf');
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanPreseceControllerMobile.getCountry(countryId);
        System.assertNotEquals(null, result);
        System.assertEquals(countryId, result.Id);
        System.assertEquals('engaged', result.Engaged__c);
        System.assertEquals('bank', result.Primary_Bank__c);
        System.assertEquals('country', result.Banking_Country__c);
    }
    
    static testMethod void testAddCountry() {
    
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //not-existing planId
        Boolean result = ClientPlanPreseceControllerMobile.addCountry(null, null, null, null);
        System.assertEquals(true, result);
        
        List<Country_Presence__c> countries = [
            SELECT Id
            FROM Country_Presence__c
        ];
        System.assertEquals(0, countries.size());
        
        result = ClientPlanPreseceControllerMobile.addCountry('asdf', null, null, null);
        System.assertEquals(true, result);
        
        countries = [
            SELECT Id
            FROM Country_Presence__c
        ];
        System.assertEquals(0, countries.size());
        
        //working code
        result = ClientPlanPreseceControllerMobile.addCountry(plan.Id, null, null, null);
        System.assertEquals(false, result);
        
        countries = [
            SELECT Id, Client_Plan__c, Engaged__c, Primary_Bank__c, Banking_Country__c
            FROM Country_Presence__c
        ];
        System.assertEquals(1, countries.size());
        System.assertEquals(plan.Id, countries[0].Client_Plan__c);
        System.assertEquals(null, countries[0].Engaged__c);
        System.assertEquals(null, countries[0].Primary_Bank__c);
        System.assertEquals(null, countries[0].Banking_Country__c);
        
        delete countries;
        
        result = ClientPlanPreseceControllerMobile.addCountry(plan.Id, 'country', 'engaged', 'bank');
        System.assertEquals(false, result);
        
        countries = [
            SELECT Id, Client_Plan__c, Engaged__c, Primary_Bank__c, Banking_Country__c
            FROM Country_Presence__c
        ];
        System.assertEquals(1, countries.size());
        System.assertEquals(plan.Id, countries[0].Client_Plan__c);
        System.assertEquals('engaged', countries[0].Engaged__c);
        System.assertEquals('bank', countries[0].Primary_Bank__c);
        System.assertEquals('country', countries[0].Banking_Country__c);
    }
    
    static testMethod void testEditCountry() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String countryId = prepareCountry(plan.Id);
        
        //not-existing countryId
        Boolean result = ClientPlanPreseceControllerMobile.editCountry(null, null, null, null);
        System.assertEquals(true, result);
        
        result = ClientPlanPreseceControllerMobile.editCountry('asdf', null, null, null);
        System.assertEquals(true, result);
        
        //working code
        result = ClientPlanPreseceControllerMobile.editCountry(countryId, 'c', 'e', 'b');
        System.assertEquals(false, result);
        
        List<Country_Presence__c> countries = [
            SELECT Id, Client_Plan__c, Engaged__c, Primary_Bank__c, Banking_Country__c
            FROM Country_Presence__c
        ];
        System.assertEquals(1, countries.size());
        System.assertEquals(plan.Id, countries[0].Client_Plan__c);
        System.assertEquals('e', countries[0].Engaged__c);
        System.assertEquals('b', countries[0].Primary_Bank__c);
        System.assertEquals('c', countries[0].Banking_Country__c);
    }
    
    static testMethod void testRemoveCountry() {
        
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        String countryId = prepareCountry(plan.Id);
        
        //not-existing countryId
        Boolean result = ClientPlanPreseceControllerMobile.removeCountry(null);
        System.assertEquals(true, result);
        
        List<Country_Presence__c> countries = [
            SELECT Id
            FROM Country_Presence__c
        ];
        System.assertEquals(1, countries.size());
        
        result = ClientPlanPreseceControllerMobile.removeCountry('asdfasdf');
        System.assertEquals(true, result);
        
        countries = [
            SELECT Id
            FROM Country_Presence__c
        ];
        System.assertEquals(1, countries.size());
        
        //working code
        result = ClientPlanPreseceControllerMobile.removeCountry(countryId);
        System.assertEquals(false, result);
        
        countries = [
            SELECT Id
            FROM Country_Presence__c
        ];
        System.assertEquals(0, countries.size());
    }
    
    private static String prepareCountry(String planId) {
    
        Country_Presence__c cp = new Country_Presence__c();
        cp.Client_Plan__c = planId;
        cp.Engaged__c = 'engaged';
        cp.Primary_Bank__c = 'bank';
        cp.Banking_Country__c = 'country';
        insert cp;
        
        return cp.Id;
    }
    
}