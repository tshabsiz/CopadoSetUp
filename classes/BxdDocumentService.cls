/**
* @Author       Kapeshi.Kongolo@bsg.co.za, Mickey.Hariparsad@bsg.co.za
* @Company:     BSG
* @Description: Send BoxDocument Metadata or upload BoxDocument Files to Box
* @Date:        2017
*/
public class BxdDocumentService {
    private static FolderHandler folderHandler = new FolderHandler();
    private static MetadataHandler metaHandler = new MetadataHandler();
    private final static String BOX_FILE_URL = 'https://account.box.com/file/';
    private static final String COLLABORATOR_ACCESS = 'collaborators';
    private static final String DEAL_METADATA = 'Deal';
    private BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance();    
    
	
    /**
	* Upload when calling from trigger
	**/
    @Future(callout = true)
    public static void uploadHotDocsToBoxFuture(Id boxDocumentId, Blob fileBody, Id attachmentId, String boxUserEmail) {
    	uploadHotDocsToBoxAsUser(boxDocumentId, fileBody, boxUserEmail);
        delete [select Id FROM Attachment WHERE Id =: attachmentId];
    }
    
    /**
	* uploadHotDocsToBox - upload document to box, the documents are light weight enough to not break the memory
	**/ 
    
    public static Boolean uploadHotDocsToBox(Id boxDocumentId, Blob fileBody) {
    	return uploadHotDocsToBoxAsUser(boxDocumentId, fileBody, null);
    }
    
    
    public static Boolean uploadHotDocsToBoxAsUser(Id boxDocumentId, Blob fileBody, String boxUserEmail) {
        Boolean uploaded = false;
        String folderId;
        String fileId;
        String sharedLink;

        //Custom Settings
        //HotDocs_Integration_Settings__c settings = HotDocs_Integration_Settings__c.getInstance('Default');

        //This method assume upload for Agreements only, Call getDocumentParentRecord(sobjectName, boxDocumentId) if this becomes generic 
        BoxDocument__c doc = [SELECT Id, Name, Box_Unique_Id__c, Agreement__c, Type__c, Status__c, Owner_Type__c, PII__c FROM BoxDocument__c WHERE Id =: boxDocumentId];
        
        if(doc != null && doc.Agreement__c != null) {
            try{
                if(boxUserEmail != null) {
                    // Initialize folder handler with box user email
                	UserFolderHandler userFolderHandler = new UserFolderHandler(boxUserEmail);
                    
                    folderId = userFolderHandler.getBoxFolderIdByRecordIdForCustomUI(doc.Agreement__c);
                    fileId = userFolderHandler.uploadFileVersionToBox(fileBody, folderId, doc.Name);
                    
                } else {
                    folderId = folderHandler.getBoxFolderIdByRecordIdForCustomUI(doc.Agreement__c);
                    fileId = folderHandler.uploadFileVersionToBox(fileBody, folderId, doc.Name);
                }
                
                if(!String.isBlank(fileId)) {
                    //File has been uploaded to Box
                    uploaded = true;
                    
                    //Create shared link for Box Document UI, no longer required for now
                    //sharedLink = folderHandler.createBoxFileLink(fileId, COLLABORATOR_ACCESS, true , true);
                    
                    //Set details on Box Document
                    doc.Box_Unique_Id__c = fileId;
                    doc.Box_Location__c = BOX_FILE_URL + fileId;
                    doc.Upload_Date__c = DateTime.now();
                    
                    //Update Box document.
                    update doc;
                }
            } catch (Exception e){
                DebugLog.create( new DebugLog.Error(e, 'BxdDocumentService', 'uploadHotDocsToBox', 'Box Document ID:'+boxDocumentId) );
                System.debug('**Error while uploading to Box: ' + e);
            }            
        }

        //LOG
        /*if(settings.Enable_Verbose_Logging__c == true)
        {
            DebugLog.create( new DebugLog.Info('fileId:'+fileId, 'BxdDocumentService', 'uploadHotDocsToBox') );
            DebugLog.create( new DebugLog.Info('folderId:'+folderId, 'BxdDocumentService', 'uploadHotDocsToBox') );
            DebugLog.create( new DebugLog.Info('sharedLink:'+sharedLink, 'BxdDocumentService', 'uploadHotDocsToBox') );
        }*/

        return uploaded;
    }
    
    /**
	* addAdditionalBoxInfo - add Metadata on a file from the box document
	**/
    @future (callout=true)
    public static void addAdditionalBoxInfo(Id boxDocumentId) {
        if(boxDocumentId != null){
            //Find the BoxDocument__c object based on the parent lookup
            Schema.SObjectType sobjectType = boxDocumentId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            BoxDocument__c doc = getDocumentParentRecord(sobjectName, boxDocumentId);
            
            system.debug('****BOX DOCUMENT '+doc);
            if(doc.Box_Unique_Id__c != null){
                addMetadata(doc.Box_Unique_Id__c);
                addClassification(doc.Box_Unique_Id__c);
            }                          
        }
    }
    
