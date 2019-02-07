/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate :2017-06-23
@Description : Add contact t parent Account
@Test Class : ZZTEST_ContactTrigger_Helper
------------------------------------------------------*/
global class Batch_AddClientContactToRelationship implements Database.Batchable<sObject>{
    public Set<ID> contactIDs{get;set;}
    global Batch_AddClientContactToRelationship(Set<ID> contactIDs)
    {
        this.contactIDs = contactIDs;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {      
        return  Database.getQueryLocator([Select ID,AccountId,Name from Contact where ID IN:contactIDs]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {      
        Set<ID> accountIDs = new Set<ID>();
        List<AccountContactRelation> accountContactRelationshipList = new List<AccountContactRelation>();
        List<Contact> contactToUpdate = new List<Contact>();
        
        for(Contact con : scope){
            accountIDs.add(con.accountID);
        }
        
        Map<ID,Account> accountListMap = new Map<ID,account>([select id,ParentID,RecordTypeID,RecordType.Name,Type 
                                     from account 
                                     where ID IN:accountIDS]);
        
        for(Contact con :scope){
            if(accountListMap.containsKey(con.AccountId)){
                Account currentAccount  = accountListMap.get(con.AccountId);
                
                if(currentAccount.recordTypeID==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId()){
                    if(currentAccount.ParentID!=null){
                        accountContactRelationshipList.add(new AccountContactRelation(AccountID=currentAccount.ParentId,contactID = con.ID));
                        con.accountID = currentAccount.ParentId;
                    contactToUpdate.add(con);
                    }
                }
                
            }
            
        }
        
        
        if(accountContactRelationshipList.size()>0){
            insert accountContactRelationshipList;
        }
        if(contactToUpdate.size()>0)
        {
            update contactToUpdate;
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    
}