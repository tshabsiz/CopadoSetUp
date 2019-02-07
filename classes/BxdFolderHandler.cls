/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Handles BoxFolder and BoxFile related REST API
* @Date:        2017
*/
public abstract class BxdFolderHandler extends BxdFolderStructureHelper {
    private static final String UPLOAD_FILE_VERSION_URL = 'files/{0}/content';
    private static final String UPLOAD_FILE_URL = 'files/content?parent_id={0}';
    private static final String FILE_SHAREDLINK_URL = 'files/{0}?fields=shared_link';
    private static final String FOLDER_SHAREDLINK_URL = 'folders/{0}?fields=shared_link';
    private static final String FILE_TOKENEXCHANGE_URL = 'files/{0}';
    private static final String FOLDER_TOKENEXCHANGE_URL = 'folders/{0}';
    private static final String DOWNLOAD_FILE = 'files/{0}/content';
    private static final String DEFAULT_ACCESS = 'collaborators';
    private static final String DISCLAIMER_DOCUMENT = 'Disclaimer';
    private static final String TEST_FOLDER_ID = '0';
    private static final String TIMESTAMP_FORMAT = 'hhmmssSSS';
    private static final String EXCHANGE_GRANT_TYPE = 'urn:ietf:params:oauth:grant-type:token-exchange';
    private static final String EXCHANGE_TOKEN_TYPE = 'urn:ietf:params:oauth:token-type:access_token';
    private static BxdIntegrationConnection boxConnection;
    private static BoxPlatformApiConnection api;
    private static box.Toolkit boxToolkit;
    
    /**
	* BxdFolderHandler - construct the folder handler with the toolkit only
	**/
    public BxdFolderHandler() {
        boxToolkit = new box.Toolkit();
    }
    
