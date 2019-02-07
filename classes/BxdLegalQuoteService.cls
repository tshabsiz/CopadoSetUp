public class BxdLegalQuoteService {
    private static String EXTERNAL_FOLDER = '0';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxLegalQuoteFolder - used to create box folder for legalQuoteRequest record
	**/
    public static BxdLegalQuoteHelper createBoxLegalQuoteFolder(Legal_Quote_Request__c legalQuoteRequest, Legal_Quote__c quote, String parentFolderId, String attachmentFolderId, BxdLegalQuoteRequestService.WebhookHelper webhookHelper, String externalFolder, box.Toolkit boxToolkit){     
        BxdLegalQuoteHelper helper;
        if(quote != null){
            box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.VIEWERUPLOADER;                       
            Contact contact = [SELECT Email, AccountId FROM Contact WHERE Id=:quote.Contact__c LIMIT 1];
            Account account = [SELECT Name FROM Account WHERE Id =:quote.Law_Firm__c LIMIT 1];           
            
            if(account != null && contact != null && !String.isBlank(parentFolderId)){
                BxdCollaborationRequest collabRequest = BxdCollaborationRequest.getRequest();
                collabRequest.recordId = quote.Id;
                collabRequest.email = contact.Email;
                collabRequest.collabType = collabType;
                collabRequest.folderId = parentFolderId;
                collabRequest.folderName = account.Name + ' - ' + legalQuoteRequest.Quote_Title__c;
                //create response folder
                String folderId = createFolder(boxToolkit, collabRequest);
                //create response shared link
                String lawFirmLink = createSharedLinkQuoteResponse(boxToolkit, folderId, collabRequest);
                //create webhook              
                String webhhookId = createWebhookForFolder(folderId, webhookHelper);
                //create collaboration on attachments folder
                String quoteUrl = createSharedLinkForQuoteAttachment(legalQuoteRequest.Id, attachmentFolderId, legalQuoteRequest.Box_Quote_Request_Link__c, collabRequest, boxToolkit);
                //build helper
                helper = new BxdLegalQuoteHelper(String.isBlank(quoteUrl) ? '' : quoteUrl, String.isBlank(lawFirmLink) ? '' : lawFirmLink, String.isBlank(webhhookId) ? '' : webhhookId);
            } 
        }
        return helper;
    }
    
    /**
    * notifyLegalQuote - this method executes asynchronously, used to update legalQuote record linked to webhookNotification instance of the passed notificationId
	**/
    @Future(callout = true)
    public static void  notifyLegalQuote(Id notificationId){
        if(notificationId != null){
            BoxWebhookNotification__c notification = [SELECT Id, WebhookId__c FROM BoxWebhookNotification__c WHERE Id =:notificationId AND Notified__c = false LIMIT 1]; 
            //Select quote
            List<Legal_Quote__c> quotes = [SELECT Id, Box_Webhook__c, Quote_Recieved__c, Invoice_Received_WebhookId__c, InvoiceReceived__c FROM Legal_Quote__c WHERE (Box_Webhook__c =:notification.WebhookId__c AND Quote_Recieved__c = false) OR (Invoice_Received_WebhookId__c =:notification.WebhookId__c AND InvoiceReceived__c = false)];      
            
            if(quotes !=null && !quotes.isEmpty()){
                Legal_Quote__c quote = quotes[0];
                if(!String.isBlank(quote.Box_Webhook__c)){
                    quote.Quote_Recieved__c = true;
                }
                
                if(!String.isBlank(quote.Invoice_Received_WebhookId__c)){
                    quote.InvoiceReceived__c = true;
                }
                //set received
                update quote;            
                //set webhook notified
                notification.Notified__c = true;
            }
            
            update notification;
        }              
    }
    
    /**
    * createFolder - used to call createExternalBoxFolder in BxdFolderHandler to request creation of external box folder
    * https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getrecordidbyfolderid-
    * https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolderassociation-
	**/
    private static String createFolder(box.Toolkit boxToolkit, BxdCollaborationRequest collabRequest) {
        //create folder
        String coowner = UserInfo.getUserEmail();
        BxdExternalCollaborationHelper external = new BxdExternalCollaborationHelper(coowner, collabRequest.folderName, collabRequest.folderId, EXTERNAL_FOLDER, null, null);
        external = folderHandler.createExternalBoxFolder(external);
        String folderId = external.folderId;
        if(folderId == null){
            folderId = boxToolkit.getFolderIdByRecordId(collabRequest.recordId);
        } else{
            //link record folder to box
            boxToolkit.createFolderAssociation(collabRequest.recordId, folderId);
        }
        return folderId;
    }
    
    /**
    * createSharedLinkQuoteResponse - used to create collaboration on the legalQuote folder and request folder url
    * https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaboration-
    * https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getfolderurl-
	**/
    private static String createSharedLinkQuoteResponse(box.Toolkit boxToolkit, String folderId, BxdCollaborationRequest collabRequest) {
        // Share
        String collabId = boxToolkit.createCollaboration(folderId, null, collabRequest.email, collabRequest.collabType, null);
        PageReference res = boxToolkit.getFolderUrl(collabRequest.recordId, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
    }
    
    /**
    * createWebhookForFolder - used to call createFolderWebhook in BxdWebhookHandler passing received legalQuote folderId
	**/
    private static String createWebhookForFolder(String folderId, BxdLegalQuoteRequestService.WebhookHelper webhookHelper) {
        if(webhookHelper != null){
            //get webhook triggers
            List<String> triggers = webhookHelper.webhookTrigger == null ? new List<String>() : webhookHelper.webhookTrigger.split(';');
            
            System.debug('*******WEBHOOK TRIGGERS '+triggers);
            System.debug('*******WEBHOOK URL '+webhookHelper.webhookURL);
            //create webhook
            WebhookHandler webhookEvent = new WebhookHandler();
            BxdWebHook webhook = webhookEvent.createFolderWebhook(folderId, webhookHelper.webhookURL, triggers);
            return webhook.id;
        }
        
        return null;
    }
    
    /**
    * createSharedLinkForQuoteAttachment - used to create collaboration on the legalQuote folder, with collaborator as a viewer and request folder url 
	**/
    private static String createSharedLinkForQuoteAttachment(Id legalQuoteRequest, String quoteFolderId, String quoteRequestLink, BxdCollaborationRequest collabRequest, box.Toolkit boxToolkit) {
        box.Toolkit.CollaborationType collabT = box.Toolkit.CollaborationType.VIEWER;
        String collabId = boxToolkit.createCollaboration(quoteFolderId, null, collabRequest.email, collabT, null);
        PageReference res = boxToolkit.getFolderUrl(legalQuoteRequest, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
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