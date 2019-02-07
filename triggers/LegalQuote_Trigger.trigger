/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 12/07/2017 - PG    - Created trigger.

**/ 
trigger LegalQuote_Trigger on Legal_Quote__c (before insert, after insert, before update, after update) 
{
    //Blank list.
    Set<Id> legalQuoteIds = new Set<Id>();
    
    //Before Insert Context
    if(Trigger.isBefore && Trigger.isInsert)
    {
        //Blank list.
        Set<Id> legaQuoteRequestIds = new Set<Id>();
        Map<Id, Id> parentRecordTypeMap = new Map<Id, Id>();
        
        //Legal quote request record type map.
        Map<Id, String> recordTypeMap = LegalQuoteRequest_Helper.getRecordTypeMap();
        
        //Legal quote record type map.
        Id litigationQuoteRTId = LegalQuote_Helper.recordTypeIdByName('Litigation Quote');
        Id legalQuoteRTId = LegalQuote_Helper.recordTypeIdByName('Legal Quote');
        
        //Loop through inserted records.
        for(Legal_Quote__c legalQuote : Trigger.new)
        {
            //Add the legal quote requests to set.
            legaQuoteRequestIds.add(legalQuote.Legal_Quote_Request__c);
        }
        
        //Get full legal quote request record.
        List<Legal_Quote_Request__c> legalQuoteRequests = LegalQuoteRequest_Helper.getFullRecords(legaQuoteRequestIds);
        
        //Build the legal quote request to record type map.
        for(Legal_Quote_Request__c legalQuoteRequest : legalQuoteRequests)
        {
            //Add to map.
            parentRecordTypeMap.put(legalQuoteRequest.Id, legalQuoteRequest.RecordTypeId);
        }
        
        //Loop through inserted records.
        for(Legal_Quote__c legalQuote : Trigger.new)
        {
            Id parentRecordTypeId       =  parentRecordTypeMap.get(legalQuote.Legal_Quote_Request__c);
            String parentRecordTypeName =  recordTypeMap.get(parentRecordTypeId);
            
            if(parentRecordTypeName == 'Litigation Request')
            {
                //Set record type.
                legalQuote.RecordTypeId = litigationQuoteRTId;
                
                //Set Quote recieved.
                legalQuote.Quote_Recieved__c = true;
            }
            else
            {
                //Set record type.
                legalQuote.RecordTypeId = legalQuoteRTId;
            }
        }
    }
    //Before Insert Context End.
    
    //After Insert Context
    if(Trigger.isAfter && Trigger.isInsert)
    {     
        for(Legal_Quote__c legalQuote : Trigger.new)
        {
            legalQuoteIds.add(legalQuote.Id);
        }    

        //Insert record. 
        List<Legal_Quote_Item__c> legalQuoteItems = LegalQuote_Helper.blah(legalQuoteIds);        
        insert legalQuoteItems;

        //Set quote approver.
        LegalQuote_Helper.setQuoteApprover(Trigger.new);
    }
    //After Insert Context end.

    //After Update
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        LegalQuoteRequest_Helper.detemineLegalQuoteRequestStatus(Trigger.new, Trigger.oldMap); 
    }
    //After Update End.
}