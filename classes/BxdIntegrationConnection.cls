/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Create the box api connection using the ABSA JWT app configurations on box
* @Date:        2017
*/
public class BxdIntegrationConnection {
    private static BxdIntegrationConnection instance = null;
    private static String ENTERPRISE_ID;
    private static String CLIENT_ID;
    private static String CLIENT_SECRET;        
    private static String PUBLIC_KEY_ID;
    private static String PRIVATE_KEY;
    private static String DEFAULT_USER_ID;    
    
    private BxdIntegrationConnection(){}
    
    /**
	* getInstance - get the instance of this class
	**/
    public static BxdIntegrationConnection getInstance(){
        if(instance == null) instance = new BxdIntegrationConnection();
        return instance;
    }
    
    /**
	* getBoxApi - get the Box API for the default service account
	**/
    public BoxPlatformApiConnection getBoxApi(){
        //Get Platform Settings
        setBoxPlatformSettings();
        
        //create JWT
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(PUBLIC_KEY_ID);
        preferences.setPrivateKey(PRIVATE_KEY);
        
        //check if we are running in test mode or not
        if(test.isRunningTest() == false){
            return BoxPlatformApiConnection.getAppUserConnection(DEFAULT_USER_ID, CLIENT_ID, CLIENT_SECRET, preferences);
        } else {
            return boxApiStub();
        }       
    }
    
    /**
	* getBoxApi - get the Box API based on the user id
	**/
    public BoxPlatformApiConnection getBoxApi(String userId){
        //Get Platform Settings
        setBoxPlatformSettings();
        if(String.isBlank(userId) || String.isEmpty(userId)){
            userId = DEFAULT_USER_ID;
        }   
        
        //create JWT
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(PUBLIC_KEY_ID);
        preferences.setPrivateKey(PRIVATE_KEY);
        
        //check if we are running in test mode or not
        if(test.isRunningTest() == false){
            return BoxPlatformApiConnection.getAppUserConnection(userId, CLIENT_ID, CLIENT_SECRET, preferences);
        } else {
            return boxApiStub(); 
        }
    }
    
    /**
	* sendBoxRequest - will send generic request to Box and the response will be parsed in the BoxGenericJsonObject
	**/
    public BoxGenericJsonObject sendBoxRequest(BoxAPIRequest request){
        try
        {
            //send request to box
            HttpResponse response = request.send();
            
            //return the json body response
            return new BoxGenericJsonObject(response.getBody());
        }
        catch (Exception e)
        {
            System.debug('EXCEPTION >> Line number: ' + e.getLineNumber() + ', Message: ' + e.getMessage());
        }
        
        return new BoxGenericJsonObject();
    }
    
    /**
	* sendBlobRequest - will send request to Box that will require Blob response
	**/
    public Blob sendBlobRequest(BoxAPIRequest request){
        try
        {
            //send request to box
            HttpResponse response = request.send();
            
            //return the blob response
            return response.getBodyAsBlob();
        }
        catch (Exception e)
        {
            System.debug('EXCEPTION >> Line number: ' + e.getLineNumber() + ', Message: ' + e.getMessage());
        }
        
        return null;
    }
    
