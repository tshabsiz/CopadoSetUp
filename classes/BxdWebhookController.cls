@RestResource(urlMapping='/webhook/*')
global class BxdWebhookController {
    private static final String PRIMARY_SIGNATURE = 'box-signature-primary';
    private static final String SECONDARY_SIGNATURE = 'box-signature-secondary';
    private static final String DELIVERY_TIMESTAMP = 'box-delivery-timestamp';
    private static final String SIGNATURE_ALGORITHM = 'box-signature-algorithm';
    private static final String SIGNATURE_VERSION = 'box-signature-version';
    
    /**
    * doPost - this method is used to consume and process a request received. Could be from a webhook
    **/
    @HttpPost 
    global static String doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        //read request Header
        Map<string, string> headers = req.headers;
        //read request Body
        String jsonBody = req.requestBody != null ? req.requestBody.toString() : '';
        system.debug('BODY '+jsonBody);
        
        //Verifying Signatures
        String primarySign = headers.get(PRIMARY_SIGNATURE);
        String secondarySign = headers.get(SECONDARY_SIGNATURE);
        String deliveryTimestamp = headers.get(DELIVERY_TIMESTAMP);
        String signatureAlgorithm = headers.get(SIGNATURE_ALGORITHM);
        String signatureVersion = headers.get(SIGNATURE_VERSION);
        system.debug('HEADERS '+headers);
        Boolean verified = verifyBoxSignature(signatureVersion, signatureAlgorithm, primarySign, secondarySign, jsonBody, deliveryTimestamp);
        
        if(!verified){
            res.statusCode = 403;
            return 'Permission Denied!';
        }
        
        return processPost(jsonBody, res);
    }
    
    /**
    * processPost - this method is a helper of the doPost to process the notification received from webhook
    **/
    private static String processPost(String jsonBody, RestResponse res)
    {   
        try
        {
            BxdWebhookJsonObject webhookJson = BxdWebhookJsonObject.parse(jsonBody);
            DateTime parsedDateTime = BoxDateFormat.parseBoxDateTimeString(webhookJson.created_at);
            
            system.debug('***webhookJson***'+webhookJson.Webhook.id);
            
            BoxWebhookNotification__c webhookObject = new BoxWebhookNotification__c ();
            webhookObject.Name = webhookJson.id;
            webhookObject.WebhookId__c = webhookJson.Webhook.id;
            webhookObject.WebhookDate__c = parsedDateTime;
            webhookObject.WebhookTrigger__c = webhookJson.trigger_Z;
            webhookObject.WebhookSourceId__c = webhookJson.Source.id;
            webhookObject.WebhookSourceType__c = webhookJson.Source.type_Z;
            webhookObject.WebhookSourceParentId__c = webhookJson.Source.Parent.id;
            
            insert webhookObject;
        }
        catch (Exception e)
        {
            res.statusCode = 500;
            return 'Error: '+ e + ' StackTrace: '+e.getStackTraceString();
        }
        
        res.statusCode = 200;
        return 'Success';
    }
    
    /**
    * verifyBoxSignature - used to call an external verify method found in BxdWebHookSignatureVerifier, to verify the signature
    **/
    public static Boolean verifyBoxSignature(String signatureVersion, String algorithm, String primarySignature, String secondarySignature, String webHookPayload, String deliveryTimestamp) {
        final BxdWebHookSignatureVerifier verifier = new BxdWebHookSignatureVerifier();        
        return verifier.verify(signatureVersion, algorithm, primarySignature,
            secondarySignature, webHookPayload, deliveryTimestamp);
    }
}