/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanHeader VF component.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanHeader
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanHeaderController {
    
    public String orgName {get;set;}
    
    public String orgId {get;set;}
    
    public String planId {get;set;}

    public ClientPlanHeaderController() {
        planId = ApexPages.currentPage().getParameters().get('planId');
        if (String.isEmpty(planId)) {
            planId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if (!String.isEmpty(planId)) {
            queryOrgName(planId);
        } else {
            orgName = '';
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries organisation name
      * @Params           String planId - Id of client plan
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryOrgName(String planId) {
    
        List<Client_Plan__c> plans = [
            SELECT Relationship__c, Relationship__r.Name
            FROM Client_Plan__c 
            WHERE Id = :planId];
            
        if (plans.isEmpty()) {
            orgName = '';
            orgId = '#';
        } else {
            orgName = plans[0].Relationship__r.Name;
            orgId = plans[0].Relationship__c;
        }
    }
    
}