/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPresence VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPresence
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPresenceController extends ClientPlanUtils{

    public Client_Plan__c plan {get;set;}
    
    public Boolean planLoaded {get;set;}
    
    public List<SelectOption> primaryBankOptions {get;set;}
    
    public List<SelectOption> engagedOptions {get;set;}
    
    private String planId;
    
    
    //static variables
    
    @testVisible
    private static String engagedJson = JsonUtils.returnJSONString('Picklists', 'CountryPresenceEngagedJSON', 
            'txt', 'Picklists');
            
    @testVisible       
    private static Map<String, String> engagedMap = JsonUtils.returnPicklistMap(engagedJson);
    
    private static final String countriesJson = JsonUtils.returnJSONString('Picklists', 'CountryPresenceJSON', 
            'txt', 'Picklists');
    
    @testVisible
    private static Map<String, String> countriesMap = JsonUtils.returnPicklistMap(countriesJson);
    
    @testVisible
    private static String bankingCountriesJson = Json.serializePretty(countriesMap.keySet());
    
    @testVisible
    private static String barclaysPresenceJson = JsonUtils.returnJSONString('Picklists', 'BarclaysPresenceJSON', 
            'txt', 'Picklists');
    
    private static final String COUNTRIES_QUERY = 
        'SELECT Id, Engaged__c, Primary_Bank__c, Banking_Country__c FROM Country_Presence__c WHERE Client_Plan__c = ';
        
    private static final String COUNTRIES_QUERY_ORDER = ' ORDER BY Banking_Country__c';
    
    public ClientPresenceController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        planId = ApexPages.currentPage().getParameters().get('planId');
        if (!String.isEmpty(planId)) {
            queryPlan();
            if (planLoaded) {
                preparePrimaryBankOptions();
                prepareEngagedOptions();
            }
        } else {
            planLoaded = false;
        }
    }
    
     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds country presence
      * @Params:          planId - Id of client plan, country - Banking_Country__c, engaged - Engaged__c, bank - Primary_Bank__c
      * @Returns:         json with error message or added record
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String addCountry(String planId, String country, String engaged, String bank) {
        Country_Presence__c cp = new Country_Presence__c();
        cp.Banking_Country__c = country;
        cp.Engaged__c = engaged;
        cp.Primary_Bank__c = bank;
        
        try {
            cp.Client_Plan__c = planId;
            insert cp;
        } catch (System.DmlException e) {
            System.debug(e);
            
            String message = Label.errMsg_ErrorAddingCountryPresence;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                message += ' ' + e.getDmlMessage(i);
            }
            
            ResultWrapper rw = new ResultWrapper();
            rw.message = message;
            return Json.serializePretty(rw);
        }
        
        List<CountryPresenceMapWrapper> wrappers = wrapCountries(new List<Country_Presence__c>{cp});
        ResultWrapper rw = new ResultWrapper();
        rw.wrapper = wrappers.get(0);
        
        return JSON.serializePretty(rw);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     country presence editation
      * @Params:          countryId - record Id, country - Banking_Country__c, engaged - Engaged__c, bank - Primary_Bank__c
      * @Returns:         json with error message or null if succeeded
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String editCountry(String countryId, String country, String engaged, String bank) {
        List<Country_Presence__c> cps = [
            SELECT Id, Banking_Country__c, Engaged__c, Primary_Bank__c
            FROM Country_Presence__c
            WHERE Id = :countryId
        ];
        
        if (cps.isEmpty()) {
            ResultWrapper rw = new ResultWrapper();
            rw.message = Label.errMsg_RecordNotFound;
            return Json.serializePretty(rw);
        }
        Country_Presence__c cp = cps[0];
        
        cp.Banking_Country__c = country;
        cp.Engaged__c = engaged;
        cp.Primary_Bank__c = bank;
        
        try {
            update cp;
        } catch (System.DmlException e) {
            System.debug(e);
            
            String message = Label.errMsg_ErrorEditingCountryPresence;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                message += ' ' + e.getDmlMessage(i);
            }
            
            ResultWrapper rw = new ResultWrapper();
            rw.message = message;
            return Json.serializePretty(rw);
        }
        
        ResultWrapper rw = new ResultWrapper();
        rw.wrapper = null;
        return JSON.serializePretty(rw);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     country presence removing
      * @Params:          countryId - Id of record to delete
      * @Returns:         boolean - false if an error occured, true otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static Boolean removeCountry(String countryId) {
        List<Country_Presence__c> cps = [
            SELECT Id
            FROM Country_Presence__c
            WHERE Id = :countryId
        ];
        
        if (cps.isEmpty()) {
            return false;
        }
        
        delete cps;
        return true;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries country presence records
      * @Params:          planId - Id of client plan, engagedPart - filters
      * @Returns:         null if an error occcured, json with records otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String queryCountries(String planId, String engagedPart) {
        String query = COUNTRIES_QUERY + '\'' + planId + '\'' + engagedPart + COUNTRIES_QUERY_ORDER;
        
        List<Country_Presence__c> countries;
        try {
            countries = Database.query(query);
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
        
        List<CountryPresenceMapWrapper> wrappers = wrapCountries(countries);
        return JSON.serializePretty(wrappers);
    }
    
    public static List<Country_Presence__c> queryCountries(String planId) {
        
        return  [select ID,Banking_Country__c,Engaged__c,Primary_Bank__c 
                   from Country_Presence__c where Client_Plan__c=:planId];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     wraps country presence records to DTOs
      * @Params:          countries - list of country presence records to wrap
      * @Returns:         List<CountryPresenceMapWrapper> - wrapped DTOs
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private static List<CountryPresenceMapWrapper> wrapCountries(List<Country_Presence__c> countries) {
        List<CountryPresenceMapWrapper> wrappers = new List<CountryPresenceMapWrapper>();
        
        for (Country_Presence__c cp: countries) {
            String countryCode = countriesMap.get(cp.Banking_Country__c);
            String color = engagedMap.get(cp.Engaged__c);
            
            if (countryCode == null || color == null) {
                continue;
            }
            
            CountryPresenceMapWrapper wrapper = new CountryPresenceMapWrapper();
            wrapper.id = cp.Id;
            wrapper.countryCode = countryCode;
            wrapper.country = cp.Banking_Country__c;
            wrapper.color = color;
            wrapper.engaged = cp.Engaged__c;
            wrapper.primaryBank = cp.Primary_Bank__c;
            wrappers.add(wrapper);
        }
        return wrappers;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries client plan
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryPlan() {
        List<Client_Plan__c> plans;
        try {
            plans = [
                SELECT Id 
                FROM Client_Plan__c 
                WHERE Id = :planId];
        } catch (Exception e) {
            planLoaded = false;
            return;
        }
            
        if (plans.isEmpty()) {
            planLoaded = false; 
        } else {
            planLoaded = true;
            plan = plans[0];
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of primary bank field
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void preparePrimaryBankOptions() {
        Schema.DescribeFieldResult f = Country_Presence__c.Primary_Bank__c.getDescribe();
        primaryBankOptions = prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of engaged field
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareEngagedOptions() {
        Schema.DescribeFieldResult f = Country_Presence__c.Engaged__c.getDescribe();
        engagedOptions = prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options from describe field result
      * @Params           Schema.DescribeFieldResult f - field info to process
      * @Returns:         List<SelectOption> - prepared select options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of engagedJson
      * @Returns:         String engagedJson
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static String getEngagedJson() {
        return engagedJson;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of bankingCountriesJson
      * @Returns:         String bankingCountriesJson
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static String getBankingCountriesJson() {
        return bankingCountriesJson;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of barclaysPresenceJson
      * @Returns:         String barclaysPresenceJson
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static String getBarclaysPresenceJson() {
        return barclaysPresenceJson;
    }
    
    @testVisible
    private class CountryPresenceMapWrapper {
        public String id;
        public String countryCode;
        public String country;
        public String primaryBank;
        public String color;
        public String engaged;
    }
    
    @testVisible
    private class ResultWrapper {
        public String message;
        public CountryPresenceMapWrapper wrapper;
    }

}