    /**
	* addMetadata - add Metadata on a file from the box document
	**/
    private static void addMetadata(String resourceId) {
        //Query the metadata key - value pairs that were set on box.com
        System.debug('BxdDocumentService-addMetadata');
        BoxMetadata__c retrievedMetadata = [select BoxBaseMetadata__r.Metadata_Template__c,BoxBaseMetadata__r.Name,Deal_Document_Name__c,Deal_Document_Expiry_Date__c, Deal_Document_Type__c, Deal_Issuer_Name__c, Deal_Borrower_Name__c, Deal_Name__c, Deal_Agreement_Name__c, Deal_Beneficiary_Name__c, Deal_SDS__c, Deal_Collateral_Type__c, Deal_Provider_Name__c, Deal_Condition_Type__c, Deal_Status__c, Personal_Information__c from BoxMetadata__c where BoxBaseMetadata__r.Name=:DEAL_METADATA];

        //set metadata on the BxdMetadata json object if we have it
        if(!String.isBlank(resourceId) && retrievedMetadata != null){
            BxdMetadata metadata = new BxdMetadata();
            if(!String.isBlank(metaHandler.documentType)){
                metadata.add('/' + retrievedMetadata.Deal_Document_Type__c, metaHandler.documentType);
            }
            if(!String.isBlank(metaHandler.status)){
                metadata.add('/' + retrievedMetadata.Deal_Status__c, metaHandler.status);
            }
            if(!String.isBlank(metaHandler.documentName)){
                metadata.add('/' + retrievedMetadata.Deal_Document_Name__c, metaHandler.documentName);
            }
            if(!String.isBlank(metaHandler.expiryDate)){
                String documentExpiryDate = boxDateFormat(metaHandler.expiryDate);
                System.debug('BxdDocumentService - documentExpiryDate');
                System.debug(documentExpiryDate);
                metadata.add('/' + retrievedMetadata.Deal_Document_Expiry_Date__c, documentExpiryDate);
            }
            if (!String.isBlank(metaHandler.dealName))
            {
                System.debug('BxdDocumentService - dealName');
                System.debug(metaHandler.dealName);
                metadata.add('/' + retrievedMetadata.Deal_Name__c,  metaHandler.dealName);
            }
            if (!String.isBlank(metaHandler.agreementName))
            {
                System.debug('BxdDocumentService - metaHandler.agreementName)');
                System.debug(metaHandler.agreementName);
                metadata.add('/' + retrievedMetadata.Deal_Agreement_Name__c,  metaHandler.agreementName);
            }
            if (!String.isBlank(metaHandler.collateralType))
            {
                System.debug('BxdDocumentService -  metaHandler.collateralType)');
                System.debug( metaHandler.collateralType);
                metadata.add('/' + retrievedMetadata.Deal_Collateral_Type__c,  metaHandler.collateralType);
            }
            if (!String.isBlank(metaHandler.issuerName))
            {
                System.debug('BxdDocumentService -  metaHandler.issuerName)');
                System.debug( metaHandler.issuerName);
                metadata.add('/' + retrievedMetadata.Deal_Issuer_Name__c,  metaHandler.issuerName);
            }
            if (!String.isBlank(metaHandler.providerName))
            {
                System.debug('BxdDocumentService -  metaHandler.providerName)');
                System.debug( metaHandler.providerName);
                metadata.add('/' + retrievedMetadata.Deal_Provider_Name__c,  metaHandler.providerName);
            }
            if (!String.isBlank(metaHandler.beneficiaryName))
            {
                System.debug('BxdDocumentService -  metaHandler.beneficiaryName)');
                System.debug( metaHandler.beneficiaryName);
                metadata.add('/' + retrievedMetadata.Deal_Beneficiary_Name__c,  metaHandler.beneficiaryName);
            }
            if (!String.isBlank(metaHandler.borrowerName))
            {
                System.debug('BxdDocumentService -  metaHandler.borrowerName)');
                System.debug( metaHandler.borrowerName);
                metadata.add('/' + retrievedMetadata.Deal_Borrower_Name__c,  metaHandler.borrowerName);
            }
            if (!String.isBlank(metaHandler.SDS))
            {
                System.debug('BxdDocumentService -  metaHandler.SDS)');
                System.debug( metaHandler.SDS);
                metadata.add('/' + retrievedMetadata.Deal_SDS__c,  metaHandler.SDS);
            }
            
            if (!String.isBlank(metaHandler.personalInformation))
            {
                System.debug('BxdDocumentService -  metaHandler.personalInformation)');
                System.debug( metaHandler.personalInformation);
                metadata.add('/' + retrievedMetadata.Personal_Information__c,  metaHandler.personalInformation);
            }
            if (!String.isBlank(metaHandler.conditionType))
            {
                System.debug('BxdDocumentService -  metaHandler.conditionType');
                System.debug( metaHandler.conditionType);
                metadata.add('/' + retrievedMetadata.Deal_Condition_Type__c,  metaHandler.conditionType);
            }
            
            //send metadata to Box
            metadata = metaHandler.createFileMetadata(resourceId, retrievedMetadata.BoxBaseMetadata__r.Metadata_Template__c, metadata);
        }    
    }
    
