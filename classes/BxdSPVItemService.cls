public class BxdSPVItemService {
    private static String ITEM_FOLDER = 'Items';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of spvItem records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<SPV_Items__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(SPV_Items__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each spvItem record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> recordsSet) {
        SPV_Items__c item;
        List<SPV_Items__c> recordsList = new List<SPV_Items__c>([SELECT Id, Name, Agreement__c, RecordTypeId FROM SPV_Items__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c itemStructure;
        String parentFolderId;
        String customKey;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
                
        if(recordsList !=null && !recordsList.isEmpty())
        {
            item = recordsList[0];
            String recordTypeName = SPV_Items__c.sObjectType.getDescribe().getRecordTypeInfosById().get(item.RecordTypeId).getName();
            itemStructure = folderHandler.getFolderStructure(recordTypeName);
            
            if(item != null && itemStructure != null && item.Agreement__c != null && itemStructure.Folder_Name__c != null){
                customKey = item.Agreement__c + ' - ' + itemStructure.Folder_Name__c;
                
                String queryWhere = '%' + item.Agreement__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                                        FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(item.Agreement__c);
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
        System.debug('FRUP MAP '+frupMap);   
        //Keep parent folder
        String staticItemFolderId;
        for (SPV_Items__c itemObject : recordsList) {
            staticItemFolderId = createBoxFolderForRecord(itemObject, itemStructure, parentFolderId, staticItemFolderId, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticItemFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticItemFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for spvItem record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(SPV_Items__c item, Box_Folder_Structure__c itemStructure, String parentFolderId, String staticItemFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(item != null && !String.isBlank(parentFolderId)){
            String folderId;
            //Select custom folder name for this record type                
            if(itemStructure != null){
                ITEM_FOLDER = itemStructure.Folder_Name__c;
            }
            
            String customKey = item.Agreement__c + ' - ' + ITEM_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticItemFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(item.Id, item.Name, details.FolderId__c);
                } else if(!String.isBlank(staticItemFolderId)){
                    folderId = folderHandler.createBoxFolder(item.Id, item.Name, staticItemFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(item.Id, folderId);
            } else {
                //create holding folder
                staticItemFolderId = folderHandler.createBoxFolder(ITEM_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(item.Id, item.Name, staticItemFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(item.Id, folderId);
            } 
        }
        
        return staticItemFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}