public class LegalQuote_Helper  {

    public static void sendNotificationEmails(List<Legal_Quote__c> inputLegalQuotes) 
    {
        //Get the id of the email template
        Id emailTempateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'BAGL_Legal_Request_for_Quotation_Law_Firm'].Id;
        System.debug('### LegalQuote_Helper : sendEmails : emailTempateId : '+emailTempateId);
        
        //Final list of all email messages for sending.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        //Loop through input Legal Quotes.
        for(Legal_Quote__c legalQuote : inputLegalQuotes)
        {
            //Single email object.
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setTemplateId(emailTempateId); 
            singleEmail.setTargetObjectId(legalQuote.Contact__c);
            singleEmail.setWhatId(legalQuote.Id);
            
            //Add to list.
            emailMessages.add(singleEmail);
        }
        System.debug('### LegalQuote_Helper : sendEmails : emailMessages : '+emailMessages);
        
        //Send emails.
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
        System.debug('### LegalQuote_Helper : sendEmails : emailResults : '+emailResults);
    }
    
    /**
     * Used to bulk submit legal quotes for approval.
    **/
    public static Approval.ProcessResult[] submitQuotesForApproval(List<Legal_Quote__c> inputLegalQuotes)
    {
        System.debug('### LegalQuote_Helper : submitQuotesForApproval');
        
        //Blank list.
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessResult[] approvalResults = null;
        
        //Loop through legal quote records.
        for(Legal_Quote__c legalQuote : inputLegalQuotes)
        {
            //New approval item.
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setObjectId(legalQuote.Id);
            approvalRequest.setComments(legalQuote.Motivation_Comments__c);
            approvalRequest.setSubmitterId(UserInfo.getUserId());
            approvalRequest.setProcessDefinitionNameOrId('Legal_Quote_Approval_V2');
            approvalRequest.setSkipEntryCriteria(false);
            
            //Add to approval requests list.
            approvalRequests.add(approvalRequest);
        }
        
        //Anything to process.
        if(!approvalRequests.isEmpty()) 
        {
            System.debug('### LegalQuote_Helper : submitQuotesForApproval : TRY');
            
            //Submit records for approval.
            approvalResults = Approval.process(approvalRequests, false);
            System.debug('### LegalQuote_Helper : submitQuotesForApproval : approvalResults : '+approvalResults);
            
            //Return results.
            return approvalResults;
        }
        
        //Default return.
        return null;
    }
    
    /**
     * getUserQuoteApprovals - Used to bulk submit legal quotes for approval.
    **/
    public static Map<Id, Id> getWorkItemIds(Id inputUserId)
    {
        System.debug('### LegalQuote_Helper : getWorkItemIds');
        
        //Blnak list.
        List<ProcessDefinition> definitions = new List<ProcessDefinition>();
        List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>();
        Map<Id, Id> legalQuoteWorkItemIds = new Map<Id, Id>();
        
        //Try get an approval definition record.
        definitions = [SELECT Id, Name FROM ProcessDefinition WHERE State='Active' AND Name Like 'Legal Quote Approval V%' LIMIT 1];
        System.debug('### LegalQuote_Helper : getWorkItemIds : definitions : '+definitions);
        
        //Make sure we get a definition back.
        if(!definitions.isEmpty())
        {
            workItems = [
                SELECT
                    Id,
                    ProcessInstanceId,
                    ActorId,
                    ProcessInstance.ProcessDefinitionId,
                    ProcessInstance.TargetObjectId, 
                    ProcessInstance.Status
                FROM ProcessInstanceWorkitem
                WHERE 
                    ProcessInstance.ProcessDefinitionId = :definitions[0].Id 
                    AND ActorId = :inputUserId 
                    AND ProcessInstance.Status = 'Pending'
            ];
            System.debug('### LegalQuote_Helper : getUserQuoteApprovals : workItems : '+workItems);
            
            //Anything for approval?
            if(!workItems.isEmpty())
            {
                //Loop through all approval to build a list of legla quote objects.
                for(ProcessInstanceWorkitem workItem : workItems)
                {
                    //Add to id map.
                    legalQuoteWorkItemIds.put(workItem.ProcessInstance.TargetObjectId, workItem.Id);
                }
            }
        }
        
        //Default return
        return legalQuoteWorkItemIds;
    }
    
    public static List<Approval.ProcessWorkitemRequest> executeApprovals(List<Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper> inputlegalQuotesWrapper, String inputMode)
    {
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
        //Loop through input records.
        for(Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper wrapperItem : inputlegalQuotesWrapper)
        {
            //New approval request.
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setWorkitemId(wrapperItem.workItemId);
            request.setAction(inputMode);
            request.setComments(wrapperItem.comment);
            
            //Add to list.
            requests.add(request);
        }
        
        //Default return.
        return requests;
    }
    
    /**
     * fullRecords - Returns legal quotes records based on the input ids.
    **/
    public static List<Legal_Quote__c> getFullRecords(Set<Id> inputIds)
    {
        List<Legal_Quote__c> legalQuotes = new List<Legal_Quote__c>();
        
        legalQuotes = [
            SELECT 
                Id,
                Name,
                Law_Firm__c,
                Contact__c,
                Legal_Quote_Request__r.Litigation_Risk_Score__c,
                Legal_Quote_Request__c,
                Legal_Quote_Request__r.RecordType.Name
            FROM Legal_Quote__c 
            WHERE 
                Id IN :inputIds
        ];
        
        return legalQuotes;
    }
    
     /**
    * getRecordTypeMap - Returns a map of record type id to name.
    **/
    public static Map<Id, String> getRecordTypeMap()
    {
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Legal_Quote__c').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo info : recordTypeInfo)
        {
            recordTypeMap.put(info.getRecordTypeId(), info.getName()); 
        }
        
        //Default return.
        return recordTypeMap;
    }
    
    /**
     * recordTypeIdByName - Returns the record type id for a record type name.
    **/
    public static Id recordTypeIdByName(String inputRecordTypeName)
    {
        Id devRecordTypeId = Schema.SObjectType.Legal_Quote__c.getRecordTypeInfosByName().get(inputRecordTypeName).getRecordTypeId();
        return devRecordTypeId; 
    }
    
    public static List<Legal_Quote_Item__c> blah(Set<Id> inputLegalQuoteIds)
    {
        //Blank List
        Set<Id> relationshipIds = new Set<Id>();
        Set<Id> legalQuoteRequestIds = new Set<Id>(); 
        Map<Id, Set<Id>> legelQuoteRequestServices = new Map<Id,Set<Id>>();
        
        //Get full records.
        List<Legal_Quote__c> legalQuotes = getFullRecords(inputLegalQuoteIds); 

        //Build id sets.
        for(Legal_Quote__c legalQuote : legalQuotes)
        {
            legalQuoteRequestIds.add(legalQuote.Legal_Quote_Request__c);
            relationshipIds.add(legalQuote.Law_Firm__c);
        }
        
        //Get a list of all the services for the legal quote requests.
        List<Legal_Quote_Request__c> legalQuoteRequests = [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Legal_Quote_Request__c,
                        Fixed_Service_Activity__c
                    FROM Legal_Quote_Services__r
                )
            FROM Legal_Quote_Request__c
            WHERE
                Id IN :legalQuoteRequestIds
        ];
        
        //Build the service mapping for quote 
        for(Legal_Quote_Request__c legalQuoteRequest : legalQuoteRequests)
        {
            Set<Id> serviceIds = new Set<Id>();
            
            List<Legal_Quote_Service__c> legalQuoteServices = new List<Legal_Quote_Service__c>(legalQuoteRequest.Legal_Quote_Services__r); 
            legalQuoteServices.addAll(legalQuoteRequest.Legal_Quote_Services__r);

            for(Legal_Quote_Service__c legalQuoteService : legalQuoteServices)
            {
                serviceIds.add(legalQuoteService.Fixed_Service_Activity__c);
            }
            
            //Add to main service map.
            legelQuoteRequestServices.put(legalQuoteRequest.Id, serviceIds);
        }
        
        //Get all the cost records for law firms needed.
        List<Fixed_Service_Cost__c> fixedServiceCosts = [
            SELECT
                Id,
                Fixed_Service__c,
                Fee_Excl_VAT__c,
                Risk_Score__c,
                Fixed_Service__r.Relationship__c,
                Fixed_Service__r.Fixed_Service_Activity__c
            FROM Fixed_Service_Cost__c 
            WHERE 
                Fixed_Service__r.Relationship__c IN :relationshipIds
        ];
        
        List<Legal_Quote_Item__c> legalQuoteItems = new List<Legal_Quote_Item__c>();
        
        //The main part to build legal quote items.
        for(Legal_Quote__c legalQuote : legalQuotes)
        {
            //Get services for this legalQuote
            Set<Id> serviceIds = legelQuoteRequestServices.get(legalQuote.Legal_Quote_Request__c);
            system.debug('******SERV_ID:'+legelQuoteRequestServices+'******'+legalQuote.Legal_Quote_Request__c);
            for(Id serviceId : serviceIds)
            {
                for(Fixed_Service_Cost__c fixedServiceCost : fixedServiceCosts)
                {
                    if(fixedServiceCost.Fixed_Service__r.Fixed_Service_Activity__c == serviceId && fixedServiceCost.Fixed_Service__r.Relationship__c == legalQuote.Law_Firm__c  && legalQuote.Legal_Quote_Request__r.Litigation_Risk_Score__c == Decimal.valueOf(fixedServiceCost.Risk_Score__c))
                    {
                        Legal_Quote_Item__c quoteItem = new Legal_Quote_Item__c();
                        quoteItem.Legal_Quote__c = legalQuote.Id;
                        quoteItem.Fee_Excl_VAT__c = fixedServiceCost.Fee_Excl_VAT__c;
                        quoteItem.Fixed_Service__c = fixedServiceCost.Fixed_Service__c; 
                        
                        //Add tp list
                        legalQuoteItems.add(quoteItem);
                    }
                }
            }
            
        }
        
        return legalQuoteItems;
    }

    /**
    * 
    **/
    public static void setQuoteApprover(List<Legal_Quote__c> inputNewList)
    {
        //Variables.
        Set<Id> legalQuoteIds = new Set<Id>();
        List<Legal_Quote__c> legalQuotes = new List<Legal_Quote__c>();
        Set<id> legalRequestIds = new Set<Id>();

        //Loop through quotes.
        for(Legal_Quote__c legalQuote : inputNewList)
        {
            legalQuoteIds.add(legalQuote.Id);
        }

        //Get full records
        legalQuotes = [
            SELECT
                Id,
                Quote_Approver__c,
                Legal_Quote_Request__c,
                Status__c
            FROM Legal_Quote__c
            WHERE
                Id IN :legalQuoteIds
        ];

        //Loop thorigh full records.
        for(Legal_Quote__c legalQuote : legalQuotes)
        {
            //Add to requests set.
            legalRequestIds.add(legalQuote.Legal_Quote_Request__c);
        }

        //Get legal requests
        List<Legal_Quote_Request__c> legalQuoteRequests = [
            SELECT
                Id,
                Quote_Approver__c
            FROM Legal_Quote_Request__c
            WHERE
                Id IN :legalRequestIds 
        ];

        //Convert to map.
        Map<Id, Legal_Quote_Request__c> legalQuoteRequestsMap = new Map<Id, Legal_Quote_Request__c>(legalQuoteRequests);

        for(Legal_Quote__c quote : legalQuotes)
        {
            if(quote.Quote_Approver__c == null)
            {
                quote.Quote_Approver__c = legalQuoteRequestsMap.get(quote.Legal_Quote_Request__c).Quote_Approver__c;
            }

            if(quote.Status__c == null)
            {
                quote.Status__c = 'New';
            }
        }

        //Update records.
        update legalQuotes; 
    }
}