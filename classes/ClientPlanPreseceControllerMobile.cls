/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanPresence Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanPresenceControllerMob
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanPreseceControllerMobile {
    
    private static final String COUNTRIES_QUERY = 
        'SELECT Id, Engaged__c, Primary_Bank__c, Banking_Country__c FROM Country_Presence__c WHERE Client_Plan__c = ';
    
    private static final String COUNTRIES_QUERY_ORDER = ' ORDER BY Banking_Country__c';

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of countries
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Country_Presence__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Country_Presence__c> queryCountries(String planId) {
        String query = COUNTRIES_QUERY + '\'' + planId + '\'' + COUNTRIES_QUERY_ORDER;
        
        List<Country_Presence__c> countries;
        try {
            countries = Database.query(query);
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
        
        return countries;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of map metadata
      * @Returns:         String - metadata is Json
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static String getMapMetadata() {
        MetadataWrapper result = new MetadataWrapper();

        String engagedJson = JsonUtils.returnJSONStringMobile('Picklists', 'CountryPresenceEngagedJSON', 
            'txt', 'Picklists');
        String countriesJson = JsonUtils.returnJSONStringMobile('Picklists', 'CountryPresenceJSON', 
            'txt', 'Picklists');
        String barclaysPresenceJson = JsonUtils.returnJSONStringMobile('Picklists', 'BarclaysPresenceJSON', 
            'txt', 'Picklists');

        Map<String, String> engagedMap = JsonUtils.returnPicklistMap(engagedJson);
        Map<String, String> countriesMap = JsonUtils.returnPicklistMap(countriesJson);

        result.barclaysPresenceJson = barclaysPresenceJson;
        result.bankingCountriesJson = Json.serialize(countriesMap.keySet());
        result.engagedMap = engagedMap;
        result.countriesMap = countriesMap;

        return JSON.serialize(result);
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of fields' metadata
      * @Returns:         Map<String, List<String>> - keys are names of fields, values are lists of picklist values
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getFieldsMetadata() {
        Map<String, List<String>> metadata = new Map<String, List<String>>();

        //engaged options
        Schema.DescribeFieldResult fieldResult = Country_Presence__c.Engaged__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('engaged', options);

        //primary bank
        fieldResult = Country_Presence__c.Primary_Bank__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('primaryBank', options);

        return metadata;
    }


    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter country
      * @Params:          String countryId - Id of country
      * @Returns:         Country_Presence__c
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Country_Presence__c getCountry(String countryId) {

        List<Country_Presence__c> countries = [
            SELECT Id, Engaged__c, Primary_Bank__c, Banking_Country__c
            FROM Country_Presence__c
            WHERE Id = :countryId
        ];

        if (countries.isEmpty()) {
            return null;
        } else {
            return countries[0];
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds country
      * @Params:          String planId - Id of client plan, fields of country to insert
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addCountry(String planId, String country, String engaged, String primaryBank) {

        Country_Presence__c cp = new Country_Presence__c();
        cp.Engaged__c = engaged;
        cp.Primary_Bank__c = primaryBank;
        cp.Banking_Country__c = country;

        try {
            cp.Client_Plan__c = planId;
            insert cp;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits country
      * @Params:          String countryId - Id of country, fields of country to update
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editCountry(String countryId, String country, String engaged, String primaryBank) {

        List<Country_Presence__c> countries = [
            SELECT Id, Engaged__c, Primary_Bank__c, Banking_Country__c
            FROM Country_Presence__c
            WHERE Id = :countryId
        ];

        if (countries.isEmpty()) {
            return true;
        }

        Country_Presence__c cp = countries[0];
        cp.Engaged__c = engaged;
        cp.Primary_Bank__c = primaryBank;
        cp.Banking_Country__c = country;

        try {
            update cp;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes country
      * @Params:          String countryId - id of country
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeCountry(String countryId) {

        List<Country_Presence__c> countries = [
            SELECT Id
            FROM Country_Presence__c
            WHERE Id = :countryId
        ];

        if (countries.isEmpty()) {
            return true;
        }

        try {
            delete countries[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    @testVisible
    private class MetadataWrapper {
        public String barclaysPresenceJson;
        public String bankingCountriesJson;
        public Map<String, String> engagedMap;
        public Map<String, String> countriesMap;     
    }

}