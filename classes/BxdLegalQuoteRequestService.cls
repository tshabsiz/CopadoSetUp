public class BxdLegalQuoteRequestService {
    private static String QUOTE_FOLDER = 'Quotes';
    private static String LEGAL_QUOTE_REQUEST = 'Legal Quote Requests';
    private static String LITIGATION_RECORD_TYPE = 'Litigation Request';
    private static String EXTERNAL_FOLDER = '0';
    private static FolderHandler folderHandler = new FolderHandler(); 
    
    /**
    * createBoxFolders - used to create box folder for each legalQuote instance by calling createBoxLegalQuoteFolder in BxdLegalQuoteService
	**/
    public static void createBoxFolders(Legal_Quote_Request__c legalQuoteRequest, 
                                        List<Legal_Quote__c> lst_LegalQuote, 
                                        Map<String, List<Custom_FRUP__c>> frupMap, 
                                        Box_Folder_Structure__c requestStructure, 
                                        Box_Folder_Structure__c quoteStructure) 
    {
        
        if(legalQuoteRequest != null){         
            //init vars
            String folderId;
            WebhookHelper webhookHelper;
            List<Custom_FRUP__c> customFolders = new List<Custom_FRUP__c>();
            //NOTE: This should eventually be replaced by folderHandler toolkit but left to avoid breaking functionality for now
            box.Toolkit boxToolkit = new box.Toolkit();
                     
            //get legal quote request
            if(requestStructure != null){
                LEGAL_QUOTE_REQUEST = requestStructure.Folder_Name__c;
            }
            
            if(quoteStructure != null){
                QUOTE_FOLDER = quoteStructure.Folder_Name__c;
                EXTERNAL_FOLDER = quoteStructure.External_Collaboration_Id__c;
                webhookHelper = new WebhookHelper(quoteStructure.Webhook_Triggers__c, quoteStructure.Webhook_URL__c);
            }
            
            //Get existing parent folder
            String parentFolderId = boxToolkit.getFolderIdByRecordId(legalQuoteRequest.Matter__c);
            
            //get static folder details from custom frup
            String customKey = legalQuoteRequest.Matter__c + ' - ' + LEGAL_QUOTE_REQUEST;           
            List<Custom_FRUP__c> frups = frupMap.get(customKey);
            if (frups == null || frups.isEmpty()){
                //create holding folder
                system.debug('**static***'+LEGAL_QUOTE_REQUEST+'***parent***'+parentFolderId);
                String staticQuoteRequestFolderId = boxToolkit.createFolder(LEGAL_QUOTE_REQUEST, parentFolderId, null);
                
                //create record folder
                folderId = boxToolkit.createFolder(legalQuoteRequest.Name, staticQuoteRequestFolderId, null);
                boxToolkit.createFolderAssociation(legalQuoteRequest.Id, folderId);
                
                //add to custom folder details
                Custom_FRUP__c details = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticQuoteRequestFolderId, ParentFolderId__c = parentFolderId);
                customFolders.add(details);
            } else {
                Custom_FRUP__c details = frups[0];
                if(String.isBlank(details.FolderId__c)){
                    System.debug('something went wrong with the first ' + LEGAL_QUOTE_REQUEST + ' creation ***parent***'+parentFolderId);
                    
                    //create the parent static folder or get existing one
                    String requestFolderId = folderHandler.createBoxFolderOrGetExistingFolder(LEGAL_QUOTE_REQUEST, parentFolderId);
                    details.FolderId__c = requestFolderId;
                    customFolders.add(details);
                }
                
                folderId = createLegalQuoteRequestFolder(boxToolkit, legalQuoteRequest, details.FolderId__c);
            }        
            
            System.debug('***Legal Quote External Folder: '+folderId);
            
            //create quote instructions folder
            String quoteFolderKey = legalQuoteRequest.Id + ' - ' + QUOTE_FOLDER;
            BxdLegalQuoteHelper helper = createQuoteFolder(boxToolkit, folderId, QUOTE_FOLDER, quoteFolderKey, frupMap);
            if(!helper.quoteFolderExists){
                Custom_FRUP__c quoteCfd = new Custom_FRUP__c(CustomKey__c = quoteFolderKey, FolderId__c = helper.quoteFolderId, ParentFolderId__c = folderId);      
                customFolders.add(quoteCfd);
            }
            
            //loop through all quote items and create lawfirm response folders
            for(Legal_Quote__c legalQuote : lst_LegalQuote){
                BxdLegalQuoteHelper quoteHelper = BxdLegalQuoteService.createBoxLegalQuoteFolder(legalQuoteRequest, legalQuote, folderId, helper.quoteFolderId, webhookHelper, EXTERNAL_FOLDER, boxToolkit);
                if(quoteHelper != null){
                    //set lawfirm link
                    if(!String.isBlank(quoteHelper.lawFirmLink)){
                        legalQuote.Box_Document_Link__c = quoteHelper.lawFirmLink;
                    }
                    
                    //set webhook id 
                    if(!String.isBlank(quoteHelper.webhhookId)){
                        legalQuote.Box_Webhook__c = quoteHelper.webhhookId;
                    }
                    
                    //set quote link
                    if(!String.isBlank(quoteHelper.quoteUrl)){
                        String url = quoteHelper.quoteUrl;
                        url = url.replace(folderId, helper.quoteFolderId);
                        legalQuoteRequest.Box_Quote_Request_Link__c = url;
                    }
                }                 
            }
            
            // save box changes.
            boxToolkit.commitChanges();
            // save configuration
            if(!customFolders.isEmpty()){
                upsert customFolders;
            }                       
            //save links and webhook on records
            update legalQuoteRequest;
            if(!lst_LegalQuote.isEmpty()){
                update lst_LegalQuote;
            }        
        }
    }
    
    /**
	* createQuoteFolder - used to create an external box folder for the legalQuote
	**/
    private static BxdLegalQuoteHelper createQuoteFolder(box.Toolkit boxToolkit, String parentFolderId, String folderName, String customKey, Map<String, List<Custom_FRUP__c>> frupMap) {
        //get legal quote request co-owner email address
        String coowner = UserInfo.getUserEmail();
        BxdExternalCollaborationHelper external = new BxdExternalCollaborationHelper(coowner, folderName, parentFolderId, EXTERNAL_FOLDER, null, null);
        external = folderHandler.createExternalBoxFolder(external);
        String folderId = external.folderId;
        Boolean quoteFolderExists = false;
        
        // If there was an error, folderId will be null. mostRecentError will contain the error message
        String recentError = boxToolkit.mostRecentError;
        String folderExist = 'already exists';
        if(folderId == null && !String.isBlank(recentError) && recentError.contains(folderExist)) {
            List<Custom_FRUP__c> frups = frupMap.get(customKey);
            if (frups != null && !frups.isEmpty()){
                Custom_FRUP__c details = frups[0];
                folderId = details.FolderId__c;
                quoteFolderExists = true;
            }
        }       
        
        return new BxdLegalQuoteHelper(folderId, quoteFolderExists);
    }
    
    /**
	* createLegalQuoteRequestFolder - calls createFolder to create a folder for the passed legalQuoteRequest instance
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolder-
	**/
    private static String createLegalQuoteRequestFolder(box.Toolkit boxToolkit, Legal_Quote_Request__c legalQuoteRequest, String staticQuoteRequestFolderId) {
        //create the request folder
        String folderId = boxToolkit.createFolder(legalQuoteRequest.Name, staticQuoteRequestFolderId, null);

        // If there was an error, folderId will be null. mostRecentError will contain the error message        
        if(folderId == null) {
            String recentError = boxToolkit.mostRecentError;
            String folderExist = 'already exists';
            if(!String.isBlank(recentError) && recentError.contains(folderExist)){
                folderId = boxToolkit.getFolderIdByRecordId(legalQuoteRequest.Id);
            }            
        } else {
            //link the folder on the FRUP
            boxToolkit.createFolderAssociation(legalQuoteRequest.Id, folderId);
        }
        
        return folderId;
    }
    
    /**
	* Wrapper class for webhooks
	**/
	public class WebhookHelper
	{
		public String webhookTrigger { get; set; }
        public String webhookURL { get; set; }

		public WebhookHelper(String webhookTrigger, String webhookURL)
		{
			this.webhookTrigger = webhookTrigger;
			this.webhookURL = webhookURL;
		}
	}
    
    /**
	* Wrapper class for BxdFolderHandler
	**/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super(true);
        }
    }
}