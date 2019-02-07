public class BxdAgreementPermission extends BxdPermissionHandler {
    private static String PRIME_SERVICES_AGREEMENT = 'Prime Services Agreement';
    private static String GMRA_AGREEMENT = 'GMRA Agreement';
    private static String GMSLA_AGREEMENT = 'GMSLA Agreement';
    private static String ISDA_AGREEMENT = 'ISDA Agreement';
    private Agreement__c agreement { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdAgreementPermission constructor - used to initialize Agreement__c object
	**/
    public BxdAgreementPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdAgreementService';
        this.agreement = (Agreement__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Agreement__c to its view
	**/
    public PageReference actionViewRoute(){
        PageReference standardPage;
        if(ApexPages.currentPage().getParameters().get('redirect') == '0'){
            createBoxPermissions(agreement.Id);
            standardPage = new PageReference('/apex/AgreementBxdDocuments?Id=' + agreement.Id + '&boxService=' + boxServiceName);
            standardPage.setRedirect(true);
        } else {
            createFolder(agreement);
            standardPage = new PageReference('/apex/Agreement_BoxDocument_RelatedList?Id='+agreement.Id+'&redirect=0');
            standardPage.setRedirect(true);
        }
        
        //Redirect
        return standardPage;
    }

    /**
	* createFolder - used to make an external call to createFolderForRecord in BxdAgreementService, a box folder for record will be created
	**/
    public void createFolder(Agreement__c agreementRecord) {
        String folderId = super.getBoxFolderIdByRecordId(agreementRecord.Id);
        
        //create folder if empty
        if(String.isBlank(folderId) && agreementRecord.RecordTypeId != null){           
            //Select custom folder name for this record type
            String recordTypeName = Agreement__c.SObjectType.getDescribe().getRecordTypeInfosById().get(agreementRecord.RecordTypeId).getName();
            Map<String, String> recordTypes = buildRecordTypes();
            System.debug('TYPE: '+recordTypeName);
            System.debug('REQUIRED TYPES**: '+recordTypes);
            
            //set the folder name
            if(recordTypes !=null && recordTypes.containsKey(recordTypeName)){
                //initialise agreement service
                BxdAgreementService agreementService = new BxdAgreementService();
                
                //create the folder
                folderId = agreementService.createBoxFolderSync(agreementRecord.Id);
                System.debug('##DocumentTreeView - ' + boxServiceName + ' - Manual Created Folder ' + folderId);
            }
        }   
    }
    
	/**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Agreement__c
	**/    
    public void createBoxPermissions(Id agreementId){
        super.createPermissionForUser(agreementId);   
    }
    
    /**
	* buildRecordTypes - list the type of agreement we want to create box folder for. Other agreement types are created from triggers
	**/
    private static Map<String, String> buildRecordTypes(){
        Map<String, String> recordTypes = new Map<String, String>();
        recordTypes.put(PRIME_SERVICES_AGREEMENT, PRIME_SERVICES_AGREEMENT);
        recordTypes.put(GMRA_AGREEMENT, GMRA_AGREEMENT);
        recordTypes.put(GMSLA_AGREEMENT, GMSLA_AGREEMENT);
        recordTypes.put(ISDA_AGREEMENT, ISDA_AGREEMENT);     
        
        return recordTypes;
    }
}