    /**
	* addClassification - add Metadata of type Classification on a file from the box document
	**/
    private static void addClassification(String resourceId) {
        //Query the metadata of type classification key - value pairs that were set on box.com
        System.debug('BxdDocumentService-addClassification');
    	BoxMetadata__c template = [select Classification_Confidential_Key__c, BoxBaseMetadata__r.Classification_Template__c from BoxMetadata__c where BoxBaseMetadata__r.Name=:DEAL_METADATA];
        
        //set metadata if we have it 
        if(!String.isBlank(resourceId) && template != null){
            BxdMetadata metadata = new BxdMetadata();        
            metadata.add('/' + template.Classification_Confidential_Key__c,  'Confidential');      
            
            //send metadata to Box
            metadata = metaHandler.createFileMetadata(resourceId, template.BoxBaseMetadata__r.Classification_Template__c, metadata);
        }
        
    }
    
    /**
	* boxDateFormat - build box date format
	**/
    private static String boxDateFormat(String bxdDate) {
        System.debug('boxDateFormat');
        
        //format sequentially
        Datetime bxdServiceDate = Datetime.valueOf(bxdDate);
        String SbxdServiceDate = bxdServiceDate.format('yyyy-MM-dd'); 
        String SbxdServiceTime = bxdServiceDate.format('HH:mm:ssZ');
        String SbxdServiceDateTime = SbxdServiceDate+'T'+SbxdServiceTime;
        System.debug(SbxdServiceDateTime);
        
        return SbxdServiceDateTime;
    }
    
    /**
	* getDocumentParentRecord - get the BoxDocument__c object based on the id and the parent object name
	**/
    private static BoxDocument__c getDocumentParentRecord(String sobjectName, String boxId) {
        System.debug('BxdDocumentService-getDocumentParentRecord');
        BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance();

        //Query all fields as it will only return the ones with values
        SObject record = Database.query('Select Id, PII__c, Expiry_Date__c, Name, Box_Unique_Id__c, Box_Location__c, Account__c, Matter__c, Agreement__c, Collateral__c, Condition_Occurrence__c, Condition__c, Drawdown__c, Facility__c, Facility_Tranche__c, SPV_Item__c, Agency_Transfer__c, Collateral_Valuation__c, Collateral_Monitoring__c, Watcher__c, Trigger__c, Margin_Ratchet__c, Type__c, Status__c, Owner_Type__c From ' + sobjectName + ' Where Id = :boxId');

        //populates the metaHandler with the required metaHandler
        getParentMetaData(record);
        
        //Loop through to get the parent Id as it won't be blank
        List<String> fields = viewHelper.getBoxDocumentFieldNames(); //getting the fields for BoxDocument
        for(String field : fields){           
            String Id = folderHandler.getRecordValue(record, field);
            if(!String.isBlank(Id)){
                metaHandler.parentRecordId = Id;
                metaHandler.documentType = folderHandler.getRecordValue(record, 'Type__c');
                System.debug('BxdDocumentService-getDocumentParentRecord --- documentType for MetaData ' + metaHandler.documentType);
                metaHandler.status = folderHandler.getRecordValue(record, 'Status__c');
                System.debug('BxdDocumentService-getDocumentParentRecord --- Status__c for MetaData ' + metaHandler.status);
                metaHandler.documentName = folderHandler.getRecordValue(record, 'Name');
                System.debug('BxdDocumentService-getDocumentParentRecord --- Name for MetaData ' + metaHandler.documentName);
                metaHandler.expiryDate = folderHandler.getRecordValue(record, 'Expiry_Date__c');
                System.debug('BxdDocumentService-getDocumentParentRecord --- Name for Expiry_Date__c ' + metaHandler.expiryDate);
                metaHandler.personalInformation = folderHandler.getRecordValue(record, 'PII__c');
                System.debug('BxdDocumentService-getDocumentParentRecord --- Name for PII__c ' + metaHandler.personalInformation);
                
                return (BoxDocument__c) record;
            }
        }
        return null;
    }
    
