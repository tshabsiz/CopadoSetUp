public class BxdInvoiceService {
    private static String WEBHOOK_URL = '';
    private static final String INVOICE_FOLDER = 'Invoices';
    private static final String SUPPLIER_FOLDER = 'Suppliers';
    private static FolderHandler folderHandler = new FolderHandler();   
    
    /**
    * createInvoiceBoxFolder - this method executes asynchronously, it creates an invoice box folder by calling createBoxFolder in BxdFolderHandler
	**/
    @Future(callout = true)
    public static void createInvoiceBoxFolder(Id legalQuoteRequestId, Id legaQuoteId) {
        if(legalQuoteRequestId != null && legaQuoteId !=null){     
            Legal_Quote_Request__c legalQuoteRequest = [Select Id, Name, Matter__c, Quote_Title__c, Box_Supplier_Link__c, RecordTypeId From Legal_Quote_Request__c Where id =: legalQuoteRequestId];
            Legal_Quote__c quote = [Select Id, Name, Law_Firm__c, Status__c, Contact__c, RecordTypeId From Legal_Quote__c where Id =: legaQuoteId];
            Account account = [SELECT Name FROM Account WHERE Id =:quote.Law_Firm__c LIMIT 1];
            Contact contact = [SELECT Email, AccountId FROM Contact WHERE Id=:quote.Contact__c LIMIT 1];
            
            //Legal Quote Folder Structure
            Box_Folder_Structure__c quoteStructure = folderHandler.getFolderStructure(Legal_Quote__c.SObjectType, quote.RecordTypeId);
            if(quoteStructure != null){
                WEBHOOK_URL = quoteStructure.Webhook_URL__c;
            }   
                        
            String parentFolderId = folderHandler.getBoxFolderIdByRecordId(legalQuoteRequest.Id);
            system.debug('**PARENT '+parentFolderId);
            
            if(account != null && contact != null && !String.isBlank(parentFolderId)){
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.VIEWERUPLOADER;
                BxdCollaborationRequest collabRequest = BxdCollaborationRequest.getRequest();
                collabRequest.recordId = quote.Id;
                collabRequest.email = contact.Email;
                collabRequest.collabType = collabType;
                //create invoice folder
                String folderId = folderHandler.createBoxFolder(legalQuoteRequest.Quote_Title__c + ' - ' + quote.Name + ' - ' + INVOICE_FOLDER, parentFolderId);
                //create invoice shared link
                String invoiceLink = createSharedLinkQuoteResponse(folderId, collabRequest);
                //create webhook              
                String webhhookId = createWebhookForFolder(folderId);
                system.debug('**WEBHOOK ID '+webhhookId);
				
                String tempFolderId = folderHandler.getBoxFolderIdByRecordId(quote.Id);
                folderHandler.commitBoxChanges();
                
                //set webhook
                if(!String.isBlank(webhhookId)){
                    quote.Invoice_Received_WebhookId__c = webhhookId;           
                }
                //set link
                if(!String.isBlank(invoiceLink)){
                    String url = invoiceLink;
                    url = url.replace(tempFolderId, folderId);
                    System.debug('**INVOICE URL '+url);
                    quote.Invoice_Received_Box_Link__c = url;
                }     
                
                update quote;
            }
        }
    }
    
    /**
    * createSupplierBoxFolder - this method executes asynchronously, it creates a box folder for legalQuote dependant on the frup
    * It also create collaboration with Viewer Uploader collaborationType 
	**/
    @Future(callout = true)
    public static void createSupplierBoxFolder(Id legalQuoteRequestId, Id legaQuoteId) {
        if(legalQuoteRequestId != null && legaQuoteId !=null){
            Legal_Quote_Request__c legalQuoteRequest = [Select Id, Name, Matter__c, Quote_Title__c, Box_Supplier_Link__c, RecordTypeId From Legal_Quote_Request__c Where id =: legalQuoteRequestId];
            Legal_Quote__c legalQuote = [Select id, Law_Firm__c, Status__c, Contact__c, RecordTypeId From Legal_Quote__c where Id =: legaQuoteId];
            Account account = [SELECT Name FROM Account WHERE Id =:legalQuote.Law_Firm__c LIMIT 1];
            Contact contact = [SELECT Email, AccountId FROM Contact WHERE Id=:legalQuote.Contact__c LIMIT 1];
                        
            if(account != null && contact != null){
                String folderId;
                List<Custom_FRUP__c> customFolders = new List<Custom_FRUP__c>();
                
                //Get existing parent folder
                String parentFolderId = folderHandler.getBoxFolderIdByRecordId(legalQuoteRequest.Matter__c);
                
                String customKey = legalQuoteRequest.Matter__c + ' - ' + SUPPLIER_FOLDER;
                List<Custom_FRUP__c> frups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE CustomKey__c =:customKey];
                if (frups == null || frups.isEmpty()){
                    //create holding folder
                    String staticQuoteRequestFolderId = folderHandler.createBoxFolder(SUPPLIER_FOLDER, parentFolderId);
                    //create record folder
                    folderId = folderHandler.createBoxFolder(account.Name + ' - ' + legalQuoteRequest.Quote_Title__c, staticQuoteRequestFolderId);
                    //add to custom folder details
                    Custom_FRUP__c details = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticQuoteRequestFolderId, ParentFolderId__c = parentFolderId);
                    customFolders.add(details);
                } else {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(account.Name + ' - ' + legalQuoteRequest.Quote_Title__c, details.FolderId__c);
                }
                
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.VIEWERUPLOADER;
                BxdCollaborationRequest collabRequest = BxdCollaborationRequest.getRequest();
                collabRequest.recordId = legalQuoteRequest.Id;
                collabRequest.email = contact.Email;
                collabRequest.collabType = collabType;
                         
                //create response shared link
                String supplierLink = createSharedLinkQuoteResponse(folderId, collabRequest);
                String tempFolderId = folderHandler.getBoxFolderIdByRecordId(legalQuoteRequest.Id);
                folderHandler.commitBoxChanges();
                // insert
                if(!customFolders.isEmpty()){
                    insert customFolders;
                }
                
                //set link
                if(!String.isBlank(supplierLink)){
                    String url = supplierLink;
                    url = url.replace(tempFolderId, folderId);
                    legalQuoteRequest.Box_Supplier_Link__c = url; 
                    System.debug('**INVOICE URL '+url);
                    update legalQuoteRequest;
                }
            }                   
        }
    }
    
    /**
    * createSharedLinkQuoteResponse - this method create a collaboration by calling createCollaboration in BxdFolderHandler and request the folder url by calling getBoxFolderURL in BxdFolderHandler
	**/
    private static String createSharedLinkQuoteResponse(String folderId, BxdCollaborationRequest collabRequest) {
        //Share
        String collabId = folderHandler.createCollaboration(folderId, collabRequest.email, collabRequest.collabType);
        PageReference res = folderHandler.getBoxFolderURL(collabRequest.recordId, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
    }
    
    /**
    * createWebhookForFolder - used to make a call to createFolderWebhook in BxdWebhookHandler to create webhook folder for the passed folder
	**/
    private static String createWebhookForFolder(String folderId) {
        List<String> triggers = new List<String>();
        triggers.add('FILE.UPLOADED');
        WebhookHandler webhookEvent = new WebhookHandler();
        BxdWebHook webhook = webhookEvent.createFolderWebhook(folderId, WEBHOOK_URL, triggers);
        return webhook.id;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
    
    private class WebhookHandler extends BxdWebhookHandler {
        private WebhookHandler() {
            super(true);
        }
    }
}