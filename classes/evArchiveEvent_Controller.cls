public class evArchiveEvent_Controller {
    
    public Event__c event {get;set;}
    
    
    public evArchiveEvent_Controller(ApexPages.StandardController stdController) 
    {
        event = (Event__c)stdController.getRecord();
    }

    public pageReference archiveEvent() {
        
        Id archiveRecType = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Archived').getRecordTypeId();
        event.RecordTypeId = archiveRecType;
        update event;
        
        Schema.DescribeSObjectResult result = Event__c.SObjectType.getDescribe();
        PageReference pageRef = new PageReference('/' + result.getKeyPrefix());
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
}