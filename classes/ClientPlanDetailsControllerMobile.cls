/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanDetails Lightning component.
* @Date:        02/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanDetailsControllerMobile
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanDetailsControllerMobile {
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client plan and client plan completion
      * @Params           String planId - client plan Id
      * @Returns:         Map<String, Object> - contains client plan itself and completion
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, Object> getClientPlan(String planId) {
        List<Client_Plan__c> plans = [
            SELECT Relationship__c, Status__c, Expansion_Policy__c, DG__c, LGD__c, Relationship__r.Owner.Name, LastModifiedDate,
                Client_Overview__c, FAIS_Status__c, Financial_Year_End__c, Latest_Audited_Financial_Statement__c,
                Sector_Overview__c, TFL__c, Country_Presence_Count__c, Relationships_Count__c, Budget_Revenues_Count__c,
                Potential_Opportunities_Count__c, Strategies_Count__c, Org_Structure_Items_Count__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return null;
        }

        Client_Plan__c plan = plans[0];
        
        Integer planProgress = 0;

        if (plan.Client_Overview__c != null && plan.Client_Overview__c.length() > 20) planProgress += 8;
        if (plan.Status__c != null) planProgress += 2;
        if (plan.Expansion_Policy__c != null) planProgress += 2;
        if (plan.DG__c != null) planProgress += 2;
        if (plan.FAIS_Status__c != null) planProgress += 2;
        if (plan.Financial_Year_End__c != null) planProgress += 4;
        if (plan.Latest_Audited_Financial_Statement__c != null) planProgress += 2;
        if (plan.Sector_Overview__c != null && plan.Sector_Overview__c.length() > 20) planProgress += 8;
        if (plan.TFL__c != null) planProgress += 2;

        planProgress += (getTeamMembers(planId).size() == 0 ? 0 : 4);
        
        Integer finInfoCount = Database.countQuery('SELECT count() FROM Financial_Information__c' +
            ' WHERE (Year__c = \'' + String.valueOf(Date.today().year() - 1) + '\' OR Year__c = \'' + Date.today().year() + '\')' +
            ' AND Relationship__c = \'' + plan.Relationship__c + '\'');
        if (finInfoCount > 1) planProgress += 5;
        if (finInfoCount > 0) planProgress += 3;
        
        if (plan.Country_Presence_Count__c > 5) planProgress += 5;
        if (plan.Country_Presence_Count__c > 1) planProgress += 3;

        if (plan.Relationships_Count__c > 5) planProgress += 5;
        if (plan.Relationships_Count__c > 1) planProgress += 3;

        if (plan.Budget_Revenues_Count__c > 2) planProgress += 5;
        if (plan.Budget_Revenues_Count__c > 0) planProgress += 3;

        if (plan.Potential_Opportunities_Count__c > 0) planProgress += 3;
        if (plan.Potential_Opportunities_Count__c > 2) planProgress += 5;

        Integer optyCount = Database.countQuery('SELECT count() FROM Opportunity' + 
            ' WHERE Client_Plan_Strategy__r.Client_Plan__c = \'' + planId + '\'');
        if (optyCount > 0) planProgress += 3;
        if (optyCount > 2) planProgress += 5;

        if (plan.Strategies_Count__c > 0) planProgress += 3;
        if (plan.Strategies_Count__c > 5) planProgress += 5;
        
        if (plan.Org_Structure_Items_Count__c > 1) planProgress += 3;
        if (plan.Org_Structure_Items_Count__c > 5) planProgress += 5;

        Map<String, Object> result = new Map<String, Object>();
        result.put('plan', plan);
        result.put('planProgress', planProgress);
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of account team members
      * @Params           String planId - client plan Id
      * @Returns:         List<Account_Team_Member__c>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Account_Team_Member__c> getTeamMembers(String planId) {
        
        return [
            SELECT Id, Team_Member__r.Id, Team_Member__r.Name, Team_Role__c
            FROM Account_Team_Member__c
            WHERE Organisation__c IN 
                (SELECT Relationship__c
                FROM Client_Plan__c 
                WHERE Id = :planId)
        ];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of fields' metadata
      * @Returns:         Map<String, List<String>> - keys are name fields, values are picklists' options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Map<String, List<String>> getMetadata() {
        Map<String, List<String>> metadata = new Map<String, List<String>>();

        //stage options
        Schema.DescribeFieldResult fieldResult = Client_Plan__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('stage', options);

        //expansion policy
        fieldResult = Client_Plan__c.Expansion_Policy__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('expansionPolicy', options);
        
        //dg
        fieldResult = Client_Plan__c.DG__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        metadata.put('dg', options);

        return metadata;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves client plan data shown on this tab
      * @Params           String planId - client plan Id, values to change to
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean saveClientPlanInfo(String planId, String stage, String expansionPolicy, 
            String dg, Decimal lgd) {
        
        List<Client_Plan__c> plans = [
            SELECT Status__c, Expansion_Policy__c, DG__c, LGD__c
            FROM Client_Plan__c
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return true;
        }
        
        Client_Plan__c plan = plans[0];
        plan.Status__c = stage;
        plan.Expansion_Policy__c = expansionPolicy;
        plan.DG__c = dg;
        plan.LGD__c = lgd;
        
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
      * @Description:     removes team member
      * @Params           String planId - team member Id
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean removeTeamMember(String memberId) {
    
        List<Account_Team_Member__c> members = [
            SELECT Id
            FROM Account_Team_Member__c
            WHERE Id = :memberId
        ];
        
        if (members.isEmpty()) {
            return true;
        }
        
        try {
            delete members[0];
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     search of users which are not in account team
      * @Params           String limitString - records limitation, String name - username start string, 
      *                   List<String> team - Ids of team members to exclude them from search
      * @Returns:         List<User> - found users
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<User> getUsers(String limitString, String name, List<String> team) {
    
        if (team == null) {
            return new List<User>();
        }
    
        if (name == null) {
            name = '%';
        } else {
            name += '%';
        }
        
        Integer limitInt;
        try {
            limitInt = Integer.valueOf(limitString);
        } catch (Exception e) {
            system.debug(e);
            return new List<User>();
        }
    
        return [
            SELECT Id, Name
            FROM User
            WHERE Name LIKE :name AND Id NOT IN :team
            LIMIT :limitInt
        ];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of team member role options
      * @Returns:         List<String> - options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<String> getRoleOptions() {
    
        Schema.DescribeFieldResult fieldResult = Account_Team_Member__c.Team_Role__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> options = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds team member
      * @Params:          String planI - client plan Id, String userId - Id of user to add, String role - team role
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static Boolean addTeamMember(String planId, String userId, String role) {
    
        List<Client_Plan__c> plans = [
            SELECT Relationship__c
            FROM Client_Plan__c 
            WHERE Id = :planId
        ];
        
        if (plans.isEmpty()) {
            return true;
        }
            
        Account_Team_Member__c atm = new Account_Team_Member__c();
        
        try {
            atm.Team_Member__c = userId;
            atm.Team_Role__c = role;
            atm.Organisation__c = plans[0].Relationship__c;
            insert atm;
            
        } catch (Exception e) {
            system.debug(e);
            return true;
        }
        
        return false;
        
    }
    
}