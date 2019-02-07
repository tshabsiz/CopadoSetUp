/*-------------------------------------------------------
@CreatedBY : Sizwe Tshabalala 
@CreatedDate :
@Description : 
@Test Class : 
------------------------------------------------------*/
global class Batch_ProductPartnerReminder implements Database.Batchable<sObject>,Schedulable 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {      
            return  Database.getQueryLocator('SELECT Id, ProcessDefinition.Name, TargetObjectId,TargetObject.ID, Status FROM ProcessInstance where ProcessDefinition.Name=\'Product Partner Approval\' and Status = \'Pending\'');
    }
    global void execute(Database.BatchableContext BC, List<ProcessInstance> scope)
    {      
        Set<ID> oppID  = new Set<ID>();        
        for(ProcessInstance PI : scope)
        {
            oppID.add(PI.TargetObjectId);
        }
        
        List<Opportunity> oppList = [Select ID,ProductPartner__r.ManagerID,ProductPartner__c,ProductPartner__r.Manager.Email from Opportunity where ID IN: oppID];
        
        Opportunity_Email_Alert_Config__c opportunityConfig = Opportunity_Email_Alert_Config__c.getValues('ProductPartnerReminder');
        ID templateID  =opportunityConfig.EscalateTemplateID__c;
        
        SendOpportunityEmailAlert_Function.sendWarningEmailProductPartner(oppList,templateID,true);
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_ProductPartnerReminder());
    }
}