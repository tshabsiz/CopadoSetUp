public virtual class BxdPermissionHandler {
    private static box.Toolkit boxToolkit;
    
    /**
	* BxdPermissionHandler constructor - used to instantiate box.Toolkit object
	**/
    public BxdPermissionHandler() {
        boxToolkit = new box.Toolkit();
    }
    
    /**
	* createPermissionForUser - used to call createPermission and it requires one argument recordId
	**/
    public void createPermissionForUser(Id recordId){
        Id userId = UserInfo.getUserId();
        createPermission(recordId, userId);      
    }
    
    /**
	* createPermissionForUser -  used to call createPermission and it requires two arguments recordId and userId
	**/
    public void createPermissionForUser(Id recordId, Id userId){
        createPermission(recordId, userId);       
    }
    
    /**
	* createPermission - used to set collaborationType based on the recordAccess level for the user 
	* It then createCollaborationOnRecord for this user 
	**/
    private void createPermission(Id recordId, Id userId){        
        if(userId != null && recordId != null){
            
            UserRecordAccess recordAccess = [SELECT RecordId, MaxAccessLevel FROM UserRecordAccess WHERE UserId =:userId AND RecordId =:recordId];
            
            box.Toolkit.CollaborationType collaborationType;
            system.debug('***userId**'+userId+'***recordAccess**'+recordAccess.MaxAccessLevel);
            if(recordAccess.MaxAccessLevel == 'All' || recordAccess.MaxAccessLevel == 'Transfer' || recordAccess.MaxAccessLevel == 'Delete' || recordAccess.MaxAccessLevel == 'Edit'){
                collaborationType = box.Toolkit.CollaborationType.EDITOR;
            } else if(recordAccess.MaxAccessLevel == 'Read'){
                collaborationType = box.Toolkit.CollaborationType.VIEWER;
            } else {
                //No collaboration allowed
            }
            
            String collabId = createCollaborationOnRecord(userId, recordId, collaborationType);
            
            system.debug('Collaboration '+ collabId + ', Box Permission Debug: ' + boxToolkit.mostRecentError);
            
            //check that the collaboration is valid if not recreate, this is for old collaboration
            if (test.isRunningTest() == false){
                BxdPermissionHelper.validateCollaboration(userId, recordId, collabId, collaborationType);
            }
            
            commitBoxChanges();
        }       
    }
    
    /**
	* createConditionPermission - used to set collaborationType based on the recordAccess level for the user 
	* It then createCollaboration for this user 
	**/
    public void createConditionPermission(Id recordId, Custom_FRUP__c detail){
        Id userId = UserInfo.getUserId();
        String email = UserInfo.getUserEmail();
        if(recordId != null && detail != null && userId != null && !String.isBlank(email)){
            UserRecordAccess recordAccess = [SELECT RecordId, MaxAccessLevel FROM UserRecordAccess WHERE UserId =:userId AND RecordId =:recordId];
            
            box.Toolkit.CollaborationType collaborationType;
            
            if(recordAccess.MaxAccessLevel == 'All' || recordAccess.MaxAccessLevel == 'Transfer' || recordAccess.MaxAccessLevel == 'Delete' || recordAccess.MaxAccessLevel == 'Edit'){
                collaborationType = box.Toolkit.CollaborationType.EDITOR;
            } else if(recordAccess.MaxAccessLevel == 'Read'){
                collaborationType = box.Toolkit.CollaborationType.VIEWER;
            } else {
                //No collaboration allowed
            }
                       
            String collabId = createCollaboration(detail.FolderId__c, email, collaborationType);
            system.debug('Collaboration Id: '+collabId+ ', Message: '+boxToolkit.mostRecentError);
        }       
    }
    
    /**
	* createCollaboration - used to instantiate box.Toolkit object
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaboration-	
	**/
    public String createCollaboration(String folderId, String email, box.Toolkit.CollaborationType collaborationType){
        return boxToolkit.createCollaboration(folderId, null, email, collaborationType, null);
    }
    
    /**
	* createCollaborationOnRecord - used to call createCollaborationOnRecord in boxToolkit
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--createcollaborationonrecord-
	**/
    public String createCollaborationOnRecord(Id userId, Id recordId, box.Toolkit.CollaborationType collaborationType){
        return  boxToolkit.createCollaborationOnRecord(userId, recordId, collaborationType, false);
    }
    
    /**
	* getBoxFolderIdByRecordId - return the folder id of the record. Do not use this for Condition object
	**/
    public String getBoxFolderIdByRecordId(Id recordId){
        return boxToolkit.getFolderIdByRecordId(recordId);    
    }
    
    /**
	* commitBoxChanges - used to save changes
	* https://developer.box.com/docs/box-for-salesforce-developer-toolkit#section--commitchanges-
	**/
    public void commitBoxChanges(){
        // ALWAYS call this method when finished with boxToolkit.
        if (test.isRunningTest() == false){
            boxToolkit.commitChanges();
        }
    }  
}