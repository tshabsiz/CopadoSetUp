public class BxdAgencyTransferService {
    private static String TRANSFER_FOLDER = 'Transfers';
    private static String AGREEMENT_LOOKUP = 'Agreement__c';
    private static String FACILITY_LOOKUP = 'Facility__c';
    private static String TRANCHE_LOOKUP = 'Facility_Tranche__c';
    private static FolderHandler folderHandler = new FolderHandler();    
    
    /**
    * createBoxFolderTrigger - prepares a set of agencyTransfer records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Agency_Transfer__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Agency_Transfer__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each agencyTransfer record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> recordsSet) {
        Agency_Transfer__c agencyTransfer;
        List<Agency_Transfer__c> recordsList = new List<Agency_Transfer__c>([SELECT Id, Name, Agreement__c, Facility__c, Facility_Tranche__c, RecordTypeId FROM Agency_Transfer__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c agencyTransferStructure;
        String parentFolderId;
        String customKey;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
                
        if(recordsList !=null && !recordsList.isEmpty())
        {
            agencyTransfer = recordsList[0];

            System.debug(' ## RECORD :'+agencyTransfer);

            String recordTypeName = Agency_Transfer__c.sObjectType.getDescribe().getRecordTypeInfosById().get(agencyTransfer.RecordTypeId).getName();

            System.debug(' ## RECORD TYPE:'+recordTypeName);

            agencyTransferStructure = folderHandler.getFolderStructure(recordTypeName);
            
            if(agencyTransfer != null && agencyTransferStructure != null && agencyTransfer.Agreement__c != null && agencyTransferStructure.Folder_Name__c != null){
                //
                TRANSFER_FOLDER = agencyTransferStructure.Folder_Name__c;
                System.debug('LOOKUP '+agencyTransferStructure.Parent_Lookup__c);
                if(AGREEMENT_LOOKUP.equals(agencyTransferStructure.Parent_Lookup__c)){
                    customKey = agencyTransfer.Agreement__c + ' - ' + TRANSFER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(agencyTransfer.Agreement__c);
                } else if(FACILITY_LOOKUP.equals(agencyTransferStructure.Parent_Lookup__c)){
                    customKey = agencyTransfer.Facility__c + ' - ' + TRANSFER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(agencyTransfer.Facility__c);
                } else if(TRANCHE_LOOKUP.equals(agencyTransferStructure.Parent_Lookup__c)){
                    customKey = agencyTransfer.Facility_Tranche__c + ' - ' + TRANSFER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(agencyTransfer.Facility_Tranche__c);
                }
                
                String queryWhere = '%' + agencyTransfer.Agreement__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                                        FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                  
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
        String staticTransferFolderId;
        for (Agency_Transfer__c transferObject : recordsList) {
            staticTransferFolderId = createBoxFolderForRecord(transferObject, parentFolderId, staticTransferFolderId, customKey, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticTransferFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticTransferFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for agencyTransfer record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(Agency_Transfer__c agencyTransfer, String parentFolderId, String staticTransferFolderId, String customKey, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(agencyTransfer != null && !String.isBlank(parentFolderId)){
            String folderId;
            
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticTransferFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(agencyTransfer.Id, agencyTransfer.Name, details.FolderId__c);
                } else if(!String.isBlank(staticTransferFolderId)){
                    folderId = folderHandler.createBoxFolder(agencyTransfer.Id, agencyTransfer.Name, staticTransferFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(agencyTransfer.Id, folderId);
            } else {
                //create holding folder
                staticTransferFolderId = folderHandler.createBoxFolder(TRANSFER_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(agencyTransfer.Id, agencyTransfer.Name, staticTransferFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(agencyTransfer.Id, folderId);
            } 
        }
        
        return staticTransferFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}