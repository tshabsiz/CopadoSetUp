/**
* @Author       Unknown
* @Company:     Deloitte
* @Description: Helper for Contact trigger
* @Date:        13.10.2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ContactTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 13.10.2015    Svata Sejkota   US-0625 Class created
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public without sharing class ContactTrigger_Helper {
       
    public static void addToRelationshipGroup(List<Contact> triggerNew){
        
        Set<ID> contactIDs = new Set<ID>();
        
        for(Contact con : triggerNew){
            contactIDs.add(con.ID);
        }
        
        Database.executeBatch(new Batch_AddClientContactToRelationship(contactIDs));
        
    }
}