/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2018-08-01
@Description : AOM current work in Progress
@Test Class : Batch_SubmitWIP_Test
------------------------------------------------------*/
global class Batch_SubmitWIP implements Database.Batchable<sObject>,Schedulable 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(Test.isRunningTest())
        {
            return Database.getQueryLocator([Select ID,CaseNumber,Queue__c,Subcategory__c,IsClosed,Service_Type__c,CreatedDate,WIP__c
                                         From case 
                                         where IsClosed =false limit 10 ]);
        }
        else
        {
            return Database.getQueryLocator([Select ID,CaseNumber,Queue__c,Subcategory__c,IsClosed,Service_Type__c,CreatedDate,WIP__c,(SELECT Id 
                                                                                                          FROM WIP_Logs__r 
                                                                                                          where Processed__c =false) 
                                         From case 
                                         where IsClosed =false
                                            AND (recordType.Name = 'CSC Manual Cases' OR recordType.Name = 'CSC Default Support Cases')]);
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_SubmitWIP(),30000);
    }
    global void execute(Database.BatchableContext BC, List<Case> scope)
    { 
        CSC_Utility.createWIPFile(scope);
    }
}