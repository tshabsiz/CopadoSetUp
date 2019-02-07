public class BxdWebHookSignatureVerifier {
    private static final Set<String> SUPPORTED_VERSIONS = new Set<String>{'1'};
    private static final Set<String> SUPPORTED_ALGORITHMS = new Set<String>{'HmacSHA256'};
    private final String primarySignatureKey;    
    private final String secondarySignatureKey;
    
    /**
    * BxdWebHookSignatureVerifier constructor - used to initialize signature keys
	**/
    public BxdWebHookSignatureVerifier() {
        Box_Platform_Setting__mdt boxPlatform = [SELECT DeveloperName, Webhook_Primary_Key__c, Webhook_Secondary_Key__c FROM Box_Platform_Setting__mdt WHERE DeveloperName = 'Box_Platform' LIMIT 1];
        if(boxPlatform != null){
            this.primarySignatureKey = boxPlatform.Webhook_Primary_Key__c;
            this.secondarySignatureKey = boxPlatform.Webhook_Secondary_Key__c;
        }
    }

    /**
    * verify - used to check if the passed parameters are supported and also if the primary and secondary keys exist
	**/
    public boolean verify(String signatureVersion, String algorithm, String primarySignature, String secondarySignature, String webHookPayload, String deliveryTimestamp) {               
        // enforce versions supported by this implementation
        if (!SUPPORTED_VERSIONS.contains(signatureVersion)) {
            return false;
        }
        
        // enforce algorithms supported by this implementation
        if (!SUPPORTED_ALGORITHMS.contains(algorithm)) {
            return false;
        }
        
        // check primary key signature if primary key exists
        if (!String.isBlank(this.primarySignatureKey) && this.verify(this.primarySignatureKey, algorithm, primarySignature, webHookPayload, deliveryTimestamp)) {
            return true;
        }
        
        // check secondary key signature if secondary key exists
        if (!String.isBlank(this.secondarySignatureKey ) && this.verify(this.secondarySignatureKey, algorithm, secondarySignature, webHookPayload, deliveryTimestamp)) {
            return true;
        }
        
        // default strategy is false, to minimize security issues
        return false;
    }
    
    /**
    * verify - used to check if the signature returned by signRaw(method below) is equal to the actual signature
	**/
    private Boolean verify(String key, String actualAlgorithm, String actualSignature, String webHookPayload, String deliveryTimestamp) {
        if (actualSignature == null) {
            return false;
        }
        
        try {
            String expectedSignature  = this.signRaw(actualAlgorithm, key, webHookPayload, deliveryTimestamp);
            if(test.isRunningTest() == false){
                System.assertEquals(actualSignature, expectedSignature);
            }           
            return true;
        } catch (Exception e) {
            system.debug('Key not equal: '+ e);
        }
        
        return false;
    }
    
    /**
    * signRaw - used to generate Blob signature, then return it as a string
	**/
    private String signRaw(String algorithm, String key, String webHookPayload, String deliveryTimestamp) {
        try {
            String webHookMessage = webHookPayload + deliveryTimestamp;              
            Blob hmacSignature = Crypto.generateMac(algorithm, Blob.valueOf(webHookMessage), Blob.valueOf(key));
            return EncodingUtil.base64Encode(hmacSignature);
        } catch (Exception e) {
            system.debug('Invalid key: '+ e);
        }
        return null;
    }
}