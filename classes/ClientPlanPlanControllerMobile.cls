/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanPlan Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanPlanControllerMobile
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanPlanControllerMobile {

    private static final String CLOSED_WON = 'Closed Won';
    
    private static final String CLOSED_LOST = 'Closed Lost';

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of budget revenues
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Budget_Revenue__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Budget_Revenue__c> getBudgetRevenues(String planId) {
    
        return [SELECT Id, Product_Level_3__r.Name, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, 
                   Previous_Year_Annualised_Revenues__c, Actual_Year_Annualised_Revenues__c,
                   Budget_Annualised__c, Next_year_budget__c, YTD_RWA__c, Actual_RWA__c, YTD_RoRWA__c, 
                   Actual_RoRWA__c, CurrencyIsoCode
               FROM Budget_Revenue__c
               WHERE Client_Plan__c = :planId
               ORDER BY Product_Level_3__r.Name];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of potential opportunities
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Potential_Opportunity__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Potential_Opportunity__c> getPotOptys(String planId) {
        
        return [
            SELECT Id, Name, Close_Date__c, Product_Level_3__r.Name, Stage__c, Probability__c, Type__c
            FROM Potential_Opportunity__c
            WHERE Client_Plan__c = :planId AND IsConverted__c = false AND Opportunity__c = null];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of opportunities
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Opportunity>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Opportunity> getOptys(String planId) {
    
        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return null;
        }
        
        return [
            SELECT Id, Name, Total_Balance_Facility_Size__c, Annualised_Income__c, StageName, Owner.Name, 
                CloseDate, CurrencyIsoCode, Probability
            FROM Opportunity
            WHERE AccountId = :plans[0].Relationship__c AND StageName != :CLOSED_WON AND 
                StageName != :CLOSED_LOST 
            ORDER BY Annualised_Income__c DESC];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of budget revenue
      * @Params:          String brId - Id of budget revenues
      * @Returns:         List<Opportunity>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Budget_Revenue__c> getBudgetRevenue(String brId) {

        List<Budget_Revenue__c> brs = [SELECT Id, Product_Level_3__r.Name, Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, 
                   Previous_Year_Annualised_Revenues__c, Actual_Year_Annualised_Revenues__c,
                   Budget_Annualised__c, Next_year_budget__c, YTD_RWA__c, Actual_RWA__c, YTD_RoRWA__c, 
                   Actual_RoRWA__c, CurrencyIsoCode
               FROM Budget_Revenue__c
               WHERE Id = :brId];
               
        if (brs.isEmpty()) {
            return new List<Budget_Revenue__c>();
        }
        
        return brs;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds budget revenue
      * @Params:          String planId - Id of client plan, field values
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addBudgetRevenue(String planId, String product, Decimal previousYtdRevenues, 
        Decimal ytdAnnualizedRevenues, Decimal budgetYtd, Decimal actYearAnnRev, Decimal annBudget,
        Decimal nextYearBudget, Decimal actRwa, Decimal actRorwa) {

        Budget_Revenue__c br = new Budget_Revenue__c();
        br.Previous_YTD_Revenues__c = previousYtdRevenues;
        br.Actual_YTD_Revenues__c = ytdAnnualizedRevenues;
        br.Budget_YTD__c = budgetYtd;
        br.Actual_Year_Annualised_Revenues__c = actYearAnnRev;
        br.Budget_Annualised__c = annBudget;
        br.Next_year_budget__c = nextYearBudget;
        br.Actual_RWA__c = actRwa;
        br.Actual_RoRWA__c = actRorwa;

        try {
            br.Product_Level_3__c = product;
            br.Client_Plan__c = planId;
            insert br;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits budget revenue
      * @Params:          String brId - Id of record, field values
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editBudgetRevenue(String brId, String product, Decimal previousYtdRevenues, 
        Decimal ytdAnnualizedRevenues, Decimal budgetYtd, Decimal actYearAnnRev, Decimal annBudget,
        Decimal nextYearBudget, Decimal actRwa, Decimal actRorwa) {

        List<Budget_Revenue__c> brs = [
            SELECT Id, Product_Level_3__c, Previous_YTD_Revenues__c, Actual_YTD_Revenues__c, Budget_YTD__c, 
                   Previous_Year_Annualised_Revenues__c, Actual_Year_Annualised_Revenues__c,
                   Budget_Annualised__c, Next_year_budget__c, YTD_RWA__c, Actual_RWA__c, YTD_RoRWA__c, 
                   Actual_RoRWA__c, CurrencyIsoCode
            FROM Budget_Revenue__c
            WHERE Id = :brId];

        if (brs.isEmpty()) {
            return true;
        }
        Budget_Revenue__c br = brs[0];
        br.Previous_YTD_Revenues__c = previousYtdRevenues;
        br.Actual_YTD_Revenues__c = ytdAnnualizedRevenues;
        br.Budget_YTD__c = budgetYtd;
        br.Actual_Year_Annualised_Revenues__c = actYearAnnRev;
        br.Budget_Annualised__c = annBudget;
        br.Next_year_budget__c = nextYearBudget;
        br.Actual_RWA__c = actRwa;
        br.Actual_RoRWA__c = actRorwa;

        try {
            br.Product_Level_3__c = product;
            update br;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes budget revenue
      * @Params:          String brId - Id of record
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeBudgetRevenue(String brId) {

        List<Budget_Revenue__c> brs = [
            SELECT Id
            FROM Budget_Revenue__c
            WHERE Id = :brId
        ];

        if (brs.isEmpty()) {
            return true;
        }

        try {
            delete brs[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     converts potential opportunity to opportunity
      * @Params:          String optyId - Id of potential opportunity to convert
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean convertUnqOpty(String optyId) {
        return ClientPlanUtilsMobile.convertUnqOpty(optyId);
    }

}