    /**
	* getParentMetaData - get the parent object metadata by way of rolling up
	**/
    private static void getParentMetaData (Sobject record) {
        //Get the parent record through the type and the relevant field.
        //Fetch the data through retrieving from the parent record. 
        System.debug('getParentMetaData');
        String bxdType = String.valueOf(record.get('Owner_Type__c')); 
        system.debug('Owner Type: '+bxdType);
        
        BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance();  
        system.debug('Fetching Related MetaData');
        if (bxdType == 'Collateral__c')
        {
            system.debug('Collateral__c');
            getCollateralMetaData(record);
        }
        else if (bxdType == 'Account__c')
        {
            system.debug('Account__c');
            system.debug('Not Setting any metaData');
        }
        else if (bxdType == 'Agreement__c')
        {
            system.debug('Agreement__c');
            getAgreementMetaData(record);
        }
        else if (bxdType == 'Condition__c')
        {
            system.debug('Condition__c');
            getConditionMetaData(record);
            
        }
        else if (bxdType == 'Condition_Occurrence__c')
        {
            system.debug('Condition_Occurrence__c');
            getConditionOccurenceMetaData(record);
        } 
        
        else if (bxdType == 'advpm__Matter__c')
        {
            system.debug('advpm__Matter__c'); 
            getDealMetaData(record);
        }
        else if (bxdType == 'DrawDown__c')
        {
            system.debug('DrawDown__c'); 
            getDrawDownMetaData(record);
        }
        else
        {
            system.debug('Unknown BxD Owner');
        }
        
    }
    
    /**
	* getDrawDownMetaData - get metadata related to the drawdown
	**/
    private static void getDrawDownMetaData (Sobject record) {
        //Populates metaHandler with Agreement Name, Deal Name, Borrower and Borrower SDS
        system.debug('getDrawDownMetaData');
        
        //Build the query
        String query = 'Select Deal__c, Agreement__r.Name, Borrower__r.Deal_Party__r.Relationship__r.Name, Borrower__r.Deal_Party__r.Relationship__r.SDS__c from DrawDown__c';
        query += ' WHERE Id = ' +'\''+ String.valueOf(record.get('DrawDown__c')) +'\'';
        Drawdown__c drawdown = Database.query(query);
        
        //Set the metadata
        Agreement__c agreement = drawdown.Agreement__r;
        Agreement_Party__c agreementParty = drawdown.Borrower__r;
        Deal_Party__c dealParty = agreementParty.Deal_Party__r;
        Account acc = dealParty.Relationship__r;
        metaHandler.dealName = drawdown.Deal__c;
        metaHandler.agreementName = agreement.Name;
        metaHandler.borrowerName = acc.Name;
        metaHandler.SDS = acc.SDS__c;    
    }
    