    /**
	* setBoxPlatformSettings - Used to set Box JWT app settings based on Salesforce org environment
	**/
    private void setBoxPlatformSettings(){
        //Detemine which enviroment we are in for jwt selection.
        String salesforceEnviroment = CloudSmiths_Utils.getEnviroment();
        System.debug('***Box currently running in: ' + salesforceEnviroment);
        
        if(!String.isBlank(salesforceEnviroment) && salesforceEnviroment.containsIgnoreCase('DEV')){
            //Query Box Sandbox settings, used by all salesforce dev enviroment
            Box_Platform_Setting__mdt boxPlatform = [SELECT DeveloperName, Enterprise_Id__c, Client_Id__c, Client_Key__c, Public_Key_Id__c, Private_Key__c, Default_User_Id__c FROM Box_Platform_Setting__mdt WHERE DeveloperName = 'Box_Sandbox' LIMIT 1];
            
            if(boxPlatform != null){
                ENTERPRISE_ID = boxPlatform.Enterprise_Id__c;
                CLIENT_ID = boxPlatform.Client_Id__c;
                CLIENT_SECRET = boxPlatform.Client_Key__c;
                PUBLIC_KEY_ID = boxPlatform.Public_Key_Id__c;
                PRIVATE_KEY = boxPlatform.Private_Key__c;
                DEFAULT_USER_ID = boxPlatform.Default_User_Id__c;
            } 
        } else if(!String.isBlank(salesforceEnviroment) && (salesforceEnviroment.containsIgnoreCase('PROD') || salesforceEnviroment.containsIgnoreCase('UAT'))){
            //Query Box Production settings, used by Salesforce Production and UAT (Always make sure UAT has its own SalesforceUAT root folder)
            Box_Platform_Setting__mdt boxPlatform = [SELECT DeveloperName, Enterprise_Id__c, Client_Id__c, Client_Key__c, Public_Key_Id__c, Private_Key__c, Default_User_Id__c FROM Box_Platform_Setting__mdt WHERE DeveloperName = 'Box_Platform' LIMIT 1];
            
            if(boxPlatform != null){
                ENTERPRISE_ID = boxPlatform.Enterprise_Id__c;
                CLIENT_ID = boxPlatform.Client_Id__c;
                CLIENT_SECRET = boxPlatform.Client_Key__c;
                PUBLIC_KEY_ID = boxPlatform.Public_Key_Id__c;
                PRIVATE_KEY = boxPlatform.Private_Key__c;
                DEFAULT_USER_ID = boxPlatform.Default_User_Id__c;
            }  
        } else {
            throw new BoxAPIException('BxdIntegrationConnection : setBoxPlatformSettings : Unable to find integration settings.');
        }
        
    }
    
    /**
	* boxApiStub - Used to build test mock for BoxPlatformApiConnection, this will only be run in test mod
	**/
    private static BoxPlatformApiConnection boxApiStub(){
        system.debug('Run Test Box Api Connection');
        String clientId = 'clientid';
        String clientSecret = 'clientsecret';
        String entityId = 'entityid';
        String publicKeyId = 'publicKeyId';
        
        BoxPlatform.PlatformEntityType entityType = BoxPlatform.PlatformEntityType.USER;
        BoxJwtEncryptionPreferences encryptionPref = testConstructEncryptionPrefs();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        String responseR = '{"access_token":"mNr1FrCvOeWiGnwLL0OcTL0Lux5jbyBa","expires_in":4169,"restricted_to":[],"token_type":"bearer", "total_count":1,"entries":[{"type":"file","id":"198538570868"}], "shared_link":{"url":"https://app.box.com"}}';
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(responseR, 'OK', 200)));
        
        BoxPlatformApiConnection api = new BoxPlatformApiConnection(entityId, entityType, clientId, clientSecret, encryptionPref);
        return api; 
    }
    
    /**
	* testConstructEncryptionPrefs - Used to build test mock for BoxJwtEncryptionPreferences 
	**/
    private static BoxJwtEncryptionPreferences testConstructEncryptionPrefs() {
        BoxJwtEncryptionPreferences.EncryptionAlgorithm algorithm = BoxJwtEncryptionPreferences.EncryptionAlgorithm.RSA_SHA_256;
        String privateKey = BoxTestJsonResponseFactory.AUTH_PRIVATE_KEY;
        String privateKeyPassword = 'privateKeyPassword';
        String publicKeyId = 'publicKeyId';
        
        BoxJwtEncryptionPreferences prefs = new BoxJwtEncryptionPreferences();
        prefs.setEncryptionAlgorithm(algorithm);
        prefs.setPrivateKey(privateKey);
        prefs.setPrivateKeyPassword(privateKeyPassword);
        prefs.setPublicKeyId(publicKeyId);
        return prefs;
    }
                  
   public class BoxAPIException extends Exception {}
}