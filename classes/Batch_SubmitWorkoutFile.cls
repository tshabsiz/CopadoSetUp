/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2018-08-01
@Description : 
@Test Class : 
------------------------------------------------------*/
global class Batch_SubmitWorkoutFile implements Database.Batchable<sObject>,Schedulable 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
       return Database.getQueryLocator([SELECT Id, Case__c, Date_Actioned__c, BRID__c, Team__c, Service_Type_Task__c,
                                        Processed__c,Name,Case__r.CaseNumber,Workout__c
                                        FROM WIP_Log__c 
                                        where Processed__c =false]);
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_SubmitWorkoutFile());
    }
    global void execute(Database.BatchableContext BC, List<WIP_Log__c> scope)
    { 
        CSC_Utility.createWorkoutFile(scope);
    }
}