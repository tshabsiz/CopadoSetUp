public class AcmMitigantCRUDService {
    public static String POST_URL = '';
    public static String POST_METHOD ='POST';
    public static String BAAP ='SALESFORCE';
    public static String MITIGANT_TYPE = 'Mitigant';
    public static String CREATE_ACTION = 'Create';
    public static String CREATE_UPDATE_ACTION  = 'Create_or_update';
    public static String ACTIVE_ACTION  = 'Create_or_update';
    public static String UPDATE_ACTION  = 'Update';
    public static String DELETE_ACTION = 'Delete_if_found';
    public static String READ_ACTION = 'Read';
    public static String MESSAGE = '';
    public static Collateral__c CURRENTCOLLATERAL;
    public static String ALLOWED_PRODUCT_ACTION = CREATE_ACTION;
    
    // Facility settings
    public static String BASE_ENDPOINT = '';

    public static List<Collateral_Relationship__c> getAllRelationshipsForCollateral(Collateral__c collateral) {
        List<Collateral_Relationship__c> collateralRelationships = new List<Collateral_Relationship__c>();
        collateralRelationships =  [SELECT Relationship__r.SDS__c,relationship__r.CIF__c,Relationship__c,isPrimaryRelationship__c,Collateral_Type__c,Active__c, Relationship_Type__c FROM Collateral_Relationship__c where Collateral__c =: collateral.Id];    
        return collateralRelationships;
    }
    
    public static List<Collateral_Facility__c> getAllFacilitiesForCollateral(Collateral__c collateral) {
        return [SELECT Collateral__c,Acmfacility__r.Facility_Id__c, acmfacility__r.Bank_Application_key__c,Saved_To_Acm__c,Active__c, Facility_Client__c, AcmFacility__c FROM Collateral_Facility__c where Collateral__c = :collateral.id];
    }
    
    public static List<Acm_Collateral_Status__c> getAllCollateralAcmStatuses(Collateral__c collateral) {
         return [SELECT Id, Collateral_No__c, Name, Collateral_Id__c, Collateral_Message__c, Collateral_Owner__c,Status__c FROM Acm_Collateral_Status__c where Collateral_Id__c =:collateral.id];
    }
    
    public static HttpResponse getFacilityFromACM(string clientSDS) {
        Map<String, String> headers = createFacilityHeader();
        FacilityLookUp facilityLookUp = new FacilityLookUp();
        facilityLookUp.counterPartyId = clientSDS;
        String body = json.serialize(facilityLookUp);
        System.debug('Created body : ' + body);
        BASE_ENDPOINT = BASE_ENDPOINT + 'Facilities?_useDefaults=true';
        AcmHttpClient acmHttpClient = new AcmHttpClient(headers, BASE_ENDPOINT, POST_METHOD, body);
        HttpResponse response = acmHttpClient.sendRequest();
        return response;
    }
    
    public static Acm_Collateral_Status__c createOrUpdateAcmStatusList(Collateral__c collateral, List<Acm_Collateral_Status__c> AcmStatuses) {
        Acm_Collateral_Status__c acmCollateralStatus = getStatus(collateral.Id,AcmStatuses);
        
        if(acmCollateralStatus == NULL) {
            // Insert 
            Acm_Collateral_Status__c acmCollateral = new Acm_Collateral_Status__c();
            acmCollateral.Name = collateral.Name;
            acmCollateral.Collateral_No__c = collateral.Collateral_No__c;
            acmCollateral.Status__c = 'Not Sent to ACM';
            acmCollateral.Collateral_Owner__c = collateral.OwnerId;
            acmCollateral.Collateral_Id__c = String.valueOf(collateral.Id);
            acmCollateral.Email_Sent__c = false;
            acmCollateral.hasError__c = false;
            acmCollateral.OwnerId = collateral.OwnerId;
            acmCollateral.Collateral__c = collateral.Id;
            return acmCollateral;
        }
        return acmCollateralStatus;
    }
    
    public static List<Collateral_Relationship__c> getAllCRelationships(Collateral__c collateral, List<Collateral_Relationship__c> CRelationships) {
        List<Collateral_Relationship__c> CRs = new List<Collateral_Relationship__c>();
        for(Collateral_Relationship__c cr : CRelationships ) {
            if(cr.Collateral__c == collateral.Id) {
                CRs.add(cr);
            }
        }
        return CRs;
    }
    
    public static List<Collateral_Facility__c> getAllCFacilities(Collateral__c collateral, List<Collateral_Facility__c> CFacilities) {
        List<Collateral_Facility__c> CFs = new List<Collateral_Facility__c>();
        for(Collateral_Facility__c cf : CFacilities ) {
            if(cf.Collateral__c == collateral.Id) {
                CFs.add(cf);
            }
        }
        return CFs;
    }
    
    public static Acm_Collateral_Status__c getStatus(Id collateralId, List<Acm_Collateral_Status__c> AcmStatuses) {
        for(Acm_Collateral_Status__c st : AcmStatuses){
            if(Id.valueOf(st.Collateral_Id__c) == collateralId){
                return st;
            }
        }
        return null; 
    }
    
    public static void createOrUpdateMitigantsList(List<Acm_Collateral_Status__c> AcmStatuses, List<Collateral__c> collaterals, List<Collateral_Relationship__c> CRelationships,List<Collateral_Facility__c> CFacilities) {
        List<Acm_Collateral_Status__c> AcmStatusesUpdated = new List<Acm_Collateral_Status__c>();
        for(Collateral__c collateral : collaterals) {
            String body = createMitigantJsonBodyList(collateral,getAllCRelationships(collateral,CRelationships),getAllCFacilities(collateral, CFacilities),CREATE_UPDATE_ACTION, BAAP, MITIGANT_TYPE);
            Acm_Collateral_Status__c acmStatus = sendBodyToAcm(body, collateral, AcmStatuses, CRelationships, CFacilities);
            if(acmStatus != null) {
            	AcmStatusesUpdated.add(acmStatus);
            }
        }
        update AcmStatusesUpdated;
    }
    
    public static String createMitigantJsonBodyList(Collateral__c collateral,List<Collateral_Relationship__c> collateralRelationships,List<Collateral_Facility__c> collateralFacilities, String action, string baapId, String mitigantType) {
        return createBodyArray(collateral, collateralRelationships, collateralFacilities);
    }
    
    public static Acm_Collateral_Status__c sendBodyToAcm(String body, Collateral__c collateral, List<Acm_Collateral_Status__c> AcmStatuses, List<Collateral_Relationship__c> collateralRelationships,List<Collateral_Facility__c> collateralFacilities) {
        MESSAGE = '';   
        Map<String, String> headers = createHeader();
            Acm_Collateral_Status__c acmStatus = new Acm_Collateral_Status__c();
                if(headers.size() > 0) {
                    HttpResponse response  = createOrUpdateMitigantObject(headers, POST_URL, POST_METHOD, body);
                    if(response != null) {
                        System.debug(LoggingLevel.Info, 'RESPONSE BODY : ' +  response.getBody());
                        if(response.getStatusCode() == 200) {
                            String createdBody = json.serialize(createMitigantObject(collateral,collateralRelationships,collateralFacilities));
                            boolean isValid = verifyBody(response.getBody(), createdBody);
                            if(!isValid) {
                                MESSAGE = 'ACM Body verification failed : Please call you administrator';
                            } else {
                                MESSAGE = 'Mitigant successfully created/update';
                            }
                        }
                    } 
                    acmStatus = createOrUpdateAcmStatusList(collateral, AcmStatuses);
					return UpdateAcmStatus(collateral, AcmStatuses);
            } else {
                MESSAGE = 'Your acm integration settings are not set.';
            }
        return null;         
    }
    
    public static Acm_Collateral_Status__c UpdateAcmStatus(Collateral__c collateral, List<Acm_Collateral_Status__c> AcmStatuses) {
        Acm_Collateral_Status__c acmStatus = getStatus(collateral.Id, AcmStatuses);
        if(acmStatus != null) {
            acmStatus.Collateral_Message__c = MESSAGE;
            if(AcmMitigantCRUDService.MESSAGE.Contains('Mitigant successfully created/update')) {
                acmStatus.hasError__c = false;
                acmStatus.Status__c = 'Sent to ACM';
            } else {
                acmStatus.hasError__c = true;
            }
            acmStatus.Collateral_No__c = collateral.Collateral_No__c;
            acmStatus.Email_Sent__c = false;
            acmStatus.Name = collateral.Name;
            acmStatus.Collateral_Message__c = MESSAGE;
            return acmStatus;
        }
        return null;
    }
    
    public static void createOrUpdateMitigants(Id collateralId) {
        MESSAGE = '';
        Collateral__c collateral = getCollateralFromId(collateralId);
        if(collateral != null) {
            List<Collateral_Relationship__c> collateralRelationships = getAllRelationshipsForCollateral(collateral);
            List<Collateral_Facility__c> collateralFacilities = getAllFacilitiesForCollateral(collateral);
            List<Acm_Collateral_Status__c> acmStatuses = getAllCollateralAcmStatuses(collateral);
            String body = createMitigantJsonBodyList(collateral,collateralRelationships,collateralFacilities,CREATE_UPDATE_ACTION, BAAP, MITIGANT_TYPE);
            Acm_Collateral_Status__c acmStatus = sendBodyToAcm(body, collateral, acmStatuses, collateralRelationships, collateralFacilities);
            if(acmStatus != null){
                upsert acmStatus;
            }
        }
    }
    
    public static boolean verifyBody(String res, String mitigant) {
        String resBody = json.serialize(mitigant);
        List<String> fieldsToCompare = new List<String>{'"BAAPID"','"PRCD"',
            '"COTYGR"','"COTY"','"CMPU"','"CUCD"','"SCPIN"', '"CTSHNA"',
            '"RIENSHNA"', '"QROCD"'};
        Map<String, List<String>> mapResponseBody = createMapBody(res, fieldsToCompare);
        Map<String, List<String>> mapRequestBody = createMapBody(resBody, fieldsToCompare);
       
        
        // Compare fields        
        for(String key : fieldsToCompare) {
            if(mapRequestBody.get(key) != null && mapResponseBody.get(key) != null ){
                if(!equalLists(mapRequestBody.get(key), mapResponseBody.get(key) )){
                    System.debug('Body verification failed : Some fields where not set successfully : ' + key + ' : Request Body : ' + mapRequestBody.get(key) +'Response Body : '+ mapResponseBody.get(key));
                    return false;
                }
            } else {
                System.debug('Body verification failed : Field ' + key + 'was not SET');
                return false;
            }
        }
        System.debug('Body verification successful');
        return true;
    }
    
    public static boolean equalLists(List<String> requestFields, List<String> respondFields) {
        Set<String> respondFieldsSet = new Set<String>();
        for(String respondField : respondFields)
        {
            respondFieldsSet.add(respondField);
        }
        for(String reqField : requestFields) {
            if(!respondFieldsSet.contains(reqField)){
                return false;
            }
        }
        return true;
    }
    
    public static Map<String, List<String>> createMapBody(String responseBody, List<String> fieldsToCompare) {
        // Clean out body
        responseBody = responseBody.replace('"_type"', '"type"');
        responseBody = responseBody.replace('"_objects"', '');
        responseBody = responseBody.replace('"objects"', '');
        responseBody = responseBody.replace(': [ {', '');
        responseBody = responseBody.replace('}, {', ',');
        responseBody = responseBody.replace('\r\n', '');
        responseBody = responseBody.replace('\n', '');
        responseBody = responseBody.replace('\r', '');
        responseBody = responseBody.replace('{', '');
        responseBody = responseBody.replace('[ {', ',');
        responseBody = responseBody.replace('} ]  } ]}', '');
        responseBody = responseBody.replace('}', '');
        responseBody = responseBody.replace(']', '');
        responseBody = responseBody.replace(':[', '');
        
        // Create a map of lists
        String[] arrFields = responseBody.split(',');
        Map<String, List<String>> allFields = new Map<String, List<String>>();
        for(String str : fieldsToCompare){
            String strkey = str;
            Set<String> values = new Set<String>();
            for(String str2 : arrFields) {
                String strkey2 = (str2.split(':')[0]);
                if(strkey.trim() == strkey2.trim()) {
                    if(str2.split(':').size() > 1) {
                        if( !values.contains( (str2.split(':')[1]).trim() ) ){
                            values.add((str2.split(':')[1]).trim());
                        }
                    }
                }
            }
            allFields.put(strkey.trim(), new List<String>(values));
        }
        return allFields;
    }
    
    public static HttpResponse createOrUpdateMitigantObject(Map<String, String> headers, string url, string method, string body) {
        AcmHttpClient acmHttpClient = new AcmHttpClient(headers, url, method, body);
        HttpResponse response = null;
        
        try {
            response = acmHttpClient.sendRequest();
            if(response.getStatusCode() == 200) {
                MESSAGE = 'Mitigant successfully created/update';
                System.debug('Mitigant successfully created/update : ' + response.getStatus());
            } else {
                String statusBody = response.getStatus();
                if(response.getStatusCode() == 400) {
                    if(statusBody.Contains('(COTYGR / Mitigant Group) must not be changed')) {
                        MESSAGE = 'Unable to Update mitigant, the value of Collateral Type/Collateral Group Must Not Change, Please change it back and Try again';
                    } else if (statusBody.Contains('needs at least 1 Provider')) {
                        MESSAGE = 'Unable to Create/Update mitigant, You need atleast one Provider relationship';
                    } else if (statusBody.Contains('must not have any Beneficiary')) {
                        MESSAGE = 'Unable to Create/Update mitigant, Can not have Provider/Relationship of type Beneficiary';
                    } else if (statusBody.Contains('needs at least 1 Beneficiary')) {
                        MESSAGE = 'Unable to Create/Update mitigant, Collateral must have at least 1 Beneficiary';
                    } else if (statusBody.Contains('provided key fields for (CollateralType) are empty')) {
                        MESSAGE = 'Unable to Create/Update mitigant, Please specify correct collateral type';
                    } else if (statusBody.Contains('Association')) {
                        MESSAGE = 'Unable to Create/Update mitigant, Collateral type and collateral group association does not exist';
                    } else if(statusBody.Contains('Mitigant Provider): A value for field (RIENGEID / Entity Generated ID) must be given')) {
                        MESSAGE = 'Unable to Create/Update mitigant, The Specified Provider does not exist in ACM';
                    } else if(statusBody.Contains('BENEF): A value for field (RIENGEID / Entity Generated ID) must be given')) {
                        MESSAGE = 'Unable to Create/Update mitigant, The Specified Beneficiary does not exist in ACM';
                    } else if(statusBody.Contains('A value for field (COTYGR / Mitigant Group)')) {
                        MESSAGE = 'Unable to Create/Update mitigant, The specified Collateral Group Does not exist in ACM';
                    } else if(statusBody.Contains('for (COTY / Mitigant Type) of (Mitigant')) {
                        MESSAGE = 'Unable to Create/Update mitigant, The specified Collateral Type Does not exist in ACM';
                    } else if(statusBody.Contains('Mitigant.AllowedProduct') && statusBody.Contains('already exists')) {
                        MESSAGE = 'Facility/AllowedProduct already exists';
                    } else if(statusBody.Contains('The provided key fields for (Facility) are empty')) {
                        MESSAGE = 'Unable to Create/Update mitigant, The provided Facility does not exist in ACM';
                    } else if(statusBody.Contains('RiskEntity') && statusBody.Contains('BeneficiaryRole') && statusBody.Contains('does not exist')  ) {
                        MESSAGE = 'Unable to Create/Update mitigant, Provided Beneficiary Does not exist in ACM';
                    } else if(statusBody.Contains('RiskEntity') && statusBody.Contains('ProviderRole') && statusBody.Contains('does not exist')  ) {
                        MESSAGE = 'Unable to Create/Update mitigant, Provided Provider Does not exist in ACM';
                    } else if(statusBody.Contains('Mitigant') && statusBody.Contains('does not exist') && statusBody.Contains('does not exist')  ) {
                        MESSAGE = 'Unable to Create mitigant, Collateral Type does not exist or is deprecated';
                    } else {
                        MESSAGE = 'Unable to create/update mitigant : ' + statusBody ;
                        System.debug('Unable to create/update mitigant : ' + response);
                    }
                } else if (response.getStatusCode() == 500) {
                    if(response.getBody().contains('Status=SQL-033: Sql-statement')){
                        MESSAGE = 'Could not complete request please call administrator : Status ' + response.getStatusCode()    ;
                    } else {
                        MESSAGE = 'Acm Server could not respond. This collateral will be queued';
                    }
                } else if (response.getStatusCode() == 405) {
                    MESSAGE = 'Could not complete request : ' + response.getStatus();
                } else if(response.getStatusCode() == 401) {
                    MESSAGE = 'Could not complete request : ' + response.getStatus();
                } else if(response.getStatusCode() == 404) {
                     MESSAGE = 'Could not find requested url : ' + url;
                }
            }
        } catch (Exception e) {
            System.debug('Server response timed out, Please try again : ' + e);
            MESSAGE = 'Server response timed out, Please try again';
        }
        return response;
    }
    
    public static Map<String, String> createFacilityHeader() {
        Map<String, String> headers = new Map<String, String>();
        for(Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT','OPERATION_FACILITIESFEED','SYNC_TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret','OPERATION_LIMITS')]){
            if (settings.DeveloperName == 'BASE_ENDPOINT') BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Id') headers.put('X-IBM-Client-Id',settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Secret') headers.put('X-IBM-Client-Secret',settings.Setting__c);
        }
        headers.put('Content-Type', 'application/json');
        return headers;
    }
    
    public static Map<String, String> createHeader() {
        Map<String, String> headers = new Map<String, String>();
        
        // Populate impersonation details
        list<AcmIntegration__c> acmIntegrations = [Select Acm_Service_Account_UserName__c, Acm_Service_Account_Password__c, 
                                                   X_IBM_Client_Id__c, X_IBM_Client_Secret__c, IMPERSONATE__c,
                                                   POST_URL__c FROM AcmIntegration__c LIMIT 1];
        if(acmIntegrations.size() > 0){
            AcmIntegration__c acmIntegration =  acmIntegrations.get(0);
            // Get user name: TODO will have to decide whether to use this or the service account to impersonate
            String email = UserInfo.getUserName();
            if(acmIntegration.IMPERSONATE__c == true) {
                // Get session context and use SSD 
                headers.put('X-ACM-IMPERSONATE', 'Value here');
             }
            
            
            // Populate token details
            headers.put('X-IBM-Client-Secret', acmIntegration.X_IBM_Client_Secret__c == null ? ' ' : acmIntegration.X_IBM_Client_Secret__c  );
            headers.put('X-IBM-Client-Id', acmIntegration.X_IBM_Client_Id__c == null ? ' ' : acmIntegration.X_IBM_Client_Id__c );
            
            // Populate basic auth details
            Blob headerBlob = Blob.valueOf(acmIntegration.Acm_Service_Account_UserName__c + ':' + acmIntegration.Acm_Service_Account_Password__c);
            String authorization = 'Basic ' + EncodingUtil.base64Encode(headerBlob);
            headers.put('Authorization', authorization);
            
            // Populate the rest of the headers
            headers.put('Content-Type', 'application/json');
            
            // Set Post and get urls
            POST_URL = acmIntegration.POST_URL__c;
        }
        System.debug('Created headers : ' + headers);
        
        return headers;
    }
    
    public static Collateral__c getCollateralFromId(Id collateralId) {
        System.debug('record id : ' + collateralId);
        Collateral__c collateral = [SELECT Id, Collateral_Type1__r.deprecated__c,Collateral_Type1__r.Collateral_Purpose__c ,Acm_External_Id__c, Name, OwnerId, Collateral_Group__c,Collateral_Group__r.Credit_Code__c, Scope__c, Saved_To_Acm__c, Beneficiary__c, Account__c, CurrencyIsoCode, Collateral_Type1__c,Collateral_Type1__r.Credit_Code__c,Expiry_Date__c, Country__c, Signature_Date__c, Physical_Location__c,
                                    Status__c, Comments__c, Asset_Description__c, Value__c, Value_Type__c, Value_Limit__c, Asset__c,
                                    Asset_Type__c, Collateral_No__c, Document_Type__c, Document_Name__c, Document_Expiry_Date__c, Manager__c,
                                    Document_Description__c, Document_Status__c, Supporting_Documentation_Uploaded__c, 
                                    Has_Underlying_Assets__c FROM Collateral__c WHERE Id =: collateralId];
        
        CURRENTCOLLATERAL = collateral;
        return collateral;
    }
    
    public static String createBodyArray(Collateral__c collateral, List<Collateral_Relationship__c> collateralRelationships, 
                                  List<Collateral_Facility__c> collateralFacilities) {                      
        Mitigant mitigant = createMitigantObject(collateral,collateralRelationships, collateralFacilities);
        
        Mitigant deleteMitigant = new Mitigant();     
        deleteMitigant.type = MITIGANT_TYPE;
        deleteMitigant.action = DELETE_ACTION;
        deleteMitigant.BAAPID = BAAP;
        deleteMitigant.PRCD = String.valueOf(collateral.Collateral_No__c).toUpperCase();
        if(collateral.Acm_External_Id__c != null){
           deleteMitigant.PRCD = collateral.Acm_External_Id__c ;                               
        }
        
        Mitigant readMitigant = new Mitigant();     
        readMitigant.type = MITIGANT_TYPE;
        readMitigant.action = READ_ACTION;
        readMitigant.BAAPID = BAAP;
        readMitigant.PRCD = String.valueOf(collateral.Collateral_No__c).toUpperCase();
        if(collateral.Acm_External_Id__c != null){
           readMitigant.PRCD = collateral.Acm_External_Id__c ;                               
        }
        readMitigant.details = 'ProviderRole,BeneficiaryRole,AllowedProduct,MarketValuation';
        
        Mitigant[] mitigants = new Mitigant[]{deleteMitigant,mitigant,readMitigant};
            
        // Create mitigant wrapper
        MitigantWrapper mitigantWrapper = new MitigantWrapper();
        mitigantWrapper.objects = mitigants;
        
        // Serialize string
        String body = json.serialize(mitigantWrapper, true);
        body = renameFields(body);
        system.debug('Constructed Body : '+ body);
        return body;
    }
    
    public static Mitigant createMitigantObject(Collateral__c collateral, List<Collateral_Relationship__c> collateralRelationships, 
                                  List<Collateral_Facility__c> collateralFacilities) {
                                      
            Map<String,String> countryCodeMap =new Map<String,String>();
            // Get the object type of the SObject.
            Schema.sObjectType contactType = Contact.getSObjectType();
            // Describe the SObject using its object type.
            Schema.DescribeSObjectResult contactDescribe = contactType.getDescribe();
            // Get a map of fields for the SObject
            map<String, Schema.SObjectField> fieldMap = contactDescribe.fields.getMap();
            // Get the list of picklist values for this field.
            list<Schema.PicklistEntry> countryCodes = fieldMap.get('MailingCountryCode').getDescribe().getPickListValues();
            // Add these values to the selectoption list.
            for (Schema.PicklistEntry picklist : countryCodes) {
                countryCodeMap.put(picklist.getLabel(), picklist.getValue());
            }
                
            ObjectRelation[] providers = new ObjectRelation[]{};
            for(Collateral_Relationship__c collateralRelationship : CollateralRelationships) {
                    Provider provider = new Provider();
                    if(collateralRelationship.Active__c && collateralRelationship.Relationship_Type__c == 'Provider') {
                        String key = collateralRelationship.relationship__r.SDS__c;
                        if(collateralRelationship.relationship__r.SDS__c == null || collateralRelationship.relationship__r.SDS__c == '') {
                            key = collateralRelationship.relationship__r.CIF__c;
                            if(key.contains(';')) {
                                key = key.split(';')[0];
                            }
                        }
                        provider.type = 'ProviderRole';
                        provider.QROCD = 'Mitigant Provider';
                        provider.RIENSHNA = String.valueOf(key);
                        provider.REINALID = String.valueOf(key);
                        provider.action = CREATE_UPDATE_ACTION;
                        if( key!= null && key.isNumeric() == true) {
                            provider.ALTYNA = 'SDS';
                        } else {
                            provider.ALTYNA = 'CIF';       
                        }
                        if(collateralRelationship.isPrimaryRelationship__c) {
                            provider.ISROPTPC = '100';                            
                        } else {
                            provider.ISROPTPC = '0';
                        }
                        providers.add(provider);
                    } else if(collateralRelationship.Active__c && collateralRelationship.Relationship_Type__c == 'Beneficiary' && collateral.Scope__c == 'Beneficiary' ) {
                        String key = collateralRelationship.relationship__r.SDS__c;
                        if(collateralRelationship.relationship__r.SDS__c == null || collateralRelationship.relationship__r.SDS__c == '') {
                            key = collateralRelationship.relationship__r.CIF__c;
                            if(key.contains(';')) {
                                key = key.split(';')[0];
                            }
                        }
                        provider.type = 'BeneficiaryRole';
                        provider.QROCD = 'BENEF';
                        provider.RIENSHNA = String.valueOf(key);
                        provider.REINALID = String.valueOf(key);
                        provider.action = CREATE_UPDATE_ACTION;
                        if(key != null && key.isNumeric() == true) {
                            provider.ALTYNA = 'SDS';
                        } else {
                            provider.ALTYNA = 'CIF';       
                        }
                        
                        if(collateralRelationship.isPrimaryRelationship__c) {
                            provider.ISROPTPC = '100';                            
                        } else {
                            provider.ISROPTPC = '0';
                        }
                        providers.add(provider);
                } 
            }        
        System.debug('Getting collateral facility : ' + collateralFacilities);
        for(Collateral_Facility__c collateralFacility : collateralFacilities) {
            if(collateralFacility.Active__c && collateral.Scope__c == 'Facility' ) {
                    // Delete if found
                    AllowedProduct allowedProductDelete = new AllowedProduct();
                    allowedProductDelete.type = 'AllowedProduct';
                    allowedProductDelete.action = DELETE_ACTION;
                    allowedProductDelete.PRCDPR = collateralFacility.ACMFacility__r.Facility_Id__c;
                    allowedProductDelete.BAAPIDPR = collateralFacility.ACMFacility__r.Bank_Application_key__c;
                    providers.add(allowedProductDelete);
                    
                    // Recreate
                    AllowedProduct allowedProductCreate = new AllowedProduct();
                    allowedProductCreate.type = 'AllowedProduct';
                    allowedProductCreate.action = ALLOWED_PRODUCT_ACTION;
                    allowedProductCreate.PRCDPR = collateralFacility.ACMFacility__r.Facility_Id__c;
                    allowedProductCreate.BAAPIDPR = collateralFacility.ACMFacility__r.Bank_Application_key__c;
                    providers.add(allowedProductCreate);
            }
        }
                                      
        String PRCD = String.valueOf(collateral.Collateral_No__c).toUpperCase();
        if(collateral.Acm_External_Id__c != null) {
            PRCD = String.valueOf(collateral.Acm_External_Id__c).toUpperCase();
        } 
        
        // Create mitigant
        Mitigant mitigant = new Mitigant();
        mitigant.type = MITIGANT_TYPE;
        mitigant.action = CREATE_UPDATE_ACTION;
        mitigant.BAAPID = BAAP;
        mitigant.PRCD = PRCD ;
        mitigant.COTYGR = collateral.Collateral_Group__r.Credit_Code__c;
        mitigant.COTY = collateral.Collateral_Type1__r.Credit_Code__c;
        mitigant.PRDE = collateral.Comments__c; 
        //mitigant.PRMG = (collateral.Comments__c == null ? '' : (collateral.Comments__c + '\n') ) +  ' '+ collateral.Asset_Description__c == null?'':collateral.Asset_Description__c;
        mitigant.STDA = String.valueOf(collateral.Signature_Date__c);
        mitigant.EDDA = String.valueOf(collateral.Expiry_Date__c);
        mitigant.APCUCD = String.valueOf(collateral.CurrencyIsoCode);
        mitigant.APAM = String.valueOf(collateral.Value__c);
        mitigant.CUCD = collateral.CurrencyIsoCode;
        // Had to populate NVAM and NVCUCD this for PLUM report
        mitigant.NVAM =  String.valueOf(collateral.Value__c);
        mitigant.NVCUCD = collateral.CurrencyIsoCode;
                                      
        mitigant.CTSHNA = countryCodeMap.get(collateral.Country__c);
        mitigant.CTGEID = '';
        mitigant.ACTFL = 'Y';
        if(Date.today() > collateral.Expiry_Date__c) {
            mitigant.ACTFL = 'N';
        }
                                      
        // If we are releasing to ACM
        if(collateral.Status__c == 'Released') {
            mitigant.ACTFL = 'N';
            mitigant.RLDA = String.valueOf(Date.today());
        }
        
        if(collateral.Scope__c == 'Beneficiary') {
            mitigant.SCPIN = 'B'; 
        } else {
            mitigant.SCPIN = 'F';
        }
        // Create MarketValuation
        MarketValuation marketValuation = new MarketValuation();
        marketValuation.action = CREATE_ACTION;
        marketValuation.type = 'MarketValuation';
        marketValuation.MKVACUCD = String.valueOf(collateral.CurrencyIsoCode);
        marketValuation.MKVAAM = String.valueOf(collateral.Value__c);
        marketValuation.CTRLIN = 'Y';
        providers.add(marketValuation);
        
        // Add providers
        mitigant.objects = providers;                          
        return mitigant;
    }
    
    private static String renameFields(String body) {
        body = body.replace('"type"', '"_type"');
        body = body.replace('"action"', '"_action"');
        body = body.replace('"objects"', '"_objects"');
        body = body.replace('"details"', '"_details"');
        return body;
    }
    
    private class Mitigant {
        public String type { get; set; }
        public String action { get; set; }
        public String BAAPID { get; set; }
        public String PRCD { get; set; }
        public String COTYGR { get; set; }
        public String COTY { get; set; }
        public String PRDE { get; set; }
        public String CUCD { get; set; }
        public String PRMG { get; set; }
        public String STDA { get; set; }
        public String EDDA { get; set; }
        public String APCUCD { get; set; }
        public String APAM { get; set; }
        public String CTGEID { get; set; }
        public String ACTFL { get; set; }
        public String SCPIN { get; set; }
        public String RLDA { get; set; }
        public String CTSHNA { get; set; }
        public String details { get; set; }
        public String NVCUCD { get; set; }
        public String NVAM { get; set; }
        // Not required anymore, ACM will set it
        // public String CMPU { get; set; }
        public ObjectRelation[] objects { get; set; }
    }
    
    private class Provider extends ObjectRelation {
        public String RIENSHNA { get; set; }
        public String QROCD { get; set; } 
        public String ISROPTPC { get; set; }
        public String REINALID { get; set; }
        public String ALTYNA { get; set; }
    }
    
    private class AllowedProduct extends ObjectRelation {
        public String PRCDPR { get; set; }
        public String BAAPIDPR { get; set; }
    }
    
    private virtual class ObjectRelation {
        public String type { get; set; }
        public String action { get; set; }
    }
    
    private class MitigantWrapper {
        public Mitigant[] objects { get; set; }
    }
    
    private class MarketValuation extends ObjectRelation {
        public String SEQNO { get; set; }
        public String MKVACUCD { get; set; }
        public String MKVAAM { get; set; }
        public String CTRLIN { get; set; }
    }
    
    private class FacilityLookUp {
        public String counterpartyid { get; set; }
    }
}