    /**
	* getConditionOccurenceMetaData - get metadata related to the Condition Occurence
	**/
    private static void getConditionOccurenceMetaData (SObject record) {
        //Populates metaHandler with Agreement Name, Deal Name, Borrower(multi) and SDS
        system.debug('getConditionOccurenceMetaData');
        List<Condition__c> conditionList = null;
        String conditionOccurenceId = String.valueOf(record.get('Condition_Occurrence__c'));
        
        //query the condition occurence
        Condition_Occurrence__c conditionOccurence = [Select Id, recordTypeId, Name, Condition__c from Condition_Occurrence__c where Id=:conditionOccurenceId];
        
        //Build the query
        String query = null;        
        query = 'Select Name, recordTypeId, Type__c, Agreement__r.Matter_Deal__r.Name, Agreement__r.Name, Matter__r.Name, (Select Party_Type__c, Agreement_Party__r.Deal_Party__r.Relationship__r.Name,  Agreement_Party__r.Deal_Party__r.Relationship__r.SDS__c from Condition_Parties__r) from Condition__c';
        query += ' where Id = '; 
        query += '\''+ String.valueOf(conditionOccurence.Condition__c) +'\'';
        system.debug('getConditionOccurenceMetaData Query');
        system.debug(query);
        conditionList =  Database.query(query);

        //init variables
        String sSDS = '';
        String DealName;
        String AgreementName;
        String sborrowerListName = ''; //In use is sBorrowerListName
        List<String> SDS = new List<String>();
        List<String> borrowerListName = new List<String>();
        Agreement__c agreement;
        advpm__Matter__c deal;
        
        String ConditionType = Condition_Occurrence__c.sObjectType.getDescribe().getRecordTypeInfosById().get(conditionOccurence.recordTypeId).getName(); 
        
        //loop through all condition list and set rolled-up metadata
        for (Condition__c conditionItem:conditionList)
        {
            if (conditionItem.Agreement__r !=null) 
            {
                agreement = conditionItem.Agreement__r;
                AgreementName = agreement.Name;
                if (agreement.Matter_Deal__r !=null)
                {
                    deal = agreement.Matter_Deal__r;
                }
                DealName = deal.Name;
            }
            if (conditionItem.Condition_Parties__r !=null)
            {
                List<Condition_Party__c> conditionParties = conditionItem.Condition_Parties__r;
                
                for (Condition_Party__c conditionParty:conditionParties)
                {
                    system.debug('getConditionOccurenceMetaData conditionParty');
                    if (conditionParty.Party_Type__c == 'Borrower')
                    {
                        system.debug('getConditionOccurenceMetaData Borrower'); 
                        if (conditionParty.Agreement_Party__r !=null)
                        {
                            system.debug('getConditionOccurenceMetaData Agreement Party');
                            Agreement_Party__c agreementParty = conditionParty.Agreement_Party__r;
                            if (agreementParty.Deal_Party__r !=null)
                            {
                                system.debug('getConditionOccurenceMetaData Deal Party');
                                Deal_Party__c dealParty =  agreementParty.Deal_Party__r;  
                                Account acc = dealParty.Relationship__r;
                                borrowerListName.add(acc.Name);
                                system.debug('getConditionOccurenceMetaData Acc Name and SDS');
                                system.debug(acc.Name);
                                system.debug(acc.SDS__c);
                                if (acc.SDS__c !=null)
                                {
                                    SDS.add(acc.SDS__c);    
                                }
                            }
                            else
                            {
                                system.debug('This is not a BOX catered for Party Type');
                            }
                        }  
                    }
                    
                }   
            }
        }
        if (borrowerListName !=null)
        {
            sBorrowerListName = BoxDocumentViewHelper.packListCSV(borrowerListName);
        }
        if (SDS !=null)
        {
            sSDS = BoxDocumentViewHelper.packListCSV(SDS);
        }

        //set metadata on handler
        system.debug('getConditionOccurenceMetaData DealName '+DealName);
        metaHandler.dealName = DealName;
        system.debug('getConditionOccurenceMetaData AgreementName '+AgreementName);
        metaHandler.agreementName = AgreementName;
        system.debug('getConditionOccurenceMetaData sBorrowerListName '+sBorrowerListName);
        metaHandler.borrowerName =  sBorrowerListName;
        system.debug('getConditionOccurenceMetaData sSDS '+sSDS);
        metaHandler.SDS = sSDS;
        system.debug('getConditionOccurenceMetaData conditionType '+ConditionType);
        metaHandler.conditionType = ConditionType;
    }
    
