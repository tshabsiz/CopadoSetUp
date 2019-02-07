/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanFinancials Lightning tab.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPresence
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanFinancialsControllerMobile {

    @testVisible
    private static final String ABSA = 'ABSA';

    @testVisible
    private static final String OTHER = 'OTHER';


     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client plan
      * @Params:          String planId - Id of client plan
      * @Returns:         Client_Plan__c
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Client_Plan__c getClientPlan(String planId) {
        List<Client_Plan__c> plans = [
            SELECT Id, TFL__c, FAIS_Status__c, Last_Review_Date__c, Financial_Year_End__c,
                Latest_Audited_Financial_Statement__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return null;
        } else {
            return plans[0];
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client financials
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Financial_Information__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Financial_Information__c> getClientFinancials(String planId) {

        List<Client_Plan__c> plans = [SELECT Relationship__c FROM Client_Plan__c WHERE Id = :planId];
        if (plans.isEmpty()) {
            return new List<Financial_Information__c>();
        }
        return [
            SELECT Id, Year__c, Turnover__c, Total_Assets__c, Net_Asset_Value__c, Total_Interest_Bearing_Debt__c,
                Cash_Generated_by_Operations__c, EBITDA__c, EBIT__c, ROE__c, ROA__c, Debt_Equity__c,
                Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c, CurrencyIsoCode
            FROM Financial_Information__c
            WHERE Relationship__c = :plans[0].Relationship__c
            ORDER BY Year__c DESC];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of fields' metadata
      * @Returns:         Map<String, List<String>> - keys are fields, values are lists of picklist values
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getRatingMetadata() {
        Map<String, List<String>> metadata = new Map<String, List<String>>();

        //fais options
        Schema.DescribeFieldResult fieldResult = Client_Plan__c.FAIS_Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('fais', options);

        //financial year end
        fieldResult = Client_Plan__c.Financial_Year_End__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('financialYearEnd', options);

        return metadata;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves client plan changes
      * @Params:          String planId - Id of client plan, fields to edit
      * @Returns:         Boolean - true if an error occcured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean saveRating(String planId, Decimal tfl, String fais, String lastReviewDate, 
            String financialYearEnd, String latestAudited) {
                
        List<Client_Plan__c> plans = [
            SELECT Id, TFL__c, FAIS_Status__c, Last_Review_Date__c, Financial_Year_End__c,
                Latest_Audited_Financial_Statement__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];

        if (plans.isEmpty()) {
            return true;
        }

        Client_Plan__c plan = plans[0];
        plan.TFL__c = tfl;
        plan.FAIS_Status__c = fais;
        plan.Last_Review_Date__c = DateUtils.convertTimestampToDate(lastReviewDate);
        plan.Financial_Year_End__c = financialYearEnd;
        plan.Latest_Audited_Financial_Statement__c = DateUtils.convertTimestampToDate(latestAudited);
        try {
            update plan;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of facilities and securities
      * @Params:          String planId - Id of client plan
      * @Returns:         String - json with data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static String getFacilitiesAndSecurity(String planId) {
        FacilitiesAndSecurity result = new FacilitiesAndSecurity();

        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        if (plans.isEmpty()) {
            result.absaFacilities = new List<Client_Plan_Facility__c>();
            result.otherFacilities = new List<Client_Plan_Facility__c>();
            result.security = new List<Client_Plan_Security__c>();
            return JSON.serialize(result);
        }

        result.absaFacilities = [
            SELECT Id, Limit__c, Utilisation__c, CurrencyIsoCode, Product_Level_3__r.Name
            FROM Client_Plan_Facility__c
            WHERE Relationship__c = :plans[0].Relationship__c AND Type_Of_Facility__c = :ABSA
            ORDER BY CreatedDate ASC
        ];

        result.otherFacilities = [
            SELECT Id, Limit__c, Bank__c, CurrencyIsoCode, Product_Level_3__r.Name
            FROM Client_Plan_Facility__c
            WHERE Relationship__c = :plans[0].Relationship__c AND Type_Of_Facility__c = :OTHER
            ORDER BY CreatedDate ASC
        ];

        result.security = [
            SELECT Id, Security_Description__c, Value__c, CurrencyIsoCode
            FROM Client_Plan_Security__c
            WHERE Relationship__c = :plans[0].Relationship__c
            ORDER BY CreatedDate ASC
        ];

        return JSON.serialize(result);
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of facility
      * @Params:          String faiclityId - Id of facility
      * @Returns:         List<Client_Plan_Facility__c> - found data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Client_Plan_Facility__c> getFacility(String facilityId) {

        return [SELECT Id, Limit__c, Utilisation__c, Bank__c, CurrencyIsoCode, Product_Level_3__c, Product_Level_3__r.Name
                FROM Client_Plan_Facility__c
                WHERE Id = :facilityId];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of facility fields metadata
      * @Returns:         Map<String, List<String>> - keys are fields' names, values are lists of picklist values
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getFacilityMetadata() {

        Map<String, List<String>> result = new Map<String, List<String>>();

        List<String> options = new List<String>();
        Schema.DescribeFieldResult f = Client_Plan_Facility__c.CurrencyIsoCode.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();

        for (Schema.PicklistEntry e: p) {
            options.add(e.getValue());
        }
        result.put('currencyIsoCode', options);

        return result;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds facility
      * @Params:          String planId, fields to set
      * @Returns:         Boolean - true if an error occured, fakse otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addFacility(String planId, String product, Decimal lim, String curr, 
        Decimal utilisation, String bank, Boolean isBarclays) {

        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];

        if (isBarclays == null || plans.isEmpty()) {
            return true;
        }

        Client_Plan_Facility__c fac = new Client_Plan_Facility__c();
        fac.Limit__c = lim;
        fac.CurrencyIsoCode = curr;

        if (isBarclays) {
            fac.Utilisation__c = utilisation;
            fac.Type_Of_Facility__c = ABSA;
        } else {
            fac.Bank__c = bank;
            fac.Type_Of_Facility__c = OTHER;
        }

        try {
            fac.Product_Level_3__c = product;
            fac.Relationship__c = plans[0].Relationship__c;
            insert fac;

        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits facility
      * @Params:          String facilityId, fields to set
      * @Returns:         Boolean - true if an error occured, fakse otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editFacility(String facilityId, String product, Decimal lim, String curr, 
        Decimal utilisation, String bank, Boolean isBarclays) {

        if (isBarclays == null || curr == null) {
            return true;
        }

        List<Client_Plan_Facility__c> facs = [
            SELECT Id, Product__c, Limit__c, Utilisation__c, CurrencyIsoCode
            FROM Client_Plan_Facility__c
            WHERE Id = :facilityId
        ];

        if (facs.isEmpty()) {
            return true;
        }

        Client_Plan_Facility__c fac = facs[0];
        fac.Limit__c = lim;
        fac.CurrencyIsoCode = curr;

        if (isBarclays) {
            fac.Utilisation__c = utilisation;
        } else {
            fac.Bank__c = bank;
        }

        try {
            fac.Product_Level_3__c = product;
            update fac;

        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of security
      * @Params:          String securityId
      * @Returns:         List<Client_Plan_Security__c> - found data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Client_Plan_Security__c> getSecurity(String securityId) {
      
        return [SELECT Id, Security_Description__c, Value__c, CurrencyIsoCode
                FROM Client_Plan_Security__c
                WHERE Id = :securityId
        ];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds security
      * @Params:          String planId, fields to set
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addSecurity(String planId, String description, Decimal value) {

        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];

        if (plans.isEmpty()) {
            return true;
        }

        Client_Plan_Security__c sec = new Client_Plan_Security__c();
        sec.Security_Description__c = description;
        sec.Value__c = value;

        try {
            sec.Relationship__c = plans[0].Relationship__c;
            insert sec;

        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits security
      * @Params:          String securityId, fields to set
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editSecurity(String securityId, String description, Decimal value) {

        List<Client_Plan_Security__c> secs = [
            SELECT Id, Security_Description__c, Value__c
            FROM Client_Plan_Security__c
            WHERE Id = :securityId
        ];

        if (secs.isEmpty()) {
            return true;
        }

        Client_Plan_Security__c sec = secs[0];
        sec.Security_Description__c = description;
        sec.Value__c = value;

        try {
            update sec;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of financials information
      * @Params:          String finId
      * @Returns:         List<Financial_Information__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Financial_Information__c> getFinancialInformation(String finId) {
        return [
            SELECT Id, Year__c, Turnover__c, Total_Assets__c, Net_Asset_Value__c, Total_Interest_Bearing_Debt__c,
                Cash_Generated_by_Operations__c, EBITDA__c, EBIT__c, ROE__c, ROA__c, Debt_Equity__c,
                Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c, CurrencyIsoCode
            FROM Financial_Information__c
            WHERE Id = :finId
        ];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of financial years available for adding
      * @Params:          String planId
      * @Returns:         List<String>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> getFinancialsYears(String planId) {
        List<Financial_Information__c> financials = getClientFinancials(planId);
        List<String> result = new List<String>();

        for (Financial_Information__c fi: financials) {
            result.add(fi.Year__c);
        }
        return result;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds financial information
      * @Params:          String planId, String year and fields to set
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
   public static Boolean addFinancials(String planId, String year, Decimal turnover, Decimal totalAssets, Decimal netAssetValue, 
        Decimal bearingDebt, Decimal cashGenerated, Decimal ebitda, Decimal ebit, Decimal roe, Decimal roa, Decimal debtEquity, 
        String currentRatio, Decimal eps, String interestCoverRatio) {

        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        if (plans.isEmpty()) {
            return true;
        }
        
        Financial_Information__c fi = new Financial_Information__c();
        fi.Year__c = year;
        fi.Turnover__c = turnover;
        fi.Total_Assets__c = totalAssets;
        fi.Net_Asset_Value__c = netAssetValue;
        fi.Total_Interest_Bearing_Debt__c = bearingDebt;
        fi.Cash_Generated_by_Operations__c = cashGenerated;
        fi.EBITDA__c = ebitda;
        fi.EBIT__c = ebit;
        fi.ROE__c = roe;
        fi.ROA__c = roa;
        fi.Debt_Equity__c = debtEquity;
        fi.Current_Ratio__c = currentRatio;
        fi.EPS__c = eps;
        fi.Interest_Cover_Ratio__c = interestCoverRatio;

        try {
            fi.Relationship__c = plans[0].Relationship__c;
            insert fi;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits financial information
      * @Params:          String financialsId and fields to set
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled  
    public static Boolean editFinancials(String financialsId, Decimal turnover, Decimal totalAssets, Decimal netAssetValue, 
        Decimal bearingDebt, Decimal cashGenerated, Decimal ebitda, Decimal ebit, Decimal roe, Decimal roa, Decimal debtEquity, 
        String currentRatio, Decimal eps, String interestCoverRatio) {
            
        List<Financial_Information__c> fis = [
            SELECT Id, Turnover__c, Total_Assets__c, Net_Asset_Value__c, Total_Interest_Bearing_Debt__c,
                Cash_Generated_by_Operations__c, EBITDA__c, EBIT__c, ROE__c, ROA__c, Debt_Equity__c,
                Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c, CurrencyIsoCode
            FROM Financial_Information__c
            WHERE Id = :financialsId
        ];

        if (fis.isEmpty()) {
            return true;
        }

        Financial_Information__c fi = fis[0];
        fi.Turnover__c = turnover;
        fi.Total_Assets__c = totalAssets;
        fi.Net_Asset_Value__c = netAssetValue;
        fi.Total_Interest_Bearing_Debt__c = bearingDebt;
        fi.Cash_Generated_by_Operations__c = cashGenerated;
        fi.EBITDA__c = ebitda;
        fi.EBIT__c = ebit;
        fi.ROE__c = roe;
        fi.ROA__c = roa;
        fi.Debt_Equity__c = debtEquity;
        fi.Current_Ratio__c = currentRatio;
        fi.EPS__c = eps;
        fi.Interest_Cover_Ratio__c = interestCoverRatio;

        try {
            update fi;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes financial information
      * @Params:          String financialsId
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeFinancials(String financialsId) {

        List<Financial_Information__c> fis = [
            SELECT Id
            FROM Financial_Information__c
            WHERE Id = :financialsId
        ];

        if (fis.isEmpty()) {
            return true;
        }

        try {
            delete fis[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    @testVisible
    private class FacilitiesAndSecurity {
        @testVisible
        List<Client_Plan_Facility__c> absaFacilities;
        
        @testVisible
        List<Client_Plan_Facility__c> otherFacilities;
        
        @testVisible
        List<Client_Plan_Security__c> security;
    }
    
}