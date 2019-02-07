public class BxdFacilityTrancheService {
    private static final String TRANCHE_FS = 'Tranche';
    private static String TRANCHE_FOLDER = 'Tranches';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of facilityTranche records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Facility_Tranche__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Facility_Tranche__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each facilityTranche record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> recordsSet) {
        Facility_Tranche__c tranche;
        List<Facility_Tranche__c> recordsList = new List<Facility_Tranche__c>([SELECT Id, Name, Facility__c FROM Facility_Tranche__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c trancheStructure;
        String parentFolderId;
        String customKey;      
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
                
        if(recordsList !=null && !recordsList.isEmpty()) 
        {
            tranche = recordsList[0];
            trancheStructure = folderHandler.getFolderStructure(TRANCHE_FS);
            
            if(tranche != null && trancheStructure != null && tranche.Facility__c != null && trancheStructure.Folder_Name__c != null){
                customKey = tranche.Facility__c + ' - ' + trancheStructure.Folder_Name__c;
                
                String queryWhere = '%' + tranche.Facility__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                                        FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(tranche.Facility__c);
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
        String staticTrancheFolderId;
        for (Facility_Tranche__c trancheObject : recordsList) {
            staticTrancheFolderId = createBoxFolderForRecord(trancheObject, trancheStructure, parentFolderId, staticTrancheFolderId, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticTrancheFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticTrancheFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for facilityTranche record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(Facility_Tranche__c tranche, Box_Folder_Structure__c trancheStructure, String parentFolderId, String staticTrancheFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(tranche != null && !String.isBlank(parentFolderId)){
            String folderId;
            //Select custom folder name for this record type                
            if(trancheStructure != null){
                TRANCHE_FOLDER = trancheStructure.Folder_Name__c;
            }
            
            String customKey = tranche.Facility__c + ' - ' + TRANCHE_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticTrancheFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(tranche.Id, tranche.Name, details.FolderId__c);
                } else if(!String.isBlank(staticTrancheFolderId)){
                    folderId = folderHandler.createBoxFolder(tranche.Id, tranche.Name, staticTrancheFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(tranche.Id, folderId);
            } else {
                //create holding folder
                staticTrancheFolderId = folderHandler.createBoxFolder(TRANCHE_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(tranche.Id, tranche.Name, staticTrancheFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(tranche.Id, folderId);
            } 
        }
        
        return staticTrancheFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}