    /**
	* getConditionMetaData - get metadata related to the Condition
	**/
    private static void getConditionMetaData (SObject record) {
        //Populates metaHandler with Agreement Name, Deal Name, Borrower(multi) and SDS
        system.debug('getConditionMetaData');
        List<Condition__c> conditionList = null;
        
        //build query
        String query = null;
        query = 'Select Name, recordTypeId, Agreement__r.Matter_Deal__r.Name, Agreement__r.Name, Matter__r.Name, (Select Party_Type__c, Agreement_Party__r.Deal_Party__r.Relationship__r.Name,  Agreement_Party__r.Deal_Party__r.Relationship__r.SDS__c from Condition_Parties__r) from Condition__c';
        query += ' WHERE Id = ' +'\''+ String.valueOf(record.get('Condition__c')) +'\'';
        system.debug('getConditionMetaData Query');
        system.debug(query);
        conditionList =  Database.query(query);
        
        //init variables
        String sSDS = '';
        String DealName;
        String AgreementName;
        String ConditionType;
        String sborrowerListName = ''; //In use is sBorrowerListName
        List<String> borrowerListName = new List<String>();
        List<String> SDS = new List<String>();
        Agreement__c agreement;
        advpm__Matter__c deal;
        
        //loop through and set rolled-up metadata
        for (Condition__c conditionItem:conditionList)
        {
            ConditionType = Condition__c.sObjectType.getDescribe().getRecordTypeInfosById().get(conditionItem.recordTypeId).getName(); 
            if (conditionItem.Agreement__r !=null) 
            {
                agreement = conditionItem.Agreement__r;
                AgreementName = agreement.Name;
                if (agreement.Matter_Deal__r !=null)
                {
                    deal = agreement.Matter_Deal__r;
                }
                DealName = deal.Name;
            }
            if (conditionItem.Condition_Parties__r !=null)
            {
                List<Condition_Party__c> conditionParties = conditionItem.Condition_Parties__r;
                
                for (Condition_Party__c conditionParty:conditionParties)
                {
                    system.debug('getConditionMetaData conditionParty');
                    if (conditionParty.Party_Type__c == 'Borrower')
                    {
                        system.debug('getConditionMetaData Borrower'); 
                        if (conditionParty.Agreement_Party__r !=null)
                        {
                            system.debug('getConditionMetaData Agreement Party');
                            Agreement_Party__c agreementParty = conditionParty.Agreement_Party__r;
                            if (agreementParty.Deal_Party__r !=null)
                            {
                                system.debug('getConditionMetaData Deal Party');
                                Deal_Party__c dealParty =  agreementParty.Deal_Party__r;  
                                Account acc = dealParty.Relationship__r;
                                borrowerListName.add(acc.Name);
                                system.debug('getConditionMetaData Acc Name and SDS');
                                system.debug(acc.Name);
                                system.debug(acc.SDS__c);
                                if (acc.SDS__c !=null)
                                {
                                    SDS.add(acc.SDS__c);    
                                }
                            }
                            else
                            {
                                system.debug('getConditionMetaData - This is not a BOX catered for Party Type');
                            }
                        }  
                    }
                    
                }   
            }
        }
        if (borrowerListName !=null)
        {
            sBorrowerListName = BoxDocumentViewHelper.packListCSV(borrowerListName);
        }
        if (SDS !=null)
        {
            sSDS = BoxDocumentViewHelper.packListCSV(SDS);
        }

        //set metadata on handler
        system.debug('getConditionMetaData DealName '+DealName);
        metaHandler.dealName = DealName;
        system.debug('getConditionMetaData AgreementName '+AgreementName);
        metaHandler.agreementName = AgreementName;
        system.debug('getConditionMetaData sBorrowerListName '+sBorrowerListName);
        metaHandler.borrowerName =  sBorrowerListName;
        system.debug('getConditionMetaData sSDS '+sSDS);
        metaHandler.SDS = sSDS;
        system.debug('getConditionMetaData conditionType '+ConditionType);
        metaHandler.conditionType = ConditionType;   
    }
    
    /**
	* getCollateralMetaData - get metadata related to the Collateral
	**/
    private static void getCollateralMetaData (Sobject record) {   
        //Populating the metadaHandler with Borrower,Benefiticiary, Issuer, Provider, A single SDS and Collateral Type
        system.debug('getCollateralMetaData');
        
        //build query
        List<Collateral__c> collateralList = null;
        String query = null;
        query = 'Select Name,(Select Relationship_Type__c, Relationship__r.Name, Relationship__r.SDS__c from Collateral_Relationships__r) from Collateral__c'; //using subeqry for child relationships
        query += ' WHERE Id = ' +'\''+ String.valueOf(record.get('Collateral__c')) +'\'';
        system.debug(query);
        collateralList =  Database.query(query);
        
        //init variables
        String sSDS = '';
        String sBorrowerListName = '';
        String sProviderListName = '';
        String sIssuerListName = '';
        String sBeneficiaryListName = ''; //In use is sbeneficiaryListName
        List<String> SDS = new List<String>();
        List<String> borrowerListName = new List<String>();
        List<String> providerListName = new List<String>();
        List<String> issuerListName = new List<String>();
        List<String> beneficiaryListName = new List<String>();
        
        String Collateral_Type = '';
        
        //flattening all relationships, we can only do this if the list exists
        system.debug('Flattening Relationships'); 
        for (Collateral__c collateralItem:collateralList)
        {
            system.debug(collateralItem);
            Collateral_Type = '';//collateralItem.Collateral_Type__c;
            //TODO: Do a validation that relationships exist
            List<Collateral_Relationship__c> collatRels = collateralItem.Collateral_Relationships__r; //Taken from config for field and add __r
            system.debug(collatRels);
            
            //Loop throou collateral relationship get metadata
            for (Collateral_Relationship__c collatRel:collatRels)
            {             
                system.debug(collatRel);
                if (collatRel.Relationship__c != null)
                {
                    Account acc = collatRel.Relationship__r; //Since this is the parent lookup field replacing the __c with __r
                    system.debug('Account Types '+collatRel.Relationship_Type__c);
                    system.debug('Account Name '+acc.Name);
                    system.debug('Account SDS '+acc.SDS__c);
                                
                    if (collatRel.Relationship_Type__c == 'Borrower')
                    {
                        borrowerListName.add(acc.Name);
                        SDS.add(acc.SDS__c);
                    }
                    else if (collatRel.Relationship_Type__c == 'Provider')
                    {
                        providerListName.add(acc.Name);
                        SDS.add(acc.SDS__c);
                    }
                    else if (collatRel.Relationship_Type__c == 'Issuer')
                    {
                        issuerListName.add(acc.Name);
                        SDS.add(acc.SDS__c);
                    }
                    else if (collatRel.Relationship_Type__c == 'Beneficiary')
                    {
                        beneficiaryListName.add(acc.Name);
                        SDS.add(acc.SDS__c);
                    }
                    else
                    {
                        system.debug('Unknown Account Relationship Type');
                    }   
                }
            }
            
            if (borrowerListName != null)
            {
                sBorrowerListName = BoxDocumentViewHelper.packListCSV(borrowerListName);
            }
            if (providerListName != null)
            {
                sProviderListName = BoxDocumentViewHelper.packListCSV(providerListName);
            }
            if (issuerListName != null)
            {
                sIssuerListName = BoxDocumentViewHelper.packListCSV(issuerListName);
            }
            if (beneficiaryListName != null)
            {
                sbeneficiaryListName = BoxDocumentViewHelper.packListCSV(beneficiaryListName);
            }
            if (SDS != null)
            {
                sSDS = BoxDocumentViewHelper.packListCSV(SDS);
            }
            system.debug('getCollateralMetaData Information');
            system.debug(borrowerListName);
            system.debug(sBorrowerListName);
            system.debug(providerListName);
            system.debug(sProviderListName);  
            system.debug(issuerListName);
            system.debug(sIssuerListName);
            system.debug(beneficiaryListName);
            system.debug(sbeneficiaryListName);
            system.debug(SDS);
            system.debug(sSDS);            
            metaHandler.issuerName = sIssuerListName;
            metaHandler.beneficiaryName = sbeneficiaryListName;
            metaHandler.borrowerName = sBorrowerListName;
            metaHandler.providerName = sProviderListName;
            metaHandler.SDS = sSDS;
            metaHandler.collateralType = Collateral_Type; 
        }
    }
    
