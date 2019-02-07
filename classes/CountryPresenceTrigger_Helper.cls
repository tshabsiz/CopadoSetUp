/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Helper class for CountryPresenceTrigger
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_CountryPresenceTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class CountryPresenceTrigger_Helper {

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Checks if each country is used maximally once with given account plan.
      * @Params:          List<Country_Presence__c> newCPs - list of triggered records, Map<Id, Country_Presence__c> newCPsMap - map of triggered records
      *                       Boolean isInsert - true if trigger is insert, false otherwise
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static void checkCountryUniqueness(List<Country_Presence__c> newCPs, 
        Map<Id, Country_Presence__c> newCPsMap, Boolean isInsert) {
    
        Map<Id, List<Country_Presence__c>> planCpsMap = new Map<Id, List<Country_Presence__c>>();
        
        //creating map from new records
        for (Country_Presence__c cp: newCPs) {
            if (planCpsMap.containsKey(cp.Client_Plan__c)) {
                List<Country_Presence__c> cps = planCpsMap.get(cp.Client_Plan__c);
                cps.add(cp);
            } else {
                List<Country_Presence__c> cps = new List<Country_Presence__c>{cp};
                planCpsMap.put(cp.Client_Plan__c, cps);
            }
        }
        
        //querying records from database
        for (Country_Presence__c cp: [
            SELECT Id, Banking_Country__c, Client_Plan__c 
            FROM Country_Presence__c 
            WHERE Client_Plan__c IN :planCpsMap.keySet() AND Id NOT IN :newCPs]) {
        
                List<Country_Presence__c> cps = planCpsMap.get(cp.Client_Plan__c);
                cps.add(cp);
        }
    
        if (isInsert) {
            processUniquenessWithInsert(planCpsMap);
        } else {
            processUniquenessWithUpdate(planCpsMap, newCPsMap);
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Checks if each country is used maximally once with given account plan (before insert).
      * @Params:          Map<Id, List<Country_Presence__c>> planCpsMap - map of account plans and list of country presence,
      *                       Map<String, Country_Presence__c> countries - map of country in string and country presence with given country
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static void processUniquenessWithInsert(Map<Id, List<Country_Presence__c>> planCpsMap) {
        Map<String, Country_Presence__c> countries;
        
        for (Id planId: planCpsMap.keySet()) {
            countries = new Map<String, Country_Presence__c>();
            
            for (Country_Presence__c cp: planCpsMap.get(planId)) {
                if (cp.Banking_Country__c == null || cp.Banking_Country__c == '') {
                    continue;
                }
            
                if (countries.containsKey(cp.Banking_Country__c)) {
                    Country_Presence__c alreadyProcessed = countries.get(cp.Banking_Country__c);
                    
                    if (alreadyProcessed.Id == null && cp.Id == null) {
                        cp.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                        alreadyProcessed.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                        
                    } else if (alreadyProcessed.Id == null) {
                        alreadyProcessed.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                    } else {
                        cp.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                    } 
                } else {
                    countries.put(cp.Banking_Country__c, cp);
                } 
            }
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Checks if each country is used maximally once with given account plan (before update).
      * @Params:          Map<Id, List<Country_Presence__c>> planCpsMap - map of account plans and list of country presence,
      *                       Map<Id, Country_Presence__c> newCPsMap - map of triggered records
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static void processUniquenessWithUpdate(Map<Id, List<Country_Presence__c>> planCpsMap, 
        Map<Id, Country_Presence__c> newCPsMap) {
        
        Map<String, Country_Presence__c> countries;
        for (Id planId: planCpsMap.keySet()) {
            countries = new Map<String, Country_Presence__c>();
            
            for (Country_Presence__c cp: planCpsMap.get(planId)) {
                if (cp.Banking_Country__c == null || cp.Banking_Country__c == '') {
                    continue;
                }
            
                if (countries.containsKey(cp.Banking_Country__c)) {
                    Country_Presence__c alreadyProcessed = countries.get(cp.Banking_Country__c);
                    
                    if (newCPsMap.containsKey(alreadyProcessed.Id) && newCPsMap.containsKey(cp.Id)) {
                        cp.Banking_Country__c.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                        alreadyProcessed.Banking_Country__c.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                    } else if (newCPsMap.containsKey(alreadyProcessed.Id)) {
                        alreadyProcessed.Banking_Country__c.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                    } else {
                        cp.Banking_Country__c.addError(prepareUniquenessErrorMessage(cp.Banking_Country__c));
                    }
                } else {
                    countries.put(cp.Banking_Country__c, cp);
                }
            }
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares error message for already used country
      * @Params:          String country - already used country
      * @Returns:         String - created error message
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static String prepareUniquenessErrorMessage(String country) {
        return country + ' ' + Label.errMsg_AlreadyUsed;
    }

}