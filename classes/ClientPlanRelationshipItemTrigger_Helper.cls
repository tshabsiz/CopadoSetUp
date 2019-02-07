/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Helper class for ClientPlanRelationshipItemTrigger
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanRelatItemTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 2018-02-06  Dino Scarcella	 Check if contact has duplicate Barclays Contacts
*------------------------------------------------------------*/
public class ClientPlanRelationshipItemTrigger_Helper {

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     checks if every contact has only one barclays contact marked as primary
      * @Params:          newList
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static void checkPrimaryUniqueness(List<Client_Plan_Relationship_Item__c> newList) {
        
        Set<Id> relIds = new Set<Id>();
        Set<Id> itemIds = new Set<Id>();
        for (Client_Plan_Relationship_Item__c i: newList) {
            relIds.add(i.Client_Plan_Relationship__c);
            itemIds.add(i.Id);
        }
        
        List<Client_Plan_Relationship_Item__c> existingItems = [
                SELECT Id, Primary_Contact__c, Client_Plan_Relationship__c, Barclays_Contact_User__c
                FROM Client_Plan_Relationship_Item__c
                WHERE Client_Plan_Relationship__c IN :relIds AND Id NOT IN :itemIds];
                
        //key = relationship id
        //value = primary item
        Map<Id, Client_Plan_Relationship_Item__c> primaryItems = new Map<Id, Client_Plan_Relationship_Item__c>();
        Map<String, Client_Plan_Relationship_Item__c> uniqueContactItems = new Map<String, Client_Plan_Relationship_Item__c>();
        
        for (Client_Plan_Relationship_Item__c i: existingItems) {
            if (i.Primary_Contact__c) {
                primaryItems.put(i.Client_Plan_Relationship__c, i);
            }
            if (i.Client_Plan_Relationship__c != NULL 
                && i.Barclays_Contact_User__c != NULL
                && !uniqueContactItems.containsKey(String.valueOf(i.Client_Plan_Relationship__c)+String.valueOf(i.Barclays_Contact_User__c))) {
            	uniqueContactItems.put(String.valueOf(i.Client_Plan_Relationship__c)+String.valueOf(i.Barclays_Contact_User__c), i);   
            }
        }
        
        for (Client_Plan_Relationship_Item__c i: newList) {
            // Check Primary Uniqueness
            if (i.Primary_Contact__c) { 
                if (!primaryItems.containsKey(i.Client_Plan_Relationship__c)) {
                    primaryItems.put(i.Client_Plan_Relationship__c, i);
                } else {
                    i.Primary_Contact__c.addError(Label.errMsg_OneContactMax);
                }
            }
            // Check Unique Barclays Contact per Contact
            if (
                i.Client_Plan_Relationship__c != NULL 
                && i.Barclays_Contact_User__c != NULL 
                && !uniqueContactItems.containsKey(String.valueOf(i.Client_Plan_Relationship__c)+String.valueOf(i.Barclays_Contact_User__c))
               ) 
            {
            		uniqueContactItems.put(String.valueOf(i.Client_Plan_Relationship__c)+String.valueOf(i.Barclays_Contact_User__c), i);
            } else if (
                i.Client_Plan_Relationship__c != NULL 
                && i.Barclays_Contact_User__c != NULL 
                && uniqueContactItems.containsKey(String.valueOf(i.Client_Plan_Relationship__c)+String.valueOf(i.Barclays_Contact_User__c))
               ) 
            {
            	i.Barclays_Contact_User__c.addError(Label.errMsg_SameContact); 
            }
        }
    }
}