    /**
	* getAgreementMetaData - get metadata related to the Agreement
	**/
    private static void getAgreementMetaData (Sobject record) {
        //Populates metaHandler with Agreement Name, Deal Name and Borrower(multi)
        system.debug('getAgreementMetaData');
        List<Agreement__c> agreementList = null;
        
        //build query
        String query = null;
        query = 'Select Name, Matter_Deal__c, Matter_Deal__r.Name, (Select Party_Type__c, Deal_Party__r.Relationship__r.Name, Deal_Party__r.Relationship__r.SDS__c from Agreement_Parties__r) from Agreement__c';
        query += ' WHERE Id = ' +'\''+ String.valueOf(record.get('Agreement__c')) +'\'';
        system.debug('getAgreementMetaData Query');
        system.debug(query);
        agreementList =  Database.query(query);
        
        //init variables
        String sSDS = '';
        String DealName;
        String agreementName;
        String sborrowerListName = ''; //In use is sBorrowerListName
        List<String> borrowerListName = new List<String>();
        List<String> SDS = new List<String>();
        
        //loop through agreement list to fetch metadata
        for (Agreement__c agreementItem:agreementList)
        {
            agreementName = agreementItem.Name;
            if (agreementItem.Matter_Deal__c !=null) 
            {
                advpm__Matter__c matter = agreementItem.Matter_Deal__r;
                dealName = matter.Name;
            }
            if (agreementItem.Agreement_Parties__r !=null)
            {
                List<Agreement_Party__c> agreementParties = agreementItem.Agreement_Parties__r;
                system.debug('getAgreementMetaData agreementParties');
                system.debug(agreementParties);
                for (Agreement_Party__c agreementParty:agreementParties)
                {
                    system.debug('getAgreementMetaData agreementParty');
                    if (agreementParty.Party_Type__c == 'Borrower')
                    {
                        system.debug('getAgreementMetaData Borrower'); 
                        //borrowerListName.add(agreementParties.Deal_Party__r.Relationship__r.Name);
                        if( agreementParty.Deal_Party__r != null)
                        {
                            system.debug('getAgreementMetaData Deal Party'); 
                            Deal_Party__c dealParty =  agreementParty.Deal_Party__r;
                            Account acc = dealParty.Relationship__r;
                            system.debug('getAgreementMetaData Acc Name and SDS');
                            system.debug(acc.Name);
                            system.debug(acc.SDS__c);
                            borrowerListName.add(acc.Name);
                            if (acc.SDS__c !=null)
                            {
                                SDS.add(acc.SDS__c);    
                            } 
                        }
                        else
                        {
                            system.debug('This is not a BOX catered for Party Type');
                        }  
                    }
                }   
            }            
        }
        if (borrowerListName !=null)
        {
            sBorrowerListName = BoxDocumentViewHelper.packListCSV(borrowerListName);
        }
        if (SDS !=null)
        {
            sSDS = BoxDocumentViewHelper.packListCSV(SDS);
        }

        //set metadata on handler
        system.debug('getAgreementMetaData DealName '+DealName);
        metaHandler.dealName = DealName;
        system.debug('getAgreementMetaData AgreementName '+agreementName);
        metaHandler.agreementName = agreementName;
        system.debug('getDealMetaData sBorrowerListName '+sBorrowerListName);
        metaHandler.borrowerName =  sBorrowerListName;
        system.debug('getDealMetaData sSDS '+sSDS);
        metaHandler.SDS = sSDS;
        
    }
    
