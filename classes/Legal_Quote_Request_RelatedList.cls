public class Legal_Quote_Request_RelatedList {
    
    /**
     * Variables
    **/
    private Legal_Quote_Request__c recordObject { get; set; }
    public List<LegalQuoteWrapper> legalQuotesWrapper { get; set; } 
    public List<Legal_Quote__c> legalQuotesSubmitted { get; set; } 
    public String parentLegelQuoteRequest { get; set; } 
    public Boolean pageHasError { get; set; }
    
    Public String LegalquoteNoAmountError {get;set;}
   
    /**
    public Boolean shouldRedirect { get; private set; }
    **/
    public String redirectURL { get; set; }
    
    /**
     * Constructor
    **/
    public Legal_Quote_Request_RelatedList(){
    
    }
    
    public Legal_Quote_Request_RelatedList(ApexPages.StandardController controller)
    {
        System.debug('### Legal_Quote_Request_RelatedList');
        
        //Some default values.
        legalQuotesWrapper = new List<LegalQuoteWrapper>();
        legalQuotesSubmitted = new List<Legal_Quote__c>(); 
        redirectURL = null;
        pageHasError = false;
        
        //Get record from controller.
        recordObject = (Legal_Quote_Request__c)controller.getRecord();
        System.debug('### Legal_Quote_Request_RelatedList : recordObject : '+recordObject);
        
        //Fetch a list of assocaited legal quotes.
        List<Legal_Quote__c> relatedLegalQuotes = [
            SELECT
                Id,
                Name,
                Law_Firm__c,
                Contact__c,
                Status__c,
                Legal_Quote_Request__c,
                External_Counsel_Name__c,
                CreatedById,
                CreatedDate
            FROM Legal_Quote__c
            WHERE 
                Legal_Quote_Request__c = :recordObject.Id
        ];
        
        System.debug('### Legal_Quote_Request_RelatedList : relatedLegalQuotes : '+relatedLegalQuotes);
        
        //Are there actually related items.
        if(relatedLegalQuotes.size() > 0 || relatedLegalQuotes != null)
        {
            System.debug('### Legal_Quote_Request_RelatedList : IF');
            
            //loop through the records and build the wrapper.
            for(Legal_Quote__c quoteItem : relatedLegalQuotes) 
            {
                System.debug('### Legal_Quote_Request_RelatedList : FOR');
                
                //New wrapper item.
                LegalQuoteWrapper wrapperItem = new LegalQuoteWrapper();
                wrapperItem.legalQuote = quoteItem;
                wrapperItem.selected = false;
                
                System.debug('### Legal_Quote_Request_RelatedList : wrapperItem : '+wrapperItem);
                
                //Add to wrapper list.
                legalQuotesWrapper.add(wrapperItem);   
            }
        }
        System.debug('### Legal_Quote_Request_RelatedList : legalQuotesWrapper : '+legalQuotesWrapper);
    }
    
    /**
     * Builds the redirect URL for the selected records.
    **/
    public PageReference setupRedirect()
    {
        System.debug('### Legal_Quote_Request_RelatedList : setupRedirect');
         
        String idString = '';
        List<Legal_Quote__c> selectedLegalQuotes = new List<Legal_Quote__c>();
        
        //Detemine how many items are selected.
        for(LegalQuoteWrapper item : legalQuotesWrapper)
        {
            if(item.selected == true)
            {
                selectedLegalQuotes.add(item.legalQuote);
            }
        }
        System.debug('### Legal_Quote_Request_RelatedList : setupRedirect : idString : '+idString);
        
        //Return blank URL if nothing is selected.
        if(!selectedLegalQuotes.isEmpty() || selectedLegalQuotes.size() > 0)
        {
            //Build the URL parameter string.
            //Empty list of string.
            List<String> selectedQuoteIds = new List<String>();
            
            //Loop through the strings.
            for(Legal_Quote__c quote : selectedLegalQuotes)
            {
                selectedQuoteIds.add(quote.Id);
            }
            
            //Parameter string.
            idString = String.join(selectedQuoteIds, '|');
            
            //Set final redirect URL
            redirectURL = Page.Legal_Quote_Request_Submit_Approval.getUrl()+'?selectedRecords='+idString;
        }
        else
        {
            redirectURL = '';
        }
        
        //Return
        return null;
    }
    
    /**
     * Action - Loads the records passed to the approval page.
    **/
    public PageReference actionLoadApprovalRecords()
    {
        System.debug('### Legal_Quote_Request_RelatedList : actionLoadApprovalRecords');
        
        
        
        //URL parameters passed.
        String selectedParam = ApexPages.currentPage().getParameters().get('selectedRecords');
        String parentParam = ApexPages.currentPage().getParameters().get('parentRecord');
        
        Legal_Quote_Request__c[] QuoteRequest = [Select RecordType.Name from Legal_Quote_Request__c Where id=:parentParam];
        
        //Split them into strings.
        List<String> recordIds = selectedParam.split('\\|');
        System.debug('### Legal_Quote_Request_RelatedList : actionLoadApprovalRecords : recordIds : '+recordIds);
        
        //Set parent leqal quote request object.
        parentLegelQuoteRequest = parentParam;
        
        //Get all the passed records and assign.
        legalQuotesSubmitted = [
            SELECT
                Id,
                Name,
                Contact__c,Quote_Amount__c,Quote_Amount_Rollup__c,
                Law_Firm__c,
                Legal_Quote_Request__c, 
                Motivation_Comments__c,
                External_Counsel_Name__c,
                Status__c
            FROM Legal_Quote__c
            WHERE
                Id IN :recordIds 
                AND Status__c != 'Approved' AND Status__c != 'Pending Approval' AND Quote_Recieved__c = true
        ];
        
        System.debug('### Legal_Quote_Request_RelatedList : actionLoadApprovalRecords : legalQuotesSubmitted : '+legalQuotesSubmitted);
        
        Boolean NoAmount=false;
        
        for(Legal_Quote__c l:legalQuotesSubmitted){
                if((QuoteRequest[0].RecordType.Name=='Legal Request' && (l.Quote_Amount__c==null || l.Quote_Amount__c==0)) || (QuoteRequest[0].RecordType.Name=='Litigation Request' && l.Quote_Amount_Rollup__c ==0)){
                    NoAmount=true;    
                }            
        }
        
        if(NoAmount){
        LegalquoteNoAmountError = parentParam;
            Return new Pagereference('/Apex/LegalquoteNoAmountError?id='+parentParam);        
        }
        //Add the associated Legal_Quote_Request__c for reference in approval page cancel action.
        if(legalQuotesSubmitted.isEmpty())
        {
            //Set error variable.
            pageHasError = true;
                    
            //Show page error.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Only legal quotes that are marked as "Quote Received" and are not "Approved" or "Pending Approval" can be submitted for approval.'));
        }
        
        //Return
        return null;
    }
    
    Public Pagereference ErroronAmount(){   
            Return new Pagereference('/'+ApexPages.currentPage().getParameters().get('Id'));        
    }
    
    
    /**
     *  Action - Validates the form and submit the records for approval.
    **/
    public PageReference actionSubmitForApproval()
    {
        System.debug('### Legal_Quote_Request_RelatedList : actionSubmitForApproval');
        
        try
        {
            //Update the legal quote records with comments / motivation from form.
            update legalQuotesSubmitted;
            
            //Submit records for approval.
            Approval.ProcessResult[] approvalResults = LegalQuote_Helper.submitQuotesForApproval(legalQuotesSubmitted);
        }
        catch(Exception e)
        {
            return null;   
        }
        
        //Default return.
        return cancel();
    }
    
    /**
     *  Action - Custom cancel page redirect.
    **/
    public PageReference cancel() 
    { 
        System.debug('### Legal_Quote_Request_RelatedList : cancel');
        
        PageReference page = new PageReference('/'+parentLegelQuoteRequest);
        page.setRedirect(true);
        
        //Default return.
        return page;
    }
    
    /**
     * Wrapper class for selected items in the related list.
    **/
    public class LegalQuoteWrapper
    {
        public Legal_Quote__c legalQuote { get; set; }
        public Boolean selected { get; set; }
        
        public LegalQuoteWrapper()
        {
            //Empty constructor.
        }
    }
}