/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2017-05-31
@Description : Batch Process sends out emaili notifications on opportunities that have passed their closedate or nearing their closeddate while they are not closed
@Test Class : Batch_SendOpportunityEmailAlert_Test
------------------------------------------------------*/
global class Batch_SendOpportunityEmailAlert implements Database.Batchable<sObject>,Schedulable 
{
    private Date ReminderEarlierDate;
    private Opportunity_Email_Alert_Config__c opportunityConfig;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator ql;
        
        //Tonga MM : Get config setting used to query opportunities as well as templates thats are to be used for sending out emails
        opportunityConfig = Opportunity_Email_Alert_Config__c.getValues('ClosedOpportunityAlert');
        
        if(opportunityConfig!=null)
        {
            List<String>  stageNames = opportunityConfig.StageName__c.split(';');
            ReminderEarlierDate = Date.today().addDays(Integer.valueOf(opportunityConfig.Future_Warning_Days__c));
            return  Database.getQueryLocator([Select ID, name, closeDate, StageName, Owner.Name, CreatedDate, Owner.Manager.Email 
                                              from Opportunity 
                                              where closeDate <=: ReminderEarlierDate 
                                              AND CALENDAR_YEAR(closeDate) >=: Integer.ValueOf(opportunityConfig.Starting_Year__c) 
                                              AND StageName 
                                              NOT IN: stageNames 
                                              AND Owner.UserRole.Name 
                                              Like '%CIB%'  AND Owner.isActive = true
                                             AND (NOT Owner.Email Like '%example%')
                                              AND (NOT Owner.Manager.Email Like '%example%')]);
        }
        else
        {
            return null;
        }
        
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {      
        List<Opportunity> beforeCloseDate = new List<Opportunity>();
        List<Opportunity> passedCloseDate = new List<Opportunity>();
        
        //Tonga MM : Get config setting used to query opportunities as well as templates thats are to be used for sending out emails
        opportunityConfig = Opportunity_Email_Alert_Config__c.getValues('ClosedOpportunityAlert');
        ReminderEarlierDate = Date.today().addDays(Integer.valueOf(opportunityConfig.Future_Warning_Days__c));
        for(Opportunity currentOpp : scope)
        {
            //Tonga MM : Go through each opp to determine if they have went passed their closeddate or near their close date without the status in the main query
            if(currentOpp.closeDate <= ReminderEarlierDate && currentOpp.closeDate >= Date.TODAY())
            {
                beforeCloseDate.add(currentOpp);
            }
            else              
            {
                passedCloseDate.add(currentOpp);
            }
        }
        
        // Tonga MM : detemine if collections have a atleast one item before sending them to the handler for emails to be sent
        if(beforeCloseDate.size()>0)
        { 
            SendOpportunityEmailAlert_Function.sendWarningEmail(beforeCloseDate, opportunityConfig.WarningTemplateID__c,false);
        }
        if(passedCloseDate.size()>0)
        {
            SendOpportunityEmailAlert_Function.sendWarningEmail(passedCloseDate, opportunityConfig.EscalateTemplateID__c,true);
        }
  
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_SendOpportunityEmailAlert());
    }
}