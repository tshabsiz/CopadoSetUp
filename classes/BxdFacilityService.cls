public class BxdFacilityService {
    private static final String FACILITY_FS = 'Facility';
    private static String FACILITY_FOLDER = 'Facilities';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of facility records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Facility__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Facility__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each facility record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> recordsSet) {
        Facility__c facility;
        List<Facility__c> recordsList = new List<Facility__c>([SELECT Id, Name, Agreement__c FROM Facility__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c facilityStructure;
        String parentFolderId;
        String customKey;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
                
        if(recordsList !=null && !recordsList.isEmpty()) 
        {
            facility = recordsList[0];
            facilityStructure = folderHandler.getFolderStructure(FACILITY_FS);
            
            if(facility != null && facilityStructure != null && facility.Agreement__c != null && facilityStructure.Folder_Name__c != null){
                customKey = facility.Agreement__c + ' - ' + facilityStructure.Folder_Name__c;
                
                String queryWhere = '%' + facility.Agreement__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                                        FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(facility.Agreement__c);
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
        String staticFacilityFolderId;
        for (Facility__c facilityObject : recordsList) {
            staticFacilityFolderId = createBoxFolderForRecord(facilityObject, facilityStructure, parentFolderId, staticFacilityFolderId, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticFacilityFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticFacilityFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for facility record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(Facility__c facility, Box_Folder_Structure__c facilityStructure, String parentFolderId, String staticFacilityFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(facility != null && !String.isBlank(parentFolderId)){
            String folderId;
            //Select custom folder name for this record type                
            if(facilityStructure != null){
                FACILITY_FOLDER = facilityStructure.Folder_Name__c;
            }
            
            String customKey = facility.Agreement__c + ' - ' + FACILITY_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticFacilityFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(facility.Id, facility.Name, details.FolderId__c);
                } else if(!String.isBlank(staticFacilityFolderId)){
                    folderId = folderHandler.createBoxFolder(facility.Id, facility.Name, staticFacilityFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(facility.Id, folderId);
            } else {
                //create holding folder
                staticFacilityFolderId = folderHandler.createBoxFolder(FACILITY_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(facility.Id, facility.Name, staticFacilityFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(facility.Id, folderId);
            } 
        }
        
        return staticFacilityFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}