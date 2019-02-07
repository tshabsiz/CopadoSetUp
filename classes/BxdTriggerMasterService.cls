public class BxdTriggerMasterService {
    private static final String TRIGGER_FS = 'Trigger Master';
    private static String TRIGGER_FOLDER = 'Triggers';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of trigger records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Trigger__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Trigger__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each trigger record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> recordsSet) {
        Trigger__c theTrigger;
        List<Trigger__c> recordsList = new List<Trigger__c>([SELECT Id, Name, Agreement__c FROM Trigger__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c triggerStructure;
        String parentFolderId;
        String customKey;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        
        if(recordsList !=null && !recordsList.isEmpty()) 
        {
            theTrigger = recordsList[0];
            triggerStructure = folderHandler.getFolderStructure(TRIGGER_FS);
            
            if(theTrigger != null && triggerStructure != null && theTrigger.Agreement__c != null && triggerStructure.Folder_Name__c != null){
                customKey = theTrigger.Agreement__c + ' - ' + triggerStructure.Folder_Name__c;
                
                String queryWhere = '%' + theTrigger.Agreement__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                           FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(theTrigger.Agreement__c);
            }           
            System.debug('### PARENT FOLDERID: '+parentFolderId);
            System.debug('### customKey : '+customKey);
        }
        
        Map<String, List<Custom_FRUP__c>> frupMap = new Map<String, List<Custom_FRUP__c>>();
        List<Custom_FRUP__c> lst;
        for(Custom_FRUP__c l : details) {
            if(frupMap.get(l.CustomKey__c)==null){
                lst = new List<Custom_FRUP__c>();
            }            
            lst.Add(l);
            frupMap.put(l.CustomKey__c,lst);       
        }
        System.debug('### FRUP MAP '+frupMap);  
        //Keep parent folder
        String staticTriggerFolderId;
        for (Trigger__c triggerObject : recordsList) {
            staticTriggerFolderId = createBoxFolderForRecord(triggerObject, triggerStructure, parentFolderId, staticTriggerFolderId, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticTriggerFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticTriggerFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    
    /**
    * createBoxFolderForRecord - used to create a box folder for trigger record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(Trigger__c triggerObject, Box_Folder_Structure__c triggerStructure, String parentFolderId, String staticTriggerFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(triggerObject != null && !String.isBlank(parentFolderId)){
            String folderId;
            //Select custom folder name for this record type                
            if(triggerStructure != null){
                TRIGGER_FOLDER = triggerStructure.Folder_Name__c;
            }
            
            String customKey = triggerObject.Agreement__c + ' - ' + TRIGGER_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticTriggerFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(triggerObject.Id, triggerObject.Name, details.FolderId__c);
                } else if(!String.isBlank(staticTriggerFolderId)){
                    folderId = folderHandler.createBoxFolder(triggerObject.Id, triggerObject.Name, staticTriggerFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(triggerObject.Id, folderId);
            } else {
                //create holding folder
                staticTriggerFolderId = folderHandler.createBoxFolder(TRIGGER_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(triggerObject.Id, triggerObject.Name, staticTriggerFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(triggerObject.Id, folderId);
            } 
            System.debug('***Box Folder '+folderId);
        }
        
        return staticTriggerFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}