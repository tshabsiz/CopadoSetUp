public class Legal_Quote_Bulk_Approval {
    
    /**
     * Variables
    **/
    public static final Id userId = UserInfo.getUserId();
    public List<legalQuoteApprovalWrapper> legalQuoteWrapper { get; set; }
    public Id singleRowId { get; set; } 
    public String bulkApprovalMode { get; set; }
    public String approve { get; set; } 
    public String reject { get; set; } 
    public Boolean hasError { get; set; }
    @TestVisible  Private  Map<Id, Id> workItems;
    /**
* Constructor
**/
    public Legal_Quote_Bulk_Approval()
    {
        System.debug('### Legal_Quote_Bulk_Approval : Legal_Quote_Bulk_Approval');
        if(test.isRunningTest() == true) //only initialize list if test is running so we can set the list with testData in a test class, when tests are not running the buildWrapperItems method initializes it
        {
            workItems = new Map<Id, Id>(); 
        }
        //Default values.
        hasError = false;
    }
    
    /**
     * buildWrapperItems - Builds the approval records wrapper list.
    **/
    public void buildWrapperItems()
    {
        System.debug('### Legal_Quote_Bulk_Approval : buildWrapperItems');
        
        //Default values.
        hasError = false;
        approve = 'Approve';
        reject = 'Reject';
        
        //Clear lists.
        legalQuoteWrapper = new List<legalQuoteApprovalWrapper>();
        List<Legal_Quote__c> legalQuotes = new List<Legal_Quote__c>(); 
        
        //Map<Legal Quote Id, Work Item Id>
       if(test.isRunningTest() == false) //only clear list if test is njot running so we can set the list with testData in a test class
        {
        workItems = new Map<Id, Id>(); 
        //Gets the ids for all the approval process ids.
        workItems = LegalQuote_Helper.getWorkItemIds(userId);
        }
        //Make sure we have anything to approve.
        if(!workItems.isEmpty())
        {
            //Get the ids of the legal quotes for approval.
            Set<Id> legalQuoteIds = workItems.keySet();
            
            //Fetch full quote records.
            legalQuotes = [
                SELECT
                    Id,
                    Name,
                    Law_Firm__c,
                    Contact__c,
                    Motivation_Comments__c,
                    External_Counsel_Name__c,
                    Quote_Amount__c,
                    Quote_Amount_Rollup__c,
                    Legal_Quote_Request__r.Matter__c,
                    Legal_Quote_Request__r.Matter__r.Name,
                    Legal_Quote_Request__c,
                    Legal_Quote_Request__r.Name,
                    Legal_Quote_Request__r.Quote_Title__c
                FROM Legal_Quote__c 
                WHERE
                    Id IN :legalQuoteIds
            ];
            System.debug('### Legal_Quote_Bulk_Approval : Legal_Quote_Bulk_Approval : legalQuotes : '+legalQuotes);
            
            //We have anything to process.
            if(!legalQuotes.isEmpty())
            {
                //Loop through records.
                for(Legal_Quote__c legalQuote : legalQuotes)
                {
                    //New wrapper item.
                    legalQuoteApprovalWrapper wrapperItem = new legalQuoteApprovalWrapper();
                    wrapperItem.selected = false;
                    wrapperItem.comment = '';
                    wrapperItem.quote = legalQuote;
                    
                    //Get work item id from map.
                    wrapperItem.workItemId = workItems.get(legalQuote.Id);
                    
                    //Add to main wrapper list.
                    legalQuoteWrapper.add(wrapperItem);
                }
            }
        }
        //Nothing to approve.
        else
        {   
            //Set error msg.
            hasError = true;
            
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'You have no outstanding quote approvals..'));
        }
    }
    
    /**
    * actionBulkUpdate - Used to bulk update for global controls on page.
    **/
    public PageReference actionBulkUpdate()
    {
        System.debug('### Legal_Quote_Bulk_Approval : actionBulkUpdate');
        System.debug('### Legal_Quote_Bulk_Approval : actionBulkUpdate : bulkApprovalMode : '+bulkApprovalMode);
        
        //Blank list.
        List<legalQuoteApprovalWrapper> selectedWrappers = new List<legalQuoteApprovalWrapper>();
        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
        
        //Loop through wrapper list and determine which are selected.
        for(legalQuoteApprovalWrapper wrapperItem : legalQuoteWrapper)
        {
            //Selected?
            if(wrapperItem.selected == true)
            {
                //Add to list.
                selectedWrappers.add(wrapperItem);
            }
        }
        
        //Anything to process
        if(!selectedWrappers.isEmpty())
        {
            approvalRequests = LegalQuote_Helper.executeApprovals(selectedWrappers, bulkApprovalMode);
        
            //Anything to process?
            if(!approvalRequests.isEmpty())
            {
                //Update approval.
                Approval.ProcessResult[] processResults = Approval.process(approvalRequests);
            
                //Refesh data
                buildWrapperItems();
            }
        }
        
        //Default return.
        return null;
    }
    
    /**
     * approveSingleRow - Approves a single row. 
    **/
    public PageReference approveSingleRow()
    {
        System.debug('### Legal_Quote_Bulk_Approval : approveSingleRow');
        
        //Blank list.
        List<legalQuoteApprovalWrapper> wrapperList = new List<legalQuoteApprovalWrapper>();
        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
        
        for(legalQuoteApprovalWrapper wrapperItem : legalQuoteWrapper)
        {
             //Find selected quote details.
            if(wrapperItem.quote.Id == singleRowId)
            {
                //Add to single wrapper list.
                wrapperList.add(wrapperItem);
            }
        }
        
        //Anything to process?
        if(!wrapperList.isEmpty())
        {
            //Call helper call to get approval requests.
            approvalRequests = LegalQuote_Helper.executeApprovals(wrapperList, 'Approve');
            
            //Anything to process?
            if(!approvalRequests.isEmpty())
            {
                //Update approval.
                Approval.ProcessResult[] processResults = Approval.process(approvalRequests);
                
                //Refesh data
                buildWrapperItems();
            }
        }

        //Default return.
        return null;
    }
    
    /**
     * rejectSingleRow - Rejects a single row. 
    **/
    public PageReference rejectSingleRow()
    {
        System.debug('### Legal_Quote_Bulk_Approval : rejectSingleRow');
        
        //Blank list.
        List<legalQuoteApprovalWrapper> wrapperList = new List<legalQuoteApprovalWrapper>();
        List<Approval.ProcessWorkitemRequest> approvalRequests = new List<Approval.ProcessWorkitemRequest>();
        
        for(legalQuoteApprovalWrapper wrapperItem : legalQuoteWrapper)
        {
            //Find selected quote details.
            if(wrapperItem.quote.Id == singleRowId)
            {
                //Add to single wrapper list.
                wrapperList.add(wrapperItem);
            }
        }
        
        //Anything to process?
        if(!wrapperList.isEmpty())
        {
            //Call helper call to get approval requests.
            approvalRequests = LegalQuote_Helper.executeApprovals(wrapperList, 'Reject');
            
            //Anything to process?
            if(!approvalRequests.isEmpty())
            {
                //Update approval.
                Approval.ProcessResult[] processResults = Approval.process(approvalRequests);
                
                //Refesh data
                buildWrapperItems();
            }
        }

        //Default return.
        return null;
    }
    
    /**
     * actionLoadRecords - 
    **/
    public PageReference actionLoadRecords()
    {
        //Builds the approval records wrapper list.
        buildWrapperItems();
        
        //Default return.
        return null;
    }
    
    /**
     * Wrapper - Used for bulk selecting and commenting.
    **/
    public class legalQuoteApprovalWrapper
    {
        public Boolean selected { get; set; }
        public String comment { get; set; }
        public Legal_Quote__c quote { get; set; }
        public Id workItemId { get; set; }
        
        public legalQuoteApprovalWrapper()
        {
            //Empty constructor.
        }
    }
}