    /**
	* getDealMetaData - get metadata related to the Deal
	**/
    private static void getDealMetaData (Sobject record) {
        //Populates metaHandler with Deal Name, Borrower(multi) and single SDS (multi)
        system.debug('getDealMetaData');
        List<advpm__Matter__c> matterList = null;
        
        //build query
        String query = null;
        query = 'Select Name, (Select Name, Party_Type__c, Relationship__r.Name, Relationship__r.SDS__c  from Deal_Parties__r) from advpm__Matter__c'; 
        query += ' WHERE Id = ' +'\''+ String.valueOf(record.get('Matter__c')) +'\'';
        system.debug(query);
        matterList =  Database.query(query);
        
        
        //init variables
        String sSDS = '';
        String DealName =''; 
        String sBorrowerListName = '';
        List<String> borrowerListName = new List<String>();
        List<String> SDS = new List<String>();
        
        //loop through all matter_deal list and fetch metadata
        for (advpm__Matter__c matterItem:matterList)
        {
            DealName = matterItem.Name;
            if (matterItem.Name != null)
            {
                //This should be same for any record returned. There should be only one record
                
                if (matterItem.Deal_Parties__r != null)
                {
                    List<Deal_Party__c> dealPartyList = matterItem.Deal_Parties__r;
                    
                    for (Deal_Party__c dealParty:dealPartyList )
                    {
                        if (dealParty.Party_Type__c == 'Borrower')
                        {
                            System.debug('getDealMetaData - SDS/Borrower List');
                            
                            if (dealParty.Relationship__c !=null)
                            {
                                Account acc=  dealParty.Relationship__r;
                                system.debug('getDealMetaData Acc Name and SDS');
                                system.debug(acc.Name);
                                system.debug(acc.SDS__c);
                                borrowerListName.add(acc.Name);
                                if (acc.SDS__c !=null)
                                {
                                    SDS.add(acc.SDS__c);
                                }
                            }
                            
                        }
                        else
                        {
                            system.debug('This is not a BOX catered for Party Type');
                        }
                    }
                    if (borrowerListName !=null)
                    {
                        sBorrowerListName = BoxDocumentViewHelper.packListCSV(borrowerListName);
                    }
                    if (SDS !=null)
                    {
                        sSDS = BoxDocumentViewHelper.packListCSV(SDS);
                    }                  
                }
            }         
        }
        
        //set deal metadata on handler
        system.debug('getDealMetaData DealName '+DealName);
        metaHandler.dealName = DealName;
        system.debug('getDealMetaData sBorrowerListName '+sBorrowerListName);
        metaHandler.borrowerName =  sBorrowerListName;
        system.debug('getDealMetaData sSDS '+sSDS);
        metaHandler.SDS = sSDS;  
    }
    
        /**
    * FolderHandler - wrapper class for BxdFolderHandler
	**/
    private class UserFolderHandler extends BxdFolderHandler {
        private UserFolderHandler(String boxUserEmail) { 
            //the specific constructor in parent will be initialized with null to allow finding current user email
            super(true, boxUserEmail);
        }
    }
    
    
    /**
    * FolderHandler - wrapper class for BxdFolderHandler
	**/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() { 
            //the specific constructor in parent will be initialized with null to allow finding current user email
            super(true, null);
        }
    }
    
    /**
    * MetadataHandler - wrapper class for BxdMetadataHandler
	**/
    private class MetadataHandler extends BxdMetadataHandler {
        private String parentRecordId {get;set;} 
        private String documentType {get;set;}
        private String expiryDate {get;set;}
        private String status {get;set;}
        private String documentName {get;set;}
        private String dealName {get;set;} 
        private String agreementName {get;set;}
        private String collateralType {get;set;}
        private String issuerName {get;set;}
        private String borrowerName {get;set;}
        private String providerName {get;set;}
        private String SDS {get;set;}
        private String beneficiaryName {get;set;}
        private String conditionType {get;set;}
        private String personalInformation {get;set;}
        
        private MetadataHandler() {
            //the specific constructor in parent will be initialized
            super(true);
        }
    }
}