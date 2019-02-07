/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanList Lightning component.
* @Date:        2/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanListControllerMobile
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ClientPlanListControllerMobile {
    
     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     searches for acccounts according to name and limit in params
      * @Params:          String limitString - records limit, String name - account name to search for
      * @Returns:         List<Account>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static List<Account> getAccounts(String limitString, String name) {
    
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
            return new List<Account>();
        }
        
        List<Account> result = [
            SELECT Name, Owner.Name,
                (
                SELECT Name, Status__c, CreatedDate
                FROM ClientPlans__r
                ORDER BY CreatedDate DESC
                )
            FROM Account
            WHERE Name LIKE :name
            LIMIT :limitInt
        ];
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     creates new client plan
      * @Params:          String accountId
      * @Returns:         String - Id of created plan, null if an error occcured
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @AuraEnabled
    public static String addPlan(String accountId) {
        
        Client_Plan__c plan = new Client_Plan__c();
        
        try {
            plan.Relationship__c = accountId;
            insert plan;
            return plan.Id;
        } catch (Exception e) {
            system.debug(e);
            return null;
        }
    }
    
}