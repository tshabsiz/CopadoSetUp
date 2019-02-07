public abstract class BxdWebhookHandler {
    private static BxdIntegrationConnection boxConnection;
    private static BoxPlatformApiConnection api;
    public static final String WEBHOOKS_URL_TEMPLATE  = 'webhooks';
    public static final String WEBHOOK_URL_TEMPLATE  = 'webhooks/{0}';
    
    /**
    * BxdWebhookHandler  - construct the webhook handler and connect to the box api as the service account
	**/
    public BxdWebhookHandler(Boolean connect) {
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi();
        }
    }
    
    /**
    * BxdWebhookHandler - construct the webhook handler and connect to the box api as the user passed in 
	**/
    public BxdWebhookHandler(Boolean connect, String userId) {
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi(userId);
        }
    }
    
    /**
    * createFileWebhook - calls create below to create file Webhook 
	**/
    public BxdWebhook createFileWebhook(String fileId, String address, List<String> triggers) {  
        BxdWebhook webhook = new BxdWebhook();
        webhook.target.id = fileId;
        webhook.target.type = 'file';
        webhook.address = address;
        webhook.triggers = triggers;
        return create(BxdWebhook.getJsonString(webhook));
    }
    
    /**
    * createFolderWebhook - calls create below to create folder Webhook 
	**/
    public BxdWebhook createFolderWebhook(String folderId, String address, List<String> triggers) {   
        BxdWebhook webhook = new BxdWebhook();
        webhook.target.id = folderId;
        webhook.target.type = 'folder';
        webhook.address = address;
        webhook.triggers = triggers;
        return create(BxdWebhook.getJsonString(webhook));
    }
    
    /**
    * create - used to create a Webhook, parse the json object in the response
	**/
    public BxdWebhook create(String jsonObject) {
        String url = api.baseUrl + String.format(WEBHOOKS_URL_TEMPLATE, new String[] {});
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        request.setBody(jsonObject);
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        return BxdWebhook.parse(response.getJsonString());
    }
}