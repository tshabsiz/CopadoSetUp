/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate :2017-06-23
@Description : The purpose of this job is to recalculate manual sharing entries that have been calculated in apex
@Test Class : Batch_RecalculateOpportunityShare_Test
------------------------------------------------------*/
global class Batch_RecalculateOpportunityShare implements Database.Batchable<sObject>,Schedulable 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {      
            return  Database.getQueryLocator([Select ID,OwnerID,parentID,Parent.OwnerID 
                                              from Account 
                                              where RecordTypeID =:Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId()
                                              AND Type='Global Parent']);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {      
        Map<id,Account> newBuiltAccountMap = new Map<ID,Account>();
        Map<ID,Account> oldBuiltAccountMap = new Map<ID,Account>();
        
        for(Account currentAccount : scope)
        {
            newBuiltAccountMap.put(currentAccount.ID, currentAccount);
            oldBuiltAccountMap.put(currentAccount.ID, currentAccount);
        }
        
        AccountTrigger_Helper.updateOpportunityShare(newBuiltAccountMap,oldBuiltAccountMap);
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_RecalculateOpportunityShare());
    }
}