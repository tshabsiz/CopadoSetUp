/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate :
@Description : 
@Test Class : 
------------------------------------------------------*/
global class Batch_UpdateAttendeeSharing implements Database.Batchable<sObject>,Schedulable 
{
    public String strQuery{get;set;}
    global Batch_UpdateAttendeeSharing(String strQuery)
    {
        this.strQuery =strQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {      
            return  Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, List<Attendee__c> scope)
    {      
        List<Call_Report__Share> crsToSave = new List<Call_Report__Share>();
        for(Attendee__c att : scope)
        {
            Call_Report__Share crs = new Call_Report__Share();
                                    crs.ParentId = att.Call_Report__r.Id;
                                    crs.UserOrGroupId = att.Barclays_Attendee__c;
                                    crs.AccessLevel = 'Read';
            crsToSave.add(crs);
        }
        
        Database.insert(crsToSave,false);
       
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new Batch_UpdateAttendeeSharing('Select Id, Barclays_Attendee__c, CreatedDate FROM Attendee__c where '));
    }
}