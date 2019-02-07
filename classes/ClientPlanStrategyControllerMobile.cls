/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanStrategyList Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanStrategyControllerMobile
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanStrategyControllerMobile {

    private static final String CLOSED_WON = 'Closed Won';
    
    private static final String CLOSED_LOST = 'Closed Lost';

     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of strategies
      * @Params:          String planId - Id of client plan, String name - name of strategy to look for
      * @Returns:         List<Client_Plan_Strategy__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Client_Plan_Strategy__c> getStrategies(String planId, String name) {
        
        if (name == null) {
            name = '%';
        } else {
            name += '%';
        }
        
        return [
            SELECT Id, Name, LastModifiedDate
            FROM Client_Plan_Strategy__c
            WHERE Client_Plan__c = :planId AND Name LIKE :name
            ORDER BY LastModifiedDate DESC];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of strategy
      * @Params:          String strategyId - Id of strategy
      * @Returns:         Client_Plan_Strategy__c
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Client_Plan_Strategy__c getStrategy(String strategyId) {

        List<Client_Plan_Strategy__c> strategies = [
            SELECT Id, Name, CreatedDate, Client_Strategy__c, Bank_Strategy__c,
                (SELECT Id, Name, Close_Date__c, Type__c, Opportunity__c, Probability__c 
                    FROM Unqualified_Opportunities__r
                    WHERE IsConverted__c = false),
                (SELECT Id, Name, Probability
                    FROM Opportunities__r)
            FROM Client_Plan_Strategy__c
            WHERE Id = :strategyId
        ];

        if (strategies.isEmpty()) {
            return null;
        } else {
            return strategies[0];
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds strategy
      * @Params:          String planId - Id of client plan, String name - name of strategy
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addStrategy(String planId, String name) {
        
        Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();
        cps.Name = name;
        //cps.Client_Strategy__c = clientStrategy;
        //cps.Bank_Strategy__c = bankStrategy;

        try {
            cps.Client_Plan__c = planId;
            system.debug(cps);
            insert cps;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits strategy
      * @Params:          String strategyId - Id of strategy, String name - name of strategy
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editStrategy(String strategyId, String name) {
        List<Client_Plan_Strategy__c> strategies = [
            SELECT Id, Name, Client_Strategy__c, Bank_Strategy__c
            FROM Client_Plan_Strategy__c
            WHERE Id = :strategyId
        ];

        if (strategies.isEmpty()) {
            return true;
        }

        Client_Plan_Strategy__c cps = strategies[0];
        cps.Name = name;
        //cps.Client_Strategy__c = clientStrategy;
        //cps.Bank_Strategy__c = bankStrategy;

        try {
            update cps;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes strategy
      * @Params:          String strategyId - Id of strategy to remove
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeStrategy(String strategyId) {
        List<Client_Plan_Strategy__c> strategies = [
            SELECT Id
            FROM Client_Plan_Strategy__c
            WHERE Id = :strategyId
        ];

        if (strategies.isEmpty()) {
            return true;
        }

        try {
            delete strategies[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     unlinks opportunity from strategy
      * @Params:          String optyId - id of opportunity to unlink
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean unlinkOpty(String optyId) {
    
        List<Opportunity> optys = [
            SELECT Id, Client_Plan_Strategy__c
            FROM Opportunity
            WHERE Id = :optyId
        ];
        
        if (optys.isEmpty()) {
            return true;
        }
        
        optys[0].Client_Plan_Strategy__c = null;
        try {
            update optys[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes potential opportunity
      * @Params:          String optyId - id of opportunity remove
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removePotOpty(String optyId) {
    
        List<Potential_Opportunity__c> optys = [
            SELECT Id, Client_Plan_Strategy__c
            FROM Potential_Opportunity__c
            WHERE Id = :optyId
        ];
        
        if (optys.isEmpty()) {
            return true;
        }
        
        try {
            delete optys[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of field's metadata
      * @Returns:         Map<String, List<String>> - keys are field names, values are lists of picklists' values
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getPotOptyMetadata() {
        Map<String, List<String>> metadata = new Map<String, List<String>>();

        //stage options
        Schema.DescribeFieldResult fieldResult = Potential_Opportunity__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('stage', options);

        //type options
        fieldResult = Potential_Opportunity__c.Type__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('type', options);

        return metadata;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of field's metadata
      * @Returns:         Map<String, List<String>> - keys are field names, values are lists of picklists' values
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getOptyMetadata() {
        Map<String, List<String>> metadata = new Map<String, List<String>>();

        //stage options
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Integer i = 0; i < 3; i++) {
            options.add(entries[i].getLabel());
        }
        metadata.put('stage', options);

        //type options
        fieldResult = Opportunity.Type.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('type', options);

        return metadata;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds potential opportunity
      * @Params:          String planId - client plan Id, String strategyId - if of strategy to link to, field values
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addPotOpty(String planId, String strategyId, String name, String closeDate, 
            String product, String stage, String probability, String type) {

        Potential_Opportunity__c opty = new Potential_Opportunity__c();

        try {
            opty.Client_Plan__c = planId;
            opty.Client_Plan_Strategy__c = strategyId;
            opty.Name = name;
            opty.Close_Date__c = DateUtils.convertTimestampToDate(closeDate);
            opty.Product_Level_3__c = product;
            opty.Stage__c = stage;
            opty.Type__c = type;
            if (probability != null) {
                opty.Probability__c = Decimal.valueOf(String.valueOf(probability));
            }
            
            insert opty;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds opportunity
      * @Params:          String planId - client plan Id, String strategyId - if of strategy to link to, field values
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addOpty(String planId, String strategyId, String name, String closeDate, 
            String stage, String probability, String type) {

        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];

        if (plans.isEmpty()) {
            return true;
        }

        Opportunity opty = new Opportunity();

        try {
            opty.AccountId = plans[0].Relationship__c;
            opty.Client_Plan_Strategy__c = strategyId;
            opty.Name = name;
            opty.CloseDate = DateUtils.convertTimestampToDate(closeDate);
            opty.StageName = stage;
            opty.Type = type;
            if (probability != null) {
                opty.Probability = Decimal.valueOf(String.valueOf(probability));
            }
            
            insert opty;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits potential opportunity
      * @Params:          String optyId - if of opty, field values
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editPotOpty(String optyId, String name, String closeDate, String product, 
            String stage, String probability, String type) {

        List<Potential_Opportunity__c> optys = getPotOpty(optyId);

        if (optys.isEmpty()) {
            return true;
        }

        Potential_Opportunity__c opty = optys[0];
        opty.Name = name;
        opty.Stage__c = stage;
        opty.Type__c = type;

        try {
            opty.Close_Date__c = DateUtils.convertTimestampToDate(closeDate);
            opty.Product_Level_3__c = product;
            
            if (probability != null) {
                opty.Probability__c = Decimal.valueOf(String.valueOf(probability));
            }
            
            update opty;
        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of potential opportunity
      * @Params:          String optyId - if of opty
      * @Returns:         List<Potential_Opportunity__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Potential_Opportunity__c> getPotOpty(String optyId) {

        return [
            SELECT Name, Close_Date__c, Product_Level_3__c, Product_Level_3__r.Name, Stage__c, Probability__c, Type__c
            FROM Potential_Opportunity__c
            WHERE Id = :optyId
        ];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of opportunities available for linking
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Opportunity>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Opportunity> getOptysToLink(String planId) {

        return [
            SELECT Id, Name
            FROM Opportunity
            WHERE AccountId IN 
                (
                    SELECT Relationship__c
                    FROM Client_Plan__c
                    WHERE Id = :planId
                ) 
                AND Client_Plan_Strategy__c = null AND
                StageName != :CLOSED_WON AND StageName != :CLOSED_LOST ];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of potential opportunities available for linking
      * @Params:          String planId - Id of client plan
      * @Returns:         List<Potential_Opportunity__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Potential_Opportunity__c> getPotOptysToLink(String planId) {

        return [
            SELECT Id, Name
            FROM Potential_Opportunity__c
            WHERE Client_Plan_Strategy__c = null AND IsConverted__c = false AND Client_Plan__c = :planId
        ];
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     links opportunities to strategy
      * @Params:          String strategyId - Id of strategy to link to, List<String> optysToLink - Ids of optys to link
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean linkOptys(String strategyId, List<String> optysToLink) {

        List<Opportunity> optys = [
            SELECT Id, Client_Plan_Strategy__c
            FROM Opportunity
            WHERE Id IN :optysToLink
        ];

        try {
            for (Opportunity opty: optys) {
                opty.Client_Plan_Strategy__c = strategyId;
            }
            update optys;

        } catch (Exception e) {
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     links potential opportunities to strategy
      * @Params:          String strategyId - Id of strategy to link to, List<String> optysToLink - Ids of pot optys to link
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean linkPotOptys(String strategyId, List<String> optysToLink) {

        if (optysToLink == null || strategyId == null) {
            return true;
        }

        List<Potential_Opportunity__c> optys = [
            SELECT Id, Client_Plan_Strategy__c
            FROM Potential_Opportunity__c
            WHERE Id IN :optysToLink
        ];

        try {
            for (Potential_Opportunity__c opty: optys) {
                opty.Client_Plan_Strategy__c = strategyId;
            }
            update optys;

        } catch (Exception e) {
            system.debug(e);
            return true;
        }

        return false;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     edits richtext fields on a strategy
      * @Params:          String strategyId - Id of strategy to link to, String value - to be set,
      *                   Boolean isClient - true if client field, false otherwise
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean editRichtextField(String strategyId, String value, Boolean isClient) {

        List<Client_Plan_Strategy__c> strategies = [
            SELECT Client_Strategy__c, Bank_Strategy__c
            FROM Client_Plan_Strategy__c
            WHERE Id = :strategyId
        ];

        if (strategies.isEmpty()) {
            return true;
        }

        if (isClient) {
            strategies[0].Client_Strategy__c = value;
        } else {
            strategies[0].Bank_Strategy__c = value;
        }

        try {
            update strategies[0];
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