public virtual class BxdFolderStructureHelper {

    public BxdFolderStructureHelper() {}
        
    /**
    * getFolderStructure - used to query Box_Folder_Structure__c to find folder structure based on recordTypeName passed as an argument
	**/
    public Box_Folder_Structure__c getFolderStructure(String recordTypeName) {
        Box_Folder_Structure__c queryHelper;
        try
        {
            queryHelper = [select ID, Custom__c, Folder_Level__c, Folder_Name__c, Folder_Type__c, Main_Record_Type__c, Legal_Hold_Policy_Id__c, Legal_Hold_Policy_Name__c, Static_Folder__c, Webhook_Triggers__c, Webhook_URL__c, Parent_Lookup__c, External_Collaboration_Id__c from Box_Folder_Structure__c where Folder_Type__c includes (:recordTypeName) ORDER BY Folder_Level__c ASC LIMIT 1];
        }
        catch (Exception e)
        {
            system.debug('Box Integration: Cannot find record type name for ' + recordTypeName + ' on Box Folder Structure: '+e);
        }   
        return queryHelper;
    }
    
    /**
    * getFolderStructure - used to query Box_Folder_Structure__c to find folder structure based on recordTypeName, requires two arguments
	**/
    public Box_Folder_Structure__c getFolderStructure(SObjectType sObjectType, Id recordTypeId){
        Box_Folder_Structure__c queryHelper;
        try
        {
            String recordTypeName = sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            return queryHelper =[select ID, Custom__c, Folder_Level__c, Folder_Name__c, Folder_Type__c, Main_Record_Type__c, Legal_Hold_Policy_Id__c, Legal_Hold_Policy_Name__c, Static_Folder__c, Webhook_Triggers__c, Webhook_URL__c, Parent_Lookup__c, External_Collaboration_Id__c from Box_Folder_Structure__c where Folder_Type__c includes (:recordTypeName) ORDER BY Folder_Level__c ASC LIMIT 1];
        }
        catch (Exception e)
        {
            system.debug('Box Integration: Cannot find record type name for ' + sObjectType.getDescribe().getName() + ' on Box Folder Structure: '+e);
        }
        
        return null;
    }
    
 	/**
    * getFolderStructure - used to query Box_Folder_Structure__c to find static folder structure based on recordTypeName
	**/
    public Box_Folder_Structure__c getFolderStructure(SObjectType sObjectType, Id recordTypeId, Boolean staticFolder, Boolean customLink){
        Box_Folder_Structure__c queryHelper;
        try
        {
            String recordTypeName = sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            return queryHelper =[select ID, Custom__c, Folder_Level__c, Folder_Name__c, Folder_Type__c, Main_Record_Type__c, Legal_Hold_Policy_Id__c, Legal_Hold_Policy_Name__c, Static_Folder__c, Webhook_Triggers__c, Webhook_URL__c, Parent_Lookup__c, External_Collaboration_Id__c from Box_Folder_Structure__c where Folder_Type__c includes (:recordTypeName) AND Static_Folder__c =: staticFolder AND Custom__c =: customLink ORDER BY Folder_Level__c ASC LIMIT 1];  
        }
        catch (Exception e)
        {
            system.debug('Box Integration: Cannot find record type name for ' + sObjectType.getDescribe().getName() + ' on Box Folder Structure: '+e);
        }
        
        return null;
    }
    
    /**
    * getFolderStructures - used to query Box_Folder_Structure__c to find a list of static folder structures based on recordTypeName
	**/
    public List<Box_Folder_Structure__c> getFolderStructures(SObjectType sObjectType, Id recordTypeId, Boolean staticFolder){
        List<Box_Folder_Structure__c> queryHelper;
        try
        {
            String recordTypeName = sObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
            return queryHelper =[select ID, Custom__c, Folder_Level__c, Folder_Name__c, Folder_Type__c, Main_Record_Type__c, Legal_Hold_Policy_Id__c, Legal_Hold_Policy_Name__c, Static_Folder__c, Webhook_Triggers__c, Webhook_URL__c, Parent_Lookup__c, External_Collaboration_Id__c from Box_Folder_Structure__c where Folder_Type__c includes (:recordTypeName) AND Static_Folder__c =: staticFolder ORDER BY Folder_Level__c ASC];
            
        }
        catch (Exception e)
        {
            system.debug('Box Integration: Cannot find record type name for ' + sObjectType.getDescribe().getName() + ' on Box Folder Structure: '+e);
        }
        
        return new List<Box_Folder_Structure__c>();
    }
    
    /**
    * getRecordValue - used to manipulate a record to get a value of a specific field
	**/
    public String getRecordValue(SObject record, String fieldName){
        String value;
        try
        {
            value = String.valueOf(record.get(fieldName));
        }
        catch (Exception e)
        {
            system.debug('Failed to get record value for field '+fieldName);
        }
        return value;
    }
    
    /**
    * getRecordTypeName - used to find the record type name using the record type id parameter to query the database
	**/
    public String getRecordTypeName(String recordTypeId){
        try
        {
            RecordType recordType = [SELECT Name FROM RecordType WHERE Id=:recordTypeId LIMIT 1];
            if(recordType != null){
                return recordType.Name;
            }
        }
        catch (Exception e)
        {
            system.debug('Failed to get record type name: '+e);
        }
        
        return '';
    }
    
    /**
    * getFolderStructure - used to query Box_Folder_Structure__c to find folder structure based on recordTypeName passed as an argument
	**/
    public box__FRUP__c getBoxUser(Id salesforceUser) {
        box__FRUP__c frup;
        try
        {
            frup = [SELECT ID, box__Box_user__c, CreatedDate, box__Object_Name__c FROM box__FRUP__c WHERE box__Salesforce_User__c =: salesforceUser AND box__Box_user__c != null ORDER BY CreatedDate DESC LIMIT 1];
        }
        catch (Exception e)
        {
            system.debug('Box Integration: Cannot find a Box user associate with Salesforce user: ' + salesforceUser + ' on FRUP: ' + e);
        }   
        return frup;
    }
    
    /**
    * getTokenExchangeDataString - this method takes in a map, then generate a string as in url param form
	**/
    public String getTokenExchangeDataString(Map<String, String> params) {
        BxdStringBuilder result = new BxdStringBuilder();
        boolean first = true;
        for(String key : params.keySet()) {
            if (first) {
                first = false;
            } else {
                result.append('&');
            }                
            result.append(key);
            result.append('=');
            result.append(params.get(key));
        }    
        return result.build();
    }
    
    /**
    * parseToolkitRole - parse a role string into Box Toolkit Collaboration Role
	**/
    public box.Toolkit.CollaborationType parseToolkitRole(String value) {
        if (value == 'VIEWER_UPLOADER') {
            return box.Toolkit.CollaborationType.VIEWERUPLOADER;
        } else if (value == 'PREVIEWER_UPLOADER') {
            return box.Toolkit.CollaborationType.PREVIEWERUPLOADER;
        } else if (value == 'VIEWER') {
            return box.Toolkit.CollaborationType.VIEWER;
        } else if (value == 'PREVIEWER') {
            return box.Toolkit.CollaborationType.PREVIEWER;
        }
        
        return null;
    }
    
    /**
    * parseRole - parse a role string into Box SDK Collaboration Role
	**/
    public BoxCollaboration.Role parseRole(String value) {
        if (value == 'VIEWER_UPLOADER') {
            return BoxCollaboration.Role.VIEWER_UPLOADER;
        } else if (value == 'PREVIEWER_UPLOADER') {
            return BoxCollaboration.Role.PREVIEWER_UPLOADER;
        } else if (value == 'VIEWER') {
            return BoxCollaboration.Role.VIEWER;
        } else if (value == 'PREVIEWER') {
            return BoxCollaboration.Role.PREVIEWER;
        }
        
        return null;
    }
}