    /**
	* BxdFolderHandler - construct the folder handler and connect to the box api as the service account
	**/
    public BxdFolderHandler(Boolean connect) {
        //init boxToolkit from here aswell, as this is called from super
        boxToolkit = new box.Toolkit();
        
        //init the Box Api from box integration connection
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi();
        }
    }
    
    /**
	* BxdFolderHandler - construct the folder handler and connect to the box api as the user passed in
	**/
    public BxdFolderHandler(Boolean connect, String userId) {
        //init boxToolkit from here aswell, as this is called from super
        boxToolkit = new box.Toolkit();
        
        //init the Box Api from box integration connection
        boxConnection = BxdIntegrationConnection.getInstance();
        if(connect){
            api = boxConnection.getBoxApi(getCurrentBoxUser(userId));
        }
    }
    
    /**
	* getBoxApi - get box api as we might need it from outside of this class for flexibility
	**/
    public BoxPlatformApiConnection getBoxApi(){
        return api;
    }
    
    /**
	* createBoxFolderForRecord - create box folder for the record id, only used for folders on higher level of folder structure like Deal
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolderforrecordid-
	**/
    public String createBoxFolderForRecord(Id recordId){
        String folderId = boxToolkit.createFolderForRecordId(recordId, null, true);
        
        // If there was an error. mostRecentError will contain the error message
        if(folderId == null) {
            system.debug('**createBoxFolderForRecord Log: ' + boxToolkit.mostRecentError);
        }
        
        return folderId;
    }
    
    /**
	* createBoxFolder - create box folder with provided folder name inside the provided parent folder
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolder-
	**/
    public String createBoxFolder(String folderName, String parentFolderId){
        if(test.isRunningTest() == false){
            //create folder
            String folderId = boxToolkit.createFolder(folderName, parentFolderId, null);
            
            // If there was an error. mostRecentError will contain the error message
            if(folderId == null) {
                system.debug('**createBoxFolder Log: ' + boxToolkit.mostRecentError);
            }
            
            return folderId;
        } else {
            return TEST_FOLDER_ID;
        }
    }
    
    /**
	* createBoxFolder - create box folder, attempt to create folder again using timestamp if another folder with same name exist
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolder-
	**/
    public String createBoxFolder(Id recordId, String folderName, String parentFolderId){
        if(test.isRunningTest() == true){
            return TEST_FOLDER_ID;
        }
        //create folder
        String folderId = boxToolkit.createFolder(folderName, parentFolderId, null);
        
        // If there was an error. mostRecentError will contain the error message
        if(folderId == null) {
            //check if failed to existing folder name
            String recentError = boxToolkit.mostRecentError;
            String folderExist = 'already exists';
            
            if(!String.isBlank(recentError) && recentError.contains(folderExist)){
                //Attempt to create folder again with record id
                String timestamp = Datetime.now().format(TIMESTAMP_FORMAT);
                folderName = folderName + '_' + recordId + '_' + timestamp;
                folderId = boxToolkit.createFolder(folderName, parentFolderId, null);
            } else {
                system.debug('**createBoxFolder Log: ' + boxToolkit.mostRecentError);
            }
        }
        
        return folderId;
    }
    
    /**
	* createBoxFolderOrGetExistingFolder - create box folder with provided folder name inside the provided parent folder
	* if the folder already exists, get the existing folder id.
	**/
    public String createBoxFolderOrGetExistingFolder(String folderName, String parentFolderId){
        try{
            BoxFolder folder = new BoxFolder(api, parentFolderId);
            BoxFolder.Info createdFolderInfo = folder.createFolder(folderName);
            if(createdFolderInfo != null && createdFolderInfo.Id != null){
                return createdFolderInfo.Id;
            } else {
                BoxJsonObject jsonObject = (BoxJsonObject) createdFolderInfo;
                if (jsonObject != null && jsonObject.getValue('status') == '409' && jsonObject.getValue('context_info') != null) {
                    BxdFileConflict item = BxdFileConflict.parse(jsonObject.getValue('context_info'));
                    return item.conflicts.id;
                }  
            }
        } catch (Exception e){
            System.debug('***createBoxFolderOrGetExistingFolder EXCEPTION ' + e);
        }
        
        return null;
    }
    
    /**
	* createExternalBoxFolder - create collaboration for external users by using temporary folder then move to intended folder
	* https://developer.box.com/v2.0/reference#collaboration-object
	**/
    public BxdExternalCollaborationHelper createExternalBoxFolder(BxdExternalCollaborationHelper collaboration){
        String folderId = boxToolkit.createFolder(collaboration.name, collaboration.externalFolderId, null);
        
        // If a folder with same name exist, attempt to create again but add timestamp of current datetime
        if(String.isBlank(folderId)) {
            system.debug('***External Folder Log: ' + boxToolkit.mostRecentError);
            //build timestamp
            String timestamp = Datetime.now().format(TIMESTAMP_FORMAT);
            folderId = boxToolkit.createFolder(collaboration.name + ' ' + timestamp, collaboration.externalFolderId, null);
        }
        
        //Give permission to coowner
        if(!String.isBlank(collaboration.coowner)){
            box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.COOWNER;
            String collabId = this.createCollaboration(folderId, collaboration.coowner, collabType);
            system.debug('***Co-owner Collaboration Id: ' + collabId);
        }
        
        //Give permission to requested collaborators
        if(collaboration.collaborators != null && !collaboration.collaborators.isEmpty() && collaboration.collaborationType != null){
            addCollaboratorsToFolder(folderId, collaboration.collaborators, collaboration.collaborationType);
            system.debug('***Collaborators Collaboration IDs: ' + collaboration.collaborators);
        }
              
        //Move Folder to real parent
        if(!String.isBlank(folderId)){
            //Move 
            Boolean moved = this.moveBoxFolder(folderId, collaboration.parentFolderId);
            system.debug('***External Collaboration Folder Moved To Parent? ' + moved);
            if(!moved){
                //Attempt to move folder again to correct destination in case it failed (network issues etc)
                moved = this.moveBoxFolder(folderId, collaboration.parentFolderId);
                system.debug('***Try Again External Collaboration Folder Moved To Parent? ' + moved);
            }
            
            //Copy disclaimer document
            copyDisclaimerDocument(folderId);
        } 
        
        //set External Collaboration Folder Id on helper class
        collaboration.folderId = folderId;
        
        return collaboration;
    }
    
    /**
	* addCollaborators - add collaborators on the folder with provided collaboration type
	**/
    public void addCollaboratorsToFolder(String folderId, List<BxdExternalCollaborationHelper.Collaborator> collaborators, box.Toolkit.CollaborationType collaborationType){
        //loop through emails and create collaboration
        for(BxdExternalCollaborationHelper.Collaborator collaborator : collaborators){
            //call api to create collaboration
            String collabId = this.createCollaboration(folderId, collaborator.email, collaborationType);
            
            //set collaboration id back on list as might need it for future edit/remove
            collaborator.collaborationId = collabId;
        }
    }
    
    /**
	* linkBoxFolderToSalesforceRecord - associate box folder to a salesforce record on the FRUP object
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createfolderassociation-
	**/
    public void linkBoxFolderToSalesforceRecord(Id recordId, String folderId){
        boxToolkit.createFolderAssociation(recordId, folderId);
        system.debug('**linkBoxFolderToSalesforceRecord Log: ' + boxToolkit.mostRecentError);
    }
    
    /**
	* createCollaboration - create collaboration on the provided folder and the user email.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaboration-
	**/
    public String createCollaboration(String folderId, String email, box.Toolkit.CollaborationType collaborationType){
        String ret = boxToolkit.createCollaboration(folderId, null, email, collaborationType, null);
        system.debug('**createCollaboration Log: ' + boxToolkit.mostRecentError);
        return ret;
    }
    
    /**
	* createCollaboration - create collaboration on the provided folder and the user id.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaboration-
	**/
    public String createCollaborationOnUser(String folderId, String userId, box.Toolkit.CollaborationType collaborationType){
        String ret = boxToolkit.createCollaboration(folderId, userId, null, collaborationType, null);
        system.debug('**createCollaborationOnUser Log: ' + boxToolkit.mostRecentError);
        return ret;
    }
    
    /**
	* createCollaborationOnRecord - create collaboration on a salesforce record linked folder based on type.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaborationonrecord-
	**/
    public String createCollaborationOnRecord(Id userId, Id recordId, box.Toolkit.CollaborationType collaborationType){
        String ret = boxToolkit.createCollaborationOnRecord(userId, recordId, collaborationType, false);
        system.debug('**createCollaborationOnRecord Log: ' + boxToolkit.mostRecentError);
        return ret;
    }
    
    /**
	* getBoxFolderIdByRecordId - get Box folder id associated with the Salesforce record id passed in.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getfolderidbyrecordid-
	**/
    public String getBoxFolderIdByRecordId(String recordId){
        //check if not in test
        if (test.isRunningTest() == false){
            String folderId = boxToolkit.getFolderIdByRecordId(recordId);
            system.debug('**getBoxFolderIdByRecordId Log: ' + boxToolkit.mostRecentError);
            return folderId;
        }else{
            return TEST_FOLDER_ID;
        }
        
    }
    
    /**
	* getBoxFolderIdByRecordIdForCustomUI - get Box folder id associated with the Salesforce record id passed in for custom folder structure
	**/
    public String getBoxFolderIdByRecordIdForCustomUI(Id recordId){
        //find the parent objec type
        Schema.SObjectType ObjType =  recordId.getSobjectType();
        
        //condition folder structure is a bit complex, the below will query the condition folder id from Custom FRUP
        if (String.valueOf(ObjType) == 'Condition__c'){
            //find the condition
            Condition__c condition = [SELECT Id, Name, Agreement__c, RecordTypeId FROM Condition__c WHERE Id=:recordId LIMIT 1];
            String conditionTypeName = Schema.SObjectType.Condition__c.getRecordTypeInfosById().get(condition.RecordTypeId).getName(); 
            
            //based on the condition info, find the folder id on the custom frup as we know the key (agreement - condition name)
            if(conditionTypeName != null && condition != null){
                String conditionKey = condition.Agreement__c + ' - ' + conditionTypeName;
                List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE FolderId__c != NULL AND CustomKey__c =:conditionKey];
                if (conditionFrups != null && !conditionFrups.isEmpty()){
                    Custom_FRUP__c details = conditionFrups[0];
                    return details.FolderId__c;
                }  
            }
            
            //if for some reason we can't find the folder based on complex custom frup, get the folder id from normal FRUP
            return boxToolkit.getFolderIdByRecordId(recordId);
            
        } else if(String.valueOf(ObjType) == 'Condition_Occurrence__c'){
            //condition occurence folder structure is a bit complex, build query to find condition occurence
            Condition_Occurrence__c occurence = [SELECT Id, Name, Condition__r.Agreement__r.Id, RecordTypeId FROM Condition_Occurrence__c WHERE Id=:recordId LIMIT 1];
            String conditionTypeName = Schema.SObjectType.Condition_Occurrence__c.getRecordTypeInfosById().get(occurence.RecordTypeId).getName();
            
            //based on the condition occurence info, find the folder id on the custom frup as we know the key (agreement - condition name)
            if(conditionTypeName != null && occurence != null){
                String conditionKey = occurence.Condition__r.Agreement__r.Id + ' - ' + conditionTypeName;
                List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE FolderId__c!=NULL AND CustomKey__c =:conditionKey];
                if (conditionFrups != null && !conditionFrups.isEmpty()){
                    Custom_FRUP__c details = conditionFrups[0];
                    return details.FolderId__c;
                }  
            }
            
            //if for some reason we can't find the folder based on complex custom frup, get the folder id from normal FRUP
            return boxToolkit.getFolderIdByRecordId(recordId);
            
        } else {
            //return folder from normal FRUP for all other objects
            return boxToolkit.getFolderIdByRecordId(recordId);
        }       
    }
    
    /**
	* getRecordIdByBoxFolderId - get the salesforce record id associated with the Box folder id passed in.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getrecordidbyfolderid-
	**/
    public String getRecordIdByBoxFolderId(String folderId){
        String ret = boxToolkit.getRecordIdByFolderId(folderId);
        system.debug('**getRecordIdByBoxFolderId Log: ' + boxToolkit.mostRecentError);
        return ret;
    }
    
    /**
	* getObjectFolderByBoxFolderId - get the Box folder id of the object root folder for the record id passed in.
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getobjectfolderbyrecordid-
	**/
    public String getObjectFolderByBoxFolderId(Id recordId){
        String ret = boxToolkit.getObjectFolderByRecordId (recordId);
        system.debug('**getObjectFolderByBoxFolderId Log: ' + boxToolkit.mostRecentError);
        return ret;
    }
    
    /**
	* getBoxFolderURL - get the folder url
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--getfolderurl-
	**/
    public PageReference getBoxFolderURL(Id recordId, Boolean mobile){
        PageReference ref =  boxToolkit.getFolderUrl(recordId, mobile);
        system.debug('**getBoxFolderURL Log: ' + boxToolkit.mostRecentError);
        return ref;
    }
    
    /**
	* moveBoxFolder - move folder from old parent to new parent
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--movefolder-
	**/
    public Boolean moveBoxFolder(String folderId, String newParentFolderId){
        //move the folder to new parent
        Boolean result =  boxToolkit.moveFolder(folderId, newParentFolderId, null);
        system.debug('**moveBoxFolder Folder : ' + folderId + ' to ' + newParentFolderId + ' Log: ' + boxToolkit.mostRecentError);
        return result;
    }
    
    /**
	* uploadFileToBox - straight upload file to box from SF attachment
	* https://developer.box.com/v2.0/reference#upload-a-file
	**/
    public String uploadFileToBox(Attachment att, String folderId, String fileName){
        BoxFolder folder = new BoxFolder(api, folderId);
        BoxFile.Info fileInfo = folder.uploadFile(att, fileName);
        return fileInfo == null ? '' : fileInfo.id;
    }
    
    /**
	* uploadFileToBox - straight upload file to box from blob
	* https://developer.box.com/v2.0/reference#upload-a-file
	**/
    public String uploadFileToBox(Blob fileBody, String folderId, String fileName){
        //init box folder where we will upload
        BoxFolder folder = new BoxFolder(api, folderId);
        System.debug('Createdfolder :' + folder);
        
        //upload the file
        BoxFile.Info fileInfo = folder.uploadFile(fileBody, fileName);
        System.debug('uploaded file info :' + fileInfo);
        return fileInfo == null ? '' : fileInfo.id;
    }
    
    /**
	* uploadFileVersionToBox - attempt to upload file to box, if file exists, upload a new version
	* https://developer.box.com/v2.0/reference#upload-a-new-version-of-a-file
	**/
    public String uploadFileVersionToBox(Blob fileBody, String folderId, String fileName){
        //init and check that filename is there and filebody contains something 
        BoxFile.Info fileInfo;
        if (String.isEmpty(fileName)) {
            throw new BoxResource.BoxResourceException('fileName must not be null or empty when calling BoxFolder.uploadFile.');
        }
        if (fileBody == null || fileBody.size() == 0) {
            throw new BoxResource.BoxResourceException('fileBody must not be null or empty when calling BoxFolder.uploadFile.');
        }
        
        //Set URL
        String url = api.baseUploadUrl + String.format(UPLOAD_FILE_URL, new String[] { folderId });
        
        //Create Request
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
        request.setTimeout(api.getTimeout());
        request.setMultipartFormBody(fileBody, fileName);
        
        //upload file
        BoxGenericJsonObject responseObject = boxConnection.sendBoxRequest(request); 
        
        //Process response
        if (responseObject.getValue('total_count') != null) {	
            list<String> fileEntries = BoxJsonObject.parseJsonObjectArray(responseObject.getValue('entries'));
            if (fileEntries.size() > 0) {
                fileInfo = new BoxFile.Info(fileEntries[0]);
            }
        }
        
        //if upload failed due to conflict 409, upload a new version
        if(fileInfo == null){
            if (responseObject.getValue('status') == '409' && responseObject.getValue('context_info') != null) {
                BxdFileConflict file = BxdFileConflict.parse(responseObject.getValue('context_info'));
                String fileId = file.conflicts.id;
                
                //Set URL
                url = api.baseUploadUrl + String.format(UPLOAD_FILE_VERSION_URL, new String[] { fileId });
                
                //Set Request
                request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
                request.setTimeout(api.getTimeout());
                request.setMultipartFormBody(fileBody, fileName);
                
                //Send and get response
                responseObject = boxConnection.sendBoxRequest(request);
                
                //Process response
                if (responseObject.getValue('total_count') != null) {	
                    list<String> fileEntries = BoxJsonObject.parseJsonObjectArray(responseObject.getValue('entries'));
                    if (fileEntries.size() > 0) {
                        fileInfo = new BoxFile.Info(fileEntries[0]);
                    }
                }
            }  
        }
        
        return fileInfo == null ? '' : fileInfo.id;
    }
    
    /**
	* createBoxFileLink -  create shared link for file
	* https://developer.box.com/v2.0/reference#create-or-update-shared-link
	**/
    public String createBoxFileLink(String fileId, String access, Boolean canDownload, Boolean canPreview) {
        //build json body request params
        BxdSharedLink helper = new BxdSharedLink();
        helper.shared_link.access = access;
        if(!DEFAULT_ACCESS.equalsIgnoreCase(helper.shared_link.access)){
            helper.shared_link.permissions.can_download = canDownload;
            helper.shared_link.permissions.can_preview = canPreview;
        }      
        
        //send request param to create method
        helper = this.createFileSharedLink(fileId, helper);
        return helper.shared_link == null ? '' : helper.shared_link.url;
    }
    
    /**
	* createFileSharedLink -  http request to create a shared link for file
	* https://developer.box.com/v2.0/reference#create-or-update-shared-link
	**/
    public BxdSharedLink createFileSharedLink(String fileId, BxdSharedLink sharedLinkHelper) {
        //build URL
        String url = api.baseUrl + String.format(FILE_SHAREDLINK_URL, new String[] {fileId});
        
        //create http put request
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_PUT);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        request.setBody(BxdSharedLink.getJsonString(sharedLinkHelper));
        
        //send request and process response json string to object
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        return BxdSharedLink.parse(response.getJsonString());
    }
    
    /**
	* downloadFile -  download a file from box based on file id. Assuming that file size is within allowed memory
	* https://developer.box.com/v2.0/reference#download-a-file
	**/
    public Blob downloadFile(String fileId) {
        //build url
        String url = api.baseUrl + String.format(DOWNLOAD_FILE, new String[] {fileId});
        
        //create http get request
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_GET);
        request.setTimeout(api.getTimeout());
        request.addJsonContentTypeHeader();
        
        //send request and get response as blob
        Blob b = boxConnection.sendBlobRequest(request);
        return b;
    }
    
    /**
	* deleteFile -  delete a file on box based on file id.
	* https://developer.box.com/v2.0/reference#delete-a-file
	**/
    public void deleteFile(String fileId) {
        //init the box file
        BoxFile fileToDelete  = new BoxFile(api, fileId);
        System.debug('**Box File to Delete ID: '+fileToDelete .Id);
        
        //delete the file
        Boolean deleteFileResult = fileToDelete.deleteFile();
        System.debug('**Deleted: '+deleteFileResult);
    }
    
    /**
	* downscopeBoxToken -  exchange a parent token for a more granularly-scoped child token.
	* https://developer.box.com/v2.0/reference#token-exchange
	**/
    public String downscopeBoxToken(String parentToken, String scope, String resourceId, String type) {
        //Token URL endpoint
        String url = api.TokenUrl;
        
        //Build body-data
        Map<String, String> data = new Map<String, String>();       
        data.put('subject_token', parentToken);
        data.put('subject_token_type', EXCHANGE_TOKEN_TYPE);
        data.put('grant_type', EXCHANGE_GRANT_TYPE);
        data.put('scope', scope); 
        if(!String.isBlank(resourceId) && type == 'folder'){
            data.put('resource', api.baseUrl + String.format(FOLDER_TOKENEXCHANGE_URL, new String[] {resourceId}));
        }else if(!String.isBlank(resourceId) && type == 'file'){
            data.put('resource', api.baseUrl + String.format(FILE_TOKENEXCHANGE_URL, new String[] {resourceId}));
        } else {
            System.debug('** BxdTokenExchange -- downscopeBoxToken -- Generic Exchange');
        }
        
        //convert data map to string param
        String body = getTokenExchangeDataString(data);
        
        //Build https request
        BoxAPIRequest request = new BoxAPIRequest(api, url, BoxApiRequest.METHOD_POST);
        request.setTimeout(api.getTimeout());
        request.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        
        //Get response from box
        BoxGenericJsonObject response = boxConnection.sendBoxRequest(request);
        
        //Parse response
        BxdTokenExchange exchanged = BxdTokenExchange.parse(response.getJsonString());
        
        //Return exchanged token if successful else return original token
        if(exchanged != null && !String.isBlank(exchanged.access_token)){
            return exchanged.access_token;
        }
        
        return parentToken;
    }
    
    /**
	* removeCollaboration -  remove collaboration on a box resource.
	* https://developer.box.com/v2.0/reference#remove-a-collaboration
	**/
    public Boolean removeCollaboration(String collaborationId) {
        //check if collaboration is already invalid
        Boolean deleted = checkCollaboration(collaborationId);
        if(deleted){
            return true;
        }
        //init collaboration
        BoxCollaboration collaboration = new BoxCollaboration(api, collaborationId);
        
        //remove collaboration
        return collaboration.deleteCollaboration();
    }
    
    /**
	* updateCollaboration -  update collaboration on a box resource.
	* https://developer.box.com/v2.0/reference#remove-a-collaboration
	**/
    public void updateCollaboration(String collaborationId, BoxCollaboration.Role role) {
        //check collaboration
        Boolean invalid = checkCollaboration(collaborationId);
        if(!invalid){
            //init collaboration
            BoxCollaboration collaboration = new BoxCollaboration(api, collaborationId);
            
            //update collaboration role
            BoxCollaboration.Info updatedCollabInfo = collaboration.updateCollaboration(role);
            System.debug('***Updated Collab: ' + updatedCollabInfo);
        } 
    }
    
    public Boolean checkCollaboration(String collaborationId) {
        try{
            //ini collaboration and get info
            BoxCollaboration collaboration = new BoxCollaboration(api, collaborationId);
            BoxCollaboration.Info collabInfo = collaboration.getCollaboration();
            System.debug('***Valid collaboration: ' + collabInfo.Id);
            if (test.isRunningTest() == true){
                throw new BoxAPIException('Not Found');
            }
        } catch (Exception e){
            System.debug('***checkCollaboration - INVALID: ' + e);
            
            //check if not found
            String errorMessage = '' + e;
            String filter = 'Not Found';
            if(!String.isBlank(errorMessage) && errorMessage.contains(filter)){
                return true;
            }
        } 
        
        return false;
    }
    
    /**
	* copyDisclaimerDocument - copy and add disclaimer document to the folder
	**/
    private void copyDisclaimerDocument(String folderId){        
        try{
            //get file id from folder details
            box__Folder_Details__c setting = box__Folder_Details__c.getInstance(DISCLAIMER_DOCUMENT);
            
            //get file to copy and the destination folder
            if(setting != null){
                //check if we have the api
                if(api == null){
                    boxConnection = BxdIntegrationConnection.getInstance();
                    api = boxConnection.getBoxApi();
                }
                
                //initialize box resources
                BoxFile fileToCopy = new BoxFile(api, setting.box__FolderId__c);
                BoxFolder destination = new BoxFolder(api, folderId);
                
                //copy the file
                BoxFile.Info copiedFileInfo = (BoxFile.Info) fileToCopy.copy(destination);
                System.debug('***Disclaimer copied: ' + copiedFileInfo.Id);
            }
        } catch (Exception e){
            System.debug('***copyDisclaimerDocument - FAILED: ' + e);
        }
    }
    
    /**
	* getCurrentBoxUser - get back the user passed on parameter or find user on box
	**/
    public static String getCurrentBoxUser(String userId) {
        String email = UserInfo.getUserEmail();
        
        //return the userid or find the user based on email
        if(test.isRunningTest() == false){
            return !String.isBlank(userId) ? userId : getBoxEntrepriseUser(email);
        } else {
            return null;
        }
    }
    
    /**
	* getBoxEntrepriseUser - find user based on search key - email
	* https://developer.box.com/v2.0/reference#get-all-users-in-an-enterprise
	**/
    public static String getBoxEntrepriseUser(String searchKey) {
        //search the user login on box
        BoxUser.Info user;
        list<String> fields = new list<String> {'login'};
            
        //login as service account to search the user
        api = boxConnection.getBoxApi();
        list<BoxUser.Info> users = BoxUser.getAllEnterpriseUsers(api, searchKey, fields);
        
        //return the user found
        if(users != null && !users.isEmpty()){
            user = users[0];
            return user.Id;
        }        
        return null;
    }
    
    /**
	* recentBoxErrors - get recent error in box queue
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--mostrecenterror-
	**/
    public String recentBoxErrors(){
        return boxToolkit.mostRecentError;
    }
    
    /**
	* commitBoxChanges - commit box changes to db
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--commitchanges-
	**/
    public void commitBoxChanges(){
        // ALWAYS call this method when finished with boxToolkit.
        boxToolkit.commitChanges();
    }
    
    public class BoxAPIException extends Exception {}
}