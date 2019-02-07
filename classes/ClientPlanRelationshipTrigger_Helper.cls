/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Helper class for ClientPlanRelationshipTrigger
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanRelatTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanRelationshipTrigger_Helper {

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     deletes all relationship items for every relationship triggered
      * @Params:          oldMap
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static void deleteRelationshipItems(Map<Id, Client_Plan_Relationship__c> oldMap) {
            
        Set<Id> aprIds = oldMap.keySet();
        
        List<Client_Plan_Relationship_Item__c> items = [
            SELECT Id
            FROM Client_Plan_Relationship_Item__c
            WHERE Client_Plan_Relationship__c IN :aprIds];
        
        try {
            delete items;
        } catch (Exception e) {
            System.debug(e);
        }
    }

}